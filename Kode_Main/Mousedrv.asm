 _mCollectInfo_addStart
; Cmouse equ #1b
; Dmouse equ #1a

; Mouse Driver (for text screen)
; On number:
; A=00h mouse
; A=01h cursor on screen
; A=02h cursor with screen
; A=03h get coordinates mouse and
; Internal operation
; A=03h get coordinates mouse and
; Internal operation
; Internal operation
MousDrv: OR	A
	JR	Z,Init_MS
	DEC	A
	JR	Z,SetMous
	DEC	A
	JR	Z,ResMous
	DEC	A
	JR	Z,ExmFire
	DEC	A
	JR	Z,GetFire
	RET 

; Initialization lpt port & mouse
Init_MS:
	LD	A,#55
	OUT	(Z84.CTC.Ch_0),A
	LD	A,MOUSE_BAUD.multiplier_2
	OUT	(Z84.CTC.Ch_0),A
	; Reg 0
	SUB	A
	OUT	(Z84.SIO.Ch_B.Ctrl),A
	; Reg 4
	LD	A,4
	OUT	(Z84.SIO.Ch_B.Ctrl),A
	LD	A,+(5 | MOUSE_BAUD.multiplier_1)	; First multiplier
	OUT	(Z84.SIO.Ch_B.Ctrl),A
	; Reg 3
	LD	A,3
	OUT	(Z84.SIO.Ch_B.Ctrl),A
	LD	A,#41
	OUT	(Z84.SIO.Ch_B.Ctrl),A
	; Reg 5
	LD	A,5
	OUT	(Z84.SIO.Ch_B.Ctrl),A
	LD	A,#E0
	OUT	(Z84.SIO.Ch_B.Ctrl),A
	; Reg 1
	LD	A,1
	OUT	(Z84.SIO.Ch_B.Ctrl),A
	IF	MOUSE_INT_ENABLED
	 LD	A,%0001'1001
	ELSE
	 XOR	A
	ENDIF
	OUT	(Z84.SIO.Ch_B.Ctrl),A
	;
	SUB	A
	LD	(MSbutt),A
	RET 

; Set mouse & print cursor mouse by screen
SetMous: DI 
	PUSH	IX
	PUSH	HL
	PUSH	DE
	PUSH	BC
	CALL	Refresh
	POP	BC
	POP	DE
	POP	HL
	POP	IX
	SUB	A
	INC	A
	LD	(MousFlg),A
	EI 
	RET 

; Res mouse & clear cursor mouse from screen
ResMous:
	LD	A,(MousFlg)
	OR	A
	RET	Z
	DI 
	SUB	A
	LD	(MousFlg),A
	LD	(MSbutt),A
	PUSH	IX
	PUSH	HL
	PUSH	DE
	PUSH	BC
	CALL	RestorM
	POP	BC
	POP	DE
	POP	HL
	POP	IX
	EI 
	RET 

; Examination by fire
; Input: none
; Output: z - not fire
; Nz - yep fire:
; Hl = y,x (in znak)
; A = 1 - left button
; A = 2 - right button
ExmFire	LD	HL,(Tcoords)
	LD	A,(MSbutt)
	AND	#03
	RET 

; Get fire (wait not fire)
; Input: none
; Output: z - not fire
; Nz - yep fire:
; Hl = y,x (in znak)
; A = 1 - left button
; A = 2 - right button
GetFire	LD	HL,(Tcoords)
	LD	A,(MSbutt)
	AND	#03
	RET	Z
	PUSH	AF
	LD	A,(MSbutt)
	AND	#03
	JR	NZ,$-5
	POP	AF
	RET 

; Refresh mouse by screen
Refresh	CALL	GetMousInfo
	LD	A,(HiddMouse)
	OR	A
	JR	Z,RefrMs
	LD	HL,(Xcoord)
	SRL	H
	RR	L
	SRL	H
	RR	L
	SRL	L
	LD	A,(Ycoord)
	RRA 
	RRA 
	RRA 
	AND	#1F
	LD	H,A
	LD	DE,(TempXY)
	SBC	HL,DE
	JR	NZ,RefrMs
KeyPres	LD	A,#00
	OR	A
	JR	Z,RefrMs1
	JP	RestorM
RefrMs	SUB	A
	LD	(KeyPres+1),A
RefrMs1	CALL	RestorM
	CALL	MousWrt
	RET 

; Restore screen from mouse
RestorM	LD	DE,(TempXY)
	IN	A,(PORT_Y)
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,#54
	OUT	(SLOT3),A
	LD	A,D
	ADD	A,A
	ADD	A,A
	LD	L,A
	LD	H,#C3
	IN	A,(RGMOD)
	RRCA 
	AND	#80
	OR	#01
	ADD	A,E
	OUT	(PORT_Y),A
	INC	L
	INC	L
	LD	A,(HL)
	LD	(HL),A
	POP	BC
	LD	A,B
	OUT	(SLOT3),A
	LD	A,C
	OUT	(PORT_Y),A
	RET 

