;[]===========================================================[]
; Build/Run decision layer. Included by BuildRun.asm (PG2) and,
; standalone, by test/buildtest.asm under the host Z80 harness.
;
; Contract: the DOS environment is already active when these are called
; (caller did the DOSpage->SLOT0 + #7FFD=#10 sandwich and ChDir'd into the
; project directory). No dialogs; DSS calls use a resident trampoline to
; restore SLOT3 before returning to this page.
;
; External symbols expected from the including translation unit:
;   BldDssTramp / BldCopyStable - resident DSS return and argument copy
;   FuncBuffer  - 256-byte scratch (target list output)
;   SynFileBuf  - 640-byte scratch (makefile read chunk)
;[]===========================================================[]
; Existence probe. HL = ASCIIZ name. CF=1 absent/error, CF=0 present.
; Clobbers A (and HL/DE/BC via DSS).
BldTryOpen
	CALL	BldFOpenName
	RET	C
	LD	C,Dss.Close
	CALL	BldDssTramp
	RET	NC
	LD	(BldIoErr),A
	RET
BldFOpenName
	CALL	BldCopyStable
	LD	A,#01
	LD	C,Dss.Open
	CALL	BldDssTramp
	RET	NC
	CP	#03			; only file-not-found permits fallback
	JR	Z,BldOpenMiss
	LD	(BldIoErr),A
BldOpenMiss
	SCF
	RET
;[]===========================================================[]
; Decide what to launch. In: A = 0 Build / 1 Run.
; Out: A = 0 command ready, 1 nothing found, 2 file I/O error.
BldDecide
	PUSH	AF
	XOR	A
	LD	(BldIoErr),A
	LD	(BldCmdBuf),A
	POP	AF
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
BldDcB1	LD	A,(BldIoErr)
	OR	A
	JR	NZ,BldDcErr
	LD	HL,BldNMkf
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
BldDcR1	LD	A,(BldIoErr)
	OR	A
	JR	NZ,BldDcErr
	LD	A,#01			; Scan MAKEFILE for a run: target
	CALL	BldScanMk
	JR	C,BldDcNo		; No MAKEFILE
	OR	A
	JR	Z,BldDcNo		; No run target
	LD	HL,BldNMkRun		; "MAKE.EXE run"
	CALL	BldStrCpy
	XOR	A
	RET
BldDcNo	LD	A,(BldIoErr)
	OR	A
	JR	NZ,BldDcErr
	LD	A,#01
	RET
BldDcErr	LD	A,#02
	RET
