// Exercise the assembled text import/export routines with paged memory and DSS.
// Run after ./run/make.sh: node test/textio.js [original-file]
const fs = require('fs');
const path = require('path');
const assert = require('assert');
global.window = {};
const Z80 = require('./Z80core.js');
const root = process.env.KODE_TEXTIO_BUILD || path.resolve(__dirname, '..');
const listing = fs.readFileSync(path.join(root, 'Build/KodeEXE.LST'), 'utf8');
const symbols = {};
for (const line of listing.split('\n')) {
  const address = line.match(/^\s*\d+\+\+([0-9A-F]{4}) /);
  const label = line.slice(24).match(/^([A-Za-z][A-Za-z0-9]*)(?:[:\s]|$)/);
  if (address && label && !/\bEQU\b/i.test(line.slice(24)))
    symbols[label[1]] = parseInt(address[1], 16);
}
const binary = fs.readFileSync(path.join(root, 'build/bin/KodeMain.bin'));

function machine() {
  const memory = new Uint8Array(16 * 0x4000);
  memory.fill(0xA5);
  memory.set(binary);
  const banks = [0, 1, 10, 11];
  const physical = a => banks[(a & 0xffff) >>> 14] * 0x4000 + (a & 0x3fff);
  const rd = a => memory[physical(a)];
  const wr = (a, v) => { memory[physical(a)] = v & 255; };
  const word = (a, v) => { wr(a, v); wr(a + 1, v >>> 8); };
  const getWord = a => rd(a) | rd(a + 1) << 8;
  const ports = [0x82, 0xA2, 0xC2, 0xE2];
  const cpu = new Z80({mem_read: rd, mem_write: wr,
    io_read: p => banks[ports.indexOf(p & 255)] ?? 255,
    io_write: (p, v) => { const i = ports.indexOf(p & 255); if (i >= 0) banks[i] = v; }
  });
  let input = Buffer.alloc(0), position = 0, output = [];
  for (const [label, value] of Object.entries({SymbPg1: 12, SymbPg2: 13,
    DOSpage: 8, CnTxtPg: 12, AsmTabPg: 13})) wr(symbols[label], value);
  wr(symbols.TxtWtab + 0x1d, 10);
  wr(symbols.TxtWtab + 0x1e, 11);
  const ret = state => {
    state.pc = getWord(state.sp); state.sp = (state.sp + 2) & 65535;
    cpu.setState(state);
  };
  function dss() {
    const s = cpu.getState(), fn = s.c;
    let de = s.d << 8 | s.e, hl = s.h << 8 | s.l;
    s.flags.C = 0;
    if (fn === 0x15) {
      const offset = s.ix + hl * 65536;
      position = offset + (s.b === 2 ? input.length : s.b === 1 ? position : 0);
      s.ix = position & 65535; hl = position >>> 16;
      s.h = hl >>> 8; s.l = hl & 255; s.a = 0;
    } else if (fn === 0x13) {
      const n = Math.min(de, input.length - position);
      for (let i = 0; i < n; i++) wr(hl + i, input[position++]);
      s.d = n >>> 8; s.e = n & 255; s.a = n === de ? 0 : 255;
      // DSS uses IX while moving the file pointer after a read.
      s.ix = n;
    } else if (fn === 0x14) {
      for (let i = 0; i < de; i++) output.push(rd(hl + i));
      s.a = 0;
    } else throw new Error('Unexpected DSS call: ' + fn.toString(16));
    s.b = 0xBA; s.c = 0xD0;
    if (fn !== 0x15) { s.h = 0xDE; s.l = 0xAD; }
    s.iy = 0x0200; // Real DSS selects its file descriptor in IY.
    ret(s);
  }
  function call(label, skip = []) {
    const s = cpu.getState(); s.pc = symbols[label]; s.sp = 0x7ff0; s.iy = 0x8010;
    word(s.sp, 0x7ff8); cpu.setState(s);
    for (let steps = 0; steps < 2000000; steps++) {
      if (cpu.getState().pc === 0x7ff8) return cpu.getState();
      if (skip.some(name => cpu.getState().pc === symbols[name])) ret(cpu.getState());
      else if (cpu.getState().pc === 0x10) dss(); else cpu.run_instruction();
    }
    throw new Error('Step limit in ' + label);
  }
  function selectWindow(pages = [10, 11]) {
    banks[2] = pages[0]; banks[3] = pages[1];
    wr(symbols.TxtWtab + 0x1d, pages[0]);
    wr(symbols.TxtWtab + 0x1e, pages[1]);
  }
  function importText(data, drain = false, pages = [10, 11]) {
    const collected = [];
    selectWindow(pages);
    input = data; position = 0;
    word(symbols.RealBytes, 0); word(symbols.BegTXTstr, 0);
    word(symbols.BegTASstr, 0x8040); word(0x8028, 0);
    word(0x8022, 0x8040); word(0x8040, 0);
    wr(symbols.ReadFlag, 0); wr(symbols.LstByte + 1, 1);
    wr(symbols.ImportEOL, 0); wr(0x803e, 0);
    wr(symbols.textpg1 + 1, pages[0]); wr(symbols.textpg2 + 1, pages[1]);
    for (let n = 0; n < 20000; n++) {
      if (call('ProcessImportTXT').flags.C) break;
      if (drain) {
        collected.push(...records());
        word(symbols.BegTASstr, 0x8040); word(0x8022, 0x8040); wr(0x8040, 0);
      }
      if (n === 19999) throw new Error('Import did not terminate');
    }
    return drain ? collected : records();
  }
  function records() {
    const lines = [];
    for (let a = 0x8040; rd(a); a += rd(a)) {
      assert(a < 0xffff, 'Record overflow');
      const len = rd(a);
      assert(len >= 3 && rd(a + len - 1) === len, 'Invalid text record');
      lines.push(Buffer.from(Array.from({length: len - 3}, (_, i) => rd(a + 2 + i))));
    }
    return lines;
  }
  function exportText() {
    output = [];
    word(symbols.BegTASstr, 0x8040); word(symbols.BegTXTstr, 0x8000);
    for (let n = 0; n < 10000; n++) {
      if (call('ProcessExportTXT').flags.C) return Buffer.from(output);
    }
    throw new Error('Export did not terminate');
  }
  const poisonInput = (offset, value) => { memory[12 * 0x4000 + offset] = value; };
  return {importText, exportText, wr, word, rd, call, cpu, records, poisonInput, selectWindow,
    getOutput: () => Buffer.from(output)};
}

