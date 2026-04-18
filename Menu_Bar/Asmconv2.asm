 _mCollectInfo_addStart
; Original address 9055
ConvSyntax:
	LD	HL,ReCompBuff
	LD	A,(IY+#00)
	OR	A
	RET	Z
	LD	B,A
	LD	C,#00
	LD	(IY+#01),C
	LD	(IY+#02),C
	LD	(IY+#03),C
	LD	(IY+#04),C
	LD	DE,#FF20
	SET	0,(IY+#01)
; Examination label (len)
SynCon1	LD	A,(HL)
	CP	D
	JP	Z,SynCom1
	CP	E
	JR	Z,SynNxt1
	INC	L
	INC	C
	DJNZ	SynCon1
	LD	(IY+#02),C	; Len label
	RET 
SynNxt1	LD	(IY+#02),C	; Len label
	LD	A,C
	OR	A
	JR	NZ,$+6
	RES	0,(IY+#01)
SynCon2	LD	A,(HL)
	CP	D
	RET	Z
	CP	E
	JR	NZ,SynNxt2
	INC	L
	DJNZ	SynCon2
	RET 
SynNxt2	LD	(BegComm),HL
	LD	C,#00
SynCon3	LD	A,(HL)
	CP	D
	JP	Z,SynCom2
	CP	E
	JR	Z,SynNxt3
	INC	L
	INC	C
	DJNZ	SynCon3
SynNxt3	LD	(IY+#03),C	; Len operator
	CALL	SetSynComm
	LD	A,B
	OR	A
	RET	Z
SynCon4	LD	A,(HL)
	CP	D
	JP	Z,SynCom3
	CP	E
	JR	NZ,SynNxt4
	INC	L
	DJNZ	SynCon4
	RET 
SynNxt4	LD	(BegArgm),HL
	LD	C,#00
SynCon5	LD	A,(HL)
	CP	#22
	JR	NZ,ScNxt04
	LD	A,(IY+#01)
	XOR	#80
	LD	(IY+#01),A
	JR	ScNxt14
ScNxt04	BIT	7,(IY+#01)
	JR	NZ,ScNxt14
	CP	D
	JP	Z,SynCom4
	CP	E
	JR	Z,SynNxt5
ScNxt14	INC	L
	INC	C
	DJNZ	SynCon5
SynNxt5	LD	(IY+#04),C	; Len argument
	CALL	SetSynArgm
	LD	A,B
	OR	A
	RET	Z
SynCon6	LD	A,(HL)
	CP	D
	JP	Z,SynCom5
	CP	E
	JR	NZ,SynNxt6
	INC	L
	DJNZ	SynCon6
	RET 
SynNxt6	SET	6,(IY+#01)
	RET 

; Search operand & set(res) color
SetSynComm:						; !FIXIT and in must
	EXX 
	LD	HL,(BegComm)
	LD	C,(IY+#03)	; Len command
	LD	DE,CommOk
	PUSH	DE
	LD	A,(HL)
	CP	"A"
	JP	Z,Cmnd_Ac
	CP	"B"
	JP	Z,Cmnd_Bc
	CP	"C"
	JP	Z,Cmnd_Cc
	CP	"D"
	JP	Z,Cmnd_Dc
	CP	"E"
	JP	Z,Cmnd_Ec
	CP	"F"
	JP	Z,Cmnd_Fc
	CP	"H"
	JP	Z,Cmnd_Hc
	CP	"I"
	JP	Z,Cmnd_Ic
	CP	"J"
	JP	Z,Cmnd_Jc
	CP	"L"
	JP	Z,Cmnd_Lc
	CP	"N"
	JP	Z,Cmnd_Nc
	CP	"O"
	JP	Z,Cmnd_Oc
	CP	"P"
	JP	Z,Cmnd_Pc
	CP	"R"
	JP	Z,Cmnd_Rc
	CP	"S"
	JP	Z,Cmnd_Sc
	CP	"U"
	JR	Z,Cmnd_Uc
	CP	"V"
	JR	Z,Cmnd_Vc
	CP	"X"
	JR	Z,Cmnd_Xc
	POP	DE
	SET	6,(IY+#01)
	EXX 
	RET 
; Set color operand
CommOk	LD	(BegTabl),IX
	LD	L,(IX+#09)
	LD	H,(IX+#0A)

	IFN NEW_VERSION : SET 6,H : ENDIF
	
	LD	(BegAtbl),HL
	SET	1,(IY+#01)
	BIT	7,(IX+#06)
	JR	NZ,.Cok
	LD	A,(IX+#08)
	OR	A
	JR	Z,.Cok
	SET	4,(IY+#01)
.Cok	EXX 
	RET 

; Searching command
Cmnd_Xc	LD	IX,CMD_TBL.CHR.X
	LD	A,(IX+#00)
	CP	C
	JR	NZ,cmndno1
	CALL	searchC
	RET	Z
	JR	cmndno1

Cmnd_Vc	LD	IX,CMD_TBL.CHR.V
	LD	DE,#000B
	LD	A,(IX+#00)
	CP	C
	CALL	Z,searchC
	RET	Z
	ADD	IX,DE
	LD	A,(IX+#00)
	CP	C
	JR	NZ,cmndno1
	CALL	searchC
	RET	Z
	JR	cmndno1

Cmnd_Uc	LD	IX,CMD_TBL.CHR.U
	LD	A,(IX+#00)
	CP	C
	JR	NZ,cmndno1
	CALL	searchC
	RET	Z
	JR	cmndno1

Cmnd_Sc	LD	IX,CMD_TBL.CHR.S
	LD	DE,#000B
	LD	B,#08
cmndSlp	LD	A,(IX+#00)
	CP	C
	CALL	Z,searchC
	RET	Z
	ADD	IX,DE
	DJNZ	cmndSlp
cmndno1	SET	6,(IY+#01)
	EXX 
	RET 

Cmnd_Rc	LD	IX,CMD_TBL.CHR.R
	LD	DE,#000B
	LD	B,#0F
cmndRlp	LD	A,(IX+#00)
	CP	C
	CALL	Z,searchC
	RET	Z
	ADD	IX,DE
	DJNZ	cmndRlp
	SET	6,(IY+#01)
	EXX 
	RET 

Cmnd_Pc	LD	IX,CMD_TBL.CHR.P
	LD	DE,#000B
	LD	B,#03
cmndPlp	LD	A,(IX+#00)
	CP	C
	CALL	Z,searchC
	RET	Z
	ADD	IX,DE
	DJNZ	cmndPlp
	SET	6,(IY+#01)
	EXX 
	RET 

Cmnd_Oc	LD	IX,CMD_TBL.CHR.O
	LD	DE,#000B
	LD	B,#07
cmndOlp	LD	A,(IX+#00)
	CP	C
	CALL	Z,searchC
	RET	Z
	ADD	IX,DE
	DJNZ	cmndOlp
	SET	6,(IY+#01)
	EXX 
	RET 

Cmnd_Nc	LD	IX,CMD_TBL.CHR.N
	LD	DE,#000B
	LD	A,(IX+#00)
	CP	C
	CALL	Z,searchC
	RET	Z
	ADD	IX,DE
	LD	A,(IX+#00)
	CP	C
	JR	NZ,cmndno2
	CALL	searchC
	RET	Z
	JR	cmndno2

Cmnd_Lc	LD	IX,CMD_TBL.CHR.L
	LD	DE,#000B
	LD	B,#05
cmndLlp	LD	A,(IX+#00)
	CP	C
	CALL	Z,searchC
	RET	Z
	ADD	IX,DE
	DJNZ	cmndLlp
cmndno2	SET	6,(IY+#01)
	EXX 
	RET 

Cmnd_Jc	LD	IX,CMD_TBL.CHR.J
	LD	DE,#000B
	LD	A,(IX+#00)
	CP	C
	CALL	Z,searchC
	RET	Z
	ADD	IX,DE
	LD	A,(IX+#00)
	CP	C
	JR	NZ,cmndno2
	CALL	searchC
	RET	Z
	JR	cmndno2

Cmnd_Ic	LD	IX,CMD_TBL.CHR.I
	LD	DE,#000B
	LD	B,#0A
cmndIlp	LD	A,(IX+#00)
	CP	C
	CALL	Z,searchC
	RET	Z
	ADD	IX,DE
	DJNZ	cmndIlp
	SET	6,(IY+#01)
	EXX 
	RET 

Cmnd_Hc	LD	IX,CMD_TBL.CHR.H
	LD	A,(IX+#00)
	CP	C
	JR	NZ,cmndno3
	CALL	searchC
	RET	Z
	JR	cmndno3

Cmnd_Fc	LD	IX,CMD_TBL.CHR.F
	LD	A,(IX+#00)
	CP	C
	JR	NZ,cmndno3
	CALL	searchC
	RET	Z
	JR	cmndno3

Cmnd_Ec	LD	IX,CMD_TBL.CHR.E
	LD	DE,#000B
	LD	B,#05
cmndElp	LD	A,(IX+#00)
	CP	C
	CALL	Z,searchC
	RET	Z
	ADD	IX,DE
	DJNZ	cmndElp
cmndno3	SET	6,(IY+#01)
	EXX 
	RET 

Cmnd_Dc	LD	IX,CMD_TBL.CHR.D
	LD	DE,#000B
	LD	B,#0D
cmndDlp	LD	A,(IX+#00)
	CP	C
	CALL	Z,searchC
	RET	Z
	ADD	IX,DE
	DJNZ	cmndDlp
	SET	6,(IY+#01)
	EXX 
	RET 

Cmnd_Cc	LD	IX,CMD_TBL.CHR.C
	LD	DE,#000B
	LD	B,#0A
cmndClp	LD	A,(IX+#00)
	CP	C
	CALL	Z,searchC
	RET	Z
	ADD	IX,DE
	DJNZ	cmndClp
	SET	6,(IY+#01)
	EXX 
	RET 

Cmnd_Bc	LD	IX,CMD_TBL.CHR.B
	LD	A,(IX+#00)
	CP	C
	JR	NZ,cmndno4
	CALL	searchC
	RET	Z
	JR	cmndno4

Cmnd_Ac	LD	IX,CMD_TBL.CHR.A
	LD	DE,#000B
	LD	B,#04
cmndAlp	LD	A,(IX+#00)
	CP	C
	CALL	Z,searchC
	RET	Z
	ADD	IX,DE
	DJNZ	cmndAlp
cmndno4	SET	6,(IY+#01)
	EXX 
	RET 

searchC	PUSH	IX
	PUSH	BC
	LD	B,A
	DEC	B
	LD	C,L
srchlp1	INC	L
	LD	A,(HL)
	CP	(IX+#02)
	JR	NZ,nopcmnd
	INC	IX
	DJNZ	srchlp1
nopcmnd	LD	L,C
	POP	BC
	POP	IX
	RET 

; Search & set(res) argument color
SetSynArgm
	BIT	6,(IY+#01)
	RET	NZ
	EXX 
	LD	DE,ArgumOk
	PUSH	DE
	LD	IX,(BegTabl)
	BIT	7,(IX+#08)
	JR	Z,setarg0

	LD	DE,(BegArgm)
	LD	L,(IX+#09)
	LD	H,(IX+#0A)

	IFN NEW_VERSION : SET 6,H : ENDIF
	
	LD	C,(IX+#00)
	LD	B,(IX+#08)
	RES	7,B
	LD	A,(DE)
upgrlp	CP	(HL)
	JR	Z,foundup
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	DJNZ	upgrlp
	JR	ArgumNo

foundup	INC	HL
	LD	B,(HL)
	INC	HL
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	LD	E,C
	JR	setarg1

setarg0	LD	L,(IX+#09)	; Address command table
	LD	H,(IX+#0A)
	LD	E,(IX+#00)	; Len operand
	LD	B,(IX+#08)	; Equipmend command
setarg1	LD	D,#00

	IFN NEW_VERSION : SET 6,H : ENDIF

	PUSH	HL
	POP	IX
	INC	E
	ADD	HL,DE
	LD	A,(IY+#04)	; Len argument
	LD	(cycle1+1),A
	RLCA 
	RLCA 
	RLCA 
	RLCA 
	LD	C,A
	LD	DE,#0013
	LD	A,B
	OR	A
	JR	Z,ArgumNo
arglp01	LD	A,(IX+#12)
	OR	A
	JR	Z,resA
	AND	#F0
	JR	Z,ArgProgS
	CP	C
	CALL	NC,SrchArgS
	RET	Z
resA	ADD	HL,DE
	ADD	IX,DE
	DJNZ	arglp01
ArgumNo	POP	DE
	EXX 
	SET	6,(IY+#01)
	RET 
SrchArgS
	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	LD	DE,(BegArgm)
cycle1	LD	B,#00
	LD	A,(DE)
	CP	(HL)
	JR	NZ,argmno
	INC	HL
	INC	E
	DJNZ	cycle1+2
	POP	AF
	SET	4,(IY+#01)
	JR	NZ,$+6
	RES	4,(IY+#01)
	POP	BC
	POP	DE
	POP	HL
	SUB	A
	RET 

argmno	POP	AF
	POP	BC
	POP	DE
	POP	HL
	SUB	A
	INC	A
	RET 

; Arguments with parameters
ArgProgS
	POP	DE
	RES	4,(IY+#01)
	LD	DE,#0013
argloop	LD	A,(IX+#12)
	AND	#0F
	DEC	A
	JR	Z,arglext
	DEC	A
	JR	Z,Sprgr02
	DEC	A
	JP	Z,Sprgr03
	DEC	A
	JP	Z,Sprgr04
	DEC	A
	JP	Z,Sprgr05
	DEC	A
	JP	Z,Sprgr06
	DEC	A
	JP	Z,Sprgr07
	DEC	A
	JP	Z,Sprgr08
	DEC	A
	JP	Z,Sprgr09
	DEC	A
	JP	Z,Sprgr0A
	DEC	A
	JP	Z,Sprgr0B
	DEC	A
	JP	Z,Sprgr0C
	DEC	A
	JP	Z,Sprgr0D
	DEC	A
	JP	Z,Sprgr0E
	JP	Sprgr0F

arglpnx	JR	Z,arglext
	ADD	HL,DE
	ADD	IX,DE
	DJNZ	argloop
	EXX 
	SET	6,(IY+#01)
	RET 

arglext	EXX 
	SET	2,(IY+#01)
	LD	(BegAtbl),IX
	RET 
; Argument type: (rr+argum)
Sprgr02	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(cycle1+1)
	LD	B,A
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,prg02No
	DEC	B
	JR	Z,prg02Ys
	INC	L
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg02No
	DEC	B
	JR	Z,prg02Ys
	INC	L
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg02No
	DEC	B
	JR	Z,prg02Ys
	INC	L
	INC	DE
	LD	A,(HL)		;+ or -
	CP	"-"
	JR	Z,$+6
	CP	"+"
	JR	NZ,prg02No
	DEC	B
	JR	Z,prg02Ys
	INC	L
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,prg02Ys
	LD	A,(DE)		; Search )
	CP	(HL)
	JR	Z,prLp12
	INC	L
	DJNZ	$-4
	JR	prg02Ys

prLp12	DEC	B
	JR	Z,prg02Ys+4
	JR	prg02No

prg02Ys	SET	4,(IY+#01)
	SUB	A
prg02No	POP	BC
	POP	DE
	POP	HL
	JP	arglpnx

; Argument type: r,argum
Sprgr03	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(cycle1+1)
	LD	B,A
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg03No
	DEC	B
	JR	Z,prg03Ys
	INC	L
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,prg03No
	DEC	B
	JR	Z,prg03Ys
	JR	$+6

prg03Ys	SET	4,(IY+#01)
	SUB	A
prg03No	POP	BC
	POP	DE
	POP	HL
	JP	arglpnx

; Argument type: r,(argum)
Sprgr04	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(cycle1+1)
	LD	B,A
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg04No
	DEC	B
	JR	Z,prg04Ys
	INC	L
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,prg04No
	DEC	B
	JR	Z,prg04Ys
	INC	L
	INC	DE
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,prg04No
	DEC	B
	JR	Z,prg04Ys
	INC	L
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,prg04Ys
	LD	A,(DE)		; Search )
	CP	(HL)
	JR	Z,prLp42
	INC	L
	DJNZ	$-4
	JR	prg04Ys

prLp42	DEC	B
	JR	Z,prg04Ys+4
	JR	prg04No

prg04Ys	SET	4,(IY+#01)
	SUB	A
prg04No	POP	BC
	POP	DE
	POP	HL
	JP	arglpnx

; Argument type: r,(rr+argum)
Sprgr05	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(cycle1+1)
	LD	B,A
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg05No
	DEC	B
	JR	Z,prg05Ys
	INC	L
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,prg05No
	DEC	B
	JR	Z,prg05Ys
	INC	L
	INC	DE
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,prg05No
	DEC	B
	JR	Z,prg05Ys
	INC	L
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg05No
	DEC	B
	JR	Z,prg05Ys
	INC	L
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg05No
	DEC	B
	JR	Z,prg05Ys
	INC	L
	INC	DE
	LD	A,(HL)		;+ or -
	CP	"-"
	JR	Z,$+6
	CP	"+"
	JR	NZ,prg05No
	DEC	B
	JR	Z,prg05Ys
	INC	L
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,prg05Ys
	LD	A,(DE)		; Search )
	CP	(HL)
	JR	Z,prLp52
	INC	L
	DJNZ	$-4
	JR	prg05Ys

prLp52	DEC	B
	JR	Z,prg05Ys+4
	JR	prg05No

prg05Ys	SET	4,(IY+#01)
	SUB	A
prg05No	POP	BC
	POP	DE
	POP	HL
	JP	arglpnx

; Argument type: rr,argum
Sprgr06	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(cycle1+1)
	LD	B,A
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg06No
	DEC	B
	JR	Z,prg06Ys
	INC	L
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg06No
	DEC	B
	JR	Z,prg06Ys
	INC	L
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,prg06No
	DEC	B
	JR	Z,prg06Ys
	JR	$+6

prg06Ys	SET	4,(IY+#01)
	SUB	A
prg06No	POP	BC
	POP	DE
	POP	HL
	JP	arglpnx

; Argument type: rr,(argum)
Sprgr07	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(cycle1+1)
	LD	B,A
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg07No
	DEC	B
	JR	Z,prg07Ys
	INC	L
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg07No
	DEC	B
	JR	Z,prg07Ys
	INC	L
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,prg07No
	DEC	B
	JR	Z,prg07Ys
	INC	L
	INC	DE
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,prg07No
	DEC	B
	JR	Z,prg07Ys
	INC	L
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,prg07Ys
	LD	A,(DE)		; Search )
	CP	(HL)
	JR	Z,prLp72
	INC	L
	DJNZ	$-4
	JR	prg07Ys

prLp72	DEC	B
	JR	Z,prg07Ys+4
	JR	prg07No

prg07Ys	SET	4,(IY+#01)
	SUB	A
prg07No	POP	BC
	POP	DE
	POP	HL
	JP	arglpnx

; Argument type: (hl),argum
Sprgr08	PUSH	HL
	PUSH	BC
	LD	HL,(BegArgm)
	LD	A,(cycle1+1)
	LD	B,A
	LD	A,"("		;(
	CP	(HL)
	JR	NZ,prg08No
	DEC	B
	JR	Z,prg08Ys
	INC	L
	LD	A,(HL)		;H
	CP	"H"
	JR	NZ,prg08No
	DEC	B
	JR	Z,prg08Ys
	INC	L
	LD	A,(HL)		;L
	CP	"L"
	JR	NZ,prg08No
	DEC	B
	JR	Z,prg08Ys
	INC	L
	LD	A,")"		;)
	CP	(HL)
	JR	NZ,prg08No
	DEC	B
	JR	Z,prg08Ys
	INC	L
	LD	A,","		;,
	CP	(HL)
	JR	NZ,prg08No
	DEC	B
	JR	Z,prg08Ys
	JR	$+6

prg08Ys	SET	4,(IY+#01)
	SUB	A
prg08No	POP	BC
	POP	HL
	JP	arglpnx

; Argument type: (rr+argum),argum
Sprgr09	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(cycle1+1)
	LD	B,A
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,prg09No
	DEC	B
	JR	Z,prg09Ys
	INC	L
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg09No
	DEC	B
	JR	Z,prg09Ys
	INC	L
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg09No
	DEC	B
	JR	Z,prg09Ys
	INC	L
	INC	DE
	LD	A,(HL)		;+ or -
	CP	"-"
	JR	Z,$+6
	CP	"+"
	JR	NZ,prg09No
	DEC	B
	JR	Z,prg09Ys
	INC	L
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,prg09Ys
	LD	A,(DE)		; Search )
	CP	(HL)
	JR	Z,prLp92
	INC	L
	DJNZ	$-4
	JR	prg09Ys

prLp92	DEC	B
	JR	Z,prg09Ys
	INC	L
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,prg09No
	DEC	B
	JR	Z,prg09Ys
	JR	$+6

prg09Ys	SET	4,(IY+#01)
	SUB	A
prg09No	POP	BC
	POP	DE
	POP	HL
	JP	arglpnx

; Argument type: (rr+argum),r
Sprgr0A	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(cycle1+1)
	LD	B,A
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,prg0ANo
	DEC	B
	JR	Z,prg0AYs
	INC	L
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg0ANo
	DEC	B
	JR	Z,prg0AYs
	INC	L
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg0ANo
	DEC	B
	JR	Z,prg0AYs
	INC	L
	INC	DE
	LD	A,(HL)		;+ or -
	CP	"-"
	JR	Z,$+6
	CP	"+"
	JR	NZ,prg0ANo
	DEC	B
	JR	Z,prg0AYs
	INC	L
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,prg0AYs
	LD	A,(DE)		; Search )
	CP	(HL)
	JR	Z,prLpA2
	INC	L
	DJNZ	$-4
	JR	prg0AYs

prLpA2	DEC	B
	JR	Z,prg0AYs
	INC	L
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,prg0ANo
	DEC	B
	JR	Z,prg0AYs
	INC	L
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg0ANo
	DEC	B
	JR	Z,prg0AYs+4
	JR	prg0ANo

prg0AYs	SET	4,(IY+#01)
	SUB	A
prg0ANo	POP	BC
	POP	DE
	POP	HL
	JP	arglpnx

; Argument type: (argum),rr
Sprgr0B	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(cycle1+1)
	LD	B,A
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,prg0BNo
	DEC	B
	JR	Z,prg0BYs
	INC	L
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,prg0BYs
	LD	A,(DE)		; Search )
	CP	(HL)
	JR	Z,prLpB2
	INC	L
	DJNZ	$-4
	JR	prg0BYs

prLpB2	DEC	B
	JR	Z,prg0BYs
	INC	L
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,prg0BNo
	DEC	B
	JR	Z,prg0BYs
	INC	L
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg0BNo
	DEC	B
	JR	Z,prg0BYs
	INC	L
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg0BNo
	DEC	B
	JR	Z,prg0BYs+4
	JR	prg0BNo

prg0BYs	SET	4,(IY+#01)
	SUB	A
prg0BNo	POP	BC
	POP	DE
	POP	HL
	JP	arglpnx

; Argument type: (argum),r
Sprgr0C	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(cycle1+1)
	LD	B,A
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,prg0CNo
	DEC	B
	JR	Z,prg0CYs
	INC	L
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,prg0CYs
	LD	A,(DE)		; Search )
	CP	(HL)
	JR	Z,prLpC2
	INC	L
	DJNZ	$-4
	JR	prg0CYs

prLpC2	DEC	B
	JR	Z,prg0CYs
	INC	L
	INC	DE
	LD	A,(DE)		;,
	CP	(HL)
	JR	NZ,prg0CNo
	DEC	B
	JR	Z,prg0CYs
	INC	L
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg0CNo
	DEC	B
	JR	Z,prg0CYs+4
	JR	prg0CNo

prg0CYs	SET	4,(IY+#01)
	SUB	A
prg0CNo	POP	BC
	POP	DE
	POP	HL
	JP	arglpnx

; Argument type: defb,defw,defd,include,incbin
Sprgr0D	PUSH	HL
	PUSH	BC
	LD	HL,(BegArgm)
	LD	A,(cycle1+1)
	LD	B,A
	LD	C,","
prD0000	LD	A,(HL)
	CP	#22
	JR	Z,prLpD2
prLpD1	LD	A,(HL)
	INC	L
	CP	C
	JR	Z,prD0001
	DJNZ	prLpD1
	JR	prg0DYs+4

prD0001	DEC	B
	JR	Z,prg0DYs
	JR	prD0000

prLpD2	INC	L
	DEC	B
	JR	Z,prg0DYs
prLpD23	LD	A,(HL)
	INC	L
	CP	#22
	JR	Z,prLpD0
	DJNZ	prLpD23
	JR	prg0DYs

prLpD0	DEC	B
	JR	Z,prg0DYs+4
	LD	A,(HL)
	CP	C
	JR	NZ,prg0DNo
	INC	L
	DEC	B
	JR	Z,prg0DYs
	JR	prD0000

prg0DYs	SET	4,(IY+#01)
	SUB	A
prg0DNo	POP	BC
	POP	HL
	JP	arglpnx

; Argument type: argum,r/argum,(hl)
Sprgr0E	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(cycle1+1)
	LD	B,A
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,prg0EYs
	LD	A,(DE)		; Search ,
	CP	(HL)
	JR	Z,prLpE2
	INC	L
	DJNZ	$-4
	JR	prg0EYs

prLpE2	DEC	B
	JR	Z,prg0EYs
	INC	L
	INC	DE
	LD	A,(DE)		; R/(
	CP	(HL)
	JR	NZ,prg0ENo
	INC	DE
	DEC	B
	JR	Z,prg0EYs
	INC	L
	LD	A,(DE)		;H
	CP	(HL)
	JR	NZ,prg0ENo
	INC	DE
	DEC	B
	JR	Z,prg0EYs
	INC	L
	LD	A,(DE)		;L
	CP	(HL)
	JR	NZ,prg0ENo
	INC	DE
	DEC	B
	JR	Z,prg0EYs
	INC	L
	LD	A,(DE)		;)
	CP	(HL)
	JR	NZ,prg0ENo
	INC	DE
	DEC	B
	JR	Z,prg0EYs
	JR	prg0ENo

prg0EYs	LD	A,(DE)
	CP	#20
	JR	Z,$+6
	SET	4,(IY+#01)
	SUB	A
prg0ENo	POP	BC
	POP	DE
	POP	HL
	JP	arglpnx

; Argument type: argum,(rr+argum)
Sprgr0F	PUSH	HL
	PUSH	DE
	PUSH	BC
	EX	DE,HL
	LD	HL,(BegArgm)
	LD	A,(cycle1+1)
	LD	B,A
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,prg0FYs
	LD	A,(DE)		; Search ,
	CP	(HL)
	JR	Z,prLpF2
	INC	L
	DJNZ	$-4
	JR	prg0FYs

prLpF2	DEC	B
	JR	Z,prg0FYs
	INC	L
	INC	DE
	LD	A,(DE)		;(
	CP	(HL)
	JR	NZ,prg0FNo
	DEC	B
	JR	Z,prg0FYs
	INC	L
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg0FNo
	DEC	B
	JR	Z,prg0FYs
	INC	L
	INC	DE
	LD	A,(DE)		; R
	CP	(HL)
	JR	NZ,prg0FNo
	DEC	B
	JR	Z,prg0FYs
	INC	L
	INC	DE
	LD	A,(HL)		;+ or -
	CP	"-"
	JR	Z,$+6
	CP	"+"
	JR	NZ,prg0FNo
	DEC	B
	JR	Z,prg0FYs
	INC	L
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	Z,prg0FYs
	LD	A,(DE)		; Search )
	CP	(HL)
	JR	Z,prLpF4
	INC	L
	DJNZ	$-4
	JR	prg0FYs

prLpF4	DEC	B
	JR	Z,prg0FYs+4
	JR	prg0FNo

prg0FYs	SET	4,(IY+#01)
	SUB	A
prg0FNo	POP	BC
	POP	DE
	POP	HL
	JP	arglpnx

; Set color argument
ArgumOk	LD	(BegAtbl),IX
	SET	2,(IY+#01)
	EXX 
	RET 

; Set comments color
SynCom1	RES	0,(IY+#01)
	LD	A,C
	OR	A
	RET	Z
	LD	(IY+#02),C
	SET	0,(IY+#01)
	RET 

SynCom2	LD	A,C
	OR	A
	RET	Z
	LD	(IY+#03),C
	CALL	SetSynComm

SynCom3	LD	IX,(BegTabl)
	BIT	7,(IX+#06)
	JR	NZ,Scom3
	LD	A,(IX+#08)
	OR	A
	JR	NZ,$+7
Scom3	BIT	4,(IY+#01)
	RET	Z
	SET	6,(IY+#01)
	RET 

SynCom4	LD	A,C
	OR	A
	RET	Z
	LD	(IY+#04),C
	CALL	SetSynArgm
SynCom5	BIT	4,(IY+#01)
	RET	Z
	SET	6,(IY+#01)
	RET 
;
;
CompTxtStr:
	LD	IX,CompBuff
	LD	HL,ReCompBuff
	LD	DE,CompBuff+2
	CALL	CompileTxt
	LD	A,E		; ASM
	INC	A
	LD	(DE),A
	LD	(IX+#00),A
	RET 
CompileTxt:
	LD	(IX+#01),#02
	LD	A,(IY+#00)
	OR	A
	RET	Z
	BIT	6,(IY+#01)	; Error in
	JP	NZ,TextErrS
	BIT	4,(IY+#01)	; Not end
	JP	NZ,TextErrS
	BIT	0,(IY+#01)	; Label
	JR	Z,NotLabelS
	LD	C,(IY+#02)	; Len label
	LD	B,#00
	LDIR 
	SET	0,(IX+#01)	; Label flag
NotLabelS
	BIT	1,(IY+#01)	; In line none
	JP	Z,NotOperS
	RES	1,(IX+#01)
	LD	C,L
	LD	B,H
	LD	HL,(BegComm)
	OR	A
	SBC	HL,BC
	LD	H,#1F		; In r.L " "
NcLoop1	LD	A,L		; And
	SUB	H
	JR	C,NcLbNxt
	JR	Z,NcLbNxt
	LD	L,A
	LD	A,H
	LD	(DE),A
	INC	E
	JR	NcLoop1

NcLbNxt	ADD	A,H
	LD	(DE),A
	INC	E
	PUSH	IX
	LD	IX,(BegAtbl)	; Commands in table
	LD	A,HX

	IFN NEW_VERSION : RES 6,A : ENDIF
	
	LD	(DE),A
	INC	E
	LD	A,LX
	LD	(DE),A
	INC	E
	LD	C,(IX+#12)
	POP	IX
	LD	A,C
	BIT	2,(IY+#01)	; Absence argument
	JP	Z,CmpcEx0
	OR	A
	JP	Z,CmpcExt	; Absence argument
	AND	#0F
	JP	Z,CmpcEx1	; Absence
	ADD	A,A
	LD	C,A
	LD	B,#00
	LD	HL,TblPrgC-2
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	LD	BC,CmpcExt
	PUSH	BC
	JP	(HL)

TblPrgC:	DEFW	prog001
	DEFW	prog002
	DEFW	prog003
	DEFW	prog004
	DEFW	prog005
	DEFW	prog006
	DEFW	prog007
	DEFW	prog008
	DEFW	prog009
	DEFW	prog010
	DEFW	prog011
	DEFW	prog012
	DEFW	prog001	; ?????
	DEFW	prog014
	DEFW	prog015

; Only argument
prog001	CALL	equipsp
	LD	HL,(BegArgm)
	LD	C,(IY+#04)
	LD	B,#00
	LDIR 
	RET 

; Type (xx+....)
prog002	CALL	equipsp
	LD	HL,(BegArgm)
	INC	L
	INC	L
	INC	L
	LD	A,(IY+#04)
	SUB	#04
	LD	C,A
	LD	B,#00
	LDIR 
	RET 

; Type x,...
prog003	CALL	equipsp
	LD	HL,(BegArgm)
	INC	L
	INC	L
	LD	A,(IY+#04)
	SUB	#02
	LD	C,A
	LD	B,#00
	LDIR 
	RET 

; Type x,(....)
prog004	CALL	equipsp
	LD	HL,(BegArgm)
	INC	L
	INC	L
	INC	L
	LD	A,(IY+#04)
	SUB	#04
	LD	C,A
	LD	B,#00
	LDIR 
	RET 

; Type x,(xx+....)
prog005	CALL	equipsp
	LD	HL,(BegArgm)
	LD	BC,#0005
	ADD	HL,BC
	LD	A,(IY+#04)
	SUB	#06
	LD	C,A
	LDIR 
	RET 

; Type xx,....
prog006	CALL	equipsp
	LD	HL,(BegArgm)
	INC	L
	INC	L
	INC	L
	LD	A,(IY+#04)
	SUB	#03
	LD	C,A
	LD	B,#00
	LDIR 
	RET 

; Type xx,(....)
prog007	CALL	equipsp
	LD	HL,(BegArgm)
	INC	L
	INC	L
	INC	L
	INC	L
	LD	A,(IY+#04)
	SUB	#05
	LD	C,A
	LD	B,#00
	LDIR 
	RET 

; Type (hl),....
prog008	CALL	equipsp
	LD	HL,(BegArgm)
	LD	BC,#0005
	ADD	HL,BC
	LD	A,(IY+#04)
	SUB	#05
	LD	C,A
	LDIR 
	RET 

; Type (xx+....),....
prog009	CALL	equipsp
	LD	HL,(BegArgm)
	INC	L
	INC	L
	INC	L
	LD	A,(IY+#04)
	SUB	#05
	LD	C,A
	LD	B,#00
prg09lp	LDI 
	LD	A,(HL)
	CP	")"
	JR	NZ,prg09lp
	INC	L
	INC	L
	SUB	A
	LD	(DE),A
	INC	E
	LDIR 
	RET 

; Type (xx+....),x
prog010	CALL	equipsp
	LD	HL,(BegArgm)
	INC	L
	INC	L
	INC	L
	LD	A,(IY+#04)
	SUB	#06
	LD	C,A
	LD	B,#00
	LDIR 
	RET 

; Type (....),xx
prog011	CALL	equipsp
	LD	HL,(BegArgm)
	INC	L
	LD	A,(IY+#04)
	SUB	#05
	LD	C,A
	LD	B,#00
	LDIR 
	RET 

; Type (....),x
prog012	CALL	equipsp
	LD	HL,(BegArgm)
	INC	L
	LD	A,(IY+#04)
	SUB	#04
	LD	C,A
	LD	B,#00
	LDIR 
	RET 
;
; Prog013: ; !!!!!
;

prog014	CALL	equipsp		; ?????
	LD	HL,(BegArgm)
prg14lp	LDI 
	LD	A,(HL)
	CP	","
	JR	NZ,prg14lp
	RET 

; Type ....,(xx+....)
prog015	CALL	equipsp
	LD	HL,(BegArgm)
	LD	A,(IY+#04)
	SUB	#05
	LD	C,A
	LD	B,#00
prg15lp	LDI 
	LD	A,(HL)
	CP	","
	JR	NZ,prg15lp
	INC	L
	INC	L
	INC	L
	INC	L
	SUB	A
	LD	(DE),A
	INC	E
	LDIR 
	RET 

; " " and
equipsp	LD	HL,(BegTabl)
	LD	A,(BegComm)
	ADD	A,(HL)
	LD	L,A
	LD	A,(BegArgm)
	SUB	L
	LD	L,A
	LD	H,#1F
eqloop1	LD	A,L
	SUB	H
	JR	C,eqipnxt
	JR	Z,eqipnxt
	LD	L,A
	LD	A,H
	LD	(DE),A
	INC	E
	JR	eqloop1

eqipnxt	ADD	A,H
	LD	(DE),A
	INC	E
	RET 
NotOperS
	LD	L,#00
	LD	C,(IY+#02)
	SET	1,(IX+#01)
	JR	CmpcExt+6

CmpcEx0	LD	HL,(BegComm)
	LD	C,(IY+#03)
	JR	CmpcExt+6

CmpcEx1	CALL	equipsp
	SUB	A
	LD	(DE),A
	INC	E

CmpcExt	LD	HL,(BegArgm)
	LD	C,(IY+#04)
	LD	B,#00
	ADD	HL,BC

; Internal operation
	LD	C,#00
CmpcLp1	LD	A,(HL)
	OR	A
	JR	Z,CmpcNx1
	INC	L
	INC	C
	CP	#20
	JR	Z,CmpcLp1
CmpcNx1	LD	A,C
	OR	A
	RET	Z
	LD	L,A
	LD	H,#1F
	JR	eqloop1

; Internal operation
CmpcCmp	PUSH	HL
	CALL	CmpcNx1
	POP	HL
	DEC	L
ccmplp1	LD	B,#20
	LD	A,(HL)
	OR	A
	RET	Z
	INC	L
	CP	B
	JR	Z,ccmpspc
	LD	(DE),A
	INC	E
	JR	ccmplp1+2

ccmpspc	LD	C,#01
cmpsplp	LD	A,(HL)
	OR	A
	JR	Z,cmpexit
	CP	B
	JR	NZ,cmpexit
	INC	L
	INC	C
	JR	cmpsplp

cmpexit	LD	B,#1F
cmploop	LD	A,C
	SUB	B
	JR	C,cmpext1
	JR	Z,cmpext1
	LD	C,A
	LD	A,B
	LD	(DE),A
	INC	E
	JR	cmploop

cmpext1	ADD	A,B
	LD	(DE),A
	INC	E
	JR	ccmplp1

; Error in line
TextErrS
	SET	7,(IX+#01)
txterlp	LD	B,#20
	LD	A,(HL)
	OR	A
	RET	Z
	INC	L
	CP	B
	JR	Z,errspac
	LD	(DE),A
	INC	E
	JR	txterlp+2

errspac	LD	C,#01
errsplp	LD	A,(HL)
	OR	A
	JR	Z,errexit
	CP	B
	JR	NZ,errexit
	INC	L
	INC	C
	JR	errsplp

errexit	LD	B,#1F
errloop	LD	A,C
	SUB	B
	JR	C,errext1
	JR	Z,errext1
	LD	C,A
	LD	A,B
	LD	(DE),A
	INC	E
	JR	errloop

errext1	ADD	A,B
	LD	(DE),A
	INC	E
	JR	txterlp
;
 _mCollectInfo_addEnd