;[]===========================================================[]
; Scan MAKEFILE. In: A = 0 collect targets into FuncBuffer (#0D-separated,
; #00-terminated), out A = count; A = 1 look for a run: target, out A = 1
; found / 0 not. CF=1 on open/read/close error; BldIoErr=0 if absent.
; Streams the file in 512-byte chunks - no line-length limit.
BldScanMk
	LD	(BldMode),A
	XOR	A
	LD	(BldIoErr),A
	CALL	BldFOpen
	RET	C
	XOR	A
	LD	(BldTCnt),A
	LD	(BldRunF),A
	LD	HL,FuncBuffer
	LD	(BldLPtr),HL
BldScL0				; at column 0 (start of a line)
	CALL	BldFGet
	JP	C,BldScEnd
	CP	#0D
	JP	Z,BldScL0		; blank line
	CP	#0A
	JP	Z,BldScL0
	CP	#09
	JP	Z,BldScSkip		; TAB - recipe line
	CP	" "
	JP	Z,BldScSkip
	CP	"#"
	JP	Z,BldScSkip		; comment
	CP	";"
	JP	Z,BldScSkip
	CP	"-"
	JP	Z,BldScSkip		; do not pass a target as a MAKE option
	CP	"."
	JP	Z,BldScSkip		; .PHONY and friends
	LD	HL,BldTName		; capture a candidate name (A=first char)
	LD	B,#18			; max 24 chars
BldScCap	CP	"$"
	JP	Z,BldScSkip		; dynamic names need MAKE expansion
	CP	"%"
	JP	Z,BldScSkip		; pattern rules are not explicit goals
	LD	(HL),A
	INC	HL
	PUSH	HL			; BldFGet clobbers HL - keep write cursor
	CALL	BldFGet
	POP	HL
	JP	C,BldScEnd		; EOF mid-name - no colon, drop
	CP	":"
	JR	Z,BldScTgt
	CP	"="
	JP	Z,BldScSkip		; variable assignment
	CP	" "
	JR	Z,BldScSpace
	CP	#09
	JR	Z,BldScSpace
	CP	#0D
	JP	Z,BldScL0		; line ended before ':'
	CP	#0A
	JP	Z,BldScL0
	DJNZ	BldScCap
	JR	BldScSkip		; too long - not a target
BldScSpace
	PUSH	HL
	CALL	BldFGet
	POP	HL
	JP	C,BldScEnd
	CP	" "
	JR	Z,BldScSpace
	CP	#09
	JR	Z,BldScSpace
	CP	":"
	JR	Z,BldScTgt
	CP	#0D
	JP	Z,BldScL0
	CP	#0A
	JP	Z,BldScL0
	JR	BldScSkip
BldScTgt	LD	(HL),#00
	CALL	BldFGet		; := is an assignment, not a rule
	PUSH	AF
	CP	"="
	JR	Z,BldScAssign
	CALL	BldGotTgt
	POP	AF
	JP	C,BldScEnd
	CP	#0D
	JP	Z,BldScL0
	CP	#0A
	JP	Z,BldScL0
	LD	A,(BldMode)
	OR	A
	JP	Z,BldScSkip		; collect mode: continue
	LD	A,(BldRunF)
	OR	A
	JR	NZ,BldScEnd		; find-run mode: stop on first match
	JR	BldScSkip
BldScAssign	POP	AF
BldScSkip	CALL	BldFGet			; consume to end of line
	JP	C,BldScEnd
	CP	#0A
	JP	Z,BldScL0
	CP	#0D
	JP	Z,BldScL0
	JR	BldScSkip
BldScEnd	CALL	BldFClose
	LD	A,(BldIoErr)
	OR	A
	SCF
	RET	NZ
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
; Leave room for the longest name (24), separator and final NUL.
	LD	HL,(BldLPtr)
	LD	DE,FuncBuffer+#E7
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
	CALL	BldFOpenName
	RET	C
	LD	(BldFHnd),A
	LD	HL,#0000
	LD	(BldFLeft),HL		; force a refill on first BldFGet
	XOR	A
	LD	(BldFEof),A
	RET
BldFClose	LD	A,(BldFHnd)
	LD	C,Dss.Close
	CALL	BldDssTramp
	RET	NC
	LD	(BldIoErr),A
	RET
; Out: A = next char, CF=0; CF=1 at EOF.
BldFGet	LD	HL,(BldFLeft)
	LD	A,H
	OR	L
	JR	NZ,BldFG1
	LD	A,(BldFEof)
	OR	A
	JR	NZ,BldFGE		; drained and EOF
	PUSH	BC
	CALL	BldFRead
	POP	BC
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
	CALL	BldDssTramp
	JR	C,BldFReadErr
	LD	(BldFLeft),DE		; DE = bytes actually read
	LD	A,D			; short read (<512) -> EOF after drain
	CP	#02
	RET	NC
	LD	A,#01
	LD	(BldFEof),A
	RET
BldFReadErr
	LD	(BldIoErr),A
	LD	HL,#0000
	LD	(BldFLeft),HL
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
; Decision-layer data
BldIoErr	DEFB	#00		; fatal file error, distinct from absent file
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
BldParams	DEFS	66,0		; [0]=len, [1..]=ASCIIZ session args

BldNBat		DEFB	"BUILD.BAT",0
BldNRBat	DEFB	"RUN.BAT",0
BldNMkf		DEFB	"MAKEFILE",0
BldNSys		DEFB	"SYSTEM.EXE /C ",0
BldNMake	DEFB	"MAKE.EXE",0
BldNMkRun	DEFB	"MAKE.EXE run",0
BldNRun		DEFB	"run",0
BldSpc		DEFB	" ",0
;[]===========================================================[]
