;[]===========================================================[]
; Build/Run decision layer (pure). Included by BuildRun.asm (PG2) and,
; standalone, by test/buildtest.asm under the host Z80 harness.
;
; Contract: the DOS environment is already active when these are called
; (caller did the DOSpage->SLOT0 + #7FFD=#10 sandwich and ChDir'd into the
; project directory). No paging, no dialogs, only fixed buffers here - so
; behavior is identical on host and hardware.
;
; External symbols expected from the including translation unit:
;   FuncBuffer  - 256-byte scratch (target list output)
;   SynFileBuf  - 640-byte scratch (makefile read chunk)
;[]===========================================================[]
; Existence probe. In: HL = ASCIIZ name. Out: CF=1 absent, CF=0 present.
; Clobbers A (and HL/DE/BC via DSS).
BldTryOpen
	LD	A,#01			; Read-only, as SynLoadFileToBuf
	LD	C,Dss.Open
	RST	ToDSS
	RET	C			; Not found
	LD	C,Dss.Close
	RST	ToDSS
	OR	A			; CF=0 - present
	RET
;[]===========================================================[]
; Decide what to launch. In: A = 0 Build / 1 Run.
; Out: A = 0 - BldCmdBuf holds the command line; A = 1 - nothing found.
BldDecide
	OR	A
	JR	NZ,BldDcRun
; --- Build: BUILD.BAT, then MAKEFILE ---
	LD	HL,BldNBat
	CALL	BldTryOpen
	JR	C,BldDcB1
	LD	HL,BldNSys		; "SYSTEM.EXE /C " + "BUILD.BAT"
	CALL	BldStrCpy
	LD	HL,BldNBat
	CALL	BldStrCat
	XOR	A
	RET
BldDcB1	LD	HL,BldNMkf
	CALL	BldTryOpen
	JR	C,BldDcNo
	LD	HL,BldNMake		; "MAKE.EXE"
	CALL	BldStrCpy
	XOR	A
	RET
; --- Run: RUN.BAT, then MAKEFILE with a run: target ---
BldDcRun	LD	HL,BldNRBat
	CALL	BldTryOpen
	JR	C,BldDcR1
	LD	HL,BldNSys		; "SYSTEM.EXE /C " + "RUN.BAT" [+ " params"]
	CALL	BldStrCpy
	LD	HL,BldNRBat
	CALL	BldStrCat
	LD	A,(BldParams)		; length byte
	OR	A
	JR	Z,BldDcRok
	LD	HL,BldSpc		; " "
	CALL	BldStrCat
	LD	HL,BldParams+1		; ASCIIZ args
	CALL	BldStrCat
BldDcRok	XOR	A
	RET
BldDcR1	LD	A,#01			; Scan MAKEFILE for a run: target
	CALL	BldScanMk
	JR	C,BldDcNo		; No MAKEFILE
	OR	A
	JR	Z,BldDcNo		; No run target
	LD	HL,BldNMkRun		; "MAKE.EXE run"
	CALL	BldStrCpy
	XOR	A
	RET
BldDcNo	LD	A,#01
	RET
