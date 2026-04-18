 _mCollectInfo_addStart

IYpoint         EQU     #8010
CurLine         EQU     IYpoint+#0C
AdrPage         EQU     IYpoint+#0E
EndText         EQU     IYpoint+#12
BegString       EQU     IYpoint+#14
ReadyStr        EQU     IYpoint+#16
ReadyFile       EQU     IYpoint+#17
EquipLn         EQU     IYpoint+#18
TmpVBarA        EQU     IYpoint+#1A
TmpVBarP        EQU     IYpoint+#1C
TmpHBarA        EQU     IYpoint+#1E
TmpHBarP        EQU     IYpoint+#20
UpLinePg        EQU     IYpoint+#22
ProecFlg        EQU     IYpoint+#24
Tadrpg          EQU     IYpoint+#25
Tupline         EQU     IYpoint+#27
Typos           EQU     IYpoint+#29
Txpos           EQU     IYpoint+#2A
Taddx           EQU     IYpoint+#2B
EquipMr         EQU     IYpoint+#2C
MarkCeil        EQU     IYpoint-#06

Step            EQU     #08


EditorT	LD	A,(InsertMode)
	LD	(IY-#03),A
	LD	A,(HL)	;Keys
	CP	#09
	JP	Z,Tabulat
	CP	#08
	JP	Z,Delete
	CP	#0D
	JP	Z,Enter
	CP	#20
	RET	C
	EX	AF,AF'
	CALL	exProec
	LD	A,(IY+#02)
	CP	240
	JR	NZ,EditN	; Already 240
	BIT	0,(IY-#03)
	RET	NZ
EditN	LD	A,(IY+#02)
	SUB	(IY+#07)
	SUB	(IY+#00)
	JR	Z,PutChar
	DEC	(IY+#02)
	BIT	0,(IY-#03)
	JR	Z,PutChar
	INC	(IY+#02)
; In text
	ADD	A,A
	LD	C,A
	LD	A,#00
	ADC	A,A
	LD	B,A
	LD	HL,TextBuff
	LD	E,(IY+#02)
	LD	D,L
	ADD	HL,DE
	ADD	HL,DE
	LD	E,L
	LD	D,H
	DEC	HL
	INC	DE
	PUSH	DE
	LDDR 
	POP	HL
	INC	HL
	LD	(HL),C
PutChar	LD	H, high TextBuff
	LD	A,(IY+#00)
	ADD	A,(IY+#07)
	ADD	A,A
	LD	L,A
	JR	NC,$+3
	INC	H
	EX	AF,AF'
	LD	(HL),A
	INC	(IY+#02)
	INC	(IY+#00)
	LD	A,(IY+#00)
	LD	(IY-#01),A
	LD	A,(IY+#00)
	CP	(IY+#05)
	JR	Z,$+4
	CP	#4E
	CALL	Z,OutScrn
	CALL	Syntax
	SUB	A
	LD	(ReadyStr),A
	LD	(ReadyFile),A
	LD	A,(IY+#07)
	LD	(IY-#02),A
	CALL	PrintInfo
	RET 
SysComb	LD	A,(InsertMode)
	LD	(IY-#03),A
	INC	HL
	LD	E,(HL)		;Key combination
	LD	HL,CombinE-3
SysLoop	INC	HL
	INC	HL
	INC	HL
	LD	A,(HL)
	OR	A
	JP	Z,DskTopE
	CP	E
	JR	NZ,SysLoop
	INC	HL
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	CALL	exProec
	JP	(HL)

CombinE	DEFB	75
	DEFW	CurLeft
	DEFB	77
	DEFW	CurRght
	DEFB	72
	DEFW	CursUp
	DEFB	80
	DEFW	CurDown
	DEFB	71
	DEFW	HomeStr
	DEFB	79
	DEFW	EndStr
	DEFB	115
	DEFW	WordRgt
	DEFB	116
	DEFW	WordLft
	DEFB	141
	DEFW	DelWord
	DEFB	146
	DEFW	BackTab
	DEFB	81
	DEFW	NextPage
	DEFB	73
	DEFW	PreviosPage
	DEFB	132
	DEFW	PageLeft
	DEFB	118
	DEFW	PageRight
	DEFB	83
	DEFW	_Del_
	DEFB	#04
	DEFW	DelLine
	DEFB	155
	DEFW	ScrLnUp
	DEFB	156
	DEFW	ScrLnDn
	DEFB	119
	DEFW	BegTEXT
	DEFB	117
	DEFW	EndTEXT
	DEFB	144
	DEFW	MrkStrD
	DEFB	142
	DEFW	MrkStrU
	DEFB	147
	DEFW	BegMark
	DEFB	148
	DEFW	EndMark
	DEFB	149
	DEFW	ExmMark
	DEFB	0
;[]===========================================================[]
; Cursor for screen
OutScrn	LD	A,(IY+#07)
	ADD	A,Step
	LD	(IY+#07),A
	LD	(IY-#02),A
	LD	A,(IY+#00)
	SUB	Step
	LD	(IY+#00),A
	LD	(IY-#01),A
	SUB	(IY+#07)
	JP	C,RefreshPage
	CP	(IY+#05)
	JR	NC,OutScrn
	JP	RefreshPage
;[]===========================================================[]
; Cursor on single place
CurLeft	LD	A,(IY+#00)
	DEC	A
	JP	P,CurLnxt
	LD	A,(IY+#07)
	OR	A
	JR	Z,CursUp1
	SUB	Step
	JR	NC,$+3
	SUB	A
	LD	(IY+#07),A
	CALL	RefreshPage
	LD	A,(IY+#00)
	ADD	A,Step
CurLnxt	LD	(IY+#00),A
	LD	(IY-#01),A
	LD	A,(IY+#07)
	LD	(IY-#02),A
	CALL	PrintS
	CALL	PrintInfo
TestEnd	LD	A,(EditMode)
	OR	A
	RET	Z
	LD	A,(IY+#02)
	SUB	(IY+#07)
	SUB	(IY+#00)
	RET	Z
	LD	HL,TextBuff
	LD	E,(IY+#02)
	LD	D,L
	ADD	HL,DE
	ADD	HL,DE
	LD	B,A
	LD	C,#20
Cleft1	DEC	HL
	DEC	HL
	LD	A,(HL)
	CP	C
	RET	NZ
	LD	(HL),D
	DEC	(IY+#02)
	DJNZ	Cleft1
	RET 
CursUp1	LD	HL,(BegString)
	DEC	HL
	LD	A,(HL)
	OR	A
	RET	Z	; Begin text
	LD	A,(ReadyStr)	; Was not touched
	OR	A
	JR	NZ,CurUp1
	INC	A
	LD	(ReadyStr),A
	PUSH	HL
	CALL	PutString
	POP	HL
CurUp1	LD	C,(HL)
	DEC	C
	LD	B,#00
	OR	A
	SBC	HL,BC
	LD	(BegString),HL
	BIT	4,(IY+#08)
	JR	Z,$+8
	CALL	NotComm
	CALL	PrintS
	CALL	ReCompileStr
	LD	B,(IY+#07)
	LD	A,(IY+#02)
	SUB	(IY+#05)
	JR	C,CUn
	LD	(IY+#07),#00
Cun1	LD	C,A
	LD	A,(IY+#07)
	ADD	A,Step
	LD	(IY+#07),A
	LD	(IY-#02),A
	LD	A,C
	SUB	Step
	JR	NC,Cun1
CUn	LD	A,(IY+#02)
	SUB	(IY+#07)
	LD	(IY+#00),A
	LD	(IY-#01),A
	LD	A,(IY+#01)
	DEC	A
	CALL	M,ScrollDown
	LD	(IY+#01),A
	LD	A,B
	CP	(IY+#07)
	CALL	NZ,RefreshPage
	LD	HL,(CurLine)
	DEC	HL
	LD	(CurLine),HL
	CALL	Syntax
	CALL	PrintInfo
	RET 
;[]===========================================================[]
; Cursor on single place
CurRght	LD	A,(EditMode)
	OR	A
	JP	NZ,Cright
	LD	A,(IY+#00)
	ADD	A,(IY+#07)
	CP	(IY+#02)
	JR	Z,CurDwn1
	SUB	(IY+#07)
	INC	A
	CP	(IY+#05)
	JR	NZ,CurRnxt
	LD	A,(IY+#07)
	ADD	A,Step
	LD	(IY+#07),A
	CALL	RefreshPage
	LD	A,(IY+#00)
	SUB	Step
CurRnxt	LD	(IY+#00),A
	LD	(IY-#01),A
	LD	A,(IY+#07)
	LD	(IY-#02),A
	CALL	PrintS
	CALL	PrintInfo
	RET 
CurDwn1	LD	HL,(BegString)
	LD	C,(HL)
	LD	B,#00
	ADD	HL,BC
	LD	A,(HL)
	OR	A
	RET	Z	; End text
	LD	A,(ReadyStr)	; Was not touched
	OR	A
	JR	NZ,CurDn1
	INC	A
	LD	(ReadyStr),A
	CALL	PutString
CurDn1	LD	(BegString),HL
	BIT	4,(IY+#08)
	JR	Z,$+8
	CALL	NotComm
	CALL	PrintS
	CALL	ReCompileStr
	SUB	A
	LD	(IY+#00),A
	LD	(IY-#01),A
	LD	B,(IY+#07)
	LD	(IY+#07),A
	LD	(IY-#02),A
	LD	A,(IY+#01)
	INC	A
	CP	(IY+#06)
	JR	Z,$+4
	CP	#1C
	CALL	Z,ScrollUp
	LD	(IY+#01),A
	LD	A,B
	CP	(IY+#07)
	CALL	NZ,RefreshPage
	LD	HL,(CurLine)
	INC	HL
	LD	(CurLine),HL
	CALL	Syntax
	CALL	PrintInfo
	RET 
; Cursor on single place ( table)
Cright	LD	A,(IY+#02)
	CP	240
	RET	Z
	LD	A,(IY+#00)
	INC	A
	CP	(IY+#05)
	JR	NZ,CRnxt
	LD	A,(IY+#07)
	ADD	A,Step
	LD	(IY+#07),A
	CALL	RefreshPage
	LD	A,(IY+#00)
	SUB	Step
CRnxt	LD	(IY+#00),A
	LD	(IY-#01),A
	LD	A,(IY+#07)
	LD	(IY-#02),A
	LD	A,(IY+#02)
	SUB	(IY+#07)
	SUB	(IY+#00)
	JR	NC,CRext
	LD	H, high TextBuff
	LD	A,(IY+#02)
	ADD	A,A
	LD	L,A
	JR	NC,$+3
	INC	H
	LD	(HL),#20
	INC	HL
	LD	A,(ColTxtWin)
	LD	(HL),A
	INC	(IY+#02)
CRext	CALL	PrintS
	CALL	PrintInfo
	RET 
;[]===========================================================[]
; Cursor on single place
CursUp	LD	A,(EditMode)
	OR	A
	JP	NZ,Cup
	LD	HL,(BegString)
	DEC	HL
	LD	A,(HL)
	OR	A
	RET	Z	; Begin text
	LD	A,(ReadyStr)	; Was not touched
	OR	A
	JR	NZ,CursUpN
	INC	A
	LD	(ReadyStr),A
	PUSH	HL
	CALL	PutString
	POP	HL
CursUpN	LD	C,(HL)
	DEC	C
	LD	B,#00
	OR	A
	SBC	HL,BC
	LD	(BegString),HL
	BIT	4,(IY+#08)
	JR	Z,$+8
	CALL	NotComm
	CALL	PrintS
	CALL	ReCompileStr
	LD	B,(IY+#07)
	LD	A,(IY-#02)
	LD	(IY+#07),A
	LD	A,(IY-#01)
	ADD	A,(IY-#02)
	CP	(IY+#02)
	JR	C,CUnxt2
	LD	(IY+#07),#00
	LD	A,(IY+#02)
	SUB	(IY+#05)
	JR	C,CUnxt1
CUnxt0	LD	C,A
	LD	A,(IY+#07)
	ADD	A,Step
	LD	(IY+#07),A
	LD	A,C
	SUB	Step
	JR	NC,CUnxt0
CUnxt1	LD	A,(IY+#02)
	ADD	A,(IY-#02)
	SUB	(IY+#07)
CUnxt2	SUB	(IY-#02)
	LD	(IY+#00),A
	LD	A,(IY+#01)
	DEC	A
	CALL	M,ScrollDown
	LD	(IY+#01),A
	LD	A,B
	CP	(IY+#07)
	CALL	NZ,RefreshPage
	LD	HL,(CurLine)
	DEC	HL
	LD	(CurLine),HL
	CALL	Syntax
	CALL	PrintInfo
	RET 
; Cursor on single place ( table)
Cup	LD	HL,(BegString)
	DEC	HL
	LD	A,(HL)
	OR	A
	RET	Z	; Begin text
	LD	A,#01
	LD	(ReadyStr),A
	PUSH	HL
	CALL	PutString
	POP	HL
	LD	B,#00
	LD	C,(HL)
	INC	HL
	OR	A
	SBC	HL,BC
	LD	(BegString),HL
	BIT	4,(IY+#08)
	JR	Z,$+5
	CALL	NotComm
	CALL	PrintS
	LD	A,(IY-#01)
	LD	(IY+#00),A
	CALL	ReCompileStr
	LD	A,(IY+#01)
	DEC	A
	CALL	M,ScrollDown
	LD	(IY+#01),A
	LD	HL,(CurLine)
	DEC	HL
	LD	(CurLine),HL
	CALL	Syntax
	CALL	PrintInfo
	RET 
;[]===========================================================[]
; Cursor down on single place
CurDown	LD	A,(EditMode)
	OR	A
	JP	NZ,Cdown
	LD	HL,(BegString)
	LD	C,(HL)
	LD	B,#00
	ADD	HL,BC
	LD	A,(HL)
	OR	A
	RET	Z	; End text
	LD	A,(ReadyStr)	; Was not touched
	OR	A
	JR	NZ,CursDnN
	INC	A
	LD	(ReadyStr),A
	CALL	PutString
CursDnN	LD	(BegString),HL
	BIT	4,(IY+#08)
	JR	Z,$+8
	CALL	NotComm
	CALL	PrintS
	CALL	ReCompileStr
	LD	B,(IY+#07)
	LD	A,(IY-#02)
	LD	(IY+#07),A
	LD	A,(IY-#01)
	ADD	A,(IY-#02)
	CP	(IY+#02)
	JR	C,CDnxt2
	LD	(IY+#07),#00
	LD	A,(IY+#02)
	SUB	(IY+#05)
	JR	C,CDnxt1
CDnxt0	LD	C,A
	LD	A,(IY+#07)
	ADD	A,Step
	LD	(IY+#07),A
	LD	A,C
	SUB	Step
	JR	NC,CDnxt0
CDnxt1	LD	A,(IY+#02)
	ADD	A,(IY-#02)
	SUB	(IY+#07)
CDnxt2	SUB	(IY-#02)
	LD	(IY+#00),A
	LD	A,(IY+#01)
	INC	A
	CP	(IY+#06)
	JR	Z,$+4
	CP	#1C
	CALL	Z,ScrollUp
	LD	(IY+#01),A
	LD	A,B
	CP	(IY+#07)
	CALL	NZ,RefreshPage
	LD	HL,(CurLine)
	INC	HL
	LD	(CurLine),HL
	CALL	Syntax
	CALL	PrintInfo
	RET 
; Cursor down on single place ( table)
Cdown	LD	HL,(BegString)
	LD	C,(HL)
	LD	B,#00
	ADD	HL,BC
	LD	A,(HL)
	OR	A
	RET	Z	; End text
	LD	A,#01
	LD	(ReadyStr),A
	CALL	PutString
	LD	(BegString),HL
	BIT	4,(IY+#08)
	JR	Z,$+5
	CALL	NotComm
	CALL	PrintS
	LD	A,(IY-#01)
	LD	(IY+#00),A
	CALL	ReCompileStr
	LD	A,(IY+#01)
	INC	A
	CP	(IY+#06)
	JR	Z,$+4
	CP	#1C
	CALL	Z,ScrollUp
	LD	(IY+#01),A
	LD	HL,(CurLine)
	INC	HL
	LD	(CurLine),HL
	CALL	Syntax
	CALL	PrintInfo
	RET 
;[]===========================================================[]
Delete	LD	A,(IY+#00)
	OR	A
	JR	NZ,DelNext
	LD	A,(IY+#07)
	OR	A
	JR	Z,CursUpD
	SUB	Step
	JR	NC,$+3
	SUB	A
	LD	(IY+#07),A
	LD	A,(IY+#00)
	ADD	A,Step
	LD	(IY+#00),A
	CALL	RefreshPage
DelNext	LD	H, high TextBuff
	LD	A,(IY+#00)
	ADD	A,(IY+#07)
	ADD	A,A
	LD	L,A
	JR	NC,$+3
	INC	H
	LD	E,L
	LD	D,H
	DEC	DE
	DEC	DE
	INC	(IY+#02)
	BIT	0,(IY-#03)
	JR	Z,DelN0
	DEC	(IY+#02)
	LD	A,(IY+#02)
	SUB	(IY+#07)
	SUB	(IY+#00)
	JR	Z,DelN1
	ADD	A,A
	LD	C,A
	LD	A,#00
	ADC	A,A
	LD	B,A
	LDIR 
DelN0	LD	A,#20
DelN1	LD	(DE),A
	INC	DE
	LD	A,(ColTxtWin)
	LD	(DE),A
	DEC	(IY+#00)
	DEC	(IY+#02)
	LD	A,(IY+#00)
	LD	(IY-#01),A
	LD	A,(IY+#07)
	LD	(IY-#02),A
	CALL	Syntax
	SUB	A
	LD	(ReadyStr),A
	LD	(ReadyFile),A
	CALL	PrintInfo
	JP	TestEnd
CursUpD	LD	HL,(BegString)
	DEC	HL
	LD	A,(HL)
	OR	A
	RET	Z
	LD	A,(ReadyStr)	; Was not touched
	OR	A
	JR	NZ,CurUpD1
	INC	A
	LD	(ReadyStr),A
	PUSH	HL
	CALL	PutString
	POP	HL
CurUpD1	LD	C,(HL)
	LD	B,#00
	INC	HL
	OR	A
	SBC	HL,BC
	LD	(BegString),HL
	LD	HL,TextBuff
	LD	DE,ReCompBuff
	LD	A,(IY+#02)
	PUSH	AF
	ADD	A,A
	LD	C,A
	LD	A,#00
	ADC	A,A
	LD	B,A
	OR	C
	JR	Z,$+4
	LDIR 
	CALL	ReCompileStr
	POP	AF
	LD	E,A
	LD	B,(IY+#07)
	LD	(IY+#07),#00
	LD	A,(IY+#02)
	SUB	(IY+#05)
	JR	C,CUnDel
Cun1Del	LD	C,A
	LD	A,(IY+#07)
	ADD	A,Step
	LD	(IY+#07),A
	LD	(IY-#02),A
	LD	A,C
	SUB	Step
	JR	NC,Cun1Del
CUnDel	LD	A,(IY+#02)
	SUB	(IY+#07)
	LD	(IY+#00),A
	LD	(IY-#01),A
	BIT	0,(IY-#03)
	SCF 
	JR	Z,CDELNXT
	LD	A,E
	ADD	A,(IY+#02)
	JR	C,CDELNXT
	CP	241
	CCF 
	JR	C,CDELNXT
	LD	A,E
	ADD	A,A
	LD	C,A
	LD	A,#00
	ADC	A,A
	LD	B,A
	OR	C
	JR	Z,CDEL1
	LD	A,E
	ADD	A,(IY+#02)
	EX	AF,AF'
	LD	HL,ReCompBuff
	LD	D, high TextBuff
	LD	A,(IY+#02)
	ADD	A,A
	LD	E,A
	JR	NC,$+3
	INC	D
	LDIR 
	EX	AF,AF'
	LD	(IY+#02),A
CDEL1	LD	HL,(EquipLn)
	DEC	HL
	LD	(EquipLn),HL
CDELNXT	PUSH	AF
	LD	A,(IY+#01)
	DEC	A
	JP	P,CDelNxt
	LD	HL,(AdrPage)
	DEC	HL
	LD	C,(HL)
	INC	HL
	LD	B,#00
	OR	A
	SBC	HL,BC
	LD	(AdrPage),HL
	LD	HL,(UpLinePg)
	DEC	HL
	LD	(UpLinePg),HL
	SUB	A
CDelNxt	LD	(IY+#01),A
	CALL	OnlySyntax
	POP	AF
	JR	C,DELNXT1
	LD	HL,(BegString)
	PUSH	HL
	LD	A,(HL)
	LD	C,A
	LD	B,#00
	ADD	HL,BC
	ADD	A,(HL)
	POP	HL
	LD	(HL),A
	CALL	PutString
DELNXT1	LD	HL,(CurLine)
	DEC	HL
	LD	(CurLine),HL
	CALL	PrintPage
	SUB	A
	LD	(ReadyStr),A
	LD	(ReadyFile),A
	CALL	PrintInfo
	RET 
;[]===========================================================[]
Enter	LD	A,(IY+#02)
	SUB	(IY+#07)
	SUB	(IY+#00)
	JP	Z,EnterEmpty
	BIT	0,(IY-#03)
	JP	Z,EnterEmpty
	ADD	A,A
	LD	C,A
	LD	A,#00
	ADC	A,A
	LD	B,A
	LD	H, high TextBuff
	LD	A,(IY+#00)
	ADD	A,(IY+#07)
	LD	(IY+#02),A
	ADD	A,A
	LD	L,A
	JR	NC,$+3
	INC	H
	LD	DE,ReCompBuff
	PUSH	BC
	PUSH	HL
	LDIR 
	POP	HL
	LD	(HL),C
	CALL	OnlySyntax
	CALL	PutString
	POP	BC
	PUSH	HL
	LD	HL,ReCompBuff
	LD	DE,TextBuff
	PUSH	BC
	LDIR 
	SUB	A
	LD	(DE),A
	POP	BC
	SRL	B
	RR	C
	LD	(IY+#02),C
	CALL	OnlySyntax
	CALL	CompileStr
	POP	HL
	LD	(BegString),HL
	PUSH	HL
	LD	A,(CompBuff)
	LD	C,A
	LD	B,#00
	PUSH	HL
	LD	HL,(EndText)
	PUSH	HL
	ADD	HL,BC
	JP	C,OverText
	LD	E,L	; New text
	LD	D,H
	POP	HL
	POP	BC
	OR	A
	SBC	HL,BC	; Text
	LD	C,L
	LD	B,H
	LD	HL,(EndText)
	LD	(EndText),DE
	SUB	A
	LD	(DE),A
	LD	A,B
	OR	C
	JR	Z,EnterE0
	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
	LD	A,B
	OR	A
	JR	Z,EN12
EN02	DEC	H
	DEC	D
	LD	D,D
	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
	DEC	B
	JR	NZ,EN02
EN12	LD	A,C
	OR	A
	JR	Z,EN22
	LD	(ENlen2+1),A
	LD	B,#00
	SBC	HL,BC
	EX	DE,HL
	SBC	HL,BC
	EX	DE,HL
	LD	D,D
ENlen2	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
EN22	EI 
EnterE0	POP	HL
	LD	DE,CompBuff
	EX	DE,HL
	LD	C,(HL)
	LD	B,#00
	LDIR 
	LD	HL,(EquipLn)
	INC	HL
	LD	(EquipLn),HL
	JP	EnterEx
EnterEmpty
	LD	HL,(BegString)
	LD	C,(HL)
	LD	B,#00
	ADD	HL,BC
	LD	A,(ReadyStr)	; Was not touched
	OR	A
	JR	NZ,EnterE1
	INC	A
	LD	(ReadyStr),A
	CALL	PutString
EnterE1	LD	(BegString),HL
	BIT	0,(IY-#03)
	JR	NZ,EntIns
	LD	A,(HL)
	OR	A
	JP	NZ,EntOver
EntIns	PUSH	HL
	LD	BC,#0003
	PUSH	HL
	LD	HL,(EndText)
	PUSH	HL
	ADD	HL,BC
	JP	C,OverText
	LD	E,L	; New text
	LD	D,H
	POP	HL
	POP	BC
	OR	A
	SBC	HL,BC	; Text
	LD	C,L
	LD	B,H
	LD	HL,(EndText)
	LD	(EndText),DE
	SUB	A
	LD	(DE),A
	LD	A,B
	OR	C
	JR	Z,EnterE2
	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
	LD	A,B
	OR	A
	JR	Z,EE12
EE02	DEC	H
	DEC	D
	LD	D,D
	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
	DEC	B
	JR	NZ,EE02
EE12	LD	A,C
	OR	A
	JR	Z,EE22
	LD	(EElen2+1),A
	LD	B,#00
	SBC	HL,BC
	EX	DE,HL
	SBC	HL,BC
	EX	DE,HL
	LD	D,D
EElen2	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
EE22	EI 
EnterE2	LD	HL,(BegString)
	DEC	HL
	LD	E,(HL)
	INC	HL
	LD	D,A
	SBC	HL,DE
	INC	HL
	LD	C,(HL)
	POP	HL
	LD	(HL),#03
	INC	HL
	PUSH	HL
	LD	(HL),#02
	INC	HL
	LD	(HL),#03
	INC	HL
	LD	A,(HL)
	INC	HL
	LD	B,(HL)
	POP	HL
	OR	A
	JR	Z,EntOv1
	BIT	6,C
	JR	Z,EntOv1
	BIT	6,B
	JR	Z,EntOv1
	SET	6,(HL)
EntOv1	LD	HL,(EquipLn)
	INC	HL
	LD	(EquipLn),HL
EntOver	CALL	ReCompileStr
EnterEx	SUB	A
	LD	(IY+#00),A
	LD	(IY-#01),A
	LD	(IY+#07),A
	LD	(IY-#02),A
	LD	HL,(AdrPage)
	LD	A,(IY+#01)
	INC	A
	CP	(IY+#06)
	JR	NZ,EnterNx
	LD	DE,(UpLinePg)
	INC	DE
	LD	(UpLinePg),DE
	LD	E,(HL)
	LD	D,#00
	ADD	HL,DE
	DEC	A
EnterNx	LD	(IY+#01),A
	LD	(AdrPage),HL
	LD	HL,(CurLine)
	INC	HL
	LD	(CurLine),HL
	CALL	PrintPage
	SUB	A
	LD	(ReadyFile),A
	CALL	PrintInfo
	RET 
;[]===========================================================[]
PreviosPage
	LD	HL,(AdrPage)
	DEC	HL
	LD	A,(HL)
	OR	A
	JP	Z,BegTEXT	; Begin text
	INC	HL
	LD	A,(ReadyStr)	; Was not touched
	OR	A
	JR	NZ,PrevPgN
	INC	A
	LD	(ReadyStr),A
	PUSH	HL
	CALL	PutString
	POP	HL
PrevPgN	LD	IX,(UpLinePg)
	LD	B,(IY+#06)
	LD	D,#00
PrPgLp1	DEC	HL		; Search begin page
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,PrPgNx1
	LD	E,A
	SBC	HL,DE
	DEC	IX
	DJNZ	PrPgLp1
PrPgNx1	LD	(AdrPage),HL
	LD	(UpLinePg),IX
	LD	A,(IY+#01)
	OR	A
	JR	Z,PrPgNx2
	LD	B,A
	LD	E,(HL)
	ADD	HL,DE
	DJNZ	$-2
PrPgNx2	LD	(BegString),HL
	ADD	A,LX
	LD	LX,A
	JR	NC,$+4
	INC	HX
	LD	(CurLine),IX
	JR	PageExt
;[]===========================================================[]
NextPage
	LD	A,(ReadyStr)	; Was not touched
	OR	A
	JR	NZ,NextPgN
	INC	A
	LD	(ReadyStr),A
	CALL	PutString
NextPgN	LD	HL,(AdrPage)
	LD	B,(IY+#06)
	LD	D,#00
NxtPg1	LD	E,(HL)
	ADD	HL,DE
	LD	A,(HL)
	OR	A
	JP	Z,EndTEXT	; End text
	DJNZ	NxtPg1
	LD	(AdrPage),HL
	LD	IX,(UpLinePg)
	LD	A,LX
	ADD	A,(IY+#06)
	LD	LX,A
	JR	NC,$+4
	INC	HX
	LD	(UpLinePg),IX
	LD	A,(IY+#01)
	OR	A
	JR	Z,NxPgNx2
	LD	B,A
	LD	D,#00
NxPgLp1	LD	E,(HL)		; Search begin page
	ADD	HL,DE
	INC	IX
	LD	A,(HL)
	OR	A
	JR	Z,NxPgNx1
	DJNZ	NxPgLp1
	JR	NxPgNx2
NxPgNx1	LD	A,(IY+#01)
	SUB	B
	LD	(IY+#01),A
	DEC	HL
	LD	E,(HL)
	INC	HL
	SBC	HL,DE
	DEC	IX
NxPgNx2	LD	(CurLine),IX
	LD	(BegString),HL
PageExt	CALL	ReCompileStr
	LD	A,(EditMode)
	OR	A
	JR	NZ,PageEx1
	LD	A,(IY-#02)
	LD	(IY+#07),A
	LD	A,(IY-#01)
	ADD	A,(IY-#02)
	CP	(IY+#02)
	JR	C,PPnxt2
	LD	(IY+#07),#00
	LD	A,(IY+#02)
	SUB	(IY+#05)
	JR	C,PPnxt1
PPnxt0	LD	C,A
	LD	A,(IY+#07)
	ADD	A,Step
	LD	(IY+#07),A
	LD	A,C
	SUB	Step
	JR	NC,PPnxt0
PPnxt1	LD	A,(IY+#02)
	ADD	A,(IY-#02)
	SUB	(IY+#07)
PPnxt2	SUB	(IY-#02)
	LD	(IY+#00),A
	CALL	PrintPage
	CALL	PrintInfo
	RET 
; Table
PageEx1	LD	A,(IY-#01)
	LD	(IY+#00),A
	CALL	PrintPage
	CALL	PrintInfo
	RET 
;[]===========================================================[]
; Delete char in current position
_Del_	LD	H, high TextBuff
	LD	A,(IY+#00)
	INC	A
	ADD	A,(IY+#07)
	ADD	A,A
	LD	L,A
	JR	NC,$+3
	INC	H
	LD	E,L
	LD	D,H
	DEC	DE
	DEC	DE
	LD	A,(IY+#02)
	SUB	(IY+#07)
	SUB	(IY+#00)
	JR	Z,PlusStr
	ADD	A,A
	LD	C,A
	LD	A,#00
	ADC	A,A
	LD	B,A
	LDIR 
	SUB	A
	LD	(DE),A
	INC	DE
	LD	A,(ColTxtWin)
	LD	(DE),A
	DEC	(IY+#02)
	CALL	Syntax
	SUB	A
	LD	(ReadyStr),A
	LD	(ReadyFile),A
	LD	A,(IY+#07)
	LD	(IY-#02),A
	LD	A,(IY+#00)
	LD	(IY-#01),A
	RET 
PlusStr	LD	HL,(BegString)
	LD	C,(HL)
	LD	B,#00
	ADD	HL,BC
	LD	A,(HL)
	OR	A
	RET	Z	; End text
	PUSH	HL
	POP	IX
	LD	A,(IY+#02)
	PUSH	AF
	LD	HL,ReCompBuff
	CALL	ReCompile
	POP	AF
	LD	E,A
	ADD	A,(IY+#02)
	RET	C
	CP	241
	RET	NC
	PUSH	AF
	LD	A,(IY+#02)
	ADD	A,A
	LD	C,A
	LD	A,#00
	ADC	A,A
	LD	B,A
	OR	C
	JR	Z,PlsDEL
	LD	HL,ReCompBuff
	LD	D, high TextBuff
	LD	A,E
	ADD	A,A
	LD	E,A
	JR	NC,$+3
	INC	D
	LDIR 
PlsDEL	POP	AF
	LD	(IY+#02),A
	CALL	OnlySyntax
	LD	HL,(BegString)
	PUSH	HL
	LD	A,(HL)
	LD	C,A
	LD	B,#00
	ADD	HL,BC
	ADD	A,(HL)
	POP	HL
	LD	(HL),A
	CALL	PutString
	CALL	PrintPage
	SUB	A
	LD	(ReadyStr),A
	LD	(ReadyFile),A
	LD	A,(IY+#07)
	LD	(IY-#02),A
	LD	A,(IY+#00)
	LD	(IY-#01),A
	LD	HL,(EquipLn)
	DEC	HL
	LD	(EquipLn),HL
	CALL	PrintInfo
	JP	TestEnd
;[]===========================================================[]
HomeStr	LD	A,(IY+#00)
	ADD	A,(IY+#07)
	RET	Z
	LD	B,(IY+#07)
	SUB	A
	LD	(IY+#00),A
	LD	(IY-#01),A
	LD	(IY+#07),A
	LD	(IY-#02),A
	LD	A,B
	CP	(IY+#07)
	CALL	NZ,RefreshPage
	CALL	PrintS
	CALL	PrintInfo
	JP	TestEnd
;[]===========================================================[]
EndStr	LD	A,(EditMode)
	OR	A
	JR	Z,EndNxt
	LD	A,(IY+#02)
	LD	B,A
	LD	H, high TextBuff
	ADD	A,A
	LD	L,A
	JR	NC,$+3
	INC	H
	LD	A,(ColTxtWin)
	LD	C,A
	LD	E,#00
EndSpac	LD	(HL),E
	DEC	HL
	DEC	HL
	LD	A,(HL)
	CP	#20
	JR	NZ,$+7
	INC	HL
	LD	(HL),C
	DEC	HL
	DJNZ	EndSpac
	LD	(IY+#02),B
	CALL	PrintS
EndNxt	LD	A,(IY+#02)
	SUB	(IY+#07)
	CP	(IY+#00)
	RET	Z
	LD	B,(IY+#07)
	LD	(IY+#07),#00
	LD	A,(IY+#02)
	SUB	(IY+#05)
	JR	C,EndN
EndLp	LD	C,A
	LD	A,(IY+#07)
	ADD	A,Step
	LD	(IY+#07),A
	LD	(IY-#02),A
	LD	A,C
	SUB	Step
	JR	NC,EndLp
EndN	LD	A,(IY+#02)
	SUB	(IY+#07)
	LD	(IY+#00),A
	LD	(IY-#01),A
	LD	A,(IY+#05)	; Max len x
	ADD	A,(IY+#07)
	SUB	(IY+#02)
	JR	C,EndN1
	JR	Z,EndN1
	PUSH	BC
	LD	B,A
	LD	HL,TextBuff
	LD	E,(IY+#02)
	LD	D,L
	ADD	HL,DE
	ADD	HL,DE
	LD	A,(ColTxtWin)
	LD	C,A
	SUB	A
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	POP	BC
EndN1	LD	A,B
	CP	(IY+#07)
	CALL	NZ,RefreshPage
	CALL	PrintS
	CALL	PrintInfo
	RET 
;
 _mCollectInfo_addEnd