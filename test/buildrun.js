// Actual Build/Run engine and scanner, with banked DSS file I/O and failures.
// Run after the canonical build: node test/buildrun.js
const assert=require('assert');
const {machine,sym}=require('./console.js');
let pass=0,fail=0;
function check(name,f){try{f();pass++;console.log('ok - '+name);}catch(e){fail++;console.log('FAIL - '+name+': '+e.message.slice(0,350));}}
const cstr=(m,a)=>{let s='';for(let n=0;n<256;n++){const c=m.rd(a+n);if(!c)return s;s+=String.fromCharCode(c);}throw Error('Unterminated string');};
const put=(m,a,s)=>{for(const [i,c]of Buffer.from(s+'\0','latin1').entries())m.wr(a+i,c);};
function project(files={},options={}){
 const m=machine(),opened=[],executed=[],messages=[];let cwd='C:\\WORK',handle=0,reads=0;const handles=new Map();
 const directory='C:\\PROJECT';
 m.banks[2]=10;m.wr(0x8027,1);m.wr(sym.TxtWtab,0x40);m.wr(sym.TxtWtab+0x26,0x80);m.wr(sym.TxtWtab+0x1d,10);m.wr(sym.TxtWtab+0x1e,11);
 m.banks[2]=2;put(m,sym.NameTab,options.name||'c:\\PROJECT\\MAIN.ASM');m.banks[2]=10;
 const clobber=s=>{s.h=0xde;s.l=0xad;s.b=0xba;s.c=0xd0;s.ix=0xbeef;s.iy=0xd00d;if(options.hostile!==false)m.banks[3]=9;};
 m.dss(s=>{
  const c=s.c,hl=s.h<<8|s.l;let a=0,de=null,carry=0;
  if(![2,0x1e,0x1d,0x11,0x12,0x13,0x40].includes(c))return false;
  assert.strictEqual(m.banks[0],8);
  if(c===2)a=2;
  if(c===0x1e){if(options.hostile!==false)assert(hl<0x8000,'CurDir destination must be resident');put(m,hl,cwd.slice(2));}
  if(c===0x1d){assert(hl<0x8000,'ChDir argument must be resident');const path=cstr(m,hl);if((options.badDir&&path===directory)||(options.restoreError&&path==='C:\\WORK')){a=4;carry=1;}else cwd=path;}
  if(c===0x11){const name=cstr(m,hl).toUpperCase();opened.push(name);assert.strictEqual(cwd,directory);if(options.openError){a=options.openError;carry=1;}else if(!(name in files)){a=3;carry=1;}else{a=++handle;handles.set(a,{bytes:Buffer.from(files[name]),pos:0});}}
  if(c===0x12){assert(handles.has(s.a),'Unknown file handle');handles.delete(s.a);if(options.closeError){a=6;carry=1;}}
  if(c===0x13){reads++;const f=handles.get(s.a);assert(f);if(reads===options.readErrorAt){a=5;carry=1;de=0xbeef;}else{const n=Math.min(s.d<<8|s.e,f.bytes.length-f.pos);for(let i=0;i<n;i++)m.wr(hl+i,f.bytes[f.pos++]);de=n;a=n<512?255:0;}}
  if(c===0x40){assert(hl<0x8000,'EXEC argument must be resident');executed.push({command:cstr(m,hl),cwd});cwd='C:\\CHILD';a=options.exitCode||0;carry=+!!options.execError;}
  clobber(s);s.a=a;s.flags.C=carry;if(de!==null){s.d=de>>>8;s.e=de&255;}return true;
 });
 m.hooks.BldMessage=()=>messages.push(cstr(m,m.cpu.getState().h<<8|m.cpu.getState().l));
 let waits=0;m.hooks.BldWaitKode=()=>{waits++;};
 m.hooks.DialogW=()=>{m.wr(sym.what,4);m.wr(sym.what+1,options.cancelTarget?0x37:0x36);m.wr(sym.what+2,options.targetIndex||0);};
 function scan(text,mode=0){files.MAKEFILE=text;put(m,sym.BldDirBuf,directory);m.call('BldDosIn');const guard=Buffer.from(m.ram.subarray(0x7a00,0x7b00));const result=m.call('BldScanMk',{a:mode});assert.deepStrictEqual(Buffer.from(m.ram.subarray(0x7a00,0x7b00)),guard,'Target list overflow');m.call('BldDosOut');return {result,list:cstr(m,0x7900)};}
 return {...m,files,opened,executed,messages,scan,cwd:()=>cwd,handles,reads:()=>reads,waits:()=>waits};
}
for(const [action,files,command]of [
 ['BldDoBuild',{'BUILD.BAT':'echo build','MAKEFILE':'all:\n'},'SYSTEM.EXE /C BUILD.BAT'],
 ['BldDoBuild',{'MAKEFILE':'all:\n'},'MAKE.EXE'],
 ['BldDoRun',{'RUN.BAT':'echo run','MAKEFILE':'run:\n'},'SYSTEM.EXE /C RUN.BAT'],
 ['BldDoRun',{'MAKEFILE':'run : all\n'},'MAKE.EXE run']
])check(action+' launches '+command+' from project with hostile DSS',()=>{const m=project(files);m.call(action);assert.deepStrictEqual(m.executed,[{command,cwd:'C:\\PROJECT'}]);assert.strictEqual(m.cwd(),'C:\\WORK');assert.strictEqual(m.handles.size,0);assert.deepStrictEqual(m.banks,[0,1,10,3]);assert.strictEqual(m.cpu.getState().iy,0x8010);});
check('64 parameter characters preserve following constants',()=>{const m=project({'RUN.BAT':''},{hostile:false});const saved=Buffer.from(Array.from({length:12},(_,i)=>m.rd(sym.BldNBat+i)));m.hooks.DialogW=()=>{put(m,0x7905,'x'.repeat(64));m.wr(0x7904,64);m.wr(sym.what,4);m.wr(sym.what+1,0x36);};m.call('BldDoParm');assert.deepStrictEqual(Buffer.from(Array.from({length:12},(_,i)=>m.rd(sym.BldNBat+i))),saved);m.call('BldDoRun');assert.strictEqual(m.executed[0].command,'SYSTEM.EXE /C RUN.BAT '+'x'.repeat(64));});
for(const padding of [0,510,511])check('Target scanning across chunk boundary '+padding,()=>{const m=project({}, {hostile:false}),prefix=padding?'#'+'x'.repeat(padding-2)+'\n':'';const {result,list}=m.scan(prefix+'abcdefghijklmnopqrstuvwx:\nrun\t : all\nVAR:=text\n');assert.strictEqual(result.flags.C,0);assert.strictEqual(list,'abcdefghijklmnopqrstuvwx\rrun\r');});
check('Target list never overwrites the next scratch buffer',()=>{const m=project({}, {hostile:false});m.ram.fill(0xa5,0x7a00,0x7b00);const text=Array.from({length:9},(_,i)=>String(i).padStart(24,'x')+':\n').join('')+'a'.repeat(13)+':\n'+'b'.repeat(24)+':\n';m.scan(text);});
for(const readErrorAt of [1,2])check('Read error '+readErrorAt+' aborts scan and closes handle',()=>{const m=project({}, {hostile:false,readErrorAt});const {result}=m.scan('#'+'x'.repeat(600)+'\nrun:\n');assert.strictEqual(result.flags.C,1);assert.strictEqual(m.handles.size,0);assert.strictEqual(m.cwd(),'C:\\WORK');});
check('run:= is a variable, not a Run target',()=>{const m=project({'MAKEFILE':'run:=value\nall:\n'},{hostile:false});m.call('BldDoRun');assert.strictEqual(m.executed.length,0);});
check('Failed project ChDir never launches in the old directory',()=>{const m=project({'BUILD.BAT':''},{hostile:false,badDir:true});m.call('BldDoBuild');assert.strictEqual(m.executed.length,0);assert.strictEqual(m.opened.length,0);assert.strictEqual(m.cwd(),'C:\\WORK');assert(m.messages.some(s=>/project dir/i.test(s)));});
check('Open error does not silently fall back to another command',()=>{const m=project({'BUILD.BAT':'','MAKEFILE':'all:\n'},{hostile:false,openError:5});m.call('BldDoBuild');assert.strictEqual(m.opened.length,1);assert.strictEqual(m.executed.length,0);assert(m.messages.some(s=>/error/i.test(s)));});
check('Cancelled save blocks the resumed Build',()=>{const m=project({'BUILD.BAT':''},{hostile:false});m.wr(sym.BldSkip,1);m.wr(0x8027,0);const s=m.call('BldAskSave');assert.strictEqual(s.a,1);});

