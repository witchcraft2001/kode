// Execute the assembled syntax lexer and viewport renderer; measure Z80 T-states.
// Run after ./run/make.sh: node test/syntax.js [--bench]
const fs=require('fs'),assert=require('assert'),path=require('path');
const root=process.env.KODE_SYNTAX_BUILD||path.resolve(__dirname,'..');
global.window={};const Z80=require('./Z80core.js');
const sym={};
for(const line of fs.readFileSync(path.join(root,'Build/KodeEXE.LST'),'utf8').split('\n')){
 const a=line.match(/^\s*\d+\+\+([0-9A-F]{4}) /),n=line.slice(24).match(/^([A-Za-z][\w.]*)(?:[:\s]|$)/);
 if(a&&n&&!/\bEQU\b/i.test(line.slice(24)))sym[n[1]]=parseInt(a[1],16);
}
const B={text:0x7d00,recomp:0x7b00,iy:0x8010};
function machine({hostile=false,readFailure=false}={}){
 const ram=new Uint8Array(16*0x4000),banks=[0,1,10,11],ports=[0x82,0xa2,0xc2,0xe2];
 ram.set(fs.readFileSync(path.join(root,'build/bin/KodeMain.bin')));ram.set(fs.readFileSync(path.join(root,'build/bin/DialogWN.bin')),2*0x4000);
 const physical=a=>banks[(a&65535)>>>14]*0x4000+(a&0x3fff),rd=a=>ram[physical(a)],wr=(a,v)=>ram[physical(a)]=v&255;
 const word=(a,v)=>{wr(a,v);wr(a+1,v>>>8);},u16=a=>rd(a)|rd(a+1)<<8;
 const cpu=new Z80({mem_read:rd,mem_write:wr,io_read:p=>banks[ports.indexOf(p&255)]??0,io_write:(p,v)=>{const i=ports.indexOf(p&255);if(i>=0)banks[i]=v;}});
 const hooks={},opens=[];let file=null,cycles=0,directory='C:\\WORK\\';
 const ret=s=>{s.pc=u16(s.sp);s.sp=(s.sp+2)&65535;cpu.setState(s);};
 function dss(){
  const s=cpu.getState(),hl=s.h<<8|s.l;assert.strictEqual(banks[0],8);s.flags.C=0;
  if(s.c===0x02)s.a=2;
  else if(s.c===0x1e){for(let i=0;i<directory.length-2;i++)wr(hl+i,directory.charCodeAt(i+2));wr(hl+directory.length-2,0);}
  else if(s.c===0x1d){if(hostile)assert(hl<0x8000,'ChDir must use a resident argument');directory='';for(let a=hl;rd(a);a++)directory+=String.fromCharCode(rd(a));}
  else if(s.c===0x11){
   let name='';for(let a=hl;rd(a);a++)name+=String.fromCharCode(rd(a));opens.push(name);
   assert.strictEqual(directory,'C:\\KODE\\','Profiles must resolve beside KODE.EXE');
   const source=path.join(root,name.replace(/\\/g,'/').toLowerCase());file=fs.existsSync(source)?fs.readFileSync(source):null;s.a=1;s.flags.C=+!file;
  }else if(s.c===0x13){if(readFailure)s.flags.C=1;else{const n=Math.min(s.d<<8|s.e,file.length);for(let i=0;i<n;i++)wr(hl+i,file[i]);s.d=n>>>8;s.e=n&255;}}
  else if(s.c!==0x12)throw Error('DSS '+s.c.toString(16));
  s.h=0xde;s.l=0xad;s.b=0xba;s.c=0xd0;s.ix=0xbeef;s.iy=0x200;
  if(hostile)banks[3]=9;
  ret(s);
 }
 function call(name,regs={},limit=3000000){
  const s=cpu.getState();Object.assign(s,{pc:sym[name],sp:0x7ff0,iy:B.iy},regs);assert(s.pc!==undefined,name);word(s.sp,0x7ff8);cpu.setState(s);let spent=0;
  for(let i=0;i<limit;i++){
   const t=cpu.getState();if(t.pc===0x7ff8){cycles+=spent;return spent;}
   const h=Object.keys(hooks).find(k=>t.pc===sym[k]);
   if(h){hooks[h]();ret(cpu.getState());}
   else if(t.pc===0x10)dss();
   else spent+=cpu.run_instruction();
  }
  throw Error('Timeout '+name+' PC='+cpu.getState().pc.toString(16));
 }
 const setstr=(a,s)=>{for(const [i,c] of [...Buffer.from(s+'\0','latin1')].entries())wr(a+i,c);};
 for(const [n,v]of Object.entries({DialogPg1:2,DialogPg2:3,DOSpage:8,BuffPg5:5,ColTxtWin:0x17,ColSelTxt:0x4f,SynHghLght:1,CSMnemon:0x1f,CSLabel:0x1e,CSComment:0x1d,CSBrace:0x1b,CSString:0x1a,CSNumber:0x19}))wr(sym[n],v);
 banks[3]=3;setstr(sym.LaunchPathBuf,'C:\\KODE\\');banks[3]=11;
 function prepare(lines,name='test.asm',current=0,pages=[10,11],window=0){
  banks[2]=pages[0];banks[3]=pages[1];
  const descriptor=sym.TxtWtab+window*0x26;
  wr(descriptor,window===0?0x40:window);wr(descriptor+0x26,0x80);wr(descriptor+1,0);wr(descriptor+2,80);wr(descriptor+3,1);wr(descriptor+4,31);
  wr(descriptor+0x1d,pages[0]);wr(descriptor+0x1e,pages[1]);wr(descriptor+0x21,6);word(descriptor+0x1f,0);
  banks[2]=2;setstr(sym.NameTab+window*128,name);banks[2]=pages[0];
  let a=0x8040;const records=[];
  for(const line of lines){assert(line.length<=240);records.push(a);wr(a,line.length+3);wr(a+1,2);for(let i=0;i<line.length;i++)wr(a+2+i,line.charCodeAt(i));wr(a+2+line.length,line.length+3);a+=line.length+3;}
  wr(a,0);word(0x801e,records[0]);word(0x8024,records[current]);word(0x8032,0);word(0x801c,current);word(0x8022,a);wr(0x8026,1);
  wr(B.iy+1,current);wr(B.iy+3,1);wr(B.iy+4,2);wr(B.iy+5,78);wr(B.iy+6,28);wr(B.iy+7,0);
  call('ReCompileStr');return records;
 }
 function line(text,name='test.asm',attr=2,guard=true){
  const [record]=prepare([text],name);wr(record+1,attr);call('ReCompileStr');
  if(guard)for(let i=0;i<3;i++){wr(B.text+2*(text.length+3+i),'NOP'.charCodeAt(i));wr(B.text+2*(text.length+3+i)+1,0x17);}
  const before=Buffer.from(ram.subarray(0x7d00,0x7f00));const t=call('SyntaxExtTry');
  assert.deepStrictEqual(Buffer.from(ram.subarray(0x7d00,0x7f00)).filter((_,i)=>i%2===0),before.filter((_,i)=>i%2===0),'Characters changed');
  if(guard)assert.deepStrictEqual(Buffer.from(ram.subarray(0x7d00+text.length*2,0x7f00)),before.subarray(text.length*2),'Writes past line end');
  return {attrs:Array.from({length:text.length},(_,i)=>rd(B.text+2*i+1)),cycles:t};
 }
 return {ram,banks,rd,wr,word,call,cpu,hooks,prepare,line,opens,setstr,sym,cycles:()=>cycles,directory:()=>directory};
}
const colors={base:0x17,kw1:0x1f,kw2:0x1e,comment:0x1d,string:0x1a,number:0x19,bracket:0x1b};
let pass=0,fail=0;
function check(name,f){if(process.argv.includes('--bench-only'))return;try{f();pass++;console.log('ok - '+name);}catch(e){fail++;console.log('FAIL - '+name+': '+e.message.slice(0,500));}}
function expect(attrs,text,part,color,from=0){const at=text.indexOf(part,from);assert(at>=0);assert.deepStrictEqual(attrs.slice(at,at+part.length),Array(part.length).fill(colors[color]),part);}
check('ASM keywords preserve remaining count and line boundary',()=>{const m=machine(),text='LD A,1 : unknown ADD HL,BC ; comment',r=m.line(text);expect(r.attrs,text,'LD','kw1');expect(r.attrs,text,'ADD','kw1');expect(r.attrs,text,'A','kw2');expect(r.attrs,text,'1','number');expect(r.attrs,text,'; comment','comment');});
check('C strings protect comment delimiters and following code',()=>{const m=machine(),text='puts("http://host/*x*/"); int x; // comment',r=m.line(text,'test.c');expect(r.attrs,text,'"http://host/*x*/"','string');expect(r.attrs,text,'int','kw1');expect(r.attrs,text,'// comment','comment');});
check('C block ends on this line, code and second block follow',()=>{const m=machine(),text='/*one*/ int x; /*two*/ return 1;',r=m.line(text,'test.c');expect(r.attrs,text,'/*one*/','comment');expect(r.attrs,text,'int','kw1');expect(r.attrs,text,'/*two*/','comment');expect(r.attrs,text,'return','kw1');});
check('Empty line in C block does not overwrite buffer',()=>{const m=machine();m.prepare(['/* open','']);m.word(0x8024,0x8040+10);m.wr(B.iy+2,0);m.ram.fill(0xa5,0x7d00,0x7f00);m.call('SyntaxExtTry');assert(m.ram.subarray(0x7d00,0x7f00).every(v=>v===0xa5));});
check('All visible ASM lines are highlighted on first page render',()=>{const m=machine(),lines=['LD A,1','ADD HL,BC','JP label','NOP'];m.prepare(lines);m.call('InitPage');for(let row=0;row<lines.length;row++){const at=5*0x4000+10200+row*156;assert.deepStrictEqual([...m.ram.subarray(at,at+lines[row].length*2)].filter((_,i)=>i%2===0),[...Buffer.from(lines[row])]);const kw=lines[row].split(' ')[0];assert.deepStrictEqual(Array.from({length:kw.length},(_,i)=>m.ram[at+2*i+1]),Array(kw.length).fill(colors.kw1));}assert.strictEqual(m.opens.length,2,'One index and one profile load per render');});
check('DSS subdirectory paging preserves profile and editor pages',()=>{const m=machine({hostile:true});const r=m.line('LD A,1');expect(r.attrs,'LD A,1','LD','kw1');assert.deepStrictEqual(m.banks,[0,1,10,11]);assert.strictEqual(m.directory(),'C:\\WORK\\');});
check('Selected text keeps selection color',()=>{const m=machine(),text='LD A,1 ; test',r=m.line(text,'test.asm',0x42);assert(r.attrs.every(a=>a===0x4f));});
check('Disabled highlighting has no profile I/O',()=>{const m=machine();m.wr(sym.SynHghLght,0);const r=m.line('LD A,1');assert(r.attrs.every(a=>a===colors.base));assert.strictEqual(m.opens.length,0);});
for(const [name,text,part]of [['test.asm','DEFB "a;b" ; tail','"a;b"'],['test.pas',"writeln('{text} (*x*)'); begin", "'{text} (*x*)'"],['test.c','char *s = "quote\\\" // x"; return 1;', '"quote\\\" // x"']])check('Quoted comment delimiters: '+name,()=>{const m=machine(),r=m.line(text,name);expect(r.attrs,text,part,'string');});
check('Pascal both block types close before code',()=>{const m=machine(),text='{one} begin (*two*) end',r=m.line(text,'test.pas');expect(r.attrs,text,'{one}','comment');expect(r.attrs,text,'(*two*)','comment');expect(r.attrs,text,'begin','kw1');expect(r.attrs,text,'end','kw1');});
check('Pascal backslash does not escape a closing quote',()=>{const m=machine(),text="s := 'C:\\'; begin",r=m.line(text,'test.pas');expect(r.attrs,text,"'C:\\'",'string');expect(r.attrs,text,'begin','kw1');});
for(const [name,lines,lastword]of [['test.c',['/* open','', 'still */ int x;'],'int'],['test.pas',['(* open','', 'still *) begin'],'begin']])check('Block carries across empty lines: '+name,()=>{const m=machine();m.prepare(lines,name);m.call('InitPage');const at=5*0x4000+10200+2*156,text=lines[2],x=text.indexOf(lastword);assert.deepStrictEqual(Array.from({length:x-1},(_,i)=>m.ram[at+2*i+1]),Array(x-1).fill(colors.comment));assert.deepStrictEqual(Array.from({length:lastword.length},(_,i)=>m.ram[at+2*(x+i)+1]),Array(lastword.length).fill(colors.kw1));});
for(const [name,lines,lastword]of [['test.c',['puts("/*");','int x;'],'int'],['test.pas',["writeln('{');",'begin'],'begin']])check('Offscreen quoted delimiter does not open block: '+name,()=>{const m=machine(),records=m.prepare(lines,name,1);m.word(0x801e,records[1]);m.word(0x8032,1);m.call('InitPage');const at=5*0x4000+10200;assert.deepStrictEqual(Array.from({length:lastword.length},(_,i)=>m.ram[at+2*i+1]),Array(lastword.length).fill(colors.kw1));});
check('Block cache belongs to its text window',()=>{const m=machine(),first=m.prepare(['/* open','int x;'],'one.c',1);m.call('SyntaxExtTry');m.prepare(['normal','int x;'],'two.c',1,[12,13],1);m.call('SyntaxExtTry');const attrs=Array.from({length:6},(_,i)=>m.rd(B.text+2*i+1));expect(attrs,'int x;','int','kw1');});
check('Inactive window uses its own syntax profile',()=>{const m=machine();m.prepare(['LD A,1'],'one.asm');m.call('InitPage');m.prepare(['int x;'],'two.c',0,[12,13],1);m.call('InitPageRender');const at=5*0x4000+10200;assert.deepStrictEqual([m.ram[at+1],m.ram[at+3],m.ram[at+5]],Array(3).fill(colors.kw1));assert.strictEqual(m.opens.length,3);});
check('Two cached profiles switch without more I/O',()=>{const m=machine();m.line('LD A,1');m.line('int x;','test.c');const n=m.opens.length;m.line('LD A,1');m.line('int x;','test.c');assert.strictEqual(m.opens.length,n);});
check('Long identifier suffix is not a keyword',()=>{const m=machine(),text='a'.repeat(23)+'return',r=m.line(text,'test.c');assert(r.attrs.every(a=>a===colors.base));});
check('240-character line remains bounded',()=>{const m=machine(),text=('LD A,1 : '.repeat(27)).slice(0,240),r=m.line(text);assert.strictEqual(r.attrs.length,240);});
check('Numeric forms and identifier boundaries',()=>{const m=machine(),text='int123 return_value #defineNAME #BC $FA 0xA1 -12 +3',r=m.line(text,'test.c');for(const part of ['int123','return_value','#defineNAME'])expect(r.attrs,text,part,'base');for(const part of ['#BC','$FA','0xA1','-12','+3'])expect(r.attrs,text,part,'number');});
check('Missing profile stays plain and is negatively cached',()=>{const m=machine();let r=m.line('thing(12)','test.unknown');assert(r.attrs.every(a=>a===colors.base));const n=m.opens.length;r=m.line('thing(12)','test.unknown');assert(r.attrs.every(a=>a===colors.base));assert.strictEqual(m.opens.length,n);});
check('Profile read error leaves plain text and restores pages',()=>{const m=machine({hostile:true,readFailure:true}),r=m.line('LD A,1');assert(r.attrs.every(a=>a===colors.base));assert.deepStrictEqual(m.banks,[0,1,10,11]);assert.strictEqual(m.directory(),'C:\\WORK\\');});
for(const action of ['PrintPage','RefreshPage'])for(const scroll of [0,3])check(action+' renders all rows with horizontal scroll '+scroll,()=>{const m=machine(),lines=['LD A,1','ADD HL,BC','JP label','NOP'];m.prepare(lines,'test.asm',1);m.wr(B.iy+7,scroll);m.hooks.PrnTxtW=()=>{};m.hooks.SetCurs=()=>{};m.hooks.ResCurs=()=>{};m.call(action);for(let row=0;row<lines.length;row++){const at=6*0x4000+(row+1)*164+2,text=lines[row].slice(scroll);assert.deepStrictEqual(Array.from({length:text.length},(_,i)=>m.ram[at+i*2]),[...Buffer.from(text)]);if(!scroll)assert.strictEqual(m.ram[at+1],colors.kw1);}assert.strictEqual(m.rd(B.iy+7),scroll);assert.strictEqual(m.rd(B.iy+1),1);assert.strictEqual(m.rd(B.iy+2),lines[1].length);});
check('RefreshPage highlights unsaved current-line extension',()=>{const m=machine();m.prepare(['LD','NOP']);const edited='LD A,1';for(let i=0;i<edited.length;i++){m.wr(B.text+2*i,edited.charCodeAt(i));m.wr(B.text+2*i+1,colors.base);}m.wr(B.iy+2,edited.length);m.hooks.PrnTxtW=()=>{};m.hooks.SetCurs=()=>{};m.hooks.ResCurs=()=>{};m.call('RefreshPage');const at=6*0x4000+164+2;assert.strictEqual(m.ram[at+2*3+1],colors.kw2);assert.strictEqual(m.ram[at+2*5+1],colors.number);assert.strictEqual(m.rd(B.iy+2),edited.length);});
check('RefreshPage propagates an unsaved block opener to following rows',()=>{const m=machine();m.prepare(['x','int next;'],'test.c');m.wr(B.text,'/'.charCodeAt(0));m.wr(B.text+2,'*'.charCodeAt(0));m.wr(B.iy+2,2);m.hooks.PrnTxtW=()=>{};m.hooks.SetCurs=()=>{};m.hooks.ResCurs=()=>{};m.call('RefreshPage');const at=6*0x4000+2*164+2;assert.deepStrictEqual(Array.from({length:9},(_,i)=>m.ram[at+2*i+1]),Array(9).fill(colors.comment));});
for(const offscreen of [false,true])check('Overlapping C opener does not close a block, offscreen='+offscreen,()=>{const m=machine(),lines=['/*/','int x;'],records=m.prepare(lines,'test.c',offscreen?1:0);if(offscreen){m.word(0x801e,records[1]);m.word(0x8032,1);}m.call('InitPage');const at=5*0x4000+10200+(offscreen?0:156);assert.deepStrictEqual(Array.from({length:6},(_,i)=>m.ram[at+2*i+1]),Array(6).fill(colors.comment));});
for(const text of ['/', '*', '\"', '\"tail\\'])check('Lexer remains bounded at line end: '+JSON.stringify(text),()=>{machine().line(text,'test.c');});
check('RefreshPage respects a shortened unsaved current line',()=>{const m=machine();m.prepare(['LD A,1','NOP']);m.wr(B.iy+2,2);m.hooks.PrnTxtW=()=>{};m.hooks.SetCurs=()=>{};m.hooks.ResCurs=()=>{};m.call('RefreshPage');assert.strictEqual(m.rd(B.iy+2),2);assert.strictEqual(m.rd(B.text+2*5+1),colors.base);});
if(process.argv.includes('--bench')||process.argv.includes('--bench-only')){
 for(const [name,text]of [['asm','LD A,1 : ADD HL,BC ; comment'],['c','int value = 12; return value;']]){
  const m=machine();try{m.line(text,'test.'+name,2,false);const start=m.cycles();for(let i=0;i<100;i++)m.line(text,'test.'+name,2,false);console.log('BENCH',name,(m.cycles()-start)/100,'T-states per cached line including decompile');}catch(e){console.log('BENCH',name,'failed:',e.message.slice(0,100));}
 }
 for(const [name,text]of [['asm','LD A,1 : ADD HL,BC ; comment'],['c','int value = 12; return value;']]){const m=machine();try{m.prepare(Array(28).fill(text),'test.'+name);m.call('InitPage');const start=m.cycles();for(let i=0;i<20;i++)m.call('InitPage');console.log('BENCH viewport',name,(m.cycles()-start)/20,'T-states per 28 lines');}catch(e){console.log('BENCH viewport',name,'failed:',e.message.slice(0,100));}}
}
console.log(`PASS: ${pass} FAIL: ${fail}`);if(fail)process.exitCode=1;
