 _mCollectInfo_addStart
;[]===========================================================[]
;Event file box
EFileBox
	LD	A,(IX+#12)	;Directory flag
	OR	A
	JP	Z,GetDIR
	LD	HL,what	; Events list
	LD	A,(HL)
	INC	HL
	CP	evMouseFr
	JP	Z,EFmouse
	CP	evKeyboard
	JP	Z,EFkeys
	CP	evMessage
	JR	Z,EFmess
	CP	evCombKey
	RET	NZ
	BIT	7,(IX+#01)
	JR	NZ,EFcomb
	INC	HL
	LD	A,(HL)		; Shift+tab
	CP	146
	RET	NZ
	PUSH	IX
	LD	E,(IX+#00)
	LD	D,#00
	ADD	IX,DE
	BIT	7,(IX+#00)
	LD	A,(IX+#01)
	LD	E,(IX+#00)
	ADD	IX,DE
	LD	E,(IX+#00)
	POP	IX
	JP	NZ,SetFileBx	   ; If shift+tab then select my
	CP	FileInfo
	RET	NZ
	BIT	7,E
	RET	Z
	JP	SetFileBx	; If shift+tab then select my

EFmess	LD	A,(HL)
	CP	msChangeDR
	JP	Z,GetDIR
	CP	msHiddInvr
	RET	NZ
	BIT	7,(IX+#01)
	RET	NZ
	LD	A,(IX+#0B)
	OR	(IX+#0C)
	RET	Z
	JP	HdFileBxI

EFcomb	INC	HL
	LD	DE,EFexit
	PUSH	DE
	LD	A,(HL)
	CP	72	; Curs up
	JR	Z,EFup
	CP	80	;Curs down
	JP	Z,EFdown
	CP	75	; Curs left
	JP	Z,EFleft
	CP	77	;Curs right
	JP	Z,EFrght
	CP	73
	JP	Z,EFpgup
	CP	81
	JP	Z,EFpgdwn
	CP	71
	JP	Z,EFhome
	CP	79
	JP	Z,EFend
	POP	DE
	RET 

EFup	LD	A,(IX+#0C)
	OR	A
	JR	NZ,EFup0
	LD	A,(IX+#0B)
	CP	#02
	RET	C
EFup0	LD	L,(IX+#07)
	LD	H,(IX+#08)
	DEC	HL
	BIT	7,H
	JR	NZ,EFup1
	CALL	RsFileBxI
	LD	(IX+#07),L
	LD	(IX+#08),H
	CALL	StFileBxI
	CALL	FileBoxBar
	JP	EFboxex
EFup1	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	DEC	HL
	BIT	7,H
	RET	NZ
	LD	(IX+#09),L
	LD	(IX+#0A),H
	CALL	PrnFileBox
	CALL	FileBoxBar
	JP	EFboxex

EFdown	LD	A,(IX+#0C)
	OR	A
	JR	NZ,EFdown0
	LD	A,(IX+#0B)
	CP	#02
	RET	C
EFdown0	LD	A,(IX+#05)
	SUB	(IX+#04)
	SUB	#03
	ADD	A,A
	LD	C,A
	LD	A,#00
	ADC	A,A
	LD	B,A
	LD	L,(IX+#07)
	LD	H,(IX+#08)
	LD	E,(IX+#09)
	LD	D,(IX+#0A)
	ADD	HL,DE
	INC	HL
	LD	E,(IX+#0B)
	LD	D,(IX+#0C)
	AND	A
	SBC	HL,DE
	RET	Z
	LD	L,(IX+#07)
	LD	H,(IX+#08)
	INC	HL
	OR	A
	SBC	HL,BC
	JR	Z,EFdown1
	ADD	HL,BC
	CALL	RsFileBxI
	LD	(IX+#07),L
	LD	(IX+#08),H
	CALL	StFileBxI
	CALL	FileBoxBar
	JP	EFboxex

EFdown1	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	INC	HL
	LD	(IX+#09),L
	LD	(IX+#0A),H
	CALL	PrnFileBox
	CALL	FileBoxBar
	JP	EFboxex

EFleft	LD	A,(IX+#0C)
	OR	A
	JR	NZ,EFleft0
	LD	A,(IX+#0B)
	CP	#02
	RET	C
EFleft0	LD	L,(IX+#07)
	LD	H,(IX+#08)
	LD	A,H
	OR	L
	JP	Z,EFpgup	; Prev page
	LD	A,(IX+#05)
	SUB	(IX+#04)
	SUB	#03
	LD	C,A
	LD	B,#00
	OR	A
	SBC	HL,BC
	JR	NC,$+4
	LD	L,B
	LD	H,L
	CALL	RsFileBxI
	LD	(IX+#07),L
	LD	(IX+#08),H
	CALL	StFileBxI
	CALL	FileBoxBar
	JP	EFboxex

EFrght	LD	A,(IX+#0C)
	OR	A
	JR	NZ,EFrght0
	LD	A,(IX+#0B)
	CP	#02
	RET	C
EFrght0	LD	L,(IX+#07)
	LD	H,(IX+#08)
	LD	A,(IX+#05)
	SUB	(IX+#04)
	SUB	#03
	ADD	A,A
	LD	C,A
	LD	A,#00
	ADC	A,#00
	LD	B,A
	OR	A
	PUSH	HL
	DEC	BC
	SBC	HL,BC
	POP	HL
	JP	Z,EFpgdwn	; Next page
	LD	E,(IX+#0B)
	LD	D,(IX+#0C)
	DEC	DE
	PUSH	HL
	OR	A
	SBC	HL,DE
	POP	HL
	RET	Z
	PUSH	DE
	LD	A,(IX+#05)
	SUB	(IX+#04)
	SUB	#03
	LD	E,A
	LD	D,#00
	ADD	HL,DE
	POP	DE
	PUSH	HL
	OR	A
	SBC	HL,DE
	POP	HL
	JR	C,EFrght1
	LD	L,E
	LD	H,D
	LD	E,(IX+#09)
	LD	D,(IX+#0A)
	OR	A
	SBC	HL,DE
EFrght1	PUSH	HL
	OR	A
	SBC	HL,BC
	POP	HL
	JR	Z,$+6
	JR	C,$+4
	LD	L,C
	LD	H,B
	CALL	RsFileBxI
	LD	(IX+#07),L
	LD	(IX+#08),H
	CALL	StFileBxI
	CALL	FileBoxBar
	JP	EFboxex

EFpgup	LD	A,(IX+#0C)
	OR	A
	JR	NZ,EFpgup0
	LD	A,(IX+#0B)
	CP	#02
	RET	C
EFpgup0	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	LD	A,H
	OR	L
	JR	Z,EFhome
	LD	A,(IX+#05)
	SUB	(IX+#04)
	SUB	#03
	ADD	A,A
	LD	C,A
	LD	A,#00
	ADC	A,#00
	LD	B,A
	OR	A
	SBC	HL,BC
	JR	NC,$+5
	LD	HL,#0000
	LD	(IX+#09),L
	LD	(IX+#0A),H
	CALL	PrnFileBox
	CALL	FileBoxBar
	JP	EFboxex

EFpgdwn	LD	A,(IX+#0C)
	OR	A
	JR	NZ,EFpgdn0
	LD	A,(IX+#0B)
	CP	#02
	RET	C
EFpgdn0	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	LD	A,(IX+#05)
	SUB	(IX+#04)
	SUB	#03
	ADD	A,A
	LD	C,A
	LD	A,#00
	ADC	A,#00
	LD	B,A
	ADD	HL,BC
	LD	E,(IX+#0B)
	LD	D,(IX+#0C)
	EX	DE,HL
	OR	A
	PUSH	HL
	SBC	HL,BC
	POP	HL
	JR	C,EFend
	EX	DE,HL
	PUSH	HL
	OR	A
	SBC	HL,DE
	POP	HL
	JR	Z,EFend
	JR	NC,EFpgdn1
	LD	L,E
	LD	H,D
	OR	A
	SBC	HL,BC
EFpgdn1	LD	(IX+#09),L
	LD	(IX+#0A),H
	CALL	PrnFileBox
	CALL	FileBoxBar
	JP	EFboxex

EFhome	LD	A,(IX+#0C)
	OR	A
	JR	NZ,EFhome0
	LD	A,(IX+#0B)
	CP	#02
	RET	C
EFhome0	LD	A,(IX+#07)
	OR	(IX+#08)
	OR	(IX+#09)
	OR	(IX+#0A)
	RET	Z
	CALL	RsFileBxI
	SUB	A
	LD	(IX+#07),A
	LD	(IX+#08),A
	LD	(IX+#09),A
	LD	(IX+#0A),A
	CALL	PrnFileBox
	CALL	StFileBxI
	CALL	FileBoxBar
	JP	EFboxex

EFend	LD	A,(IX+#0C)
	OR	A
	JR	NZ,EFend0
	LD	A,(IX+#0B)
	CP	#02
	RET	C
EFend0	LD	E,(IX+#0B)
	LD	D,(IX+#0C)
	LD	L,(IX+#07)
	LD	H,(IX+#08)
	LD	C,(IX+#09)
	LD	B,(IX+#0A)
	ADD	HL,BC
	INC	HL
	OR	A
	SBC	HL,DE
	RET	Z
	EX	DE,HL
	LD	A,(IX+#05)
	SUB	(IX+#04)
	SUB	#03
	ADD	A,A
	LD	C,A
	LD	A,#00
	ADC	A,#00
	LD	B,A
	OR	A
	SBC	HL,BC
	JR	NC,$+5
	LD	HL,#0000
	LD	(IX+#09),L
	LD	(IX+#0A),H
	EX	DE,HL
	LD	L,(IX+#0B)
	LD	H,(IX+#0C)
	DEC	HL
	OR	A
	SBC	HL,DE
	CALL	RsFileBxI
	LD	(IX+#07),L
	LD	(IX+#08),H
	CALL	PrnFileBox
	CALL	StFileBxI
	CALL	FileBoxBar
	JP	EFboxex

EFboxex	POP	DE
	LD	A,(FMenuFlg)
	OR	A
	JR	NZ,EFboxe1
	LD	HL,what
	LD	(HL),evMessage
	INC	HL
	LD	(HL),msPtFileIn
	INC	HL
	EX	DE,HL
	LD	L,(IX+#07)
	LD	H,(IX+#08)
	LD	C,(IX+#09)
	LD	B,(IX+#0A)
	ADD	HL,BC
	EX	DE,HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	CALL	TransMessage
	LD	B,#08
	LD	A,#03
	RST	#00
	RET	Z
	HALT 
	DJNZ	$-5
	RET 

EFboxe1	LD	HL,what
	LD	(HL),evMessage
	INC	HL
	LD	(HL),msGtFileNm
	INC	HL
	EX	DE,HL
	LD	L,(IX+#07)
	LD	H,(IX+#08)
	LD	C,(IX+#09)
	LD	B,(IX+#0A)
	ADD	HL,BC
	EX	DE,HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	EX	DE,HL
	ADD	HL,HL	;*20
	ADD	HL,HL
	PUSH	HL
	ADD	HL,HL
	ADD	HL,HL
	POP	DE
	ADD	HL,DE
	LD	(NameNum+1),HL
	SUB	A
	LD	(OpenFl+1),A
	CALL	TransMessage
	LD	B,#08
	LD	A,#03
	RST	#00
	RET	Z
	HALT 
	DJNZ	$-5
	RET 

EFenter	LD	HL,what
	LD	(HL),evMessage
	INC	HL
	LD	(HL),msGtFileNm
	INC	HL
	EX	DE,HL
	LD	L,(IX+#07)
	LD	H,(IX+#08)
	LD	C,(IX+#09)
	LD	B,(IX+#0A)
	ADD	HL,BC
	EX	DE,HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	CALL	TransMessage
	LD	B,#08
	LD	A,#03
	RST	#00
	RET	Z
	HALT 
	DJNZ	$-5
	RET 

; Event - mouse fire
EFmouse	LD	E,(HL)		;Xcoord
	INC	HL
	LD	D,(HL)		;Ycoord
	LD	A,E
	BIT	7,(IX+#02)
	JR	NZ,$+6
	CP	(IX+#02)	;Xo pos
	RET	C		;<
	BIT	7,(IX+#03)
	RET	NZ
	CP	(IX+#03)	;Xi pos
	RET	NC		;>
	LD	A,D
	CP	(IX+#04)	; Yo pos list box
	RET	C
	CP	(IX+#05)	; Yi pos list box
	RET	NC
	BIT	7,(IX+#01)	; Sel or nosel
	PUSH	DE
	CALL	Z,SetFileBx
	POP	DE
	LD	A,E
	BIT	7,(IX+#02)
	JR	NZ,$+6
	CP	(IX+#02)	;Xo pos
	RET	Z		;<
	INC	A
	CP	(IX+#03)	;Xi pos
	RET	Z		;>
	LD	A,D
	CP	(IX+#04)	; Yo pos list box
	RET	Z
	INC	A
	CP	(IX+#05)	; Yi pos list box
	RET	Z
	INC	A
	CP	(IX+#05)	; Yi pos list box
	JR	NZ,EFmous0
	LD	HL,EFexit
	PUSH	HL
	LD	A,E
	CP	(IX+#0D)
	JP	Z,EFup
	BIT	7,(IX+#0D)
	JR	NZ,$+3
	RET	C
	CP	(IX+#0E)
	JP	Z,EFdown
	BIT	7,(IX+#0E)
	RET	NZ
	RET	NC
	CP	(IX+#0F)
	RET	Z
	BIT	7,(IX+#0F)
	JP	NZ,EFpgdwn
	JP	NC,EFpgdwn
	JP	EFpgup

EFmous0	LD	A,D
	SUB	(IX+#04)
	DEC	A
	LD	C,A
	LD	B,#00
	LD	A,E
	SUB	(IX+#02)
	DEC	A
	CP	#0E
	RET	Z
	JR	C,EFmous1
	LD	A,(IX+#05)
	SUB	(IX+#04)
	SUB	#03
	LD	L,A
	LD	H,B
	ADD	HL,BC
	LD	C,L
	LD	B,H
EFmous1	LD	L,(IX+#0B)
	LD	H,(IX+#0C)
	OR	A
	SBC	HL,BC
	RET	C
	RET	Z
	LD	L,(IX+#07)
	LD	H,(IX+#08)
	OR	A
	SBC	HL,BC
	JP	Z,EFenter
	PUSH	BC
	CALL	RsFileBxI
	POP	BC
	LD	(IX+#07),C
	LD	(IX+#08),B
	CALL	StFileBxI
	CALL	FileBoxBar
	JP	EFboxex+1

; Event - key press
EFkeys	LD	A,(HL)
	RES	5,A
	BIT	7,(IX+#01)	; Sel or nosel
	JR	Z,EFkeys1
	CP	#0D
	RET	NZ
	JP	EFenter
EFkeys1	CP	#09		;Tab
	JR	Z,SetFileBx	; If tab then set button
	CP	(IX+#10)	;Hot key
	RET	NZ
SetFileBx
	CALL	MoveObj		; Select button
	CALL	ResDialInv	;Reset previos invert
	LD	IX,DialTab+5
	LD	E,(IX+#02)	;Xo
	INC	E
	LD	D,(IX+#04)	;Y
	LD	A,(IX+#06)	;Xi
	SUB	E
	LD	C,A
	CALL	SetDialInv
	LD	A,(IX+#11)
	CALL	PutStatusLn
	LD	A,(IX+#0B)
	OR	(IX+#0C)
	CALL	NZ,StFileBxI
EFexit	LD	HL,what
	LD	(HL),evNothing
	RET 
;[]===========================================================[]
;Event button
EButton	LD	HL,what	; Events list
	LD	A,(HL)
	INC	HL
	CP	evMouseFr
	JR	Z,EBmouse
	CP	evKeyboard
	JR	Z,EBkeys
	CP	evCombKey
	RET	NZ
	BIT	7,(IX+#01)
	RET	NZ
	PUSH	IX
	LD	E,(IX+#00)
	LD	D,#00
	ADD	IX,DE
	BIT	7,(IX+#00)
	POP	IX
	RET	Z
	INC	HL
	LD	A,(HL)		; Shift+tab
	CP	146
	RET	NZ
	SUB	A
	LD	(Push+1),A	;Push flag
	JP	SetButt		; If tab then select my
; Event - mouse fire
EBmouse	LD	E,(HL)		;Xcoord
	INC	HL
	LD	D,(HL)		;Ycoord
	LD	A,D
	CP	(IX+#04)	;Y pos button
	RET	NZ		; If <> exit
	LD	A,E
	BIT	7,(IX+#02)
	JR	NZ,$+6
	CP	(IX+#02)	;Xo pos
	RET	C		;<
	BIT	7,(IX+#03)
	RET	NZ
	CP	(IX+#03)	;Xi pos
	RET	NC		;>
	SUB	A
	LD	(Kbutt+1),A
	INC	A
	LD	(Push+1),A	;Push flag
	BIT	7,(IX+#01)
	JR	NZ,Push
	JR	SetButt
; Event - key press
EBkeys	SUB	A
	LD	(Push+1),A	;Push flag
	LD	A,(HL)
	RES	5,A
	BIT	7,(IX+#01)	; Sel or nosel
	JR	NZ,EBkeyN
	CP	#09		;Tab
	JR	Z,SetButt	; If tab then set button
	JR	EBkeyN1
EBkeyN	CP	#0D
	JR	Z,EBent
EBkeyN1	CP	(IX+#06)	;Hot key
	RET	NZ
EBent	LD	A,#01
	LD	(Push+1),A
	LD	(Kbutt+1),A
SetButt	CALL	MoveObj		; Select button
	CALL	ResDialInv	;Reset previos invert
	LD	IX,DialTab+5
	LD	E,(IX+#02)	;Xo
	LD	D,(IX+#04)	;Y
	LD	A,(IX+#03)	;Xi
	SUB	E
	LD	C,A
	CALL	SetDialInv
	LD	A,(IX+#07)
	CALL	PutStatusLn
Push	LD	A,#00
	OR	A
	JP	Z,BTexit
	CALL	PushBut
	JP	C,BTexit
	LD	HL,what
	LD	(HL),evCommand
	INC	HL
	LD	A,(IX+#05)
	LD	(HL),A
	RET 
; Button exit
BTexit	LD	HL,what
	LD	(HL),evNothing
	RET 
;[]===========================================================[]
 _mCollectInfo_addEnd