 _mCollectInfo_addStart
;
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(AsmTabPg)
	OUT	(SLOT0),A
	IN	A,(SLOT2)
	PUSH	AF
	LD	(TxtPg1+1),A
	LD	(TxtPg3+1),A
	IN	A,(SLOT3)
	PUSH	AF
	LD	(TxtPg2+1),A
	LD	(TxtPg4+1),A
	LD	HL,#FDFE		; !hardcode
	LD	(FreeSymbol),HL
	CALL	SetSymbPg
	INC	HL
	LD	(HL),A
	INC	HL
	LD	DE,#FE01		; !hardcode
	LD	BC,#01FF		; !hardcode
	LD	(HL),L
	LDIR 
	LD	L,C
	LD	H,B
	LD	(CurString),HL
	LD	(MemoryAdr),HL
	LD	(CurrentORG),HL
	LD	HL,StrNumber
	LD	B,#05
	LD	A,"0"
	LD	(HL),A
	INC	HL
	DJNZ	$-2
	POP	AF
	OUT	(SLOT3),A
	POP	AF
	OUT	(SLOT2),A
	LD	HL,#8040		; !hardcode
	LD	(AdrCurString),HL
CompileLp1
	CALL	TestEscape
	CALL	PASS1
	CALL	NextString
TxtPg1	LD	A,#00
	OUT	(SLOT2),A
TxtPg2	LD	A,#00
	OUT	(SLOT3),A
	LD	HL,(AdrCurString)
	LD	E,(HL)
	LD	D,#00
	ADD	HL,DE
	LD	(AdrCurString),HL
	LD	A,(HL)
	OR	A
	JR	NZ,CompileLp1
	LD	L,A
	LD	H,A
	LD	(CurString),HL
	LD	(MemoryAdr),HL
	LD	(CurrentORG),HL
	LD	HL,StrNumber
	LD	B,#05
	LD	A,"0"
	LD	(HL),A
	INC	HL
	DJNZ	$-2
	LD	HL,#8040		; !hardcode
	LD	(AdrCurString),HL
CompileLp2
	CALL	TestEscape
	CALL	PASS2
	CALL	NextString
TxtPg3	LD	A,#00
	OUT	(SLOT2),A
TxtPg4	LD	A,#00
	OUT	(SLOT3),A
	LD	HL,(AdrCurString)
	LD	E,(HL)
	LD	D,#00
	ADD	HL,DE
	LD	(AdrCurString),HL
	LD	A,(HL)
	OR	A
	JR	NZ,CompileLp2
CompileExt
	POP	AF
	OUT	(SLOT0),A
	RET 
TestEscape
	IN	A,(Z84.SIO.Ch_A.Ctrl)
	CPL 
	BIT	0,A
	RET	NZ
	IN	A,(Z84.SIO.Ch_A.Data)
	CP	76
	RET 
NextString
	LD	HL,(CurString)
	INC	HL
	LD	(CurString),HL
	LD	HL,StrNumber+4
	LD	B,#05
NxtStrL	INC	(HL)
	LD	A,(HL)
	CP	#3A		; !hardcode
	RET	C
	LD	(HL),"0"
	DEC	HL
	DJNZ	NxtStrL
	RET 
;[]==========================================================[]
AdrCurString:	DEFW #0000
CurString:	DEFW #0000
CurrentORG:	DEFW #0000
MemoryAdr:	DEFW #0000
BegAdrStrng:	DEFW #0000
FreeSymbol:	DEFW #0000
StackSave:	DEFW #0000
StrNumber:	DEFS 5," "
;[]==========================================================[]
; Procedure search labels in table labels
; On: DE - label in line
; On exit: C - label not (DE-start labels)
; NC - label (reg.and=7- not )
; (DE- labels)
FindLabel
	LD	(LabelAd+1),DE
	LD	BC,#0400		; !hardcode
LabelLp	INC	B
	LD	A,(DE)
	CP	#30		; Check labels; !HARDCODE
	JR	C,EndLabel	; Less #30 ( labels)
	CP	#3A		; !hardcode
	JR	C,ChrOkey
	CP	#3F		; !hardcode
	JP	C,EndLabel
	CP	#80		; !hardcode
	JP	NC,EndLabel
ChrOkey	RLCA 
	XOR	C
	LD	C,A	; Internal operation
	INC	DE
	JR	LabelLp
; Reg.C= labels,reg.B= labels
EndLabel:	BIT	7,B		; Labels 127
	JP	NZ,LongSymbol
	LD	A,B
	LD	HX,A	; With labels
	SUB	#05
	LD	LX,A	; Labels without data
	LD	B,#00
	SLA	C	; CRC for HASH table
	LD	L,C
	LD	A,#FE	; #FE00 - A start HASH table
	ADC	A,B
	LD	H,A
	CALL	SetSymbPg
	LD	E,L
	LD	D,H
