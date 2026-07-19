 _mCollectInfo_addStart
; Initialize status line (down line)
;Work event from mouse,keyboar combination
InitStatLn
	LD	A,NoConTxt	;Main context
	JR	PutStatLn
PrvStatLn
	LD	A,(PrvConTxt)
;Initialize status line,status table for mouse
PutStatLn
	PUSH	IX
	PUSH	HL
	PUSH	DE
	EX	AF,AF'
	LD	IX,StatTab
	LD	HL,StLlist
	LD	A,(CurConTxt)
	LD	(PrvConTxt),A
	EX	AF,AF'		; Number
	LD	(CurConTxt),A
	LD	E,A	; Number context
	LD	D,#00
	ADD	HL,DE
	ADD	HL,DE
	LD	E,(HL)	; De-address context place
	INC	HL
	LD	D,(HL)
	LD	HL,ReCompBuff
	LD	B,#00		; B=begin x coords
	LD	A,(ColMenuBar)
	LD	C,A		;C=color menubar
	LD	(HL),#20
	INC	HL
	LD	(HL),C
	INC	HL
	INC	B
InStLn1	LD	(HL),#20
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(IX+#00),B	; Left x coords
	INC	IX
	INC	B
	LD	A,(DE)		;Get genered command
	INC	DE
	CP	Txt
	JP	Z,onlytxt	; Only text
	LD	(IX+#01),A
	EX	AF,AF'
	LD	A,(DE)
	OR	A
	JR	Z,noname
	EX	AF,AF'
	CALL	TstCmnd
	JR	Z,HiddStC
	EX	AF,AF'
InStLn2	INC	DE
	CP	"~"		;Flag hot key
	CALL	Z,Bhotkey
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	INC	B
	LD	A,(DE)
	OR	A
	JR	NZ,InStLn2
InStLn3	INC	DE
	LD	(HL),#20
	INC	HL
	LD	(HL),C
	INC	HL
	INC	B
	LD	(IX+#00),B	; Right x coords
	INC	IX
	INC	IX
	LD	A,(DE)		; Hot key calls
	INC	DE
	LD	(IX+#00),A
	INC	IX
	LD	A,(DE)		; Ff- end status line
	CP	#FF
	JR	NZ,InStLn1
InStLnP	LD	(IX+#00),#FF	; #ff-end mouse table
	LD	A,#50
	SUB	B
	JR	Z,InStLnE
	LD	B,A		;Fill to end screen
	LD	(HL),#20
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-5
InStLnE	LD	IX,ReCompBuff + NEW_ADDR*2	; Put status ln by screen
	LD	HL,#0150
	LD	DE,#1F00
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	POP	DE
	POP	HL
	POP	IX
	RET 

HiddStC	LD	A,C
	EX	AF,AF'
	LD	A,C
	AND	#F0
	LD	C,A
	LD	A,(ColHiddenC)
	OR	C
	LD	C,A
HiddSt1	LD	A,(DE)
	INC	DE
	CP	"~"
	JR	Z,HiddSt1
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	INC	B
	LD	A,(DE)
	OR	A
	JR	NZ,HiddSt1+1
	EX	AF,AF'
	LD	C,A
	JR	InStLn3

noname	DEC	IX
	DEC	DE
nonameL	LD	(IX+#00),#80	;End mouse coords
	INC	IX
	LD	(IX+#00),#80
	INC	IX
	LD	A,(DE)
	INC	DE
	INC	DE
	LD	(IX+#00),A
	INC	IX
	LD	A,(DE)		; Hot key calls
	INC	DE
	LD	(IX+#00),A
	INC	IX
	LD	A,(DE)		; Ff- end status line
	CP	#FF
	JR	NZ,nonameL
	JR	InStLnP

onlytxt	DEC	IX
	DEC	HL
	DEC	HL
	LD	A,(DE)
onlyTlp	INC	DE
	CP	"~"		;Flag hot key
	CALL	Z,Bhotkey
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(DE)
	CP	#FF
	JR	NZ,onlyTlp
	INC	DE
	JP	InStLnP

CurConTxt
	DEFB	#00
PrvConTxt
	DEFB	#00
; Genered status line table for work
; Format: +0 - xo coord
; +1 - xi coord
; +2 - genered command
; +3 - keyboard combination
StatTab	DEFS	#80,0

; Main programm statusline
StatusLine
	LD	HL,what
	LD	DE,StatExt
	PUSH	DE
	LD	A,(HL)
	INC	HL
	CP	evMouseFr
	JR	Z,STmouse
	CP	evCombKey
	JR	Z,STcbkey
	POP	DE
StatExt	LD	HL,what		; End object (res pole what)
	LD	(HL),evNothing
	RET 

;Test mouse event
STmouse	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	A,D
	CP	#1F	; Test ycoords by down line
	RET	NZ	; If false then exit
	LD	IX,StatTab-4
	LD	BC,#0004
	LD	A,E
STmous1	ADD	IX,BC
	BIT	7,(IX+#00)	; #80-end vision table
	RET	NZ
	CP	(IX+#00)
	JR	C,STmous1
	CP	(IX+#01)
	JR	NC,STmous1
Sselect	LD	A,(IX+#02)
	CALL	TstCmnd
	RET	Z
	PUSH	IX
	CALL	SetStLI
	LD	B,#05
	HALT 
	DJNZ	$-1
	CALL	ResStLI
	POP	IX
Sselnxt	LD	HL,what
	LD	(HL),evCommand
	INC	HL
	LD	A,(IX+#02)
	LD	(HL),A
	SUB	A
	DEC	A
	LD	(Cobject),A	;Returned to first object
	POP	DE
	LD	A,#04
	RST	#00
	RET 

;Keyboard combination
STcbkey	INC	HL
	LD	L,(HL)		; Combintion
	LD	IX,StatTab-4
	LD	BC,#0004
	LD	H,B
STkey1	ADD	IX,BC
	LD	A,(IX+#00)	; #ff-full end table
	CP	#FF
	RET	Z
	BIT	7,A
	JR	Z,$+4
	SET	0,H
	LD	A,L
	CP	(IX+#03)	; Compare
	JR	NZ,STkey1
	BIT	0,H
	JR	Z,Sselect
	LD	A,(IX+#02)
	CALL	TstCmnd
	RET	Z
	JR	Sselnxt

; Set by screen status line current invert
SetStLI	LD	E,(IX+#00)	;Xo
	LD	D,#1F		; Y = #1f
	LD	A,(IX+#01)
	SUB	E		; Xi-xo=lenx
	LD	L,A
	LD	H,#01		; Len y
	LD	(RStIlen+1),HL
	LD	(RStIpos+1),DE
	PUSH	AF		; Save lenx
	LD	IX,ReCompBuff + NEW_ADDR*2	; Get name stline
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B2
	SUB	A
	RST	#10
	POP	AF		; Reset lenx
	LD	HL,ReCompBuff
	LD	B,A
	LD	A,(ColInvr)
	LD	C,A
SetInvS	INC	HL
	LD	A,(HL)		;Set invert
	AND	#0F
	OR	C
	LD	(HL),A
	INC	HL
	DJNZ	SetInvS
	LD	IX,ReCompBuff + NEW_ADDR*2	; Put name with invert
	LD	HL,(RStIlen+1)
	LD	DE,(RStIpos+1)
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	RET 

; Res by screen menubar current invert
ResStLI	LD	IX,ReCompBuff + NEW_ADDR*2	;Get name with invert
RStIlen	LD	HL,#0000
RStIpos	LD	DE,#0000
	LD	A,L
	PUSH	AF
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B2
	SUB	A
	RST	#10
	POP	AF
	LD	HL,ReCompBuff
	LD	B,A
	LD	A,(ColMenuBar)
	AND	#F0
	LD	C,A
ResInvS	INC	HL
	LD	A,(HL)		;Set invert
	AND	#0F
	OR	C
	LD	(HL),A
	INC	HL
	DJNZ	ResInvS
	LD	IX,ReCompBuff + NEW_ADDR*2	; Put name with invert
	LD	HL,(RStIlen+1)
	LD	DE,(RStIpos+1)
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	LD	A,#01
	RST	#00
	RET 
;[]===========================================================[]
LcMenuKe
	LD	IX,TxtWtab	; Descriptor current.window
	BIT	7,(IX+#00)
	RET	NZ
	LD	C,(IX+#05)	; X,ypos close button
	LD	B,(IX+#06)
	INC	B
	BIT	7,C
	JR	Z,OpenLoc
	LD	C,#00
	JR	OpenLoc
LcMenuMe
	LD	HL,what
	LD	(HL),evNothing
	LD	A,(CurMBox)
	OR	A
	RET	NZ
	LD	A,#03
	RST	#00	; Get mouse coords
	LD	C,L
	LD	B,H
OpenLoc	LD	HL,LocalWn
	PUSH	BC
	CALL	GetLenB	; Get len local menu
	POP	BC
	LD	HL,LocPos
	INC	C
	LD	A,C
	ADD	A,E
	CP	#52
	JR	C,$+6
	SUB	E
	SUB	E
	INC	A
	LD	C,A
	LD	(HL),C
	LD	A,B
	CP	#02
	JR	NC,$+5
	LD	A,#02
	LD	B,A
	ADD	A,D
	INC	A
	CP	#1F
	JR	C,$+7
	LD	A,#1F
	SUB	D
	DEC	A
	LD	B,A
	CALL	PutMenu
	CALL	ResMBar

LocalLp	CALL	handleEvent
	LD	HL,what
	LD	DE,LocalLp	; Menu bar exit
	PUSH	DE
	LD	A,(HL)		; Get event
	INC	HL
	CP	evMouseFr	;Fire mouse
	JP	Z,LMmouse
	CP	evKeyboard	;Press key
	JR	Z,LMkeys
	CP	evCombKey	;Press comb.key
	JR	Z,LMcbkey
	POP	DE
	JR	LocalLp

LMkeys	LD	A,(HL)
	CP	#1B		;Esc
	JP	Z,CloseLm
	CP	#0D		;Enter
	JR	NZ,LMkeysN
	LD	IX,BoxTabl-2	; Search element
	LD	DE,#0006
	LD	A,(CurMBox)
	LD	B,A
	ADD	IX,DE
	DJNZ	$-2
	JP	LmEnter

LMkeysN	LD	L,A
	LD	IX,BoxTabl-2
	LD	BC,#0006
	LD	H,B
	LD	A,L		; Search element menu
	RES	5,A
LMkeys1	INC	H
	ADD	IX,BC
	BIT	7,(IX+#00)
	RET	NZ
	CP	(IX+#04)
	JR	NZ,LMkeys1
	JP	LmHotEx

LMcbkey	LD	A,(HL)
	AND	#03		; Ctrl,shift press
	RET	NZ
	INC	HL
	LD	A,(HL)
	CP	72	; Curs up
	JR	Z,LMup
	CP	80	;Curs down
	JP	Z,LMdown
	CP	71
	JP	Z,LMhome
	CP	79
	JP	Z,LMend
	JP	StatusL

; Cursor up
LMup	LD	A,(CurMBox)
	DEC	A
	JR	NZ,LMupNxt
	LD	IX,BoxTabl-2
	LD	BC,#0006
	LD	A,B
	DEC	A
LMupLp	INC	A	; Search last element
	ADD	IX,BC
	BIT	7,(IX+#00)
	JR	Z,LMupLp
LMupNxt	LD	(CurMBox),A
	LD	B,A
	LD	IX,BoxTabl-2
	LD	DE,#0006
	ADD	IX,DE
	DJNZ	$-2
	PUSH	IX
	CALL	ResBoxI
	CALL	SetBoxI
	POP	IX
	LD	A,(IX+#05)
	CALL	PutStatusLn
	RET 
; Cursor down
LMdown	LD	A,(CurMBox)
	INC	A
	LD	IX,BoxTabl-2
	LD	BC,#0006
	LD	H,B	; Test by last element
LMdnLp	INC	H
	ADD	IX,BC
	BIT	7,(IX+#00)
	JR	Z,LMdnLp
	CP	H
	JR	NZ,$+4
	LD	A,#01
	JR	LMupNxt
; Home
LMhome	LD	A,(CurMBox)
	DEC	A
	RET	Z
	LD	A,#01
	JP	LMupNxt
; End
LMend	LD	A,(CurMBox)
	LD	H,A
	LD	IX,BoxTabl-2
	LD	BC,#0006
	LD	A,B
	DEC	A
LMendLp	INC	A	; Search last element
	ADD	IX,BC
	BIT	7,(IX+#00)
	JR	Z,LMendLp
	CP	H
	RET	Z
	JP	LMupNxt

; Menu bar mouse event
LMmouse	LD	E,(HL)		; Get mouse coords in de
	INC	HL
	LD	D,(HL)
	LD	A,D
	CP	#1F
	JP	Z,StatusL
	LD	IX,BoxTabl
	LD	A,E
	CP	(IX+#00)
	JP	C,CloseLm	; <xo
	CP	(IX+#01)
	JP	NC,CloseLm	; >xi
	LD	A,D
	CP	(IX+#02)
	JP	C,CloseLm	; <yo
	CP	(IX+#03)
	JP	NC,CloseLm	; >yi
	DEC	IX
	DEC	IX
	LD	BC,#0006
	LD	H,B
LMloopB	INC	H
	ADD	IX,BC
	BIT	7,(IX+#00)
	RET	NZ
	LD	A,D
	CP	(IX+#02)
	JR	NZ,LMloopB
	LD	A,E		; Search element box
	CP	(IX+#00)
	JR	C,LMloopB	; <xo
	CP	(IX+#01)
	JR	NC,LMloopB	; >xi
LmHotEx	LD	A,(CurMBox)
	CP	H
	JR	Z,LmEnter	; Box element is set
	LD	A,H
	LD	(CurMBox),A
	PUSH	IX
	CALL	ResBoxI
	CALL	SetBoxI
	POP	IX
	LD	A,(IX+#05)
	CALL	PutStatusLn
	LD	B,#04
	HALT 
	DJNZ	$-1
LmEnter	LD	A,(IX+#03)
	CALL	TstCmnd
	RET	Z		;Command is close
	LD	HL,what
	LD	(HL),evCommand
	INC	HL
	LD	A,(IX+#03)
	LD	(HL),A
	LD	A,#FF
	LD	(Cobject),A	;Returned to first object
CloseLm	POP	DE
	CALL	ClosBox
	LD	A,NoConTxt
	CALL	PutStatusLn
	LD	A,#04
	RST	#00
	CALL	SetCurs
	LD	HL,what
	LD	A,(HL)
	CP	evCommand
	RET	Z
	LD	(HL),evNothing
	RET 

LocPos	DEFB	0,0,0
	DEFW	LocalWn

LocalWn	DEFB	cmCut,"~C~ut              Ctrl+X",0,CTcut
	DEFB   cmCutAppnd,"C~u~t&Append    Shift+Del",0,CTcutapp
	DEFB	cmCopy,"C~o~py             Ctrl+C",0,CTcopy
	DEFB	cmAppend,"~A~ppend         Ctrl+Ins",0,CTappnd
	DEFB	cmPaste,"~P~aste            Ctrl+V",0,CTpaste
	DEFB	cmClear,"C~l~ear               Del",0,CTclear
	DEFB	#FF
;
 _mCollectInfo_addEnd
