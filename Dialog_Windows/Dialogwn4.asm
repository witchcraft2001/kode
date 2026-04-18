 _mCollectInfo_addStart
;[]===========================================================[]
; Setting dialog invert objects
;Input :
; E - x pos
; D - y pos
; C - x len
SetDialInv
	PUSH	IX
	LD	IX,DialData
	IN	A,(SLOT3)
	PUSH	AF		; Save.page4
	LD	A,(BuffPg5)
	OUT	(SLOT3),A		; Enable
	LD	L,C
	LD	H,#01
	LD	(RDlIlen+1),HL	;Save len
	LD	(RDlIpos+1),DE	;Save pos
	LD	A,E
	SUB	(IX+#00)
	LD	C,A
	LD	A,D
	SUB	(IX+#01)
	LD	B,A
	CALL	GetPutA
	EX	DE,HL
	LD	(RDlIbuf+2),HL
	LD	B,E
	LD	A,(ColDialInv)
	LD	E,A
	LD	A,(ColDhotkey)
	LD	D,A
SetDin1	INC	HL
	LD	A,(HL)
	AND	#0F
	CP	D
	JR	Z,$+5
	LD	A,(HL)
	XOR	E
	LD	(HL),A
	INC	HL
	DJNZ	SetDin1
	LD	IX,(RDlIbuf+2)	       ; Put name with invert
	LD	HL,(RDlIlen+1)
	LD	DE,(RDlIpos+1)
	CALL	PutDialLn
	POP	AF
	OUT	(SLOT3),A
	POP	IX
	RET 
;Set claster buttons invert
;Input :
; E - x pos
; D - y pos
; C - x len
SetClasInv
	PUSH	IX
	LD	IX,DialData
	IN	A,(SLOT3)
	PUSH	AF		; Save.page4
	LD	A,(BuffPg5)
	OUT	(SLOT3),A		; Enable
	PUSH	HL
	LD	L,C		; Len x
	LD	H,#01		; Len y
	LD	(RClIlen+1),HL	;Save len
	LD	(RClIpos+1),DE	;Save pos
	LD	A,E
	SUB	(IX+#00)
	LD	C,A
	LD	A,D
	SUB	(IX+#01)
	LD	B,A
	CALL	GetPutA
	EX	DE,HL
	LD	(RClIbuf+2),HL
	LD	B,E
	LD	A,(ColDialInv)
	LD	E,A
	LD	A,(ColDhotkey)
	LD	D,A
SetDin2	INC	HL
	LD	A,(HL)
	AND	#0F
	CP	D
	JR	Z,$+5
	LD	A,(HL)
	XOR	E
	LD	(HL),A
	INC	HL
	DJNZ	SetDin2
	LD	IX,(RClIbuf+2)	       ; Put name with invert
	LD	HL,(RClIlen+1)
	LD	DE,(RClIpos+1)
	CALL	PutDialLn
	POP	HL
	POP	AF
	OUT	(SLOT3),A
	POP	IX
	LD	E,(IX+#02)	; Xo pos element
	INC	E
	INC	E
	INC	E
	LD	D,(HL)		;Y pos element
	LD	(CursPos),DE
	PUSH	HL
	CALL	PILCurs		;Set cursor
	POP	HL
	LD	A,#01
	LD	(CIflag+1),A
	RET 
;Res dialog invert objects
; Input: none
ResDialInv
	PUSH	IX
	IN	A,(SLOT3)
	PUSH	AF		; Save.page4
	LD	A,(BuffPg5)
	OUT	(SLOT3),A		; Enable
	LD	HL,(RDlIbuf+2)
	LD	A,(RDlIlen+1)
	LD	B,A
	LD	A,(ColDialInv)
	LD	E,A
	LD	A,(ColDhotkey)
	LD	D,A
ResDin1	INC	HL
	LD	A,(HL)
	AND	#0F
	CP	D
	JR	Z,$+5
	LD	A,(HL)
	XOR	E
	LD	(HL),A
	INC	HL
	DJNZ	ResDin1
RDlIbuf	LD	IX,#0000	       ; Put name with invert
RDlIlen	LD	HL,#0000
RDlIpos	LD	DE,#0000
	CALL	PutDialLn
CIflag	LD	A,#00			; 1-was claster invert
	OR	A
	CALL	NZ,ResClasInv
	CALL	ResILCr		;Res inp.line cursor
	POP	AF
	OUT	(SLOT3),A
	POP	IX
	LD	HL,what
	LD	(HL),evMessage
	INC	HL
	LD	(HL),msHiddInvr
	JP	TransMessage
; Res claster invert
; Input: none
ResClasInv
	PUSH	IX
	IN	A,(SLOT3)
	PUSH	AF		; Save.page4
	LD	A,(BuffPg5)
	OUT	(SLOT3),A		; Enable
	PUSH	HL
	LD	HL,(RClIbuf+2)
	LD	A,(RClIlen+1)
	LD	B,A
	LD	A,(ColDialInv)
	LD	E,A
	LD	A,(ColDhotkey)
	LD	D,A
ResDin2	INC	HL
	LD	A,(HL)
	AND	#0F
	CP	D
	JR	Z,$+5
	LD	A,(HL)
	XOR	E
	LD	(HL),A		;+6
	INC	HL
	DJNZ	ResDin2
RClIbuf	LD	IX,#0000	       ; Put name with invert
RClIlen	LD	HL,#0000
RClIpos	LD	DE,#0000
	CALL	PutDialLn
	CALL	ResILCr	;Res cursor
	SUB	A
	LD	(CIflag+1),A
	POP	HL
	POP	AF
	OUT	(SLOT3),A
	POP	IX
	RET 
;[]===========================================================[]
PutDialLn
	LD	A,D
	CP	#1F
	RET	NC
	BIT	7,E
	JR	Z,pdln
	LD	A,E
	LD	E,#00
	NEG 
	LD	C,A
	SUB	L
	NEG 
	LD	L,A
	RET	Z
	RET	M
	LD	A,C
	ADD	A,A
	ADD	A,LX
	LD	LX,A
	JR	NC,pdln
	INC	HX
pdln	LD	A,E
	CP	#50
	RET	NC
	ADD	A,L
	CP	#50
	JR	C,$+6
	LD	A,#50
	SUB	E
	LD	L,A
	LD	A,(BuffPg5)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	RET 
;[]===========================================================[]
; Put input line in window
PrnInLn	LD	A,(CurILFl)
	PUSH	AF
	CALL	ResILCr
	LD	HL,#0000
	LD	E,(IX+#06)	; Xo pos inp.line
	LD	D,(IX+#04)	;Y pos object
	BIT	7,(IX+#03)
	JP	NZ,prne
	BIT	7,E
	JR	Z,$+7
	LD	A,E
	NEG 
	LD	L,A
	LD	E,H
	LD	A,E
	CP	#50
	JR	NC,prne
	LD	A,D
	CP	#1F
	JR	NC,prne
	LD	(prnadd+1),HL
	LD	C,#84
	RST	#10
	LD	L,(IX+#09)	;Address buffer
	LD	H,(IX+#0A)
	LD	A,(IY+#03)
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	A,(IX+#03)	; Xi-xo(inp.ln.)=len inp.ln.
	SUB	(IX+#06)
	LD	E,A
	LD	C,A
	LD	B,A
	LD	A,(IX+#06)
	ADD	A,C
	CP	#51
	JR	C,$+8
	LD	A,#50
	SUB	(IX+#06)
	LD	B,A
	BIT	7,(IX+#06)
	JR	Z,$+11
	LD	A,(IX+#06)
	NEG 
	SUB	C
	NEG 
	LD	B,A
	PUSH	BC
	SUB	A
	LD	B,E
	LD	DE,CompBuff
	PUSH	DE
	LD	(DE),A
	INC	DE
	DJNZ	$-2
	LD	A,(IY+#00)
	SUB	(IY+#03)
	CP	C
	JR	NC,$+3
	LD	C,A
	LD	B,#00
	LD	A,(IY+#04)
	SUB	C
	JR	NC,$+4
	ADD	A,C
	LD	C,A
	POP	DE
	PUSH	DE
	LD	A,B
	OR	C
	JR	Z,$+4
	LDIR 
	POP	HL
	POP	BC
prnadd	LD	DE,#0000
	ADD	HL,DE
	LD	A,B
	OR	A
	JR	Z,prne
	LD	C,#86
	RST	#10
prne	LD	A,(IY+#02)
	ADD	A,(IX+#06)
	LD	E,A
	LD	D,(IX+#04)
	LD	(CursPos),DE
	POP	AF
	OR	A
	CALL	NZ,PILCurs
	EI 
	PUSH	IY
	LD	IY,DialData
	LD	A,(IX+#06)
	SUB	(IY+#00)
	LD	C,A
	LD	A,(IX+#04)
	SUB	(IY+#01)
	LD	B,A
	POP	IY
	PUSH	IX
	LD	IX,DialData
	CALL	GetPutA
	POP	IX
	LD	HL,CompBuff
	LD	A,(IX+#03)	; Xi-xo(inp.ln.)=len inp.ln.
	SUB	(IX+#06)
	LD	C,A
	LD	B,#00
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	LDI 
	INC	DE
	JP	PE,$-3
	POP	AF
	OUT	(SLOT3),A
	RET 
;[]===========================================================[]
; Change buttons
; Input parameters: hl-address claster element label
ChangeB	LD	A,(IX+#01)
	RES	7,A
	CP	ClRadioBut
	JP	Z,ChangeR
; Change check button
	LD	E,L
	LD	D,H
	PUSH	IX
	POP	HL
	LD	BC,#0007
	ADD	HL,BC
	PUSH	HL	;Save cur.elem
ChangL1	INC	HL	; Begin elements claster
	INC	HL
	INC	HL
	LD	(HL),B	; (ceil)=0
	INC	HL
	INC	HL
	INC	HL
	BIT	7,(HL)
	JR	Z,ChangL1
	EX	DE,HL	; Hl=current element claster
	INC	B
	INC	HL
	INC	HL
	INC	HL
	LD	(HL),B	;Cur.elem=1
	INC	HL
	INC	HL
	INC	HL
	POP	HL	;Reset begin elem table
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
ChangL2	LD	D,(HL)	;Ypos
	INC	HL
	INC	HL
	INC	HL
	LD	A,(HL)	;Address ceil
	INC	HL
	INC	HL
	INC	HL
	LD	E,(IX+#02)	;X pos
	INC	E
	INC	E
	INC	E
	PUSH	IX
	PUSH	DE
	LD	IX,DialData
	EX	AF,AF'
	LD	A,E
	SUB	(IX+#00)
	LD	C,A
	LD	A,D
	SUB	(IX+#01)
	LD	B,A
	CALL	GetPutA
	EX	AF,AF'
	LD	C,A
	OR	A
	LD	A,#20
	JR	Z,$+4
	LD	A,#07
	LD	(DE),A
	POP	DE
	POP	IX
	LD	A,D
	CP	#1F
	JR	NC,cl1
	BIT	7,E
	JR	NZ,cl1
	LD	A,E
	CP	#50
	JR	NC,cl1
	PUSH	HL
	LD	A,C
	PUSH	AF
	LD	C,#84	;Set position print
	RST	#10
	POP	AF
	OR	A
	LD	A,#20
	JR	Z,$+4
	LD	A,#07
	LD	BC,#0182
	RST	#10	; Print by/off
	POP	HL
cl1	BIT	7,(HL)
	JR	Z,ChangL2
	CALL	ResILCr		;Res cursor
	CALL	PILCurs		;Set cursor
	EI 
	POP	AF
	OUT	(SLOT3),A
	RET 
; Change radio button
ChangeR	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	LD	D,(HL)	;Ypos
	INC	HL
	INC	HL
	INC	HL
	LD	A,(HL)	;Address ceil
	XOR	#01
	LD	(HL),A
	INC	HL
	INC	HL
	INC	HL
	LD	E,(IX+#02)	;Xpos
	INC	E
	INC	E
	INC	E
	PUSH	IX
	PUSH	DE
	LD	IX,DialData
	EX	AF,AF'
	LD	A,E
	SUB	(IX+#00)
	LD	C,A
	LD	A,D
	SUB	(IX+#01)
	LD	B,A
	CALL	GetPutA
	EX	AF,AF'
	LD	C,A
	OR	A
	LD	A,#20
	JR	Z,$+4
	LD	A,"X"
	LD	(DE),A
	POP	DE
	POP	IX
	LD	A,D
	CP	#1F
	JR	NC,cl2
	BIT	7,E
	JR	NZ,cl2
	LD	A,E
	CP	#50
	JR	NC,cl2
	LD	A,C
	PUSH	AF
	LD	C,#84	;Set position print
	RST	#10
	POP	AF
	OR	A
	LD	A,#20
	JR	Z,$+4
	LD	A,"X"
	LD	BC,#0182
	RST	#10	;Print
cl2	CALL	ResILCr
	CALL	PILCurs
	EI 
	POP	AF
	OUT	(SLOT3),A
	RET 
;[]===========================================================[]
RsLstBoxI
	PUSH	AF
	LD	A,(ColListBox)
	CALL	LstBoxInv
	POP	AF
	RET 
HdLstBoxI
	LD	A,(ColLstBxHI)
	JR	LstBoxInv
StLstBoxI
	LD	A,(ColLstBoxI)
LstBoxInv
	LD	(lbcolor+1),A
	PUSH	IY
	PUSH	IX
	PUSH	IX
	POP	IY
	LD	IX,DialData
	LD	A,(IY+#02)
	SUB	(IX+#00)
	INC	A
	LD	C,A
	LD	A,(IY+#04)
	SUB	(IX+#01)
	INC	A
	ADD	A,(IY+#07)
	LD	B,A
	CALL	GetPutA
	PUSH	DE
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	LD	A,(IY+#03)
	SUB	(IY+#02)
	SUB	#03
	LD	L,A
	LD	H,#01
	LD	B,L
lbcolor	LD	A,#00
	INC	DE
	LD	(DE),A
	INC	DE
	DJNZ	$-3
	POP	AF
	OUT	(SLOT3),A
	POP	IX
	LD	E,(IY+#02)
	INC	E
	LD	A,(IY+#04)
	INC	A
	ADD	A,(IY+#07)
	LD	D,A
	CALL	PutDialLn
	POP	IX
	POP	IY
	RET 
LstBoxBar
	LD	A,(IX+#07)
	ADD	A,(IX+#08)
	LD	E,A
	LD	A,(IX+#0D)
	SUB	(IX+#0C)
	SUB	#02
	LD	C,A
	CALL	Mult8X8		; Curline*lenscrollbar=num16bit
	LD	A,H
	OR	L
	JR	Z,LBB1
	LD	A,(IX+#09)	; Num16bit/equipelem
	OR	A
	JR	Z,$+3
	DEC	A
	LD	C,A
	CALL	Divis16X8
LBB1	LD	A,(IX+#0C)	; Offset from start
	INC	A
	ADD	A,L
	CP	(IX+#0E)
	RET	Z
	PUSH	IY
	PUSH	IX
	PUSH	AF
	PUSH	IX
	POP	IY
	LD	IX,DialData
	LD	A,(IY+#03)
	SUB	(IX+#00)
	SUB	#02
	LD	C,A
	LD	A,(IY+#0E)
	SUB	(IX+#01)
	LD	B,A
	CALL	GetPutA
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	LD	A,#B1
	LD	(DE),A
	POP	AF
	OUT	(SLOT3),A
	LD	A,(IY+#03)
	SUB	#02
	LD	E,A
	LD	D,(IY+#0E)
	LD	A,D
	CP	#1F
	JR	NC,LBe
	BIT	7,E
	JR	NZ,LBe
	LD	A,E
	CP	#50
	JR	NC,LBe
	LD	A,(ColScrlBar)
	LD	H,A
	LD	L,#B1
	LD	BC,#1BB5
	SUB	A
	RST	#10
LBe	LD	A,(IY+#03)
	SUB	#02
	LD	E,A
	POP	AF
	LD	(IY+#0E),A
	LD	D,A
	PUSH	DE
	CP	#1F
	JR	NC,LBe1
	BIT	7,E
	JR	NZ,LBe1
	LD	A,E
	CP	#50
	JR	NC,LBe1
	LD	A,(ColScrlBar)
	LD	H,A
	LD	L,#FE
	LD	BC,#1BB5
	SUB	A
	RST	#10
LBe1	POP	DE
	LD	A,E
	SUB	(IX+#00)
	LD	C,A
	LD	A,D
	SUB	(IX+#01)
	LD	B,A
	CALL	GetPutA
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	LD	A,#FE
	LD	(DE),A
	POP	AF
	OUT	(SLOT3),A
	POP	IX
	POP	IY
	RET 

PrnLstBox
	PUSH	IY
	PUSH	IX
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	PUSH	IX
	POP	IY
	LD	IX,DialData
	LD	L,(IY+#11)
	LD	H,(IY+#12)
	LD	A,(IY+#02)
	SUB	(IX+#00)
	ADD	A,#02
	LD	C,A
	LD	A,(IY+#04)
	SUB	(IX+#01)
	INC	A
	LD	B,A
	LD	A,(IY+#05)
	SUB	(IY+#04)
	SUB	#02
PrLsBx0	PUSH	AF
	PUSH	BC
	CALL	GetPutA
	LD	A,(IY+#03)
	SUB	(IY+#02)
	SUB	#05
	LD	B,A
PrLsBx1	LD	A,(HL)
	INC	HL
	CP	#0D
	JR	Z,PrLsBx2
	LD	(DE),A
	INC	DE
	INC	DE
	DJNZ	PrLsBx1
	LD	A,(HL)
	INC	HL
	CP	#0D
	JR	NZ,$-4
PrLsBx2	LD	A,B
	OR	A
	JR	Z,PrLsBx3
	LD	A,#20
	LD	(DE),A
	INC	DE
	INC	DE
	DJNZ	$-3
PrLsBx3	POP	BC
	INC	B
	POP	AF
	DEC	A
	JR	Z,PrLsBx4
	LD	E,(HL)
	INC	E
	DEC	E
	JR	NZ,PrLsBx0
PrLsBx4	OR	A
	JR	Z,PrLsBx6
PrLsBx5	PUSH	AF
	PUSH	BC
	CALL	GetPutA
	LD	A,(IY+#03)
	SUB	(IY+#02)
	SUB	#05
	LD	B,A
	SUB	A
	LD	(DE),A
	INC	DE
	INC	DE
	DJNZ	$-3
	POP	BC
	INC	B
	POP	AF
	DEC	A
	JR	NZ,PrLsBx5
PrLsBx6	CALL	PutDial
	POP	AF
	OUT	(SLOT3),A
	POP	IX
	POP	IY
	RET 
;[]===========================================================[]
;Push/pop button
PushBut	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	PUSH	IX
	LD	E,(IX+#02)	;Xo
	LD	D,(IX+#04)	;Y
	LD	A,(IX+#03)	;Xi
	SUB	E
	INC	A		; Xi-xo+1=full len with shadow
	LD	L,A
	LD	H,#01		; Ylen=2 with shadow
	LD	(BTlen+1),HL	;Save len
	LD	(BTpos+1),DE	;Save pos
	LD	A,L
	PUSH	AF		;Save len
	LD	IX,DialData
	LD	A,E
	SUB	(IX+#00)
	LD	C,A
	LD	A,D
	SUB	(IX+#01)
	LD	B,A
	PUSH	BC
	CALL	GetPutA
	LD	C,L
	SLA	C
	LD	B,#00
	LD	HL,ReCompBuff
	EX	DE,HL
	LDIR 
	EX	DE,HL
	POP	BC
	INC	B
	CALL	GetPutA
	POP	AF
	LD	C,A
	SLA	C
	LD	B,#00
	EX	DE,HL
	LDIR 
	PUSH	AF
	DEC	A	; Len without shadow
	ADD	A,A
	LD	C,A
	LD	B,#00
	LD	HL,ReCompBuff
	LD	DE,ReCompBuff+160
	LD	A,#20
	LD	(DE),A		; Shift by one pos
	INC	DE
	LD	A,(ColDialWn)
	LD	(DE),A
	INC	DE
	LDIR			; Move button
	POP	AF		; Reset len
	EX	DE,HL
	LD	B,A
	LD	D,#20
	LD	A,(ColDialWn)	; Without down shadow
	LD	(HL),D
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-4
	LD	IX,ReCompBuff + NEW_ADDR*2 + 160		;Put button
BTlen	LD	HL,#0000
BTpos	LD	DE,#0000
	CALL	testbut
	JR	NC,bt1
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	LD	IX,ReCompBuff + NEW_ADDR*2 + 160		;Put button
	LD	HL,(BTlen+1)
	LD	DE,(BTpos+1)
	INC	D
	LD	A,L
	ADD	A,A
	ADD	A,LX
	LD	LX,A
	JR	NC,$+4
	INC	HX
	CALL	testbut
	JR	NC,bt1
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
bt1	POP	IX
Kbutt	LD	A,#00
	OR	A
	JR	Z,PushLp
	LD	B,#08
	HALT 
	DJNZ	$-1
	JR	PushEx
PushLp	LD	A,#03
	RST	#00
	JR	Z,PushEx
	BIT	1,A
	JR	Z,PushEx
	LD	A,H
	CP	(IX+#04)	;Y pos button
	JR	NZ,PushEx
	LD	C,(IX+#02)	;Xo pos
	LD	B,(IX+#03)	;Xi pos
	INC	B
	LD	A,L
	BIT	7,C
	JR	NZ,$+5
	CP	C		;Xo pos
	JR	C,PushEx	;<
	BIT	7,B
	JR	NZ,PushLp
	CP	B
	JR	C,PushLp	;>
PushEx	PUSH	IX
	PUSH	HL
	LD	IX,ReCompBuff + NEW_ADDR*2			;Put prev button
	LD	HL,(BTlen+1)
	LD	DE,(BTpos+1)
	CALL	testbut
	JR	NC,bt2
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	LD	IX,ReCompBuff + NEW_ADDR*2	;Put button
	LD	HL,(BTlen+1)
	LD	DE,(BTpos+1)
	INC	D
	LD	A,L
	ADD	A,A
	ADD	A,LX
	LD	LX,A
	JR	NC,$+4
	INC	HX
	CALL	testbut
	JR	NC,bt2
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
bt2	POP	HL
	POP	IX
	POP	AF
	OUT	(SLOT3),A
	LD	A,(Kbutt+1)
	OR	A
	RET	NZ
	LD	A,H
	CP	(IX+#04)	;Y pos button
	SCF 
	RET	NZ
	LD	C,(IX+#02)	;Xo pos
	LD	B,(IX+#03)	;Xi pos
	INC	B
	LD	A,L
	BIT	7,C
	JR	NZ,$+4
	CP	C		;Xo pos
	RET	C		;<
	BIT	7,B
	SCF 
	RET	NZ
	CP	B		;Xi pos
	CCF			;>
	RET 

testbut	LD	A,D
	CP	#1F
	RET	NC
	BIT	7,E
	JR	Z,bt0
	LD	A,E
	LD	E,#00
	NEG 
	LD	C,A
	SUB	L
	NEG 
	LD	L,A
	OR	A
	RET	Z
	RET	M
	LD	A,C
	ADD	A,A
	ADD	A,LX
	LD	LX,A
	JR	NC,bt0
	INC	HX
bt0	LD	A,E
	CP	#50
	RET	NC
	ADD	A,L
	CP	#50
	RET	C
	LD	A,#50
	SUB	E
	LD	L,A
	SCF 
	RET 
;[]===========================================================[]
RsFileBxI
	LD	A,(ColFileBox)
	JR	FBinvert
HdFileBxI
	LD	A,(ColFileBHI)
	JR	FBinvert
StFileBxI
	LD	A,(ColFileBxI)
FBinvert
	LD	(fbincol+1),A
	PUSH	IY
	PUSH	IX
	PUSH	HL
	PUSH	IX
	POP	IY
	LD	IX,DialData
	LD	A,(IY+#02)
	SUB	(IX+#00)
	INC	A
	LD	C,A
	LD	A,(IY+#04)
	SUB	(IX+#01)
	INC	A
	ADD	A,(IY+#07)
	LD	B,A
	LD	A,(IY+#05)
	SUB	(IX+#01)
	SUB	#02
	LD	E,A
	LD	A,B
	CP	E
	JR	C,sfb0
	LD	A,(IY+#05)
	SUB	(IY+#04)
	SUB	#03
	SUB	B
	NEG 
	LD	B,A
	LD	A,C
	ADD	A,#0F
	LD	C,A
sfb0	LD	(sfbadr+1),BC
	CALL	GetPutA
	PUSH	DE
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	LD	A,(IY+#03)
	SUB	(IY+#02)
	SUB	#02
	SRL	A
	LD	L,A
	LD	H,#01
	LD	B,L
fbincol	LD	A,#00
	INC	DE
	LD	(DE),A
	INC	DE
	DJNZ	$-3
	POP	AF
	OUT	(SLOT3),A
sfbadr	LD	DE,#0000
	LD	A,E
	ADD	A,(IX+#00)
	LD	E,A
	LD	A,D
	ADD	A,(IX+#01)
	LD	D,A
	POP	IX
	CALL	PutDialLn
	LD	A,#01
	RST	#00
	POP	HL
	POP	IX
	POP	IY
	RET 
PrnFileBox
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(SymbPg1)
	OUT	(SLOT3),A
	PUSH	IY
	PUSH	IX
	PUSH	IX
	POP	IY
	LD	IX,DialData
	LD	A,(IY+#02)
	SUB	(IX+#00)
	ADD	A,#02
	LD	C,A
	LD	A,(IY+#04)
	SUB	(IX+#01)
	INC	A
	LD	B,A
	LD	L,(IY+#09)
	LD	H,(IY+#0A)
	ADD	HL,HL
	ADD	HL,HL
	PUSH	HL
	ADD	HL,HL
	ADD	HL,HL
	POP	DE
	ADD	HL,DE
	LD	A,H
	ADD	A,#C0
	LD	H,A
	LD	A,(IY+#05)
	SUB	(IY+#04)
	SUB	#03
PrnFB1:
	PUSH	AF
	PUSH	BC
	PUSH	HL
	CALL	GetPutA
	PUSH	DE
	LD	DE,ReCompBuff
	PUSH	DE

 DUP 10	
	LDI
 EDUP
 
	LD	A,(HL)
	LD	(DE),A
	POP	HL
	POP	DE
	LD	A,(BuffPg5)
	OUT	(SLOT3),A

 DUP 8
	LDI 
	INC	DE
 EDUP 

	INC	DE
	INC	DE
	LDI 
	INC	DE
	LDI 
	INC	DE
	LD	A,(HL)
	LD	(DE),A
	LD	A,(SymbPg1)
	OUT	(SLOT3),A
	POP	HL
	LD	BC,20
	ADD	HL,BC
	LD	E,(HL)
	POP	BC
	INC	B
	POP	AF
	INC	E
	DEC	E
	CALL	Z,ClearFB
	DEC	A
	JR	NZ,PrnFB1
	LD	A,(IY+#02)
	SUB	(IX+#00)
	ADD	A,#11
	LD	C,A
	LD	A,(IY+#04)
	SUB	(IX+#01)
	INC	A
	LD	B,A
	LD	A,(IY+#05)
	SUB	(IY+#04)
	SUB	#03
PrnFB2	PUSH	AF
	PUSH	BC
	PUSH	HL
	CALL	GetPutA
	PUSH	DE
	LD	DE,ReCompBuff
	PUSH	DE

 DUP 10
	LDI
 EDUP

	LD	A,(HL)
	LD	(DE),A
	POP	HL
	POP	DE
	LD	A,(BuffPg5)
	OUT	(SLOT3),A

 DUP 8
	LDI 
	INC	DE
 EDUP 

	INC	DE
	INC	DE
	LDI 
	INC	DE
	LDI 
	INC	DE
	LD	A,(HL)
	LD	(DE),A
	LD	A,(SymbPg1)
	OUT	(SLOT3),A
PrnFB3	POP	HL
	LD	BC,20
	ADD	HL,BC
	LD	E,(HL)
	POP	BC
	INC	B
	POP	AF
	INC	E
	DEC	E
	CALL	Z,ClearFB
	DEC	A
	JR	NZ,PrnFB2
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	CALL	PutDial
	POP	IX
	POP	IY
	POP	AF
	OUT	(SLOT3),A
	RET 

ClearFB	CP	#01
	RET	Z
	DEC	A
	EX	AF,AF'
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	EX	AF,AF'
ClearFL	PUSH	AF
	PUSH	BC
	CALL	GetPutA
	LD	A,#20
	LD	B,#0C
	LD	(DE),A
	INC	DE
	INC	DE
	DJNZ	$-3
	POP	BC
	INC	B
	POP	AF
	DEC	A
	JR	NZ,ClearFL
	LD	A,(SymbPg1)
	OUT	(SLOT3),A
	LD	A,#01
	RET 

FileBoxBar
	LD	L,(IX+#07)
	LD	H,(IX+#08)
	LD	E,(IX+#09)
	LD	D,(IX+#0A)
	ADD	HL,DE
	EX	DE,HL
	LD	A,(IX+#0E)
	SUB	(IX+#0D)
	SUB	#02
	LD	C,A
	CALL	Mult16X8	; Curline*lenscrollbar=num16bit
	LD	C,L
	LD	B,H
	LD	E,(IX+#0B)	; Num16bit/equipelem
	LD	D,(IX+#0C)
	LD	A,D
	OR	E
	JR	Z,FBB1
	DEC	DE
	CALL	Divis16
	LD	E,C
FBB1	LD	A,(IX+#0D)	; Offset from start
	INC	A
	ADD	A,E
	CP	(IX+#0F)
	RET	Z
	PUSH	IY
	PUSH	IX
	PUSH	AF
	PUSH	IX
	POP	IY
	LD	IX,DialData
	LD	A,(IY+#0F)
	SUB	(IX+#00)
	LD	C,A
	LD	A,(IY+#05)
	SUB	(IX+#01)
	SUB	#02
	LD	B,A
	CALL	GetPutA
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	LD	A,#B1
	LD	(DE),A
	POP	AF
	OUT	(SLOT3),A
	LD	E,(IY+#0F)
	LD	A,(IY+#05)
	SUB	#02
	LD	D,A
	CP	#1F
	JR	NC,FBe
	BIT	7,E
	JR	NZ,FBe
	LD	A,E
	CP	#50
	JR	NC,FBe
	LD	A,(ColScrlBar)
	LD	H,A
	LD	L,#B1
	LD	BC,#1BB5
	SUB	A
	RST	#10
FBe	POP	AF
	LD	(IY+#0F),A
	LD	E,A
	LD	A,(IY+#05)
	SUB	#02
	LD	D,A
	PUSH	DE
	CP	#1F
	JR	NC,FBe1
	BIT	7,E
	JR	NZ,FBe1
	LD	A,E
	CP	#50
	JR	NC,FBe1
	LD	A,(ColScrlBar)
	LD	H,A
	LD	L,#FE
	LD	BC,#1BB5
	SUB	A
	RST	#10
FBe1	POP	DE
	LD	A,E
	SUB	(IX+#00)
	LD	C,A
	LD	A,D
	SUB	(IX+#01)
	LD	B,A
	CALL	GetPutA
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	LD	A,#FE
	LD	(DE),A
	POP	AF
	OUT	(SLOT3),A
	POP	IX
	POP	IY
	RET 
;[]===========================================================[]
ResPalCurs:
	PUSH	IY
	PUSH	IX
	PUSH	HL
	PUSH	AF
	PUSH	IX
	POP	IY
	LD	IX,DialData
	LD	L,(IY+#0C)
	LD	H,(IY+#0D)
	LD	A,(HL)
	AND	(IY+#09)
	BIT	7,(IY+#09)
	JR	Z,$+6
	RRCA 
	RRCA 
	RRCA 
	RRCA 
	LD	L,A
	LD	B,#FF
	INC	B
	SUB	(IY+#07)
	JR	NC,$-4
	ADD	A,(IY+#07)
	LD	C,A
	ADD	A,A
	ADD	A,A
	ADD	A,C
	ADD	A,#02
	LD	C,A
	LD	A,B
	ADD	A,A
	INC	A
	LD	B,A
	PUSH	BC
	LD	A,(IY+#02)
	SUB	(IX+#00)
	INC	A
	ADD	A,C
	LD	C,A
	LD	A,(IY+#04)
	SUB	(IX+#01)
	INC	A
	ADD	A,B
	LD	B,A
	CALL	GetPutA
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A

 IF NEW_VERSION
	LD	A,0xDB
 ELSE
	LD	A,"-"
 ENDIF

	LD	(DE),A
	INC	DE
	LD	A,L
	LD	(DE),A
	POP	AF
	OUT	(SLOT3),A
	POP	BC
	LD	A,C
	ADD	A,(IY+#02)
	INC	A
	LD	E,A
	LD	A,B
	ADD	A,(IY+#04)
	INC	A
	LD	D,A
	LD	A,D
	CP	#1F
	JR	NC,RPalCr
	LD	A,E
	CP	#50
	JR	NC,RPalCr
	LD	C,#84
	PUSH	HL
	RST	#10
	POP	DE
	LD	BC,#0181
	
 IF NEW_VERSION
	LD	A,0xDB
 ELSE
	LD	A,"-"
 ENDIF

	RST	#10
RPalCr	POP	AF
	POP	HL
	POP	IX
	POP	IY
	RET 
SetPalCurs
	LD	L,(IX+#0C)
	LD	H,(IX+#0D)
	INC	HL
	LD	A,(HL)
	AND	(IX+#09)
	RET	Z
	PUSH	IY
	PUSH	IX
	PUSH	HL
	PUSH	IX
	POP	IY
	LD	IX,DialData
	LD	L,(IY+#0C)
	LD	H,(IY+#0D)
	LD	A,(HL)
	AND	(IY+#09)
	BIT	7,(IY+#09)
	JR	Z,$+6
	RRCA 
	RRCA 
	RRCA 
	RRCA 
	LD	B,#FF
	INC	B
	SUB	(IY+#07)
	JR	NC,$-4
	ADD	A,(IY+#07)
	LD	C,A
	ADD	A,A
	ADD	A,A
	ADD	A,C
	ADD	A,#02
	LD	C,A
	LD	A,B
	ADD	A,A
	INC	A
	LD	B,A
	PUSH	BC
	LD	A,(IY+#02)
	SUB	(IX+#00)
	INC	A
	ADD	A,C
	LD	C,A
	LD	A,(IY+#04)
	SUB	(IX+#01)
	INC	A
	ADD	A,B
	LD	B,A
	CALL	GetPutA
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	LD	A,"*"
	LD	(DE),A
	INC	DE
	LD	A,(ColDialWn)
	LD	(DE),A
	POP	AF
	OUT	(SLOT3),A
	POP	BC
	LD	A,C
	ADD	A,(IY+#02)
	INC	A
	LD	E,A
	LD	A,B
	ADD	A,(IY+#04)
	INC	A
	LD	D,A
	LD	A,D
	CP	#1F
	JR	NC,SPalCr
	LD	A,E
	CP	#50
	JR	NC,SPalCr
	LD	C,#84
	RST	#10
	LD	BC,#0181
	LD	A,(ColDialWn)
	LD	E,A
	LD	A,"*"
	RST	#10
SPalCr	POP	HL
	POP	IX
	POP	IY
	RET 
ETestCol
	LD	HL,what
	LD	A,(HL)
	INC	HL
	CP	evMessage
	RET	NZ
	LD	A,(HL)
	CP	msNewColor
	RET	NZ
	INC	HL
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	LD	A,B
	CP	#FF
	JR	Z,ETestC1
	CPL 
	LD	B,A
	LD	A,(ColDialWn)
	AND	B
	OR	C
	LD	C,A
ETestC1	PUSH	IY
	PUSH	IX
	PUSH	IX
	POP	IY
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	LD	IX,DialData
	LD	A,C
	PUSH	AF
	LD	A,(IY+#02)
	SUB	(IX+#00)
	LD	C,A
	LD	A,(IY+#03)
	SUB	(IX+#01)
	LD	B,A
	CALL	GetPutA
	EX	DE,HL
	POP	AF
	PUSH	AF
	PUSH	IX
	PUSH	HL
	LD	B,(IY+#04)
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-3
	LD	E,(IY+#02)
	LD	D,(IY+#03)
	LD	L,(IY+#04)
	LD	H,#01
	POP	IX
	CALL	PutDialLn
	POP	IX
	LD	A,(IY+#02)
	SUB	(IX+#00)
	LD	C,A
	LD	A,(IY+#03)
	SUB	(IX+#01)
	INC	A
	LD	B,A
	CALL	GetPutA
	EX	DE,HL
	POP	AF
	PUSH	HL
	LD	B,(IY+#04)
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-3
	LD	E,(IY+#02)
	LD	D,(IY+#03)
	INC	D
	LD	L,(IY+#04)
	LD	H,#01
	POP	IX
	CALL	PutDialLn
	POP	AF
	OUT	(SLOT3),A
	POP	IX
	POP	IY
	RET 
;
 _mCollectInfo_addEnd