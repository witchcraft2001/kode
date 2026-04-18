 _mCollectInfo_addStart
;[]===========================================================[]
TextLine   EQU	#01
InputLine  EQU	#02
ClRadioBut EQU	#03
ClCheckBut EQU	#04
ListBox	   EQU	#05
FileInput  EQU	#06
FileBox	   EQU	#07
FileInfo   EQU	#08
Button	   EQU	#09
ProcesLine EQU	#0A
PalleteBox EQU	#0B
TestColor  EQU	#0C
PResident1 EQU	#0D
PResident2 EQU	#0E
;[]===========================================================[]
; Procedure and printing window
; On: HL - descriptor
PutDialWn
	PUSH	IY
	LD	IY,DialTab
	LD	IX,DialData
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)	;Page buffer
	OUT	(SLOT3),A
	LD	A,(HL)		;X position
	LD	(IX+#00),A	;Xpos
	INC	HL
	LD	A,(HL)		;Y position
	LD	(IX+#01),A	;Ypos
	INC	HL
	LD	A,(HL)		; Len x
	LD	(IX+#02),A	;Xlen
	INC	HL
	LD	A,(HL)		; Len y
	LD	(IX+#03),A	;Ylen
	INC	HL
	LD	DE,DialName
	LDI 
	LD	A,(HL)
	OR	A
	JR	NZ,$-4
	LDI 
	PUSH	HL
	CALL	SavDial		;Save dialog place
	CALL	PutDialRc
	LD	HL,FramDSl
	CALL	PutDialFr	; Put dialog frame & name
	CALL	PutDialSh
	LD	A,(IX+#00)	; Move window
	LD	(IY+#00),A
	INC	IY
	ADD	A,(IX+#02)
	LD	(IY+#00),A
	INC	IY
	LD	A,(IX+#01)
	LD	(IY+#00),A
	INC	IY
	LD	A,(IX+#00)	; Coords [*]
	ADD	A,#03
	LD	(IY+#00),A
	INC	IY
	LD	A,(IX+#01)
	LD	(IY+#00),A
	INC	IY
	POP	HL
DialCyc	LD	A,(HL)		;Next get includes objects
	INC	HL
	BIT	7,A
	JR	NZ,DialExt	;End dialog label
	LD	DE,DialCyc
	PUSH	DE
	CP	TextLine
	JP	Z,PTextLn	;Put text line
	CP	InputLine
	JP	Z,PInpLine	;Put object input line
	CP	ClRadioBut
	JP	Z,PClRadioB	;Put claster radio buttons
	CP	ClCheckBut
	JP	Z,PClCheckB	;Put claster check buttons
	CP	FileInput
	JP	Z,PFileInp	; Put file input line
	CP	FileBox
	JP	Z,PFileBox	; Put file box
	CP	FileInfo
	JP	Z,PFileInfo	; Put file input line
	CP	ListBox
	JP	Z,PListBox	; Put list box
	CP	Button
	JP	Z,PButton	;Put button
	CP	ProcesLine
	JP	Z,PProcess
	CP	PalleteBox
	JP	Z,PPallete
	CP	TestColor
	JP	Z,PTestCol
	CP	PResident1
	JP	Z,PResid1
	CP	PResident2
	JP	Z,PResid2
	POP	DE

DialExt	LD	(IY+#00),#80	;End dialog table
	POP	AF
	OUT	(SLOT3),A
	CALL	PutDial		;Put dialog window
	POP	IY
; Select last element
SelLast	LD	HL,DialTab+5
	LD	D,#00
SelEndL	LD	E,(HL)
	ADD	HL,DE
	BIT	7,(HL)
	JR	Z,SelEndL
	OR	A
	SBC	HL,DE		; Hl-address last object
	LD	DE,ReCompBuff
	LD	B,#00
	LD	C,(HL)
	LD	A,C
	LDIR 
	LD	C,A
	DEC	HL
	LD	E,L
	LD	D,H
	OR	A
	SBC	HL,BC
	PUSH	HL
	LD	BC,DialTab+4
	OR	A
	SBC	HL,BC
	LD	C,L
	LD	B,H
	POP	HL
	LD	A,B
	OR	C
	JR	Z,$+4
	LDDR 
	LD	HL,ReCompBuff
	LD	DE,DialTab+5
	LD	C,(HL)
	LDIR 
	SUB	A
	LD	(CIflag+1),A
	LD	IX,DialTab+5
	LD	HL,DIALe
	PUSH	HL
	LD	A,(IX+#01)
	SET	7,(IX+#01)
	CP	InputLine
	JR	Z,InpLineI
	CP	ClRadioBut
	JR	Z,ClastI
	CP	ClCheckBut
	JR	Z,ClastI
	CP	ListBox
	JR	Z,PLstBoxI
	CP	FileBox
	JR	Z,PLstBoxI
	CP	PalleteBox
	JR	Z,PLstBoxI
	CP	Button
	JR	Z,ButtonI
	CP	FileInput
	JR	Z,InpLineI
	POP	HL
DIALe	LD	A,#01
	RST	#00
	RET 

InpLineI
	LD	E,(IX+#02)	;Xo
	LD	D,(IX+#04)	;Y
	LD	A,(IX+#05)	;Xi text
	SUB	E
	LD	C,A		;Len text
	CALL	SetDialInv
	LD	A,(IX+#08)
	CALL	PutStatusLn
	LD	DE,(CursPos)
	CALL	PILCurs
	EI 
	RET 

ClastI	LD	E,(IX+#02)	;Xo
	INC	E
	LD	D,(IX+#04)	;Y
	LD	A,(IX+#06)	;Xi name
	SUB	E
	LD	C,A
	CALL	SetDialInv
	LD	E,(IX+#02)	;Xo
	INC	E
	LD	D,(IX+#07)	;Y elem
	LD	A,(IX+#03)
	SUB	E
	DEC	A
	LD	C,A		; Len x
	CALL	SetClasInv
	LD	A,(IX+#09)
	CALL	PutStatusLn
	RET 

ButtonI
	LD	E,(IX+#02)	;Xo
	LD	D,(IX+#04)	;Y
	LD	A,(IX+#03)	;Xi
	SUB	E
	LD	C,A
	CALL	SetDialInv
	LD	A,(IX+#07)
	CALL	PutStatusLn
	RET 

PLstBoxI:
	LD	E,(IX+#02)	;Xo
	INC	E
	LD	D,(IX+#04)	;Y
	LD	A,(IX+#06)	;Xi
	SUB	E
	LD	C,A
	CALL	SetDialInv
	LD	A,(IX+#0F)
	CALL	PutStatusLn
	CALL	StLstBoxI
	RET 

FramDSl:
	DEFB	_WINDOWisSelected	; Window
; window frame sample string
	DEFW	ColDialFr	; Its color
FramDMv:
	DEFB	_WINDOWisMoving	; Window
	DEFW	ColDialFrM

; Procedure. window
; On: IX - descriptor
PutDialRc
	LD	HL,WinBoxBuff+4800
	LD	B,(IX+#03)	; Len y
	LD	C,(IX+#02)	; Len x
	LD	E,#20
	LD	A,(ColDialWn)	; Window color
PutRc1	LD	D,C
	LD	(HL),E
	INC	HL
	LD	(HL),A
	INC	HL
	DEC	D
	JR	NZ,$-5
	INC	HL	; Place for shadow
	INC	HL
	INC	HL
	INC	HL
	DJNZ	PutRc1
	RET 

; Procedure on. window
; On: IX - descriptor
; HL - descriptor
PutDialFr
	PUSH	IY
	PUSH	HL
	POP	IY
	LD	HL,WinBoxBuff+4800
	LD	C,(IY+#08)
	LD	B,(IY+#09)
	LD	A,(BC)
	LD	C,A
	LD	A,(ColDialWn)
	AND	#F0
	OR	C
	LD	C,A
	LD	A,(IY+#00)
	LD	(HL),A		; First line
	INC	HL
	LD	(HL),C
	INC	HL
	LD	B,(IX+#02)	; Len dialx
	DEC	B
	DEC	B
	LD	A,(IY+#04)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	LD	A,(IY+#01)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL

	LD	E,(IX+#02)	; Lenx
	DEC	E
	DEC	E
	LD	D,B
	LD	B,(IX+#03)	; Leny
	DEC	B
	DEC	B
	LD	A,(IY+#05)
DialFMn	LD	(HL),A		; Middle space window
	INC	HL
	LD	(HL),C
	INC	HL
	ADD	HL,DE
	ADD	HL,DE
	LD	(HL),A		; Middle space window
	INC	HL
	LD	(HL),C
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	DJNZ	DialFMn

	LD	A,(IY+#02)
	LD	(HL),A		; End line
	INC	HL
	LD	(HL),C
	INC	HL
	LD	B,(IX+#02)	; Len x
	DEC	B
	DEC	B
	LD	A,(IY+#04)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	LD	A,(IY+#03)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL

	LD	HL,DialName
	LD	E,L	; De=dial label
	LD	D,H
	LD	B,#01
	INC	B		; B=len name+2 (for space)
	LD	A,(HL)
	INC	HL
	OR	A		; 0-end name
	JR	NZ,$-4
	LD	HL,WinBoxBuff+4800
	PUSH	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	A,(IY+#06)
	LD	(HL),A		;Put [*]
	INC	HL
	INC	HL
	LD	(HL),#FE
	INC	HL
	LD	A,(ColWindAtr)
	LD	C,A
	LD	A,(HL)
	AND	#F0
	OR	C
	LD	(HL),A
	INC	HL
	LD	A,(IY+#07)
	LD	(HL),A
	POP	HL
	LD	A,(IX+#02)	; Len x
	SUB	B		; Lenx-len name=len empty
	SRL	A		;Len empty/2=shift
	LD	C,A
	LD	B,0
	ADD	HL,BC		; Get address name place
	ADD	HL,BC
	LD	(HL),#20
	INC	HL
	INC	HL
	EX	DE,HL		; Hl=adr.name,de=adr.place
	LDI			;Move
	INC	DE		; Attrib place
	LD	A,(HL)
	OR	A		; 0-end name
	JR	NZ,$-5
	LD	A,#20
	LD	(DE),A
	POP	IY
	RET 

; Procedure output in shadow window
; On: IX - descriptor
PutDialSh
	LD	HL,WinBoxBuff+4800
	LD	A,(IX+#02)
	LD	E,A
	LD	D,#00
	ADD	HL,DE
	ADD	HL,DE
	EXX 
	LD	E,A		; Window X
	BIT	7,(IX+#00)
	JR	Z,ExShD1	; Screen
	LD	A,(IX+#00)
	NEG		; In and-on how many window for screen
	SUB	E	; Window=-visible part
	NEG 
	LD	E,A	; Visible part
ExShD1	LD	D,#00
	LD	HL,WinBoxBuff
	ADD	HL,DE
	ADD	HL,DE
	LD	A,(HL)		; Line without shadow
	INC	HL
	EXX 
	LD	(HL),A
	INC	HL
	EXX 
	LD	A,(HL)
	INC	HL
	EXX 
	LD	(HL),A
	INC	HL
	EXX 
	LD	A,(HL)
	INC	HL
	EXX 
	LD	(HL),A
	INC	HL
	EXX 
	LD	A,(HL)
	INC	HL
	EXX 
	LD	(HL),A
	INC	HL
; Window
	LD	B,(IX+#03)	; Window Y-1
	DEC	B
DShadLp	ADD	HL,DE
	ADD	HL,DE
	EXX 
	ADD	HL,DE
	ADD	HL,DE
	LD	A,(HL)
	INC	HL
	EXX 
	LD	(HL),A
	INC	HL
	EXX 
	LD	A,(HL)
	INC	HL
	EXX 
	AND	#07
	JR	NZ,$+4
	LD	A,#07
	LD	(HL),A
	INC	HL
	EXX 
	LD	A,(HL)
	INC	HL
	EXX 
	LD	(HL),A
	INC	HL
	EXX 
	LD	A,(HL)
	INC	HL
	EXX 
	AND	#07
	JR	NZ,$+4
	LD	A,#07
	LD	(HL),A
	INC	HL
	DJNZ	DShadLp
	ADD	HL,DE	; For shadow
	ADD	HL,DE
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	EXX 
	ADD	HL,DE	; Internal operation
	ADD	HL,DE
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	EXX 
	LD	B,E
DShadL1	EXX 
	DEC	HL	; With end
	LD	A,(HL)
	EXX 
	DEC	HL
	AND	#07
	JR	NZ,$+4
	LD	A,#07
	LD	(HL),A
	EXX 
	DEC	HL
	LD	A,(HL)
	EXX 
	DEC	HL
	LD	(HL),A
	DJNZ	DShadL1
	EXX		; Without
	DEC	HL
	LD	A,(HL)
	EXX 
	DEC	HL
	LD	(HL),A
	EXX 
	DEC	HL
	LD	A,(HL)
	EXX 
	DEC	HL
	LD	(HL),A
	EXX 
	DEC	HL
	LD	A,(HL)
	EXX 
	DEC	HL
	LD	(HL),A
	EXX 
	DEC	HL
	LD	A,(HL)
	EXX 
	DEC	HL
	LD	(HL),A
	RET 
;Get put address in memory
; Input: bc - coords from begin window
; Output:de - address put place
GetPutA	PUSH	HL
	LD	HL,WinBoxBuff+4800
	LD	A,(IX+#02)	; Len x-2
	ADD	A,#02		;Full len with shadow
	ADD	A,A		;With attributs
	LD	E,A		; Lenx in bytes
	LD	D,#00
	LD	A,B
	OR	A
	JR	Z,$+5
	ADD	HL,DE
	DJNZ	$-1
	LD	E,C		;$+5
	ADD	HL,DE		; De-shiftx
	ADD	HL,DE
	EX	DE,HL		; De-address
	POP	HL
	RET 

SavDial	PUSH	IX
	CALL	ResCurs
	LD	A,(IX+#02)	; With shadow
	ADD	A,#02
	LD	L,A
	LD	A,(IX+#03)
	INC	A
	LD	H,A		;Wind len
	LD	E,(IX+#00)
	LD	D,(IX+#01)
	CALL	ExCoordG
	EXX 
	CALL	GetMousInfo
	EXX 
	LD	IX,WinBoxBuff	; Address box buffers
	LD	A,(BuffPg5)	;Page buffer
	LD	B,A
	LD	C,#B2
	SUB	A
	RST	#10
	CALL	GetMousInfo
	POP	IX
	RET 

PutDial	PUSH	IX
	LD	A,(IX+#02)	; With shadow
	ADD	A,#02
	LD	L,A
	LD	A,(IX+#03)
	INC	A
	LD	H,A		;Wind len
	LD	E,(IX+#00)
	LD	D,(IX+#01)
	LD	IX,WinBoxBuff+4800 ; Address box buffers
	CALL	ExmOutD
	EXX 
	CALL	GetMousInfo
	EXX 
	LD	A,(BuffPg5)	;Page buffer
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	CALL	GetMousInfo
	LD	A,#01
	RST	#00
	POP	IX
	RET 

; Close dialog window and restore box place
ClsDial	CALL	ResILCr		;Res cursor
	LD	IX,DialData
	LD	A,(IX+#02)	; With shadow
	ADD	A,#02
	LD	L,A
	LD	A,(IX+#03)
	INC	A
	LD	H,A		;Wind len
	LD	E,(IX+#00)
	LD	D,(IX+#01)
	CALL	ExCoordG
	EXX 
	CALL	GetMousInfo
	EXX 
	LD	IX,WinBoxBuff	 ; Address box buffers
	LD	A,(BuffPg5)	;Page buffer
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	CALL	GetMousInfo
	LD	A,#01
	RST	#00
	RET 
; Coordinates on validity
ExmOutD	BIT	7,E		;Xo pos
	CALL	NZ,OutScLD	; Start window for screen
	LD	A,E
	ADD	A,L		; +len x
	CP	#53		; Test by out for x pos
	CALL	NC,OutScRD	; Window for screen
	LD	A,D		;Yo pos
	ADD	A,H		; +len y
	CP	#1F
	RET	C		; Okey
	LD	A,#1F
	SUB	D
	LD	H,A		; Normal len y
	RET 
; Coordinates start window
OutScLD	LD	A,E
	NEG		; In and-on how many window for screen
	LD	C,A	; Save
	SUB	L	; Window=-visible part
	NEG 
	LD	L,A	; Visible part
	LD	E,#00
	PUSH	HL
	PUSH	DE
	SLA	C
	LD	B,#00	; BC=offset from start window (with )
	LD	(do1+1),BC
	LD	B,H		; Len y
	SLA	L
	LD	H,#00	; HL=
	LD	A,L
	LD	(do2+1),A
	LD	(do3+1),HL
	LD	HL,WinBoxBuff+4800
	LD	DE,WinBoxBuff+10200  ; In new
	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
OutDlp0	PUSH	BC
do1	LD	BC,#0000
	ADD	HL,BC	; Internal operation
	LD	D,D
do2	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
do3	LD	BC,#0000
	ADD	HL,BC
	EX	DE,HL
	ADD	HL,BC	; Line window ()
	EX	DE,HL
	POP	BC
	DJNZ	OutDlp0
	EI 
	POP	DE
	POP	HL
	LD	IX,WinBoxBuff+10200
	RET 
; Window for screen
OutScRD	PUSH	DE
	LD	A,#50
	SUB	E
	LD	C,L
	SLA	C
	LD	L,A
	ADD	A,A
	LD	E,A
	LD	(dr1+1),A
	LD	D,#00	; DE= by X
	LD	B,D	; BC= by X
	LD	(dr2+1),DE
	LD	(dr3+1),BC
	PUSH	HL
	LD	B,H	; Len y
	LD	HL,WinBoxBuff+4800
	LD	DE,WinBoxBuff+10200 ; In new
	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
OutDlp1	PUSH	BC
	LD	D,D
dr1	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
dr2	LD	BC,#0000
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
dr3	LD	BC,#0000
	ADD	HL,BC
	POP	BC
	DJNZ	OutDlp1
	EI 
	POP	HL
	POP	DE
	LD	IX,WinBoxBuff+10200
	RET 
;[]===========================================================[]
;Put object "input line"
; Input: hl-label
; Format mouse table:
; +0 - object ~input line~
; +1 - xo position object
; +2 - xi position object
; +3 - y position object
; +4 - xi position text
; +5 - xo position input line
; +6 - hot keys
; +7 - context
; +8,9 - address input buffer
PInpLine
	PUSH	IY
	INC	IY
	LD	(IY+#00),A		;+0 object
	LD	A,(HL)	;X pos
	INC	HL
	LD	C,A
	ADD	A,(IX+#00)	; Pos x from begin screen
	LD	(IY+#01),A		; +1 xo
	LD	(IX+#04),A		; Temp x coord
	LD	A,(HL)	;Y pos
	INC	HL
	LD	B,A
	ADD	A,(IX+#01)	; Pos y from begin screen
	LD	(IY+#03),A		; +3 yo
	CALL	GetPutA
	EX	DE,HL
	LD	A,(ColDialWn)
	LD	C,A
	LD	A,(DE)
PInpLp1	INC	DE
	CP	"~"
	JR	NZ,PInpN0
	LD	A,(ColDhotkey)
	LD	C,A
	LD	A,(DE)
	INC	DE
	LD	(HL),A
	INC	HL
	RES	5,A
	LD	(IY+#06),A	;Hot key
	LD	A,(HL)
	AND	#F0
	OR	C
	LD	(HL),A
	INC	HL
	INC	DE
	INC	(IX+#04)
	LD	A,(ColDialWn)
	LD	C,A
	LD	A,(DE)
	INC	DE
PInpN0	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	INC	(IX+#04)
	LD	A,(DE)
	OR	A
	JR	NZ,PInpLp1
	EX	DE,HL
	INC	HL
	LD	A,(IX+#04)
	LD	(IY+#04),A	;Xi position text
	LD	A,(IX+#04)
	LD	(IY+#05),A	;Xi position input line
	LD	(next1+1),DE
	LD	B,(HL)		; Len input line
	INC	HL
	LD	A,(HL)		; Context
	INC	HL
	LD	(IY+#07),A
	LD	E,(HL)		; De-address input buffer
	LD	(IY+#08),E
	INC	HL
	LD	D,(HL)
	LD	(IY+#09),D
	INC	HL
	LD	A,(DE)
	INC	DE
	SUB	A
	INC	A
	LD	(DE),A		;Ready
	DEC	A
	INC	DE
	LD	(DE),A		; Pos x
	INC	DE
	LD	(DE),A		; Add x
	INC	DE
	INC	DE
	PUSH	HL
next1	LD	HL,#0000
	LD	A,(ColInpLine)
	LD	C,A
PInpLp2	LD	A,(DE)
	INC	DE
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	INC	(IX+#04)
	DJNZ	PInpLp2
	POP	HL
	LD	E,(IY+#05)
	LD	D,(IY+#03)
	LD	(CursPos),DE
	LD	A,(IX+#04)
	LD	(IY+#02),A	;Xi position object
	LD	BC,#000A
	ADD	IY,BC		; Iy-next element
	PUSH	IY
	EXX			;Len label objects
	POP	HL
	POP	DE
	OR	A
	SBC	HL,DE
	LD	A,L
	LD	(DE),A
	EXX 
	RET 

; Object ~claster radio buttons~
; Input: hl-label
; Format mouse table:
; +0 - object ~claster radio buttons"
; +1 - xo position object
; +2 - xi position object
; +3 - yo position object
; +4 - yi position object
; +5 - xi position name
; From: +0 - y position radio button
; +1 - hot key
; +2 - context
; +3 - (ceil)
; +4,5 - address ceil
; #80 - end buttons
PClRadioB
	PUSH	IY
	INC	IY
	LD	(IY+#00),A
	LD	A,(HL)	;X pos
	INC	HL
	LD	C,A
	LD	(IX+#04),A	; Save x pos
	ADD	A,(IX+#00)	; Pos x from begin screen
	LD	(IY+#01),A		; +1 xo
	LD	A,(HL)	;Y pos
	INC	HL
	LD	B,A
	LD	(IX+#05),A	; Save y pos
	ADD	A,(IX+#01)	; Pos y from begin screen
	LD	(IY+#03),A		; +3 yo
	CALL	GetPutA
	LD	A,(HL)
	INC	HL
	LD	(IX+#06),A
	SUB	#02
	LD	C,A
	LD	B,#00
	ADD	A,#04
	ADD	A,(IY+#01)
	LD	(IY+#02),A	;Xi pos
	LD	A,(HL)
	INC	HL
	ADD	A,#03		;Yi pos
	ADD	A,(IY+#03)
	LD	(IY+#04),A
	LD	A,#DA
	LD	(DE),A
	INC	DE
	INC	DE
	LD	A,#20
	LD	(DE),A
	INC	DE
	INC	DE
	LDI		;$-5
	INC	DE
	LD	A,(HL)
	OR	A
	JR	NZ,$-5
	LD	A,#20
	LD	(DE),A
	INC	DE
	INC	DE
	INC	HL
	LD	A,(IX+#06)
	SUB	C
	INC	A
	ADD	A,(IY+#01)
	LD	(IY+#05),A	; Xi pos name
	LD	A,C
	OR	A
	JR	Z,ClRadN1
	LD	B,C
	LD	A,#C4
	LD	(DE),A
	INC	DE
	INC	DE
	DJNZ	$-3
ClRadN1	LD	A,#BF
	LD	(DE),A
	INC	(IX+#05)
	LD	BC,#0006	;Next element claster
	ADD	IY,BC

	LD	C,(IX+#04)	;Empty string
	LD	B,(IX+#05)
	CALL	GetPutA
	EX	DE,HL
	LD	(HL),#B3
	INC	HL
	INC	HL
	LD	C,(IX+#06)
	LD	B,#00
	ADD	HL,BC
	ADD	HL,BC
	LD	(HL),#B3
	INC	(IX+#05)
	EX	DE,HL

;Next element
ClRadLp	LD	C,(IX+#04)	; Pos element
	LD	B,(IX+#05)
	CALL	GetPutA
	LD	B,#00
	EX	DE,HL
	LD	(HL),#B3
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	B
	LD	(HL),"["
	INC	HL
	INC	HL
	INC	B
	PUSH	HL
	INC	HL
	INC	HL
	INC	B
	LD	(HL),"]"
	INC	HL
	INC	HL
	INC	B
	INC	HL
	INC	HL
	INC	B

	LD	A,(ColDialWn)	;Put name element
	LD	C,A
	LD	A,(DE)
ClRadL1	INC	DE
	CP	"~"
	JR	NZ,ClRadN0
	LD	A,(ColDhotkey)
	LD	C,A
	LD	A,(DE)
	INC	DE
	LD	(HL),A
	INC	HL
	RES	5,A
	LD	(IY+#01),A	;Hot key
	LD	A,(HL)
	AND	#F0
	OR	C
	LD	(HL),A
	INC	HL
	INC	DE
	LD	A,(ColDialWn)
	LD	C,A
	INC	B
	LD	A,(DE)
	INC	DE
ClRadN0	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	INC	B
	LD	A,(DE)
	OR	A
	JR	NZ,ClRadL1
	INC	DE
	LD	A,(IX+#06)
	SUB	B
	LD	C,A
	LD	B,#00
	ADD	HL,BC
	ADD	HL,BC
	LD	(HL),#B3

	LD	A,(IX+#05)	; Current y pos
	ADD	A,(IX+#01)	; From begin screen
	LD	(IY+#00),A
	INC	IY
	INC	IY
	EX	DE,HL
	LD	A,(HL)
	INC	HL
	LD	(IY+#00),A	;Context
	INC	IY
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	A,(BC)
	LD	(IY+#00),A	; (ceil)
	INC	IY
	LD	(IY+#00),C	; Bc=ceil
	INC	IY
	LD	(IY+#00),B
	INC	IY
	POP	BC
	OR	A
	LD	A,#20
	JR	Z,$+4
	LD	A,"X"
	LD	(BC),A
	INC	(IX+#05)
	LD	A,(HL)
	OR	A
	JP	NZ,ClRadLp
	LD	(IY+#00),#80	;End tab claster
	INC	IY
	INC	HL

	LD	C,(IX+#04)	;End string
	LD	B,(IX+#05)
	CALL	GetPutA
	EX	DE,HL
	LD	(HL),#C0
	INC	HL
	INC	HL
	LD	B,(IX+#06)
	LD	A,#C4
	LD	(HL),A
	INC	HL
	INC	HL
	DJNZ	$-3
	LD	(HL),#D9
	EX	DE,HL
	PUSH	IY
	EXX 
	POP	HL
	POP	DE
	OR	A
	SBC	HL,DE
	LD	A,L
	LD	(DE),A
	EXX 
	RET 
; Object ~claster check buttons~
; Input: hl-label
; Format mouse table:
; +0 - object ~claster check buttons"
; +1 - xo position object
; +2 - xi position object
; +3 - yo position object
; +4 - yi position object
; +5 - xi position name
; From: +0 - y position check button
; +1 - hot key
; +2 - context
; +3 - (ceil)
; +4,5 - address ceil
; #80 - end buttons
PClCheckB
	PUSH	IY
	INC	IY
	LD	(IY+#00),A
	LD	A,(HL)	;X pos
	INC	HL
	LD	C,A
	LD	(IX+#04),A	; Save x pos
	ADD	A,(IX+#00)	; Pos x from begin screen
	LD	(IY+#01),A		; +1 xo
	LD	A,(HL)	;Y pos
	INC	HL
	LD	B,A
	LD	(IX+#05),A	; Save y pos
	ADD	A,(IX+#01)	; Pos y from begin screen
	LD	(IY+#03),A		; +3 yo
	CALL	GetPutA
	LD	A,(HL)
	INC	HL
	LD	(IX+#06),A
	SUB	#02
	LD	C,A
	LD	B,#00
	ADD	A,#04
	ADD	A,(IY+#01)
	LD	(IY+#02),A	;Xi pos
	LD	A,(HL)
	INC	HL
	ADD	A,#03		;Yi pos
	ADD	A,(IY+#03)
	LD	(IY+#04),A
	LD	A,#DA
	LD	(DE),A
	INC	DE
	INC	DE
	LD	A,#20
	LD	(DE),A
	INC	DE
	INC	DE
	LDI		;$-5
	INC	DE
	LD	A,(HL)
	OR	A
	JR	NZ,$-5
	LD	A,#20
	LD	(DE),A
	INC	DE
	INC	DE
	INC	HL
	LD	A,(IX+#06)
	SUB	C
	INC	A
	ADD	A,(IY+#01)
	LD	(IY+#05),A	; Xi pos name
	LD	A,C
	OR	A
	JR	Z,ClChkN1
	LD	B,C
	LD	A,#C4
	LD	(DE),A
	INC	DE
	INC	DE
	DJNZ	$-3
ClChkN1	LD	A,#BF
	LD	(DE),A
	INC	(IX+#05)
	LD	BC,#0006	;Next element claster
	ADD	IY,BC

	LD	C,(IX+#04)	;Empty string
	LD	B,(IX+#05)
	CALL	GetPutA
	EX	DE,HL
	LD	(HL),#B3
	INC	HL
	INC	HL
	LD	C,(IX+#06)
	LD	B,#00
	ADD	HL,BC
	ADD	HL,BC
	LD	(HL),#B3
	INC	(IX+#05)
	EX	DE,HL

;Next element
ClChkLp	LD	C,(IX+#04)	; Pos element
	LD	B,(IX+#05)
	CALL	GetPutA
	LD	B,#00
	EX	DE,HL
	LD	(HL),#B3
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	B
	LD	(HL),"("
	INC	HL
	INC	HL
	INC	B
	PUSH	HL
	INC	HL
	INC	HL
	INC	B
	LD	(HL),")"
	INC	HL
	INC	HL
	INC	B
	INC	HL
	INC	HL
	INC	B

	LD	A,(ColDialWn)	;Put name element
	LD	C,A
	LD	A,(DE)
ClChkL1	INC	DE
	CP	"~"
	JR	NZ,ClChkN0
	LD	A,(ColDhotkey)
	LD	C,A
	LD	A,(DE)
	INC	DE
	LD	(HL),A
	INC	HL
	RES	5,A
	LD	(IY+#01),A	;Hot key
	LD	A,(HL)
	AND	#F0
	OR	C
	LD	(HL),A
	INC	HL
	INC	DE
	LD	A,(ColDialWn)
	LD	C,A
	INC	B
	LD	A,(DE)
	INC	DE
ClChkN0	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	INC	B
	LD	A,(DE)
	OR	A
	JR	NZ,ClChkL1
	INC	DE
	LD	A,(IX+#06)
	SUB	B
	LD	C,A
	LD	B,#00
	ADD	HL,BC
	ADD	HL,BC
	LD	(HL),#B3

	LD	A,(IX+#05)	; Current y pos
	ADD	A,(IX+#01)	; From begin screen
	LD	(IY+#00),A
	INC	IY
	INC	IY
	EX	DE,HL
	LD	A,(HL)
	INC	HL
	LD	(IY+#00),A	;Context
	INC	IY
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	A,(BC)
	LD	(IY+#00),A	; (ceil)
	INC	IY
	LD	(IY+#00),C	; Bc=ceil
	INC	IY
	LD	(IY+#00),B
	INC	IY
	POP	BC
	OR	A
	LD	A,#20
	JR	Z,$+4
	LD	A,#07
	LD	(BC),A
	INC	(IX+#05)
	LD	A,(HL)
	OR	A
	JP	NZ,ClChkLp
	LD	(IY+#00),#80	;End tab claster
	INC	IY
	INC	HL

	LD	C,(IX+#04)	;End string
	LD	B,(IX+#05)
	CALL	GetPutA
	EX	DE,HL
	LD	(HL),#C0
	INC	HL
	INC	HL
	LD	B,(IX+#06)
	LD	A,#C4
	LD	(HL),A
	INC	HL
	INC	HL
	DJNZ	$-3
	LD	(HL),#D9
	EX	DE,HL
	PUSH	IY
	EXX 
	POP	HL
	POP	DE
	OR	A
	SBC	HL,DE
	LD	A,L
	LD	(DE),A
	EXX 
	RET 
 _mCollectInfo_addEnd