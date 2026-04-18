 _mCollectInfo_addStart
;[]===========================================================[]
; Main window
; On: HL- descriptor window
Dialog	CALL	PutDialWn
	CALL	ResMBar
DialogLp
	CALL	handleEvent	; Internal operation
	LD	IX,DialTab+5	; Table about'objects
DialWlp	LD	HL,DialWex
	PUSH	HL
	LD	A,(IX+#01)	; Current about'object
	RES	7,A
	CP	InputLine
	JP	Z,EInpLine
	CP	ClRadioBut
	JP	Z,EClasterB
	CP	ClCheckBut
	JP	Z,EClasterB
	CP	FileInput
	JP	Z,EFileInp
	CP	FileBox
	JP	Z,EFileBox
	CP	FileInfo
	JP	Z,EFileInfo
	CP	ListBox
	JP	Z,EListBox
	CP	Button
	JP	Z,EButton
	CP	ProcesLine
	JP	Z,EProcess
	CP	PalleteBox
	JP	Z,EPallete
	CP	TestColor
	JP	Z,ETestCol
	CP	PResident1
	JP	Z,EResident1
	CP	PResident2
	JP	Z,EResident2
	POP	HL
DialWex	LD	C,(IX+#00)
	LD	B,#00
	ADD	IX,BC		; Next.about'object
	BIT	7,(IX+#00)
	JR	Z,DialWlp	; 7 - about'objects

	LD	HL,what
	LD	DE,DialogC
	PUSH	DE
	LD	A,(HL)
	INC	HL
	CP	evMouseFr	;Fire from mouse
	JR	Z,TstExtD	; Test by close window
	CP	evKeyboard	;Keyboard event
	JR	Z,TstKeyD	; Test by break/enter
	CP	evCommand
	JR	Z,TstCmnD	;Test command
	POP	DE
	CP	evCombKey
	JR	NZ,DialogC
	INC	HL
	LD	A,(HL)
	CP	98		; Ctrl+f5
	CALL	Z,MoveDWK
DialogC	CALL	StatusL
	JP	DialogLp

TstExtD	LD	E,(HL)		;Xcoord
	INC	HL
	LD	D,(HL)		;Ycoord
	LD	HL,DialTab+3
	LD	A,E		; Button close window
	CP	(HL)
	JR	NZ,tstn		;Exam status line
	INC	HL
	LD	A,D
	CP	(HL)
	JR	Z,CancelD	;Cancel
tstn	LD	HL,DialTab
	BIT	7,(HL)
	JR	NZ,$+7
	LD	A,E
	CP	(HL)
	JP	C,StatusL
	INC	HL
	CP	(HL)
	JP	NC,StatusL
	INC	HL
	LD	A,D
	CP	(HL)
	JP	NZ,StatusL
	JP	MoveDWn

TstKeyD	LD	A,(HL)
	CP	#1B		;Esc
	JR	Z,CancelD
	CP	#0D		;Enter
	JP	Z,OkeyD
	JP	StatusL		; Else go to status line

TstCmnD	LD	A,(HL)
	CP	cmLocMenuM
	RET	Z
	CP	cmCancel
	JR	Z,CancelD
	JR	OkeyDn
;Okey
OkeyD	LD	HL,what
	LD	(HL),evCommand
	INC	HL
	LD	(HL),cmOkey
OkeyDn	LD	IX,DialTab+5
OkeyLp	LD	DE,OkeyN	;Find clasters & get data
	PUSH	DE
	LD	A,(IX+#01)
	RES	7,A
	CP	ClRadioBut
	JR	Z,GetClDt
	CP	ClCheckBut
	JR	Z,GetClDt
	CP	ListBox
	JR	Z,GetLstBox
	POP	DE
OkeyN	LD	C,(IX+#00)
	LD	B,#00
	ADD	IX,BC		;Next object
	BIT	7,(IX+#00)
	JR	Z,OkeyLp	; Nz-end object table
DialogE	CALL	ClsDial
	LD	A,NoConTxt
	CALL	PutStatusLn
	POP	DE
	LD	A,#04
	RST	#00
	LD	IX,TxtWtab
	BIT	7,(IX+#00)
	JP	Z,SetCurs
	JP	SetMBar
;Cancel
CancelD	LD	HL,what
	LD	(HL),evCommand
	INC	HL
	LD	(HL),cmCancel
	JR	DialogE

;Get claster data
GetClDt	PUSH	IX
	POP	HL
	LD	BC,#0007
	ADD	HL,BC	;Begin claster elements
GetDtLp	INC	HL	;Ypos
	INC	HL	;Hot key
	INC	HL	;Context
	LD	A,(HL)	; (ceil)
	INC	HL
	LD	E,(HL)	; Address ceil
	INC	HL	;
	LD	D,(HL)	;
	INC	HL
	LD	(DE),A
	BIT	7,(HL)		;7bit-end claster
	JR	Z,GetDtLp
	RET 
GetLstBox
	LD	HL,what
	INC	HL
	INC	HL
	LD	A,(IX+#07)
	ADD	A,(IX+#08)
	LD	(HL),A
	RET 
;[]===========================================================[]
; Procedure by about' with current about'
TransMessUp
	PUSH	IY
	PUSH	IX
	JR	TransEx
; Procedure by about' with about'
TransMessage
	PUSH	IY
	PUSH	IX
	LD	IX,DialTab+5	; Table about'objects
TransLp	LD	HL,TransEx
	PUSH	HL
	LD	A,(IX+#01)	; Current about'object
	AND	#7F		; 7 - about'object
	CP	InputLine
	JP	Z,EInpLine
	CP	ClRadioBut
	JP	Z,EClasterB
	CP	ClCheckBut
	JP	Z,EClasterB
	CP	FileInput
	JP	Z,EFileInp
	CP	FileBox
	JP	Z,EFileBox
	CP	FileInfo
	JP	Z,EFileInfo
	CP	ListBox
	JP	Z,EListBox
	CP	Button
	JP	Z,EButton
	CP	PalleteBox
	JP	Z,EPallete
	CP	TestColor
	JP	Z,ETestCol
	CP	PResident1
	JP	Z,EResident1
	CP	PResident2
	JP	Z,EResident2
	POP	HL
TransEx	LD	C,(IX+#00)
	LD	B,#00
	ADD	IX,BC		; Next.about'object
	BIT	7,(IX+#00)
	JR	Z,TransLp	; 7 - about'objects
	POP	IX
	POP	IY
	LD	HL,what
	LD	A,(HL)
	CP	evMessage
	RET	NZ		;Test command
	LD	(HL),evNothing
	RET 
;[]===========================================================[]
DialData
	DEFS	#10,0
DialName
	DEFS	#50,0
DialTab
	DEFS	#100,0
;[]===========================================================[]
; Moving object to first tab pos
; Input: ix-address object
MoveObj	SET	6,(IX+#00)	;Mark object
	LD	HL,DialTab+5
MoveOlp	BIT	6,(HL)		; Test by mark object
	RES	6,(HL)		;Reset mark
	RET	NZ		;Exit if mark
	INC	HL
	RES	7,(HL)		;Reset select object
	DEC	HL
	LD	DE,ReCompBuff	;Move first object in buffer
	LD	C,(HL)		;Len object label
	LD	B,#00
	RES	6,C
	LDIR			;Move
	PUSH	HL
	PUSH	HL
	LD	C,(HL)		;-6
	RES	6,C
	ADD	HL,BC		; Search end table
	BIT	7,(HL)
	JR	Z,$-6
	POP	BC
	OR	A		; Hl-end table,bc-address 2 obj
	SBC	HL,BC		; Hl-bc=len table -1 object
	LD	C,L		; Bc=len table
	LD	B,H
	POP	HL
	LD	DE,DialTab+5	;Move to begin table
	PUSH	DE
	LD	A,B
	OR	C
	JR	Z,$+4
	LDIR 
	LD	HL,ReCompBuff	;Move from buffer to end table
	LD	C,(HL)		; Object bc=len object label
	RES	6,C
	LDIR 
	POP	HL
	INC	HL
	SET	7,(HL)		;Setting object
	DEC	HL
	JR	MoveOlp
;[]===========================================================[]
; Window by
MoveDWn	LD	IX,DialData
	LD	(MtempXY),DE	; Save coordinates mouse
	LD	A,(CurILFl)
	PUSH	AF
	CALL	ResILCr	;Res cursor
	IN	A,(SLOT3)
	PUSH	AF		; Save.page4
	LD	A,(BuffPg5)
	OUT	(SLOT3),A		; Enable
	LD	HL,FramDMv
	CALL	PutDialFr ; Paint in window
	CALL	PutDial		; Internal operation
	CALL	GetBufD		; Copy.area in
MoveDLp	LD	A,#03	; Get coordinates mouse and
	RST	#00	; Internal operation
	BIT	1,A	; Button
	JR	Z,MoveDEx   ; Button mouse
	LD	DE,(MtempXY)
	OR	A
	SBC	HL,DE	; Check on offset mouse
	JR	Z,MoveDLp
	ADD	HL,DE
	LD	(MtempXY),HL	; Store coordinates
	LD	A,E
	SUB	L
	LD	L,A		; In X
	PUSH	HL
	CALL	RsWorkD	; Delete window in buffer
	POP	HL
	LD	A,(IX+#00)
	SUB	L
	LD	(IX+#00),A	; New coordinate Xo
	LD	A,H
	OR	A
	JR	NZ,$+4
	LD	A,#01
	CP	#1F
	JR	C,$+4
	LD	A,#1E
	LD	(IX+#01),A	; New coordinate Yo
	CALL	GtWorkD	; Store from buffers image.from-under window
	CALL	PutDialSh   ; New shadow window
	CALL	PtWorkD	; Set window in
	CALL	PutBufD	; Copy in.area
	JR	MoveDLp
MoveDEx	LD	HL,FramDSl
	CALL	PutDialFr ; Paint in window
	CALL	PutDial
	CALL	InsDobj	; Set new coordinates about'objects
	POP	AF
	OUT	(SLOT3),A		; Disable
	POP	AF
	OR	A
	RET	Z
	CALL	PILCurs
	EI 
	RET 
;[]===========================================================[]
; Procedure current window from
MoveDWK	LD	IX,DialData
	LD	(MtempXY),DE	; Save coordinates mouse
	LD	A,(CurILFl)
	PUSH	AF
	CALL	ResILCr	;Res cursor
	IN	A,(SLOT3)
	PUSH	AF		; Save.page4
	LD	A,(BuffPg5)
	OUT	(SLOT3),A		; Enable
	LD	HL,FramDMv
	CALL	PutDialFr ; Paint in window
	CALL	PutDial		; Internal operation
	CALL	GetBufD		; Copy.area in
	LD	A,CTmovresiz
	CALL	PutStatusLn	; New StatusLine
	LD	HL,DialData	; Save current.position
	LD	DE,CompBuff
	LDI 
	LDI 
MoveKey	CALL	handleEvent	; Internal operation
	LD	HL,what		; Field events
	LD	A,(HL)
	INC	HL
	CP	evKeyboard	; Pressed
	JR	Z,KeysWnD
	CP	evCombKey	; Pressed
	JR	Z,CombWnD
	JR	MoveKey
; Internal operation
KeysWnD	LD	A,(HL)		; Take
	CP	#0D		;Enter
	JP	Z,DRdone
	CP	#1B		;Esc
	JP	Z,DRcancel
	JR	MoveKey
; Internal operation
CombWnD	INC	HL
	LD	A,(HL)		; Take
	CP	72		; Up
	JR	Z,DminusY
	CP	75		; Left
	JR	Z,DminusX
	CP	80		; Down
	JR	Z,DplusY
	CP	77		; Right
	JR	Z,DplusX
	JR	MoveKey
; New coordinates window
DminusY	LD	H,1
	LD	L,0
	JR	DShow
DminusX	LD	L,1
	LD	H,0
	JR	DShow
DplusY	LD	H,-1
	LD	L,0
	JR	DShow
DplusX	LD	L,-1
	LD	H,0
DShow	LD	IX,DialData	; Set descriptor
	LD	A,(IX+#00)
	SUB	L
	CP	#50
	JR	Z,MoveKey
	LD	L,A
	ADD	A,(IX+#02)
	JR	Z,MoveKey
	LD	A,(IX+#01)
	SUB	H
	JR	Z,MoveKey
	CP	#1F
	JR	Z,MoveKey
	LD	H,A
	PUSH	HL
	CALL	RsWorkD	; Delete window in buffer
	POP	HL
	LD	(IX+#00),L	; New coordinate Xo
	LD	(IX+#01),H	; New coordinate Yo
	CALL	GtWorkD	; Store from buffers image.from-under window
	CALL	PutDialSh ; New shadow window
	CALL	PtWorkD	; Set window in
	CALL	PutBufD	; Copy in.area
	JP	MoveKey
; Internal operation
DRcancel
	LD	IX,DialData	; Set descriptor
	CALL	RsWorkD	; Delete window in buffer
	LD	HL,CompBuff	; Data
	LD	DE,DialData
	LDI 
	LDI 
	CALL	GtWorkD	; Store from buffers image.from-under window
	LD	HL,FramDMv  ; Pointer on frame. window
	CALL	PutDialFr   ; Draw frame
	CALL	PutDialSh   ; New shadow window
	CALL	PtWorkD	    ; Set window in
	CALL	PutBufD	    ; Copy in.area
;Okey
DRdone	LD	IX,DialData	; Set descriptor
	LD	HL,FramDSl
	CALL	PutDialFr ; Paint in window
	CALL	PutDial
	CALL	InsDobj	; Set new coordinates about'objects
	POP	AF
	OUT	(SLOT3),A		; Disable
	CALL	PrvStatusLn	; StatusLine
	LD	HL,what	; Field events
	LD	(HL),evNothing
	POP	AF
	OR	A
	RET	Z
	CALL	PILCurs
	EI 
	RET 
; Procedure copy working in
GetBufD	PUSH	IX
	CALL	GetMousInfo	; Clear state mouse
	LD	IX,WinBoxBuff+10200
	LD	HL,#1E52	; !HARDCODE;copy
	LD	DE,#0100	; In
	LD	A,(BuffPg5)
	LD	B,A
	LD	C,#B2
	SUB	A
	RST	#10
	CALL	GetMousInfo	; Clear state mouse
	POP	IX
	RET 
; Procedure copy buffers in
PutBufD	PUSH	IX
	CALL	GetMousInfo	; Clear state mouse
	LD	IX,WinBoxBuff+10200
	LD	HL,#1E52	; !HARDCODE;copy working
	LD	DE,#0100	; On screen
	LD	A,(BuffPg5)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	CALL	GetMousInfo	; Clear state mouse
	POP	IX
	RET 

; From buffers. info. from-under window (for shadow)
GtWorkD	LD	E,(IX+#00)	;Xo pos
	LD	D,(IX+#01)	;Yo pos
	LD	A,(IX+#02)
	ADD	A,#02		; Shadow
	LD	L,A		;Xlen
	LD	A,(IX+#03)
	INC	A		; Shadow
	LD	H,A		;Ylen
	CALL	ExCoordG	; Validity coordinates
	CALL	GtDBufA		; Get in buffer (DE)
	LD	B,H		; In BC
	LD	A,L
	ADD	A,A
	LD	(t1+1),A
	LD	L,A
	LD	H,#00
	LD	(t2+1),HL
	LD	HL,WinBoxBuff	; Internal operation
	DI			; From buffers in WinBoxbuff
	EXX 
	CALL	GetMousInfo
	EXX 
GetD	LD	D,D
t1	LD	A,#00
	LD	L,L
	LD	A,(DE)
	LD	(HL),A
	LD	B,B
	LD	A,B
t2	LD	BC,#0000
	ADD	HL,BC
	LD	BC,#00A4	; Next.line
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
	LD	B,A
	DJNZ	GetD
	EI 
	RET 
; In. info. from-under window
RsWorkD	LD	E,(IX+#00)	;Xo pos
	LD	D,(IX+#01)	;Yo pos
	LD	A,(IX+#02)
	ADD	A,#02		; Shadow
	LD	L,A		;Xlen
	LD	A,(IX+#03)
	INC	A		; Shadow
	LD	H,A		;Ylen
	CALL	ExCoordG	; Validity coordinates
	CALL	GtDBufA		; Get in buffer (DE)
	LD	B,H		; In BC
	LD	A,L
	ADD	A,A
	LD	(s1+1),A
	LD	L,A
	LD	H,#00
	LD	(s2+1),HL
	LD	HL,WinBoxBuff	; Internal operation
	DI			; From WinBoxbuff
	EXX 
	CALL	GetMousInfo
	EXX 
ResD	LD	D,D
s1	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
	LD	A,B
s2	LD	BC,#0000
	ADD	HL,BC
	LD	BC,#00A4	; Next.line
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
	LD	B,A
	DJNZ	ResD
	EI 
	RET 
; Window in
PtWorkD	LD	E,(IX+#00)	;Xo pos
	LD	D,(IX+#01)	;Yo pos
	LD	A,(IX+#02)
	ADD	A,#02		; Shadow
	LD	L,A		;Xlen
	LD	A,(IX+#03)
	INC	A		; Shadow
	LD	H,A		;Ylen
	PUSH	HL
	LD	H,#00
	SLA	L
	LD	(d2+1),HL
	POP	HL
	LD	BC,#0000
	BIT	7,E		;Xo pos
	JR	Z,$+11
	LD	A,E		; Start window for screen
	LD	E,B
	NEG		; In and-on how many window for screen
	LD	C,A	; Save
	SUB	L	; Window=-visible part
	NEG 
	LD	L,A	; Visible part

	LD	A,E
	ADD	A,L		; +len x
	CP	#53		; Test by out for x pos
	JR	C,$+6
	LD	A,#50
	SUB	E
	LD	L,A	; HL= by X
				; Window for screen
	LD	A,D		;Yo pos
	ADD	A,H		; +len y
	CP	#1F
	JR	C,$+6		; Okey
	LD	A,#1F
	SUB	D
	LD	H,A		; Normal len y
	SLA	C
	PUSH	BC
	CALL	GtDBufA		; Get in buffer (DE)
	LD	A,L		; Y in B
	ADD	A,L
	LD	(d1+1),A
	LD	A,H
	POP	BC
	LD	HL,WinBoxBuff+4800
	ADD	HL,BC
	LD	B,A
	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
dwl	LD	D,D
d1	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
	LD	A,B
	LD	BC,#00A4	; Next.line
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
d2	LD	BC,#0000
	ADD	HL,BC
	LD	B,A
	DJNZ	dwl
	EI 
	RET 
; Procedure getting addresses in
; On: DE - Y,X coord
; On exit: DE
GtDBufA	PUSH	HL
	LD	HL,WinBoxBuff+10200-#A4
	LD	C,E
	LD	B,D
	LD	DE,#00A4
	ADD	HL,DE
	DJNZ	$-1
	ADD	HL,BC
	ADD	HL,BC
	EX	DE,HL
	POP	HL
	RET 
;[]===========================================================[]
InsDobj	LD	C,(IX+#00)
	LD	B,(IX+#01)
	LD	IX,DialTab	; Table about'objects
	LD	A,(IX+#00)
	SUB	C
	LD	C,A
	LD	A,(IX+#02)
	SUB	B
	LD	B,A
	LD	A,(IX+#00)
	SUB	C
	LD	(IX+#00),A
	LD	A,(IX+#01)
	SUB	C
	LD	(IX+#01),A
	LD	A,(IX+#02)
	SUB	B
	LD	(IX+#02),A
	LD	A,(IX+#03)
	SUB	C
	LD	(IX+#03),A
	LD	A,(IX+#04)
	SUB	B
	LD	(IX+#04),A
	LD	HL,(CursPos)
	LD	A,L
	SUB	C
	LD	L,A
	LD	A,H
	SUB	B
	LD	H,A
	LD	(CursPos),HL
	LD	HL,(RDlIpos+1)
	LD	A,L
	SUB	C
	LD	L,A
	LD	A,H
	SUB	B
	LD	H,A
	LD	(RDlIpos+1),HL
	LD	HL,(RClIpos+1)
	LD	A,L
	SUB	C
	LD	L,A
	LD	A,H
	SUB	B
	LD	H,A
	LD	(RClIpos+1),HL
	LD	DE,#0005
	ADD	IX,DE

InsD	LD	HL,InsDex
	PUSH	HL
	LD	A,(IX+#01)	; Current about'object
	RES	7,A
	CP	InputLine
	JR	Z,IInpLn
	CP	ClRadioBut
	JR	Z,IClstrB
	CP	ClCheckBut
	JR	Z,IClstrB
	CP	FileInput
	JR	Z,IInpLn
	CP	FileBox
	JP	Z,IFileBox
	CP	FileInfo
	JP	Z,IFileInf
	CP	ListBox
	JP	Z,ILstBox
	CP	PalleteBox
	JP	Z,IPalBox
	CP	TestColor
	JP	Z,ITstCol
	CP	Button
	JP	Z,IButton
	CP	ProcesLine
	JP	Z,IFileInf
	POP	HL
InsDex	LD	E,(IX+#00)
	LD	D,#00
	ADD	IX,DE		; Next.about'object
	BIT	7,(IX+#00)
	RET	NZ		; 7 - about'objects
	JR	InsD

IInpLn	LD	A,(IX+#02)
	SUB	C
	LD	(IX+#02),A
	LD	A,(IX+#03)
	SUB	C
	LD	(IX+#03),A
	LD	A,(IX+#04)
	SUB	B
	LD	(IX+#04),A
	LD	A,(IX+#05)
	SUB	C
	LD	(IX+#05),A
	LD	A,(IX+#06)
	SUB	C
	LD	(IX+#06),A
	RET 

IClstrB	LD	A,(IX+#02)
	SUB	C
	LD	(IX+#02),A
	LD	A,(IX+#03)
	SUB	C
	LD	(IX+#03),A
	LD	A,(IX+#04)
	SUB	B
	LD	(IX+#04),A
	LD	A,(IX+#05)
	SUB	B
	LD	(IX+#05),A
	LD	A,(IX+#06)
	SUB	C
	LD	(IX+#06),A
	PUSH	IX
	POP	HL
	INC	HL
	LD	DE,#0006
clstlp	ADD	HL,DE
	BIT	7,(HL)
	RET	NZ
	LD	A,(HL)
	SUB	B
	LD	(HL),A
	JR	clstlp

IFileBox
	LD	A,(IX+#02)
	SUB	C
	LD	(IX+#02),A
	LD	A,(IX+#03)
	SUB	C
	LD	(IX+#03),A
	LD	A,(IX+#06)
	SUB	C
	LD	(IX+#06),A
	LD	A,(IX+#04)
	SUB	B
	LD	(IX+#04),A
	LD	A,(IX+#05)
	SUB	B
	LD	(IX+#05),A
	LD	A,(IX+#0D)
	SUB	C
	LD	(IX+#0D),A
	LD	A,(IX+#0E)
	SUB	C
	LD	(IX+#0E),A
	LD	A,(IX+#0F)
	SUB	C
	LD	(IX+#0F),A
	RET 

IFileInf
	LD	A,(IX+#02)
	SUB	C
	LD	(IX+#02),A
	LD	A,(IX+#03)
	SUB	C
	LD	(IX+#03),A
	LD	A,(IX+#04)
	SUB	B
	LD	(IX+#04),A
	RET 

ILstBox	LD	A,(IX+#02)
	SUB	C
	LD	(IX+#02),A
	LD	A,(IX+#03)
	SUB	C
	LD	(IX+#03),A
	LD	A,(IX+#06)
	SUB	C
	LD	(IX+#06),A
	LD	A,(IX+#04)
	SUB	B
	LD	(IX+#04),A
	LD	A,(IX+#05)
	SUB	B
	LD	(IX+#05),A
	LD	A,(IX+#0C)
	SUB	B
	LD	(IX+#0C),A
	LD	A,(IX+#0D)
	SUB	B
	LD	(IX+#0D),A
	LD	A,(IX+#0E)
	SUB	B
	LD	(IX+#0E),A
	RET 

IButton	LD	A,(IX+#02)
	SUB	C
	LD	(IX+#02),A
	LD	A,(IX+#03)
	SUB	C
	LD	(IX+#03),A
	LD	A,(IX+#04)
	SUB	B
	LD	(IX+#04),A
	RET 

IPalBox	LD	A,(IX+#02)
	SUB	C
	LD	(IX+#02),A
	LD	A,(IX+#03)
	SUB	C
	LD	(IX+#03),A
	LD	A,(IX+#04)
	SUB	B
	LD	(IX+#04),A
	LD	A,(IX+#05)
	SUB	B
	LD	(IX+#05),A
	LD	A,(IX+#06)
	SUB	C
	LD	(IX+#06),A
	RET 

ITstCol	LD	A,(IX+#02)
	SUB	C
	LD	(IX+#02),A
	LD	A,(IX+#03)
	SUB	B
	LD	(IX+#03),A
	RET 
;[]===========================================================[]
 _mCollectInfo_addEnd
