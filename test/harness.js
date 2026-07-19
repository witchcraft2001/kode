// Run kode's CMDTEST.EXE (test/cmdtest.asm, a shim around CmdLineOpen in
// Dialog_Windows/Cmdline.asm) under a Z80 core with a stubbed DSS and a
// virtual filesystem, to unit-test command-line file-open parsing on a host
// machine without a Sprinter emulator.
//
//   node harness.js <CMDTEST.EXE> <src-dir> <cmdline>
//
// The virtual disk is C:, current dir C:\WORK, and <src-dir> is mounted as
// that directory (files/subdirs present there are what Dss.Open/Dss.Create
// can see). <cmdline> is the argument text CmdLineOpen parses (e.g.
// "TEST.TXT"). Prints the shim's report line to stdout:
//   A=<0|1|2> NAME=<absolute path built by CmdLineOpen>
//
// Forked from /Users/dmitry/dev/zx/sprinter/sources/sprinter-lha/test/harness.js
// (same emulator, paging model, and DSS stub technique); the DSS switch here
// only needs Open/Close/CurDisk/CurDir, no archiver-specific calls.
//
// Z80core.js is Molly Howell's MIT-licensed Z80 emulator.
const fs = require('fs');
const path = require('path');
global.window = {};
const Z80 = require('./Z80core.js');

const EXE = process.argv[2];
const SRCDIR = process.argv[3];
const CMDLINE = process.argv[4] || '';

// ---- paged memory (4 windows x 16 KB, banks selected via ports) ----
const mem = new Uint8Array(64 * 0x4000);
const win = [0, 1, 2, 3];
const lin = (a) => win[(a >> 14) & 3] * 0x4000 + (a & 0x3FFF);
const rd = (a) => mem[lin(a & 0xffff)];
const wr = (a, v) => { mem[lin(a & 0xffff)] = v & 0xff; };

if (process.env.POISON) mem.fill(0xAA);

// load the raw EXE image at 0x4000 (WIN1 = bank 1 initially)
const exe = fs.readFileSync(EXE);
for (let i = 0; i < exe.length; i++) wr(0x4000 + i, exe[i]);

// ---- virtual filesystem: SRCDIR mounted as C:\WORK ----
function buildTree(dir) {
  const node = { dir: true, children: {}, time: 0, date: 0x5821 };
  for (const name of fs.readdirSync(dir)) {
    const full = path.join(dir, name), st = fs.statSync(full), key = name.toUpperCase();
    node.children[key] = st.isDirectory()
      ? buildTree(full)
      : { dir: false, data: fs.readFileSync(full), time: 0, date: 0x5821, size: st.size };
  }
  return node;
}
const root = { dir: true, children: {}, time: 0, date: 0x5821 };
root.children.WORK = buildTree(SRCDIR);
// Current dir at launch, as the DSS shell would have left it. CWD=<path>
// overrides it (CWD= means the drive root, where CurDir returns just "\").
let cwd = (process.env.CWD !== undefined ? process.env.CWD : 'WORK')
  .split('\\').filter((c) => c.length > 0).map((c) => c.toUpperCase());

