; DSS parent for real BIOS console restoration checks in Sprinter/MAME.
; Build with -DCON_MODE=2|3 -DCON_PAGE=0|1 and --raw=<fixture>.EXE.
	INCLUDE '../Shared_Includes/constants/SP2000.inc'
	INCLUDE '../Shared_Includes/constants/bios_equ.inc'
	INCLUDE '../Shared_Includes/constants/dss_equ.inc'
	IFNDEF CON_MODE : DEFINE CON_MODE 3 : ENDIF
	IFNDEF CON_PAGE : DEFINE CON_PAGE 0 : ENDIF
	ORG #0000
	BYTE 'EXE',1
	DWORD #0200
	WORD End-Code
	WORD 0,0,0
	WORD #4000,#4000,#7FFF
	BLOCK #0200-$,0
	DISP #4000
Code	DI
	LD	BC,#03C2
	RST	#08
	DI
	JP	C,Stop
	LD	HL,Pages
	LD	C,#C5
	RST	#08
	DI
	LD	A,(Pages+2)
	OUT	(SLOT2),A
	LD	SP,#BFFF
	LD	A,CON_MODE
	LD	B,CON_PAGE
	LD	C,Dss.SetVMod
	RST	#10
	DI
	LD	A,(Pages)
	OUT	(SLOT3),A
	LD	HL,#C000
	LD	DE,#0000
Fill	LD	A,D
	ADD	A,E
	AND	#0F
	OR	#10
	LD	B,A
	LD	A,E
	AND	#1F
	ADD	A,'A'
	LD	(HL),A
	INC	HL
	LD	(HL),B
	INC	HL
	INC	E
	LD	A,E
	CP	80		; physical width in both text modes
	JR	NZ,Fill
	LD	E,#00
	INC	D
	LD	A,D
	CP	32
	JR	NZ,Fill
	LD	A,(Pages)
	LD	C,#B3
	CALL	Copy
	LD	DE,#1F00+CON_MODE*40-41	; bottom-right: mode2 x39, mode3 x79
	LD	C,Dss.Locate
	RST	#10
	DI
	LD	HL,Command
	LD	BC,#0040
	EI
	RST	#10
	DI
	LD	(Result),A
	LD	C,Dss.Cursor
	RST	#10
	DI
	LD	(Cursor),DE
	LD	C,Dss.GetVMod
	RST	#10
	DI
	LD	(Mode),A
	LD	A,B
	LD	(Page),A
	LD	A,(Pages+1)
	LD	C,#B2
	CALL	Copy
	LD	A,(Pages)
	OUT	(SLOT2),A
	LD	A,(Pages+1)
	OUT	(SLOT3),A
	LD	HL,#8000
	LD	DE,#C000
	LD	BC,5120
Compare	LD	A,(DE)
	CP	(HL)
	JR	NZ,Failed
	INC	DE
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,Compare
	LD	A,#01
	LD	(Match),A
Failed	LD	A,#01
	LD	(Done),A
Stop	EI
	HALT
	LD	A,(ExitFlag)
	OR	A
	JR	Z,Stop
	LD	BC,#0041
	RST	#10
Copy	LD	B,A
	LD	IX,#C000
	LD	HL,#2050
	LD	DE,#0000
	XOR	A
	RST	#08
	DI
	RET
Command	BYTE 'C:\KODE.EXE C:\MAIN.ASM',0
Pages	BYTE 0,0,0,0
ExitFlag	BYTE 0
Report	BYTE 'KCON'
Done	BYTE 0
Match	BYTE 0
Result	BYTE 0
Mode	BYTE 0
Page	BYTE 0
Cursor	WORD 0
End
	ENT