;[]===========================================================[]
; Scan MAKEFILE. In: A = 0 collect targets into FuncBuffer (#0D-separated,
; #00-terminated), out A = count; A = 1 look for a run: target, out A = 1
; found / 0 not. Out: CF=1 if MAKEFILE cannot be opened.
; Streams the file in 512-byte chunks - no line-length limit.
BldScanMk
	LD	(BldMode),A
	CALL	BldFOpen
	RET	C
	XOR	A
	LD	(BldTCnt),A
	LD	(BldRunF),A
	LD	HL,FuncBuffer
	LD	(BldLPtr),HL
BldScL0				; at column 0 (start of a line)
	CALL	BldFGet
	JR	C,BldScEnd
	CP	#0D
	JR	Z,BldScL0		; blank line
	CP	#0A
	JR	Z,BldScL0
	CP	#09
	JR	Z,BldScSkip		; TAB - recipe line
	CP	" "
	JR	Z,BldScSkip
	CP	"#"
	JR	Z,BldScSkip		; comment
	CP	";"
	JR	Z,BldScSkip
	CP	"."
	JR	Z,BldScSkip		; .PHONY and friends
	LD	HL,BldTName		; capture a candidate name (A=first char)
	LD	B,#18			; max 24 chars
BldScCap	LD	(HL),A
	INC	HL
	PUSH	HL			; BldFGet clobbers HL - keep write cursor
	CALL	BldFGet
	POP	HL
	JR	C,BldScEnd		; EOF mid-name - no colon, drop
	CP	":"
	JR	Z,BldScTgt
	CP	"="
	JR	Z,BldScSkip		; variable assignment
	CP	" "
	JR	Z,BldScSkip
	CP	#09
	JR	Z,BldScSkip
	CP	#0D
	JR	Z,BldScL0		; line ended before ':'
	CP	#0A
	JR	Z,BldScL0
	DJNZ	BldScCap
	JR	BldScSkip		; too long - not a target
BldScTgt	LD	(HL),#00		; NUL-terminate name
	CALL	BldGotTgt
	LD	A,(BldMode)
	OR	A
	JR	Z,BldScSkip		; collect mode: continue
	LD	A,(BldRunF)
	OR	A
	JR	NZ,BldScEnd		; find-run mode: stop on first match
	JR	BldScSkip
BldScSkip	CALL	BldFGet			; consume to end of line
	JR	C,BldScEnd
	CP	#0A
	JR	Z,BldScL0
	CP	#0D
	JR	Z,BldScL0
	JR	BldScSkip
BldScEnd	CALL	BldFClose
	LD	A,(BldMode)
	OR	A
	JR	NZ,BldScEnd1
	LD	HL,(BldLPtr)		; collect mode: terminate list, A=count
	LD	(HL),#00
	LD	A,(BldTCnt)
	OR	A			; CF=0
	RET
BldScEnd1	LD	A,(BldRunF)		; find-run mode: A=0/1, CF=0
	OR	A
	RET
;[]===========================================================[]
; Process a captured, NUL-terminated target name in BldTName.
BldGotTgt
	LD	A,(BldMode)
	OR	A
	JR	NZ,BldGTrun
; collect mode: append name + #0D to FuncBuffer (hard cap at +#F0)
	LD	HL,(BldLPtr)
	LD	DE,FuncBuffer+#F0
	PUSH	HL
	OR	A
	SBC	HL,DE
	POP	HL
	JR	NC,BldGTdone		; list full - drop
	LD	DE,BldTName
BldGTcp	LD	A,(DE)
	OR	A
	JR	Z,BldGTeol
	LD	(HL),A
	INC	HL
	INC	DE
	JR	BldGTcp
BldGTeol	LD	(HL),#0D
	INC	HL
	LD	(BldLPtr),HL
	LD	A,(BldTCnt)
	INC	A
	LD	(BldTCnt),A
BldGTdone	RET
; find-run mode: is BldTName == "run" (case-insensitive)?
BldGTrun	LD	HL,BldTName
	LD	DE,BldNRun
BldGTrc	LD	A,(DE)
	OR	A
	JR	Z,BldGTrE		; end of "run"
	LD	B,A
	LD	A,(HL)
	CALL	BldLower
	CP	B
	RET	NZ			; mismatch
	INC	HL
	INC	DE
	JR	BldGTrc
BldGTrE	LD	A,(HL)
	OR	A
	RET	NZ			; name longer than "run"
	LD	A,#01
	LD	(BldRunF),A
	RET
;[]===========================================================[]
; Lowercase A (ASCII). Preserves non-letters.
BldLower	CP	"A"
	RET	C
	CP	"Z"+1
	RET	NC
	ADD	A,#20
	RET
;[]===========================================================[]
; Chunked reader over MAKEFILE using SynFileBuf as the chunk buffer.
BldFOpen	LD	HL,BldNMkf
	LD	A,#01
	LD	C,Dss.Open
	RST	ToDSS
	RET	C
	LD	(BldFHnd),A
	LD	HL,#0000
	LD	(BldFLeft),HL		; force a refill on first BldFGet
	XOR	A
	LD	(BldFEof),A
	RET
BldFClose	LD	A,(BldFHnd)
	LD	C,Dss.Close
	RST	ToDSS
	RET
; Out: A = next char, CF=0; CF=1 at EOF.
BldFGet	LD	HL,(BldFLeft)
	LD	A,H
	OR	L
	JR	NZ,BldFG1
	LD	A,(BldFEof)
	OR	A
	JR	NZ,BldFGE		; drained and EOF
	CALL	BldFRead
	LD	HL,(BldFLeft)
	LD	A,H
	OR	L
	JR	Z,BldFGE		; nothing read - EOF
BldFG1	LD	HL,(BldFPtr)
	LD	A,(HL)
	INC	HL
	LD	(BldFPtr),HL
	LD	HL,(BldFLeft)
	DEC	HL
	LD	(BldFLeft),HL
	OR	A			; CF=0 (char preserved in A)
	RET
BldFGE	SCF
	RET
BldFRead	LD	HL,SynFileBuf
	LD	(BldFPtr),HL
	LD	DE,#0200		; request 512
	LD	A,(BldFHnd)
	LD	C,Dss.Read
	RST	ToDSS
	LD	(BldFLeft),DE		; DE = bytes actually read
	LD	A,D			; short read (<512) -> EOF after drain
	CP	#02
	RET	NC
	LD	A,#01
	LD	(BldFEof),A
	RET
;[]===========================================================[]
; Copy ASCIIZ (HL) into BldCmdBuf. Sets the append cursor at the NUL.
BldStrCpy	LD	DE,BldCmdBuf
	JR	BldStrC0
; Append ASCIIZ (HL) at the current cursor (overwrites prior NUL).
BldStrCat	LD	DE,(BldCmdPtr)
BldStrC0	LD	A,(HL)
	LD	(DE),A
	OR	A
	JR	Z,BldStrC1
	INC	HL
	INC	DE
	JR	BldStrC0
BldStrC1	LD	(BldCmdPtr),DE		; points at the NUL
	RET
;[]===========================================================[]
; Pure-layer data
BldMode		DEFB	#00
BldTCnt		DEFB	#00		; collected target count
BldRunF		DEFB	#00		; run: target found flag
BldLPtr		DEFW	#0000		; list write cursor
BldFHnd		DEFB	#00		; MAKEFILE handle
BldFPtr		DEFW	#0000		; read cursor in SynFileBuf
BldFLeft	DEFW	#0000		; bytes left in current chunk
BldFEof		DEFB	#00
BldCmdPtr	DEFW	#0000		; append cursor in BldCmdBuf
BldTName	DEFS	25,0		; captured target name, ASCIIZ
BldCmdBuf	DEFS	96,0		; built command line
BldParams	DEFS	65,0		; [0]=len, [1..]=ASCIIZ session args

BldNBat		DEFB	"BUILD.BAT",0
BldNRBat	DEFB	"RUN.BAT",0
BldNMkf		DEFB	"MAKEFILE",0
BldNSys		DEFB	"SYSTEM.EXE /C ",0
BldNMake	DEFB	"MAKE.EXE",0
BldNMkRun	DEFB	"MAKE.EXE run",0
BldNRun		DEFB	"run",0
BldSpc		DEFB	" ",0
;[]===========================================================[]
