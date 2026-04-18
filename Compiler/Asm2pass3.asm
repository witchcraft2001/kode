 _mCollectInfo_addStart
;[]==========================================================[]
; ASM in machine 2
; On:
; PAGE0 - ASM table
; Iy - asmdata
; HL - ASM
PASS2
	LD	(StackSave),SP	; Save stack
	LD	A,(HL)		; Take length
	SUB	#03		; Info
	RET	Z		; Internal operation
	LD	C,A
	INC	HL
	LD	A,(HL)		; Flag
	INC	HL
	AND	#03
	LD	(IY+#00),A
	SUB	A
	LD	DE,FuncBuffer
	LD	B,A
	PUSH	DE
	LDIR 
	LD	(DE),A
	POP	DE
	BIT	0,(IY+#00)
	JR	Z,NoLabel2	; 0-absence labels
FindNoL	LD	A,(DE)
	INC	DE
	OR	A
	RET	Z
	CP	";"
	RET	Z
	CP	#20
	JR	NC,FindNoL
NoLabel2
	BIT	1,(IY+#00)	; None commands
	RET	NZ
	LD	HL,(CurrentORG)
	LD	(BegAdrStrng),HL
	LD	A,(DE)		; Internal operation
	INC	DE
	CP	#20
	JR	C,$-4
	AND	#3F
	LD	HX,A		; Byte addresses
	LD	A,(DE)
	INC	DE
	LD	LX,A		; Byte addresses
	PUSH	IX
	EXX 
	POP	HL
	LD	BC,#000C
	ADD	HL,BC
	EX	DE,HL
	LD	B,(IX+#10)
	EXX 
	LD	C,(IX+#11)	; Number.program
	LD	A,(IX+#12)
	AND	#0F
	OR	C
	JP	Z,PASS2_prg
	LD	HL,PASS2tab
	LD	B,#00
	ADD	HL,BC
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	PUSH	BC
	LD	A,(DE)		; Internal operation
	CP	#20
	RET	NC
	INC	DE
	JR	$-5
PASS2tab
	DEFW	PASS2_0
	DEFW	PASS2_1
	DEFW	PASS2_2
	DEFW	PASS2_3
	DEFW	PASS2_4
	DEFW	PASS2_5
	DEFW	PASS2_6
	DEFW	PASS2_7
	DEFW	PASS2_8
	DEFW	PASS2_9
	DEFW	PASS2_A
	DEFW	PASS2_B
	DEFW	PASS2_C
	DEFW	PASS2_D
	DEFW	PASS2_E
	DEFW	PASS2_F
	DEFW	PASS2_10
	DEFW	PASS2_11
	DEFW	PASS2_12
	DEFW	PASS2_13
	DEFW	PASS2_14
; No argument
PASS2_prg:
	EXX 
	LD	HL,(MemoryAdr)
	PUSH	HL
	LD	C,B
	CALL	SetMemPg
PutByte:	LD	A,(DE)
	LD	(HL),A
	INC	HL
	INC	DE
	DJNZ	PutByte
	POP	HL
	ADD	HL,BC
	LD	(MemoryAdr),HL
	LD	HL,(CurrentORG)
	ADD	HL,BC
	LD	(CurrentORG),HL
	RET 
; R,.... (1b)
PASS2_0:	CALL	GetArgument
	LD	A,(DE)
	CP	","
	JP	Z,SyntaxError
	LD	A,H
	OR	A
	JP	NZ,ValueOut
	LD	A,L
	EXX 
	LD	HL,(MemoryAdr)
	PUSH	HL
	LD	C,B
	INC	C
	EX	AF,AF'
	CALL	SetMemPg
PutByt0:	LD	A,(DE)
	LD	(HL),A
	INC	HL
	INC	DE
	DJNZ	PutByt0
	EX	AF,AF'
	LD	(HL),A
	POP	HL
	ADD	HL,BC
	LD	(MemoryAdr),HL
	LD	HL,(CurrentORG)
	ADD	HL,BC
	LD	(CurrentORG),HL
	RET 
; Rr,....(2b)
PASS2_1:	CALL	GetArgument
	LD	A,(DE)
	CP	","
	JP	Z,SyntaxError
	EXX 
	LD	HL,(MemoryAdr)
	PUSH	HL
	LD	C,B
	INC	C
	INC	C
	CALL	SetMemPg
PutByt1:	LD	A,(DE)
	LD	(HL),A
	INC	HL
	INC	DE
	DJNZ	PutByt1
	EXX 
	PUSH	HL
	EXX 
	POP	DE
	LD	(HL),E
	INC	HL
	LD	(HL),D
	POP	HL
	ADD	HL,BC
	LD	(MemoryAdr),HL
	LD	HL,(CurrentORG)
	ADD	HL,BC
	LD	(CurrentORG),HL
	RET 
; Djnz,jr
PASS2_2:	CALL	GetArgument
	LD	A,(DE)
	CP	","
	JP	Z,SyntaxError
	LD	DE,(CurrentORG)
	INC	DE
	SCF 
	SBC	HL,DE
	CALL	TestShort
	JP	NZ,WrongShort
	EXX 
	LD	HL,(MemoryAdr)
	PUSH	HL
	EX	AF,AF'
	CALL	SetMemPg
	LD	A,(DE)
	LD	(HL),A
	INC	HL
	EX	AF,AF'
	LD	(HL),A
	POP	HL
	INC	HL
	INC	HL
	LD	(MemoryAdr),HL
	LD	HL,(CurrentORG)
	INC	HL
	INC	HL
	LD	(CurrentORG),HL
	RET 
;(rr+....)
PASS2_3:	CALL	GetArgument
	CALL	TestShort
	JP	NZ,WrongShort
	EXX 
	LD	HL,(MemoryAdr)
	LD	B,C
	PUSH	HL
	EX	AF,AF'
	CALL	SetMemPg
	LD	A,(DE)
	LD	(HL),A
	INC	HL
	INC	DE
	DEC	B
	LD	A,(DE)
	LD	(HL),A
	INC	HL
	INC	DE
	DEC	B
	EX	AF,AF'
	LD	(HL),A
	INC	HL
	DEC	B
	JR	Z,$+4
	LD	A,(DE)
	LD	(HL),A
	POP	HL
	ADD	HL,BC
	LD	(MemoryAdr),HL
	LD	HL,(CurrentORG)
	ADD	HL,BC
	LD	(CurrentORG),HL
	RET 
;(rr+....),....
PASS2_4:	CALL	GetArgument
	CALL	TestShort
	JP	NZ,WrongShort
	EXX 
	LD	HL,(MemoryAdr)
	LD	BC,#0003
	PUSH	HL
	EX	AF,AF'
	CALL	SetMemPg
	LD	A,(DE)
	LD	(HL),A
	INC	HL
	INC	DE
	LD	A,(DE)
	LD	(HL),A
	INC	HL
	INC	DE
	EX	AF,AF'
	LD	(HL),A
	POP	HL
	ADD	HL,BC
	PUSH	HL
	LD	HL,(CurrentORG)
	ADD	HL,BC
	PUSH	HL
	EXX 
	INC	DE
	CALL	GetArgument
	LD	A,(DE)
	CP	","
	JP	Z,SyntaxError
	LD	A,H
	OR	A
	JP	NZ,ValueOut
	LD	A,L
	EXX 
	POP	DE
	POP	HL
	EX	AF,AF'
	CALL	SetMemPg
	EX	AF,AF'
	LD	(HL),A
	POP	HL
	INC	HL
	LD	(MemoryAdr),HL
	INC	DE
	LD	(CurrentORG),DE
	RET 
; Im
PASS2_5:	CALL	GetArgument
	LD	A,(DE)
	CP	","
	JP	Z,SyntaxError
	LD	A,H
	OR	A
	JP	NZ,IllegINTNum
	LD	A,L
	CP	#03
	JP	NC,IllegINTNum
	LD	E,#46
	OR	A
	JR	Z,AsmPr05
	DEC	A
	LD	E,#56
	JR	Z,AsmPr05
	LD	E,#5E
AsmPr05:	LD	A,E
	EXX 
	LD	HL,(MemoryAdr)
	PUSH	HL
	EX	AF,AF'
	CALL	SetMemPg
	LD	(HL),#ED
	INC	HL
	EX	AF,AF'
	LD	(HL),A
	POP	HL
	INC	HL
	INC	HL
	LD	(MemoryAdr),HL
	LD	HL,(CurrentORG)
	INC	HL
	INC	HL
	LD	(CurrentORG),HL
	RET 
; Rst
PASS2_6:	CALL	GetArgument
	LD	A,(DE)
	CP	","
	JP	Z,SyntaxError
	LD	A,H
	OR	A
	JP	NZ,IllegRSTNum
	LD	A,L
	AND	#C7
	JP	NZ,IllegRSTNum
	LD	A,L
	OR	#C7
	EXX 
	LD	HL,(MemoryAdr)
	PUSH	HL
	EX	AF,AF'
	CALL	SetMemPg
	EX	AF,AF'
	LD	(HL),A
	POP	HL
	INC	HL
	LD	(MemoryAdr),HL
	LD	HL,(CurrentORG)
	INC	HL
	LD	(CurrentORG),HL
	RET 
; Bit,set,res
PASS2_7:	CALL	GetArgument
	LD	A,H
	OR	A
	JP	NZ,IllegBITNum
	LD	A,L
	AND	#07
	CP	L
	JP	NZ,IllegBITNum
	RLCA 
	RLCA 
	RLCA 
	EXX 
	LD	C,A
	LD	HL,(MemoryAdr)
	PUSH	HL
	CALL	SetMemPg
	LD	(HL),#CB
	INC	HL
	INC	DE
	LD	A,(DE)
	OR	C
	LD	(HL),A
	POP	HL
	INC	HL
	INC	HL
	LD	(MemoryAdr),HL
	LD	HL,(CurrentORG)
	INC	HL
	INC	HL
	LD	(CurrentORG),HL
	RET 
; Bit,set,res(rr+....)
PASS2_8:	CALL	GetArgument
	INC	DE
	LD	A,H
	OR	A
	JP	NZ,IllegBITNum
	LD	A,L
	AND	#07
	CP	L
	JP	NZ,IllegBITNum
	RLCA 
	RLCA 
	RLCA 
	LD	(setA+1),A
	CALL	GetArgument
	CALL	TestShort
	JP	NZ,WrongShort
	EXX 
	LD	HL,(MemoryAdr)
	PUSH	HL
	EX	AF,AF'
	CALL	SetMemPg
	LD	A,(DE)
	LD	(HL),A
	INC	HL
	INC	DE
	LD	A,(DE)
	LD	(HL),A
	INC	HL
	INC	DE
	EX	AF,AF'
	LD	(HL),A
	INC	HL
	INC	DE
	LD	A,(DE)
setA:	OR	#00
	LD	(HL),A
	POP	HL
	LD	BC,#0004
	ADD	HL,BC
	LD	(MemoryAdr),HL
	LD	HL,(CurrentORG)
	ADD	HL,BC
	LD	(CurrentORG),HL
	RET 
TestShort:
	LD	A,L
	ADD	A,#80
	LD	A,H
	JR	NC,$+3
	INC	A
	AND	A
	LD	A,L
	RET 
; Org
PASS2_9:	CALL	GetArgument
	LD	(MemoryAdr),HL
	LD	(CurrentORG),HL
	LD	A,(DE)
	CP	","
	RET	NZ
	JP	SyntaxError
; Disp
PASS2_A:	CALL	GetArgument
	LD	(CurrentORG),HL
	LD	A,(DE)
	CP	","
	RET	NZ
	JP	SyntaxError
; Ent
PASS2_B:	LD	HL,(MemoryAdr)
	LD	(CurrentORG),HL
; Equ
PASS2_C:	RET 
; Dup
PASS2_D:	CALL	GetArgument
	LD	A,H
	OR	L
	JP	Z,IllegCount
	POP	DE
dupnext:	PUSH	HL
	LD	HL,(AdrCurString)
	PUSH	HL
	LD	HL,#0000
	PUSH	HL
dupret:	EX	DE,HL
	JP	(HL)
; Edup
PASS2_E:	POP	DE
	POP	HL
	LD	A,H
	OR	L
	JP	NZ,IllegDirect
	POP	BC
	POP	HL
	DEC	HL
	LD	A,H
	OR	L
	JR	Z,dupret
	LD	(AdrCurString),BC
	JR	dupnext
; Include
PASS2_F:	RET 
; Incbin
PASS2_10:	RET 
; Defb
PASS2_11:	EXX 
	LD	HL,(MemoryAdr)
	LD	BC,(CurrentORG)
	LD	E,L
	LD	D,H
	CALL	SetMemPg
	EXX 
DEFBlp1:	LD	A,(DE)
	CP	#22
	JR	NZ,DEFBnum
	INC	DE
	LD	A,(DE)
	CP	#22
	JP	Z,SyntaxError
	INC	DE
	LD	A,(DE)
	DEC	DE
	DEC	DE
	CP	#22
	JR	Z,DEFBnum
DEFBlp2:	INC	DE
	LD	A,(DE)
	OR	A
	JP	Z,MissGuote
	CP	#22
	JR	Z,DEFBlp3
	EXX 
	LD	(HL),A
	INC	HL
	INC	DE
	INC	BC
	EXX 
	JR	DEFBlp2
DEFBlp3:	INC	DE
	JR	DEFBlpE
DEFBnum:	CALL	GetArgument
	LD	A,H
	OR	A
	JP	NZ,ValueOut
	LD	A,L
	EXX 
	LD	(HL),A
	INC	HL
	INC	DE
	INC	BC
	EXX 
DEFBlpE:	LD	A,(DE)
	INC	DE
	CP	","
	JR	Z,DEFBlp1
	EXX 
	LD	(MemoryAdr),DE
	LD	(CurrentORG),BC
	RET 
; Defw
PASS2_12:	EXX 
	LD	HL,(MemoryAdr)
	LD	BC,(CurrentORG)
	LD	E,L
	LD	D,H
	CALL	SetMemPg
	EXX 
DEFWlp:	CALL	GetArgument
	LD	A,H
	EX	AF,AF'
	LD	A,L
	EXX 
	LD	(HL),A
	INC	HL
	INC	DE
	INC	BC
	EX	AF,AF'
	LD	(HL),A
	INC	HL
	INC	DE
	INC	BC
	EXX 
	LD	A,(DE)
	INC	DE
	CP	","
	JR	Z,DEFWlp
	EXX 
	LD	(MemoryAdr),DE
	LD	(CurrentORG),BC
	RET 
; Defd
PASS2_13:	RET 
; Defs
PASS2_14:	CALL	GetArgument
	LD	A,H
	OR	L
	JP	Z,IllegCount
	PUSH	HL
	LD	BC,CompBuff
DEFSlp1:	LD	A,(DE)
	INC	DE
	CP	","
	JR	NZ,DEFSfill2
	LD	A,(DE)
	CP	#22
	JR	Z,DEFSfill1
	PUSH	BC
	CALL	GetArgument
	POP	BC
	LD	A,H
	OR	A
	JP	NZ,ValueOut
	LD	A,L
	LD	(BC),A
	INC	BC
	JR	DEFSlp1
DEFSfill1:
	INC	DE
DEFSf1:	LD	A,(DE)
	INC	DE
	CP	#22
	JR	Z,DEFSlp1
	LD	(BC),A
	INC	C
	JR	DEFSf1
DEFSfill2:
	CP	#20
	JR	C,DEFSfl1
	CP	";"
	JP	NZ,SyntaxError
DEFSfl1:	LD	A,C
	OR	A
	JR	NZ,$+4
	LD	(BC),A
	INC	C
	LD	LX,C
	POP	BC
DEFSlp2:	LD	DE,CompBuff
	EXX 
	LD	HL,(MemoryAdr)
	LD	BC,(CurrentORG)
	LD	E,L
	LD	D,H
	CALL	SetMemPg
	EXX 
	PUSH	BC
DEFSlp3:	LD	A,(DE)
	INC	DE
	EXX 
	LD	(HL),A
	INC	HL
	INC	DE
	INC	BC
	EXX 
	LD	A,LX
	CP	E
	JR	NZ,DEFSlp3
	EXX 
	LD	(MemoryAdr),DE
	LD	(CurrentORG),BC
	EXX 
	POP	BC
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,DEFSlp2
	RET 
;
 _mCollectInfo_addEnd