NxLabLp	LD	(PrLabel+1),HL
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	OR	H
	JR	Z,FndLabOk
	LD	E,L
	LD	D,H
	CALL	SetSymbPg
	LD	A,(HL)
	OR	A
	JR	Z,FndLabOk
	CP	HX
	JR	Z,CmpLabel
	LD	L,E
	LD	H,D
FndNxtL	INC	HL
	INC	HL
	INC	HL
	JR	NxLabLp
FndLabOk
	SCF 
	EX	DE,HL
	LD	DE,(LabelAd+1)
	RET 
CmpLabel
	PUSH	DE
	LD	C,HX
	ADD	HL,BC
	LD	C,LX
LabelAd	LD	DE,#0000
CmpLab1	DEC	HL
	LD	A,(DE)
	CP	(HL)
	JR	NZ,CmpNot
	INC	DE
	DEC	C
	JR	NZ,CmpLab1
CmpNot	POP	HL
	JR	NZ,FndNxtL
	INC	HL
	INC	HL
	RET 
;[]==========================================================[]
; Procedure write labels in table labels
; On:DE - labels in line
; HX - labels with
; LX - without data
PutLabel:	LD	HL,(FreeSymbol)	 ; Place in e
	LD	C,HX
	LD	B,#00
	PUSH	HL
	OR	A
	SBC	HL,BC
	POP	HL
	JP	C,OverSTable
	LD	B,LX
	CALL	SetSymbPg
PutLab1:	LD	A,(DE)
	LD	(HL),A
	DEC	HL
	INC	DE
	DJNZ	PutLab1
	PUSH	DE
	SUB	A
	LD	(HL),A		; For HASH
	DEC	HL
	LD	(HL),A
	DEC	HL
	LD	DE,(CurrentORG)
	LD	(HL),D		; Current ORG
	DEC	HL
	LD	(HL),E
	DEC	HL
	LD	(HL),C		; Labels
	LD	A,H
SubSymb:	SUB	#00
	LD	H,A
	LD	(AdrLabA+1),HL
