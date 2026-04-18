 _mCollectInfo_addStart
;[]===========================================================[]
; In ASM format
Compile	LD	A,#02
	LD	(IX+#01),A
	BIT	0,(IY-#04)
	JR	Z,$+6
	SET	6,(IX+#01)
	LD	A,(EditMode)	; 0-text edit,1-table edit
	OR	A
	JR	Z,CompNxt
	PUSH	HL
	LD	A,(IY+#02)
	LD	B,A
	LD	H,high TextBuff
	ADD	A,A
	LD	L,A
	JR	NC,$+3
	INC	H
	LD	A,(ColTxtWin)
	LD	C,A
DelSpac	LD	(HL),#00
	DEC	HL
	DEC	HL
	LD	A,(HL)
	CP	#20
	JR	NZ,$+7
	INC	HL
	LD	(HL),C
	DEC	HL
	DJNZ	DelSpac
	LD	(IY+#02),B
	POP	HL
CompNxt	LD	A,(IY+#02)
	OR	A
	RET	Z
	PUSH	HL
	LD	C,A
	LD	B,#00
	ADD	HL,BC
	ADD	HL,BC
	LD	(HL),B
	POP	HL
	BIT	6,(IY+#08)	; Error in
	JP	NZ,TextErr
	BIT	4,(IY+#08)	; Not end
	JP	NZ,TextErr

	BIT	0,(IY+#08)	; Label
	JR	Z,NtLabel
	LD	A,(IY+#09)	; Len label
MvLabel	LDI 
	INC	HL
	DEC	A
	JR	NZ,MvLabel

	SET	0,(IX+#01)	; Label flag

NtLabel	BIT	1,(IY+#08)	; In line none
	JP	Z,NotOper
	RES	1,(IX+#01)
	LD	C,L
	LD	B,H
	LD	HL,(BegComm)
	OR	A
	SBC	HL,BC
	SRL	H
	RR	L		; In r.L " "
	LD	H,#1F
NtLoop1	LD	A,L		; And
	SUB	H
	JR	C,NtLbNxt
	JR	Z,NtLbNxt
	LD	L,A
	LD	A,H
	LD	(DE),A
	INC	E
	JR	NtLoop1

NtLbNxt	ADD	A,H
	LD	(DE),A
	INC	E

 IF NEW_VERSION
 	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(AsmTabPg)
	OUT	(SLOT3),A
 ELSE
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(AsmTabPg)
	OUT	(SLOT2),A
 ENDIF
 
	PUSH	IX
	LD	IX,(BegAtbl)	; Commands in table
	LD	A,HX
	LD	(DE),A
	INC	E
	LD	A,LX
	LD	(DE),A
	INC	E
	LD	C,(IX+#12)
	POP	IX
	POP	AF
 IF NEW_VERSION
	OUT	(SLOT3),A
 ELSE
	OUT	(SLOT2),A
 ENDIF
	LD	A,C
	BIT	2,(IY+#08)	; Absence argument
	JP	Z,CompEx0
	OR	A
	JP	Z,CompExt	; Absence argument
	AND	#0F
	JP	Z,CompEx1	; Absence
	ADD	A,A
	LD	C,A
	LD	B,#00
	LD	HL,TblProg-2
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	LD	BC,CompExt
	PUSH	BC
	JP	(HL)

TblProg	DEFW	Prog001
	DEFW	Prog002
	DEFW	Prog003
	DEFW	Prog004
	DEFW	Prog005
	DEFW	Prog006
	DEFW	Prog007
	DEFW	Prog008
	DEFW	Prog009
	DEFW	Prog010
	DEFW	Prog011
	DEFW	Prog012
	DEFW	Prog001
	DEFW	Prog014
	DEFW	Prog015

; Only argument
Prog001	CALL	EquipSp
	LD	HL,(BegArgm)
	LD	A,(IY+#0B)
	LDI 
	INC	HL
	DEC	A
	JR	NZ,$-4
	RET 

; Type (xx+....)
Prog002	CALL	EquipSp
	LD	HL,(BegArgm)
	LD	BC,#0006
	ADD	HL,BC
	LD	A,(IY+#0B)
	SUB	#04
	LDI 
	INC	HL
	DEC	A
	JR	NZ,$-4
	RET 

; Type x,...
Prog003	CALL	EquipSp
	LD	HL,(BegArgm)
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	A,(IY+#0B)
	DEC	A
	DEC	A
	LDI 
	INC	HL
	DEC	A
	JR	NZ,$-4
	RET 

; Type x,(....)
Prog004	CALL	EquipSp
	LD	HL,(BegArgm)
	LD	BC,#0006
	ADD	HL,BC
	LD	A,(IY+#0B)
	SUB	#04
	LDI 
	INC	HL
	DEC	A
	JR	NZ,$-4
	RET 

; Type x,(xx+....)
Prog005	CALL	EquipSp
	LD	HL,(BegArgm)
	LD	BC,#000A
	ADD	HL,BC
	LD	A,(IY+#0B)
	SUB	#06
	LDI 
	INC	HL
	DEC	A
	JR	NZ,$-4
	RET 

; Type xx,....
Prog006	CALL	EquipSp
	LD	HL,(BegArgm)
	LD	BC,#0006
	ADD	HL,BC
	LD	A,(IY+#0B)
	SUB	#03
	LDI 
	INC	HL
	DEC	A
	JR	NZ,$-4
	RET 

; Type xx,(....)
Prog007	CALL	EquipSp
	LD	HL,(BegArgm)
	LD	BC,#0008
	ADD	HL,BC
	LD	A,(IY+#0B)
	SUB	#05
	LDI 
	INC	HL
	DEC	A
	JR	NZ,$-4
	RET 

; Type (hl),....
Prog008	CALL	EquipSp
	LD	HL,(BegArgm)
	LD	BC,#000A
	ADD	HL,BC
	LD	A,(IY+#0B)
	SUB	#05
	LDI 
	INC	HL
	DEC	A
	JR	NZ,$-4
	RET 

; Type (xx+....),....
Prog009	CALL	EquipSp
	LD	HL,(BegArgm)
	LD	BC,#0006
	ADD	HL,BC
	LD	A,(IY+#0B)
	SUB	#05
	LD	C,A
	LD	B,#00
Prg09lp	LDI 
	INC	HL
	LD	A,(HL)
	CP	")"
	JR	NZ,Prg09lp
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	SUB	A
	LD	(DE),A
	INC	E
	LDI 
	INC	HL
	JP	PE,$-3
	RET 

; Type (xx+....),x
Prog010	CALL	EquipSp
	LD	HL,(BegArgm)
	LD	BC,#0006
	ADD	HL,BC
	LD	A,(IY+#0B)
	SUB	#06
	LDI 
	INC	HL
	DEC	A
	JR	NZ,$-4
	RET 

; Type (....),xx
Prog011	CALL	EquipSp
	LD	HL,(BegArgm)
	INC	HL
	INC	HL
	LD	A,(IY+#0B)
	SUB	#05
	LDI 
	INC	HL
	DEC	A
	JR	NZ,$-4
	RET 

; Type (....),x
Prog012	CALL	EquipSp
	LD	HL,(BegArgm)
	INC	HL
	INC	HL
	LD	A,(IY+#0B)
	SUB	#04
	LDI 
	INC	HL
	DEC	A
	JR	NZ,$-4
	RET 

Prog014	CALL	EquipSp
	LD	HL,(BegArgm)
Prg14lp	LDI 
	INC	HL
	LD	A,(HL)
	CP	","
	JR	NZ,Prg14lp
	RET 

; Type ....,(xx+....)
Prog015	CALL	EquipSp
	LD	HL,(BegArgm)
	LD	A,(IY+#0B)
	SUB	#05
	LD	C,A
	LD	B,#00
Prg15lp	LDI 
	INC	HL
	LD	A,(HL)
	CP	","
	JR	NZ,Prg15lp
	LD	A,L
	ADD	A,#08
	LD	L,A
	JR	NC,$+3
	INC	H
	SUB	A
	LD	(DE),A
	INC	E
	LDI 
	INC	HL
	JP	PE,$-3
	RET 

; " " and
EquipSp:
 IFN NEW_VERSION
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(AsmTabPg)
	OUT	(SLOT2),A
	LD	HL,(BegTabl)
	RES	6,H
	LD	C,(HL)
	LD	B,0
	POP	AF
	OUT	(SLOT2),A
 ELSE
	in a,(SLOT3)		
	push af			
	ld a,(AsmTabPg)	
	out (SLOT3),a	
	ld hl,(BegTabl)	
	ld c,(hl)		
	ld b,0		
	pop af			
	out (SLOT3),a	
 ENDIF
	LD	HL,(BegComm)
	ADD	HL,BC
	ADD	HL,BC
	LD	C,L
	LD	B,H
	LD	HL,(BegArgm)
	OR	A
	SBC	HL,BC
	SRL	H
	RR	L
	LD	H,#1F
EqLoop1:	LD	A,L
	SUB	H
	JR	C,EqipNxt
	JR	Z,EqipNxt
	LD	L,A
	LD	A,H
	LD	(DE),A
	INC	E
	JR	EqLoop1

EqipNxt:	ADD	A,H
	LD	(DE),A
	INC	E
	RET 

NotOper:	LD	HL,TextBuff
	LD	C,(IY+#09)
	SET	1,(IX+#01)
	JR	CompExt+6

CompEx0	LD	HL,(BegComm)
	LD	C,(IY+#0A)
	JR	CompExt+6

CompEx1	CALL	EquipSp
	SUB	A
	LD	(DE),A
	INC	E

CompExt	LD	HL,(BegArgm)
	LD	C,(IY+#0B)
	LD	B,#00
	ADD	HL,BC
	ADD	HL,BC

; Internal operation
	LD	C,#00
CompLp1	LD	A,(HL)
	OR	A
	JR	Z,CompNx1
	INC	HL
	INC	HL
	CP	";"
	JR	Z,CommCmp
	INC	C
	CP	#20
	JR	Z,CompLp1
CompNx1	LD	A,C
	OR	A
	RET	Z
	LD	L,A
	LD	H,#1F
	JR	EqLoop1

; Internal operation
CommCmp	PUSH	HL
	CALL	CompNx1
	POP	HL
	DEC	HL
	DEC	HL
CcmpLp1	LD	B,#20
	LD	A,(HL)
	OR	A
	RET	Z
	INC	HL
	INC	HL
	CP	B
	JR	Z,CcmpSpc
	LD	(DE),A
	INC	E
	JR	CcmpLp1+2

CcmpSpc	LD	C,#01
CmpSpLp	LD	A,(HL)
	OR	A
	JR	Z,CmpExit
	CP	B
	JR	NZ,CmpExit
	INC	HL
	INC	HL
	INC	C
	JR	CmpSpLp

CmpExit	LD	B,#1F
CmpLoop	LD	A,C
	SUB	B
	JR	C,CmpExt1
	JR	Z,CmpExt1
	LD	C,A
	LD	A,B
	LD	(DE),A
	INC	E
	JR	CmpLoop

CmpExt1	ADD	A,B
	LD	(DE),A
	INC	E
	JR	CcmpLp1

; Error in line
TextErr	SET	7,(IX+#01)
TxtErLp	LD	B,#20
	LD	A,(HL)
	OR	A
	RET	Z
	INC	HL
	INC	HL
	CP	B
	JR	Z,ErrSpac
	LD	(DE),A
	INC	E
	JR	TxtErLp+2

ErrSpac	LD	C,#01
ErrSpLp	LD	A,(HL)
	OR	A
	JR	Z,ErrExit
	CP	B
	JR	NZ,ErrExit
	INC	HL
	INC	HL
	INC	C
	JR	ErrSpLp

ErrExit	LD	B,#1F
ErrLoop	LD	A,C
	SUB	B
	JR	C,ErrExt1
	JR	Z,ErrExt1
	LD	C,A
	LD	A,B
	LD	(DE),A
	INC	E
	JR	ErrLoop

ErrExt1	ADD	A,B
	LD	(DE),A
	INC	E
	JR	TxtErLp
;[]===========================================================[]
;
 _mCollectInfo_addEnd