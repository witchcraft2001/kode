# Agent Notes

## Scope and target
- This repo is a single Z80 assembly project for the **Sprinter/ZX** text editor `kode`.
- The main sources are rooted at `KODE_BIN.asm` and `KodeEXE.asm`; feature code is split across directories such as `Kode_Main/`, `Dialog_Windows/`, `Menu_Bar/`, `Prepare/`, `Command/`, and `DEPACK/`.
- This is not a multi-package repository; treat the assembly sources here as the source of truth.

## Canonical build commands
- On macOS, run these after each iteration, in this exact order:
  - `./run/make.sh`
  - `./run/create_floppy_image.sh`
- `./run/make.sh` requires `sjasmplus` in `PATH` and the local helper tool `Tools/mhmt`.
- `./run/create_floppy_image.sh` requires `mtools` (`mformat`, `mcopy`, `mmd`) and produces a FAT12 floppy image.

## Artifacts and hygiene
- Generated artifacts live in `Build/` and `build/`; both are ignored.
- The primary generated outputs are:
  - `Build/Prebuilds.LST`
  - `Build/KodeEXE.LST`
  - `build/KODE.EXE`
  - `build/kode.img`
  - `build/bin/` and `build/bin/HRUST/*.hst`
- The repository also contains checked-in helper binaries/tools under `Tools/` (for example `Tools/hrust.exe` and `Tools/mhmt`). Do not modify or replace them unless the task explicitly requires it.
- If a task changes build outputs intentionally, say so explicitly in your summary. Do not commit generated files by accident.

## Working conventions
- Prefer small, targeted edits in the relevant module instead of restructuring the build or directory layout.
- Preserve the existing uppercase/lowercase path conventions exactly; this project uses both `Build/` and `build/` with different roles.
- When investigating behavior, start from the entry assemblers (`KODE_BIN.asm`, `KodeEXE.asm`) and then follow includes into the feature directories listed above.

## Code style and editing rules
- Match the existing Z80 style exactly:
  - opcodes uppercase: `LD`, `CALL`, `JR`, `RET`
  - labels usually `CamelCase` or short mixed-case local-style labels like `EditOp1`, `ClChkLp`
  - constants in hex are usually `#NN` / `#NNNN`
  - inline comments are terse and aligned with tabs rather than reflowed prose
- Prefer preserving local label structure and jump topology instead of “cleaning it up”.
- This codebase uses data-driven UI descriptors heavily. When changing dialogs, prefer editing descriptor coordinates and object definitions in `Dialog_Windows/Dwindows.asm` before touching the dialog engine.
- Avoid renaming existing symbols unless there is a compelling reason; many modules communicate through shared globals and fixed symbol names.
- Be careful with line endings. Git reports several asm files as `CRLF`; avoid gratuitous whole-file rewrites.

## Runtime model and shared globals
- Main event buffer is `what` in `Kode_Main/Mainunit.asm`.
- Common event codes from `Kode_Main/Mainunit.asm`:
  - `evNothing = #00`
  - `evMouseFr = #01`
  - `evKeyboard = #02`
  - `evCombKey = #03`
  - `evCommand = #04`
  - `evMessage = #05`
- Common dialog commands:
  - `cmOkey = #36`
  - `cmCancel = #37`
  - `cmSelect = #3A`
- Frequently reused scratch buffers:
  - `CompBuff = #7A00`
  - `ReCompBuff = #7B00`
  - `TextBuff = #7D00`
  - `KeyBuff = #7F00`
  - `WinBoxBuff = #C000`

## UI and dialog system
- Primary dialog entry point is `Dialog` in `Dialog_Windows/Dialogwn.asm`.
- Dialog construction is driven by descriptors passed in `HL`; `PutDialWn` in `Dialog_Windows/Dialogwn2.asm` parses the descriptor and builds runtime tables in `DialTab` / `DialData`.
- Dialog descriptors start with:
  - `DEFW y,x`
  - `DEFW ylen,xlen`
  - `DEFB "Window title",0`
  - then zero or more object descriptors
  - terminated by `DEFB #FF`
- Important: dialog object type names are historically misleading:
  - `ClCheckBut` renders and behaves like the mutually exclusive round-choice cluster used by `Keyboard`
  - `ClRadioBut` behaves like individually toggled checkbox-style items
  - Do not trust the names; verify against existing working examples in `Dialog_Windows/Dwindows.asm`

