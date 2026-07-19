; Standalone unit-test shim for Dialog_Windows/Cmdline.asm (CmdLineOpen), the
; command-line file-open parser. Assembled alone (not part of KODE_BIN.asm),
; run under test/harness.js (a fork of sprinter-lha's Z80 test harness) via
; test/run_tests.sh.
;
; Raw binary: 0x4000-0x41FF is header padding (unused by the harness, which
; loads the image at 0x4000 and starts execution at 0x4200 with IX pointing
; at a PSP-style command-line buffer at 0x4180 = load-#80, matching the
; real KodeEXE.asm entry contract).

	include	'../shared_includes/constants/SP2000.inc'
	include	'../shared_includes/constants/dss_equ.inc'

	ORG	#4000
	BLOCK	#200,0			; header padding

	ORG	#4200
Start:
	PUSH	IX			; harness: IX -> cmdline buf (load-#80)
	POP	HL
	LD	DE,CmdTailBuf		; CmdTailBuf is defined in Cmdline.asm
	LD	BC,#0080
	LDIR
	CALL	CmdLineOpen
	LD	(ResultA),A

; Report "A=<n> NAME=<FileName>\n" via Dss.PCHARS (#5C) so the harness can
; capture it in stdout and the shell test driver can grep it.
	LD	HL,MsgA
	LD	C,#5C
	RST	ToDSS
	LD	A,(ResultA)
	ADD	A,'0'
	LD	(DigitBuf),A
	LD	HL,DigitBuf
	LD	C,#5C
	RST	ToDSS
	LD	HL,MsgName
	LD	C,#5C
	RST	ToDSS
	LD	HL,FileName
	LD	C,#5C
	RST	ToDSS
	LD	HL,NL
	LD	C,#5C
	RST	ToDSS

	LD	B,#00
	LD	C,Dss.Exit
	RST	ToDSS
Hang:
	JR	Hang

MsgA:		DEFB	"A=",0
MsgName:	DEFB	" NAME=",0
NL:		DEFB	#0A,0
DigitBuf:	DEFB	0,0
ResultA:	DEFB	0

; Stand-ins for the resident kode globals CmdLineOpen expects (normally
; FileName/FileHandle live in Kode_Main/Function.asm, DOSpage in
; Kode_Main/Mainunit.asm). Must be defined before the INCLUDE below, same
; ordering as in the real build.
DOSpage:	DEFB	0
FileHandle:	DEFB	0
FileName:	BLOCK	#80,0

	INCLUDE	'../Dialog_Windows/Cmdline.asm'
