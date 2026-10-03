; Standalone unit-test shim for Dialog_Windows/BuildScan.asm (the pure Build/Run
; decision layer). Assembled alone, run under test/harness.js via
; test/run_tests.sh. The harness mounts a fixture dir as C:\WORK (current dir),
; traps RST #10 as DSS, and passes a PSP-style command tail at IX (load-#80):
; [IX+0]=len, [IX+1..]=text.
;
; The tail selects the action:
;   BUILD        -> BldDecide A=0  -> prints "A=<n> CMD=<BldCmdBuf>"
;   RUN [args]   -> BldDecide A=1  -> prints "A=<n> CMD=<BldCmdBuf>" (args -> BldParams)
;   TARGETS      -> BldScanMk A=0  -> prints "A=<n> LIST=<t1|t2|...>"

	include	'../shared_includes/constants/SP2000.inc'
	include	'../shared_includes/constants/dss_equ.inc'

FuncBuffer	EQU	#7900		; resident scratch stand-in (target list)
SynFileBuf	EQU	#7000		; PG2 scratch stand-in (makefile chunk)

	ORG	#4000
	BLOCK	#200,0			; header padding (harness enters at #4200)

	ORG	#4200
Start:
	PUSH	IX			; IX -> PSP tail (load-#80)
	POP	HL
	LD	DE,TailBuf
	LD	BC,#0080
	LDIR

	LD	HL,TailBuf
	LD	B,(HL)			; B = tail length
	INC	HL			; HL -> text
	LD	A,(HL)
	CP	"B"
	JR	Z,DoBuild
	CP	"R"
	JR	Z,DoRun
; TARGETS
	XOR	A
	CALL	BldScanMk
	JR	C,DoErr
	LD	(ResA),A
	CALL	PrintA
	LD	HL,MsgList
	CALL	PChars
	LD	HL,FuncBuffer
	LD	DE,OutBuf
	CALL	ListXform
	LD	HL,OutBuf
	CALL	PChars
	JR	Fin

DoBuild	XOR	A
	CALL	BldDecide
	JR	ReportCmd

DoRun	CALL	ParseParams
	LD	A,#01
	CALL	BldDecide
ReportCmd
	LD	(ResA),A
	CALL	PrintA
	LD	HL,MsgCmd
	CALL	PChars
	LD	HL,BldCmdBuf
	CALL	PChars
	JR	Fin

DoErr	LD	A,#09			; 9 = "no makefile" marker for TARGETS
	LD	(ResA),A
	CALL	PrintA
Fin	LD	HL,NL
	CALL	PChars
	LD	B,#00
	LD	C,Dss.Exit
	RST	ToDSS
Hang	JR	Hang

; Parse "RUN [args]" -> BldParams ([0]=len, [1..]=ASCIIZ). HL->text, B=len.
ParseParams
PrmSk1	LD	A,B
	OR	A
	JR	Z,PrmNone
	LD	A,(HL)
	CP	" "
	JR	Z,PrmSp
	INC	HL
	DEC	B
	JR	PrmSk1
PrmSp	LD	A,B
	OR	A
	JR	Z,PrmNone
	LD	A,(HL)
	CP	" "
	JR	NZ,PrmCopy
	INC	HL
	DEC	B
	JR	PrmSp
PrmCopy	LD	DE,BldParams+1
	LD	C,#00
PrmCp1	LD	A,B
	OR	A
	JR	Z,PrmDone
	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	INC	C
	DEC	B
	JR	PrmCp1
PrmDone	XOR	A
	LD	(DE),A
	LD	A,C
	LD	(BldParams),A
	RET
PrmNone	XOR	A
	LD	(BldParams),A
	LD	(BldParams+1),A
	RET

; Transform FuncBuffer (#0D-separated, #00-term) -> OutBuf ("a|b|c",0).
ListXform
LstX	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,LstXe
	CP	#0D
	JR	NZ,LstXp
	LD	A,(HL)			; peek next
	OR	A
	JR	Z,LstXe			; trailing separator -> drop
	LD	A,"|"
LstXp	LD	(DE),A
	INC	DE
	JR	LstX
LstXe	XOR	A
	LD	(DE),A
	RET

; Print "A=<digit> " (single decimal digit, sufficient for fixtures).
PrintA	LD	HL,MsgA
	CALL	PChars
	LD	A,(ResA)
	ADD	A,"0"
	LD	(DigitBuf),A
	LD	HL,DigitBuf
	CALL	PChars
	RET

PChars	LD	C,Dss.PChars
	RST	ToDSS
	RET

MsgA		DEFB	"A=",0
MsgCmd		DEFB	" CMD=",0
MsgList		DEFB	" LIST=",0
NL		DEFB	#0A,0
DigitBuf	DEFB	0,0
ResA		DEFB	0
OutBuf		DEFS	260,0
TailBuf		DEFS	#80,0

	INCLUDE	'../Dialog_Windows/BuildScan.asm'
