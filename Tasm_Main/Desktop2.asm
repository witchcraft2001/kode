 _mCollectInfo_addStart
;[]===========================================================[]
; Main events Desk Top
;[]===========================================================[]
DeskTop	LD	HL,what		; Field events
	LD	DE,DTexit
	PUSH	DE
	LD	A,(HL)
	INC	HL
	CP	evCommand      ; With
	JR	Z,DTcmnd
	CP	evMouseFr      ; With mouse
	JR	Z,DTmouse
	LD	IX,TxtWtab
	BIT	7,(IX+#00)
	JR	NZ,DskTopE
	CP	evKeyboard
	JP	Z,EditorT
	CP	evCombKey
	JP	Z,SysComb
DskTopE	POP	DE	       ; Internal operation
	RET 
; Desktop exit
DTexit	LD	HL,what		; Its
	LD	(HL),evNothing
	RET 
; With
DTcmnd	LD	A,(HL)		; From what take command
	CALL	GetCmnd		; Check on commands
	RET	Z		; Z
	JP	(HL)		; Internal operation
; Events in DeskTop, with mouse
DTmouse	LD	E,(HL)	; From events take
	INC	HL	; Coordinates mouse
	LD	D,(HL)
	LD	A,D
	CP	#1F
	JR	Z,DskTopE
	LD	IX,TxtWtab-#26
	LD	BC,#0026
DTmous1	ADD	IX,BC
	BIT	7,(IX+#00)
	JR	NZ,DskTopE	; Not on
	LD	A,E	; Xcoord mouse
	BIT	7,(IX+#01)	; Coordinate can be negative
	JR	NZ,DTmous2	; If negative.then not must
	CP	(IX+#01)
	JR	C,DTmous1	;Xo coords current object
DTmous2	CP	(IX+#02)
	JR	NC,DTmous1	;Xi coords current object
	LD	A,D	; Ycoord mouse
	CP	(IX+#03)
	JR	C,DTmous1	;Yo coords current object
	CP	(IX+#04)
	JR	NC,DTmous1	;Yi coords current object
	BIT	6,(IX+#00)	; Check on window
	JR	NZ,ExWplac	; If -then check
SetWind	PUSH	IX
	CALL	OnlySyntax
	CALL	PutString
	POP	IX
	CALL	ResCurs
	CALL	SelecWn	      ; Place descriptor in start
	CALL	HiddWin		; Disable current.window
	LD	IX,TxtWtab  ; Pointer on first windows
	LD	A,(IX+#1D)	; Text pages
	OUT	(SLOT2),A
	LD	A,(IX+#1E)
	OUT	(SLOT3),A
	CALL	GetTxtW	    ; With screen from-under.window
	LD	HL,FrameSl  ; Pointer on frame selected window
	CALL	PutFram	    ; Draw frame
	CALL	PutShad	    ; Draw shadow
	CALL	PrnTxtW	    ; Print window on screen
	CALL	ReCompileStr
	CALL	OnlySyntax
	CALL	SetCurs
	CALL	RefrWin		; Window
	LD	HL,MarkGrp
	LD	DE,(EquipMr)
	LD	A,D
	OR	E
	PUSH	AF
	CALL	Z,CloseGroup
	POP	AF
	CALL	NZ,OpenGroup
	LD	A,#04
	RST	#00
	RET 
; Check
ExWplac	LD	A,E
	CP	(IX+#05)	; Xpos close bt
	JR	NZ,ExWlp1
	LD	A,D
	CP	(IX+#06)	; Ypos close bt
	JP	Z,ClosTxW	; Window
ExWlp1	LD	A,E
	CP	(IX+#07)	; Xpos open bt
	JR	NZ,ExWlp2
	LD	A,D
	CP	(IX+#08)	; Ypos open bt
	JP	Z,ZoomWin	; Open on all screen
ExWlp2	LD	A,E
	BIT	7,(IX+#01)	; Coordinate can be negative
	JR	NZ,ExWlp3	; If negative.then not must
	CP	(IX+#09)	;Xo move window
	JR	C,ExWlp3
ExWlp3	CP	(IX+#0A)	;Xi move window
	JR	NC,ExWlp4
	LD	A,D
	CP	(IX+#0B)	;Ypos move window
	JP	Z,MovinWM	; Window
ExWlp4	LD	A,E
	CP	(IX+#0C)	; Xpos resize window
	JR	NZ,ExWlp5
	LD	A,D
	CP	(IX+#0D)	; Ypos resize window
	JP	Z,ReSizeWM
ExWlp5	LD	A,E
	CP	(IX+#0E)
	JR	NZ,ExWlp6
	LD	A,D
	CP	(IX+#0F)
	JP	Z,LineUp
ExWlp6	LD	A,E
	CP	(IX+#10)
	JR	NZ,ExWlp7
	LD	A,D
	CP	(IX+#11)
	JR	C,ExWlp7
	CP	(IX+#12)
	JP	C,BarPageV
ExWlp7	LD	A,E
	CP	(IX+#13)
	JR	NZ,ExWlp8
	LD	A,D
	CP	(IX+#14)
	JP	Z,LineDwn
ExWlp8	LD	A,D
	CP	(IX+#16)
	JR	NZ,ExWlp9
	LD	A,E
	CP	(IX+#15)
	JP	Z,LineLft
	BIT	7,(IX+#15)	; Coordinate can be negative
	JR	NZ,$+4
	JR	C,ExWlp9
	CP	(IX+#1A)
	JP	Z,LineRgt
	BIT	7,(IX+#1A)	; Coordinate can be negative
	JR	NZ,$+4
	JP	C,BarPageH
ExWlp9	LD	L,(IX+#01)	; Check on
	INC	L		; Window
	LD	H,(IX+#02)	; Coordinates
	DEC	H
	LD	C,(IX+#03)
	INC	C
	LD	B,(IX+#04)
	DEC	B
	LD	A,E
	BIT	7,L		; Coordinate can be negative
	JR	NZ,$+4		; If negative.then not must
	CP	L		; Xo pos window
	RET	C
	BIT	7,H
	RET	NZ
	CP	H		; Xi pos window
	RET	NC
	SUB	L
	LD	E,A
	LD	A,D
	CP	C		;Ypos pos window
	RET	C
	CP	B
	RET	NC
	SUB	C
	LD	D,A
	JP	NewCurP		; New position
;[]===========================================================[]
; Window from list windows
NxtTxtW	LD	IX,TxtWtab	; Start descriptor windows
	BIT	7,(IX+#26)
	RET	NZ		; 2 window none
	LD	BC,#0026
	LD	A,(IX+#00)	; Take number selected window
	AND	#0F
	LD	E,A
NxtTxt1	LD	HL,FreeWin	; Search next.window
	INC	E		; Next number
	LD	A,E
	CP	#0F		; 15
	JR	NZ,$+4
	LD	E,#00
	LD	A,L
	ADD	A,E
	LD	L,A
	JR	NC,$+3
	INC	H
	BIT	7,(HL)		; Window
	JR	Z,NxtTxt1
	JR	PutNxtW
;[]===========================================================[]
; Window from list windows
PrvTxtW	LD	IX,TxtWtab	; Start descriptor windows
	BIT	7,(IX+#26)
	RET	NZ		; 2 window none
	LD	BC,#0026
	LD	A,(IX+#00)	; Take number selected window
	AND	#0F
	LD	E,A
PrvTxt1	LD	HL,FreeWin	; Search next.window
	DEC	E		; Next number
	JP	P,$+5
	LD	E,#0E
	LD	A,L
	ADD	A,E
	LD	L,A
	JR	NC,$+3
	INC	H
	BIT	7,(HL)		; Window
	JR	Z,PrvTxt1
PutNxtW	LD	A,(HL)		; Its number
	RES	7,A
	LD	E,A
	LD	IX,TxtWtab-#26	; Start descriptor windows
SRNlp	ADD	IX,BC
	LD	A,(IX+#00)
	AND	#0F
	CP	E		; Search its descriptor
	JR	NZ,SRNlp
	PUSH	IX
	CALL	OnlySyntax
	CALL	PutString
	POP	IX
	CALL	ResCurs
	CALL	SelecWn	      ; Place descriptor in start
	CALL	HiddWin		; Disable current.window
	LD	IX,TxtWtab  ; Pointer on first windows
	LD	A,(IX+#1D)	; Text pages
	OUT	(SLOT2),A
	LD	A,(IX+#1E)
	OUT	(SLOT3),A
	CALL	GetTxtW	    ; With screen from-under.window
	LD	HL,FrameSl  ; Pointer on frame selected window
	CALL	PutFram	    ; Draw frame
	CALL	PutShad	    ; Draw shadow
	CALL	PrnTxtW	    ; Print window on screen
	CALL	ReCompileStr
	CALL	OnlySyntax
	CALL	SetCurs
	CALL	RefrWin		; Window
	LD	HL,MarkGrp
	LD	DE,(EquipMr)
	LD	A,D
	OR	E
	PUSH	AF
	CALL	Z,CloseGroup
	POP	AF
	CALL	NZ,OpenGroup
	RET 
;[]===========================================================[]
; Procedure open window on all screen ( to )
ZoomWin	LD	IX,TxtWtab
	LD	A,(IX+#22)
	OR	A
	JR	NZ,zoomwin
	LD	A,(IX+#23)
	CP	#50
	JR	NZ,zoomwin
	LD	A,(IX+#24)
	DEC	A
	JR	NZ,zoomwin
	LD	A,(IX+#25)
	CP	#1F
	JR	NZ,zoomwin
	LD	A,(IX+#01)
	OR	A
	JR	NZ,zoomwin
	LD	A,(IX+#02)
	CP	#50
	JR	NZ,zoomwin
	LD	A,(IX+#03)
	DEC	A
	JR	NZ,zoomwin
	LD	A,(IX+#04)
	CP	#1F
	RET	Z
zoomwin	CALL	ResCurs
	IN	A,(SLOT3)
	PUSH	AF		; Save.page4
	LD	A,(BuffPg4)
	OUT	(SLOT3),A		; Enable
	CALL	GetBuff		; Copy.area in
	LD	IX,TxtWtab
	LD	A,(IX+#02)
	SUB	(IX+#01)
	CP	#50
	JR	NZ,OpFullS
	LD	A,(IX+#04)
	SUB	(IX+#03)
	CP	#1E
	JR	NZ,OpFullS
	BIT	7,(IX+#01)
	JR	NZ,OpFullS
	LD	A,(IX+#02)
	CP	#51
	JR	NC,OpFullS
	LD	A,(IX+#04)
	CP	#20
	JR	NC,OpFullS
	LD	L,(IX+#22)	; Coordinates
	LD	H,(IX+#23)
	LD	E,(IX+#24)
	LD	D,(IX+#25)
	BIT	7,L
	JR	NZ,ZoomNxt
	LD	A,H
	CP	#51
	JR	NC,ZoomNxt
	LD	A,D
	CP	#20
	JR	NC,ZoomNxt
	LD	A,H	; Can on all screen
	SUB	L
	CP	#50
	JR	NZ,ZoomNxt
	LD	A,D
	SUB	E
	CP	#1E
	JP	Z,ZoomExt
ZoomNxt	PUSH	HL
	PUSH	DE
	CALL	ResWork	; Delete window in buffer
	POP	DE
	POP	HL
	LD	(IX+#01),L
	LD	(IX+#02),H
	LD	(IX+#03),E
	LD	(IX+#04),D
	JR	PutOpen
; Open on all screen
OpFullS	LD	A,(IX+#01)	; Save
	LD	(IX+#22),A	; Coordinates
	LD	A,(IX+#02)
	LD	(IX+#23),A
	LD	A,(IX+#03)
	LD	(IX+#24),A
	LD	A,(IX+#04)
	LD	(IX+#25),A
	CALL	ResWork	; Delete window in buffer
	SUB	A		; New coordinates
	LD	(IX+#01),A
	INC	A
	LD	(IX+#03),A
	LD	A,#50
	LD	(IX+#02),A
	LD	A,#1F
	LD	(IX+#04),A
PutOpen	CALL	InsWatr	; Set new coordinates windows
	CALL	GetWork	; Store from buffers image.from-under window
	LD	A,(IX+#1D)
	OUT	(SLOT2),A
	LD	A,(IX+#1E)
	OUT	(SLOT3),A
	LD	HL,FrameSl  ; Pointer on frame selected window
	CALL	PutFram	    ; Draw frame
	PUSH	IX
	CALL	InitPage
	POP	IX
	CALL	PutIPage ; Store in window page
	CALL	PutShad	; New shadow window
	LD	A,(BuffPg4)
	OUT	(SLOT3),A		; Enable
	CALL	PutWork	; Set window in
	CALL	PutBuff	; Copy in.area
ZoomExt	POP	AF
	OUT	(SLOT3),A		; Enable
	CALL	BarPgEx
	CALL	ReCompileStr
	CALL	OnlySyntax
	LD	A,#04
	RST	#00
	RET 
;[]===========================================================[]
; Window by mouse
MovinWM	LD	(MtempXY),DE	; Save coordinates mouse
	CALL	MoveWin	; Paint in window
	CALL	InitPage
	LD	IX,TxtWtab
	CALL	PutIPage
	CALL	ResCurs
	IN	A,(SLOT3)
	PUSH	AF		; Save.page4
	LD	A,(BuffPg4)
	OUT	(SLOT3),A		; Enable
	CALL	GetBuff		; Copy.area in
MovinLp	LD	A,#03	; Get coordinates mouse and
	RST	#00	; Internal operation
	BIT	1,A	; Button
	JR	Z,MovinEx   ; Button mouse
	LD	DE,(MtempXY)
	OR	A
	SBC	HL,DE	; Check on offset mouse
	JR	Z,MovinLp
	ADD	HL,DE
	LD	(MtempXY),HL	; Store coordinates
	LD	A,E
	SUB	L
	LD	L,A		; In X
	PUSH	HL
	CALL	ResWork	; Delete window in buffer
	POP	HL
	LD	A,(IX+#02)
	SUB	(IX+#01)
	LD	E,A		; Len wind x
	LD	A,(IX+#04)
	SUB	(IX+#03)
	LD	D,A		; Len wind y
	LD	A,(IX+#01)
	SUB	L
	LD	(IX+#01),A	; New coordinate Xo
	ADD	A,E
	LD	(IX+#02),A	; New coordinate Xi
	LD	A,H
	OR	A
	JR	NZ,$+4
	LD	A,#01
	CP	#1F
	JR	C,$+4
	LD	A,#1E
	LD	(IX+#03),A	; New coordinate Yo
	ADD	A,D
	LD	(IX+#04),A	; New coordinate Yi
	CALL	GetWork	; Store from buffers image.from-under window
	CALL	PutShad	; New shadow window
	CALL	PutWork	; Set window in
	CALL	PutBuff	; Copy in.area
	JR	MovinLp
MovinEx	CALL	InsWatr	; Set new coordinates windows
	CALL	SelcWin	; Paint in window
	POP	AF
	OUT	(SLOT3),A		; Enable
	CALL	SetCurs
	LD	A,#04
	RST	#00
	RET 
;[]===========================================================[]
; Window
ReSizeWM
	LD	(MtempXY),DE	; Save coordinates mouse
	CALL	MoveWin	; Paint in ReSize window
	CALL	InitPage
	CALL	ResCurs
	LD	IX,TxtWtab	; Set descriptor
	IN	A,(SLOT3)
	PUSH	AF		; Save.page4
	LD	A,(BuffPg4)
	OUT	(SLOT3),A		; Enable
	CALL	GetBuff		; Copy.area in
ReSizLp	LD	A,#03	; Get coordinates mouse and
	RST	#00	; Internal operation
	BIT	1,A	; Button
	JP	Z,ReSizEx   ; Button mouse
	LD	DE,(MtempXY)
	OR	A
	SBC	HL,DE	; Check on offset mouse
	JP	Z,ReSizLp
	ADD	HL,DE
	LD	(MtempXY),HL	; Store coordinates
	LD	A,E
	SUB	L
	LD	L,A		; In X
	LD	A,D
	SUB	H
	LD	H,A		; In Y
	PUSH	HL
	CALL	ResWork	; Delete window in buffer
	POP	HL
	LD	A,(IX+#02)
	SUB	L
	SUB	(IX+#01)
	CP	#1A
	JR	NC,$+4
	LD	A,#19
	CP	#51
	JR	C,$+4
	LD	A,#50
	ADD	A,(IX+#01)
	LD	(IX+#02),A	; New coordinate Xi
	LD	A,(IX+#04)
	SUB	H
	SUB	(IX+#03)
	CP	#06
	JR	NC,$+4
	LD	A,#05
	CP	#1F
	JR	C,$+4
	LD	A,#1E
	ADD	A,(IX+#03)
	LD	(IX+#04),A	; New coordinate Yi
	CALL	GetWork	; Store from buffers image.from-under window
	LD	HL,FrameMv  ; Pointer on frame. window
	CALL	PutFram	    ; Draw frame
	CALL	PutIPage ; Store in window page
	CALL	PutShad	; New shadow window
	CALL	PutWork	; Set window in
	CALL	PutBuff	; Copy in.area
	JP	ReSizLp
ReSizEx	CALL	InsWatr	; Set new coordinates windows
	CALL	SelcWin	; Paint in window
	POP	AF
	OUT	(SLOT3),A		; Enable
	CALL	BarPgEx
	CALL	ReCompileStr
	CALL	OnlySyntax
	LD	A,#04
	RST	#00
	RET 
MtempXY	DEFW	#0000 ; For
;[]===========================================================[]
; Procedure and current window from
MovReSizK
	LD	(MtempXY),DE	; Save coordinates mouse
	CALL	MoveWin	; Paint in Move/ReSize window
	LD	A,CTmovresiz
	CALL	PutStatusLn	; New StatusLine
	CALL	InitPage
	LD	IX,TxtWtab
	CALL	PutIPage
	CALL	ResCurs
	IN	A,(SLOT3)
	PUSH	AF		; Save.page4
	LD	A,(BuffPg4)
	OUT	(SLOT3),A		; Enable
	CALL	GetBuff		; Copy.area in
	LD	HL,TxtWtab	; Save current.position
	LD	DE,CompBuff
	LD	BC,#0005
	LDIR 
MovRes1	CALL	handleEvent	; Internal operation
	LD	HL,what		; Field events
	LD	A,(HL)
	INC	HL
	CP	evKeyboard	; Pressed
	JR	Z,KeysWnK
	CP	evCombKey	; Pressed
	JR	Z,CombWnK
	JR	MovRes1
; Internal operation
KeysWnK	LD	A,(HL)		; Take
	CP	#0D		;Enter
	JP	Z,MRdone
	CP	#1B		;Esc
	JP	Z,MRcancel
	JR	MovRes1
; Internal operation
CombWnK	INC	HL
	LD	A,(HL)		; Take
	CP	72		; Up
	JR	Z,MminusY
	CP	75		; Left
	JR	Z,MminusX
	CP	80		; Down
	JR	Z,MplusY
	CP	77		; Right
	JR	Z,MplusX
	CP	142		; Shift+up
	JP	Z,RminusY
	CP	143		; Shift+left
	JP	Z,RminusX
	CP	144		; Shift+down
	JP	Z,RplusY
	CP	145		; Shift+right
	JP	Z,RplusX
	JR	MovRes1
; New coordinates window
MminusY	LD	H,1
	LD	L,0
	JR	ShowMov
MminusX	LD	L,1
	LD	H,0
	JR	ShowMov
MplusY	LD	H,-1
	LD	L,0
	JR	ShowMov
MplusX	LD	L,-1
	LD	H,0
ShowMov	LD	IX,TxtWtab	; Set descriptor
	LD	A,(IX+#01)
	SUB	L
	CP	#50
	JR	Z,MovRes1
	LD	C,A
	LD	A,(IX+#02)
	SUB	L
	JR	Z,MovRes1
	LD	E,A
	LD	A,(IX+#03)
	SUB	H
	JR	Z,MovRes1
	CP	#1F
	JR	Z,MovRes1
	LD	B,A
	LD	A,(IX+#04)
	SUB	H
	LD	D,A
	PUSH	DE
	PUSH	BC
	CALL	ResWork	; Delete window in buffer
	POP	BC
	POP	DE
	LD	(IX+#01),C	; New coordinate Xo
	LD	(IX+#02),E	; New coordinate Xi
	LD	(IX+#03),B	; New coordinate Yo
	LD	(IX+#04),D	; New coordinate Yi
show1	CALL	GetWork	; Store from buffers image.from-under window
	CALL	PutShad	; New shadow window
	CALL	PutWork	; Set window in
	CALL	PutBuff	; Copy in.area
	JP	MovRes1
; New window
RminusY	LD	H,1
	LD	L,0
	JR	ShowRes
RminusX	LD	L,1
	LD	H,0
	JR	ShowRes
RplusY	LD	H,-1
	LD	L,0
	JR	ShowRes
RplusX	LD	L,-1
	LD	H,0
ShowRes	LD	IX,TxtWtab	; Set descriptor
	LD	A,(IX+#02)
	SUB	L
	JP	Z,MovRes1
	SUB	(IX+#01)
	CP	#19
	JP	C,MovRes1
	CP	#51
	JP	NC,MovRes1
	ADD	A,(IX+#01)
	LD	L,A
	LD	A,(IX+#04)
	SUB	H
	SUB	(IX+#03)
	CP	#05
	JP	C,MovRes1
	CP	#1F
	JP	NC,MovRes1
	ADD	A,(IX+#03)
	LD	H,A
	PUSH	HL
	CALL	ResWork	; Delete window in buffer
	POP	HL
	LD	(IX+#02),L	; New coordinate Xi
	LD	(IX+#04),H	; New coordinate Yi
	CALL	GetWork	; Store from buffers image.from-under window
	LD	HL,FrameMv  ; Pointer on frame. window
	CALL	PutFram	    ; Draw frame
	CALL	PutIPage ; Store in window page
	CALL	PutShad	; New shadow window
	CALL	PutWork	; Set window in
	CALL	PutBuff	; Copy in.area
	JP	MovRes1
; Internal operation
MRcancel
	LD	IX,TxtWtab	; Set descriptor
	CALL	ResWork	; Delete window in buffer
	LD	HL,CompBuff	; Data
	LD	DE,TxtWtab
	LD	BC,#0005
	LDIR 
	CALL	GetWork	; Store from buffers image.from-under window
	LD	HL,FrameMv  ; Pointer on frame. window
	CALL	PutFram	    ; Draw frame
	CALL	PutIPage ; Store in window page
	CALL	PutShad	; New shadow window
	CALL	PutWork	; Set window in
	CALL	PutBuff	; Copy in.area
;Okey
MRdone	LD	IX,TxtWtab	; Set descriptor
	CALL	InsWatr	; Set new coordinates windows
	CALL	SelcWin	; Paint in window
	POP	AF
	OUT	(SLOT3),A		; Enable
	LD	A,NoConTxt
	CALL	PutStatusLn	; StatusLine
	CALL	BarPgEx
	CALL	ReCompileStr
	CALL	OnlySyntax
	LD	HL,what	; Field events
	LD	(HL),evNothing
	RET 
;[]===========================================================[]
; Procedure copy working in
GetBuff	PUSH	IX
	CALL	GetMousInfo		; Clear state mouse
	LD	IX,WinBoxBuff+5100
	LD	HL,#1E52	; !HARDCODE;copy
	LD	DE,#0100		; In
	LD	A,(BuffPg4)
	LD	B,A
	LD	C,#B2
	SUB	A
	RST	#10
	CALL	GetMousInfo		; Clear state mouse
	POP	IX
	RET 
; Procedure copy buffers in
PutBuff	PUSH	IX
	CALL	GetMousInfo	; Clear state mouse
	LD	IX,WinBoxBuff+5100
	LD	HL,#1E52	; !HARDCODE;copy working
	LD	DE,#0100	; On screen
	LD	A,(BuffPg4)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	CALL	GetMousInfo	; Clear state mouse
	POP	IX
	RET 
;[]===========================================================[]
; Procedure descriptor current window
; ( table down by memory)
ResetWn	LD	HL,TxtWtab
	LD	DE,TxtWtab+#26
	PUSH	HL
	LD	BC,#0026
	ADD	HL,BC
	BIT	7,(HL)
	JR	Z,$-3
	INC	HL
	OR	A
	SBC	HL,DE
	LD	C,L
	LD	B,H
	POP	HL
	EX	DE,HL
	PUSH	DE
	LDIR 
	POP	HL
	SET	6,(HL)	; Window
	RET 
; In table under new descriptor window
; ( table by memory)
IsrtWin	LD	HL,TxtWtab-#26
	LD	BC,#0026	; Descriptor
	ADD	HL,BC
	BIT	7,(HL)
	JR	Z,$-3
	PUSH	HL
	INC	HL
	LD	BC,TxtWtab
	OR	A
	SBC	HL,BC
	LD	C,L
	LD	B,H	; Table
	POP	HL
	PUSH	HL
	LD	DE,#0026
	ADD	HL,DE
	EX	DE,HL
	POP	HL
	LDDR 
	RET 
; Procedure descriptor window ( in start)
; On: IX - descriptor
SelecWn	PUSH	IX
	POP	HL
	LD	DE,CompBuff
	LD	BC,#0026
	LD	A,C
	LDIR 
	LD	C,A
	LD	E,L
	LD	D,H
	OR	A
	SBC	HL,BC
	PUSH	HL
	LD	BC,TxtWtab
	SBC	HL,BC
	LD	C,L
	LD	B,H
	POP	HL
	DEC	HL
	DEC	DE
	LDDR 
	LD	E,L
	LD	D,H
	INC	DE
	LD	HL,CompBuff
	SET	6,(HL)
	LD	C,A
	LDIR 
	RET 
 _mCollectInfo_addEnd