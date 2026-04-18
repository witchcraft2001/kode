 _mCollectInfo_addStart
;[]===========================================================[]
;Event input line
EInpLine
	LD	HL,what	; Events list
	LD	A,(HL)
	INC	HL
	CP	evMouseFr
	JR	Z,EImouse
	CP	evKeyboard
	JR	Z,EIkeys
	CP	evCombKey
	JP	Z,EIcombK
	RET 
; Event - mouse fire
EImouse	LD	E,(HL)		;Xcoord
	INC	HL
	LD	D,(HL)		;Ycoord
	LD	A,D
	CP	(IX+#04)	;Y pos input line
	RET	NZ
	LD	A,E
	BIT	7,(IX+#02)
	JR	NZ,$+6
	CP	(IX+#02)	;Xo pos
	RET	C
	BIT	7,(IX+#03)
	RET	NZ
	CP	(IX+#03)	;Xi pos
	RET	NC
	BIT	7,(IX+#01)
	JR	Z,SetInLn
	BIT	7,(IX+#06)
	JR	NZ,$+6
	CP	(IX+#06)	;Xo inp.line
	RET	C
	SUB	(IX+#06)	; Shift from begin
	LD	C,A
	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	INC	HL
	LD	(HL),#00	;Flag
	INC	HL
	CP	(HL)
	RET	Z
	PUSH	HL
	INC	HL
	ADD	A,(HL)		; Addx
	INC	HL
	CP	(HL)		; Inpsymb
	LD	A,(HL)
	POP	HL
	JR	Z,EIM
	JR	C,EIM
	INC	HL
	SUB	(HL)
	DEC	HL
	LD	C,A
EIM	LD	(HL),C
	DEC	HL
	DEC	HL
	PUSH	IY
	PUSH	HL
	POP	IY
	CALL	PrnInLn
	POP	IY
	JR	InLnExt
; Event - key press
EIkeys	BIT	7,(IX+#01)
	JR	NZ,ILwork
	LD	A,(HL)
	RES	5,A
	CP	#09		;Tab
	JR	Z,SetInLn
	CP	(IX+#07)	;Hot key
	RET	NZ
SetInLn	CALL	MoveObj		; Select input line
	CALL	ResDialInv	;Reset previos invert
	LD	IX,DialTab+5
	LD	E,(IX+#02)	;Xo
	LD	D,(IX+#04)	;Y
	LD	A,(IX+#05)	;Xi text
	SUB	E
	LD	C,A		;Len text
	CALL	SetDialInv
	LD	A,(IX+#08)
	CALL	PutStatusLn
	PUSH	IY
	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	PUSH	HL
	POP	IY
	INC	HL
	LD	(HL),#01	;Flag
	INC	HL
	SUB	A
	LD	(HL),A		; Pos x
	INC	HL
	LD	(HL),A		; Add x
	INC	HL
	CALL	PrnInLn
	POP	IY
	CALL	PILCurs
	EI 
InLnExt	LD	HL,what
	LD	(HL),evNothing
	LD	A,#04
	RST	#00
	RET 
;Work select input line
ILwork	LD	A,(HL)		;Get keys
	CP	#08
	JR	Z,ILw1
	CP	#20
	RET	C
ILw1	PUSH	IY
	LD	DE,InLnWex
	PUSH	DE
	LD	L,(IX+#09)	;Address buffer
	LD	H,(IX+#0A)
	PUSH	HL
	POP	IY
	PUSH	AF
	RES	7,(IY+#01)
	LD	A,(InsertMode)
	AND	#01
	RRCA 
	OR	(IY+#01)
	LD	(IY+#01),A
	POP	AF
	CP	#08
	JP	Z,ILdelet
	EX	AF,AF'
	BIT	0,(IY+#01)
	CALL	NZ,ClearIL
	LD	A,(IY+#04)	; Inpytsymb
	CP	(IY+#00)	;Max len
	JR	NZ,ILn
	LD	A,(IY+#02)
	ADD	A,(IY+#03)
	CP	(IY+#00)
	RET	NC
	BIT	7,(IY+#01)
	RET	NZ
ILn	LD	A,(IY+#04)
	SUB	(IY+#03)
	SUB	(IY+#02)
	JR	Z,NoInsrt
	DEC	(IY+#04)
	BIT	7,(IY+#01)
	JR	Z,NoInsrt
	INC	(IY+#04)
; In text
	LD	C,A
	LD	B,#00
	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	LD	A,(IY+#04)
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	D,H
	LD	E,L
	DEC	HL
	LDDR 
NoInsrt	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	LD	A,(IY+#02)
	ADD	A,(IY+#03)
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	EX	AF,AF'
	LD	(HL),A
	INC	(IY+#04)
	INC	(IY+#02)
	LD	A,(IX+#03)
	SUB	(IX+#06)
	CP	(IY+#02)
	CALL	Z,OutIL
	CALL	PrnInLn
	POP	DE
InLnWex	LD	HL,what
	LD	(HL),evNothing
	POP	IY
	RET 
; Cursor for screen
OutIL	LD	A,(IY+#03)
	ADD	A,Step
	LD	(IY+#03),A
	LD	A,(IY+#02)
	SUB	Step
	LD	(IY+#02),A
	RET 
; Clear buffer
ClearIL	SUB	A
	LD	B,(IY+#00)
	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	(HL),A
	DJNZ	$-2
	LD	(IY+#04),A
	RES	0,(IY+#01)
	RET 
;Combination keys
EIcombK	BIT	7,(IX+#01)
	JR	NZ,EIcombn	; Is select
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
	JP	SetInLn

EIcombn	PUSH	IY
	INC	HL
	LD	A,(HL)
	LD	L,(IX+#09)	;Address buffer
	LD	H,(IX+#0A)
	LD	DE,InLnWex
	PUSH	DE
	PUSH	HL
	POP	IY
	CP	75
	JR	Z,ILleft
	CP	77
	JR	Z,ILright
	CP	83
	JP	Z,IL_del_
	CP	71
	JP	Z,ILHome
	CP	79
	JP	Z,ILEnd
	CP	116
	JP	Z,ILwordL
	CP	115
	JP	Z,ILwordR
	CP	141
	JP	Z,ILdelWR
	POP	DE
	POP	IY
	RET 
; Cursor on single place
ILleft	LD	A,(IY+#02)
	DEC	A
	JP	P,ILlfnxt
	LD	A,(IY+#03)
	SUB	Step
	RET	C
	LD	(IY+#03),A
	LD	A,(IY+#02)
	ADD	A,Step
ILlfnxt	LD	(IY+#02),A
	CALL	PrnInLn
	RES	0,(IY+#01)
	RET 
; Cursor on single place
ILright	LD	A,(IY+#02)
	ADD	A,(IY+#03)
	CP	(IY+#04)
	RET	Z
	LD	A,(IX+#03)
	SUB	(IX+#06)
	LD	B,A
	LD	A,(IY+#02)
	INC	A
	CP	B
	JR	NZ,ILrgnxt
	LD	A,(IY+#03)
	ADD	A,Step
	LD	(IY+#03),A
	LD	A,(IY+#02)
	SUB	Step
ILrgnxt	LD	(IY+#02),A
	CALL	PrnInLn
	RES	0,(IY+#01)
	RET 
; Delete
ILdelet	LD	A,(IY+#02)
	OR	A
	JR	NZ,ILDelNx
	LD	A,(IY+#03)
	SUB	Step
	RET	C
	LD	(IY+#03),A
	LD	A,(IY+#02)
	ADD	A,Step
	LD	(IY+#02),A
ILDelNx	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	LD	A,(IY+#02)
	ADD	A,(IY+#03)
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	D,H
	LD	E,L
	DEC	DE
	LD	A,(IY+#04)
	SUB	(IY+#03)
	SUB	(IY+#02)
	JR	Z,ILDelN
	LD	C,A
	LD	B,#00
	LDIR 
ILDelN	SUB	A
	LD	(DE),A
	DEC	(IY+#02)
	DEC	(IY+#04)
	CALL	PrnInLn
	RES	0,(IY+#01)
	RET 
; Delete char in current position
IL_del_	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	LD	A,(IY+#02)
	INC	A
	ADD	A,(IY+#03)
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	D,H
	LD	E,L
	DEC	DE
	LD	A,(IY+#04)
	SUB	(IY+#03)
	SUB	(IY+#02)
	RET	Z
	LD	C,A
	LD	B,#00
	LDIR 
	SUB	A
	LD	(DE),A
	DEC	(IY+#04)
	CALL	PrnInLn
	RES	0,(IY+#01)
	RET 
;Home
ILHome	LD	A,(IY+#02)
	OR	A
	RET	Z
	SUB	A
	LD	(IY+#02),A
	LD	(IY+#03),A
	CALL	PrnInLn
	RES	0,(IY+#01)
	RET 
;End string
ILEnd	LD	A,(IY+#04)
	SUB	(IY+#03)
	CP	(IY+#02)
	RET	Z
	ADD	A,(IY+#03)
	LD	C,A
	LD	(IY+#03),#00
	LD	A,(IX+#03)
	SUB	(IX+#06)
	SUB	C
	JR	Z,ILEndLp
	JR	NC,EndNIL
	NEG 
ILEndLp	LD	C,A
	LD	A,(IY+#03)
	ADD	A,Step
	LD	(IY+#03),A
	LD	A,C
	SUB	Step
	JR	NC,ILEndLp
EndNIL	LD	A,(IY+#04)
	SUB	(IY+#03)
	LD	(IY+#02),A
	CALL	PrnInLn
	RES	0,(IY+#01)
	RET 
;Word right
ILwordR	LD	A,(IY+#04)
	SUB	(IY+#03)
	SUB	(IY+#02)
	RET	Z
	LD	B,A
	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	LD	A,(IY+#02)
	ADD	A,(IY+#03)
	LD	C,A
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
wr0	LD	A,(HL)
	CP	#20
	JR	Z,WRIL1
	CP	","
	JR	Z,WRIL1
	CP	"."
	JR	Z,WRIL1
	INC	HL
	INC	C
	DJNZ	wr0
	JR	WRIL2
WRIL1	LD	A,(HL)
	CP	#20
	JR	Z,$+10
	CP	","
	JR	Z,$+6
	CP	"."
	JR	NZ,WRIL2
	INC	HL
	INC	C
	DJNZ	WRIL1
WRIL2	LD	(IY+#03),#00
	LD	A,(IX+#03)
	SUB	(IX+#06)
	LD	B,A
	LD	A,C
	SUB	B
	JR	C,WRIL4
WRIL3	LD	E,A
	LD	A,(IY+#03)
	ADD	A,Step
	LD	(IY+#03),A
	LD	A,E
	SUB	Step
	JR	NC,WRIL3
WRIL4	LD	A,C
	SUB	(IY+#03)
	LD	(IY+#02),A
	CALL	PrnInLn
	RES	0,(IY+#01)
	RET 
;Word left
ILwordL	LD	A,(IY+#02)
	ADD	A,(IY+#03)
	RET	Z
	LD	B,A
	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	LD	C,A
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
wl0	DEC	HL
	DEC	C
	LD	A,(HL)
	CP	#20
	JR	Z,WLIL1
	CP	","
	JR	Z,WLIL1
	CP	"."
	JR	Z,WLIL1
	DJNZ	wl0
	JR	WLIL2
WLIL1	LD	A,(HL)
	CP	#20
	JR	Z,$+10
	CP	","
	JR	Z,$+6
	CP	"."
	JR	NZ,WLIL2-1
	DEC	HL
	DEC	C
	DJNZ	WLIL1
	INC	C
WLIL2	LD	(IY+#03),#00
	LD	A,(IX+#03)
	SUB	(IX+#06)
	LD	B,A
	LD	A,C
	SUB	B
	JR	C,WLIL4
WLIL3	LD	E,A
	LD	A,(IY+#03)
	ADD	A,Step
	LD	(IY+#03),A
	LD	A,E
	SUB	Step
	JR	NC,WLIL3
WLIL4	LD	A,C
	SUB	(IY+#03)
	LD	(IY+#02),A
	CALL	PrnInLn
	RES	0,(IY+#01)
	RET 
; Delete word
ILdelWR	LD	A,(IY+#02)
	ADD	A,(IY+#03)
	RET	Z
	LD	B,A
	LD	A,(IY+#04)
	SUB	B
	LD	E,A
	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	LD	C,B
	LD	A,C
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	PUSH	HL
	DEC	HL
	DEC	C
	LD	A,(HL)
	CP	#20
	JR	Z,DWIL1
	CP	","
	JR	Z,DWIL1
	CP	"."
	JR	Z,DWIL1
	DEC	B
	JR	Z,DWIL2
dw0	DEC	HL
	DEC	C
	LD	A,(HL)
	CP	#20
	JR	Z,DWIL2-2
	CP	","
	JR	Z,DWIL2-2
	CP	"."
	JR	Z,DWIL2-2
	DJNZ	dw0
	JR	DWIL2
DWIL1	LD	A,(HL)
	CP	#20
	JR	Z,$+10
	CP	","
	JR	Z,$+6
	CP	"."
	JR	NZ,DWIL2-2
	DEC	HL
	DEC	C
	DJNZ	DWIL1
	INC	HL
	INC	C
DWIL2	LD	A,C
	EX	AF,AF'
	LD	A,(IY+#02)
	ADD	A,(IY+#03)
	SUB	C
	LD	C,A
	LD	A,(IY+#04)
	SUB	C
	LD	(IY+#04),A
	LD	A,C
	LD	(DWIL21+1),A
	LD	C,E
	LD	B,#00
	EX	DE,HL
	POP	HL
	LD	A,C
	OR	A
	JR	Z,$+4
	LDIR 
	EX	DE,HL
DWIL21	LD	B,#00
	LD	(HL),C
	INC	HL
	DJNZ	$-2
	EX	AF,AF'
	LD	C,A
	LD	(IY+#03),#00
	LD	A,(IX+#03)
	SUB	(IX+#06)
	LD	B,A
	LD	A,C
	SUB	B
	JR	C,DWIL4
DWIL3	LD	E,A
	LD	A,(IY+#03)
	ADD	A,Step
	LD	(IY+#03),A
	LD	A,E
	SUB	Step
	JR	NC,DWIL3
DWIL4	LD	A,C
	SUB	(IY+#03)
	LD	(IY+#02),A
	CALL	PrnInLn
	RES	0,(IY+#01)
	RET 
;[]===========================================================[]
;Event claster radio/check buttons
EClasterB
	LD	HL,what
	LD	A,(HL)
	INC	HL
	CP	evMouseFr
	JR	Z,ECmouse	;Mouse fire
	CP	evKeyboard
	JR	Z,ECkeys	;Key press
	CP	evCombKey
	JP	Z,ECcombK	;Key press
	RET 
; Event - mouse fire
ECmouse	LD	E,(HL)	;Xpos
	INC	HL
	LD	D,(HL)	;Ypos
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
	CP	(IX+#04)	;Yo pos
	RET	C		;<
	CP	(IX+#05)	;Yi pos
	RET	NC		;>
	SUB	A
	LD	(ECnext+1),A
	DEC	A
	LD	(SaveA1+1),A	;Begin element claster
	PUSH	IX
	POP	HL
	INC	HL
	LD	BC,#0006	; Len element claster
	LD	E,B		; Number element
	LD	A,D
EClsLp1	ADD	HL,BC
	BIT	7,(HL)
	JP	NZ,SelClas	;Elem not found
	INC	E
	CP	(HL)		; Compare with y pos elem
	JR	NZ,EClsLp1
	JR	CSelNxt
; Event - key press
ECkeys	SUB	A
	LD	(ECnext+1),A
	DEC	A
	LD	(SaveA1+1),A	;Begin element claster
	LD	A,(HL)
	CP	#20
	JR	Z,ECspace
	RES	5,A
	BIT	7,(IX+#01)
	JR	NZ,ECkeyN	;I is select
	CP	#09		;Tab
	JP	Z,SelCls0	; If tab then select my
ECkeyN	PUSH	IX
	POP	HL
	INC	HL
	LD	BC,#0006	;Len elements
	LD	E,B
ECkeyLp	ADD	HL,BC
	BIT	7,(HL)
	RET	NZ
	INC	E
	INC	HL
	CP	(HL)		;Hot key element
	DEC	HL
	JR	NZ,ECkeyLp
CSelNxt	BIT	7,(IX+#01)	; Nz-object is select
	JP	NZ,CSelect
	JP	SelCls1
; Test by space
ECspace	BIT	7,(IX+#01)
	RET	Z		; Not select
	LD	A,(SavElem+1)
	OR	A
	JR	NZ,ECspc1
	INC	A
	LD	(SavElem+1),A
ECspc1	LD	(ECnext+1),A
	PUSH	IX
	POP	HL
	INC	HL
	LD	DE,#0006
	LD	B,A
	ADD	HL,DE		; Find elem.label
	DJNZ	$-1
	JP	ECnext		; Change
; Test by cursor keys
ECcombK	BIT	7,(IX+#01)
	JR	NZ,ECcombn	; Is select
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
	JP	SelCls0		; If tab then select my

ECcombn	SUB	A
	LD	(ECnext+1),A	;Flag change buttons
	INC	HL
	LD	A,(HL)
	CP	72	;^
	JR	Z,ECup
	CP	75	;<-
	JR	Z,ECup
	CP	80
	JR	Z,ECdown ;
	CP	77
	RET	NZ	;->
; Cursor down
ECdown	PUSH	IX
	POP	HL
	INC	HL
	LD	E,L
	LD	D,H
	LD	BC,#0006
	LD	A,(SavElem+1)
	OR	A
	JR	NZ,$+3
	INC	A
	INC	A		; Increment element
	LD	(SavElem+1),A
ECcmlp	ADD	HL,BC		; Find label
	BIT	7,(HL)
	CALL	NZ,EndClst	; Table is over
	DEC	A
	JR	NZ,ECcmlp
	CALL	ResClasInv	;Res inver elem
	JP	Pcurs		; Next invert
;Get begin table elem
EndClst	EX	DE,HL
	ADD	HL,BC		; Table is begin
	LD	A,#01
	LD	(SavElem+1),A	; First elem.
	RET 
; Cursor up
ECup	PUSH	IX
	POP	HL
	INC	HL
	LD	DE,#0006
	LD	A,(SavElem+1)
	OR	A
	JR	NZ,$+3
	INC	A
	DEC	A		; Decrement cur.elem.
	CALL	Z,BegClst
	LD	(SavElem+1),A
	LD	B,A
	ADD	HL,DE		; Find label
	DJNZ	$-1
	CALL	ResClasInv	;Res inver elem
	JR	Pcurs		; Next invert
;Get end table elem
BegClst	PUSH	HL
	SUB	A
	DEC	A
	INC	A
	ADD	HL,DE		; Find nember end element
	BIT	7,(HL)
	JR	Z,$-4
	POP	HL
	RET			;A=end element
; Selected claster
SelClas	BIT	7,(IX+#01)
	JR	NZ,SaveA1	; Nz-is select
SelCls0	LD	E,#00
SelCls1	LD	A,E
	LD	(SaveA1+1),A
	CALL	MoveObj
	CALL	ResDialInv	;Res orevios invert
	LD	IX,DialTab+5
	LD	E,(IX+#02)	;Xo name
	INC	E
	LD	D,(IX+#04)	;Y name
	LD	A,(IX+#06)	;Xi name
	SUB	E
	LD	C,A		; Len name
	CALL	SetDialInv	; Set my invert
SaveA1	LD	A,#00
	INC	A
	JR	Z,EClexit	;Element not found
	DEC	A
	LD	(SavElem+1),A
	LD	(ECnext+1),A
	JR	CButton		; Change buttons
; Event - mouse fire(in select claster)
CSelect	LD	A,#01
	LD	(ECnext+1),A
	LD	A,(SavElem+1)
	CP	E
	JR	Z,ECnext
	LD	A,E
	LD	(SavElem+1),A
	CALL	ResClasInv	;Res inver elem
CButton	PUSH	IX
	POP	HL
	INC	HL
	LD	DE,#0006
SavElem	LD	A,#00
	OR	A
	JR	NZ,$+3
	INC	A
	LD	B,A
	ADD	HL,DE
	DJNZ	$-1
Pcurs	LD	E,(IX+#02)	; Xo pos element
	INC	E
	LD	D,(HL)		;Y pos element
	LD	A,(IX+#03)
	SUB	E
	DEC	A
	LD	C,A		; Len element
	CALL	SetClasInv	;Set inver elem
	INC	HL
	INC	HL
	LD	A,(HL)
	DEC	HL
	DEC	HL
	CALL	PutStatusLn
ECnext	LD	A,#00
	OR	A
	CALL	NZ,ChangeB
EClexit	LD	HL,what		;Event claster exit
	LD	(HL),evNothing
	LD	A,#04		;Wait pop fire
	RST	#00
	RET 
;[]===========================================================[]
; Event list box
EListBox
	LD	HL,what	; Events list
	LD	A,(HL)
	INC	HL
	CP	evMouseFr
	JP	Z,ELmouse
	CP	evKeyboard
	JP	Z,ELkeys
	CP	evMessage
	JR	Z,ELmess
	CP	evCombKey
	RET	NZ
	BIT	7,(IX+#01)
	JR	NZ,ELcomb
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
	JP	SetLstBox	; If shift+tab then select my

ELmess	LD	A,(HL)
	INC	HL
	CP	msHiddInvr
	JR	NZ,ELmess1
	BIT	7,(IX+#01)
	RET	NZ
	LD	A,(IX+#09)
	OR	A
	RET	Z
	JP	HdLstBoxI
ELmess1	CP	msNewList
	RET	NZ
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(IX+#0A),E
	LD	(IX+#0B),D
	LD	(IX+#11),E
	LD	(IX+#12),D
	LD	B,#00
ELmess2	LD	A,(DE)
	INC	DE
	CP	#0D
	JR	NZ,ELmess2
	INC	B
	LD	A,(DE)
	OR	A
	JR	NZ,ELmess2
ELmessE	LD	(IX+#09),B
	CALL	RsLstBoxI
	SUB	A
	LD	(IX+#07),A
	LD	(IX+#08),A
	LD	A,(IX+#09)
	OR	A
	JR	Z,ELmesE1
	BIT	7,(IX+#01)
	PUSH	AF
	CALL	Z,HdLstBoxI
	POP	AF
	CALL	NZ,StLstBoxI
ELmesE1	CALL	PrnLstBox
	CALL	LstBoxBar
	JP	ELboxex

ELcomb	INC	HL
	LD	DE,ELexit
	PUSH	DE
	LD	A,(HL)
	CP	72	; Curs up
	JR	Z,ELup
	CP	80	;Curs down
	JP	Z,ELdown
	CP	73
	JP	Z,ELpgup
	CP	81
	JP	Z,ELpgdwn
	CP	71
	JP	Z,ELhome
	CP	79
	JP	Z,ELend
	POP	DE
	RET 

ELup	LD	A,(IX+#09)
	CP	#02
	RET	C
	LD	A,(IX+#07)
	DEC	A
	JP	M,ELup1
	CALL	RsLstBoxI
	LD	(IX+#07),A
	CALL	StLstBoxI
	CALL	LstBoxBar
	JP	ELboxex
ELup1	LD	A,(IX+#08)
	DEC	A
	RET	M
	LD	(IX+#08),A
	LD	L,(IX+#0A)
	LD	H,(IX+#0B)
	JR	Z,ELupn1
	LD	L,(IX+#11)
	LD	H,(IX+#12)
	DEC	HL
	DEC	HL
	LD	A,(HL)
	CP	#0D
	JR	NZ,$-4
	INC	HL
ELupn1	LD	(IX+#11),L
	LD	(IX+#12),H
	CALL	PrnLstBox
	CALL	LstBoxBar
	JP	ELboxex

ELdown	LD	A,(IX+#09)
	CP	#02
	RET	C
	LD	A,(IX+#05)
	SUB	(IX+#04)
	SUB	#02
	LD	C,A
	LD	A,(IX+#07)
	ADD	A,(IX+#08)
	INC	A
	CP	(IX+#09)
	RET	Z
	SUB	(IX+#08)
	CP	C
	JR	Z,ELdown1
	CALL	RsLstBoxI
	LD	(IX+#07),A
	CALL	StLstBoxI
	CALL	LstBoxBar
	JP	ELboxex
ELdown1	LD	A,(IX+#08)
	INC	A
	LD	(IX+#08),A
	LD	L,(IX+#0A)
	LD	H,(IX+#0B)
	JR	Z,ELdwn1
	LD	L,(IX+#11)
	LD	H,(IX+#12)
	LD	A,(HL)
	INC	HL
	CP	#0D
	JR	NZ,$-4
ELdwn1	LD	(IX+#11),L
	LD	(IX+#12),H
	CALL	PrnLstBox
	CALL	LstBoxBar
	JP	ELboxex

ELpgup	LD	A,(IX+#09)
	CP	#02
	RET	C
	LD	A,(IX+#08)
	OR	A
	LD	B,#01
	JP	Z,ELnopg
	LD	A,(IX+#05)
	SUB	(IX+#04)
	SUB	#02
	LD	C,A
	LD	A,(IX+#08)
	SUB	C
	JR	NC,$+3
	SUB	A
	LD	(IX+#08),A
	JR	ELpgex

ELpgdwn	LD	A,(IX+#09)
	CP	#02
	RET	C
	LD	A,(IX+#05)
	SUB	(IX+#04)
	SUB	#02
	LD	C,A
	LD	A,(IX+#09)
	SUB	(IX+#08)
	LD	B,A
	CP	C
	JR	C,ELnopg
	JR	Z,ELnopg
	LD	A,(IX+#08)
	ADD	A,C
	CP	(IX+#09)
	JR	C,$+6
	LD	A,(IX+#09)
	SUB	C
	LD	(IX+#08),A
	ADD	A,C
	CP	(IX+#09)
	JR	C,ELpgex
	JR	Z,ELpgex
	LD	A,(IX+#09)
	SUB	C
	LD	(IX+#08),A

ELpgex	LD	L,(IX+#0A)
	LD	H,(IX+#0B)
	LD	A,(IX+#08)
	OR	A
	JR	Z,ELpgex1
	LD	B,A
	LD	A,(HL)
	INC	HL
	CP	#0D
	JR	NZ,$-4
	DJNZ	$-6
ELpgex1	LD	(IX+#11),L
	LD	(IX+#12),H
	CALL	PrnLstBox
	CALL	LstBoxBar
	LD	A,(IX+#07)
	ADD	A,(IX+#08)
	CP	(IX+#09)
	JR	C,ELboxex
	LD	A,(IX+#09)
	SUB	(IX+#08)
	LD	B,A

ELnopg	DEC	B
	LD	A,B
	CP	(IX+#07)
	RET	Z
	CALL	RsLstBoxI
	LD	(IX+#07),A
	CALL	StLstBoxI
	CALL	LstBoxBar

ELboxex	LD	HL,what
	LD	(HL),evMessage
	INC	HL
	LD	(HL),msNewElem
	INC	HL
	LD	A,(IX+#07)
	ADD	A,(IX+#08)
	LD	(HL),A		; Current
	CALL	TransMessUp
	LD	B,#08
	LD	A,#03
	RST	#00
	RET	Z
	HALT 
	DJNZ	$-5
	RET 

ELhome	LD	A,(IX+#08)
	OR	A
	JR	Z,ELhome1
	LD	(IX+#08),#00
	LD	L,(IX+#0A)
	LD	H,(IX+#0B)
	LD	(IX+#11),L
	LD	(IX+#12),H
	CALL	PrnLstBox
ELhome1	LD	A,(IX+#07)
	OR	A
	RET	Z
	CALL	RsLstBoxI
	LD	(IX+#07),#00
	CALL	StLstBoxI
	CALL	LstBoxBar
	RET 

ELend	LD	A,(IX+#08)
	ADD	A,(IX+#07)
	INC	A
	CP	(IX+#09)
	RET	Z
	LD	A,(IX+#05)
	SUB	(IX+#04)
	SUB	#02
	LD	C,A
	LD	A,(IX+#09)
	SUB	C
	JR	C,ELend1
	JR	Z,ELend1
	LD	A,(IX+#09)
	SUB	C
	LD	(IX+#08),A
	LD	L,(IX+#0A)
	LD	H,(IX+#0B)
	LD	B,A
	LD	A,(HL)
	INC	HL
	CP	#0D
	JR	NZ,$-4
	DJNZ	$-6
	LD	(IX+#11),L
	LD	(IX+#12),H
	CALL	RsLstBoxI
	CALL	PrnLstBox
	LD	A,(IX+#09)
	DEC	A
	SUB	(IX+#08)
	LD	(IX+#07),A
	CALL	StLstBoxI
	CALL	LstBoxBar
	RET 
ELend1	CALL	RsLstBoxI
	LD	A,(IX+#09)
	DEC	A
	LD	(IX+#07),A
	CALL	StLstBoxI
	CALL	LstBoxBar
	RET 
; Event - mouse fire
ELmouse	LD	E,(HL)		;Xcoord
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
	CALL	Z,SetLstBox
	POP	DE
	LD	HL,ELexit
	PUSH	HL
	LD	A,(IX+#09)
	OR	A
	RET	Z
	LD	A,E
	ADD	A,2
	CP	(IX+#03)
	JR	Z,ELmous1
	RET	NC
	LD	A,E
	CP	(IX+#02)
	RET	Z
	LD	A,D
	CP	(IX+#04)
	RET	Z
	INC	A
	CP	(IX+#05)
	RET	Z
	LD	A,D
	SUB	(IX+#04)
	DEC	A
	ADD	A,(IX+#08)
	CP	(IX+#09)
	JR	C,$+6
	LD	A,(IX+#09)
	DEC	A
	SUB	(IX+#08)
	CP	(IX+#07)
	JR	Z,SelLine
	CALL	RsLstBoxI
	LD	(IX+#07),A
	CALL	StLstBoxI
	CALL	LstBoxBar
	CALL	ELboxex
	RET 
SelLine	POP	HL
	LD	HL,what
	LD	(HL),evCommand
	INC	HL
	LD	(HL),cmSelect
	RET 
ELmous1	LD	A,D
	CP	(IX+#0C)
	RET	C
	JP	Z,ELup
	CP	(IX+#0D)
	JP	Z,ELdown
	RET	NC
	CP	(IX+#0E)
	RET	Z
	JP	C,ELpgup
	JP	NC,ELpgdwn
	RET 

; Event - key press
ELkeys	LD	A,(HL)
	RES	5,A
	BIT	7,(IX+#01)	; Sel or nosel
	RET	NZ
	CP	#09		;Tab
	JR	Z,SetLstBox	; If tab then set button
	CP	(IX+#0F)	;Hot key
	RET	NZ
SetLstBox
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
	LD	A,(IX+#10)
	CALL	PutStatusLn
	LD	A,(IX+#09)
	OR	A
	CALL	NZ,StLstBoxI
	LD	HL,what
	LD	(HL),evMessage
	INC	HL
	LD	(HL),msNewElem
	INC	HL
	LD	A,(IX+#07)
	ADD	A,(IX+#08)
	LD	(HL),A		; Current
	CALL	TransMessUp
ELexit	LD	HL,what
	LD	(HL),evNothing
	RET 
;[]===========================================================[]
EResident1
	LD	HL,what
	LD	A,(HL)
	INC	HL
	CP	evCommand
	JR	NZ,ERes1
	LD	A,(HL)
	DEC	HL
	CP	cmSelect
	RET	NZ
	LD	(HL),evNothing
	RET 
ERes1	CP	evMessage
	RET	NZ
	LD	A,(HL)
	CP	msNewElem
	RET	NZ
	LD	(HL),msNewList
	INC	HL
	PUSH	HL
	LD	L,(HL)
	LD	H,#00
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,ItemTab
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	POP	HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	(AdrCol+1),BC
	RET 
;[]===========================================================[]
EResident2
	LD	HL,what
	LD	A,(HL)
	INC	HL
	CP	evCommand
	JR	NZ,ERes2
	LD	A,(HL)
	DEC	HL
	CP	cmSelect
	RET	NZ
	LD	(HL),evNothing
	RET 
ERes2	CP	evMessage
	RET	NZ
	LD	A,(HL)
	CP	msNewElem
	RET	NZ
	LD	(HL),msNewColor
	INC	HL
	LD	C,(HL)
	LD	B,#00
	EX	DE,HL
AdrCol	LD	HL,#0000
	ADD	HL,BC
	ADD	HL,BC
	EX	DE,HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	RET 
;[]===========================================================[]
EPallete
	LD	HL,what
	LD	A,(HL)
	INC	HL
	CP	evMouseFr
	JP	Z,EPmouse
	CP	evKeyboard
	JP	Z,EPkeys
	CP	evMessage
	JR	Z,EPmess
	CP	evCombKey
	RET	NZ
	BIT	7,(IX+#01)
	JR	NZ,EPcomb
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
	JP	SetPalBox
;
EPmess	LD	A,(HL)
	INC	HL
	CP	msNewColor
	RET	NZ
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	L,(IX+#0C)
	LD	H,(IX+#0D)
	EX	DE,HL
	INC	DE
	LD	A,(DE)
	AND	(IX+#09)
	JR	Z,EPmess1
	DEC	DE
	LD	A,(DE)
	AND	(IX+#09)
	LD	B,A
	INC	HL
	LD	A,(HL)
	DEC	HL
	AND	(IX+#09)
	JR	Z,EPmess1
	LD	A,(HL)
	AND	(IX+#09)
	CP	B
	JR	Z,EPmess1+3
EPmess1	CALL	ResPalCurs
	LD	(IX+#0C),L
	LD	(IX+#0D),H
	INC	HL
	LD	A,(HL)
	AND	(IX+#09)
	CALL	NZ,SetPalCurs
	RET 

EPcomb	INC	HL
	LD	DE,EPexit
	PUSH	DE
	LD	A,(HL)
	CP	72	; Curs up
	JP	Z,EPup
	CP	80	;Curs down
	JP	Z,EPdown
	CP	75
	JP	Z,EPleft
	CP	77
	JP	Z,EPright
	POP	DE
	RET 

EPup	LD	L,(IX+#0C)
	LD	H,(IX+#0D)
	INC	HL
	LD	A,(HL)
	AND	(IX+#09)
	RET	Z
	DEC	HL
	LD	A,(HL)
	AND	(IX+#09)
	BIT	7,(IX+#09)
	JR	Z,$+6
	RRCA 
	RRCA 
	RRCA 
	RRCA 
	SUB	(IX+#07)
	RET	C
	JP	EPex

EPdown	LD	B,(IX+#08)
	SUB	A
	ADD	A,(IX+#07)
	DJNZ	$-3
	LD	C,A
	LD	L,(IX+#0C)
	LD	H,(IX+#0D)
	INC	HL
	LD	A,(HL)
	AND	(IX+#09)
	RET	Z
	DEC	HL
	LD	A,(HL)
	AND	(IX+#09)
	BIT	7,(IX+#09)
	JR	Z,$+6
	RRCA 
	RRCA 
	RRCA 
	RRCA 
	ADD	A,(IX+#07)
	CP	C
	RET	NC
	JP	EPex
EPleft	LD	L,(IX+#0C)
	LD	H,(IX+#0D)
	INC	HL
	LD	A,(HL)
	AND	(IX+#09)
	RET	Z
	DEC	HL
	LD	A,(HL)
	AND	(IX+#09)
	BIT	7,(IX+#09)
	JR	Z,$+6
	RRCA 
	RRCA 
	RRCA 
	RRCA 
	DEC	A
	RET	M
	JP	EPex
EPright	LD	B,(IX+#08)
	SUB	A
	ADD	A,(IX+#07)
	DJNZ	$-3
	LD	C,A
	LD	L,(IX+#0C)
	LD	H,(IX+#0D)
	INC	HL
	LD	A,(HL)
	AND	(IX+#09)
	RET	Z
	DEC	HL
	LD	A,(HL)
	AND	(IX+#09)
	BIT	7,(IX+#09)
	JR	Z,$+6
	RRCA 
	RRCA 
	RRCA 
	RRCA 
	INC	A
	CP	C
	RET	NC

EPex	CALL	ResPalCurs
	BIT	7,(IX+#09)
	JR	Z,$+6
	RLCA 
	RLCA 
	RLCA 
	RLCA 
	LD	C,A
	LD	A,(IX+#09)
	CPL 
	LD	B,A
	LD	A,(HL)
	AND	B
	OR	C
	LD	(HL),A
	CALL	SetPalCurs
	LD	HL,what
	LD	(HL),evMessage
	INC	HL
	LD	(HL),msNewColor
	INC	HL
	LD	A,(IX+#0C)
	LD	(HL),A
	INC	HL
	LD	A,(IX+#0D)
	LD	(HL),A
	JP	TransMessUp

; Event - mouse fire
EPmouse	LD	E,(HL)		;Xcoord
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
	CALL	Z,SetPalBox
	POP	DE
	LD	HL,EPexit
	PUSH	HL
	LD	L,(IX+#0C)
	LD	H,(IX+#0D)
	INC	HL
	LD	A,(HL)
	DEC	HL
	AND	(IX+#09)
	RET	Z
	LD	A,E
	CP	(IX+#02)
	RET	Z
	INC	A
	CP	(IX+#03)
	RET	Z
	SUB	(IX+#02)
	SUB	#02
	LD	C,A
	LD	A,D
	CP	(IX+#04)	; Yo pos list box
	RET	Z
	INC	A
	CP	(IX+#05)	; Yi pos list box
	RET	Z
	SUB	(IX+#04)
	SUB	#02
	SRL	A
	JR	Z,EPmous1
	LD	B,A
	SUB	A
	ADD	A,(IX+#07)
	DJNZ	$-3
EPmous1	LD	E,A
	LD	A,C
	LD	B,#FF
	INC	B
	SUB	#05
	JR	NC,$-3
	LD	A,B
	ADD	A,E
	LD	B,A
	BIT	7,(IX+#09)
	JR	Z,$+6
	RLCA 
	RLCA 
	RLCA 
	RLCA 
	LD	C,A
	LD	A,(HL)
	AND	(IX+#09)
	CP	C
	RET	Z
	LD	A,B
	JP	EPex
; Event - key press
EPkeys	LD	A,(HL)
	RES	5,A
	BIT	7,(IX+#01)	; Sel or nosel
	RET	NZ
	CP	#09		;Tab
	JR	Z,SetPalBox	; If tab then set button
	CP	(IX+#0A)	;Hot key
	RET	NZ
SetPalBox
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
	LD	A,(IX+#0B)
	CALL	PutStatusLn
EPexit	LD	HL,what
	LD	(HL),evNothing
	RET 
;
 _mCollectInfo_addEnd