function resolve(p) {
  p = p.replace(/\//g, '\\');
  if (/^[A-Za-z]:/.test(p)) p = p.slice(2);
  let comps = (p.startsWith('\\') ? p.slice(1).split('\\') : cwd.concat(p.split('\\')));
  comps = comps.filter((c) => c.length > 0 && c !== '.').map((c) => c.toUpperCase());
  let node = root, parent = null, name = null;
  for (const c of comps) {
    if (!node.dir || !node.children[c]) return { node: null, parent: node, name: c, comps };
    parent = node; name = c; node = node.children[c];
  }
  return { node, parent, name, comps };
}

const files = {}; let nextH = 1;
const cstr = (a) => { let s = ''; for (let b; (b = rd(a++)); ) s += String.fromCharCode(b); return s; };

const cpu = new Z80({
  mem_read: rd, mem_write: wr,
  io_read: (p) => { p &= 0xff; return p === 0x82 ? win[0] : p === 0xA2 ? win[1] : p === 0xC2 ? win[2] : p === 0xE2 ? win[3] : 0xff; },
  io_write: (p, v) => { p &= 0xff; v &= 0xff; if (p === 0x82) win[0] = v; else if (p === 0xA2) win[1] = v; else if (p === 0xC2) win[2] = v; else if (p === 0xE2) win[3] = v; },
});

let st = cpu.getState();
st.pc = 0x4200; st.sp = 0x7FFE; st.ix = 0x4180;
cpu.setState(st);
// PSP-style command line at load-#80 (0x4180): [0]=length, [1..]=text, NUL.
{ const text = CMDLINE; let a = 0x4180; wr(a++, text.length); for (const ch of text) wr(a++, ch.charCodeAt(0)); wr(a, 0); }

let exitCode = null, stdout = '';
const setF = (s, c) => { s.flags.C = c ? 1 : 0; };

// The real DSS does not preserve HL/DE/BC across RST #10 -- e.g. CURRDIR
// (sprinter_dss/DOS5.ASM:814) is an LDI loop that leaves HL pointing into the
// system DIRSPEC buffer, DE past the copied string and BC decremented. Kode's
// own callers defend against this (CaptureDir in Dialog_Windows/Asmsetup.asm
// brackets every call with PUSH/POP HL; FindFile in Dialogwn5.asm reloads its
// cursor from the stack). Clobber those registers here so callers that wrongly
// rely on them surviving fail in the harness instead of only on hardware.
const clobber = (s) => { s.h = 0xDE; s.l = 0xAD; s.d = 0xBE; s.e = 0xEF; s.b = 0xBA; s.c = 0xD0; };

function dss() {
  st = cpu.getState();
  const fn = st.c;
  const ret = () => { const lo = rd(st.sp), hi = rd((st.sp + 1) & 0xffff); st.sp = (st.sp + 2) & 0xffff; st.pc = lo | (hi << 8); cpu.setState(st); };
  switch (fn) {
    case 0x02: clobber(st); st.a = 2; setF(st, false); return ret();           // CURDISK -> C:
    case 0x5C: stdout += cstr(st.h << 8 | st.l); clobber(st); setF(st, false); return ret(); // PCHARS
    case 0x1E: { let p = '\\' + cwd.join('\\'); if (!cwd.length) p = '\\'; let a = st.h << 8 | st.l; for (const ch of p) wr(a++, ch.charCodeAt(0)); wr(a, 0); clobber(st); setF(st, false); return ret(); } // CURDIR (leaves HL/DE/BC trashed, as the real LDI loop does)
    case 0x0A: { const r = resolve(cstr(st.h << 8 | st.l)); clobber(st); if (!r.parent || !r.parent.dir) { st.a = 3; setF(st, true); return ret(); } const node = { dir: false, data: Buffer.alloc(0), size: 0, time: 0, date: 0x5821 }; r.parent.children[r.name] = node; const h = nextH++; files[h] = { node, pos: 0, buf: [] }; st.a = h; setF(st, false); return ret(); } // CREATE
    case 0x11: { const mode = st.a; const r = resolve(cstr(st.h << 8 | st.l)); clobber(st); if (!r.node || r.node.dir) { st.a = 3; setF(st, true); return ret(); } const h = nextH++; const f = { node: r.node, pos: 0, data: Buffer.from(r.node.data) }; if (mode !== 1) f.buf = Array.from(r.node.data); files[h] = f; st.a = h; setF(st, false); return ret(); } // OPEN (mode!=1 -> writable)
    case 0x12: { const f = files[st.a]; if (f && f.buf) { f.node.data = Buffer.from(f.buf); f.node.size = f.buf.length; } clobber(st); setF(st, false); return ret(); } // CLOSE
    case 0x41: exitCode = st.b; cpu.setState(st); throw { halt: true };        // EXIT
    default: st.a = 1; setF(st, true); return ret();
  }
}

let steps = 0;
try {
  for (;;) {
    if (cpu.getState().pc === 0x0010) dss();
    else cpu.run_instruction();
    const LIM = process.env.STEPS ? parseInt(process.env.STEPS) : 1_000_000;
    if (++steps > LIM) { console.error('STEP LIMIT pc=' + cpu.getState().pc.toString(16)); break; }
  }
} catch (e) { if (!e.halt) throw e; }

process.stdout.write(stdout);
process.exit(exitCode === 0 ? 0 : (exitCode || 1));