for(const [name,expected]of [['c:\\MAIN.ASM','C:\\'],['c:\\'+'LONGDIR\\'.repeat(12)+'MAIN.ASM','C:\\'+'LONGDIR\\'.repeat(12).slice(0,-1)],['UNTITLED','']])check('Full project directory: '+name,()=>{const m=project({}, {name});m.call('BldGetDir');assert.strictEqual(cstr(m,sym.BldDirBuf),expected);assert.strictEqual(m.banks[2],10);});
for(const [exitCode,execError]of [[0,false],[7,false],[3,true]])check('MAKE child status '+exitCode+' loadError='+execError,()=>{const m=project({'MAKEFILE':'run:\n'},{exitCode,execError});m.call('BldDoRun');assert.strictEqual(m.executed.length,1);assert.strictEqual(m.waits(),exitCode&&!execError?1:0);assert.strictEqual(m.cwd(),'C:\\WORK');assert.deepStrictEqual(m.banks,[0,1,10,3]);if(execError)assert(m.messages.some(x=>x==='Exec error 3'));});
for(const action of ['BldDoBuild','BldDoRun','BldDoTarg'])check(action+' with missing files preserves editor',()=>{const m=project();m.call(action);assert.strictEqual(m.executed.length,0);assert.strictEqual(m.cwd(),'C:\\WORK');assert.strictEqual(m.messages.length,1);assert.strictEqual(m.handles.size,0);});
for(const cancelTarget of [false,true])check('Target choice cancel='+cancelTarget,()=>{const m=project({'MAKEFILE':'all:\nclean:\nrun:\n'},{targetIndex:1,cancelTarget});m.call('BldDoTarg');assert.strictEqual(m.executed.length,cancelTarget?0:1);if(!cancelTarget)assert.strictEqual(m.executed[0].command,'MAKE.EXE clean');assert.strictEqual(m.cwd(),'C:\\WORK');});
check('Invalid target index cannot walk outside the list',()=>{const m=project({'MAKEFILE':'all:\n'},{targetIndex:1});m.call('BldDoTarg');assert.strictEqual(m.executed.length,0);});
check('Failed cwd restoration is reported after editor restoration',()=>{const m=project({'BUILD.BAT':''},{restoreError:true});m.call('BldDoBuild');assert.strictEqual(m.executed.length,1);assert(m.messages.includes('Cannot restore directory'));assert.deepStrictEqual(m.banks,[0,1,10,3]);});
check('SaveAll stops after a failed save of the current file',()=>{const m=project();m.wr(0x8027,0);let saves=0;m.hooks.SaveFile=()=>{saves++;};m.call('SaveAll');assert.strictEqual(saves,1);assert.strictEqual(m.rd(0x8027),0);});
check('SaveAll failure in another window restores original window',()=>{const m=project();const tab=sym.TxtWtab;m.wr(tab+0x26,1);m.wr(tab+2*0x26,0x80);m.wr(tab+0x26+0x1d,12);m.ram[12*0x4000+0x27]=0;let saves=0,switches=0;m.hooks.SaveFile=()=>{saves++;};m.hooks.SetWind=()=>{switches++;const a=Buffer.from(Array.from({length:0x26},(_,i)=>m.rd(tab+i))),b=Buffer.from(Array.from({length:0x26},(_,i)=>m.rd(tab+0x26+i)));for(let i=0;i<0x26;i++){m.wr(tab+i,b[i]);m.wr(tab+0x26+i,a[i]);}m.banks[2]=m.rd(tab+0x1d);};m.call('SaveAll');assert.strictEqual(saves,1);assert.strictEqual(switches,2);assert.strictEqual(m.banks[2],10);});

