// Actual assembled console/BuildRun code, banked RAM and hostile BIOS/DSS mocks.
// Run after ./run/make.sh: node test/console.js
const fs = require('fs'), assert = require('assert');
global.window = {};
const Z80 = require('./Z80core.js');
const listing = fs.readFileSync('Build/KodeEXE.LST', 'utf8');
const sym = {}, loader = {};
let initial = false;
for (const line of listing.split('\n')) {
  const a = line.match(/^\s*\d+(\+*)\s*([0-9A-F]{4}) /);
  const label = line.slice(24).match(/^([A-Za-z][\w.]*)(?:[:\s]|$)/);
  if (line.includes(' MODULE InitialConsole')) initial = true;
  if (line.includes(' ENDMODULE')) initial = false;
  if (a && label && !/\bEQU\b/i.test(line.slice(24))) {
    if (a[1] === '++') sym[label[1]] = parseInt(a[2], 16);
    else if (initial) loader[label[1]] = parseInt(a[2], 16);
    else if (a[1] === '') loader[label[1]] = parseInt(a[2], 16);
  }
}
function machine() {
  const ram = new Uint8Array(16 * 0x4000), banks = [0, 1, 2, 3];
  ram.set(fs.readFileSync('build/bin/KodeMain.bin'));
  ram.set(fs.readFileSync('build/bin/DialogWN.bin'), 2 * 0x4000);
  ram.set(fs.readFileSync('build/bin/MenuBar.bin'), 4 * 0x4000);
  const pa = a => banks[(a & 65535) >>> 14] * 0x4000 + (a & 0x3fff);
  const rd = a => ram[pa(a)], wr = (a,v) => { ram[pa(a)] = v & 255; };
  const word = (a,v) => { wr(a,v); wr(a+1,v>>>8); };
  const u16 = a => rd(a) | rd(a+1)<<8;
  const ports = [0x82,0xa2,0xc2,0xe2];
  const serial = [];
  const cpu = new Z80({mem_read:rd,mem_write:wr,
    io_read:p => (p&255) === 0x19 ? (serial.length ? 1 : 0) : (p&255) === 0x18 ? serial.shift() : banks[ports.indexOf(p&255)] ?? 0,
    io_write:(p,v) => { const i=ports.indexOf(p&255); if(i>=0) banks[i]=v; }
  });
  for (const [n,v] of Object.entries({DOSpage:8,BldDosPg:8,BldLogPg:7,BldTrS3:3,DialogPg1:2,DialogPg2:3,CnTxtPg:4})) wr(sym[n],v);
  const screens=[Buffer.alloc(5120),Buffer.alloc(5120)];
  let mode=3,page=0,pos=0,editor=null,exec=()=>({code:0}), mouse=()=>{}, scan=null, biosTrap=()=>false, dssTrap=()=>false, stopped=false;
  const events=[], hooks={};
  const ret=s=>{s.pc=u16(s.sp);s.sp=(s.sp+2)&65535;cpu.setState(s);};
  function dss() {
    const s=cpu.getState(),c=s.c,hl=s.h<<8|s.l;
    if(dssTrap(s)){ret(s);return;}
    if(c===0x89){screens[page].fill(0);pos=0;ret(s);return;}
    assert.strictEqual(banks[0],8,'DSS needs DOS in SLOT0');
    events.push(c); s.flags.C=0;
    if(c===0x51){s.a=mode;s.b=page;}
    else if(c===0x50){mode=s.a;page=s.b;pos=0;}
    else if(c===0x53){s.d=pos>>>8;s.e=pos&255;}
    else if(c===0x52){pos=s.d<<8|s.e;}
    else if(c===0x02){s.a=2;}
    else if(c===0x1e){wr(hl,92);wr(hl+1,0);}
    else if(c===0x1d){}
    else if(c===0x40){const r=exec();s.a=r.code;s.flags.C=+!!r.loadError;}
    else if(c===0x5c){for(let i=0;rd(hl+i);i++) screens[page][(pos++*2)%5120]=rd(hl+i);}
    else if(c===0x89){screens[page].fill(0);pos=0;}
    else throw new Error('DSS #'+c.toString(16));
    // Real services use IY and can return with their own system page in SLOT3.
    if(c!==0x02 && c!==0x1e) banks[3]=9;s.ix=0xbabe;s.iy=0xd00d;s.h=0xde;s.l=0xad;
    ret(s);
  }
  function bios(){
    const s=cpu.getState(),fn=s.c;
    if(biosTrap(s)){ret(s);return;}
    assert([0xb2,0xb3].includes(fn),'Unexpected BIOS call');
    assert.strictEqual(s.sp>>>14,2,'BIOS repages SLOT1: stack must be in SLOT2');
    assert.strictEqual(banks[2],s.b,'The unused tail of the snapshot page holds the stack');
    assert.strictEqual(s.h<<8|s.l,0x2050,'Full physical width, including doubled 40-column glyphs');
    assert.strictEqual(s.d<<8|s.e,0); assert.strictEqual(s.ix,0xc000);
    if(fn===0xb2) ram.set(screens[page],s.b*0x4000);
    else screens[page].set(ram.subarray(s.b*0x4000,s.b*0x4000+5120));
    events.push(fn);pos=0; banks[3]=9;s.ix=0xbabe;s.iy=0xd00d;ret(s);
  }
  hooks.ResCurs=()=>{};
  hooks.GetBuff=()=>{editor={mode,page,pos,screen:Buffer.from(screens[page])};};
  hooks.PutBuff=()=>{screens[page].set(editor.screen);pos=editor.pos;};
  for(const n of ['InitBar','ResMBar','InitStLine','SetCurs','InitEvent']) hooks[n]=()=>{};
  hooks.GetMousInfo=()=>mouse();
  function call(label, regs={}, limit=500000){
    stopped=false;
    const s=cpu.getState();Object.assign(s,{pc:sym[label]??loader[label],sp:0x7ff0,ix:0x1234,iy:0x8010},regs);
    assert(s.pc!==undefined,label);word(s.sp,0x7ff8);cpu.setState(s);
    for(let n=0;n<limit;n++) {
      const t=cpu.getState(); if(t.pc===0x7ff8 || stopped) return t;
      const name=Object.keys(hooks).find(k=>t.pc===(/^\d+$/.test(k)?Number(k):sym[k]??loader[k]));
      if(name){hooks[name]();ret(cpu.getState());}
      else if(t.pc===sym.ScanDrv && scan){scan();ret(t);}
      else if(t.pc===0x10) dss();
      else if(t.pc===0x08) bios();
      else if(t.pc===0x00){wr(sym.MSbutt,0);ret(t);}
      else if(t.pc===0x30){ret(t);}
      else cpu.run_instruction();
    }
    throw new Error('Timeout '+label+' PC='+cpu.getState().pc.toString(16));
  }
  return {ram,banks,rd,wr,word,cpu,call,hooks,events,screens,serial,
    state:()=>({mode,page,pos,screen:Buffer.from(screens[page])}),
    video:(m,p,c)=>{mode=m;page=p;pos=c;},
    bios:f=>{biosTrap=f;}, dss:f=>{dssTrap=f;}, stop:()=>{stopped=true;}, child:f=>{exec=f;}, mouse:f=>{mouse=f;}, scan:f=>{scan=f;}, sym};
}
let pass=0;
function check(name,f){f();pass++;console.log('ok - '+name);}
const pattern=n=>Buffer.from(Array.from({length:5120},(_,i)=>(i*17+n)&255));
for(const mode of [2,3]) for(const page of [0,1]) {
  check(`full console mode ${mode}, video page ${page}, bottom-right cursor`,()=>{
    const m=machine();m.video(mode,page,0x1f00+(mode===2?39:79));m.screens[page].set(pattern(43));
    const before=m.state(),banks=[...m.banks];const grab=m.call('ConsoleGrab');
    assert.deepStrictEqual(m.state(),before,'Capture must restore cursor');
    assert.deepStrictEqual(m.banks,banks);assert.strictEqual(grab.iy,0x8010);assert.strictEqual(grab.ix,0x1234);
    m.video(3,1-page,0);m.screens[page].fill(0);const restored=m.call('ConsoleRestore');
    assert.deepStrictEqual(m.state(),before);assert.deepStrictEqual(m.banks,banks);
    assert.strictEqual(restored.iy,0x8010);assert.strictEqual(restored.ix,0x1234);
    assert.deepStrictEqual(m.events,[0x51,0x53,0xb2,0x52,0x50,0xb3,0x52]);
  });
}
check('unready console is a no-op',()=>{const m=machine(),old=m.state();m.call('ConsoleRestore');assert.deepStrictEqual(m.state(),old);assert.deepStrictEqual(m.events,[]);});
check('initial loader captures the same screen before editor code',()=>{
 const m=machine(),exe=fs.readFileSync('build/KODE.EXE');
 m.ram.set(exe.subarray(exe.readUInt32LE(4),exe.readUInt32LE(4)+exe.readUInt16LE(8)),exe.readUInt16LE(16));
 // The loader still resides in its original SLOT1; it calls DSS directly.
 m.banks[0]=8;m.word(loader['ModulesPages']+7,7);m.video(2,1,0x1f27);m.screens[1].set(pattern(89));
 const before=m.state(),banks=[...m.banks];const captured=m.call('ConsoleGrab',{pc:loader.ConsoleGrab});assert.deepStrictEqual(m.state(),before);assert.deepStrictEqual(m.banks,banks);assert.strictEqual(captured.ix,0x1234);assert.strictEqual(captured.iy,0x8010);
 assert.deepStrictEqual(Buffer.from(m.ram.subarray(7*0x4000,7*0x4000+5120)),before.screen);
});
const startups = ['allocation', 'read'].map(failure=>({failure,mode:2,page:1,pos:0x1f27}));
for(const mode of [2,3]) for(const page of [0,1]) for(const pos of [0x0507,0x1f00+(mode===2?39:79)]) startups.push({mode,page,pos});
for (const {failure,mode,page,pos} of startups) check('loader banner/metadata: '+(failure||`mode ${mode}, page ${page}, cursor ${pos.toString(16)}`),()=>{
 const m=machine(),exe=fs.readFileSync('build/KODE.EXE');
 m.banks[0]=8;m.banks[1]=14;
 m.ram.set(exe.subarray(exe.readUInt32LE(4),exe.readUInt32LE(4)+exe.readUInt16LE(8)),14*0x4000+(exe.readUInt16LE(16)&0x3fff));
 m.video(mode,page,pos);m.screens[page].set(pattern(54));const initial=m.state();let reads=0,freed=0,exited=false,printed=0,expected=null;
 const modules=['Prepare','KodeMain','DialogWN','MenuBar','Command'];
 m.bios(s=>{
  if(s.c===0xc2){assert.strictEqual(s.b,8);s.a=42;s.flags.C=+(failure==='allocation');return true;}
  if(s.c===0xc5){for(let i=0;i<8;i++)m.wr((s.h<<8|s.l)+i,i);s.flags.C=0;return true;}
  if(s.c===0xc3){assert.strictEqual(s.a,42);freed++;return true;}
  return false;
 });
 m.dss(s=>{
  const hl=s.h<<8|s.l;
  if(s.c===0x5c){
   printed++;assert.deepStrictEqual(m.state(),initial,'Banner starts at the original cursor');
   const bytes=[];for(let i=0;m.rd(hl+i);i++)bytes.push(m.rd(hl+i));
   const banner=Buffer.from(bytes).toString('latin1');
   assert(/^Kode v 0\.1\.1, Sprinter Team, \d{2}\.\d{2}\.\d{4}\r\n$/.test(banner),banner);
   const columns=mode===2?40:80,physical=80/columns;let x=pos&255,y=pos>>>8,scrolls=0;
   const nextLine=()=>{if(++y===32){m.screens[page].copyWithin(0,160);m.screens[page].fill(0,4960);y=31;scrolls++;}};
   for(const c of bytes){
    if(c===13)x=0;
    else if(c===10)nextLine();
    else {for(let j=0;j<physical;j++)m.screens[page][(y*80+x*physical+j)*2]=c;if(++x===columns){x=0;nextLine();}}
   }
   assert.strictEqual(scrolls,pos>>>8===31?Math.floor(((pos&255)+bytes.length-2)/columns)+1:0);
   m.video(mode,page,y<<8|x);expected=m.state();
   if(pos>>>8!==31){
    assert.strictEqual(expected.screen[(5*80+7*physical)*2],'K'.charCodeAt(0));
    assert.deepStrictEqual(expected.screen.subarray(0,(5*80+7*physical)*2),initial.screen.subarray(0,(5*80+7*physical)*2));
   }
   m.banks[3]=9;s.ix=0xbabe;s.iy=0xd00d;s.h=0xde;s.l=0xad;s.flags.C=0;return true;
  }
  if(s.c===0x41){exited=true;m.stop();return true;}
  if(s.c===0x13){
   if(failure==='read'){s.flags.C=1;return true;}
   const packed=fs.readFileSync('build/bin/HRUST/'+modules[reads++]+'.hst');
   assert.strictEqual(s.d<<8|s.e,packed.length);
   for(let i=0;i<packed.length;i++)m.wr(hl+i,packed[i]);s.flags.C=0;return true;
  }
  if(s.c===0x47){m.wr(hl,0);s.flags.C=0;return true;}
  if(s.c===0x02){s.a=2;return true;}
  if(s.c===0x1e){m.wr(hl,92);m.wr(hl+1,0);return true;}
  if(s.c===0x1d || s.c===0x12) return true;
  if(s.c===0x11){s.flags.C=1;return true;}
  return false;
 });
 m.hooks[0x9000]=()=>{assert.strictEqual(printed,1);assert.deepStrictEqual(m.state(),expected);m.screens[page].fill(32);m.video(mode,page,0);};
 m.hooks.KodeStart=()=>{m.stop();};
 m.call('exeLoader.Start',{pc:loader['exeLoader.Start'],ix:0x7980},4000000);
 if(failure){assert.strictEqual(printed,0);assert(exited);assert.deepStrictEqual(m.state(),initial);assert.strictEqual(freed,failure==='read'?1:0);}
 else {
  const main=fs.readFileSync('build/bin/KodeMain.bin');
  assert.deepStrictEqual(Buffer.from(m.ram.subarray(main.length-256,main.length)),main.subarray(main.length-256),'Loader return stack must not overwrite the end of Main');
  assert.strictEqual(reads,5);assert.strictEqual(m.rd(sym.BldLogPg),7);assert.strictEqual(m.rd(sym.BldDosPg),8);
  m.banks[3]=3;assert.strictEqual(m.rd(sym.ConsoleReady),1);assert.strictEqual(m.rd(sym.ConsoleMode),mode);
  assert.strictEqual(m.rd(sym.ConsolePage),page);assert.strictEqual(m.rd(sym.ConsolePos),expected.pos&255);assert.strictEqual(m.rd(sym.ConsolePos+1),expected.pos>>>8);
  assert.deepStrictEqual(Buffer.from(m.ram.subarray(7*0x4000,7*0x4000+5120)),expected.screen);
  m.call('ConsoleRestore');assert.deepStrictEqual(m.state(),expected,'Restoration includes banner and its ending cursor');
 }
});
check('initial list selection uses context, not its hotkey',()=>{
 const m=machine();let context=null;
 m.banks[2]=2;m.wr(sym.DialTab+5+0x0f,0x54);m.wr(sym.DialTab+5+0x10,0x3c);
 m.hooks.SetDialInv=()=>{};m.hooks.StLstBoxI=()=>{};
 m.hooks.PutStatusLn=()=>{context=m.cpu.getState().a;};
 m.call('PLstBoxI',{ix:sym.DialTab+5});assert.strictEqual(context,0x3c);
});
check('DOS directory restoration preserves the target list',()=>{
 const m=machine();const list=Buffer.from('all\rclean\r\0');
 for(let i=0;i<list.length;i++)m.wr(0x7900+i,list[i]);
 m.call('BldDosIn');m.call('BldDosOut');
 assert.deepStrictEqual(Buffer.from(Array.from({length:list.length},(_,i)=>m.rd(0x7900+i))),list);
});
check('two children resume prior output; nonzero message is captured',()=>{
 const m=machine();m.video(2,1,0x0403);m.screens[1].set(pattern(30));m.call('ConsoleGrab');
 const first=m.state();m.video(3,0,0x0907);m.screens[0].set(pattern(20));const editor=m.state();
 for(let n=0;n<2;n++){
  m.call('BldSaveEditor');m.call('ConsoleRestore');
  assert.strictEqual(m.state().pos,n===0?first.pos:first.pos+1);
  m.banks[0]=8;m.child(()=>{m.screens[1][m.state().pos*2]=65+n;m.video(2,1,m.state().pos+1);return {code:n?7:0};});
  m.call('BldExecCon');
  m.banks[0]=0;m.call('ConsoleGrab');m.call('BldReInit');assert.deepStrictEqual(m.state(),editor);
 }
 m.call('ConsoleRestore');assert.strictEqual(m.screens[1][first.pos*2],65);assert.strictEqual(m.screens[1][(first.pos+1)*2],66);
 assert(Buffer.from(Array.from({length:28},(_,i)=>m.screens[1][(first.pos+2+i)*2])).toString('latin1').startsWith('Exit code 7 - press any key')); 
 assert.strictEqual(m.rd(sym.BldErr),7);assert.strictEqual(m.rd(sym.ScanDown),0);
});
for(const action of ['BldDoBuild','BldDoRun','BldDoTarg']) for(const kind of ['success','child error','load error','no command','cancel']) {
 check(`${action}: ${kind}`,()=>{
  const m=machine();m.screens[0].set(pattern(70));m.video(2,0,0x0102);m.call('ConsoleGrab');
  const log=Buffer.from(m.ram.subarray(7*0x4000,7*0x4000+5120)),metadata=Buffer.from(m.ram.subarray(3*0x4000+(sym.ConsoleState&0x3fff),3*0x4000+(sym.ConsoleState&0x3fff)+5));
  m.video(3,1,0x0907);m.screens[1].set(pattern(10));const editor=m.state();let ran=0,wait=0;
  m.hooks.BldAskSave=()=>{const s=m.cpu.getState();s.a=kind==='cancel'?1:0;m.cpu.setState(s);};
  m.hooks.BldGetDir=()=>{};
  m.banks[2]=10;m.ram.fill(0x5a,10*0x4000,11*0x4000);
  const window=Buffer.from(m.ram.subarray(10*0x4000,11*0x4000));
  m.hooks.SetCurs=()=>assert.strictEqual(m.cpu.getState().iy,0x8010);
  m.hooks.BldDecide=()=>{const s=m.cpu.getState();s.a=kind==='no command'?1:0;m.cpu.setState(s);};
  m.hooks.BldScanMk=()=>{const s=m.cpu.getState();s.a=1;s.flags.C=+(kind==='no command');m.cpu.setState(s);};
  m.hooks.DialogW=()=>{m.wr(sym.what,4);m.wr(sym.what+1,kind==='cancel'?0x37:0x36);m.wr(sym.what+2,0);};
  m.hooks.BldNthTgt=()=>{m.wr(sym.BldTgtName,0);};m.hooks.BldMessage=()=>{};
  m.hooks.BldWaitKode=()=>{wait++;};
  m.wr(sym.ScanDown,0x44);
  m.child(()=>{ran++;if(kind==='load error')return{code:3,loadError:true};m.screens[0][0]=90;return{code:kind==='child error'?9:0};});
  m.call(action);assert.deepStrictEqual(Buffer.from(m.ram.subarray(10*0x4000,11*0x4000)),window);assert.deepStrictEqual(m.state(),editor);assert.strictEqual(ran,['no command','cancel'].includes(kind)?0:1);
  assert.strictEqual(wait,kind==='child error'?1:0);
  if(ran) assert.strictEqual(m.rd(sym.ScanDown),0,'DSS can consume a key release on failed EXEC too');
  if(['no command','cancel','load error'].includes(kind)){
   assert.deepStrictEqual(Buffer.from(m.ram.subarray(7*0x4000,7*0x4000+5120)),log);
   assert.deepStrictEqual(Buffer.from(m.ram.subarray(3*0x4000+(sym.ConsoleState&0x3fff),3*0x4000+(sym.ConsoleState&0x3fff)+5)),metadata);
  }else assert.strictEqual(m.ram[7*0x4000],90);
 });
}
check('held mouse opening is preserved when hiding editor pointer',()=>{
 const m=machine();m.wr(sym.MSbutt,1);m.call('BldSaveEditor');assert.strictEqual(m.rd(sym.MSbutt),1);
});
for(const close of ['key','mouse']) check(`Show log consumes opening and closing ${close} events`,()=>{
 const m=machine();m.video(2,1,0x1f27);m.screens[1].set(pattern(23));m.call('ConsoleGrab');
 const log=Buffer.from(m.ram.subarray(7*0x4000,7*0x4000+5120));m.video(3,0,0x0708);m.screens[0].set(pattern(98));const editor=m.state();
 let tick=0,doneAt=0;
 m.wr(sym.ScanDown,0x44);m.wr(sym.ScanPress,2);m.wr(sym.MSbutt,1);
 m.scan(()=>{
  tick++;if(tick===2)m.wr(sym.ScanDown,0);
  if(tick===7&&close==='key'){m.wr(sym.ScanDown,0x29);m.wr(sym.ScanPress,3);}
  if(tick===10)m.wr(sym.ScanDown,0);
 });
 let poll=0;m.mouse(()=>{poll++;m.wr(sym.MSbutt,poll<3?1:close==='mouse'&&tick>=7&&poll<15?2:0);});
 m.hooks.InitEvent=()=>{doneAt=tick;assert.strictEqual(m.rd(sym.ScanDown),0);assert.strictEqual(m.rd(sym.MSbutt),0);};
 m.call('BldDoShow');assert(doneAt>=(close==='key'?10:7),'Must await a fresh press and its release');assert.deepStrictEqual(m.state(),editor);
 assert.deepStrictEqual(Buffer.from(m.ram.subarray(7*0x4000,7*0x4000+5120)),log);
});
check('PS/2 makes, repeats and releases are tracked by the real scan driver',()=>{
 const m=machine();m.call('ClearBuff');
 for(const [packet,press,down] of [[[0x44],1,0x44],[[0x44],1,0x44],[[0xf0,0x44],1,0],[[0x12],2,0x12],[[0xf0,0x12],2,0],[[0x29],3,0x29]]){
  m.serial.push(...packet);m.call('ScanDrv');assert.strictEqual(m.rd(sym.ScanPress),press);assert.strictEqual(m.rd(sym.ScanDown),down);
 }
});
check('Pause is a fresh press even though its PS/2 sequence has no ordinary break',()=>{
 const m=machine();m.call('ClearBuff');m.serial.push(0xe1,0x14,0x77,0xe1,0xf0,0x14,0xf0,0x77);
 m.call('ScanDrv');m.call('ScanDrv');assert.strictEqual(m.rd(sym.ScanPress),2);assert.strictEqual(m.rd(sym.ScanDown),0);
});
for(const cancel of [false,true]) check('editor exit '+(cancel?'cancel preserves editor':'restores console before freeing memory'),()=>{
 const m=machine();m.video(2,1,0x1f27);m.screens[1].set(pattern(11));m.call('ConsoleGrab');const saved=m.state();
 m.video(3,0,0x0506);m.screens[0].set(pattern(23));const editor=m.state();let freed=0;
 m.banks[3]=11;m.wr(sym.BuffInd,35);m.word(sym.SaveStk+1,0xf702);m.ram[0x4000+0x3702]=0xf8;m.ram[0x4000+0x3703]=0x7f;
 m.hooks.CloseAll=()=>{if(cancel)m.stop();};m.hooks.CloseGroup=()=>{};
 m.bios(s=>{if(s.c!==0xc3)return false;assert.strictEqual(s.a,35);assert.deepStrictEqual(m.state(),saved);freed++;return true;});
 m.call('exit');assert.strictEqual(freed,cancel?0:1);assert.deepStrictEqual(m.state(),cancel?editor:saved);
});
check('exit restores console through resident page switch',()=>{
 const m=machine();m.video(2,1,0x1f27);m.screens[1].set(pattern(11));m.call('ConsoleGrab');const saved=m.state();
 m.video(3,0,0);m.banks[3]=11;m.call('BldConsoleExit');assert.deepStrictEqual(m.state(),saved);assert.strictEqual(m.banks[3],11);
});
console.log('PASS: '+pass);
