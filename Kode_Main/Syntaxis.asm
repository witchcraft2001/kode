 _mCollectInfo_addStart
;
Syntaxis:
	LD	HL,TextBuff
	LD	B,(IY+#02)
	LD	A,(CSLabel)
	LD	E,A
	LD	A,(CSMnemon)
	LD	D,A
	LD	A,(ColTxtWin)
	LD	C,A
	INC	HL
	LD	(HL),C
	LD	A,(CSComment)
	BIT	0,(IY-#04)
	JR	Z,Syntax1
	LD	A,(ColSelTxt)
	LD	C,A
	LD	E,A
	LD	D,A
	LD	(HL),A
Syntax1:
	DEC	HL
	LD	(TmpColC),A
	LD	A,C
	LD	(TmpColW),A
	LD	A,D
	LD	(TmpColM),A
	LD	A,E
	LD	(TmpColL),A
	LD	C,#00
	LD	(IY+#08),C
	LD	(IY+#09),C
	LD	(IY+#0A),C
	LD	(IY+#0B),C
	LD	A,B
	OR	A
	RET	Z
	LD	E,#20
	LD	A,(TmpColL)
	LD	D,A
	SET	0,(IY+#08)
; Examination label (len)
SnLoop1:
	LD	A,(HL)
	CP	";"
	JP	Z,Commen1
	CP	E
	JR	Z,SnNext1
	INC	HL
	LD	(HL),D
	INC	HL
	INC	C
	DJNZ	SnLoop1
	LD	(IY+#09),C	; Len label
	RET 

SnNext1:
	LD	(IY+#09),C	; Len label
	LD	A,C
	OR	A
	JR	NZ,$+6
	RES	0,(IY+#08)
	LD	A,(TmpColW)
	LD	C,A
	LD	D,";"
SnLoop2:
	LD	A,(HL)
	CP	D
	JP	Z,Comm01
	CP	E
	JR	NZ,SnNext2
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	SnLoop2

SnNext2:
	LD	A,B
	OR	A
	RET	Z
	LD	(BegComm),HL
	LD	C,#00
SnLoop3:
	LD	A,(HL)
	CP	D
	JP	Z,Commen2
	CP	E
	JR	Z,SnNext3
	INC	HL
	INC	HL
	INC	C
	DJNZ	SnLoop3

SnNext3:
	LD	(IY+#0A),C	; Len operator
	CALL	SetComm
	LD	A,B
	OR	A
	RET	Z
	LD	A,(TmpColW)
	LD	C,A
SnLoop4:
	LD	A,(HL)
	CP	D
	JP	Z,Commen3
	CP	E
	JR	NZ,SnNext4
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	SnLoop4
	RET 

SnNext4:
	LD	(BegArgm),HL
	LD	C,#00
SnLoop5:
	LD	A,(HL)

	CP	#22
	JR	NZ,SnNxt04
	LD	A,(IY+#08)
	XOR	#80
	LD	(IY+#08),A
	JR	SnNxt24

SnNxt04:
	BIT	7,(IY+#08)
	JR	NZ,SnNxt24
	CP	D
	JP	Z,Commen4
	CP	E
	JR	Z,SnNext5
SnNxt24:
	INC	HL
	INC	HL
	INC	C
	DJNZ	SnLoop5

SnNext5:
	LD	(IY+#0B),C	; Len argument
	CALL	SetArgm
	LD	A,B
	OR	A
	RET	Z

	LD	A,(TmpColW)
	LD	C,A
SnLoop6:
	LD	A,(HL)
	CP	D
	JP	Z,Commen5
	CP	E
	JR	NZ,NotEnd
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	SnLoop6
	RET 

NotEnd:
	CALL	NotComm
SnLoop7:
	LD	A,(HL)
	CP	D
	JP	Z,Comm01
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	SnLoop7
	RET 

; Search operand & set(res) color
SetComm:
	EXX 

 IF NEW_VERSION
	in a,(SLOT3)
	push af
	ld a,(AsmTabPg)	
	out (SLOT3),a	
 ELSE
	IN	A,(SLOT2)
	PUSH	AF
 ENDIF

	LD	HL,(BegComm)
	LD	C,(IY+#0A)	; Len command
	LD	DE,SetCcol
	PUSH	DE

 IFN NEW_VERSION
	LD	A,(AsmTabPg)
	OUT	(SLOT2),A
 ENDIF

	LD	A,(HL)
	CP	"A"
	JP	Z,Cmnd_A
	CP	"B"
	JP	Z,Cmnd_B
	CP	"C"
	JP	Z,Cmnd_C
	CP	"D"
	JP	Z,Cmnd_D
	CP	"E"
	JP	Z,Cmnd_E
	CP	"F"
	JP	Z,Cmnd_F
	CP	"H"
	JP	Z,Cmnd_H
	CP	"I"
	JP	Z,Cmnd_I
	CP	"J"
	JP	Z,Cmnd_J
	CP	"L"
	JP	Z,Cmnd_L
	CP	"N"
	JP	Z,Cmnd_N
	CP	"O"
	JP	Z,Cmnd_O
	CP	"P"
	JP	Z,Cmnd_P
	CP	"R"
	JP	Z,Cmnd_R
	CP	"S"
	JP	Z,Cmnd_S
	CP	"U"
	JR	Z,Cmnd_U
	CP	"V"
	JR	Z,Cmnd_V
	CP	"X"
	JR	Z,Cmnd_X
	POP	DE
; Res color operand
ResCcol:
	LD	HL,(BegComm)
	LD	B,C		; Len command
	LD	A,(TmpColW)
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-3

 IF NEW_VERSION
	set 6,(iy+8)
	pop af
	out (SLOT3),a
 ELSE
	POP	AF
	OUT	(SLOT2),A
	SET	6,(IY+#08)
 ENDIF
	EXX 
	RET 

; Set color operand
SetCcol:
	LD	HL,(BegComm)
	LD	B,C		; Len command
	LD	A,(TmpColM)
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-3
	LD	(BegTabl),IX
	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	LD	(BegAtbl),HL

 IF NEW_VERSION
	set 1,(iy+8)
	bit 7,(ix+6)
	jr nz,Cex	
	ld a,(ix+8)
	or a			
	jr z,Cex		
	set 4,(iy+8)
Cex:
 	pop af		
 	out (SLOT3),a
 ELSE
	LD	C,(IX+6)
	LD	B,(IX+8)
	POP	AF
	OUT	(SLOT2),A
	SET	1,(IY+8)
	BIT	7,C
	JR	NZ,Cex
	LD	A,B
	OR	A
	JR	Z,Cex
	SET	4,(IY+#08)
Cex:
 ENDIF
	EXX 
	RET 

; Searching command
Cmnd_X:	LD	IX,CMD_TBL.CHR.X
	LD	A,(IX+#00)
	CP	C
	JR	NZ,CmndNo1
	CALL	SearchC
	RET	Z
	JR	CmndNo1

Cmnd_V:	LD	IX,CMD_TBL.CHR.V
	LD	DE,#000B
	LD	A,(IX+#00)
	CP	C
	CALL	Z,SearchC
	RET	Z
	ADD	IX,DE
	LD	A,(IX+#00)
	CP	C
	JR	NZ,CmndNo1
	CALL	SearchC
	RET	Z
	JR	CmndNo1

Cmnd_U:	LD	IX,CMD_TBL.CHR.U
	LD	A,(IX+#00)
	CP	C
	JR	NZ,CmndNo1
	CALL	SearchC
	RET	Z
	JR	CmndNo1

Cmnd_S:	LD	IX,CMD_TBL.CHR.S
	LD	DE,#000B
	LD	B,#08
CmndSlp:	LD	A,(IX+#00)
	CP	C
	CALL	Z,SearchC
	RET	Z
	ADD	IX,DE
	DJNZ	CmndSlp
CmndNo1:	LD	HL,ResCcol
	EX	(SP),HL
	RET 

Cmnd_R:	LD	IX,CMD_TBL.CHR.R
	LD	DE,#000B
	LD	B,#0F
CmndRlp:	LD	A,(IX+#00)
	CP	C
	CALL	Z,SearchC
	RET	Z
	ADD	IX,DE
	DJNZ	CmndRlp
	LD	HL,ResCcol
	EX	(SP),HL
	RET 

Cmnd_P:	LD	IX,CMD_TBL.CHR.P
	LD	DE,#000B
	LD	B,#03
CmndPlp:	LD	A,(IX+#00)
	CP	C
	CALL	Z,SearchC
	RET	Z
	ADD	IX,DE
	DJNZ	CmndPlp
	LD	HL,ResCcol
	EX	(SP),HL
	RET 

Cmnd_O:	LD	IX,CMD_TBL.CHR.O
	LD	DE,#000B
	LD	B,#07
CmndOlp:	LD	A,(IX+#00)
	CP	C
	CALL	Z,SearchC
	RET	Z
	ADD	IX,DE
	DJNZ	CmndOlp
	LD	HL,ResCcol
	EX	(SP),HL
	RET 

Cmnd_N:	LD	IX,CMD_TBL.CHR.N
	LD	DE,#000B
	LD	A,(IX+#00)
	CP	C
	CALL	Z,SearchC
	RET	Z
	ADD	IX,DE
	LD	A,(IX+#00)
	CP	C
	JR	NZ,CmndNo2
	CALL	SearchC
	RET	Z
	JR	CmndNo2

Cmnd_L:	LD	IX,CMD_TBL.CHR.L
	LD	DE,#000B
	LD	B,#05
CmndLlp:	LD	A,(IX+#00)
	CP	C
	CALL	Z,SearchC
	RET	Z
	ADD	IX,DE
	DJNZ	CmndLlp
CmndNo2:	LD	HL,ResCcol
	EX	(SP),HL
	RET 

Cmnd_J:	LD	IX,CMD_TBL.CHR.J
	LD	DE,#000B
	LD	A,(IX+#00)
	CP	C
	CALL	Z,SearchC
	RET	Z
	ADD	IX,DE
	LD	A,(IX+#00)
	CP	C
	JR	NZ,CmndNo2
	CALL	SearchC
	RET	Z
	JR	CmndNo2

Cmnd_I:	LD	IX,CMD_TBL.CHR.I
	LD	DE,#000B
	LD	B,#0A
CmndIlp:	LD	A,(IX+#00)
	CP	C
	CALL	Z,SearchC
	RET	Z
	ADD	IX,DE
	DJNZ	CmndIlp
	LD	HL,ResCcol
	EX	(SP),HL
	RET 

Cmnd_H:	LD	IX,CMD_TBL.CHR.H
	LD	A,(IX+#00)
	CP	C
	JR	NZ,CmndNo3
	CALL	SearchC
	RET	Z
	JR	CmndNo3

Cmnd_F:	LD	IX,CMD_TBL.CHR.F
	LD	A,(IX+#00)
	CP	C
	JR	NZ,CmndNo3
	CALL	SearchC
	RET	Z
	JR	CmndNo3

Cmnd_E:	LD	IX,CMD_TBL.CHR.E
	LD	DE,#000B
	LD	B,#05
CmndElp:	LD	A,(IX+#00)
	CP	C
	CALL	Z,SearchC
	RET	Z
	ADD	IX,DE
	DJNZ	CmndElp
CmndNo3:	LD	HL,ResCcol
	EX	(SP),HL
	RET 

Cmnd_D:	LD	IX,CMD_TBL.CHR.D
	LD	DE,#000B
	LD	B,#0D
CmndDlp:	LD	A,(IX+#00)
	CP	C
	CALL	Z,SearchC
	RET	Z
	ADD	IX,DE
	DJNZ	CmndDlp
	LD	HL,ResCcol
	EX	(SP),HL
	RET 

Cmnd_C:	LD	IX,CMD_TBL.CHR.C
	LD	DE,#000B
	LD	B,#0A
CmndClp:	LD	A,(IX+#00)
	CP	C
	CALL	Z,SearchC
	RET	Z
	ADD	IX,DE
	DJNZ	CmndClp
	LD	HL,ResCcol
	EX	(SP),HL
	RET 

Cmnd_B:	LD	IX,CMD_TBL.CHR.B
	LD	A,(IX+#00)
	CP	C
	JR	NZ,CmndNo4
	CALL	SearchC
	RET	Z
	JR	CmndNo4

Cmnd_A:	LD	IX,CMD_TBL.CHR.A
	LD	DE,#000B
	LD	B,#04
CmndAlp:	LD	A,(IX+#00)
	CP	C
	CALL	Z,SearchC
	RET	Z
	ADD	IX,DE
	DJNZ	CmndAlp
CmndNo4:	LD	HL,ResCcol
	EX	(SP),HL
	RET 

SearchC:	PUSH	IX
	PUSH	HL
	PUSH	BC
	LD	B,A
	DEC	B
SrchLp1:	INC	HL
	INC	HL
	LD	A,(HL)
	CP	(IX+#02)
	JR	NZ,NopCmnd
	INC	IX
	DJNZ	SrchLp1
	SUB	A
NopCmnd:	POP	BC
	POP	HL
	POP	IX
	RET 

; Res argument & operand color
NotComm:	EXX 
	LD	HL,(BegComm)
	LD	A,(IY+#0A)	; Len command
	OR	A
	JR	Z,NotExit
	LD	B,A
	LD	A,(TmpColW)
	LD	C,A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-3
	LD	A,(IY+#0B)	; Len argument
	OR	A
	JR	Z,NotExit
	LD	HL,(BegArgm)
	LD	B,A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-3
NotExit:	EXX 
	SET	6,(IY+#08)
	RET 

; Search & set(res) argument color
SetArgm:	BIT	6,(IY+#08)
	JR	NZ,NotComm
	EXX 

 IF NEW_VERSION
	in a,(SLOT3)		
	push af			
	ld a,(AsmTabPg)	
	out (SLOT3),a		
 ELSE
	LD	C,(IY+#0B)	; Len argument
	LD	B,(IY+#08)	; Len argument
	PUSH	IY
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(AsmTabPg)
	OUT	(SLOT2),A
	LD	IY,ArgData
	LD	(IY+#00),C
	LD	(IY+#01),B
 ENDIF
	LD	DE,SetCarg
	PUSH	DE
	LD	IX,(BegTabl)
	BIT	7,(IX+#08)
	JR	Z,SetArg0

	LD	DE,(BegArgm)
	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	LD	C,(IX+#00)
	LD	B,(IX+#08)
	RES	7,B
	LD	A,(DE)
UpgrLp:	CP	(HL)
	JR	Z,FoundUp
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	DJNZ	UpgrLp
	JR	ResArgm

FoundUp:	INC	HL
	LD	B,(HL)
	INC	HL
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	LD	E,C
	JR	SetArg1

SetArg0:	LD	L,(IX+#09)	; Address command table
	LD	H,(IX+#0A)
	LD	E,(IX+#00)	; Len operand
	LD	B,(IX+#08)	; Equipmend command
SetArg1:	LD	D,#00
	PUSH	HL
	POP	IX
	INC	E
	ADD	HL,DE

 IF NEW_VERSION
	LD	A,(IY+#0B)
 ELSE
	LD	A,(IY+#00)	; Len argument
 ENDIF

	LD	(Cycle1+1),A
	RLCA 
	RLCA 
	RLCA 
	RLCA 
	LD	C,A
	LD	DE,#0013
	LD	A,B
	OR	A
	JR	Z,ResArgm
ArgLp01:	LD	A,(IX+#12)
	OR	A
	JR	Z,ResA
	AND	#F0
	JR	Z,ArgProg
	CP	C
	CALL	NC,SrchArg
	RET	Z
ResA:	ADD	HL,DE
	ADD	IX,DE
	DJNZ	ArgLp01
ResArgm:	POP	DE
	POP	AF
	
 IF NEW_VERSION
	OUT	(SLOT3),A
 ELSE
	OUT	(SLOT2),A
	LD	A,(IY+#01)
	POP	IY
	LD	(IY+#08),A
 ENDIF

	EXX 
	JP	NotComm

SrchArg:	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	LD	DE,(BegArgm)
Cycle1:	LD	B,#00
	LD	A,(DE)
	CP	(HL)
	JR	NZ,ArgmNo
	INC	HL
	INC	DE
	INC	DE
	DJNZ	Cycle1+2
	POP	AF

 IF NEW_VERSION
	SET	4,(IY+#08)
 ELSE
	SET	4,(IY+#01)
 ENDIF

	JR	NZ,.exit

 IF NEW_VERSION
	RES	4,(IY+#08)
 ELSE
	RES	4,(IY+#01)
 ENDIF

.exit:	POP	BC
	POP	DE
	POP	HL
	SUB	A
	RET 

ArgmNo:	POP	AF
	POP	BC
	POP	DE
	POP	HL
	SUB	A
	INC	A
	RET 

; Arguments with parameters
ArgProg:	POP	DE

 IF NEW_VERSION
	RES	4,(IY+#08)
 ELSE
	RES	4,(IY+#01)
 ENDIF

ArgLoop:	LD	A,(IX+#12)
	AND	#0F
	DEC	A
	JR	Z,Progr01
	DEC	A
	JR	Z,Progr02
	DEC	A
	JP	Z,Progr03
	DEC	A
	JP	Z,Progr04
	DEC	A
	JP	Z,Progr05
	DEC	A
	JP	Z,Progr06
	DEC	A
	JP	Z,Progr07
	DEC	A
	JP	Z,Progr08
	DEC	A
	JP	Z,Progr09
	DEC	A
	JP	Z,Progr0A
	DEC	A
	JP	Z,Progr0B
	DEC	A
	JP	Z,Progr0C
	DEC	A
	JP	Z,Progr0D
	DEC	A
	JP	Z,Progr0E
	JP	Progr0F

ArgLpNx:	JR	Z,ArgLext
	LD	DE,#0013
	ADD	HL,DE
	ADD	IX,DE
	DJNZ	ArgLoop
	POP	AF
 IF NEW_VERSION
	OUT	(SLOT3),A
 ELSE
	OUT	(SLOT2),A
	LD	A,(IY+#01)
	POP	IY
	LD	(IY+#08),A
 ENDIF
	EXX 
	JP	NotComm


ArgLext:	EXX 
 IF NEW_VERSION
	set 2,(iy+8)	
	ld (BegAtbl),ix	
	pop af			
	out (SLOT3),a	
 ELSE
	POP	AF
	OUT	(SLOT2),A
	LD	A,(IY+#01)
	POP	IY
	SET	2,A
	LD	(IY+#08),A
	LD	(BegAtbl),IX
 ENDIF
	RET 

; Argument type: only argm
Progr01:	PUSH	HL
	PUSH	BC
	LD	HL,(BegArgm)
	LD	A,(Cycle1+1)
	LD	B,A
	LD	A,(TmpColL)
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-3
	SUB	A
	POP	BC
	POP	HL
	JP	ArgLpNx

; Argument type: (rr+argum)
Progr02:	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(Cycle1+1)
	LD	C,A
	LD	A,(TmpColM)
	LD	B,A
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,Prg02No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg02Ys
	INC	HL
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg02No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg02Ys
	INC	HL
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg02No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg02Ys
	INC	HL
	INC	DE
	LD	A,(HL)		;+ or -
	CP	"-"
	JR	Z,$+6
	CP	"+"
	JR	NZ,Prg02No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg02Ys
	INC	HL
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,Prg02Ys
	LD	B,C
	LD	A,(TmpColL)
	LD	C,A
	LD	A,(DE)		; Search )
PrLp11:	CP	(HL)
	JR	Z,PrLp12
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrLp11
	JR	Prg02Ys

PrLp12:	LD	A,(TmpColM)
	INC	HL
	LD	(HL),A
	DEC	B
	JR	Z,Prg02Ys+4
	JR	Prg02No

Prg02Ys:

 IF NEW_VERSION
	SET	4,(IY+#08)
 ELSE
	SET	4,(IY+#01)
 ENDIF

	SUB	A
Prg02No:	POP	BC
	POP	DE
	POP	HL
	JP	ArgLpNx

; Argument type: r,argum
Progr03:	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(Cycle1+1)
	LD	C,A
	LD	A,(TmpColM)
	LD	B,A
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg03No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg03Ys
	INC	HL
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,Prg03No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg03Ys
	INC	HL
	INC	DE
	INC	DE
	LD	B,C
	LD	A,(TmpColL)
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-3
	JR	$+6

Prg03Ys:

 IF NEW_VERSION
	SET	4,(IY+#08)
 ELSE
	SET	4,(IY+#01)
 ENDIF

	SUB	A
Prg03No:	POP	BC
	POP	DE
	POP	HL
	JP	ArgLpNx

; Argument type: r,(argum)
Progr04:	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(Cycle1+1)
	LD	C,A
	LD	A,(TmpColM)
	LD	B,A
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg04No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg04Ys
	INC	HL
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,Prg04No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg04Ys
	INC	HL
	INC	DE
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,Prg04No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg04Ys
	INC	HL
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,Prg04Ys
	LD	B,C
	LD	A,(TmpColL)
	LD	C,A
	LD	A,(DE)		; Search )
PrLp41:	CP	(HL)
	JR	Z,PrLp42
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrLp41
	JR	Prg04Ys

PrLp42:	LD	A,(TmpColM)
	INC	HL
	LD	(HL),A
	DEC	B
	JR	Z,Prg04Ys+4
	JR	Prg04No

Prg04Ys:

 IF NEW_VERSION
	SET	4,(IY+#08)
 ELSE
	SET	4,(IY+#01)
 ENDIF

	SUB	A
Prg04No:	POP	BC
	POP	DE
	POP	HL
	JP	ArgLpNx

; Argument type: r,(rr+argum)
Progr05:	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(Cycle1+1)
	LD	C,A
	LD	A,(TmpColM)
	LD	B,A
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg05No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg05Ys
	INC	HL
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,Prg05No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg05Ys
	INC	HL
	INC	DE
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,Prg05No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg05Ys
	INC	HL
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg05No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg05Ys
	INC	HL
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg05No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg05Ys
	INC	HL
	INC	DE
	LD	A,(HL)		;+ or -
	CP	"-"
	JR	Z,$+6
	CP	"+"
	JR	NZ,Prg05No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg05Ys
	INC	HL
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,Prg05Ys
	LD	B,C
	LD	A,(TmpColL)
	LD	C,A
	LD	A,(DE)		; Search )
PrLp51:	CP	(HL)
	JR	Z,PrLp52
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrLp51
	JR	Prg05Ys

PrLp52:	LD	A,(TmpColM)
	INC	HL
	LD	(HL),A
	DEC	B
	JR	Z,Prg05Ys+4
	JR	Prg05No

Prg05Ys:

 IF NEW_VERSION
	SET	4,(IY+#08)
 ELSE
	SET	4,(IY+#01)
 ENDIF

	SUB	A
Prg05No:	POP	BC
	POP	DE
	POP	HL
	JP	ArgLpNx

; Argument type: rr,argum
Progr06:	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(Cycle1+1)
	LD	C,A
	LD	A,(TmpColM)
	LD	B,A
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg06No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg06Ys
	INC	HL
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg06No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg06Ys
	INC	HL
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,Prg06No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg06Ys
	INC	HL
	INC	DE
	INC	DE
	LD	B,C
	LD	A,(TmpColL)
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-3
	JR	$+6

Prg06Ys:

 IF NEW_VERSION
	SET	4,(IY+#08)
 ELSE
	SET	4,(IY+#01)
 ENDIF

	SUB	A
Prg06No:	POP	BC
	POP	DE
	POP	HL
	JP	ArgLpNx

; Argument type: rr,(argum)
Progr07:	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(Cycle1+1)
	LD	C,A
	LD	A,(TmpColM)
	LD	B,A
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg07No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg07Ys
	INC	HL
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg07No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg07Ys
	INC	HL
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,Prg07No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg07Ys
	INC	HL
	INC	DE
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,Prg07No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg07Ys
	INC	HL
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,Prg07Ys
	LD	B,C
	LD	A,(TmpColL)
	LD	C,A
	LD	A,(DE)		; Search )
PrLp71:	CP	(HL)
	JR	Z,PrLp72
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrLp71
	JR	Prg07Ys

PrLp72:	LD	A,(TmpColM)
	INC	HL
	LD	(HL),A
	DEC	B
	JR	Z,Prg07Ys+4
	JR	Prg07No

Prg07Ys:

 IF NEW_VERSION
	SET	4,(IY+#08)
 ELSE
	SET	4,(IY+#01)
 ENDIF

	SUB	A
Prg07No:	POP	BC
	POP	DE
	POP	HL
	JP	ArgLpNx

; Argument type: (hl),argum
Progr08:	PUSH	HL
	PUSH	BC
	LD	HL,(BegArgm)
	LD	A,(Cycle1+1)
	LD	C,A
	LD	A,(TmpColM)
	LD	B,A
	LD	A,"("		;(
	CP	(HL)
	JR	NZ,Prg08No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg08Ys
	INC	HL
	LD	A,(HL)		;H
	CP	"H"
	JR	NZ,Prg08No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg08Ys
	INC	HL
	LD	A,(HL)		;L
	CP	"L"
	JR	NZ,Prg08No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg08Ys
	INC	HL
	LD	A,")"		;)
	CP	(HL)
	JR	NZ,Prg08No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg08Ys
	INC	HL
	LD	A,","		;,
	CP	(HL)
	JR	NZ,Prg08No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg08Ys
	INC	HL
	LD	B,C
	LD	A,(TmpColL)
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-3
	JR	$+6

Prg08Ys:

 IF NEW_VERSION
	SET	4,(IY+#08)
 ELSE
	SET	4,(IY+#01)
 ENDIF

	SUB	A
Prg08No:	POP	BC
	POP	HL
	JP	ArgLpNx

; Argument type: (rr+argum),argum
Progr09:	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(Cycle1+1)
	LD	C,A
	LD	A,(TmpColM)
	LD	B,A
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,Prg09No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg09Ys
	INC	HL
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg09No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg09Ys
	INC	HL
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg09No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg09Ys
	INC	HL
	INC	DE
	LD	A,(HL)		;+ or -
	CP	"-"
	JR	Z,$+6
	CP	"+"
	JR	NZ,Prg09No
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg09Ys
	INC	HL
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,Prg09Ys
	LD	B,C
	LD	A,(TmpColL)
	LD	C,A
	LD	A,(DE)		; Search )
PrLp91:	CP	(HL)
	JR	Z,PrLp92
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrLp91
	JR	Prg09Ys

PrLp92:	LD	A,(TmpColM)
	LD	C,A
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg09Ys
	INC	HL
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,Prg09No
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg09Ys
	INC	HL
	LD	A,(TmpColL)
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-3
	JR	$+6

Prg09Ys:

 IF NEW_VERSION
	SET	4,(IY+#08)
 ELSE
	SET	4,(IY+#01)
 ENDIF

	SUB	A
Prg09No:	POP	BC
	POP	DE
	POP	HL
	JP	ArgLpNx

; Argument type: (rr+argum),r
Progr0A:	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(Cycle1+1)
	LD	C,A
	LD	A,(TmpColM)
	LD	B,A
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,Prg0ANo
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg0AYs
	INC	HL
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg0ANo
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg0AYs
	INC	HL
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg0ANo
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg0AYs
	INC	HL
	INC	DE
	LD	A,(HL)		;+ or -
	CP	"-"
	JR	Z,$+6
	CP	"+"
	JR	NZ,Prg0ANo
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg0AYs
	INC	HL
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,Prg0AYs
	LD	B,C
	LD	A,(TmpColL)
	LD	C,A
	LD	A,(DE)		; Search )
PrLpA1:	CP	(HL)
	JR	Z,PrLpA2
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrLpA1
	JR	Prg0AYs

PrLpA2:	LD	A,(TmpColM)
	LD	C,A
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg0AYs
	INC	HL
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,Prg0ANo
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg0AYs
	INC	HL
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg0ANo
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg0AYs+4
	JR	Prg0ANo

Prg0AYs:

 IF NEW_VERSION
	SET	4,(IY+#08)
 ELSE
	SET	4,(IY+#01)
 ENDIF

	SUB	A
Prg0ANo:	POP	BC
	POP	DE
	POP	HL
	JP	ArgLpNx

; Argument type: (argum),rr
Progr0B:	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(Cycle1+1)
	LD	C,A
	LD	A,(TmpColM)
	LD	B,A
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,Prg0BNo
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg0BYs
	INC	HL
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,Prg0BYs
	LD	B,C
	LD	A,(TmpColL)
	LD	C,A
	LD	A,(DE)		; Search )
PrLpB1:	CP	(HL)
	JR	Z,PrLpB2
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrLpB1
	JR	Prg0BYs

PrLpB2:	LD	A,(TmpColM)
	LD	C,A
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg0BYs
	INC	HL
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,Prg0BNo
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg0BYs
	INC	HL
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg0BNo
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg0BYs
	INC	HL
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg0BNo
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg0BYs+4
	JR	Prg0BNo

Prg0BYs:

 IF NEW_VERSION
	SET	4,(IY+#08)
 ELSE
	SET	4,(IY+#01)
 ENDIF

	SUB	A
Prg0BNo:	POP	BC
	POP	DE
	POP	HL
	JP	ArgLpNx

; Argument type: (argum),r
Progr0C:	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(Cycle1+1)
	LD	C,A
	LD	A,(TmpColM)
	LD	B,A
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,Prg0CNo
	INC	HL
	LD	(HL),B
	DEC	C
	JR	Z,Prg0CYs
	INC	HL
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,Prg0CYs
	LD	B,C
	LD	A,(TmpColL)
	LD	C,A
	LD	A,(DE)		; Search )
PrLpC1:	CP	(HL)
	JR	Z,PrLpC2
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrLpC1
	JR	Prg0CYs

PrLpC2:	LD	A,(TmpColM)
	LD	C,A
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg0CYs
	INC	HL
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,Prg0CNo
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg0CYs
	INC	HL
	INC	DE
	LD	A,(HL)		; R
	CP	"A"
	JR	NZ,Prg0CNo
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg0CYs+4
	JR	Prg0CNo

Prg0CYs:

 IF NEW_VERSION
	SET	4,(IY+#08)
 ELSE
	SET	4,(IY+#01)
 ENDIF

	SUB	A
Prg0CNo:	POP	BC
	POP	DE
	POP	HL
	JP	ArgLpNx

; Argument type: defb,defw,defd,include,incbin
Progr0D:	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	HL,(BegArgm)
	LD	A,(Cycle1+1)
	LD	B,A
	LD	A,(TmpColM)
	LD	E,A
	LD	A,(TmpColL)
	LD	D,A
	LD	C,","
PrD0000:	LD	A,(HL)
	CP	#22
	JR	Z,PrLpD2
PrLpD1:	LD	A,(HL)
	INC	HL
	CP	C
	JR	Z,PrD0001
	LD	(HL),D
	INC	HL
	DJNZ	PrLpD1
	JR	Prg0DYs+4

PrD0001:	LD	(HL),E
	INC	HL
	DEC	B
	JR	Z,Prg0DYs
	JR	PrD0000

PrLpD2:	INC	HL
	LD	(HL),E
	INC	HL
	DEC	B
	JR	Z,Prg0DYs
PrLpD23:	LD	A,(HL)
	INC	HL
	CP	#22
	JR	Z,PrLpD0
	LD	(HL),D
	INC	HL
	DJNZ	PrLpD23
	JR	Prg0DYs

PrLpD0:	LD	(HL),E
	INC	HL
	DEC	B
	JR	Z,Prg0DYs+4
	LD	A,(HL)
	CP	C
	JR	NZ,Prg0DNo
	INC	HL
	LD	(HL),E
	INC	HL
	DEC	B
	JR	Z,Prg0DYs
	JR	PrD0000

Prg0DYs:

 IF NEW_VERSION
	SET	4,(IY+#08)
 ELSE
	SET	4,(IY+#01)
 ENDIF

	SUB	A
Prg0DNo:	POP	BC
	POP	DE
	POP	HL
	JP	ArgLpNx

; Argument type: argum,r/argum,(hl)
Progr0E:	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(Cycle1+1)
	LD	B,A
	LD	A,(TmpColL)
	LD	C,A
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,Prg0EYs
	LD	A,(DE)		; Search ,
PrLpE1:	CP	(HL)
	JR	Z,PrLpE2
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrLpE1
	JR	Prg0EYs

PrLpE2:	LD	A,(TmpColM)
	LD	C,A
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg0EYs
	INC	HL
	INC	DE
	LD	A,(DE)		; R/(
	CP	(HL)
	JR	NZ,Prg0ENo
	INC	HL
	INC	DE
	LD	(HL),C
	DEC	B
	JR	Z,Prg0EYs
	INC	HL
	LD	A,(DE)		;H
	CP	(HL)
	JR	NZ,Prg0ENo
	INC	HL
	INC	DE
	LD	(HL),C
	DEC	B
	JR	Z,Prg0EYs
	INC	HL
	LD	A,(DE)		;L
	CP	(HL)
	JR	NZ,Prg0ENo
	INC	HL
	INC	DE
	LD	(HL),C
	DEC	B
	JR	Z,Prg0EYs
	INC	HL
	LD	A,(DE)		;)
	CP	(HL)
	JR	NZ,Prg0ENo
	INC	HL
	INC	DE
	LD	(HL),C
	DEC	B
	JR	Z,Prg0EYs
	JR	Prg0ENo

Prg0EYs:	LD	A,(DE)
	CP	#20
	JR	Z,$+6

 IF NEW_VERSION
	SET	4,(IY+#08)
 ELSE
	SET	4,(IY+#01)
 ENDIF

	SUB	A
Prg0ENo:	POP	BC
	POP	DE
	POP	HL
	JP	ArgLpNx

; Argument type: argum,(rr+argum)
Progr0F:	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(Cycle1+1)
	LD	B,A
	LD	A,(TmpColL)
	LD	C,A
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,Prg0FYs
	LD	A,(DE)		; Search ,
PrLpF1:	CP	(HL)
	JR	Z,PrLpF2
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrLpF1
	JR	Prg0FYs

PrLpF2:	LD	A,(TmpColM)
	LD	C,A
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg0FYs
	INC	HL
	INC	DE
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,Prg0FNo
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg0FYs
	INC	HL
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg0FNo
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg0FYs
	INC	HL
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,Prg0FNo
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg0FYs
	INC	HL
	INC	DE
	LD	A,(HL)		;+ or -
	CP	"-"
	JR	Z,$+6
	CP	"+"
	JR	NZ,Prg0FNo
	INC	HL
	LD	(HL),C
	DEC	B
	JR	Z,Prg0FYs
	INC	HL
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,Prg0FYs
	LD	A,(TmpColL)
	LD	C,A
	LD	A,(DE)		; Search )
PrLpF3:	CP	(HL)
	JR	Z,PrLpF4
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrLpF3
	JR	Prg0FYs

PrLpF4:	LD	A,(TmpColM)
	INC	HL
	LD	(HL),A
	DEC	B
	JR	Z,Prg0FYs+4
	JR	Prg0FNo

Prg0FYs:

 IF NEW_VERSION
	SET	4,(IY+#08)
 ELSE
	SET	4,(IY+#01)
 ENDIF

	SUB	A
Prg0FNo:	POP	BC
	POP	DE
	POP	HL
	JP	ArgLpNx

; Set color argument
SetCarg:
 IFN NEW_VERSION
	LD	C,(IY+#01)
	POP	AF
	OUT	(SLOT2),A
	POP	IY
	LD	(BegAtbl),IX
 ENDIF
 	LD	HL,(BegArgm)
	LD	B,(IY+#0B)
	LD	A,(TmpColM)
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-3

 IF NEW_VERSION
	ld (BegAtbl),ix
	set 2,(iy+8)	
	pop af			
	out (SLOT3),a		
 ELSE
	SET	2,C
	LD	(IY+#08),C
 ENDIF
	EXX 
	RET 

 IFN NEW_VERSION
ArgData:	WORD	0000
 ENDIF

; Set comments color
Commen1:	RES	0,(IY+#08)
	LD	A,C
	OR	A
	JR	Z,Comm01
	LD	(IY+#09),C
	SET	0,(IY+#08)
Comm01:	LD	A,(TmpColC)
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-3
	RET 

Commen2:	LD	A,C
	OR	A
	JR	Z,Comm01
	LD	(IY+#0A),C
	CALL	SetComm

Commen3:
 IF NEW_VERSION
	in a,(SLOT3)		
	push af			
	ld a,(AsmTabPg)	
	out (SLOT3),a	
	ld ix,(BegTabl)	
	bit 7,(ix+6)	
	jr nz,Comm3	
	ld a,(ix+8)		
 ELSE
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(AsmTabPg)
	OUT	(SLOT2),A
	LD	IX,(BegTabl)
	LD	C,(IX+#06)
	LD	B,(IX+#08)
	POP	AF
	OUT	(SLOT2),A
	BIT	7,C
	JR	NZ,Comm3
	LD	A,B
 ENDIF
	OR	A
	JR	NZ,Comm3.skip
Comm3:	BIT	4,(IY+#08)
.skip:	CALL	NZ,NotComm
	LD	A,(TmpColC)
.loop:	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	.loop

 IF NEW_VERSION
  	pop af			
  	out (SLOT3),a	
 ENDIF
	RET 

Commen4:	LD	A,C
	OR	A
	JR	Z,Comm01
	LD	(IY+#0B),C
	CALL	SetArgm
Commen5:	BIT	4,(IY+#08)
	CALL	NZ,NotComm
	LD	A,(TmpColC)
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-3
	RET 
 _mCollectInfo_addEnd