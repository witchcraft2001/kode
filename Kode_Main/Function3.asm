 _mCollectInfo_addStart
;[]===========================================================[]
; Procedure windows
Cascade:
	SUB	A
	LD	(WinPutMode),A
	CALL	OnlySyntax	; Syntax-highlight last line
	CALL	PutString	; Insert it in text
	CALL	ResCurs
	LD	HL,FreeWin
	SUB	A
	LD	B,#0F
	BIT	7,(HL)	; Count count-in open windows
	INC	HL
	JR	Z,$+3
	INC	A
	DJNZ	$-6
	LD	IX,TxtWtab	; Table window descriptors
	LD	DE,#0026
	ADD	IX,DE
	BIT	7,(IX+#00)  ; Search same window
	JR	Z,$-6
	LD	HL,#0100
	LD	DE,-#0026   ; Refresh window down by table
	PUSH	IX
	LD	B,A
Casc2:
	ADD	IX,DE
	LD	(IX+#01),L
	LD	(IX+#02),#50
	LD	(IX+#03),H
	LD	(IX+#04),#1F
	LD	A,(IX+#1D)
	OUT	(SLOT2),A
	LD	A,(IX+#1E)
	OUT	(SLOT3),A
	CALL	InsWatr
	INC	L
	INC	H
	DJNZ	Casc2
	POP	IX
	CALL	NewDisplay
	CALL	SetCurs
	RET 
;[]===========================================================[]
; Procedure windows
Tile:
	LD	A,#01
	LD	(WinPutMode),A
	CALL	OnlySyntax	; Syntax-highlight last line
	CALL	PutString	; Insert it in text
	CALL	ResCurs
	LD	HL,FreeWin
	SUB	A
	LD	B,#0F
	BIT	7,(HL)	; Count count-in open windows
	INC	HL
	JR	Z,$+3
	INC	A
	DJNZ	$-6
	LD	HL,TileTab
	LD	DE,#0000
	LD	B,A
	ADD	HL,DE
	INC	DE
	INC	DE
	INC	DE
	INC	DE
	DJNZ	$-5
	LD	IX,TxtWtab	; Table window descriptors
	LD	DE,#0026
	ADD	IX,DE
	BIT	7,(IX+#00)  ; Search same window
	JR	Z,$-6
	LD	DE,-#0026   ; Refresh window down by table
	LD	B,A
	PUSH	IX
Tile2:
	ADD	IX,DE
	LD	A,(HL)		;Ypos
	INC	HL
	INC	A
	LD	(IX+#03),A
	LD	A,(HL)		;Xpos
	INC	HL
	LD	(IX+#01),A
	LD	A,(HL)		;Ylen
	INC	HL
	ADD	A,(IX+#03)
	LD	(IX+#04),A
	LD	A,(HL)		;Xlen
	INC	HL
	ADD	A,(IX+#01)
	LD	(IX+#02),A
	LD	A,(IX+#1D)
	OUT	(SLOT2),A
	LD	A,(IX+#1E)
	OUT	(SLOT3),A
	CALL	InsWatr
	DJNZ	Tile2
	POP	IX
	CALL	NewDisplay
	CALL	SetCurs
	RET 
; Procedure in buffer working
NewDisplay:
	LD	A,(BuffPg4)
	OUT	(SLOT3),A		; Enable
; In buffer
	LD	HL,WinBoxBuff+5100  ; Place
	LD	E,L
	LD	D,H
	LD	B,#80
	LD	C,#B0
	LD	A,(ColDeskTop)	; Color DeskTop
	LD	(HL),C		; Byte DeskTop
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-4
	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
	LD	B,#13
	LD	D,D
	LD	A,#00
	LD	L,L
	LD	A,(DE)
	LD	(HL),A
	LD	B,B
	INC	H
	INC	D
	DJNZ	$-9
	EI 
	LD	DE,-#0026
NewDisp:
	ADD	IX,DE
	BIT	6,(IX+#00)
	JR	NZ,NewDSex  ; Same window
	PUSH	DE
	CALL	GetWork	    ; Take from under window for shadow (from )
	LD	A,(IX+#1D)
	OUT	(SLOT2),A
	LD	A,(IX+#1E)
	OUT	(SLOT3),A
	LD	HL,FrameHd ; Pointer on frame window
	CALL	PutFram	    ; Draw frame
	PUSH	IX
	CALL	InitPage+6	; Page
	POP	IX
	CALL	PutIPage	; Store in window page
	CALL	PutShad	    ; Draw shadow
	LD	A,(BuffPg4)
	OUT	(SLOT3),A
	CALL	PutWork	    ; Copy in..area.window
	POP	DE
	JR	NewDisp
NewDSex:
	CALL	GetWork	    ; Take from under window for shadow (from )
	LD	A,(IX+#1D)
	OUT	(SLOT2),A
	LD	A,(IX+#1E)
	OUT	(SLOT3),A
	LD	HL,FrameSl  ; Pointer on frame selected window
	CALL	PutFram	    ; Draw frame
	PUSH	IX
	CALL	InitPage+6	; Page
	POP	IX
	CALL	PutIPage	; Store in window page
	CALL	PutShad	    ; Draw shadow
	LD	A,(BuffPg4)
	OUT	(SLOT3),A
	CALL	PutWork	    ; Copy in..area.window
	LD	A,(IX+#1E)
	OUT	(SLOT3),A
	JP	PutBuff
;[]===========================================================[]
; Procedure close windows
CloseAll:
	LD	IX,TxtWtab
	BIT	7,(IX+#00)
	RET	NZ
	LD	DE,#0026
	LD	B,D
CloseA1:
	INC	B
	ADD	IX,DE
	BIT	7,(IX+#00)
	JR	Z,CloseA1
CloseA2:
	PUSH	BC
	CALL	ClosTxW
	POP	BC
	DJNZ	CloseA2
	RET 
;[]===========================================================[]
; Window. windows
WinList:
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	CALL	GetWnLs
	POP	AF
	OUT	(SLOT2),A
	LD	HL,DWnList
	CALL	DialogW
	LD	IX,TxtWtab
	BIT	7,(IX+#00)
	RET	NZ
	LD	HL,what
	LD	A,(HL)
	INC	HL
	CP	evCommand
	RET	NZ
	LD	A,(HL)
	INC	HL
	CP	cmCancel
	RET	Z
	LD	C,A
	LD	A,(HL)
	OR	A
	LD	A,C
	JR	Z,WinLex
	PUSH	AF
	LD	DE,#0026
	LD	B,(HL)
	ADD	IX,DE
	DJNZ	$-2
	CALL	SetWind
	POP	AF
WinLex:
	CP	cmDelWind
	RET	NZ
	JP	ClosTxW
;
GetWnLs:
	LD	IX,TxtWtab
	LD	DE,FuncBuffer
GetWL1:
	SUB	A
	LD	(DE),A
	BIT	7,(IX+#00)
	RET	NZ
	PUSH	DE
	LD	A,(IX+#00)
	AND	#0F
	INC	A
	LD	B,A
	LD	HL,NameTab-#80
	LD	DE,#0080
	ADD	HL,DE
	DJNZ	$-1
	LD	DE,#0026
	ADD	IX,DE
	POP	DE
	LD	(BegGnam+1),HL
GetWL2:
	LD	A,(HL)
	INC	HL
	CP	'\' 
	JR	NZ,$+5
	LD	(BegGnam+1),HL
	BIT	7,A
	JR	NZ,BegGnam
	OR	A
	JR	NZ,GetWL2
BegGnam:
	LD	HL,#0000
	LD	A,(HL)
GetWL3:
	INC	HL
	RES	7,A
	LD	(DE),A
	INC	DE
	LD	A,(HL)
	OR	A
	JR	NZ,GetWL3
	LD	A,#0D
	LD	(DE),A
	INC	DE
	JR	GetWL1
;[]===========================================================[]
; Procedure copy block in ClipBoard
CopyBlock:
	LD	HL,#0000
	LD	(EqClipLn),HL
	LD	(EndClipB),HL
; Procedure block in ClipBoard
AppBlock:
	CALL	OnlySyntax	; Syntax-highlight last line
	CALL	PutString	; Insert it in text
	LD	HL,#8040	; Start TAS
	LD	D,#00
CopyB1:
	INC	HL
	BIT	6,(HL)		; Selection
	DEC	HL
	JR	NZ,CopyB11
	LD	E,(HL)
	ADD	HL,DE
	LD	A,(HL)
	OR	A		; 0 - TAS
	RET	Z
	JR	CopyB1
CopyB11:
	LD	BC,#0000
	PUSH	HL
CopyB2:
	LD	A,(HL)
	OR	A
	JR	Z,CopyB3
	LD	E,A		; Search selected
	ADD	HL,DE		; Block
	INC	BC
	INC	HL
	BIT	6,(HL)		; Selection
	DEC	HL
	JR	NZ,CopyB2
CopyB3:
	POP	DE
	OR	A
	SBC	HL,DE
	PUSH	HL
	PUSH	DE
	LD	DE,(EndClipB)
	ADD	HL,DE
	BIT	7,H
	JP	NZ,NoBfSpace
	POP	DE
	POP	HL
	PUSH	HL
	LD	HL,(EqClipLn)
	ADD	HL,BC
	LD	(EqClipLn),HL
	POP	HL
	LD	C,L		; Block
	LD	B,H
	EX	DE,HL		; HL - start
	RES	7,H		; #8000 - offset from start
	LD	DE,(EndClipB)
	SUB	A
	CALL	CopyToClip	; Copy in
	LD	A,cmPaste
	CALL	OpenCmnd	; Open command Paste
	CALL	ExmMark
	RET 
;[]===========================================================[]
; Procedure block in ClipBoard
CutBlock:
	LD	HL,#0000
	LD	(EqClipLn),HL
	LD	(EndClipB),HL
; Procedure and. block in ClipBoard
AppCutBlck:
	CALL	OnlySyntax	; Syntax-highlight last line
	CALL	PutString	; Insert it in text
	LD	HL,#8040	; Start TAS
	LD	BC,#0000
	LD	D,C
CutB1:
	INC	HL
	BIT	6,(HL)		; Selection
	DEC	HL
	JR	NZ,CutB11
	LD	E,(HL)
	ADD	HL,DE
	INC	BC
	LD	A,(HL)
	OR	A		; 0 - TAS
	RET	Z
	JR	CutB1
CutB11:
	PUSH	BC
	PUSH	HL
	LD	BC,#0000
CutB2:
	LD	A,(HL)
	OR	A
	JR	Z,CutB3
	LD	E,A		; Search selected
	ADD	HL,DE		; Block
	INC	BC
	INC	HL
	BIT	6,(HL)		; Selection
	DEC	HL
	JR	NZ,CutB2
CutB3:
	POP	DE
	PUSH	DE
	PUSH	HL
	OR	A
	SBC	HL,DE
	PUSH	HL
	PUSH	DE
	LD	DE,(EndClipB)
	ADD	HL,DE
	BIT	7,H
	JP	NZ,NoBfSpace
	POP	DE
	POP	HL
	PUSH	HL
	LD	HL,(EqClipLn)
	ADD	HL,BC
	LD	(EqClipLn),HL
	POP	HL
	LD	C,L		; Block
	LD	B,H
	EX	DE,HL		; HL - start
	RES	7,H		; #8000 - offset from start
	LD	DE,(EndClipB)
	SUB	A
	CALL	CopyToClip	; Copy
	LD	A,cmPaste
	CALL	OpenCmnd	; Open command Paste
	POP	DE
	LD	HL,(EndText)
	OR	A
	SBC	HL,DE
	LD	C,L
	LD	B,H
	POP	HL
	EX	DE,HL
	PUSH	DE
	LD	A,B
	OR	C
	JR	Z,$+4
	LDIR 
	SUB	A
	LD	(DE),A
	LD	(EndText),DE
	POP	HL
	POP	BC
	LD	(BegString),HL
	LD	(CurLine),BC
	LD	D,#00
	LD	A,(HL)
	OR	A
	JR	NZ,CutB4
	DEC	HL
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,CutB4
	LD	E,A
	SBC	HL,DE
	LD	(BegString),HL
	LD	BC,(UpLinePg)
	DEC	BC
	LD	(UpLinePg),BC
	LD	BC,(CurLine)
	DEC	BC
	LD	(CurLine),BC
CutB4:
	LD	B,(IY+#06)
	SRL	B
	SRL	B
	LD	C,#00
	JR	Z,CutB6
CutB5:
	DEC	HL
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,CutB6
	LD	E,A
	SBC	HL,DE
	INC	C
	DJNZ	CutB5
CutB6:
	LD	(IY+#01),C
	LD	(AdrPage),HL
	LD	HL,(CurLine)
	LD	B,D
	SBC	HL,BC
	LD	(UpLinePg),HL
	SUB	A
	LD	(IY-#02),A
	LD	(IY-#01),A
	LD	(IY+#00),A
	LD	(IY+#07),A
	LD	(ReadyFile),A
	LD	HL,#8040
	LD	A,(HL)
	OR	A
	JR	NZ,CutB7
	LD	(HL),#03
	INC	HL
	LD	(HL),#02
	INC	HL
	LD	(HL),#03
	INC	HL
	LD	(HL),#00
	LD	(EndText),HL
CutB7:
	CALL	PrintPage
	LD	HL,#8040
	LD	BC,#0000
	LD	D,C
CutB8:
	LD	E,(HL)
	ADD	HL,DE
	INC	BC
	LD	A,(HL)
	OR	A
	JR	NZ,CutB8
	LD	(EquipLn),BC
	CALL	PrintInfo
	LD	HL,MarkGrp
	CALL	CloseGroup
	LD	HL,#0000
	LD	(EquipMr),HL
	RET 
;[]===========================================================[]
; Procedure block
ClearBlock:
	CALL	OnlySyntax	; Syntax-highlight last line
	CALL	PutString	; Insert it in text
	LD	HL,#8040	; Start TAS
	LD	BC,#0000
	LD	D,C
ClrB1:
	INC	HL
	BIT	6,(HL)		; Selection
	DEC	HL
	JR	NZ,ClrB11
	LD	E,(HL)
	ADD	HL,DE
	INC	BC
	LD	A,(HL)
	OR	A		; 0 - TAS
	RET	Z
	JR	ClrB1
ClrB11:
	LD	(BegString),HL
	LD	(CurLine),BC
	LD	B,(IY+#06)
	SRL	B
	SRL	B
	LD	C,#00
	JR	Z,ClrB3
ClrB2:
	DEC	HL
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,ClrB3
	LD	E,A
	SBC	HL,DE
	INC	C
	DJNZ	ClrB2
ClrB3:
	LD	(IY+#01),C
	LD	(AdrPage),HL
	LD	HL,(CurLine)
	LD	B,D
	SBC	HL,BC
	LD	(UpLinePg),HL
	SUB	A
	LD	(IY-#02),A
	LD	(IY-#01),A
	LD	(IY+#00),A
	LD	(IY+#07),A
	CALL	PrintPage
	CALL	PrintInfo
	LD	HL,DclearB
	CALL	DialogW
	LD	HL,what
	LD	A,(HL)
	LD	(HL),evNothing
	INC	HL
	CP	evCommand
	RET	NZ
	LD	A,(HL)
	CP	cmYes
	RET	NZ
	LD	HL,(BegString)
	LD	D,#00
	PUSH	HL
ClrB4:
	LD	A,(HL)
	OR	A
	JR	Z,ClrB5
	LD	E,A		; Search selected
	ADD	HL,DE		; Block
	INC	HL
	BIT	6,(HL)		; Selection
	DEC	HL
	JR	NZ,ClrB4
ClrB5:
	EX	DE,HL
	LD	HL,(EndText)
	OR	A
	SBC	HL,DE
	LD	C,L
	LD	B,H
	POP	HL
	EX	DE,HL
	LD	A,B
	OR	C
	JR	Z,$+4
	LDIR 
	SUB	A
	LD	(DE),A
	LD	(EndText),DE
	LD	HL,(BegString)
	LD	D,#00
	LD	A,(HL)
	OR	A
	JR	NZ,ClrB6
	DEC	HL
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,ClrB6
	LD	E,A
	SBC	HL,DE
	LD	(BegString),HL
	LD	HL,(UpLinePg)
	DEC	HL
	LD	(UpLinePg),HL
	LD	HL,(CurLine)
	DEC	HL
	LD	(CurLine),HL
	LD	HL,(AdrPage)
	DEC	HL
	LD	E,(HL)
	INC	HL
	SBC	HL,DE
	LD	(AdrPage),HL
ClrB6:
	SUB	A
	LD	(ReadyFile),A
	LD	HL,#8040
	LD	A,(HL)
	OR	A
	JR	NZ,ClrB7
	LD	(HL),#03
	INC	HL
	LD	(HL),#02
	INC	HL
	LD	(HL),#03
	INC	HL
	LD	(HL),#00
	LD	(EndText),HL
ClrB7:
	CALL	PrintPage
	LD	HL,#8040
	LD	BC,#0000
	LD	D,C
ClrB8:
	LD	E,(HL)
	ADD	HL,DE
	INC	BC
	LD	A,(HL)
	OR	A
	JR	NZ,ClrB8
	LD	(EquipLn),BC
	CALL	PrintInfo
	LD	HL,MarkGrp
	CALL	CloseGroup
	LD	HL,#0000
	LD	(EquipMr),HL
	RET 
;[]===========================================================[]
; Procedure block from ClipBoard in text
PasteBlock:
	CALL	OnlySyntax	; Syntax-highlight last line
	CALL	PutString	; Insert it in text
	CALL	exProec
	CALL	ExmMark
	LD	A,(OvrwrtBlck)
	OR	A
	JR	NZ,OverBlock
	LD	HL,(EndText)
	LD	DE,(EndClipB)
OverUp:
	ADD	HL,DE
	JP	C,NoTxtSpace
	PUSH	HL
	LD	HL,(EndText)
	PUSH	HL
	LD	DE,(BegString)
	SBC	HL,DE
	LD	C,L
	LD	B,H
	POP	HL
	POP	DE
	LD	(EndText),DE
	INC	BC
	LDDR 
PasteB:
	LD	HL,(BegString)
	RES	7,H
	LD	DE,#0000
	LD	BC,(EndClipB)
	LD	A,#01
	CALL	CopyToClip
	SUB	A
	LD	(IY-#02),A
	LD	(IY-#01),A
	LD	(IY+#00),A
	LD	(IY+#07),A
	LD	(ReadyFile),A
	CALL	PrintPage
	LD	HL,#8040
	LD	BC,#0000
	LD	D,C
Paste1:
	LD	E,(HL)
	ADD	HL,DE
	INC	BC
	LD	A,(HL)
	OR	A
	JR	NZ,Paste1
	LD	(EquipLn),BC
	CALL	PrintInfo
	RET 
OverBlock:
	LD	HL,(BegString)
	LD	BC,(EqClipLn)
	PUSH	HL
	LD	D,#00
OverB1:
	LD	A,(HL)
	OR	A
	JR	Z,OverB2
	LD	E,A
	ADD	HL,DE
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,OverB1
OverB2:
	POP	DE
	LD	C,L
	LD	B,H
	SBC	HL,DE
	LD	DE,(EndClipB)
	SBC	HL,DE
	JR	Z,PasteB
	JR	NC,OverDn
	EX	DE,HL
	LD	HL,#0000
	OR	A
	SBC	HL,DE
	EX	DE,HL
	LD	HL,(EndText)
	JP	OverUp
OverDn:
	EX	DE,HL
	LD	L,C
	LD	H,B
	SBC	HL,DE
	PUSH	HL
	PUSH	BC
	LD	HL,(EndText)
	SBC	HL,BC
	LD	C,L
	LD	B,H
	POP	HL
	POP	DE
	LD	A,B
	OR	C
	JR	Z,$+4
	LDIR 
	SUB	A
	LD	(DE),A
	LD	(EndText),DE
	JP	PasteB
;
; Procedure copy block from TAS in ClipBoard
; On:
; HL - offset from start TAS
; DE - offset from start ClipBoard
; BC - block
; A - 0 copy from text in
; A - 1 copy from buffers in text
CopyToClip:
	OR	A
	JR	Z,$+4
	LD	A,#EB	; Ex de,hl
	LD	(CopyMOD),A
	LD	IX,TxtWtab
CopyBl0:
	PUSH	HL
	PUSH	DE
	BIT	6,H
	RES	6,H
	LD	A,(IX+#1D)
	JR	Z,$+5
	LD	A,(IX+#1E)
	OUT	(SLOT2),A
	LD	(BegMove+1),HL
	BIT	6,D
	RES	6,D
	LD	A,(ClipPg1)
	JR	Z,$+5
	LD	A,(ClipPg2)
	OUT	(SLOT3),A
	LD	(ToMove+1),DE
	LD	(MoveLen+1),BC
	LD	HL,(BegMove+1)
	ADD	HL,BC
	BIT	6,H
	JR	Z,CopyBl1
	SBC	HL,BC
	LD	DE,#4000
	EX	DE,HL
	SBC	HL,DE
	LD	C,L
	LD	B,H
CopyBl1:
	LD	HL,(ToMove+1)
	ADD	HL,BC
	BIT	6,H
	JR	Z,BegMove
	SBC	HL,BC
	LD	DE,#4000
	EX	DE,HL
	SBC	HL,DE
	LD	C,L
	LD	B,H
BegMove:
	LD	HL,#0000
ToMove:
	LD	DE,#0000
	SET	7,H
	LD	A,D
	OR	#C0
	LD	D,A
	PUSH	BC
CopyMOD:
	NOP 
	LDIR 
	POP	BC
	POP	HL
	ADD	HL,BC
	LD	(EndClipB),HL
	EX	DE,HL
	POP	HL
	ADD	HL,BC
	PUSH	HL
MoveLen:
	LD	HL,#0000
	SBC	HL,BC
	LD	C,L
	LD	B,H
	POP	HL
	JR	NZ,CopyBl0
	LD	A,(CopyMOD)
	OR	A
	JR	NZ,CopyCLe
	LD	HL,#8000
	LD	D,L
	LD	BC,(EqClipLn)
	LD	A,(ClipPg1)
	OUT	(SLOT2),A
	LD	A,(ClipPg2)
	OUT	(SLOT3),A
ResMrk:
	INC	HL
	RES	6,(HL)
	DEC	HL
	LD	E,(HL)
	ADD	HL,DE
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,ResMrk
CopyCLe:
	LD	A,(IX+#1D)
	OUT	(SLOT2),A
	LD	A,(IX+#1E)
	OUT	(SLOT3),A
	RET 
EndClipB:
	DEFW	#0000
EqClipLn:
	DEFW	#0000
;[]===========================================================[]
NoTxtSpace:
	LD	HL,Dnotxtsp
	CALL	DialogW
	LD	HL,what
	LD	(HL),evNothing
	RET 
;[]===========================================================[]
NoBfSpace:
	LD	HL,Dnobfspc
	CALL	DialogW
	LD	HL,what
	LD	(HL),evNothing
	LD	SP,#7FFF
	JP	MainCyc
;[]===========================================================[]
; Function - Editor
EditorOpt:
	LD	IX,TxtWtab
	BIT	7,(IX+#00)
	JR	NZ,EditOp1
	CALL	OnlySyntax	; Syntax-highlight last line
	CALL	PutString	; Insert it in text
EditOp1:
	LD	HL,LabBuff+5
	PUSH	HL
	SUB	A
	LD	(HL),A
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HL),A
	POP	IX
	LD	H,A
	LD	A,(LabSize)
	LD	L,A
	CALL	Put16Num
	LD	A,B
	LD	(LabBuff+4),A
	LD	HL,TabBuff+5
	PUSH	HL
	SUB	A
	LD	(HL),A
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HL),A
	POP	IX
	LD	H,A
	LD	A,(TabSize)
	LD	L,A
	CALL	Put16Num
	LD	A,B
	LD	(TabBuff+4),A
	LD	A,(SynHghLght)
	LD	(CompSyn+1),A
	LD	HL,DeditorO
	CALL	DialogW
	LD	HL,what
	LD	A,(HL)
	LD	(HL),evNothing
	INC	HL
	CP	evCommand
	RET	NZ
	LD	A,(HL)
	CP	cmCancel
	RET	Z
	LD	HL,LabBuff+4
	LD	C,(HL)
	INC	HL
	PUSH	HL
	LD	B,#00
	ADD	HL,BC
	LD	(HL),B
	POP	DE
	CALL	Get16Num
	JR	C,EditOp2
	LD	A,L
	OR	A
	JR	Z,EditOp2
	CP	#21
	JR	NC,EditOp2
	LD	(LabSize),A
EditOp2:
	LD	HL,TabBuff+4
	LD	C,(HL)
	INC	HL
	PUSH	HL
	LD	B,#00
	ADD	HL,BC
	LD	(HL),B
	POP	DE
	CALL	Get16Num
	JR	C,EditOp3
	LD	A,L
	OR	A
	JR	Z,EditOp3
	CP	#21
	JR	NC,EditOp3
	LD	(TabSize),A
EditOp3:
	LD	A,(SynHghLght)
CompSyn:
	CP	#00
	RET	Z
	LD	A,(ColLabel)
	LD	E,A
	LD	A,(ColMnemon)
	LD	D,A
	LD	A,(ColComment)
	LD	B,A
	LD	A,(SynHghLght)
	OR	A
	JR	NZ,EditOp4
	LD	A,(ColTxtWin)
	LD	E,A
	LD	D,E
	LD	B,D
EditOp4:
	LD	A,E
	LD	(CSLabel),A
	LD	A,D
	LD	(CSMnemon),A
	LD	A,B
	LD	(CSComment),A
	CALL	ResCurs
RefrScr:
	LD	IX,TxtWtab  ; Table window descriptors
	BIT	7,(IX+#00)
	RET	NZ
	LD	BC,#0026
EditOp5:
	ADD	IX,BC
	BIT	7,(IX+#00)  ; Search same window
	JR	Z,EditOp5
EditOp6:
	LD	BC,-#0026   ; Refresh window down by table
	ADD	IX,BC
	LD	A,(IX+#1D)
	OUT	(SLOT2),A
	LD	A,(IX+#1E)
	OUT	(SLOT3),A
	PUSH	IX
	CALL	InitPage+6	; Page
	POP	IX
	CALL	PutIPage	; Store in window page
	BIT	6,(IX+#00)
	JR	Z,EditOp6   ; Same window
	CALL	RefrWin		; Refresh screen in buffer
	CALL	PutShad		; Draw shadow
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg4)
	OUT	(SLOT3),A
	CALL	PutWork	; Set window in
	POP	AF
	OUT	(SLOT3),A
	CALL	PutBuff	; Copy in.area
	CALL	SetCurs
	RET 

LabBuff:
	DEFB	#02
	DEFB	#00	; Readystring
	DEFB	#00	; Pos x
	DEFB	#00	; Add x
	DEFB	#00	; Inp.symb
	DEFS	#03,0
TabBuff:
	DEFB	#02
	DEFB	#00	; Readystring
	DEFB	#00	; Pos x
	DEFB	#00	; Add x
	DEFB	#00	; Inp.symb
	DEFS	#03,0
;[]===========================================================[]
Colors:
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	LD	HL,PalleteAr
	LD	DE,ColorList
	LD	BC,64
	LDIR 
	POP	AF
	OUT	(SLOT2),A
	LD	HL,Dcolors
	CALL	DialogW
	LD	HL,what
	LD	A,(HL)
	LD	(HL),evNothing
	INC	HL
	CP	evCommand
	RET	NZ
	LD	A,(HL)
	CP	cmCancel
	RET	Z
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	LD	HL,ColorList
	LD	DE,PalleteAr
	LD	BC,64
	LDIR 
	POP	AF
	OUT	(SLOT2),A
RefrDisplay:
	LD	IX,TxtWtab
	BIT	7,(IX+#00)
	JR	NZ,Colors1
	CALL	OnlySyntax	; Syntax-highlight last line
	CALL	PutString	; Insert it in text
Colors1:
	CALL	InitBar		; Initialize menu bar
	CALL	InitStLine	; Initialize status line
	LD	HL,TextBuff
	LD	BC,#0000
	LD	A,(ColTxtWin)
	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-4
	AND	#F0
	LD	B,A
	LD	C,#0F
	LD	A,(ColLabel)
	AND	C
	OR	B
	LD	(ColLabel),A
	LD	A,(ColMnemon)
	AND	C
	OR	B
	LD	(ColMnemon),A
	LD	A,(ColComment)
	AND	C
	OR	B
	LD	(ColComment),A
	LD	A,(ColLabel)
	LD	E,A
	LD	A,(ColMnemon)
	LD	D,A
	LD	A,(ColComment)
	LD	B,A
	LD	A,(SynHghLght)
	OR	A
	JR	NZ,Color1
	LD	A,(ColTxtWin)
	LD	E,A
	LD	D,E
	LD	B,D
Color1:
	LD	A,E
	LD	(CSLabel),A
	LD	A,D
	LD	(CSMnemon),A
	LD	A,B
	LD	(CSComment),A
	LD	IX,TxtWtab  ; Table window descriptors
	BIT	7,(IX+#00)
	JP	NZ,InitDeskTop
	CALL	ResMBar
	CALL	ReCompileStr
	CALL	OnlySyntax
	CALL	ResCurs
	LD	IX,TxtWtab
	LD	DE,#0026
	ADD	IX,DE
	BIT	7,(IX+#00)  ; Search same window
	JR	Z,$-6
	CALL	NewDisplay
	CALL	SetCurs
	RET 
;
 _mCollectInfo_addEnd