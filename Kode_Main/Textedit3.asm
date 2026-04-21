 _mCollectInfo_addStart
;[]===========================================================[]
LineLft:	LD	A,(IY+#07)
	OR	A
	RET	Z
	CALL	SaveProec
	DEC	(IY+#07)
	LD	A,(IY+#2A)	; Temp x pos
	ADD	A,(IY+#2B)	; Temp add x
	SUB	(IY+#07)
	JR	C,LineLRe
	LD	(IY+#00),A
LineLRe:	LD	A,(ReadyStr)	; Was not touched
	OR	A
	JP	NZ,BarPgEx
	INC	A
	LD	(ReadyStr),A
	CALL	OnlySyntax
	CALL	PutString
	JP	BarPgEx
;[]===========================================================[]
LineRgt:	LD	A,241
	SUB	(IY+#05)
	CP	(IY+#07)
	RET	Z
	CALL	SaveProec
	INC	(IY+#07)
	LD	A,(IY+#00)
	INC	A
	JR	Z,LineLRe
	DEC	(IY+#00)
	JR	LineLRe
;[]===========================================================[]
BarPageH:	LD	HL,(TmpHBarP)
	LD	A,E
	BIT	7,L
	JR	NZ,RgtBrPg
	CP	L
	RET	Z
	JR	NC,RgtBrPg
	LD	A,(IY+#07)
	OR	A
	RET	Z
	PUSH	AF
	CALL	SaveProec
	POP	AF
	SUB	(IY+#05)
	JR	NC,$+3
	SUB	A
	LD	(IY+#07),A
	LD	A,(IY+#2A)	; Temp x pos
	ADD	A,(IY+#2B)	; Temp add x
	SUB	(IY+#07)
	JR	C,LineLRe
	LD	(IY+#00),A
	CP	(IY+#05)
	JR	C,LineLRe
	LD	(IY+#00),#FF
	JR	LineLRe
;[]===========================================================[]
RgtBrPg:	LD	A,241
	SUB	(IY+#05)
	LD	L,A
	CP	(IY+#07)
	RET	Z
	CALL	SaveProec
	LD	A,(IY+#07)
	ADD	A,(IY+#05)
	JR	C,RgBrPg1
	CP	L
	JR	C,$+3
RgBrPg1:	LD	A,L
	LD	(IY+#07),A
	LD	A,(IY+#2A)	; Temp x pos
	ADD	A,(IY+#2B)	; Temp add x
	SUB	(IY+#07)
	JR	NC,$+4
	LD	A,#FF
	LD	(IY+#00),A
	JP	LineLRe
;[]===========================================================[]
DelLine:	LD	HL,(BegString)
	LD	DE,(EndText)
	LD	C,(HL)
	LD	B,#00
	ADD	HL,BC
	EX	DE,HL
	SBC	HL,DE
	JR	Z,LastLine
	LD	C,L
	LD	B,H
	EX	DE,HL
	LD	DE,(BegString)
	LDIR 
	SUB	A
	LD	(DE),A
	LD	(ReadyFile),A
	LD	(EndText),DE
	LD	HL,(EquipLn)
	DEC	HL
	LD	(EquipLn),HL
	JP	PageExt
LastLine:	LD	HL,(BegString)
	LD	A,(IY+#02)
	OR	A
	JR	NZ,$+6
	LD	A,(HL)
	CP	#03
	RET	Z
	SUB	A
	LD	(HL),#03
	INC	HL
	LD	(HL),#02
	INC	HL
	LD	(HL),#03
	INC	HL
	LD	(HL),A
	LD	(ReadyFile),A
	LD	(EndText),HL
	JP	PageExt
;[]===========================================================[]
PageLeft:	LD	A,(IY+#07)
	OR	A
	JP	Z,HomeStr
	SUB	(IY+#05)
	JR	NC,$+3
	SUB	A
	LD	(IY+#07),A
	LD	(IY-#02),A
	CALL	PageRLe
	JP	TestEnd
;[]===========================================================[]
PageRight:
	LD	A,(EditMode)
	OR	A
	JR	Z,PageRgt
	LD	A,(IY+#02)
	CP	#F0
	RET	NC
	LD	A,#F1
	SUB	(IY+#05)
	LD	B,A
	LD	A,(IY+#07)
	CP	B
	JR	NC,PageRg1
	ADD	A,(IY+#05)
	JR	C,PageRg0
	CP	B
	JR	C,$+3
PageRg0:	LD	A,B
	LD	(IY+#07),A
	LD	(IY-#02),A
	LD	A,(IY+#07)
	ADD	A,(IY+#00)
	JR	C,PageRg1
	CP	#F1
	JR	C,PageRg2
PageRg1:	LD	A,#F0
	SUB	(IY+#07)
	LD	(IY+#00),A
	LD	(IY-#01),A
PageRg2:	LD	A,(IY+#07)
	ADD	A,(IY+#00)
	LD	C,A
	SUB	(IY+#02)
	JR	C,PageRLe
	JR	Z,PageRLe
	LD	B,A
	LD	HL,TextBuff
	LD	E,(IY+#02)
	LD	(IY+#02),C
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
	JR	PageRLe
PageRgt:	LD	A,(IY+#02)
	SUB	(IY+#07)
	SUB	(IY+#05)
	JP	C,EndStr
	LD	A,#F1
	SUB	(IY+#05)
	LD	B,A
	LD	A,(IY+#07)
	ADD	A,(IY+#05)
	JR	C,PageRg3
	CP	B
	JR	C,$+3
PageRg3:	LD	A,B
	LD	(IY+#07),A
	LD	(IY-#02),A
	LD	A,(IY+#02)
	SUB	(IY+#07)
	CP	(IY+#00)
	JR	NC,PageRLe
	LD	(IY+#00),A
	LD	(IY-#01),A
PageRLe:	CALL	RefreshPage
	CALL	PrintInfo
	RET 
;[]===========================================================[]
BegMark:	CALL	ExmMark
	LD	HL,(BegString)
	LD	(MarkCeil),HL
	CALL	SetCurs
	RET 
;[]===========================================================[]
EndMark:	CALL	ExmMark
	LD	IX,(MarkCeil)
	LD	A,HX
	OR	LX
	RET	Z
	LD	HL,(MarkCeil)
	LD	DE,(BegString)
	OR	A
	SBC	HL,DE
	RET	NC
	LD	HL,(EquipMr)
	LD	B,#00
EndMr1:	SET	6,(IX+#01)
	INC	HL
	LD	A,E
	CP	LX
	JR	NZ,EndM11
	LD	A,D
	CP	HX
	JR	Z,EndMr2
EndM11:	LD	C,(IX+#00)
	ADD	IX,BC
	JR	EndMr1
EndMr2:	LD	(EquipMr),HL
	CALL	PrintPage
	CALL	SetCurs
	LD	HL,MarkGrp
	CALL	OpenGroup
	RET 
;[]===========================================================[]
BegTEXT:	LD	HL,(AdrPage)
	DEC	HL
	LD	A,(HL)
	OR	A
	JR	NZ,BegTXT0	; Begin text
	LD	A,(IY+#01)
	OR	A
	RET	Z
BegTXT0:	LD	A,(ReadyStr)	; Was not touched
	OR	A
	JR	NZ,BegTXT1
	INC	A
	LD	(ReadyStr),A
	CALL	OnlySyntax
	CALL	PutString
	BIT	4,(IY+#08)
	JR	Z,BegTXT1
	CALL	NotComm
	CALL	PrintS
BegTXT1:	LD	HL,#0000
	LD	(CurLine),HL
	LD	(UpLinePg),HL
	LD	HL,#8040
	LD	(AdrPage),HL
	LD	(BegString),HL
	LD	(IY+#01),#00
	JP	PageExt

EndTEXT:	LD	HL,(AdrPage)
	LD	B,(IY+#06)
	LD	D,#00
EndTXT0:	LD	E,(HL)
	ADD	HL,DE
	LD	A,(HL)
	OR	A
	JR	Z,EndTXTn      ; End text
	DJNZ	EndTXT0
	LD	A,(ReadyStr)	; Was not touched
	OR	A
	JR	NZ,EndTXT1
	INC	A
	LD	(ReadyStr),A
	CALL	OnlySyntax
	CALL	PutString
	BIT	4,(IY+#08)
	JR	Z,EndTXT1
	CALL	NotComm
	CALL	PrintS
EndTXT1:	LD	IX,(EquipLn)
	LD	HL,(EndText)
	LD	B,(IY+#06)
	LD	D,#00
EndTXT2:	DEC	HL
	LD	E,(HL)
	INC	HL
	OR	A
	SBC	HL,DE
	DEC	IX
	DJNZ	EndTXT2
	LD	(UpLinePg),IX
	LD	(AdrPage),HL
	LD	A,(IY+#06)
	DEC	A
	LD	(IY+#01),A
EndTXTe:	LD	HL,(EndText)
	DEC	HL
	LD	E,(HL)
	INC	HL
	LD	D,#00
	OR	A
	SBC	HL,DE
	LD	(BegString),HL
	LD	HL,(EquipLn)
	DEC	HL
	LD	(CurLine),HL
	JP	PageExt
EndTXTn:	LD	A,(IY+#06)
	SUB	B
	CP	(IY+#01)
	RET	Z
	LD	(IY+#01),A
	LD	A,(ReadyStr)	; Was not touched
	OR	A
	JR	NZ,EndTXTe
	INC	A
	LD	(ReadyStr),A
	CALL	OnlySyntax
	CALL	PutString
	BIT	4,(IY+#08)
	JR	Z,EndTXTe
	CALL	NotComm
	CALL	PrintS
	JR	EndTXTe
;[]===========================================================[]
PrintPage:
	LD	A,#01
	LD	(SynRenderPass),A
	CALL	SynDetectLang
	LD	(SynLang),A
	LD	(SynRenderLang),A
	LD	A,#01
	LD	(SynRenderLangValid),A
	CALL	SynSeedBlockFromTop
	LD	IX,TxtWtab
	LD	A,(IX+#21)	; Window page
	LD	(Page1+1),A
	LD	A,(IX+#04)
	SUB	(IX+#03)
	SUB	#02
	LD	B,A
	LD	C,#00
	LD	IX,(AdrPage)
	LD	DE,(UpLinePg)
PrnPage:	LD	A,(IX+#00)
	OR	A
	JR	Z,PrPageE
	PUSH	DE
	PUSH	IX
	LD	HL,(CurLine)
	OR	A
	SBC	HL,DE
	PUSH	AF
	LD	HL,ReCompBuff
	JR	NZ,PrPage1
	LD	(BegString),IX
	LD	HL,TextBuff
PrPage1:	LD	E,LX
	LD	D,HX
	INC	DE
	INC	DE
	PUSH	HL
	PUSH	BC
	CALL	ReCompile
	POP	BC
	POP	HL
	POP	AF
	JR	NZ,PrPage2
	LD	A,(IY+#02)
	LD	(regA1+3),A
	LD	A,(IY-#04)
	LD	(regA2+3),A
PrPage2:	PUSH	BC
	PUSH	HL
	CALL	SyntaxExtLine
	POP	HL
	POP	BC
	LD	A,C		;Y pos
	ADD	A,(IY+#04)
	LD	D,A
	LD	A,H
	ADD	A,#80
	LD	HX,A
	LD	A,(IY+#07)
	ADD	A,A
	LD	LX,A
	JR	NC,$+4
	INC	HX
	PUSH	BC
	IN	A,(SLOT3)
	PUSH	AF
Page1:	LD	A,#00		; Window page
	OUT	(SLOT3),A
	CALL	PutWinS
	POP	AF
	OUT	(SLOT3),A
	POP	BC
	POP	IX
	LD	E,(IX+#00)
	LD	D,#00
	ADD	IX,DE
	POP	DE
	INC	DE
	INC	C
	DJNZ	PrnPage
PrPageE:	LD	IX,TxtWtab
	LD	A,B
	OR	A
	JR	Z,PrnPgEx
;Clear down screen
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(IX+#21)
	OUT	(SLOT3),A
	LD	L,(IX+#1F)	; Address window place
	LD	H,(IX+#20)
	LD	A,H		; Shift page
	ADD	A,#C0
	LD	H,A
PutEmpS:	LD	A,C	;Ypos string
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
	DJNZ	PutEmpS
	POP	AF
	OUT	(SLOT3),A
PrnPgEx:	CALL	ResCurs
	CALL	PrnTxtW	    ; Print window on screen
	CALL	SetCurs
regA1:	LD	(IY+#02),#00
regA2:	LD	(IY-#04),#00
	XOR	A
	LD	(SynRenderPass),A
	LD	(SynRenderLangValid),A
	RET
;[]===========================================================[]
RefreshPage:
	LD	A,#01
	LD	(SynRenderPass),A
	CALL	SynDetectLang
	LD	(SynLang),A
	LD	(SynRenderLang),A
	LD	A,#01
	LD	(SynRenderLangValid),A
	CALL	SynSeedBlockFromTop
	LD	IX,TxtWtab
	LD	A,(IX+#21)	; Window page
	LD	(Page2+1),A
	LD	A,(IY+#02)
	LD	(refA1+3),A
	LD	A,(IY-#04)
	LD	(refA2+3),A
	LD	A,(IY+#00)
	LD	(refA3+3),A
	LD	(IY+#00),#FF
	LD	A,(IX+#04)
	SUB	(IX+#03)
	SUB	#02
	LD	B,A
	LD	C,#00
	LD	IX,(AdrPage)
RefPage:	LD	A,(IX+#00)
	OR	A
	JR	Z,RefPgE
	PUSH	IX
	LD	HL,TextBuff
	LD	A,C
	CP	(IY+#01)
	JR	Z,RefPg1
	LD	HL,ReCompBuff
	LD	E,LX
	LD	D,HX
	INC	DE
	INC	DE
	PUSH	HL
	PUSH	BC
	CALL	ReCompile
	POP	BC
	POP	HL
RefPg1:	PUSH	BC
	PUSH	HL
	CALL	SyntaxExtLine
	POP	HL
	POP	BC
	LD	A,C		;Y pos
	ADD	A,(IY+#04)
	LD	D,A
	LD	A,H
	ADD	A,#80
	LD	HX,A
	LD	A,(IY+#07)
	ADD	A,A
	LD	LX,A
	JR	NC,$+4
	INC	HX
	PUSH	BC
	IN	A,(SLOT3)
	PUSH	AF
Page2:	LD	A,#00		; Window page
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
	DJNZ	RefPage
RefPgE:	LD	IX,TxtWtab
refA1:	LD	(IY+#02),#00
refA2:	LD	(IY-#04),#00
refA3:	LD	(IY+#00),#00
	LD	A,(IY+#05)	; Max len x
	ADD	A,(IY+#07)
	SUB	(IY+#02)
	JR	C,refrEX
	INC	A
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
refrEX:	CALL	ResCurs
	CALL	PrnTxtW	    ; Print window on screen
	CALL	SetCurs
	XOR	A
	LD	(SynRenderPass),A
	LD	(SynRenderLangValid),A
	RET 
;[]===========================================================[]
PrintInfo:
	SUB	A
	LD	(ProecFlg),A
	LD	IX,TxtWtab
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(IX+#21)
	OUT	(SLOT3),A
	LD	A,(IX+#02)
	SUB	(IX+#01)
	ADD	A,#02
	ADD	A,A
	LD	E,A
	LD	D,#00
	LD	A,(IX+#04)
	SUB	(IX+#03)
	DEC	A
	LD	B,A
	LD	L,(IX+#1F)
	LD	H,(IX+#20)
	LD	A,H
	ADD	A,#C0
	LD	H,A
	ADD	HL,DE
	DJNZ	$-1
	INC	HL
	INC	HL
	PUSH	HL
	CALL	PutInfo
	POP	IX
	LD	A,(IY+#04)
	ADD	A,(IY+#06)
	LD	D,A
	LD	E,(IY+#03)
	LD	HL,#0112
	CALL	ExStrPs
	LD	A,L
	OR	A
	JR	Z,PrnIext
	LD	A,D
	CP	#1F
	JR	NC,PrnIext
	IN	A,(SLOT3)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
PrnIext:	POP	AF
	OUT	(SLOT3),A
; Procedure and printing SCROLLBAR in window and on screen
; On: None
PrnBars:	LD	IX,TxtWtab
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(IX+#21)
	OUT	(SLOT3),A
	LD	HL,(UpLinePg)
	PUSH	HL
	LD	C,(IY+#06)
	LD	B,#00
	ADD	HL,BC
	EX	DE,HL
	LD	HL,(EquipLn)
	SBC	HL,DE
	POP	DE
	JR	NC,PrnBr1
	LD	HL,(EquipLn)
	OR	A
	SBC	HL,BC
	EX	DE,HL
	JR	NC,PrnBr1
	LD	DE,#0000
PrnBr1:	LD	A,(IX+#12)
	SUB	(IX+#11)
	DEC	A
	LD	C,A
	CALL	Mult16X8	; Curline*lenscrollbar=a24
	EX	DE,HL
	LD	HL,(EquipLn)	; A24/equipln
	LD	C,(IY+#06)
	LD	B,#00
	OR	A
	SBC	HL,BC
	JR	NC,$+5
	LD	HL,(EquipLn)
	EX	DE,HL
	LD	C,L
	LD	L,H
	LD	H,A
	CALL	Divis24X16
	ADD	A,(IX+#11)
	LD	D,A
	LD	E,(IX+#10)
	LD	HL,(TmpVBarP)
	OR	A
	SBC	HL,DE
	JR	Z,PrntHor
	PUSH	DE
	LD	L,(IX+#1F)
	LD	H,(IX+#20)
	LD	A,H
	ADD	A,#C0
	LD	H,A
	LD	A,D
	SUB	(IX+#03)
	LD	B,A
	LD	DE,(TmpVBarA)
	LD	A,#B1
	LD	(DE),A
	LD	A,(IX+#02)
	SUB	(IX+#01)
	ADD	A,#02
	ADD	A,A
	LD	E,A
	LD	D,#00
	ADD	HL,DE
	DJNZ	$-1
	ADD	HL,DE
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	LD	(HL),#FE
	LD	(TmpVBarA),HL
	LD	DE,(TmpVBarP)
	LD	A,D
	CP	#1F
	JR	NC,VrtN
	LD	A,E
	CP	#50
	JR	NC,VrtN
	LD	A,(ColScrlBar)
	LD	H,A
	LD	L,#B1
	LD	BC,#1BB5
	SUB	A
	RST	#10
VrtN:	POP	DE
	LD	(TmpVBarP),DE
	LD	A,D
	CP	#1F
	JR	NC,VrtN1
	LD	A,E
	CP	#50
	JR	NC,VrtN1
	LD	A,(ColScrlBar)
	LD	H,A
	LD	L,#FE
	LD	BC,#1BB5
	SUB	A
	RST	#10
VrtN1:							; ?????
; Put horizontal bar
PrntHor:	LD	A,240
	SUB	(IY+#05)	;Max len string
	LD	E,(IY+#07)	; Add x
	PUSH	AF
	CP	E
	JR	NC,$+3
	LD	E,A
	LD	A,(IX+#18)	; Len horizontal bar
	SUB	(IX+#17)
	DEC	A
	LD	C,A
	CALL	Mult8X8		; Curline*lenscrollbar=a16
	POP	AF
	LD	C,A		; Max addx
	CALL	Divis16X8
	LD	A,(IX+#17)
	ADD	A,L		; Offset from start
	LD	E,A
	SUB	(IX+#01)
	EX	AF,AF'
	LD	D,(IX+#19)
	LD	HL,(TmpHBarP)
	OR	A
	SBC	HL,DE
	JR	Z,HorE
	PUSH	DE
	LD	L,(IX+#1F)
	LD	H,(IX+#20)
	LD	A,H
	ADD	A,#C0
	LD	H,A
	LD	A,D
	SUB	(IX+#03)
	LD	B,A
	LD	DE,(TmpHBarA)
	LD	A,#B1
	LD	(DE),A
	LD	A,(IX+#02)
	SUB	(IX+#01)
	ADD	A,#02
	ADD	A,A
	LD	E,A
	LD	D,#00
	ADD	HL,DE
	DJNZ	$-1
	EX	AF,AF'
	ADD	A,A
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
	LD	(HL),#FE
	LD	(TmpHBarA),HL
	LD	DE,(TmpHBarP)
	LD	A,D
	CP	#1F
	JR	NC,HorN
	LD	A,E
	CP	#50
	JR	NC,HorN
	LD	A,(ColScrlBar)
	LD	H,A
	LD	L,#B1
	LD	BC,#1BB5
	SUB	A
	RST	#10
HorN:	POP	DE
	LD	(TmpHBarP),DE
	LD	A,D
	CP	#1F
	JR	NC,HorE
	LD	A,E
	CP	#50
	JR	NC,HorE
	LD	A,(ColScrlBar)
	LD	H,A
	LD	L,#FE
	LD	BC,#1BB5
	SUB	A
	RST	#10
HorE:	POP	AF
	OUT	(SLOT3),A
	RET 
; Procedure (32bit)
; On: DE+HL*BC
; On exit:HL+IX
Mult32:	LD	IX,#0000
	LD	A,#20
mul32b:	ADD	IX,IX
	ADC	HL,HL
	RL	E
	RL	D
	JR	NC,noadd
	ADD	IX,BC
	JR	NC,noadd
	INC	HL
noadd:	DEC	A
	JR	NZ,mul32b
	RET 
; Procedure (16*8bit)
; On: DE*C
; On exit:A+HL
Mult16X8:	SUB	A
	LD	L,A
	LD	H,A
	CP	C
	RET	Z
	OR	D
	OR	E
	RET	Z
	LD	A,C
	LD	C,#00
	LD	B,#08
Mlt16x8:	ADD	HL,HL
	RLA 
	JR	NC,$+4
	ADD	HL,DE
	ADC	A,C
	DJNZ	Mlt16x8
	RET 
; Procedure (8*8bit)
; On: E*C
; On exit:HL
Mult8X8:	SUB	A
	LD	L,A
	LD	H,A
	LD	D,A
	CP	C
	RET	Z
	CP	E
	RET	Z
	LD	H,C
	LD	B,#08
Mlt8x8:	ADD	HL,HL
	JR	NC,$+3
	ADD	HL,DE
	DJNZ	Mlt8x8
	RET 
; Procedure (32bit)
; On: HL+DE/BC
; On exit:DE
; HL
Divis32:	LD	A,B
	OR	C
	RET	Z
	EX	DE,HL
	LD	HL,#0000
	LD	A,#20
div32b1:	ADD	IX,IX
	EX	DE,HL
	ADC	HL,HL
	EX	DE,HL
	ADC	HL,HL
	SBC	HL,BC
	JR	NC,div32b2
	ADD	HL,BC
	DEC	A
	JR	NZ,div32b1
	RET 
div32b2:	INC	IX
	DEC	A
	JR	NZ,div32b1
	RET 
; Procedure (24x16bit)
; On: H+L+C/DE
; On exit:A
; HL
Divis24X16:
	LD	A,D
	CPL 
	LD	D,A
	LD	A,E
	CPL 
	LD	E,A
	INC	DE
	LD	A,C
	LD	B,#08
Div2416:	ADD	HL,HL
	JR	C,Dv2416n
	ADD	A,A
	JR	NC,$+3
	INC	HL
	PUSH	HL
	ADD	HL,DE
	JR	NC,$+4
	EX	(SP),HL
	INC	A
	POP	HL
	DJNZ	Div2416
	RET 
Dv2416n:	ADC	A,A
	JR	NC,$+3
	INC	HL
	ADD	HL,DE
	DJNZ	Div2416
	RET 
; Procedure (16bit)
; On: BC/DE
; On exit:BC
; HL
Divis16:	LD	A,D
	OR	E
	RET	Z
	LD	HL,#0000
	LD	A,B
	LD	B,#10
Btrial1:	RL	C
	RLA 
	ADC	HL,HL
	SBC	HL,DE
	CCF 
	JR	NC,Bngv1
Bptv1:	DJNZ	Btrial1
	RL	C
	RLA 
	LD	B,A
	RET 
Brestr1:	RL	C
	RLA 
	ADC	HL,HL
	ADD	HL,DE
	JR	C,Bptv1
Bngv1:	DJNZ	Brestr1
	RL	C
	RLA 
	ADD	HL,DE
	LD	B,A
	RET 
; (16X8bit)
; On: HL/C
; On exit:L
; H
Divis16X8:
	LD	B,#08
Div16X8:	ADD	HL,HL
	LD	A,H
	JR	C,Div1
	SUB	C
	JR	NC,Div2
	ADD	A,C
	LD	H,A
	DJNZ	Div16X8
	RET 
Div1:	SUB	C
Div2:	LD	H,A
	INC	HL
	DJNZ	Div16X8
	RET 
; Info. editor in window
; On HL- line window
PutInfo:	LD	A,(HL)
	LD	(CurFram),A
	INC	HL
	INC	HL
	BIT	0,(IY+#17)	;Ready file
	JR	NZ,$+4
	LD	A,"*"
	LD	(HL),A
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	PUSH	HL
	EX	DE,HL
	EXX 
	LD	C,#00
	EXX 
	LD	HL,(CurLine)
	INC	HL
	LD	BC,10000
	CALL	GetNm16
	LD	BC,1000
	CALL	GetNm16
	LD	BC,100
	CALL	GetNm16
	LD	BC,10
	CALL	GetNm16
	LD	A,L
	ADD	A,#30
	LD	(DE),A
	INC	DE
	INC	DE
	LD	A,":"
	LD	(DE),A
	INC	DE
	INC	DE
	EX	DE,HL
	LD	A,(IY+#00)
	ADD	A,(IY+#07)
	INC	A
	LD	D,A
	LD	C,#00
	LD	E,100
	CALL	GetNum8
	LD	E,10
	CALL	GetNum8
	LD	A,D
	ADD	A,#30
	LD	(HL),A
	INC	HL
	INC	HL
	LD	A,(CurFram)
PrInfLp:	BIT	7,(HL)
	JR	NZ,PutFree
	LD	(HL),A
	INC	HL
	INC	HL
	JR	PrInfLp
PutFree:	POP	HL
	LD	DE,#0016
	ADD	HL,DE
	EX	DE,HL
	LD	HL,#FFFF  ; End text page
	LD	BC,(EndText)
	OR	A
	SBC	HL,BC
	CALL	GetHexN
	RET 

CurFram:	DEFB	#00

GetNm16:	LD	A,#2F
	INC	A
	SBC	HL,BC
	JR	NC,$-3
	ADD	HL,BC
	CP	#30
	EXX 
	JR	Z,$+4
	SET	0,C
	BIT	0,C
	EXX 
	JR	NZ,$+5
	LD	A,(CurFram)
	LD	(DE),A
	INC	DE
	INC	DE
	RET 
GetNum8:	LD	B,#2F
	LD	A,D
	INC	B
	SUB	E
	JR	NC,$-2
	ADD	A,E
	LD	D,A
	LD	A,B
	CP	"0"
	JR	Z,$+4
	SET	0,C
	BIT	0,C
	RET	Z
	LD	(HL),A
	INC	HL
	INC	HL
	RET 

GetHexN:	LD	A,H
	CALL	GetHex
	LD	A,L
GetHex:	PUSH	AF
	RRCA 
	RRCA 
	RRCA 
	RRCA 
	CALL	GetHex1
	POP	AF
GetHex1:	AND	#0F
	ADD	A,#90
	DAA 
	ADC	A,#40
	DAA 
	LD	(DE),A
	INC	DE
	INC	DE
	RET 
;[]===========================================================[]
PutString:
	LD	HL,#0000
	LD	(MarkCeil),HL
	CALL	CompileStr
PutStr1:	LD	IX,TxtWtab
	LD	A,(IX+#1D)
	OUT	(SLOT2),A
	LD	A,(IX+#1E)
	OUT	(SLOT3),A
	LD	HL,(BegString)
	LD	A,(CompBuff)
	CP	(HL)
	CALL	NZ,NewLen
	LD	DE,CompBuff
	EX	DE,HL
	LD	C,(HL)
	LD	B,L
	LDIR 
	EX	DE,HL
	RET 
NewLen:	JR	NC,AddStrLen
	PUSH	HL
	LD	C,A
	LD	B,#00
	PUSH	HL
	ADD	HL,BC
	LD	E,L
	LD	D,H
	POP	HL
	LD	C,(HL)
	ADD	HL,BC
	PUSH	HL
	LD	C,L
	LD	B,H
	LD	HL,(EndText)
	SBC	HL,BC
	LD	C,L
	LD	B,H
	POP	HL
	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
	LD	A,B
	OR	A
	JR	Z,NL1
NL0:	LD	D,D
	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
	INC	H
	INC	D
	DEC	B
	JR	NZ,NL0
NL1:	LD	A,C
	OR	A
	JR	Z,NL2
	LD	(NLlen1+1),A
	LD	D,D
NLlen1:	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
	LD	A,C
	ADD	A,E
	LD	E,A
	JR	NC,NL2
	INC	D
NL2:	EI 
	LD	(EndText),DE
	SUB	A
	LD	(DE),A
	POP	HL
	RET 
AddStrLen:
	PUSH	HL
	SUB	(HL)
	LD	C,A
	LD	B,#00
	LD	E,(HL)
	LD	D,B
	ADD	HL,DE
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
	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
	LD	A,B
	OR	A
	JR	Z,NL12
NL02:	DEC	H
	DEC	D
	LD	D,D
	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
	DEC	B
	JR	NZ,NL02
NL12:	LD	A,C
	OR	A
	JR	Z,NL22
	LD	(NLlen2+1),A
	LD	B,#00
	SBC	HL,BC
	EX	DE,HL
	SBC	HL,BC
	EX	DE,HL
	LD	D,D
NLlen2:	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
NL22:	EI 
	POP	HL
	RET 
OverText:
	LD	HL,Dnotxtsp
	CALL	DialogW
	LD	HL,what
	LD	(HL),evNothing
	SUB	A
	LD	(IY+#00),A
	LD	(IY-#01),A
	LD	(IY+#07),A
	LD	(IY-#02),A
	LD	HL,#8040
	LD	BC,(UpLinePg)
	LD	D,#00
	LD	A,B
	OR	C
	JR	Z,OverT1
OverT0:	LD	E,(HL)
	ADD	HL,DE
	LD	A,B
	OR	C
	JR	Z,OverT0
OverT1:	LD	(AdrPage),HL
	LD	A,(IY+#01)
	OR	A
	JR	Z,OverT2
	LD	B,A
	LD	E,(HL)
	ADD	HL,DE
	DJNZ	$-2
OverT2:	LD	(BegString),HL
	CALL	PrintPage
	CALL	SelcWin
	LD	SP,#7FFF
	JP	MainCyc
;[]===========================================================[]
exProec:	LD	A,(ProecFlg)
	OR	A
	RET	Z
	SUB	A
	LD	(ProecFlg),A
	LD	A,(CurFlag)
	OR	A
	RET	NZ
	PUSH	HL
	EX	AF,AF'
	PUSH	AF
	LD	HL,(Tadrpg)
	LD	(AdrPage),HL
	LD	HL,(Tupline)
	LD	(UpLinePg),HL
	LD	A,(Typos)
	LD	(IY+#01),A
	LD	A,(Txpos)
	LD	(IY+#00),A
	LD	A,(Taddx)
	LD	(IY+#07),A
	CALL	PrintPage
	CALL	PrintInfo
	POP	AF
	EX	AF,AF'
	POP	HL
	RET 
SaveProec:
	LD	A,(ProecFlg)
	OR	A
	RET	NZ
	PUSH	HL
	LD	HL,(AdrPage)
	LD	(Tadrpg),HL
	LD	HL,(UpLinePg)
	LD	(Tupline),HL
	LD	A,(IY+#01)
	LD	(Typos),A
	LD	A,(IY+#00)
	LD	(Txpos),A
	LD	A,(IY+#07)
	LD	(Taddx),A
	LD	A,#01
	LD	(ProecFlg),A
	POP	HL
	RET 

; Kode syntax routine
Syntax:	CALL	SyntaxExtTry
	JP	PrintS

OnlySyntax:
	JP	SyntaxExtTry

BegTabl:		DEFW	#0000
BegAtbl:		DEFW	#0000
BegComm:		DEFW	#0000
BegArgm:		DEFW	#0000
TmpColL:		DEFB	#00
TmpColM:		DEFB	#00
TmpColW:		DEFB	#00
TmpColC:		DEFB	#00
TmpColB:		DEFB	#00
CSLabel:		DEFB	#1E
CSMnemon:		DEFB	#1F
CSComment:	DEFB	#1D
CSBrace:	DEFB	#1B

PrintS:	CALL	ResCurs
	IN	A,(SLOT3)
	PUSH	AF
	LD	IX,TxtWtab
	LD	A,(IX+#21)	; Window page
	OUT	(SLOT3),A
	LD	B,(IX+#04)	;Yi window
	LD	A,(IY+#01)
	ADD	A,(IY+#04)
	LD	D,A		;Y pos
	LD	E,(IY+#03)	;X pos
	LD	HX, high (TextBuff + NEW_ADDR*2)
	LD	A,(IY+#07)
	ADD	A,A
	LD	LX,A
	JR	NC,$+4
	INC	HX
	LD	L,(IY+#05)
	LD	H,#01
	PUSH	IX
	PUSH	DE
	CALL	ExStrPs
	LD	A,L
	OR	A
	JR	Z,PrnSext
	LD	A,D
	CP	#1F
	JR	NC,PrnSext
	INC	A
	CP	B
	JR	NC,PrnSext
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	POP	DE
	POP	IX
	CALL	PutWinS
	CALL	SetCurs
	POP	AF
	OUT	(SLOT3),A
	RET 
PrnSext:	POP	DE
	POP	IX
	CALL	SetCurs
	POP	AF
	OUT	(SLOT3),A
	RET 
; Procedure write in window
PutWinS:	LD	A,D	;Ypos string
	SUB	(IY+#04)
	EXX 
	LD	B,A
	PUSH	IX
	LD	IX,TxtWtab
	LD	L,(IX+#1F)	; Address window place
	LD	H,(IX+#20)
	LD	DE,#C000	; Shift page
	ADD	HL,DE
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
	POP	IX
	LD	A,HX
	SUB	#80
	LD	D,A
	LD	E,LX
	EX	DE,HL
	DEC	C		; Frame
	DEC	C
	SLA	C
	LDIR 
	EXX 
	RET 
; Check
ExStrPs:	BIT	7,E		;Xo pos
	JR	Z,ExStrNx	; Start window for screen
	PUSH	BC
	LD	A,E
	NEG		; In and-on how many window for screen
	LD	C,A
	SUB	L	; Window=-visible part
	NEG 
	BIT	7,A
	JR	Z,$+3
	SUB	A
	LD	L,A	; Visible part
	LD	E,#00
	SLA	C
	LD	B,E
	ADD	IX,BC	; Line
	POP	BC
	RET 
ExStrNx:	LD	A,E
	ADD	A,L		; +len x
	CP	#50		; Test by out for x pos
	RET	C		; Window for screen
	LD	A,#50
	SUB	E
	LD	L,A
	RET 

CompileStr:
	LD	IX,CompBuff
	LD	A,#02
	LD	HL,(BegString)
	INC	HL
	LD	B,(HL)
	LD	A,B
	AND	#40		; preserve mark bit
	OR	#02
	LD	(IX+#01),A

	LD	HL,TextBuff
	LD	DE,CompBuff+2
	LD	A,(IY+#02)
	LD	B,A
CmpStrLp:
	LD	A,B
	OR	A
	JR	Z,CmpStrEnd
	LD	A,(HL)
	LD	(DE),A
	INC	DE
	INC	HL
	INC	HL
	DEC	B
	JR	CmpStrLp
CmpStrEnd:
	LD	A,(IY+#02)
	ADD	A,#03
	LD	(IX+#00),A
	LD	(DE),A
	RET 

ReCompile:
	PUSH	HL
	POP	DE
	LD	A,(ColTxtWin)
	LD	(ReCmpFillCol+1),A
	BIT	6,(IX+#01)
	JR	Z,ReCmpCol0
	LD	A,(ColSelTxt)
ReCmpCol0:
	LD	(ReCmpCol+1),A
	LD	A,(IX+#00)
	CP	#03
	JR	NC,ReCmpA0
	LD	A,#03
ReCmpA0:
	SUB	#03
	LD	B,A
	LD	C,A
	PUSH	IX
	POP	HL
	INC	HL
	INC	HL
ReCmpALp:
	LD	A,B
	OR	A
	JR	Z,ReCmpAEnd
	LD	A,(HL)
	LD	(DE),A
	INC	DE
ReCmpCol	LD	A,#00
	LD	(DE),A
	INC	DE
	INC	HL
	DEC	B
	JR	ReCmpALp
ReCmpAEnd:
	XOR	A
	LD	(DE),A
	INC	DE
	LD	A,(ReCmpFillCol+1)
	LD	(DE),A
	INC	DE
	LD	A,#F1
	SUB	C
	RET	Z
	LD	B,A
ReCmpFill:
	XOR	A
	LD	(DE),A
	INC	DE
ReCmpFillCol:
	LD	A,#00
	LD	(DE),A
	INC	DE
	DJNZ	ReCmpFill
	RET

ReCompileStr:
	LD	IX,(BegString)
	LD	HL,TextBuff
	CALL	ReCompile
	LD	A,(IX+#00)
	CP	#03
	JR	NC,ReCmpS0
	XOR	A
	LD	(IY+#02),A
	RET
ReCmpS0:
	SUB	#03
	LD	(IY+#02),A
	RET

;
 _mCollectInfo_addEnd