PrLabel:	LD	(#0000),HL
	DEC	HL
	LD	(FreeSymbol),HL
	POP	DE
	RET 
;[]==========================================================[]
; Procedure getting values argument
; On: DE- start argument
; On exit:HL-value argument
;[]==========================================================[]
GetArgument:
	LD	HL,#0000	; Value argument
	LD	(Argument),HL
	LD	B,L	; Flag
			; 0
			; 1
			; 2
			; 3
			; 4-selection byte
			; 5-selection byte
			; 7=1 okey
	DEC	DE
GetArgLoop
	INC	DE
GtALoop	LD	A,(DE)
	OR	A
	JR	NZ,ExArgum
ArgumEx	LD	A,B
	SUB	#80
	JP	C,NeedExpress
Argument+1: LD	HL,#0000		; Take value and exit
	RET 
ExArgum
	CP	#20
	JR	C,ArgumEx		; Argument
	CP	","
	JR	Z,ArgumEx		; Argument
	CP	"A"
	JP	NC,GetLabel	; Get value labels
	CP	"0"
	JP	NC,GtDecNum 	; Get value DEC numbers
	INC	DE
	CP	"#"
	JP	Z,GetHexNum	; Get value HEX numbers
	CP	#22		;"
	JP	Z,GetChar
	CP	"$"
	JP	Z,GetShift
	CP	"%"		; Get value BIN numbers
	JP	Z,GetBinNum
	CP	"'"
	JR	Z,HghByte		; Byte numbers
	CP	"."
	JR	Z,LowByte		; Byte numbers
	CP	"*"
	JR	Z,Multipl
	CP	"+"
	JR	Z,Addit
	CP	"-"
	JR	Z,Subst
	CP	"/"
	JR	Z,Div
	JP	UnknownChar
; Selection.byte
HghByte	BIT	5,B
	JP	NZ,NeedExpress
	BIT	7,B
	JR	Z,$+7
	BIT	6,B
	JP	Z,NeedExpress
	SET	4,B
	SET	5,B
	JR	GtALoop
; Selection.byte
LowByte	BIT	5,B
	JP	NZ,NeedExpress
	BIT	7,B
	JR	Z,$+7
	BIT	6,B
	JP	Z,NeedExpress
	SET	5,B
	JR	GtALoop
; Internal operation
Addit	LD	A,B
	AND	#64
	JP	NZ,NeedExpress
	SET	6,B
	JP	GtALoop
; Internal operation
Subst	SET	0,B
	LD	A,B
	AND	#64
	JP	NZ,NeedExpress
	SET	6,B
	JP	GtALoop
; Internal operation
Multipl	SET	1,B
	BIT	3,B
	JP	NZ,NeedExpress
	BIT	7,B
	JP	Z,NeedExpress
	LD	A,B
	AND	#64
	JP	NZ,NeedExpress
	SET	6,B
	JP	GtALoop
; Internal operation
Div	SET	0,B
	SET	1,B
	BIT	3,B
	JP	NZ,NeedExpress
	BIT	7,B
	JP	Z,NeedExpress
	LD	A,B
	AND	#64
	JP	NZ,NeedExpress
	SET	6,B
	JP	GtALoop
; Get values labels
GetLabel
	CP	#80
	JP	NC,UnknownChar
	LD	(IY+#01),B
	IN	A,(SLOT2)
	PUSH	AF
	IN	A,(SLOT3)
	PUSH	AF
	CALL	FindLabel
	JR	NC,GetLab2
	BIT	7,(IY+#00)
	JP	NZ,IllegForwrd
	JP	NotDefined
GetLab2
	LD	A,(HL)
	DEC	HL
	LD	L,(HL)
	LD	H,A
	POP	AF
	OUT	(SLOT3),A
	POP	AF
	OUT	(SLOT2),A
ArgumAct
	LD	A,(IY+#01)
	BIT	5,A
	JR	Z,ArgumA0
	BIT	4,A
	JR	Z,$+3
	LD	L,H
	LD	H,#00
ArgumA0	BIT	7,A
	JR	Z,ArgumA1
	BIT	6,A
	JP	Z,NeedExpress
ArgumA1	AND	#03
	JR	Z,Plus
	DEC	A
	JR	Z,Minus
	DEC	A
	JR	Z,Mult
Divis
	LD	A,H
	OR	L
	JP	Z,DivByZero
	PUSH	DE
	LD	BC,(Argument)
	EX	DE,HL
	LD	HL,#0000
	LD	A,#10
Div1616	RL	E
	RL	D
	ADC	HL,HL
	SBC	HL,BC
	JR	NC,NoAdd16
	ADD	HL,BC
NoAdd16	CCF 
	DEC	A
	JR	NZ,Div1616
	EX	DE,HL
	ADD	HL,HL
	POP	DE
	LD	(Argument),HL
	LD	A,(IY+#01)
	AND	#0C
	OR	#80
	LD	B,A
	JP	GtALoop
Plus
	LD	BC,(Argument)
	ADD	HL,BC
	LD	(Argument),HL
	LD	A,(IY+#01)
	AND	#0C
	OR	#80
	LD	B,A
	JP	GtALoop
Minus
	LD	C,L
	LD	B,H
	LD	HL,(Argument)
	SBC	HL,BC
	LD	(Argument),HL
	LD	A,(IY+#01)
	AND	#0C
	OR	#80
	LD	B,A
	JP	GtALoop
Mult
	PUSH	DE
	EX	DE,HL
	LD	BC,(Argument)
	LD	HL,#0000
	LD	A,#10
MultLp	RR	B
	RR	C
	JR	NC,$+3
	ADD	HL,DE
	SLA	E
	RL	D
	DEC	A
	JR	NZ,MultLp
	POP	DE
	LD	(Argument),HL
	LD	A,(IY+#01)
	AND	#0C
	OR	#80
	LD	B,A
	JP	GtALoop
GtDecNum
	LD	L,E
	LD	H,D
FindDec	INC	HL
	LD	A,(HL)
	CP	#20
	JR	C,GetDecN
	CP	","
	JR	Z,GetDecN
	CP	";"
	JR	Z,GetDecN
	RES	5,A
	CP	"H"
	JR	Z,GetHexNum
	CP	"B"
	JP	Z,GetBinNum
	CP	"D"
	JR	NZ,FindDec
GetDecN	LD	(IY+#01),B
	CALL	ConvDec
	JP	C,ArOverflow
	CP	#20
	JP	C,ArgumAct
	CP	","
	JP	Z,ArgumAct
	CP	";"
	JP	Z,ArgumAct
	INC	DE
	RES	5,A
	CP	"D"
	JP	Z,ArgumAct
	JP	IllegNumber
; Get numbers
; On: DE-A numbers
; On exit:HL
ConvDec
	LD	HL,#0000
ConvDlp	LD	A,(DE)
	CP	#30
	CCF 
	RET	NC
	CP	#3A
	RET	NC
	LD	C,L
	LD	B,H
	ADD	HL,HL
	RET	C
	ADD	HL,HL
	RET	C
	ADD	HL,BC
	RET	C
	ADD	HL,HL
	RET	C
	LD	B,#00
	SUB	#30
	LD	C,A
	ADD	HL,BC
	RET	C
	INC	DE
	JR	ConvDlp
GetHexNum
	LD	(IY+#01),B
	CALL	ConvHex
	JP	C,ArOverflow
	LD	A,(DE)
	CP	#20
	JP	C,ArgumAct
	CP	","
	JP	Z,ArgumAct
	CP	";"
	JP	Z,ArgumAct
	INC	DE
	RES	5,A
	CP	"H"
	JP	Z,ArgumAct
	JP	IllegNumber
; Get HEX numbers
; On: DE-A numbers
; On exit:HL
ConvHex
	LD	HL,#0000
GetHlp	LD	A,(DE)
	CP	#20
	CCF 
	RET	NC
	CP	#61
	JR	C,$+4
	SUB	#20
	CP	#30
	CCF 
	RET	NC
	CP	#47
	RET	NC
	SUB	#30
	CP	#0A
	JR	C,GetHnxt
	SUB	#07
	CP	#0A
	CCF 
	RET	NC
GetHnxt	ADD	HL,HL
	RET	C
	ADD	HL,HL
	RET	C
	ADD	HL,HL
	RET	C
	ADD	HL,HL
	RET	C
	OR	L
	LD	L,A
	INC	DE
	JR	GetHlp
; Get values BIN numbers
GetBinNum
	LD	(IY+#01),B
	CALL	ConvBin
	LD	A,(DE)
	CP	#20
	JP	C,ArgumAct
	CP	","
	JP	Z,ArgumAct
	CP	";"
	JP	Z,ArgumAct
	INC	DE
	RES	5,A
	CP	"B"
	JP	Z,ArgumAct
	JP	ArgumAct
ConvBin
	LD	HL,#0000
	LD	B,#10
GetBin1	LD	A,(DE)
	SUB	#30
	SRL	A
	RET	NZ
	RL	L
	RL	H
	INC	DE
	DJNZ	GetBin1
	RET 
; Get values from " "
GetChar	LD	(IY+#01),B
	INC	DE
	LD	H,#00
GetCh1	LD	A,(DE)
	INC	DE
	LD	L,A
	LD	A,(DE)
	INC	DE
	CP	#20
	JP	C,MissGuote
	CP	#22
	JP	Z,ArgumAct
	LD	H,L
	LD	L,A
	LD	A,(DE)
	CP	#22
	JP	Z,ArgumAct
	JR	GetCh1
; Get values $
GetShift
	LD	(IY+#01),B
	LD	HL,(BegAdrStrng)
	JP	ArgumAct
;[]==========================================================[]
SetMemPg
	LD	A,H
	INC	A
	JR	NZ,SetMem1
	LD	A,(MemPage2)
	OUT	(SLOT2),A
	LD	A,(MemPage3)
	OUT	(SLOT3),A
	RET 
SetMem1	LD	A,H
	CP	#BF
	JR	C,SetMem2
	LD	A,(MemPage2)
	OUT	(SLOT2),A
	LD	A,(MemPage3)
	OUT	(SLOT3),A
	RET 
SetMem2	ADD	A,#40
	LD	H,A
	LD	A,(MemPage1)
	OUT	(SLOT2),A
	LD	A,(MemPage2)
	OUT	(SLOT3),A
	RET 
;[]==========================================================[]
SetSymbPg
	LD	A,H
	CP	#81
	JR	C,EndPage
	LD	A,(SymbPg2)
	OUT	(SLOT2),A
	LD	A,(SymbPg1)
	OUT	(SLOT3),A
	SUB	A
	LD	(SubSymb+1),A
	RET 
EndPage	CP	#41
	JR	C,EndPage1
	ADD	A,#40
	LD	H,A
	LD	A,(SymbPg3)
	OUT	(SLOT2),A
	LD	A,(SymbPg2)
	OUT	(SLOT3),A
	LD	A,#40
	LD	(SubSymb+1),A
	RET 
EndPage1
	SET	7,H
	LD	A,(SymbPg4)
	OUT	(SLOT2),A
	LD	A,(SymbPg3)
	OUT	(SLOT3),A
	LD	A,#80
	LD	(SubSymb+1),A
	RET 

; !fixit
BadMemory:
SyntaxError:
IllegForwrd:
IllegNumber:
IllegINTNum:
IllegRSTNum:
IllegBITNum:
IllegDirect:
NeedExpress:
UnknownChar:
LabelBegNum:
LongSymbol:
SymbolDefin:
NotDefined:
MissGuote:
WrongShort:
ValueOut:
OverSTable:
ArOverflow:
IllegCount:
DivByZero:
	LD	SP,(StackSave)
	POP	HL
	LD	A,(TxtPg1+1)
	OUT	(SLOT2),A
	LD	A,(TxtPg2+1)
	OUT	(SLOT3),A
	LD	A,4
	OUT	(254),A			; !hardcode
	JP	CompileExt
;
 _mCollectInfo_addEnd