let pass = 0, fail = 0;
function check(name, f) {
  try { f(); pass++; console.log('ok   - ' + name); }
  catch (e) { fail++; console.log('FAIL - ' + name + ': ' + e.message.slice(0, 600)); }
}
const bytes = s => Buffer.from(s, 'latin1');
function roundTrip(data) {
  const m = machine(); m.importText(data); return m.exportText();
}
for (const [eol, format] of [['\r\n', 1], ['\r', 2], ['\n', 3]]) {
  check('detect and preserve ' + JSON.stringify(eol), () => {
    const data = bytes('FIRST' + eol + 'LAST' + eol);
    const m = machine(); m.importText(data);
    assert.strictEqual(m.rd(0x803e), format);
    assert.deepStrictEqual(m.exportText(), data);
  });
  check('mixed endings use first ' + JSON.stringify(eol), () => {
    const m = machine(); m.importText(bytes('FIRST' + eol + 'SECOND\r\nTHIRD\nLAST\r'));
    assert.deepStrictEqual(m.exportText(), bytes(['FIRST', 'SECOND', 'THIRD', 'LAST', ''].join(eol)));
  });
}
check('new file without a detected ending defaults to CRLF', () => {
  assert.deepStrictEqual(roundTrip(bytes('LAST')), bytes('LAST\r\n'));
});
check('two windows retain separate formats when saving repeatedly', () => {
  const m = machine();
  m.importText(bytes('WINDOW1\rLAST\r'));
  m.importText(bytes('WINDOW2\nLAST\n'), false, [14, 15]);
  assert.deepStrictEqual(m.exportText(), bytes('WINDOW2\nLAST\n'));
  m.selectWindow();
  assert.strictEqual(m.rd(0x803e), 2);
  assert.deepStrictEqual(m.exportText(), bytes('WINDOW1\rLAST\r'));
  m.selectWindow([14, 15]);
  assert.deepStrictEqual(m.exportText(), bytes('WINDOW2\nLAST\n'));
});
for (const eol of ['\r\n', '\n', '\r', '']) {
  check('final line, terminator ' + JSON.stringify(eol), () => {
    const m = machine();
    assert.deepStrictEqual(m.importText(bytes('first\r\nLAST' + eol)), [bytes('first'), bytes('LAST')]);
    assert.deepStrictEqual(m.exportText(), bytes('first\r\nLAST\r\n'));
  });
}
check('spaces in literals and between tokens', () => {
  const data = bytes('#define SPACE \' \'\r\nprintf("a       b");\r\n');
  assert.deepStrictEqual(roundTrip(data), data);
});
check('tab at EOF', () => {
  const m = machine();
  assert.deepStrictEqual(m.importText(bytes('first\r\nLAST\t')), [bytes('first'), bytes('LAST    ')]);
});
check('last character after a tab, without EOL', () => {
  const m = machine();
  assert.deepStrictEqual(m.importText(bytes('first\r\nLAST\tx')), [bytes('first'), bytes('LAST    x')]);
});
check('tab does not consume following lines', () => {
  const m = machine();
  assert.deepStrictEqual(m.importText(bytes('\tfirst\r\nLAST')), [bytes('        first'), bytes('LAST')]);
});
check('tabs at 4-column stops', () => {
  const m = machine(); m.wr(symbols.TABimpWidth, 4);
  assert.deepStrictEqual(m.importText(bytes('\tfirst\r\nLAST\t')), [bytes('    first'), bytes('LAST    ')]);
});
check('tab optimization only changes indentation', () => {
  const m = machine(); m.importText(bytes('        puts("a       b");\r\n'));
  assert.deepStrictEqual(m.exportText(), bytes('\tputs("a       b");\r\n'));
});
check('short indentation stays as spaces', () => {
  assert.deepStrictEqual(roundTrip(bytes('       text\r\n')), bytes('       text\r\n'));
});
check('CR at EOF ignores stale LF after read', () => {
  const m = machine();
  // Poison the unread byte following the file with LF.
  const mData = bytes('first\r\nLAST\r');
  m.poisonInput(mData.length, 10);
  assert.deepStrictEqual(m.importText(mData), [bytes('first'), bytes('LAST')]);
});
check('last line near full text window', () => {
  const data = bytes(('x'.repeat(100) + '\r\n').repeat(317) + 'LAST');
  const m = machine();
  const lines = m.importText(data);
  assert.strictEqual(lines.length, 318);
  assert.deepStrictEqual(lines.at(-1), bytes('LAST'));
  assert.deepStrictEqual(m.exportText(), Buffer.concat([data, bytes('\r\n')]));
});
check('input refill, CRLF near block boundary, final line without EOL', () => {
  const data = bytes(('x'.repeat(100) + '\r\n').repeat(321) + 'x'.repeat(25) + '\r\nLAST');
  const m = machine();
  // Drain packed records between callbacks to isolate input refill from the UI
  // that opens a second text window when the first window is full.
  const lines = m.importText(data, true);
  assert.strictEqual(lines.length, 323);
  assert.deepStrictEqual(lines[321], bytes('x'.repeat(25)));
  assert.deepStrictEqual(lines[322], bytes('LAST'));
});
check('empty file', () => {
  assert.deepStrictEqual(roundTrip(Buffer.alloc(0)), Buffer.alloc(0));
});
check('edited last line is packed and saved', () => {
  const m = machine(); m.importText(bytes('FIRST\r\n'));
  // A new final empty record with unsaved LAST in the editor's char/attr buffer.
  const a = 0x8048;
  m.wr(a, 3); m.wr(a + 1, 2); m.wr(a + 2, 3); m.wr(a + 3, 0);
  m.word(0x8022, a + 3); m.word(0x8024, a); m.word(0x8028, 2);
  m.wr(0x8012, 4); m.wr(0x8026, 0);
  for (const [i, c] of [...bytes('LAST')].entries()) {
    m.wr(0x7d00 + i * 2, c); m.wr(0x7d01 + i * 2, 0x0f);
  }
  m.call('PutString', ['GetMousInfo']);
  assert.deepStrictEqual(m.records(), [bytes('FIRST'), bytes('LAST')]);
  assert.deepStrictEqual(m.exportText(), bytes('FIRST\r\nLAST\r\n'));
});
check('output block boundary and final flush', () => {
  const m = machine();
  m.importText(bytes('FIRST\r\nLAST'));
  // Seed a partly filled output block so the next line crosses its end.
  for (let i = 0; i < 0x7ffc; i++) m.poisonInput(i, 0xA5);
  m.word(symbols.BegTASstr, 0x8040); m.word(symbols.BegTXTstr, 0xfffc);
  assert.strictEqual(m.call('ProcessExportTXT').flags.C, 0);
  assert.strictEqual(m.call('ProcessExportTXT').flags.C, 0);
  assert.strictEqual(m.call('ProcessExportTXT').flags.C, 1);
  assert.deepStrictEqual(m.getOutput(), Buffer.concat([Buffer.alloc(0x7ffc, 0xA5), bytes('FIRST\r\nLAST\r\n')]));
});
if (process.argv[2]) check('user source: normalized CRLF, all text retained', () => {
  const data = fs.readFileSync(process.argv[2]);
  const normalized = bytes(data.toString('latin1').replace(/\r\n|\r|\n/g, '\r\n'));
  const m = machine(); m.wr(symbols.OptimalTAB, 0);
  m.importText(data);
  assert.deepStrictEqual(m.exportText(), normalized);
});
console.log('PASS: ' + pass + ' FAIL: ' + fail);
process.exitCode = fail ? 1 : 0;