for(const text of ['run:\r','run:\n','run:\r\n','RuN:','run \t: all\r\n','all:\r\nrun:\r\n'])check('Run target endings '+JSON.stringify(text),()=>{const m=project({'MAKEFILE':text});m.call('BldDoRun');assert.strictEqual(m.executed[0].command,'MAKE.EXE run');});
check('Long target crossing read boundary cannot corrupt command storage',()=>{const m=project({}, {hostile:false});const before=Buffer.from(Array.from({length:96},(_,i)=>m.rd(sym.BldCmdBuf+i)));const {list}=m.scan('#'+'x'.repeat(498)+'\n'+'a'.repeat(60)+':\nrun:\n');assert.strictEqual(list,'run\r');assert.deepStrictEqual(Buffer.from(Array.from({length:96},(_,i)=>m.rd(sym.BldCmdBuf+i))),before);});
for(const action of ['BldDoRun','BldDoTarg'])check(action+' aborts MAKEFILE read error without executing',()=>{const m=project({'MAKEFILE':'run:\n'},{readErrorAt:1});m.call(action);assert.strictEqual(m.executed.length,0);assert(m.messages.includes('File I/O error'));assert.strictEqual(m.handles.size,0);assert.strictEqual(m.cwd(),'C:\\WORK');});
check('Close error is reported without executing',()=>{const m=project({'BUILD.BAT':''},{closeError:true});m.call('BldDoBuild');assert.strictEqual(m.executed.length,0);assert(m.messages.includes('File I/O error'));});
for(const saved of [false,true])check('Full Build save/resume path saved='+saved,()=>{const m=project({'BUILD.BAT':''});m.wr(0x8027,0);let saves=0;m.hooks.DialogW=()=>{m.wr(sym.what,4);m.wr(sym.what+1,0x38);};m.hooks.SaveAll=()=>{saves++;if(saved)m.wr(0x8027,1);};m.banks[3]=11;m.call('BldBuild');assert.strictEqual(saves,1);assert.strictEqual(m.executed.length,saved?1:0);assert.deepStrictEqual(m.banks,[0,1,10,11]);});
check('Settings scratch fits its reserved page after relocation',()=>{const m=machine();const s=m.call('InitSetTxt');const end=s.d<<8|s.e;assert(end>=sym.SetupBuff&&end<=0xfffd);assert.strictEqual(sym.SynFileBuf,sym.SetupBuff);});
check('Target list excludes dynamic names, patterns and options',()=>{const m=project();const {list}=m.scan('$(BIN):\n%.o: %.c\n-n:\nall:\n');assert.strictEqual(list,'all\r');});
console.log(`PASS: ${pass} FAIL: ${fail}`);if(fail)process.exitCode=1;
