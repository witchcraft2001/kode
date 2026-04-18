 _mCollectInfo_addStart
;[]==========================================================[]
AppendLabel
	CALL	FindLabel
	JR	NC,TestLabel
	SUB	A
	CALL	PutLabel
ApLabel	SET	6,(IY+#00)
	LD	A,(DE)
	CP	"="
	JR	Z,NewLabel
	CP	":"
	RET	NZ
	INC	DE
	RET 
TestLabel
	LD	(AdrLabA+1),HL
	BIT	7,A
	JR	Z,TwLabel
	AND	#7F
	EX	AF,AF'
	CALL	SetSymbPg
	LD	BC,(MemoryAdr)
	LD	(HL),B
	DEC	HL
	LD	(HL),C
	DEC	HL
	EX	AF,AF'
	LD	(HL),A
	JR	ApLabel
TwLabel	LD	A,(DE)
	CP	"="
	JP	NZ,SymbolDefin
NewLabel
	INC	DE
	SET	7,(IY+#00)
	CALL	GetArgument
	DEC	DE
NewLab1	INC	DE
	LD	A,(DE)
	OR	A
	JR	Z,NewLab2
	CP	#20
	JR	C,NewLab1
	CP	";"
	JP	NZ,UnknownChar
NewLab2	EX	DE,HL
AdrLabA	LD	HL,#0000
	CALL	SetSymbPg
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	RET 
;[]==========================================================[]
; Procedure search labels in table labels
; On: DE - label in line
; On exit: C - label not (DE-start labels)
; NC - label (reg.and=7- not )
; (DE- labels)
FindLabel
	LD	(LabelAd+1),DE
	LD	BC,#0400
LabelLp	INC	B
	LD	A,(DE)
	CP	#30		; Check labels
	JR	C,EndLabel	; Less #30 ( labels)
	CP	#3A
	JR	C,ChrOkey
	CP	#3F
	JP	C,EndLabel
	CP	#80
	JP	NC,EndLabel
ChrOkey	RLCA 
	XOR	C
	LD	C,A	; Internal operation
	INC	DE
	JR	LabelLp
; Reg.C= labels,reg.B= labels
EndLabel
	BIT	7,B		; Labels 127
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
NxLabLp	LD	(PrLabel+1),HL
	LD	E,L
	LD	D,H
	CALL	SetSymbPg
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	OR	H
	JR	Z,FndLabOk
	LD	A,(HL)
	OR	A
	JR	Z,FndLabOk
	AND	#7F
	CP	HX
	JR	Z,CmpLabel
	EX	DE,HL
FndNxtL	INC	HL
	INC	HL
	INC	HL
	JR	NxLabLp
FndLabOk
	SCF 
	LD	DE,(LabelAd+1)
	RET 
CmpLabel
	PUSH	DE
	PUSH	HL
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
	LD	A,(HL)
	POP	HL
	JR	NZ,FndNxtL
	INC	HL
	INC	HL
	RET 
;[]==========================================================[]
; Procedure write labels in table labels
; On:DE - labels in line
; And - 00h label
; 80h label
; HX - labels with
; LX - without data
PutLabel
	LD	HL,(FreeSymbol)	 ; Place in e
	OR	HX
	LD	C,A
	LD	B,LX
	CALL	SetSymbPg
PutLab1	LD	A,(DE)
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
	LD	DE,(MemoryAdr)
	LD	(AdrLabA+1),HL
	LD	(HL),D		; Current ORG
	DEC	HL
	LD	(HL),E
	DEC	HL
	LD	(HL),C		; Labels
	LD	A,H
SubSymb	SUB	#00
	LD	H,A
PrLabel	LD	(#0000),HL
	DEC	HL
	LD	(FreeSymbol),HL
	POP	DE
	RET 
;[]==========================================================[]
; Procedure getting values argument
; On: DE- start argument
; On exit:HL-value argument
;[]==========================================================[]
GetArgument
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
ArgLoop	LD	A,(DE)
	OR	A
	JR	NZ,ExArgum
ArgumEx	LD	A,B
	SUB	#80
	JP	C,NeedExpress
	LD	HL,(Argument)	; Take value and exit
	RET 
Argument
	DEFW	#0000
ExArgum
	CP	#20
	JR	C,ArgumEx	; Argument
	CP	","
	JR	Z,ArgumEx	; Argument
	CP	"A"
	JP	NC,GetLabel	; Get value labels
	CP	"0"
	JP	NC,GetDecNum	; Get value DEC numbers
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
	JR	Z,HghByte	; Byte numbers
	CP	"."
	JR	Z,LowByte	; Byte numbers
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
	JR	ArgLoop
; Selection.byte
LowByte	BIT	5,B
	JP	NZ,NeedExpress
	BIT	7,B
	JR	Z,$+7
	BIT	6,B
	JP	Z,NeedExpress
	SET	5,B
	JR	ArgLoop
; Internal operation
Addit	LD	A,B
	AND	#64
	JP	NZ,NeedExpress
	SET	6,B
	JP	ArgLoop
; Internal operation
Subst	SET	0,B
	LD	A,B
	AND	#64
	JP	NZ,NeedExpress
	SET	6,B
	JP	ArgLoop
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
	JP	ArgLoop
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
	JP	ArgLoop
; Get values labels
GetLabel
	CP	#80
	JP	NC,UnknownChar
	LD	(IY+#01),B
	IN	A,(#C2)
	PUSH	AF
	IN	A,(#E2)
	PUSH	AF
	CALL	FindLabel
	JR	NC,GetLab2
	BIT	7,(IY+#00)
	JP	NZ,IllegForwrd
	LD	A,#80
	CALL	PutLabel
	LD	HL,(AdrLabA+1)
GetLab1	DEC	HL
	DEC	HL
	LD	C,L
	LD	B,H
	LD	HL,(FreePost)
	CALL	SetPostPg
	LD	A,(HighPost)
	CP	B
	JR	Z,PostS1
	LD	(HL),#48
	INC	HL
	LD	(HL),B
	INC	HL
	LD	A,B
	LD	(HighPost),A
PostS1	LD	A,(HighAdr)
	LD	B,A
	LD	A,(MemoryAdr+1)
	CP	B
	JR	Z,PostS2
	LD	(HL),#44
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HighAdr),A
PostS2	LD	A,(IY+#01)
	AND	#13
	ADD	A,#70
	AND	#83
	OR	(IY+#00)
	AND	#BF
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(MemoryAdr)
	LD	(HL),A
	INC	HL
	CALL	ResPostPg
	LD	(FreePost),HL
	LD	HL,#0000
	BIT	1,(IY+#01)
	JR	Z,PostS3
	SET	2,(IY+#01)
	INC	HL
PostS3	LD	A,(IY+#00)
	AND	#30
	CP	#10
	JR	NZ,ArgAct
	LD	HL,(MemoryAdr)
	INC	HL
	JR	ArgAct

GetLab2	BIT	7,A
	JR	Z,GetLab3
	BIT	7,(IY+#00)
	JR	Z,GetLab1
	JP	IllegForwrd

GetLab3	LD	A,(HL)
	DEC	HL
	LD	L,(HL)
	LD	H,A
ArgAct	POP	AF
	OUT	(#E2),A
	POP	AF
	OUT	(#C2),A
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
	JP	ArgLoop
Plus
	LD	BC,(Argument)
	ADD	HL,BC
	LD	(Argument),HL
	LD	A,(IY+#01)
	AND	#0C
	OR	#80
	LD	B,A
	JP	ArgLoop
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
	JP	ArgLoop
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
	JP	ArgLoop
GetDecNum
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
PostMain
CurPost	LD	HL,#0000
PostLoop
	CALL	TestEscape
	JP	Z,ResPostPg
	EX	DE,HL
	LD	HL,(FreePost)	; POST SYMBOLS
	OR	A
	SBC	HL,DE
	JP	Z,ResPostPg
	EX	DE,HL
	LD	E,L
	LD	D,H
	CALL	SetPostPg
	LD	B,(HL)
	INC	HL
	BIT	6,B
	JR	Z,PostNext
	RRC	B
	JR	NC,NoPostP
	LD	A,(HL)
	INC	HL
	LD	(NewPage),A	; Page program
NoPostP	RRC	B
	JR	NC,NoPostD
	PUSH	DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(NewDisp),DE	; New DISP
	POP	DE
NoPostD	RRC	B
	JR	NC,NoPostM
	LD	A,(HL)
	INC	HL
	LD	(HighMem),A
NoPostM	RRC	B
	JR	NC,PostNx1
	LD	A,(HL)
	INC	HL
	LD	(HghSymb),A
PostNx1	CALL	ResPostPg1
	JR	PostLoop
PostNext
	LD	A,(HL)
	INC	HL
	LD	(LowSymb),A
	LD	A,(HL)
	INC	HL
	LD	(LowMem),A
	CALL	ResPostPg1
	LD	(CurPost+1),HL
NewPage+3: LD	(IY+#03),#00

	PUSH	BC

LowSymb		EQU	$+1
	LD	HL,#0000		; Values labels
HghSymb		EQU	$-1

	PUSH	HL
	CALL	SetSymbPg
	LD	A,(HL)		; Internal operation
	INC	HL
	LD	E,(HL)		; Value
	INC	HL
	LD	D,(HL)
	POP	HL
	LD	(SaveLabel),HL
	AND	#80
	CALL	M,NotDefinedP
	LD	HL,(LowMem)
	CALL	SetMemPg
	POP	BC
	BIT	3,B
	JR	Z,NoPostI
	LD	A,(HL)
	CP	#DD
	JR	Z,PostIn2
	CP	#ED
	JR	Z,PostIn2
	CP	#FD
	JR	NZ,PostIn1
PostIn2	INC	HL
PostIn1	INC	HL
NoPostI	LD	A,B
	BIT	1,A
	CALL	NZ,CantCountP
	BIT	7,A
	JR	Z,NoPostH
	LD	E,D
	LD	D,#00
NoPostH	BIT	0,A
	JR	Z,NoPostN
	PUSH	HL
	AND	A
	LD	HL,#0000
	SBC	HL,DE
	EX	DE,HL
	POP	HL
NoPostN	BIT	5,A
	JR	Z,OneByte
	BIT	4,A
	JR	NZ,TwoByte
OneByte:	LD	C,(HL)
	LD	B,#00
	BIT	7,C
	JR	Z,$+3
	DEC	B
	PUSH	HL
	LD	HL,#0000
	BIT	4,A
	JR	Z,LLB317
	PUSH	BC
NewDisp+1: LD	BC,#0000
	ADD	HL,BC

LowMem		EQU	$+1
	LD	BC,#0000
HighMem		EQU	$-1

	INC	BC
	AND	A
	SBC	HL,BC
	BIT	0,A
	JR	Z,$+4
	LD	L,C
	LD	H,B
	POP	BC
LLB317	ADD	HL,DE
	ADD	HL,BC
	BIT	5,A
	SCF 
	CALL	Z,TestShort
	POP	HL
	JR	C,ShortOk
	CALL	NZ,WrongShortP
ShortOk	LD	(HL),A
	JP	PostMain

TwoByte	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	PUSH	HL
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
	POP	HL
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	JP	PostMain
;
 _mCollectInfo_addEnd