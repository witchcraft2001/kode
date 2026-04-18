 _mCollectInfo_addStart
;
ConvDeComp:
	LD	IX,CompBuff
	LD	HL,ReCompBuff
	LD	DE,CompBuff+2
	LD	A,(IX+#00)
	CP	#03
	JP	Z,DeCompExt
	SUB	#02
	LD	B,A
	BIT	7,(IX+#01)
	JP	NZ,DeCompErr
	BIT	0,(IX+#01)
	JR	Z,DeCompNxt
DeCompLp1
	DEC	B
	JP	Z,DeCompExt
	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,DeSpaceM
	CP	";"
	JP	Z,DeCommMn
	LD	(HL),A
	INC	L
	JR	DeCompLp1
DeSpaceM
	PUSH	BC
	LD	B,A
	LD	A,#20
	LD	(HL),A
	INC	L
	DJNZ	$-2
	POP	BC
DeCompNxt
	DEC	B
	JP	Z,DeCompExt
	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,DeSpaceM
	CP	";"
	JP	Z,DeCommMn
	
	IFN NEW_VERSION : SET 6,A : ENDIF

	LD	HX,A
	LD	A,(DE)
	LD	LX,A
	INC	E
	DEC	B
	DEC	B
	EXX 
	LD	A,(IX+#12)
	LD	(rega+1),A
	AND	#0F
	ADD	A,A
	LD	C,A
	LD	B,#00
	LD	HL,Tdeprog
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	EXX 
DeCompLp2
	LD	A,(IX+#00)
	INC	IX
	CP	#20
	JR	Z,rega
	LD	(HL),A
	INC	L
	JR	DeCompLp2

rega	LD	A,#00
	AND	#F0
	JR	Z,jumping
	CALL	spacearg
	INC	E
	DEC	B
DeCompLp3
	LD	A,(IX+#00)
	INC	IX
	CP	#20
	JR	Z,jumping
	LD	(HL),A
	INC	L
	JR	DeCompLp3

jumping	EXX 
	JP	(HL)

Tdeprog	DEFW	progD00
	DEFW	progD01
	DEFW	progD02
	DEFW	progD03
	DEFW	progD04
	DEFW	progD05
	DEFW	progD06
	DEFW	progD07
	DEFW	progD08
	DEFW	progD09
	DEFW	progD10
	DEFW	progD11
	DEFW	progD12
	DEFW	progD13
	DEFW	progD0E
	DEFW	progD0F

; Type: no argument
progD00	EXX 
	INC	B
	DEC	B
	JP	Z,DeCompExt
	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,DeCompEx
	JP	DeCommMn
; Type: only argument
progD01	EXX 
	CALL	spacearg
prgR01l	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,DeCompEx
	CP	";"
	JP	Z,DeCommMn
	LD	(HL),A
	INC	L
	DJNZ	prgR01l
	JP	DeCompExt
; Type: (xx+....)
progD02	EXX 
	CALL	spacearg
	LD	(HL),"("
	INC	L
	LD	A,(IX+#01)
	LD	(HL),A
	INC	L
	LD	A,(IX+#02)
	LD	(HL),A
	INC	L
	LD	A,(DE)
	INC	E
	LD	(HL),A
	INC	L
	DEC	B
	JR	Z,pr02Ex
prgR02l	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,pr02Ex
	CP	";"
	JR	Z,pr02Ex
	LD	(HL),A
	INC	L
	DJNZ	prgR02l
pr02Ex	LD	(HL),")"
	INC	L
	CP	#20
	JP	C,DeCompEx
	CP	";"
	JP	Z,DeCommMn
	JP	DeCompExt
; Type x,...
progD03	EXX 
	CALL	spacearg
	LD	A,(IX+#00)
	LD	(HL),A
	INC	L
	LD	(HL),","
	INC	L
prgR03l	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,DeCompEx
	CP	";"
	JP	Z,DeCommMn
	LD	(HL),A
	INC	L
	DJNZ	prgR03l
	JP	DeCompExt
; Type x,(....)
progD04	EXX 
	CALL	spacearg
	LD	A,(IX+#00)
	LD	(HL),A
	INC	L
	LD	(HL),","
	INC	L
	LD	(HL),"("
	INC	L
prgR04l	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,pr04Ex
	CP	";"
	JR	Z,pr04Ex
	LD	(HL),A
	INC	L
	DJNZ	prgR04l
pr04Ex	LD	(HL),")"
	INC	L
	CP	#20
	JP	C,DeCompEx
	CP	";"
	JP	Z,DeCommMn
	JP	DeCompExt
; Type x,(xx+....)
progD05	EXX 
	CALL	spacearg
	LD	A,(IX+#00)
	LD	(HL),A
	INC	L
	LD	(HL),","
	INC	L
	LD	(HL),"("
	INC	L
	LD	A,(IX+#03)
	LD	(HL),A
	INC	L
	LD	A,(IX+#04)
	LD	(HL),A
	INC	L
	LD	A,(DE)
	INC	E
	LD	(HL),A
	INC	L
	DEC	B
	JR	Z,pr05Ex
prgR05l	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,pr05Ex
	CP	";"
	JR	Z,pr05Ex
	LD	(HL),A
	INC	L
	DJNZ	prgR05l
pr05Ex	LD	(HL),")"
	INC	L
	CP	#20
	JP	C,DeCompEx
	CP	";"
	JP	Z,DeCommMn
	JP	DeCompExt
; Type xx,....
progD06	EXX 
	CALL	spacearg
	LD	A,(IX+#00)
	LD	(HL),A
	INC	L
	LD	A,(IX+#01)
	LD	(HL),A
	INC	L
	LD	(HL),","
	INC	L
prgR06l	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,DeCompEx
	CP	";"
	JP	Z,DeCommMn
	LD	(HL),A
	INC	L
	DJNZ	prgR06l
	JP	DeCompExt

; Type xx,(....)
progD07	EXX 
	CALL	spacearg
	LD	A,(IX+#00)
	LD	(HL),A
	INC	L
	LD	A,(IX+#01)
	LD	(HL),A
	INC	L
	LD	(HL),","
	INC	L
	LD	(HL),"("
	INC	L
prgR07l	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,pr07Ex
	CP	";"
	JR	Z,pr07Ex
	LD	(HL),A
	INC	L
	DJNZ	prgR07l
pr07Ex	LD	(HL),")"
	INC	L
	CP	#20
	JP	C,DeCompEx
	CP	";"
	JP	Z,DeCommMn
	JP	DeCompExt
; Type (hl),....
progD08	EXX 
	CALL	spacearg
	LD	(HL),"("
	INC	L
	LD	(HL),"H"
	INC	L
	LD	(HL),"L"
	INC	L
	LD	(HL),")"
	INC	L
	LD	(HL),","
	INC	L
prgR08l	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,DeCompEx
	CP	";"
	JP	Z,DeCommMn
	LD	(HL),A
	INC	L
	DJNZ	prgR08l
	JP	DeCompExt
; Type (xx+....),....
progD09	EXX 
	CALL	spacearg
	LD	(HL),"("
	INC	L
	LD	A,(IX+#01)
	LD	(HL),A
	INC	L
	LD	A,(IX+#02)
	LD	(HL),A
	INC	L
	LD	A,(DE)
	INC	E
	LD	(HL),A
	INC	L
	DEC	B
prgR09l	LD	A,(DE)
	INC	E
	OR	A
	JR	Z,pr09Ex
	LD	(HL),A
	INC	L
	DJNZ	prgR09l
pr09Ex	LD	(HL),")"
	INC	L
	LD	(HL),","
	INC	L
	DEC	B
	JP	Z,DeCompExt
prgR09n	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,DeCompEx
	CP	";"
	JP	Z,DeCommMn
	LD	(HL),A
	INC	L
	DJNZ	prgR09n
	JP	DeCompExt
; Type (xx+....),x
progD10	EXX 
	CALL	spacearg
	LD	(HL),"("
	INC	L
	LD	A,(IX+#01)
	LD	(HL),A
	INC	L
	LD	A,(IX+#02)
	LD	(HL),A
	INC	L
	LD	A,(DE)
	INC	E
	LD	(HL),A
	INC	L
	DEC	B
	JR	Z,pr0AEx
prgR0Al	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,pr0AEx
	CP	";"
	JR	Z,pr0AEx
	LD	(HL),A
	INC	L
	DJNZ	prgR0Al
pr0AEx	EX	AF,AF'
	LD	(HL),")"
	INC	L
	LD	(HL),","
	INC	L
	LD	A,(IX+#07)
	LD	(HL),A
	INC	L
	EX	AF,AF'
	CP	#20
	JP	C,DeCompEx
	CP	";"
	JP	Z,DeCommMn
	JP	DeCompExt
; Type (....),xx
progD11	EXX 
	CALL	spacearg
	LD	(HL),"("
	INC	L
prgR0Bl	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,pr0BEx
	CP	";"
	JR	Z,pr0BEx
	LD	(HL),A
	INC	L
	DJNZ	prgR0Bl
pr0BEx	EX	AF,AF'
	LD	(HL),")"
	INC	L
	LD	(HL),","
	INC	L
	LD	A,(IX+#04)
	LD	(HL),A
	INC	L
	LD	A,(IX+#05)
	LD	(HL),A
	INC	L
	EX	AF,AF'
	CP	#20
	JP	C,DeCompEx
	CP	";"
	JP	Z,DeCommMn
	JP	DeCompExt
; Type (....),x
progD12	EXX 
	CALL	spacearg
	LD	(HL),"("
	INC	L
prgR0Cl	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,pr0CEx
	CP	";"
	JR	Z,pr0CEx
	LD	(HL),A
	INC	L
	DJNZ	prgR0Cl
pr0CEx	EX	AF,AF'
	LD	(HL),")"
	INC	L
	LD	(HL),","
	INC	L
	LD	A,(IX+#04)
	LD	(HL),A
	INC	L
	EX	AF,AF'
	CP	#20
	JP	C,DeCompEx
	CP	";"
	JP	Z,DeCommMn
	JP	DeCompExt
; Type: defb,defw,incbin,include
progD13	EXX 
	CALL	spacearg
prgR13l	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,DeCompEx
	CP	";"
	JP	Z,DeCommMn
	LD	(HL),A
	INC	L
	DJNZ	prgR13l
	JP	DeCompExt
; Type ....,(xx+....)
progD0E	EXX 
	CALL	spacearg
prgR1El	LD	A,(DE)
	CP	#20
	JR	C,pr1EEx
	INC	E
	LD	(HL),A
	INC	L
	DJNZ	prgR1El
pr1EEx	LD	(HL),","
	INC	L
	LD	A,(IX+#02)
	LD	(HL),A
	INC	L
	LD	A,(IX+#03)
	CP	#20
	JR	Z,pr2EEx
	LD	(HL),A
	INC	L
	LD	A,(IX+#04)
	LD	(HL),A
	INC	L
	LD	A,(IX+#05)
	LD	(HL),A
	INC	L
pr2EEx	INC	B
	DEC	B
	JP	Z,DeCompExt
prgR3En	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,DeCompEx
	CP	";"
	JP	Z,DeCommMn
	LD	(HL),A
	INC	L
	DJNZ	prgR3En
	JP	DeCompExt
; Type ....,(xx+....)
progD0F	EXX 
	CALL	spacearg
prgR1Fl	LD	A,(DE)
	INC	E
	OR	A
	JR	Z,pr1FEx
	LD	(HL),A
	INC	L
	DJNZ	prgR1Fl
pr1FEx	LD	(HL),","
	INC	L
	LD	(HL),"("
	INC	L
	LD	A,(IX+#03)
	LD	(HL),A
	INC	L
	LD	A,(IX+#04)
	LD	(HL),A
	INC	L
	LD	A,(DE)
	INC	E
	LD	(HL),A
	INC	L
	DEC	B
	DEC	B
prgR2Fl	LD	A,(DE)
	CP	#20
	JR	C,pr2FEx
	INC	E
	LD	(HL),A
	INC	L
	DJNZ	prgR2Fl
pr2FEx	LD	(HL),")"
	INC	L
	INC	B
	DEC	B
	JP	Z,DeCompExt
prgR3Fn	LD	A,(DE)
	INC	E
	CP	#20
	JP	C,DeCompEx
	CP	";"
	JP	Z,DeCommMn
	LD	(HL),A
	INC	L
	DJNZ	prgR3Fn
	JP	DeCompExt

DeCompEx
	CALL	DeCompSp1
	DEC	B
	JP	Z,DeCompExt
	LD	A,(DE)
	INC	E
	CP	";"
	JR	Z,DeCommMn
	JR	DeCompEx
spacearg
	LD	A,(DE)
	OR	A
	RET	Z
	CP	#20
	RET	NC
	DEC	B
	CALL	DeCompSp1
	INC	E
	JR	spacearg
DeCompSp1
	PUSH	BC
	LD	B,A
	LD	A,#20
	LD	(HL),A
	INC	L
	DJNZ	$-2
	POP	BC
	RET 
DeCommMn
	LD	(HL),A
	INC	L
DeCommMnLp
	DEC	B
	JR	Z,DeCompExt
	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,DeCommSp
	LD	(HL),A
	INC	L
	JR	DeCommMnLp
DeCommSp
	PUSH	BC
	LD	B,A
	LD	A,#20
	LD	(HL),A
	INC	L
	DJNZ	$-2
	POP	BC
	JR	DeCommMnLp
;
;
DeCompErr
	LD	A,(DE)
	CP	#20
	JR	C,DeCompErNxt
	INC	E
	LD	(HL),A
	INC	L
	DEC	B
	JR	DeCompErr
DeCompErNxt
	DEC	B
	JR	Z,DeCompExt
	LD	A,(DE)
	INC	E
	CP	#20
	JR	C,DeSpace
	CP	";"
	JR	Z,DeCommErr
	LD	(HL),A
	INC	L
	JR	DeCompErNxt
DeSpace
	PUSH	BC
	LD	B,A
	LD	A,#20
	LD	(HL),A
	INC	L
	DJNZ	$-2
	POP	BC
	JR	DeCompErNxt
DeCommErr
	LD	(HL),A
	INC	L
	JR	DeCompErNxt

DeCompExt
	LD	(HL),#00
	RET 

TABcorrect
	LD	HL,CompBuff
	LD	DE,ReCompBuff
	JR	TABnocorr
	LD	C,#20
TABcorL	LD	A,(DE)
	OR	A
	JR	Z,TABcorE
	CP	C
	JR	Z,TABfill
TABcorN	LD	(HL),A
	INC	L
	INC	E
	JR	TABcorL
TABcorE	LD	(HL),#0D
	INC	L
	LD	(HL),#0A
	INC	L
	LD	C,L
	LD	B,#00
	RET 

TABfill	LD	B,#00
	INC	E
	INC	B
	LD	A,(DE)
	CP	C
	JR	Z,TABfill+2
	LD	A,B
	CP	#01
	JR	Z,TABspac
	LD	A,E
	AND	#07
	LD	LX,A
	LD	A,B
	SUB	LX
	JR	Z,TABspac
	JR	C,TABspac
TABput	LD	(HL),#09
	INC	L
	SUB	#08
	JR	Z,TABext
	JR	NC,TABput
TABext	LD	A,LX
	OR	A
	JR	Z,TABcorL
	LD	B,A
TABspac	LD	(HL),C
	INC	L
	DJNZ	$-2
	JR	TABcorL
TABnocorr
TABnocL	LD	A,(DE)
	OR	A
	JR	Z,TABcorE
	LD	(HL),A
	INC	L
	INC	E
	JR	TABnocL
;
 _mCollectInfo_addEnd
