 _mCollectInfo_addStart
;
; Object ~list box~
; Input: hl-label
; Format mouse table:
; +0 - object ~list box"
; +1 - xo position object
; +2 - xi position object
; +3 - yo position object
; +4 - yi position object
; +5 - xi position name
; +6 - current
; +7 - count-in in ListBox
; +8,9 - address list
; +0a - y pos line up
; +0b - y pos line down
; +0c - previos y pos bar
; +0d - hot key
; +0e - context
PListBox
	LD	(IY+#01),A
	LD	A,(HL)	;X pos
	INC	HL
	LD	C,A
	LD	(IX+#04),A	; Save x pos
	ADD	A,(IX+#00)	; Pos x from begin window
	LD	(IY+#02),A		; +1 xo
	LD	A,(HL)	;Y pos
	INC	HL
	LD	B,A
	LD	(IX+#05),A	; Save y pos
	ADD	A,(IX+#01)	; Pos y from begin window
	LD	(IY+#04),A		; +3 yo
	CALL	GetPutA
	LD	A,(HL)	; Len x
	INC	HL
	ADD	A,#03
	LD	(IX+#06),A
	LD	B,A
	ADD	A,#02
	ADD	A,(IY+#02)
	LD	(IY+#03),A	;Xi pos
	LD	A,(HL)	; Len y
	INC	HL
	ADD	A,#02		;Yi pos
	ADD	A,(IY+#04)
	LD	(IY+#05),A

 IF NEW_VERSION
	LD	A,0xDA
 ELSE	
	LD	A,"-"
 ENDIF

	LD	(DE),A
	INC	DE
	INC	DE
	LD	A,#20
	LD	(DE),A
	INC	DE
	INC	DE
	DEC	B
	LD	A,(ColDialWn)	;Put name element
	LD	C,A
	LD	A,(HL)
LstBox0	INC	HL
	CP	"~"
	JR	NZ,LstBox1
	LD	A,(ColDhotkey)
	LD	C,A
	LD	A,(HL)
	INC	HL
	INC	HL
	LD	(DE),A
	INC	DE
	RES	5,A
	LD	(IY+#0F),A	;Hot key
	LD	A,(DE)
	AND	#F0
	OR	C
	LD	(DE),A
	INC	DE
	LD	A,(ColDialWn)
	LD	C,A
	DEC	B
	LD	A,(HL)
	INC	HL
LstBox1	LD	(DE),A
	INC	DE
	INC	DE
	DEC	B
	LD	A,(HL)
	OR	A
	JR	NZ,LstBox0
	INC	HL
	LD	A,#20
	LD	(DE),A
	INC	DE
	INC	DE
	DEC	B
	LD	A,(IX+#06)
	SUB	B
	ADD	A,(IY+#02)
	LD	(IY+#06),A	; Xi pos name
	LD	A,B
	OR	A
	JR	Z,LstBox2
	
 IF NEW_VERSION
	LD	A,0xC4
 ELSE	
	LD	A,"-"
 ENDIF

	LD	(DE),A
	INC	DE
	INC	DE
	DJNZ	$-3
LstBox2	LD	A,0xBF
	LD	(DE),A
	INC	(IX+#05)
	LD	A,(HL)		;Context
	INC	HL
	LD	(IY+#10),A
	SUB	A
	LD	(IY+#07),A	; Current
	LD	(IY+#08),A	; First. on
	LD	(IY+#09),A	; Count-in
	LD	E,(HL)
	INC	HL
	LD	(IY+#0A),E	; List
	LD	(IY+#11),E	; List
	LD	D,(HL)
	INC	HL
	LD	(IY+#0B),D
	LD	(IY+#12),D
	PUSH	HL
	EX	DE,HL
	LD	A,(HL)
	OR	A
	JP	Z,EndBox

;Next element list
LstBox3	LD	C,(IX+#04)	; Pos element
	LD	B,(IX+#05)
	CALL	GetPutA
	LD	A,(IX+#06)
	SUB	#03
	LD	B,A
	EX	DE,HL
	LD	(HL),0xB3
	INC	HL
	INC	HL
	LD	A,(IY+#04)
	SUB	(IX+#01)
	INC	A
	CP	(IX+#05)
	LD	A,(ColListBox)
	JR	NZ,$+5
	LD	A,(ColLstBxHI)
	LD	C,A
	LD	(HL),#20
	INC	HL
	LD	(HL),C
	INC	HL
LstBox4	LD	A,(DE)
	INC	DE
	CP	#0D
	JR	Z,NxtLst
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	LstBox4
	LD	A,(DE)
	INC	DE
	CP	#0D
	JR	NZ,$-4
NxtLst	LD	A,B
	OR	A
	JR	Z,LstBox5
	LD	A,#20
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
LstBox5	LD	(HL),#20
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IY+#04)
	SUB	(IX+#01)
	INC	A
	CP	(IX+#05)
	LD	B,#1E
	JR	Z,PutLsBr
	INC	A
	CP	(IX+#05)
	LD	B,#FE
	JR	Z,PutLsBr
	LD	A,(IY+#05)
	SUB	(IX+#01)
	SUB	#02
	CP	(IX+#05)
	LD	B,#1F
	JR	Z,PutLsBr
	LD	B,#B1
PutLsBr	LD	(HL),B
	INC	HL
	LD	A,(ColScrlBar)
	LD	(HL),A
	INC	HL
	LD	(HL),0xB3
	EX	DE,HL
	INC	(IY+#09)
	INC	(IX+#05)
	LD	A,(IY+#05)
	SUB	(IX+#01)
	DEC	A
	CP	(IX+#05)
	JR	Z,EndBox1
	LD	A,(HL)
	OR	A
	JP	NZ,LstBox3
EndBox
	LD	A,(IY+#05)
	SUB	(IX+#01)
	SUB	(IX+#05)
	DEC	A
	JR	Z,EndBox1
	LD	B,A
LstBox6	PUSH	BC
	LD	C,(IX+#04)	; Pos element
	LD	B,(IX+#05)
	CALL	GetPutA
	LD	A,(IX+#06)
	DEC	A
	LD	B,A
	EX	DE,HL
	LD	(HL),0xB3
	INC	HL
	INC	HL
	LD	A,(ColListBox)
	LD	C,A
	LD	A,#20
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	LD	A,(IY+#04)
	SUB	(IX+#01)
	INC	A
	CP	(IX+#05)
	LD	B,#1E
	JR	Z,PutLsB1
	INC	A
	CP	(IX+#05)
	LD	B,#FE
	JR	Z,PutLsB1
	LD	A,(IY+#05)
	SUB	(IX+#01)
	SUB	#02
	CP	(IX+#05)
	LD	B,#1F
	JR	Z,PutLsB1
	LD	B,#B1
PutLsB1	LD	(HL),B
	INC	HL
	LD	A,(ColScrlBar)
	LD	(HL),A
	INC	HL
	LD	(HL),0xB3
	EX	DE,HL
	INC	(IX+#05)
	POP	BC
	DJNZ	LstBox6

EndBox1	LD	A,(HL)
	OR	A
	JR	Z,EndBox2
	CP	#0D
	INC	HL
	LD	A,(HL)
	JR	NZ,$-4
	INC	(IY+#09)
	JR	EndBox1+1

EndBox2	LD	C,(IX+#04)	;End string
	LD	B,(IX+#05)
	CALL	GetPutA
	EX	DE,HL

 IF NEW_VERSION
	LD	(HL),0xC0
 ELSE	
	LD	(HL),"L"
 ENDIF

	INC	HL
	INC	HL
	LD	B,(IX+#06)

 IF NEW_VERSION
	LD	A,0xC4
 ELSE	
	LD	A,"-"
 ENDIF

	LD	(HL),A
	INC	HL
	INC	HL
	DJNZ	$-3

 IF NEW_VERSION
	LD	(HL),0xD9
 ELSE	
	LD	(HL),"-"
 ENDIF

	LD	A,(IY+#04)
	INC	A
	LD	(IY+#0C),A	; Line up
	INC	A
	LD	(IY+#0E),A	; Prev pos
	LD	A,(IY+#05)
	SUB	#02
	LD	(IY+#0D),A	; Line down
	POP	HL
	LD	BC,#0013
	LD	(IY+#00),C
	ADD	IY,BC
	RET 

; Object ~pallete box~
; Input: hl-label
; Format mouse table:
; +0 - object ~pallete box"
; +1 - xo position object
; +2 - xi position object
; +3 - yo position object
; +4 - yi position object
; +5 - xi position name
; +6 - count-in by X
; +7 - count-in by Y
; +8 - current
; +9 - hot key
; +a - context
PPallete
	LD	(IY+#01),A
	LD	A,(HL)	;X pos
	INC	HL
	LD	C,A
	LD	(IX+#04),A	; Save x pos
	ADD	A,(IX+#00)	; Pos x from begin window
	LD	(IY+#02),A		; +1 xo
	LD	A,(HL)	;Y pos
	INC	HL
	LD	B,A
	LD	(IX+#05),A	; Save y pos
	ADD	A,(IX+#01)	; Pos y from begin window
	LD	(IY+#04),A		; +3 yo
	CALL	GetPutA
	LD	A,(HL)	; Len x
	INC	HL
	LD	(IY+#07),A	; Count-in. X
	LD	C,A
	ADD	A,A
	ADD	A,A
	ADD	A,C
	LD	(IX+#06),A
	LD	B,A
	ADD	A,#02
	ADD	A,(IY+#02)
	LD	(IY+#03),A	;Xi pos
	LD	A,(HL)	; Len y
	INC	HL
	LD	(IY+#08),A	; Count-in. Y
	ADD	A,A
	ADD	A,#02		;Yi pos
	ADD	A,(IY+#04)
	LD	(IY+#05),A

 IF NEW_VERSION
	LD	A,0xDA
 ELSE
	LD	A,"-"
 ENDIF

	LD	(DE),A
	INC	DE
	INC	DE
	LD	A,#20
	LD	(DE),A
	INC	DE
	INC	DE
	DEC	B
	LD	A,(ColDialWn)	;Put name element
	LD	C,A
	LD	A,(HL)
PltBox0	INC	HL
	CP	"~"
	JR	NZ,PltBox1
	LD	A,(ColDhotkey)
	LD	C,A
	LD	A,(HL)
	INC	HL
	INC	HL
	LD	(DE),A
	INC	DE
	RES	5,A
	LD	(IY+#0A),A	;Hot key
	LD	A,(DE)
	AND	#F0
	OR	C
	LD	(DE),A
	INC	DE
	LD	A,(ColDialWn)
	LD	C,A
	DEC	B
	LD	A,(HL)
	INC	HL
PltBox1	LD	(DE),A
	INC	DE
	INC	DE
	DEC	B
	LD	A,(HL)
	OR	A
	JR	NZ,PltBox0
	INC	HL
	LD	A,#20
	LD	(DE),A
	INC	DE
	INC	DE
	DEC	B
	LD	A,(IX+#06)
	SUB	B
	ADD	A,(IY+#02)
	LD	(IY+#06),A	; Xi pos name
	LD	A,B
	OR	A
	JR	Z,PltBox2

 IF NEW_VERSION
	LD	A,0xC4
 ELSE
	LD	A,"-"
 ENDIF	

	LD	(DE),A
	INC	DE
	INC	DE
	DJNZ	$-3
PltBox2	LD	A,0xBF
	LD	(DE),A
	INC	(IX+#05)
	LD	A,(HL)		;Context
	INC	HL
	LD	(IY+#0B),A
	LD	A,(HL)
	INC	HL
	LD	(IY+#09),A	; Internal operation
	LD	A,(HL)
	INC	HL
	LD	(IY+#0C),A	; Internal operation
	LD	A,(HL)
	INC	HL
	LD	(IY+#0D),A
	PUSH	HL
	LD	A,(ColDialWn)
	AND	#F0
	LD	(IX+#06),A	; Color
	LD	B,(IY+#08)
PltBox3	PUSH	BC
	LD	C,(IX+#04)	; Pos element
	LD	B,(IX+#05)
	CALL	GetPutA
	EX	DE,HL
	LD	(HL),0xB3
	INC	HL
	INC	HL
	LD	B,(IY+#07)
	LD	A,(IX+#06)

 IF NEW_VERSION
	LD	C,0xDB
 ELSE
	LD	C,"-"
 ENDIF

PltBox4:	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	INC	A
	DJNZ	PltBox4
	LD	(HL),0xB3
	EX	DE,HL
	INC	(IX+#05)
	LD	C,(IX+#04)	; Pos element
	LD	B,(IX+#05)
	CALL	GetPutA
	EX	DE,HL
	LD	(HL),0xB3
	INC	HL
	INC	HL
	LD	B,(IY+#07)
	LD	A,(IX+#06)

 IF NEW_VERSION
	LD	C,0xDB
 ELSE
	LD	C,"-"
 ENDIF

PltBox5:	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	INC	A
	DJNZ	PltBox5

 IF NEW_VERSION
	LD	(HL),0xB3
 ELSE
	LD	(HL),0xB3
 ENDIF

	EX	DE,HL
	INC	(IX+#05)
	LD	A,(IY+#07)
	ADD	A,(IX+#06)
	LD	(IX+#06),A
	POP	BC
	DJNZ	PltBox3
	LD	C,(IX+#04)	; Pos element
	LD	B,(IX+#05)
	CALL	GetPutA
	EX	DE,HL

 IF NEW_VERSION
	LD	(HL),0xC0
 ELSE
 	LD	(HL),"L"
 ENDIF

	INC	HL
	INC	HL
	LD	A,(IY+#03)
	SUB	(IY+#02)
	SUB	#02
	LD	B,A

 IF NEW_VERSION
	LD	A,0xC4
 ELSE
	LD	A,"-"
 ENDIF

	LD	(HL),A
	INC	HL
	INC	HL
	DJNZ	$-3

 IF NEW_VERSION
	LD	(HL),0xD9
 ELSE
	LD	(HL),"-"
 ENDIF

	LD	L,(IY+#0C)
	LD	H,(IY+#0D)
	INC	HL
	LD	A,(HL)
	AND	(IY+#09)
	JR	Z,PltBox6
	DEC	HL
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
	LD	A,"*"
	LD	(DE),A
	INC	DE
	LD	A,(ColDialWn)
	LD	(DE),A
PltBox6	POP	HL
	LD	BC,#000E
	LD	(IY+#00),C
	ADD	IY,BC
	RET 

; Object ~file box~
; Input: hl-label
; Format mouse table:
; +0 - object ~file box"
; +1 - xo position object
; +2 - xi position object
; +3 - yo position object
; +4 - yi position object
; +5 - xi position name
; +6,7 - current file
; +8,9 - first file on
; +A,B - count-in in FileBox
; +c - x pos scroll left
; +d - x pos scroll right
; +e - previos x pos bar
; +f - hot key
; +10 - context
; +11 - flag
PFileBox
	LD	(IY+#01),A
	LD	A,(HL)	;X pos
	INC	HL
	LD	C,A
	LD	(IX+#04),A	; Save x pos
	ADD	A,(IX+#00)	; Pos x from begin window
	LD	(IY+#02),A		; +1 xo
	LD	A,(HL)	;Y pos
	INC	HL
	LD	B,A
	LD	(IX+#05),A	; Save y pos
	ADD	A,(IX+#01)	; Pos y from begin window
	LD	(IY+#04),A		; +3 yo
	CALL	GetPutA
	LD	A,#1D
	LD	(IX+#06),A
	LD	B,A
	ADD	A,#02
	ADD	A,(IY+#02)
	LD	(IY+#03),A	;Xi pos
	LD	A,(HL)	; Len y
	INC	HL
	ADD	A,#03		;Yi pos
	ADD	A,(IY+#04)
	LD	(IY+#05),A

 IF NEW_VERSION
	LD	A,0xDA
 ELSE
	LD	A,"-"
 ENDIF

	LD	(DE),A
	INC	DE
	INC	DE
	LD	A,#20
	LD	(DE),A
	INC	DE
	INC	DE
	DEC	B
	LD	A,(ColDialWn)	;Put name element
	LD	C,A
	LD	A,(HL)
FilBox0	INC	HL
	CP	"~"
	JR	NZ,FilBox1
	LD	A,(ColDhotkey)
	LD	C,A
	LD	A,(HL)
	INC	HL
	INC	HL
	LD	(DE),A
	INC	DE
	RES	5,A
	LD	(IY+#10),A	;Hot key
	LD	A,(DE)
	AND	#F0
	OR	C
	LD	(DE),A
	INC	DE
	LD	A,(ColDialWn)
	LD	C,A
	DEC	B
	LD	A,(HL)
	INC	HL
FilBox1	LD	(DE),A
	INC	DE
	INC	DE
	DEC	B
	LD	A,(HL)
	OR	A
	JR	NZ,FilBox0
	INC	HL
	LD	A,#20
	LD	(DE),A
	INC	DE
	INC	DE
	DEC	B
	LD	A,(IX+#06)
	SUB	B
	ADD	A,(IY+#02)
	LD	(IY+#06),A	; Xi pos name
	LD	A,B
	OR	A
	JR	Z,FilBox2

 IF NEW_VERSION
	LD	A,0xC4
 ELSE
	LD	A,"-"
 ENDIF

	LD	(DE),A
	INC	DE
	INC	DE
	DJNZ	$-3
FilBox2	LD	A,0xBF
	LD	(DE),A
	INC	(IX+#05)
	LD	A,(HL)		;Context
	INC	HL
	LD	(IY+#11),A
	SUB	A
	LD	(IY+#07),A	; Current
	LD	(IY+#08),A	;
	LD	(IY+#09),A	; First. on
	LD	(IY+#0A),A	;
	LD	(IY+#0B),A	; Count-in
	LD	(IY+#0C),A	;
	LD	(IY+#12),A	; Flag

FilBox3:	LD	C,(IX+#04)	; Pos element
	LD	B,(IX+#05)
	CALL	GetPutA
	EX	DE,HL

 IF NEW_VERSION
	LD	(HL),0xB3
 ELSE
	LD	(HL),0xB3
 ENDIF

	INC	HL
	INC	HL
	LD	A,(ColFileBox)
	LD	C,A
	LD	A,#20
	LD	B,(IX+#06)
	SRL	B
	PUSH	BC
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	LD	(HL),0xB3
	INC	HL
	LD	(HL),C
	INC	HL
	POP	BC
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	LD	(HL),0xB3
	EX	DE,HL
	INC	(IX+#05)
	LD	A,(IY+#05)
	SUB	(IX+#01)
	SUB	#02
	CP	(IX+#05)
	JR	NZ,FilBox3

	LD	C,(IX+#04)	; Filboxbar
	LD	B,(IX+#05)
	CALL	GetPutA
	EX	DE,HL

 IF NEW_VERSION
	LD	(HL),0xB3
 ELSE
	LD	(HL),0xB3
 ENDIF

	INC	HL
	INC	HL
	LD	A,(ColScrlBar)
	LD	C,A
	LD	(HL),#11
	INC	HL
	LD	(HL),C
	INC	HL
	LD	B,(IX+#06)
	DEC	B
	DEC	B
	LD	A,#B1
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	LD	(HL),#10
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),0xB3
	INC	(IX+#05)
	EX	DE,HL

	LD	C,(IX+#04)	;End string
	LD	B,(IX+#05)
	CALL	GetPutA
	EX	DE,HL

 IF NEW_VERSION
	LD	(HL),0xC0
 ELSE
	LD	(HL),"L"
 ENDIF

	INC	HL
	INC	HL
	LD	B,(IX+#06)

 IF NEW_VERSION
	LD	A,0xC4
 ELSE
	LD	A,"-"
 ENDIF

	LD	(HL),A
	INC	HL
	INC	HL
	DJNZ	$-3

 IF NEW_VERSION
	LD	(HL),0xD9
 ELSE
	LD	(HL),"-"
 ENDIF

	LD	A,(IY+#02)
	INC	A
	LD	(IY+#0D),A	; Line up
	ADD	A,#02
	LD	(IY+#0F),A	; Prev pos
	LD	A,(IY+#03)
	SUB	#02
	LD	(IY+#0E),A	; Line down
	EX	DE,HL
	LD	BC,#0013
	LD	(IY+#00),C
	ADD	IY,BC
	RET 

; Put object "file input line"
; Input: hl-label
; Format mouse table:
; +0 - object ~file input line~
; +1 - xo position object
; +2 - xi position object
; +3 - y position object
; +4 - xi position text
; +5 - xo position file input line
; +6 - hot keys
; +7 - context
; +8,9 - address input buffer
PFileInp
	LD	(IY+#01),A		;+0 object
	LD	A,(HL)	;X pos
	INC	HL
	LD	C,A
	ADD	A,(IX+#00)	; Pos x from begin screen
	LD	(IY+#02),A		; +1 xo
	LD	(IX+#04),A		; Temp x coord
	LD	A,(HL)	;Y pos
	INC	HL
	LD	B,A
	ADD	A,(IX+#01)	; Pos y from begin screen
	LD	(IY+#04),A		; +3 yo
	CALL	GetPutA
	EX	DE,HL
	LD	A,(ColDialWn)
	LD	C,A
	LD	A,(DE)
PFilLp1	INC	DE
	CP	"~"
	JR	NZ,PFilN0
	LD	A,(ColDhotkey)
	LD	C,A
	LD	A,(DE)
	INC	DE
	LD	(HL),A
	INC	HL
	RES	5,A
	LD	(IY+#07),A	;Hot key
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
PFilN0	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	INC	(IX+#04)
	LD	A,(DE)
	OR	A
	JR	NZ,PFilLp1
	EX	DE,HL
	INC	HL
	LD	A,(IX+#04)
	LD	(IY+#05),A	;Xi position text
	LD	A,(IX+#04)
	LD	(IY+#06),A	;Xo position input line
	LD	(Fnext+1),DE
	LD	B,(HL)		; Len input line
	INC	HL
	LD	A,(HL)		; Context
	INC	HL
	LD	(IY+#08),A
	LD	E,(HL)		; De-address input buffer
	LD	(IY+#09),E
	INC	HL
	LD	D,(HL)
	LD	(IY+#0A),D
	INC	HL
	INC	DE
	SUB	A
	INC	A
	LD	(DE),A		;Ready
	INC	DE
	DEC	A
	LD	(DE),A		; Pos x
	INC	DE
	LD	(DE),A		; Add x
	PUSH	HL
Fnext	LD	HL,#0000
	LD	A,(ColFileInp)
	LD	C,A
	LD	A,#20
PFilLp2	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	INC	(IX+#04)
	DJNZ	PFilLp2
	POP	HL
	LD	E,(IY+#06)
	LD	D,(IY+#04)
	LD	(CursPos),DE
	LD	A,(IX+#04)
	LD	(IY+#03),A	;Xi position object
	LD	BC,#000B
	LD	(IY+#00),C
	ADD	IY,BC		; Iy-next element
	RET 

; Object ~file info~
; Input: hl-label
; Format mouse table:
; +0 - object ~file info"
; +1 - xo position object
; +2 - xi position object
; +3 - yo position object
PFileInfo
	LD	(IY+#01),A
	LD	A,(HL)	;X pos
	INC	HL
	LD	C,A
	LD	(IX+#04),A		; Temp x coord
	ADD	A,(IX+#00)	; Pos x from begin window
	LD	(IY+#02),A
	LD	A,(HL)	;Y pos
	INC	HL
	LD	B,A
	LD	(IX+#05),A		; Temp y coord
	ADD	A,(IX+#01)	; Pos y from begin window
	LD	(IY+#04),A
	CALL	GetPutA
	LD	A,(HL)	; Len x
	INC	HL
	LD	B,A
	ADD	A,(IY+#02)
	LD	(IY+#03),A	;Xi pos
	EX	DE,HL
	LD	A,(ColFileInf)
	LD	C,A
	PUSH	BC
	LD	A,#20
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	EX	DE,HL
	INC	(IX+#05)
	LD	C,(IX+#04)
	LD	B,(IX+#05)
	CALL	GetPutA
	EX	DE,HL
	POP	BC
	LD	A,#20
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	EX	DE,HL
	LD	BC,#0005
	LD	(IY+#00),C
	ADD	IY,BC
	RET 

; Object ~button~
; Input: hl-label
; Format mouse table:
; +0 - object ~claster check buttons"
; +1 - xo position object
; +2 - xi position object
; +3 - y position object
; +4 - genered command
; +5 - hot key
; +6 - context
PButton
	PUSH	IY
	INC	IY
	LD	(IY+#00),A		;+0 object
	LD	A,(HL)	;X pos
	INC	HL
	LD	C,A
	ADD	A,(IX+#00)	; Pos x from begin screen
	LD	(IY+#01),A		; +1 xo
	LD	A,(HL)	;Y pos
	INC	HL
	LD	B,A
	ADD	A,(IX+#01)	; Pos y from begin screen
	LD	(IY+#03),A		; +3 yo
	PUSH	BC		;Save position
	CALL	GetPutA
	EX	DE,HL
	LD	A,(ColButton)
	LD	C,A
	LD	B,#00
	LD	(IY+#05),B
	LD	A,(DE)
PButLp1	INC	DE
	CP	"~"
	JR	NZ,PButN0
	LD	A,(ColDhotkey)
	LD	C,A
	LD	A,(DE)
	INC	DE
	LD	(HL),A
	INC	HL
	RES	5,A
	LD	(IY+#05),A	;Hot key
	LD	A,(ColButton)
	AND	#F0
	OR	C
	LD	(HL),A
	INC	HL
	INC	DE
	LD	A,(ColButton)
	LD	C,A
	INC	B
	LD	A,(DE)
	INC	DE
PButN0	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	INC	B
	LD	A,(DE)
	OR	A
	JR	NZ,PButLp1
	INC	DE
	LD	A,(IY+#01)
	ADD	A,B
	LD	(IY+#02),A
	LD	(HL),#DC
	EX	DE,HL
	POP	BC	;Reset position
	INC	B
	CALL	GetPutA
	INC	DE
	INC	DE
	LD	A,(IY+#02)
	SUB	(IY+#01)
	LD	B,A
	LD	A,#DF
	LD	(DE),A
	INC	DE
	INC	DE
	DJNZ	$-3
	LD	A,(HL)
	INC	HL
	LD	(IY+#04),A
	LD	A,(HL)
	INC	HL
	LD	(IY+#06),A	;Context
	LD	BC,#0007
	ADD	IY,BC
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

; Object ~text line~
; Input: hl-label
; Format mouse table:
; None
PTextLn
	LD	C,(HL)	;X pos
	INC	HL
	LD	B,(HL)	;Y pos
	INC	HL
	CALL	GetPutA
PTxtLp1	LDI 
	INC	DE
	LD	A,(HL)
	OR	A
	JR	NZ,PTxtLp1
	INC	HL
	RET 

; Object ~process line~
; Input: hl-label
; Format mouse table:
; +0 - object ~process line~
; +1 - xo position object
; +2 - xi position object
; +3 - y position object
; +4 -. printing
; +5,6 - count-in on 1 process
; +7,8 -,where current
; +9,and - process
PProcess
	LD	(IY+#01),A		;+0 object
	LD	A,(HL)	;X pos
	INC	HL
	LD	C,A
	ADD	A,(IX+#00)	; Pos x from begin screen
	LD	(IY+#02),A		; +1 xo
	LD	A,(HL)	;Y pos
	INC	HL
	LD	B,A
	ADD	A,(IX+#01)	; Pos y from begin screen
	LD	(IY+#04),A		; +3 yo
	LD	A,(HL)
	INC	HL
	ADD	A,(IY+#02)
	LD	(IY+#03),A
	LD	(IY+#05),#00	; Output
	LD	E,(HL)		; Where
	INC	HL
	LD	D,(HL)
	INC	HL
	PUSH	IX
	PUSH	HL
	PUSH	BC
	EX	DE,HL
	LD	E,(HL)		; HL+IX - max
	INC	HL
	LD	D,(HL)
	INC	HL
	PUSH	DE
	POP	IX
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	LD	A,(IY+#03)
	SUB	(IY+#02)
	LD	C,A		; Count-in process
	LD	B,#00
	CALL	Divis32
	LD	A,LX
	LD	(IY+#06),A
	LD	A,HX		; Internal operation
	LD	(IY+#07),A
	POP	BC
	POP	HL
	POP	IX
	LD	A,(HL)
	INC	HL
	LD	(IY+#08),A
	LD	A,(HL)
	INC	HL
	LD	(IY+#09),A
	LD	A,(HL)
	INC	HL
	LD	(IY+#0A),A
	LD	A,(HL)
	INC	HL
	LD	(IY+#0B),A
	CALL	GetPutA
	EX	DE,HL
	LD	A,(ColProcess)
	LD	C,A
	LD	A,(IY+#03)
	SUB	(IY+#02)
	LD	B,A
PProc1	LD	(HL),#B1
	INC	HL
	LD	A,(HL)
	AND	#F0
	OR	C
	LD	(HL),A
	INC	HL
	DJNZ	PProc1
	EX	DE,HL
	LD	DE,#000C
	LD	(IY+#00),E
	ADD	IY,DE
	RET 
; Object ~pallette resident 1 or 2~
; Format mouse table:
; +0 - object ~pallette resident~
PResid1
	LD	(IY+#00),#02
	INC	IY
	LD	(IY+#00),A		;+0 object
	INC	IY
	RET 
; Object ~pallette resident 1 or 2~
; Format mouse table:
; +0 - object ~pallette resident~
PResid2
	EX	AF,AF'
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	A,(DialogPg2)
	OUT	(SLOT3),A
	LD	(AdrCol+1),DE
	LD	A,(BuffPg5)	;Page buffer
	OUT	(SLOT3),A
	EX	AF,AF'
	JR	PResid1
; Object ~test color~
; Format mouse table:
PTestCol
	LD	(IY+#01),A		;+0 object
	LD	(IY+#04),#00
	LD	A,(HL)	;X pos
	INC	HL
	LD	C,A
	ADD	A,(IX+#00)	; Pos x from begin screen
	LD	(IY+#02),A		; +1 xo
	LD	A,(HL)	;Y pos
	INC	HL
	LD	B,A
	ADD	A,(IX+#01)	; Pos y from begin screen
	LD	(IY+#03),A		; +3 yo
	LD	(PTestC2+1),BC
	CALL	GetPutA
	PUSH	DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	A,(DE)
	INC	DE
	LD	C,A
	LD	A,(DE)
	CPL 
	LD	B,A
	POP	DE
	PUSH	HL
	LD	A,(HL)
PTestC1	INC	HL
	LD	(DE),A
	INC	DE
	LD	A,(DE)
	AND	B
	OR	C
	LD	(DE),A
	INC	DE
	INC	(IY+#04)
	LD	A,(HL)
	OR	A
	JR	NZ,PTestC1
	POP	HL
	PUSH	BC
PTestC2	LD	BC,#0000
	INC	B
	CALL	GetPutA
	POP	BC
	LD	A,(HL)
PTestC3	INC	HL
	LD	(DE),A
	INC	DE
	LD	A,(DE)
	AND	B
	OR	C
	LD	(DE),A
	INC	DE
	LD	A,(HL)
	OR	A
	JR	NZ,PTestC3
	INC	HL
	LD	BC,#0005
	LD	(IY+#00),C
	ADD	IY,BC
	RET 
;
 _mCollectInfo_addEnd