## Common dialog object APIs
- Object type ids are defined in `Dialog_Windows/Dialogwn2.asm`:
  - `TextLine = #01`
  - `InputLine = #02`
  - `ClRadioBut = #03`
  - `ClCheckBut = #04`
  - `ListBox = #05`
  - `FileInput = #06`
  - `FileBox = #07`
  - `FileInfo = #08`
  - `Button = #09`
  - `ProcesLine = #0A`
  - `PalleteBox = #0B`
  - `TestColor = #0C`
- `TextLine`
  - descriptor: `DEFB TextLine`, `DEFW y,x`, `DEFB "text",0`
  - no backing state structure
- `InputLine`
  - descriptor format, as used by `PInpLine`:
    - `DEFB InputLine`
    - `DEFW y,x`
    - `DEFB "Label",0,max_len,context`
    - `DEFW Buffer`
  - buffer layout:
    - byte 0: max input symbols
    - byte 1: ready-string flag
    - byte 2: cursor x
    - byte 3: add-x / scroll
    - byte 4: current input length
    - bytes 5+: text storage
  - common examples: `LabBuff`, `TabBuff`, `FileBuf`
- `Button`
  - descriptor format, as used by `PButton`:
    - `DEFB Button`
    - `DEFW y,x`
    - `DEFB " ~O~k ",0,command,context`
  - hotkey is encoded with `~`
- `ClCheckBut` / `ClRadioBut`
  - cluster format:
    - `DEFB <cluster type>`
    - `DEFW y,x,ylen,xlen`
    - `DEFB "Cluster title",0`
    - repeated items:
      - `DEFB "item text",0,context`
      - `DEFW StateByte`
    - terminated by `DEFB 0`
  - see `Keyboard` in `Dialog_Windows/Dwindows.asm` as the canonical mutually exclusive example
- `FileInput`
  - same general buffer-backed idea as `InputLine`, but specialized for file dialogs
- `FileBox` / `ListBox`
  - use descriptor-specific runtime tables managed by `PFileBox` / `PListBox`
  - changing their behavior usually requires engine work, not only descriptor edits
- `ProcesLine`
  - descriptor format example is in `Dialog_Windows/Dwindows.asm` (`Dprocess`)
  - binds max/current counters and a worker callback via words after the visual width byte

## Frequently used UI helper procedures
- Dialog/window lifecycle:
  - `Dialog` — run dialog event loop
  - `PutDialWn` — instantiate descriptor into runtime dialog
  - `ClsDial` — close dialog and restore screen contents
- Cursor / refresh helpers:
  - `SetCurs`, `ResCurs`, `PILCurs`, `ResILCr`
  - `PutStatusLn` — update status/help line
- Text-window refresh pipeline used after settings changes:
  - `OnlySyntax`
  - `PutString`
  - `RefrWin`
  - `PutShad`
  - `PutWork`
  - `PutBuff`
- Window arrangement commands in `Kode_Main/Function3.asm`:
  - `Cascade`
  - `Tile`
  - `NewDisplay`

## Practical UI rules discovered in this code
- Prefer changing only coordinates in dialog descriptors when the user asks for layout tweaks.
- Keep an eye on dialog height when moving controls; the button row can easily fall outside the frame if `ylen` is reduced too much.
- For mutually exclusive two-option selectors, reuse the exact cluster style already used by `Keyboard`.
- For input fields, keep using fixed-size local buffers near the owning procedure/data section; that is the established pattern.
- Hotkeys in labels are marked with `~X~`.

## Where to look first for common tasks
- Editor options / visual dialog layout:
  - `Dialog_Windows/Dwindows.asm`
  - `Kode_Main/Function3.asm`
- Setup persistence:
  - `Dialog_Windows/Asmsetup.asm`
- Text import/export and file-format conversions:
  - `Kode_Main/TextIO.asm`
- Dialog engine behavior:
  - `Dialog_Windows/Dialogwn.asm`
  - `Dialog_Windows/Dialogwn2.asm`
  - `Dialog_Windows/Dialogwn3.asm`
  - `Dialog_Windows/Dialogwn4.asm`
  - `Dialog_Windows/Dialogwn6.asm`

## External reference sources
- You may consult the following local sibling repositories/directories for answers, platform details, and implementation ideas:
  - `/Users/dmitry/dev/zx/sprinter/sprinter_bios`
  - `/Users/dmitry/dev/zx/sprinter/sprinter_dss`
  - `/Users/dmitry/dev/zx/sprinter/sprinter_ai_doc/manual`
  - `/Users/dmitry/dev/zx/sprinter/sources/tasm_071/TASM`
  - `/Users/dmitry/dev/zx/sprinter/sources/fformat/src/fformat_v113`
  - `/Users/dmitry/dev/zx/sprinter/sources/fm/FM-SRC/FM`
- Treat them as reference material only; this repository remains the source of truth for changes you make here.