; Put text mouse cursor by screen
MousWrt	LD	DE,(Xcoord)
	SRL	D
	RR	E
	SRL	D
	RR	E
	SRL	E
	LD	A,(Ycoord)
	RRA 
	RRA 
	RRA 
	AND	#1F
	LD	D,A
	LD	(TempXY),DE
	IN	A,(PORT_Y)
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,#54
	OUT	(SLOT3),A
	LD	A,D
	ADD	A,A
	ADD	A,A
	LD	L,A
	LD	H,#C3
	IN	A,(RGMOD)
	RRCA 
	AND	#80
	OR	#01
	ADD	A,E
	OUT	(PORT_Y),A
	INC	L
	INC	L
	LD	A,(HL)
	XOR	#77
	LD	(HL),A
	POP	BC
	LD	A,B
	OUT	(SLOT3),A
	LD	A,C
	OUT	(PORT_Y),A
	RET 
; Get mouse
GetMousInfo
	CALL	Read_MS
	RET	C
	LD	DE,(Xcoord)
	SRL	D
	RR	E
	SRL	D
	RR	E
	SRL	E
	LD	A,(Ycoord)
	RRA 
	RRA 
	RRA 
	AND	#1F
	LD	D,A
	LD	(Tcoords),DE
	RET 
; Input mouse data from lpt ports
Read_MS	SCF 
	IN	A,(Z84.SIO.Ch_B.Ctrl)
	BIT	0,A
	RET	Z
	IN	A,(Z84.SIO.Ch_B.Data)
	LD	L,A
	BIT	6,A
	RET	Z

Read_L1	IN	A,(Z84.SIO.Ch_B.Ctrl)
	RRCA 
	JR	NC,Read_L1
	IN	A,(Z84.SIO.Ch_B.Data)
	LD	E,A
	BIT	6,A
	RET	NZ

Read_L2	IN	A,(Z84.SIO.Ch_B.Ctrl)
	RRCA 
	JR	NC,Read_L2
	IN	A,(Z84.SIO.Ch_B.Data)
	LD	D,A
	BIT	6,A
	RET	NZ

	LD	A,E
	AND	#3F
	LD	E,A
	LD	A,L
	AND	#03
	RRCA 
	RRCA 
	OR	E
	LD	C,A		;X addition

	LD	A,D
	AND	#3F
	LD	D,A
	LD	A,L
	AND	#0C
	RRCA 
	RRCA 
	RRCA 
	RRCA 
	OR	D
	LD	B,A		;Y addition

	LD	A,L
	AND	#30
	RRCA 
	RRCA 
	RRCA 
	RRCA 
	LD	(MSbutt),A	; Button pressed
; Corrected mouse place
	LD	HL,(Xcoord)
	BIT	7,C
	JR	NZ,subX
	LD	E,C
	LD	D,#00
	ADD	HL,DE
	LD	DE,#027F
	EX	DE,HL
	SBC	HL,DE
	ADD	HL,DE
	JR	C,$+3
	EX	DE,HL
	LD	(Xcoord),HL
	JR	NxtCoord

subX	LD	E,C
	LD	D,#FF
	ADD	HL,DE
	JR	C,$+5
	LD	HL,#0000
	LD	(Xcoord),HL
NxtCoord
	LD	HL,(Ycoord)
	BIT	7,B
	JR	NZ,subY
	LD	A,L
	ADD	A,B
	JR	NC,$+4
	LD	A,#FF
	LD	L,A
	LD	(Ycoord),HL
	AND	A
	RET 

subY	LD	A,L
	ADD	A,B
	JR	C,$+3
	SUB	A
	LD	L,A
	LD	(Ycoord),HL
	AND	A
	RET 

MousFlg:	DEFB #00		; Flag mouse:
; #00 - mouse none
; #01

Coords:			; Coordinates mouse in
Xcoord:	DEFW #0140	; Coordinate X (0-639)
Ycoord:	DEFW #0080	; Coordinate Y (0-255)

TempXY:	DEFW #0000	; Coordinates in
; X (0-79), y (0-31)

MSbutt:	DEFB #00		; :
; 0 - button mouse
; 1 - button mouse

Tcoords:			; Coordinates mouse in
TcoordX:	DEFB #28		; Coordinate X (0-79)
TcoordY:	DEFB #10		; Coordinate Y (0-31)

; For from under mouse
MousBuf	DEFB #00
;
 _mCollectInfo_addEnd