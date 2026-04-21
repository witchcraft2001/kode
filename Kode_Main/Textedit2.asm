 _mCollectInfo_addStart
;[]===========================================================[]
Tabulat	LD	A,(TabSize)
	LD	C,A
	LD	A,(LabSize)
	LD	B,A
	LD	A,(IY+#00)
	ADD	A,(IY+#07)
	ADD	A,C
	CP	240
	RET	NC
	BIT	0,(IY-#03)
	JR	NZ,TabInsrt
TabOver	SUB	A
	ADD	A,B
	CP	(IY+#00)
	JR	Z,$+4
	JR	NC,TabExit
	ADD	A,C
	CP	(IY+#00)
	JR	Z,$-4
	JR	C,$-6
TabExit	LD	HL,PrintInfo
	PUSH	HL
	LD	(IY+#00),A
	LD	(IY-#01),A
	LD	C,A
	ADD	A,(IY+#07)
	PUSH	AF
	LD	A,C
	CP	(IY+#05)
	CALL	NC,OutScrn
	POP	AF
	CP	(IY+#02)
	JP	C,Syntax
	JP	Z,Syntax
	LD	E,(IY+#02)
	LD	(IY+#02),A
	SUB	E
	LD	B,A
	LD	HL,TextBuff
	LD	D,L
	ADD	HL,DE
	ADD	HL,DE
	LD	A,(ColTxtWin)
	LD	C,#20
	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-4
	SUB	A
	LD	(ReadyStr),A
	LD	(ReadyFile),A
	LD	A,(IY+#07)
	LD	(IY-#02),A
	JP	Syntax
TabInsrt
	LD	A,(IY+#00)
	ADD	A,(IY+#07)
	CP	(IY+#02)
	JR	Z,TabOver
	SUB	A
	ADD	A,B
	CP	(IY+#00)
	JR	Z,$+4
	JR	NC,TabIns1
	ADD	A,C
	CP	(IY+#00)
	JR	Z,$-4
	JR	C,$-6
TabIns1	LD	HL,TextBuff
	PUSH	AF
	SUB	(IY+#00)
	PUSH	AF
	ADD	A,(IY+#02)
	LD	C,A
	LD	B,L
	PUSH	HL
	ADD	HL,BC
	ADD	HL,BC
	EX	DE,HL
	POP	HL
	LD	C,(IY+#02)
	ADD	HL,BC
	ADD	HL,BC
	LD	A,(IY+#02)
	SUB	(IY+#00)
	ADD	A,A
	LD	C,A
	LD	A,#00
	ADC	A,A
	LD	B,A
	PUSH	DE
	DEC	HL
	DEC	DE
	LDDR 
	POP	HL
	LD	(HL),C
	POP	AF
	LD	B,A
	ADD	A,(IY+#02)
	LD	(IY+#02),A
	POP	AF
	LD	(IY+#00),A
	LD	(IY-#01),A
	EX	AF,AF'
	LD	A,(ColTxtWin)
	LD	C,A
	LD	A,#20
	EX	DE,HL
	LD	(HL),C
	DEC	HL
	LD	(HL),A
	DEC	HL
	DJNZ	$-4
	EX	AF,AF'
	CP	(IY+#05)
	CALL	NC,OutScrn
	SUB	A
	LD	(ReadyStr),A
	LD	(ReadyFile),A
	LD	A,(IY+#07)
	LD	(IY-#02),A
	JP	Syntax
BackTab
	LD	A,(IY+#00)
	ADD	A,(IY+#07)
	RET	Z
	LD	D,A
	LD	A,(TabSize)
	LD	C,A
	LD	A,(LabSize)
	LD	B,A
	SUB	A
	LD	E,A
	ADD	A,B
	CP	D
	JR	Z,BckTabE
	JR	NC,BckTabE
	LD	E,A
	ADD	A,C
	CP	D
	JR	Z,BckTabE
	JR	C,$-5
BckTabE	BIT	0,(IY-#03)
	JR	NZ,BckTabIns
BckTabR	LD	B,(IY+#07)
	LD	(IY+#07),#00
	LD	A,E
	SUB	(IY+#05)
	JR	C,BckTnxt
BckTlp	LD	C,A
	LD	A,(IY+#07)
	ADD	A,Step
	LD	(IY+#07),A
	LD	(IY-#02),A
	LD	A,C
	SUB	Step
	JR	NC,BckTlp
BckTnxt	LD	A,E
	SUB	(IY+#07)
	LD	(IY+#00),A
	LD	(IY-#01),A
	LD	A,B
	CP	(IY+#07)
	CALL	NZ,RefreshPage
	CALL	Syntax
	CALL	PrintInfo
	LD	A,(IY+#07)
	LD	(IY-#02),A
	JP	TestEnd
BckTabIns
	LD	HL,TextBuff
	LD	C,D
	LD	B,#00
	ADD	HL,BC
	ADD	HL,BC
	LD	A,D
	SUB	E
	LD	C,A
	LD	B,A
	PUSH	HL
BckTbI0	DEC	HL
	DEC	HL
	LD	A,(HL)
	CP	#20
	JR	NZ,BckTbI1
	DJNZ	BckTbI0
BckTbI1	POP	HL
	LD	A,B
	SUB	C
	JR	Z,BckTabR
	LD	A,E
	ADD	A,B
	LD	E,A
	LD	C,A
	LD	A,(IY+#02)
	SUB	D
	PUSH	DE
	EX	DE,HL
	LD	HL,TextBuff
	LD	B,#00
	ADD	HL,BC
	ADD	HL,BC
	EX	DE,HL
	ADD	A,A
	LD	C,A
	LD	A,#00
	ADC	A,A
	LD	B,A
	OR	C
	JR	Z,$+4
	LDIR 
	EX	DE,HL
	POP	DE
	LD	A,D
	SUB	E
	LD	B,A
	LD	A,(IY+#02)
	SUB	B
	LD	(IY+#02),A
	LD	A,(ColTxtWin)
	LD	C,A
	SUB	A
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	SUB	A
	LD	(ReadyStr),A
	LD	(ReadyFile),A
	JP	BckTabR
;[]===========================================================[]
WordRgt	LD	A,(IY+#02)
	SUB	(IY+#00)
	SUB	(IY+#07)
	JP	Z,CurRght
	LD	B,A
	LD	H, high TextBuff
	LD	A,(IY+#00)
	ADD	A,(IY+#07)
	LD	C,A
	ADD	A,A
	LD	L,A
	JR	NC,$+3
	INC	H
WRnxt0	LD	A,(HL)
	CP	#20
	JR	Z,WRnxt1
	CP	","
	JR	Z,WRnxt1
	CP	";"
	JR	Z,WRnxt1
	CP	"."
	JR	Z,WRnxt1
	INC	HL
	INC	HL
	INC	C
	DJNZ	WRnxt0
	JR	WRnxt2
WRnxt1	LD	A,(HL)
	CP	#20
	JR	Z,WRnxt11
	CP	";"
	JR	Z,WRnxt11
	CP	","
	JR	Z,WRnxt11
	CP	"."
	JR	NZ,WRnxt2
WRnxt11	INC	HL
	INC	HL
	INC	C
	DJNZ	WRnxt1
WRnxt2	LD	B,(IY+#07)
	LD	(IY+#07),#00
	LD	A,C
	SUB	(IY+#05)
	JR	C,WRnxt4
WRnxt3	LD	E,A
	LD	A,(IY+#07)
	ADD	A,Step
	LD	(IY+#07),A
	LD	(IY-#02),A
	LD	A,E
	SUB	Step
	JR	NC,WRnxt3
WRnxt4	LD	A,C
	SUB	(IY+#07)
	LD	(IY+#00),A
	LD	(IY-#01),A
	LD	A,B
	CP	(IY+#07)
	CALL	NZ,RefreshPage
	CALL	PrintInfo
	CALL	ResCurs
	CALL	SetCurs
	RET 
;[]===========================================================[]
WordLft	LD	A,(IY+#00)
	ADD	A,(IY+#07)
	JP	Z,CurLeft
	LD	B,A
	LD	H, high TextBuff
	LD	C,A
	ADD	A,A
	LD	L,A
	JR	NC,$+3
	INC	H
WLnxt0	DEC	HL
	DEC	HL
	DEC	C
	LD	A,(HL)
	CP	#20
	JR	Z,WLnxt1
	CP	";"
	JR	Z,WLnxt1
	CP	","
	JR	Z,WLnxt1
	CP	"."
	JR	Z,WLnxt1
	DJNZ	WLnxt0
	JR	WLnxt2
WLnxt1	LD	A,(HL)
	CP	#20
	JR	Z,WLnxt11
	CP	";"
	JR	Z,WLnxt11
	CP	","
	JR	Z,WLnxt11
	CP	"."
	JR	NZ,WLnxt2-1
WLnxt11	DEC	HL
	DEC	HL
	DEC	C
	DJNZ	WLnxt1
	INC	C
WLnxt2	CALL	WRnxt2
	LD	A,(EditMode)
	OR	A
	RET	Z
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
WLnxt5	LD	(HL),E
	DEC	HL
	DEC	HL
	LD	A,(HL)
	CP	#20
	JR	NZ,$+7
	INC	HL
	LD	(HL),C
	DEC	HL
	DJNZ	WLnxt5
	LD	(IY+#02),B
	CALL	PrintS
	RET 
;[]===========================================================[]
DelWord	LD	A,(IY+#00)
	ADD	A,(IY+#07)
	JP	Z,Delete
	LD	B,A
	LD	A,(IY+#02)
	SUB	B
	LD	E,A
	LD	H, high TextBuff
	LD	C,B
	LD	A,C
	ADD	A,A
	LD	L,A
	JR	NC,$+3
	INC	H
	PUSH	HL
	DEC	HL
	DEC	HL
	DEC	C
	LD	A,(HL)
	CP	#20
	JR	Z,DWnxt1
	CP	";"
	JR	Z,DWnxt1
	CP	","
	JR	Z,DWnxt1
	CP	"."
	JR	Z,DWnxt1
	DEC	B
	JR	Z,DWnxt2
DWnxt0	DEC	HL
	DEC	HL
	DEC	C
	LD	A,(HL)
	CP	#20
	JR	Z,DWnxt2-3
	CP	";"
	JR	Z,DWnxt2-3
	CP	","
	JR	Z,DWnxt2-3
	CP	"."
	JR	Z,DWnxt2-3
	DJNZ	DWnxt0
	JR	DWnxt2
DWnxt1	LD	A,(HL)
	CP	#20
	JR	Z,DWnxt11
	CP	";"
	JR	Z,DWnxt11
	CP	","
	JR	Z,DWnxt11
	CP	"."
	JR	NZ,DWnxt2-3
DWnxt11	DEC	HL
	DEC	HL
	DEC	C
	DJNZ	DWnxt1
	INC	C
	INC	HL
	INC	HL
DWnxt2	LD	A,C
	EX	AF,AF'
	BIT	0,(IY-#03)
	JR	NZ,DWins0
	POP	DE
	EX	DE,HL
	OR	A
	SBC	HL,DE
	SRL	H
	RR	L
	LD	B,L
	EX	DE,HL
	LD	E,#20
	LD	A,(IY+#02)
	SUB	C
	SUB	B
	JR	NZ,$+7
	LD	E,#00
	LD	(IY+#02),C
	LD	A,(ColTxtWin)
	LD	(HL),E
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-4
	JR	DWins1
DWins0	LD	A,(IY+#00)
	ADD	A,(IY+#07)
	SUB	C
	LD	C,A
	LD	A,(IY+#02)
	SUB	C
	LD	(IY+#02),A
	LD	A,C
	LD	C,E
	INC	C
	LD	B,#00
	RL	C
	SLA	B
	EX	DE,HL
	POP	HL
	LDIR 
	EX	DE,HL
	LD	B,A
	LD	A,(ColTxtWin)
	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-4
DWins1	EX	AF,AF'
	LD	C,A
	LD	B,(IY+#07)
	LD	(IY+#07),#00
	LD	A,C
	SUB	(IY+#05)
	JR	C,DWnxt4
DWnxt3	LD	E,A
	LD	A,(IY+#07)
	ADD	A,Step
	LD	(IY+#07),A
	LD	(IY-#02),A
	LD	A,E
	SUB	Step
	JR	NC,DWnxt3
DWnxt4	LD	A,C
	SUB	(IY+#07)
	LD	(IY+#00),A
	LD	(IY-#01),A
	LD	A,B
	CP	(IY+#07)
	CALL	NZ,RefreshPage
	SUB	A
	LD	(ReadyStr),A
	LD	(ReadyFile),A
	CALL	Syntax
	CALL	PrintInfo
	RET 
;[]===========================================================[]
ScrLnUp	LD	HL,(AdrPage)
	DEC	HL
	LD	A,(HL)
	OR	A
	RET	Z	; Begin text
	INC	HL
	LD	C,A
	LD	B,#00
	SBC	HL,BC
	LD	(AdrPage),HL
	LD	A,(ReadyStr)	; Was not touched
	OR	A
	JR	NZ,ScrLnU1
	INC	A
	LD	(ReadyStr),A
	CALL	PutString
ScrLnU1	LD	HL,(BegString)
	LD	B,#00
	DEC	HL
	LD	C,(HL)
	INC	HL
	OR	A
	SBC	HL,BC
	LD	(BegString),HL
	BIT	4,(IY+#08)
	JR	Z,$+8
	CALL	NotComm
	CALL	PrintS
	LD	HL,(CurLine)
	DEC	HL
	LD	(CurLine),HL
	LD	HL,(UpLinePg)
	DEC	HL
	LD	(UpLinePg),HL
	JP	PageExt
;[]===========================================================[]
ScrLnDn	LD	HL,(BegString)
	LD	B,#00
	LD	C,(HL)
	ADD	HL,BC
	LD	A,(HL)
	OR	A
	RET	Z	; Begin text
	LD	A,(ReadyStr)	; Was not touched
	OR	A
	JR	NZ,ScrLnD1
	INC	A
	LD	(ReadyStr),A
	CALL	PutString
ScrLnD1	LD	(BegString),HL
	BIT	4,(IY+#08)
	JR	Z,$+8
	CALL	NotComm
	CALL	PrintS
	LD	HL,(AdrPage)
	LD	B,#00
	LD	C,(HL)
	ADD	HL,BC
	LD	(AdrPage),HL
	LD	HL,(CurLine)
	INC	HL
	LD	(CurLine),HL
	LD	HL,(UpLinePg)
	INC	HL
	LD	(UpLinePg),HL
	JP	PageExt
;[]===========================================================[]
ScrollUp
	PUSH	AF
	PUSH	BC
	IN	A,(SLOT3)
	PUSH	AF
	LD	HL,(AdrPage)
	LD	E,(HL)
	LD	D,#00
	ADD	HL,DE
	LD	(AdrPage),HL
	LD	HL,(UpLinePg)
	INC	HL
	LD	(UpLinePg),HL
	LD	IX,TxtWtab
	LD	A,(IX+#21)	; Window page
	OUT	(SLOT3),A
	LD	L,(IX+#1F)	; Address window place
	LD	H,(IX+#20)
	LD	A,H
	ADD	A,#C0
	LD	H,A
	INC	HL
	INC	HL
	LD	A,(IX+02)	;Xi
	SUB	(IX+#01)	; -xo=len x
	SUB	#02		;Save len wind
	ADD	A,A		;+ atr
	LD	(scrlup+1),A
	ADD	A,#08		;+ shadow
	LD	C,A		; Window
	LD	B,#00
	ADD	HL,BC
	LD	E,L
	LD	D,H
	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
	LD	A,(IY+#06)
	DEC	A		; Count-in lines in -1
ScrlUp1	EX	AF,AF'
	ADD	HL,BC
	LD	D,D
scrlup	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
	EX	AF,AF'
	DEC	A
	JR	NZ,ScrlUp1
	EI 
	POP	AF
	OUT	(SLOT3),A
	PUSH	HL
	LD	HL,(AdrPage)
	LD	B,(IY+#06)
	DEC	B
	LD	D,#00
	LD	E,(HL)
	ADD	HL,DE
	DJNZ	$-2
	PUSH	HL
	POP	IX
	LD	E,L
	LD	D,H
	INC	E
	INC	E
	LD	HL,ReCompBuff
	PUSH	HL
	CALL	ReCompile
	POP	HL
	POP	DE
	IN	A,(SLOT3)
	PUSH	AF
	LD	IX,TxtWtab
	LD	A,(IX+#21)	; Window page
	OUT	(SLOT3),A
	LD	C,(IY+#07)
	LD	B,#00
	ADD	HL,BC
	ADD	HL,BC
	LD	C,(IY+#05)
	SLA	C
	LDIR
	POP	AF
	OUT	(SLOT3),A
	CALL	PrnTxtW
	POP	BC
	POP	AF
	DEC	A
	RET
;[]===========================================================[]
ScrollDown
	PUSH	AF
	PUSH	BC
	IN	A,(SLOT3)
	PUSH	AF
	LD	HL,(AdrPage)
	LD	D,#00
	DEC	HL
	LD	E,(HL)
	INC	HL
	OR	A
	SBC	HL,DE
	LD	(AdrPage),HL
	LD	HL,(UpLinePg)
	DEC	HL
	LD	(UpLinePg),HL
	LD	IX,TxtWtab
	LD	A,(IX+#21)	; Window page
	OUT	(SLOT3),A
	LD	L,(IX+#1F)	; Address window place
	LD	H,(IX+#20)
	LD	A,H
	ADD	A,#C0
	LD	H,A
	INC	HL
	INC	HL
	LD	A,(IX+02)	;Xi
	SUB	(IX+#01)	; -xo=len x
	SUB	#02		;Save len wind
	ADD	A,A		;+ atr
	LD	(scrldw+1),A
	ADD	A,#08		;+ shadow
	LD	E,A		; Window
	LD	D,#00
	LD	A,(IY+#06)
	LD	B,A
	ADD	HL,DE
	DJNZ	$-1
	DEC	A		; Count-in lines in -1
	PUSH	AF
	LD	C,E
	LD	E,L
	LD	D,H
	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
	POP	AF		; Count-in lines in -1
ScrlDn1	EX	AF,AF'
	OR	A
	SBC	HL,BC
	LD	D,D
scrldw	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
	EX	DE,HL
	OR	A
	SBC	HL,BC
	EX	DE,HL
	EX	AF,AF'
	DEC	A
	JR	NZ,ScrlDn1
	EI 
	POP	AF
	OUT	(SLOT3),A
	CALL	PrnTxtW
	POP	BC
	POP	AF
	INC	A
	RET 
;[]===========================================================[]
MrkStrD	LD	HL,(BegString)
	INC	HL
	LD	A,(HL)
	RES	6,(HL)
	PUSH	AF
	PUSH	HL
	LD	B,#00
	DEC	HL
	DEC	HL
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,MarkD0
	PUSH	HL
	LD	C,A
	OR	A
	SBC	HL,BC
	INC	HL
	BIT	6,(HL)
	POP	HL
	JR	NZ,MarkD2
MarkD0	LD	C,(HL)
	ADD	HL,BC
	LD	A,(HL)
	OR	A
	JR	Z,MarkD2
	INC	HL
	BIT	6,(HL)
	CALL	Z,ExmMark
MarkD2	POP	HL
	POP	AF
	XOR	#40
	LD	(HL),A
	DEC	HL
	LD	DE,(EquipMr)
	RES	0,(IY-#04)
	BIT	6,A
	JR	Z,$+8
	INC	DE
	INC	DE
	SET	0,(IY-#04)
	DEC	DE
	LD	(EquipMr),DE
	CALL	Z,ExmMark+3
	CALL	Syntax
	LD	HL,MarkGrp
	LD	DE,(EquipMr)
	LD	A,D
	OR	E
	PUSH	AF
	CALL	Z,CloseGroup
	POP	AF
	CALL	NZ,OpenGroup
	LD	A,(EditMode)
	OR	A
	JP	Z,CurDown
	JP	Cdown
;
MrkStrU	LD	HL,(BegString)
	INC	HL
	LD	A,(HL)
	RES	6,(HL)
	PUSH	AF
	PUSH	HL
	LD	B,#00
	DEC	HL
	DEC	HL
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,MarkU0
	PUSH	HL
	LD	C,A
	OR	A
	SBC	HL,BC
	INC	HL
	BIT	6,(HL)
	POP	HL
	JR	NZ,MarkU2
MarkU0	LD	C,(HL)
	ADD	HL,BC
	LD	A,(HL)
	OR	A
	JR	Z,MarkU1
	INC	HL
	BIT	6,(HL)
MarkU1	CALL	Z,ExmMark
MarkU2	POP	HL
	POP	AF
	XOR	#40
	LD	(HL),A
	DEC	HL
	LD	DE,(EquipMr)
	RES	0,(IY-#04)
	BIT	6,A
	JR	Z,$+8
	INC	DE
	INC	DE
	SET	0,(IY-#04)
	DEC	DE
	LD	(EquipMr),DE
	EX	AF,AF'
	LD	C,(HL)
	LD	B,#00
	ADD	HL,BC
	PUSH	HL
	LD	A,(HL)
	LD	(HL),B
	PUSH	AF
	EX	AF,AF'
	CALL	Z,ExmMark
	POP	AF
	POP	HL
	LD	(HL),A
	CALL	Syntax
	LD	HL,MarkGrp
	LD	DE,(EquipMr)
	LD	A,D
	OR	E
	PUSH	AF
	CALL	Z,CloseGroup
	POP	AF
	CALL	NZ,OpenGroup
	LD	A,(EditMode)
	OR	A
	JP	Z,CursUp
	JP	Cup
;
MarkGrp	DEFB	cmCut,cmCutAppnd,cmCopy,cmAppend,cmClear,#FF
;
ExmMark	LD	HL,#8040
	LD	A,(HL)
	LD	B,#00
	LD	E,B
	LD	D,E
ExMrkLp	LD	C,A
	INC	HL
	BIT	6,(HL)
	RES	6,(HL)
	DEC	HL
	JR	Z,$+3
	INC	DE
	ADD	HL,BC
	LD	A,(HL)
	OR	A
	JR	NZ,ExMrkLp
	RES	0,(IY-#04)
	LD	A,D
	OR	E
	RET	Z
	LD	HL,(EquipMr)
	SBC	HL,DE
	LD	(EquipMr),HL
	LD	HL,MarkGrp
	PUSH	AF
	CALL	Z,CloseGroup
	POP	AF
	CALL	NZ,OpenGroup
	CALL	OnlySyntax
	CALL	RefreshPage
	RET 
;[]===========================================================[]
; On:DE-Y,X position
NewCurP	LD	(SavePOS),DE
	SUB	A
	LD	(ProecFlg),A
	LD	A,D
	CP	(IY+#01)
	JR	NZ,NewCPY
	LD	A,(CurFlag)
	OR	A
	JR	Z,NewCPY
	LD	A,E
	CP	(IY+#00)
	RET	Z
NewCPY	CALL	OnlySyntax
	CALL	PutString
	BIT	4,(IY+#08)
	JR	Z,NewCPY0
	CALL	NotComm
	LD	A,(CurFlag)
	OR	A
	CALL	NZ,PrintS
NewCPY0	LD	IX,(UpLinePg)
	LD	HL,(AdrPage)
	LD	D,#00
	LD	(IY+#01),D
	LD	A,(SavePOS+1)
	OR	A
	JR	Z,NewCPYN
	LD	B,A
NewCPYl	LD	E,(HL)
	ADD	HL,DE
	INC	(IY+#01)
	INC	IX
	LD	A,(HL)
	OR	A
	JR	Z,NewCPYn
	DJNZ	NewCPYl
	JR	NewCPYN
NewCPYn	SUB	A
	LD	(SavePOS),A
	DEC	HL
	LD	E,(HL)
	INC	HL
	SBC	HL,DE
	DEC	(IY+#01)
	DEC	IX
	PUSH	IX
	PUSH	HL
	CALL	ExmMark
	POP	HL
	POP	IX
NewCPYN	LD	(CurLine),IX
	LD	(BegString),HL
NewCPX	CALL	ReCompileStr
	LD	HL,(BegString)
	INC	HL
	BIT	6,(HL)
	CALL	Z,ExmMark
	LD	A,(EditMode)
	OR	A
	JR	NZ,NewCPY1
	LD	B,(IY+#07)
	LD	A,(SavePOS)
	OR	(IY+#02)
	OR	B
	JR	Z,NCPnx1
	LD	A,(SavePOS)
	ADD	A,B
	CP	(IY+#02)
	JR	C,NCPnx1-3
	LD	HL,(BegString)
	INC	HL
	BIT	6,(HL)
	PUSH	BC
	CALL	NZ,ExmMark
	POP	BC
	LD	A,(IY+#02)
	SUB	B
	JR	NC,NCPnx1
	LD	(IY+#07),#00
	LD	A,(IY+#02)
	SUB	(IY+#05)
	JR	C,NCn
NCn1	LD	C,A
	LD	A,(IY+#07)
	ADD	A,Step
	LD	(IY+#07),A
	LD	A,C
	SUB	Step
	JR	NC,NCn1
NCn	LD	A,(IY+#02)
	SUB	(IY+#07)
NCPnx1	LD	(IY-#01),A
	LD	(IY+#00),A
	LD	A,B
	CP	(IY+#07)
	CALL	NZ,RefreshPage
	JR	Ndwnext
NewCPY1	LD	A,(SavePOS)
	LD	(IY-#01),A
	LD	(IY+#00),A
	ADD	A,(IY+#07)
	SUB	(IY+#02)
	JR	C,Ndwnext
	JR	Z,Ndwnext
	LD	B,A
	LD	HL,TextBuff
	LD	E,(IY+#02)
	LD	D,L
	ADD	HL,DE
	ADD	HL,DE
	LD	C,#20
	LD	A,(ColTxtWin)
	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-4
	LD	A,(IY+#00)
	ADD	A,(IY+#07)
	LD	(IY+#02),A
Ndwnext	LD	A,(IY+#07)
	LD	(IY-#02),A
	CALL	Syntax
	CALL	PrintInfo
	LD	HL,MarkGrp
	LD	DE,(EquipMr)
	LD	A,D
	OR	E
	PUSH	AF
	CALL	Z,CloseGroup
	POP	AF
	CALL	NZ,OpenGroup
	LD	A,#03
	RST	#00
	LD	IX,TxtWtab
	LD	A,H
	SUB	(IX+#03)
	DEC	A
	CP	(IY+#01)
	JP	NZ,NewExt
	LD	(SavePOS),HL
NewLoop	LD	A,#03
	RST	#00
	BIT	1,A
	RET	Z
	LD	IX,TxtWtab
	LD	A,L
	CP	(IX+#01)
	JR	C,NewExt
	CP	(IX+#02)
	JR	NC,NewExt
	LD	DE,(SavePOS)
	LD	A,D
	SUB	H
	JR	Z,TstLoop
	LD	(SavePOS),HL
	JR	C,New1
	JR	New0
TstLoop	LD	A,D
	CP	(IX+#03)
	JR	C,NewExt
	CP	(IX+#04)
	JR	NC,NewExt
	SUB	(IX+#03)
	DEC	A
	JP	M,NewUp
	CP	(IY+#01)
	JR	Z,NewLoop
	LD	A,#01
	JR	C,New0
	JR	New1+2
NewUp	LD	A,#01
New0	LD	B,A
	PUSH	BC
	CALL	MrkStrU
	POP	BC
	DJNZ	$-5
	LD	HL,(AdrPage)
	INC	HL
	BIT	6,(HL)
	JR	Z,NewLoop
	DEC	HL
	DEC	HL
	LD	A,(HL)
	OR	A
	JR	Z,NewExt
	JR	NewLoop
New1	NEG 
	LD	B,A
	PUSH	BC
	CALL	MrkStrD
	POP	BC
	DJNZ	$-5
	LD	HL,(BegString)
	INC	HL
	BIT	6,(HL)
	JR	Z,NewLoop
	LD	HL,(AdrPage)
	LD	B,(IY+#06)
	LD	D,#00
	LD	E,(HL)
	ADD	HL,DE
	DJNZ	$-2
	LD	A,(HL)
	OR	A
	JR	Z,NewExt
	JR	NewLoop
NewExt	LD	A,#04
	RST	#00
	RET 

SavePOS	DEFW	#0000
;[]===========================================================[]
LineUp	LD	HL,(AdrPage)
	DEC	HL
	LD	A,(HL)
	OR	A
	RET	Z
	CALL	SaveProec
	LD	C,(HL)
	INC	HL
	LD	B,#00
	SBC	HL,BC
	LD	(AdrPage),HL
	IN	A,(SLOT3)
	PUSH	AF
	LD	IX,TxtWtab
	LD	A,(IX+#21)	; Window page
	LD	(savepg1+1),A
	OUT	(SLOT3),A
	LD	L,(IX+#1F)
	LD	H,(IX+#20)
	LD	BC,#C002
	ADD	HL,BC
	LD	A,(IX+#02)
	SUB	(IX+#01)
	ADD	A,#02
	ADD	A,A
	LD	E,A
	LD	D,#00
	SUB	#08
	LD	(TmpLen1+1),A
	LD	A,(IY+#06)
	LD	B,A
	ADD	HL,DE
	DJNZ	$-1
	DEC	A
	PUSH	AF
	LD	C,E
	LD	E,L
	LD	D,H
	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
	POP	AF
LnUpLp1	EX	AF,AF'
	OR	A
	SBC	HL,BC
	LD	D,D
TmpLen1	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
	EX	DE,HL
	OR	A
	SBC	HL,BC
	EX	DE,HL
	EX	AF,AF'
	DEC	A
	JR	NZ,LnUpLp1
	EI 
	POP	AF
	OUT	(SLOT3),A
	LD	C,(IY+#02)
	LD	B,(IY-#04)
	PUSH	BC
	LD	IX,(AdrPage)
	LD	HL,ReCompBuff
	PUSH	HL
	PUSH	IX
	POP	DE
	INC	DE
	INC	DE
	CALL	ReCompile
	POP	IX
	LD	A,(IY+#07)
	ADD	A,A
	LD	LX,A
	JR	NC,$+4
	INC	HX
	LD	A,HX
	ADD	A,#80
	LD	HX,A
	IN	A,(SLOT3)
	PUSH	AF
savepg1	LD	A,#00		; Window page
	OUT	(SLOT3),A
	LD	D,(IY+#04)
	CALL	PutWinS
	POP	AF
	OUT	(SLOT3),A
	POP	BC
	LD	(IY-#04),B
	LD	(IY+#02),C
	LD	IX,TxtWtab
	CALL	ResCurs
	CALL	PrnTxtW	    ; Print window on screen
	LD	HL,(UpLinePg)
	DEC	HL
	LD	(UpLinePg),HL
	JP	LnDnLop
;[]===========================================================[]
LineDwn	LD	HL,(AdrPage)
	LD	B,(IY+#06)
	LD	D,#00
LnDwn0	LD	E,(HL)
	ADD	HL,DE
	LD	A,(HL)
	OR	A
	RET	Z
	DJNZ	LnDwn0
	LD	(svPGADR+2),HL
	CALL	SaveProec
	IN	A,(SLOT3)
	PUSH	AF
	LD	IX,TxtWtab
	LD	A,(IX+#21)	; Window page
	LD	(savepg2+1),A
	OUT	(SLOT3),A
	LD	L,(IX+#1F)
	LD	H,(IX+#20)
	LD	BC,#C002
	ADD	HL,BC
	LD	A,(IX+#02)
	SUB	(IX+#01)
	ADD	A,#02
	ADD	A,A
	LD	C,A
	LD	B,#00
	SUB	#08
	LD	(TmpLen2+1),A
	ADD	HL,BC
	LD	E,L
	LD	D,H
	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
	LD	A,(IY+#06)
	DEC	A
LnDnLp1	EX	AF,AF'
	ADD	HL,BC
	LD	D,D
TmpLen2	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
	EX	AF,AF'
	DEC	A
	JR	NZ,LnDnLp1
	EI 
	POP	AF
	OUT	(SLOT3),A
	LD	C,(IY+#02)
	LD	B,(IY-#04)
	PUSH	BC
svPGADR	LD	IX,#0000
	LD	HL,ReCompBuff
	PUSH	HL
	PUSH	IX
	POP	DE
	INC	DE
	INC	DE
	CALL	ReCompile
	POP	IX
	LD	A,(IY+#07)
	ADD	A,A
	LD	LX,A
	JR	NC,$+4
	INC	HX
	LD	A,HX
	ADD	A,#80
	LD	HX,A
	IN	A,(SLOT3)
	PUSH	AF
savepg2	LD	A,#00		; Window page
	OUT	(SLOT3),A
	LD	A,(IY+#04)
	ADD	A,(IY+#06)
	DEC	A
	LD	D,A
	CALL	PutWinS
	POP	AF
	OUT	(SLOT3),A
	POP	BC
	LD	(IY-#04),B
	LD	(IY+#02),C
	LD	IX,TxtWtab
	CALL	ResCurs
	CALL	PrnTxtW	    ; Print window on screen
	LD	HL,(AdrPage)
	LD	C,(HL)
	LD	B,#00
	ADD	HL,BC
	LD	(AdrPage),HL
	LD	HL,(UpLinePg)
	INC	HL
	LD	(UpLinePg),HL
LnDnLop	LD	BC,(CurLine)
	LD	A,L
	ADD	A,(IY+#06)
	LD	E,A
	LD	A,H
	ADC	A,#00
	LD	D,A
	OR	A
	EX	DE,HL
	SBC	HL,BC
	JR	Z,LnDnEx
	JR	C,LnDnEx
	ADD	HL,BC
	EX	DE,HL
	OR	A
	SBC	HL,BC
	JR	Z,LnDnCr
	JR	NC,LnDnEx
LnDnCr	LD	A,L
	NEG 
	LD	(IY+#01),A
	CALL	SetCurs
LnDnEx	CALL	PrnBars
	LD	B,#03
	LD	A,#03
	RST	#00
	RET	Z
	HALT 
	DJNZ	$-5
	RET 
;[]===========================================================[]
BarPageV
	LD	HL,(TmpVBarP)
	LD	A,D
	CP	H
	RET	Z
	JR	NC,NxtBrPg
;Prev page
	LD	HL,(AdrPage)
	DEC	HL
	LD	A,(HL)
	OR	A
	RET	Z	; Begin text
	INC	HL
	LD	A,(ReadyStr)	; Was not touched
	OR	A
	JR	NZ,PrBrPg1
	INC	A
	LD	(ReadyStr),A
	PUSH	HL
	CALL	OnlySyntax
	CALL	PutString
	POP	HL
PrBrPg1	CALL	SaveProec
	LD	IX,(UpLinePg)
	LD	B,(IY+#06)
	LD	D,#00
PrBrLp1	DEC	HL		; Search begin page
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,PrBrNx1
	LD	E,A
	SBC	HL,DE
	DEC	IX
	DJNZ	PrBrLp1
PrBrNx1	LD	(UpLinePg),IX
	LD	(AdrPage),HL
	JR	BarPgEx
;[]===========================================================[]
NxtBrPg	LD	A,(ReadyStr)	; Was not touched
	OR	A
	JR	NZ,NxBrPg0
	INC	A
	LD	(ReadyStr),A
	CALL	OnlySyntax
	CALL	PutString
NxBrPg0	LD	HL,(AdrPage)
	LD	B,(IY+#06)
	LD	D,#00
NxtBr1	LD	E,(HL)
	ADD	HL,DE
	LD	A,(HL)
	OR	A
	RET	Z	; End text
	DJNZ	NxtBr1
	CALL	SaveProec
	LD	(AdrPage),HL
	LD	HL,(UpLinePg)
	LD	A,(IY+#06)
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
	LD	(UpLinePg),HL
BarPgEx	LD	IX,TxtWtab
	LD	A,(IX+#21)	; Window page
	LD	(barp1+1),A
	LD	A,(IY+#02)
	LD	(barA1+3),A
	LD	A,(IY-#04)
	LD	(barA2+3),A
	LD	A,(IY+#00)
	LD	(barA3+3),A
	LD	(IY+#00),#FF
	LD	A,(IX+#04)
	SUB	(IX+#03)
	SUB	#02
	LD	B,A		; Count-in lines in
	LD	IX,(AdrPage)
	LD	C,#00
PrnBrPg	LD	A,(IX+#00)
	OR	A
	JR	Z,barA1
	PUSH	IX
	LD	D,HX
	LD	E,LX
	INC	DE
	INC	DE
	LD	HL,ReCompBuff
	PUSH	BC
	CALL	ReCompile
	POP	BC
	LD	A,C		;Y pos
	ADD	A,(IY+#04)
	LD	D,A
	LD	HX, high (ReCompBuff + NEW_ADDR*2)
	LD	A,(IY+#07)
	ADD	A,A
	LD	LX,A
	JR	NC,$+4
	INC	HX
	PUSH	BC
	IN	A,(SLOT3)
	PUSH	AF
barp1	LD	A,#00		; Window page
	OUT	(SLOT3),A
	CALL	PutWinS
	POP	AF
	OUT	(SLOT3),A
	POP	BC
	POP	IX
	LD	E,(IX+#00)
	LD	D,#00
	ADD	IX,DE
	INC	C
	DJNZ	PrnBrPg
barA1	LD	(IY+#02),#00
barA2	LD	(IY-#04),#00
barA3	LD	(IY+#00),#00
	LD	IX,TxtWtab
	LD	A,B
	OR	A
	JR	Z,PrnBrEx
;Clear down screen
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(IX+#21)
	OUT	(SLOT3),A
	LD	L,(IX+#1F)	; Address window place
	LD	H,(IX+#20)
	LD	DE,#C000	; Shift page
	ADD	HL,DE
PutEmpB	LD	A,C	;Ypos string
	PUSH	HL
	EXX 
	POP	HL
	LD	B,A
	LD	A,(IX+02)	;Xi
	SUB	(IX+#01)	; -xo=len x
	LD	C,A		;Save len wind
	ADD	A,#02		;+ shadow
	ADD	A,A		;+ atr
	LD	E,A
	LD	D,#00
	INC	B
	ADD	HL,DE
	DJNZ	$-1		; Hl=addres y line
	INC	HL		; Frame
	INC	HL
	DEC	C		; Frame
	DEC	C
	LD	B,C
	LD	A,(ColTxtWin)
	LD	C,A
	SUB	A
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	EXX 
	INC	C
	DJNZ	PutEmpB
	POP	AF
	OUT	(SLOT3),A
PrnBrEx	CALL	ResCurs
	CALL	PrnTxtW	    ; Print window on screen
	LD	HL,(UpLinePg)
	LD	BC,(CurLine)
	LD	A,L
	ADD	A,(IY+#06)
	LD	E,A
	LD	A,H
	ADC	A,#00
	LD	D,A
	OR	A
	EX	DE,HL
	SBC	HL,BC
	JR	Z,PgBrEx
	JR	C,PgBrEx
	ADD	HL,BC
	EX	DE,HL
	OR	A
	SBC	HL,BC
	JR	Z,PgBrCr
	JR	NC,PgBrEx
PgBrCr	LD	A,L
	NEG 
	LD	(IY+#01),A
	CALL	SetCurs
PgBrEx	CALL	PrnBars
	LD	B,#06
	LD	A,#03
	RST	#00
	RET	Z
	HALT 
	DJNZ	$-5
	RET 
 _mCollectInfo_addEnd