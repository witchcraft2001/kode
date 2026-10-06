# KODE

Multi-window text editor for the **Sprinter** computer (Peters Plus,
Estex/DSS): menu bar, overlapping windows, mouse support, configurable
syntax highlighting and Build/Run integration via `BUILD.BAT` /
`RUN.BAT` / `MAKEFILE`.

Based on the TASM editor source code by **Anton Enin** (1999),
revised for Sprinter by **Anatoliy Belyanskiy** (Sprinter Team).
Current author: **Dmitry Mikhalchenkov** (FidoNet 2:5030/1997.10).

User manuals: [English](doc/kode_en.txt) · [Russian](doc/kode_ru.txt)

## Build

The source is Z80 assembly, assembled with
[sjasmplus](https://github.com/z00m128/sjasmplus). The bundled
`Tools/mhmt` compresses the code pages; `mtools` is needed only for
the floppy image.

```sh
./run/make.sh                  # -> build/KODE.EXE  (+ Build/*.LST)
./run/create_floppy_image.sh   # -> build/kode.img  (FAT12: KODE.EXE + SYNTAX/)
./run/dist.sh                  # -> build/kode-<ver>.zip  (release archive)
```

`run/dist.sh` additionally requires `zip` and `iconv` (the Russian
manual ships recoded to CP866). The release version comes from
`_progVERSION` in `version.inc`.

## Tests

Host-side Z80 harness tests (`node`, `sjasmplus`):

```sh
./test/run_tests.sh
node test/textio.js
node test/console.js
node test/buildrun.js
```

MAME/Sprinter verification scripts and notes live in `test/` —
see `test/BUILD_RUN_TESTING.md` and `test/SYNTAX_TESTING.md`.

## Layout

```
KODE_BIN.asm      entry point (packed modules)
KodeEXE.asm       EXE loader / startup
Prepare/          setup and initialization
Kode_Main/        editor core: desktop, windows, text editing, search,
                  text I/O, syntax highlighting, keyboard/mouse drivers
Menu_Bar/         menu bar, status line, scan-code tables, dialogs data
Dialog_Windows/   dialog engine, dialog resources, setup file (KODE.SET),
                  Build/Run engine, command-line open, console snapshot
Command/          Z80 mnemonic table
DEPACK/           depacker
syntax/           highlight profiles + INDEX.LST (ships in SYNTAX/)
test/             host Z80 harness tests and MAME scripts
run/              build / packaging scripts
Tools/            bundled build tools (mhmt, hrust.exe)
Build/, build/    generated artifacts (git-ignored)
```

## Status

Working editor: files, blocks, find/replace, window management,
options and color setup persisted to `KODE.SET`, syntax highlighting,
project build/run via `SYSTEM.EXE`/`MAKE.EXE` with a saved console log.
Print, the debugger entry and the help topics are still placeholders.
