 _mCollectInfo_addStart
; ASM in line
	PUSH	DE
	RES	0,(IY-#04)
	LD	A,(CSLabel)
	LD	E,A
	LD	A,(CSMnemon)
	LD	D,A
	LD	A,(ColTxtWin)
	LD	C,A
	LD	A,(CSComment)
	LD	(HL),#20
	INC	L
	LD	(HL),C
	BIT	6,(IX+#01)
	JR	Z,ReCmpl0
	SET	0,(IY-#04)
	LD	A,(ColSelTxt)
	LD	C,A
	LD	E,A
	LD	D,A
	LD	(HL),A
ReCmpl0	INC	L
	LD	(TmpColC),A
	LD	A,C
	LD	(TmpColW),A
	LD	A,D
	LD	(TmpColM),A
	LD	A,E
	LD	(TmpColL),A
	POP	DE
	LD	A,(IX+#00)
	CP	#03
	JP	Z,FillEnd1
	DEC	L
	DEC	L
	DEC	A
	DEC	A
	LD	B,A
	BIT	7,(IX+#01)
	JP	NZ,ReCompErr
	BIT	0,(IX+#01)
	JR	Z,ReCompNxt
	LD	A,(TmpColL)
	LD	C,A
ReCompLp1
	DEC	B
	JP	Z,FillEnd
	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,ReSpaceM
	CP	";"
	JP	Z,ReCommMn
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	JR	ReCompLp1

ReSpaceM:	PUSH	BC
	LD	B,A
	LD	A,(TmpColW)
	LD	C,A
	LD	A,#20

	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	POP	BC
ReCompNxt:
	DEC	B
	JP	Z,FillEnd
	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,ReSpaceM
	CP	";"
	JP	Z,ReCommMn
	LD	HX,A
	LD	A,(DE)
	LD	LX,A

 IFN NEW_VERSION
	LD	A,(AsmTabPg)
	OUT	(SLOT2),A
 ENDIF
	INC	E
	DEC	B
	DEC	B
	EXX 
	LD	A,(IX+#12)
	LD	(regA+1),A
	AND	#0F
	ADD	A,A
	LD	C,A
	LD	B,#00
	LD	HL,TreProg
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	EXX 
	LD	A,(TmpColM)
	LD	C,A
ReCompLp2
	LD	A,(IX+#00)
	INC	IX
	CP	#20
	JR	Z,regA
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	JR	ReCompLp2

regA	LD	A,#00
	AND	#F0
	JR	Z,Jumping
	CALL	SpaceArg
	INC	E
	DEC	B
ReCompLp3
	LD	A,(IX+#00)
	INC	IX
	CP	#20
	JR	Z,Jumping
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	JR	ReCompLp3

Jumping:	EXX 
	JP	(HL)

TreProg:	DEFW	ProgR00
	DEFW	ProgR01
	DEFW	ProgR02
	DEFW	ProgR03
	DEFW	ProgR04
	DEFW	ProgR05
	DEFW	ProgR06
	DEFW	ProgR07
	DEFW	ProgR08
	DEFW	ProgR09
	DEFW	ProgR10
	DEFW	ProgR11
	DEFW	ProgR12
	DEFW	ProgR13
	DEFW	ProgR0E
	DEFW	ProgR0F

; Type: no argument
ProgR00	EXX 
	INC	B
	DEC	B
	JP	Z,FillEnd
	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,ReCompEx
	JP	ReCommMn

; Type: only argument
ProgR01	EXX 
	CALL	SpaceArg
	LD	A,(TmpColL)
	LD	C,A
PrgR01l	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,ReCompEx
	CP	";"
	JP	Z,ReCommMn
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR01l
	JP	FillEnd

; Type: (xx+....)
ProgR02	EXX 
	CALL	SpaceArg
	LD	A,(TmpColM)
	LD	C,A
	LD	(HL),"("
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#01)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#02)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(DE)
	INC	E
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DEC	B
	JR	Z,Pr02Ex
	LD	A,(TmpColL)
	LD	C,A
PrgR02l	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,Pr02Ex
	CP	";"
	JR	Z,Pr02Ex
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR02l
Pr02Ex	EX	AF,AF'
	LD	(HL),")"
	INC	HL
	LD	A,(TmpColM)
	LD	(HL),A
	INC	HL
	EX	AF,AF'
	CP	#20
	JP	C,ReCompEx
	CP	";"
	JP	Z,ReCommMn
	JP	FillEnd

; Type x,...
ProgR03	EXX 
	CALL	SpaceArg
	LD	A,(TmpColM)
	LD	C,A
	LD	A,(IX+#00)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),","
	INC	HL
	LD	(HL),C
	INC	HL

	LD	A,(TmpColL)
	LD	C,A
PrgR03l	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,ReCompEx
	CP	";"
	JP	Z,ReCommMn
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR03l
	JP	FillEnd

; Type x,(....)
ProgR04	EXX 
	CALL	SpaceArg
	LD	A,(TmpColM)
	LD	C,A
	LD	A,(IX+#00)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),","
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),"("
	INC	HL
	LD	(HL),C
	INC	HL

	LD	A,(TmpColL)
	LD	C,A
PrgR04l	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,Pr04Ex
	CP	";"
	JR	Z,Pr04Ex
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR04l
Pr04Ex	EX	AF,AF'
	LD	(HL),")"
	INC	HL
	LD	A,(TmpColM)
	LD	(HL),A
	INC	HL
	EX	AF,AF'
	CP	#20
	JP	C,ReCompEx
	CP	";"
	JP	Z,ReCommMn
	JP	FillEnd

; Type x,(xx+....)
ProgR05	EXX 
	CALL	SpaceArg
	LD	A,(TmpColM)
	LD	C,A
	LD	A,(IX+#00)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),","
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),"("
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#03)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#04)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(DE)
	INC	E
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DEC	B
	JR	Z,Pr05Ex

	LD	A,(TmpColL)
	LD	C,A
PrgR05l	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,Pr05Ex
	CP	";"
	JR	Z,Pr05Ex
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR05l
Pr05Ex	EX	AF,AF'
	LD	(HL),")"
	INC	HL
	LD	A,(TmpColM)
	LD	(HL),A
	INC	HL
	EX	AF,AF'
	CP	#20
	JP	C,ReCompEx
	CP	";"
	JP	Z,ReCommMn
	JP	FillEnd

; Type xx,....
ProgR06	EXX 
	CALL	SpaceArg
	LD	A,(TmpColM)
	LD	C,A
	LD	A,(IX+#00)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#01)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),","
	INC	HL
	LD	(HL),C
	INC	HL

	LD	A,(TmpColL)
	LD	C,A
PrgR06l	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,ReCompEx
	CP	";"
	JP	Z,ReCommMn
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR06l
	JP	FillEnd

; Type xx,(....)
ProgR07	EXX 
	CALL	SpaceArg
	LD	A,(TmpColM)
	LD	C,A
	LD	A,(IX+#00)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#01)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),","
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),"("
	INC	HL
	LD	(HL),C
	INC	HL

	LD	A,(TmpColL)
	LD	C,A
PrgR07l	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,Pr07Ex
	CP	";"
	JR	Z,Pr07Ex
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR07l
Pr07Ex	EX	AF,AF'
	LD	(HL),")"
	INC	HL
	LD	A,(TmpColM)
	LD	(HL),A
	INC	HL
	EX	AF,AF'
	CP	#20
	JP	C,ReCompEx
	CP	";"
	JP	Z,ReCommMn
	JP	FillEnd

; Type (hl),....
ProgR08	EXX 
	CALL	SpaceArg
	LD	A,(TmpColM)
	LD	C,A
	LD	(HL),"("
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),"H"
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),"L"
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),")"
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),","
	INC	HL
	LD	(HL),C
	INC	HL

	LD	A,(TmpColL)
	LD	C,A
PrgR08l	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,ReCompEx
	CP	";"
	JP	Z,ReCommMn
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR08l
	JP	FillEnd

; Type (xx+....),....
ProgR09	EXX 
	CALL	SpaceArg
	LD	A,(TmpColM)
	LD	C,A
	LD	(HL),"("
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#01)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#02)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(DE)
	INC	E
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DEC	B

	LD	A,(TmpColL)
	LD	C,A
PrgR09l	LD	A,(DE)
	INC	E
	OR	A
	JR	Z,Pr09Ex
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR09l
Pr09Ex	LD	(HL),")"
	INC	HL
	LD	A,(TmpColM)
	LD	(HL),A
	INC	HL
	LD	(HL),","
	INC	HL
	LD	(HL),A
	INC	HL
	DEC	B
	JP	Z,FillEnd
PrgR09n	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,ReCompEx
	CP	";"
	JP	Z,ReCommMn
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR09n
	JP	FillEnd

; Type (xx+....),x
ProgR10	EXX 
	CALL	SpaceArg
	LD	A,(TmpColM)
	LD	C,A
	LD	(HL),"("
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#01)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#02)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(DE)
	INC	E
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DEC	B
	JR	Z,Pr0AEx
	LD	A,(TmpColL)
	LD	C,A
PrgR0Al	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,Pr0AEx
	CP	";"
	JR	Z,Pr0AEx
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR0Al
Pr0AEx	EX	AF,AF'
	LD	A,(TmpColM)
	LD	C,A
	LD	(HL),")"
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),","
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#07)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	EX	AF,AF'
	CP	#20
	JP	C,ReCompEx
	CP	";"
	JP	Z,ReCommMn
	JP	FillEnd

; Type (....),xx
ProgR11	EXX 
	CALL	SpaceArg
	LD	A,(TmpColM)
	LD	C,A
	LD	(HL),"("
	INC	HL
	LD	(HL),C
	INC	HL

	LD	A,(TmpColL)
	LD	C,A
PrgR0Bl	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,Pr0BEx
	CP	";"
	JR	Z,Pr0BEx
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR0Bl
Pr0BEx	EX	AF,AF'
	LD	A,(TmpColM)
	LD	C,A
	LD	(HL),")"
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),","
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#04)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#05)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	EX	AF,AF'
	CP	#20
	JP	C,ReCompEx
	CP	";"
	JP	Z,ReCommMn
	JP	FillEnd

; Type (....),x
ProgR12	EXX 
	CALL	SpaceArg
	LD	A,(TmpColM)
	LD	C,A
	LD	(HL),"("
	INC	HL
	LD	(HL),C
	INC	HL

	LD	A,(TmpColL)
	LD	C,A
PrgR0Cl	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,Pr0CEx
	CP	";"
	JR	Z,Pr0CEx
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR0Cl
Pr0CEx	EX	AF,AF'
	LD	A,(TmpColM)
	LD	C,A
	LD	(HL),")"
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),","
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#04)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	EX	AF,AF'
	CP	#20
	JP	C,ReCompEx
	CP	";"
	JP	Z,ReCommMn
	JP	FillEnd

; Type: defb,defw,incbin,include
ProgR13	EXX 
	CALL	SpaceArg
	LD	C,#00
PrgR13l	LD	A,(TmpColL)
	EX	AF,AF'
	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,ReCompEx
	BIT	0,C
	JR	NZ,$+7
	CP	";"
	JP	Z,ReCommMn
	LD	(HL),A
	INC	HL
	CP	","
	JR	Z,PrgR131
	CP	#22
	JR	NZ,PrgR131+4
	LD	A,C
	XOR	#01
	LD	C,A
PrgR131	LD	A,(TmpColM)
	EX	AF,AF'
	EX	AF,AF'
	LD	(HL),A
	INC	HL
	DJNZ	PrgR13l
	JP	FillEnd

; Type ....,(xx+....)
ProgR0E	EXX 
	CALL	SpaceArg

	LD	A,(TmpColL)	 ; First arg
	LD	C,A
PrgR1El	LD	A,(DE)
	CP	#20
	JR	C,Pr1EEx
	INC	E
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR1El

Pr1EEx	LD	A,(TmpColM)
	LD	C,A
	LD	(HL),","
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#02)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#03)
	CP	#20
	JR	Z,Pr2EEx
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#04)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#05)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL

Pr2EEx	INC	B
	DEC	B
	JP	Z,FillEnd
PrgR3En	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,ReCompEx
	CP	";"
	JP	Z,ReCommMn
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR3En
	JP	FillEnd

; Type ....,(xx+....)
ProgR0F	EXX 
	CALL	SpaceArg

	LD	A,(TmpColL)	 ; First arg
	LD	C,A
PrgR1Fl	LD	A,(DE)
	INC	E
	OR	A
	JR	Z,Pr1FEx
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR1Fl

Pr1FEx	LD	A,(TmpColM)
	LD	C,A
	LD	(HL),","
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),"("
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#03)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#04)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(DE)
	INC	E
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DEC	B
	DEC	B

	LD	A,(TmpColL)
	LD	C,A
PrgR2Fl	LD	A,(DE)
	CP	#20
	JR	C,Pr2FEx
	INC	E
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR2Fl

Pr2FEx	LD	A,(TmpColM)
	LD	(HL),")"
	INC	HL
	LD	(HL),A
	INC	HL

	INC	B
	DEC	B
	JP	Z,FillEnd
	LD	A,(TmpColW)
	LD	C,A
PrgR3Fn	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,ReCompEx
	CP	";"
	JP	Z,ReCommMn
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	PrgR3Fn
	JP	FillEnd

ReCompEx
	CALL	ReCompSp1
	DEC	B
	JP	Z,FillEnd
	LD	A,(DE)
	INC	E
	CP	";"
	JR	Z,ReCommMn
	JR	ReCompEx

SpaceArg
	LD	A,(DE)
	OR	A
	RET	Z
	CP	#20
	RET	NC
	DEC	B
	CALL	ReCompSp1
	INC	E
	JR	SpaceArg

ReCompSp1
	PUSH	BC
	LD	B,A
	LD	A,(TmpColW)
	LD	C,A
	LD	A,#20

	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	POP	BC
	RET 


ReCommMn
	LD	(HL),A
	INC	HL
	LD	A,(TmpColC)
	LD	C,A
	LD	(HL),A
	INC	HL
ReCommMnLp
	DEC	B
	JR	Z,FillEnd
	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,ReCommSp
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	JR	ReCommMnLp

ReCommSp
	PUSH	BC
	LD	B,A
	LD	A,#20

	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	POP	BC
	JR	ReCommMnLp


ReCompErr
	LD	A,(TmpColL)
	LD	C,A
ReCompEr001
	LD	A,(DE)
	CP	#20
	JR	C,ReCompErNxt
	INC	E
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DEC	B
	JR	ReCompEr001

ReCompErNxt
	LD	A,(TmpColW)
	LD	C,A
ReCompErrLp
	DEC	B
	JR	Z,FillEnd
	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,ReSpace
	CP	";"
	JR	Z,ReCommErr
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	JR	ReCompErrLp

ReSpace:	PUSH	BC
	LD	B,A
	LD	A,#20

	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	POP	BC
	JR	ReCompErrLp

ReCommErr:
	LD	(HL),A
	INC	HL
	LD	A,(TmpColC)
	LD	C,A
	LD	(HL),A
	INC	HL
	JR	ReCompErrLp

FillEnd1:	POP	AF

 IF NEW_VERSION
	OUT	(SLOT3),A
 ELSE
	OUT	(SLOT2),A
 ENDIF

	LD	(IY+#02),#00
	JR	FEnd1
FillEnd:	POP	AF

 IF NEW_VERSION
	OUT	(SLOT3),A
 ELSE
	OUT	(SLOT2),A
 ENDIF

	PUSH	HL
SaveBuf:	LD	DE,#0000
	OR	A
	SBC	HL,DE
	SRL	H
	RR	L
	LD	(IY+#02),L
	POP	HL
FEnd1	LD	(HL),#00
	LD	A,(IY+#05)	; Max len x
	ADD	A,(IY+#07)
	SUB	(IY+#02)
	JR	C,FEnd2
	JR	Z,FEnd2
	LD	B,A
	LD	A,(ColTxtWin)
	LD	C,A
	SUB	A
	PUSH	HL
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	POP	HL
FEnd2:	LD	A,(EditMode)
	OR	A
	RET	Z
	LD	A,(IY+#00)
	CP	#FF
	RET	Z
	ADD	A,(IY+#07)
	SUB	(IY+#02)
	RET	C
	RET	Z
	LD	B,A
	LD	C,#20
	LD	A,(ColTxtWin)
	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-4
	LD	A,(IY+#00)
	ADD	A,(IY+#07)
	LD	(IY+#02),A
	RET 
 _mCollectInfo_addEnd