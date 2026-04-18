 _mCollectInfo_addStart
;[]==========================================================[]
; ASM in machine 1
; On:
; PAGE0 - ASM table
; Iy - asmdata
; HL - ASM
PASS1:	LD	(StackSave),SP	; Save stack
	LD	A,(HL)		; Take length
	SUB	#03		; Info
	RET	Z		; Internal operation
	LD	C,A
	INC	HL
	BIT	7,(HL)		; 7- error in
	JP	NZ,SyntaxError	; Line
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
	JR	Z,NoLabel1	; 0-absence labels
	LD	A,(DE)
	CP	#41
	JP	C,LabelBegNum
	CALL	FindLabel
	JP	NC,SymbolDefin
	CALL	PutLabel
	SET	6,(IY+#00)
	LD	A,(DE)
	CP	":"
	JR	NZ,$+3
	INC	DE
	LD	A,(DE)
	OR	A
	RET	Z
	CP	";"
	RET	Z
	CP	#20
	JP	NC,UnknownChar
	INC	DE
NoLabel1:	BIT	1,(IY+#00)	; None commands
	RET	NZ
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
	LD	C,(IX+#10)
	EXX 
	LD	C,(IX+#11)	; Number.program
	LD	A,(IX+#12)
	AND	#0F
	OR	C
	JP	Z,PASS1_prg
	LD	HL,PASS1tab
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

PASS1tab:	DEFW	PASS1_0		; 0 r,.... (1b)
	DEFW	PASS1_1		; 1 rr,....(2b)
	DEFW	PASS1_0		; 2 r,.... (1b)
	DEFW	PASS1_0		; 3 r,.... (1b)
	DEFW	PASS1_1		; 4 rr,....(2b)
	DEFW	PASS1_prg		; No argument
	DEFW	PASS1_prg		; No argument
	DEFW	PASS1_prg		; No argument
	DEFW	PASS1_0		; R,.... (1b)
	DEFW	PASS1_9		; Org
	DEFW	PASS1_A		; Disp
	DEFW	PASS1_B		; Ent
	DEFW	PASS1_C		; Equ
	DEFW	PASS1_D		; Dup
	DEFW	PASS1_E		; Edup
	DEFW	PASS1_F		; Include
	DEFW	PASS1_10		; Incbin
	DEFW	PASS1_11		; Defb
	DEFW	PASS1_12		; Defw
	DEFW	PASS1_13		; Defd
	DEFW	PASS1_14		; Defs

; No argument
PASS1_prg:
	EXX 
	LD	HL,(MemoryAdr)
	LD	A,H
	CP	#41
	JP	C,BadMemory
	ADC	HL,BC
	JR	Z,$+5
	JP	C,BadMemory
	LD	(MemoryAdr),HL
	LD	HL,(CurrentORG)
	ADD	HL,BC
	LD	(CurrentORG),HL
	RET 

; R,.... (1b)
PASS1_0:	EXX 
	LD	HL,(MemoryAdr)
	INC	C
	LD	A,H
	CP	#41
	JP	C,BadMemory
	ADC	HL,BC
	JR	Z,$+5
	JP	C,BadMemory
	LD	(MemoryAdr),HL
	LD	HL,(CurrentORG)
	ADD	HL,BC
	LD	(CurrentORG),HL
	RET 

; Rr,....(2b)
PASS1_1:	EXX 
	LD	HL,(MemoryAdr)
	INC	C
	INC	C
	LD	A,H
	CP	#41
	JP	C,BadMemory
	ADC	HL,BC
	JR	Z,$+5
	JP	C,BadMemory
	LD	(MemoryAdr),HL
	LD	HL,(CurrentORG)
	ADD	HL,BC
	LD	(CurrentORG),HL
	RET 

; Org
PASS1_9:	SET	7,(IY+#00)
	CALL	GetArgument
	LD	A,H
	CP	#41
	JP	C,BadMemory
	LD	(MemoryAdr),HL
	LD	(CurrentORG),HL
	LD	A,(DE)
	CP	","
	RET	NZ
	JP	SyntaxError

; Disp
PASS1_A:	SET	7,(IY+#00)
	CALL	GetArgument
	LD	(CurrentORG),HL
	LD	A,(DE)
	CP	","
	RET	NZ
	JP	SyntaxError

; Ent
PASS1_B:	LD	HL,(MemoryAdr)
	LD	(CurrentORG),HL
	RET 

; Equ
PASS1_C:	BIT	6,(IY+#00)
	JP	Z,SyntaxError
	SET	7,(IY+#00)
	CALL	GetArgument
	EX	DE,HL
AdrLabA:	LD	HL,#0000
	INC	HL
	CALL	SetSymbPg
	LD	(HL),E
	INC	HL
	LD	(HL),D
	RET 

; Dup
PASS1_D:	SET	7,(IY+#00)
	CALL	GetArgument
	LD	A,H
	OR	L
	JP	Z,IllegCount
	POP	DE
dupnxt1:	PUSH	HL
	LD	HL,(AdrCurString)
	PUSH	HL
	LD	HL,#0000
	PUSH	HL
dupret1:	EX	DE,HL
	JP	(HL)

; Edup
PASS1_E:	POP	DE
	POP	HL
	LD	A,H
	OR	L
	JP	NZ,IllegDirect
	POP	BC
	POP	HL
	DEC	HL
	LD	A,H
	OR	L
	JR	Z,dupret1
	LD	(AdrCurString),BC
	JR	dupnxt1

; Include
PASS1_F:	RET 						; ?????

; Incbin
PASS1_10:	RET 						; ?????

; Defb
PASS1_11:	LD	HL,(MemoryAdr)
	LD	BC,(CurrentORG)
DBlp1_1:	LD	A,H
	CP	#41
	JP	C,BadMemory
	LD	A,(DE)
	CP	#22
	JR	NZ,DBnum_1
	INC	DE
	LD	A,(DE)
	CP	#22
	JP	Z,SyntaxError
	INC	DE
	LD	A,(DE)
	DEC	DE
	DEC	DE
	CP	#22
	JR	Z,DBnum_1
DBlp2_1:	INC	DE
	LD	A,(DE)
	OR	A
	JP	Z,MissGuote
	CP	#22
	JR	Z,DBlpE_1
	INC	HL
	INC	BC
	JR	DBlp2_1	
DBnum_1:	INC	HL
	INC	BC
DBlpE_1:	LD	A,(DE)
	INC	DE
	CP	#20
	JR	C,DBlpQ_1
	CP	";"
	JR	Z,DBlpQ_1
	CP	","
	JR	Z,DBlp1_1
	JR	DBlpE_1
DBlpQ_1	LD	(MemoryAdr),HL
	LD	(CurrentORG),BC
	RET 

; Defw
PASS1_12:	LD	HL,(MemoryAdr)
	LD	BC,(CurrentORG)
DWlp1_1	LD	A,H
	CP	#41
	JP	C,BadMemory
	INC	HL
	INC	BC
	LD	A,H
	CP	#41
	JP	C,BadMemory
	INC	HL
	INC	BC
DWlpE_1	LD	A,(DE)
	INC	DE
	CP	#20
	JR	C,DWlpQ_1
	CP	";"
	JR	Z,DWlpQ_1
	CP	","
	JR	Z,DWlp1_1
	JR	DWlpE_1
DWlpQ_1	LD	(MemoryAdr),HL
	LD	(CurrentORG),BC
	RET 

; Defd
PASS1_13:	RET 						; ?????

; Defs
PASS1_14:	SET	7,(IY+#00)
	CALL	GetArgument
	LD	A,H
	OR	L
	JP	Z,IllegCount
	PUSH	HL
DSlp1_1	LD	A,(DE)
	INC	DE
	CP	","
	JR	NZ,DSf1_1
	LD	B,#00
DSlp2_1	LD	A,(DE)
	INC	DE
	CP	#22
	JR	Z,DSlp3_1
	CP	";"
	JR	Z,DSlpQ_1
	CP	","
	JR	Z,DSlpE_1
	CP	#20
	JR	C,DSlpQ_1
	JR	DSlp2_1
DSlpE_1	INC	B
	JR	DSlp1_1
DSlp3_1	LD	A,(DE)
	INC	DE
	CP	#22
	JP	Z,SyntaxError
DSlp4_1	INC	B
	LD	A,(DE)
	INC	DE
	CP	#22
	JR	NZ,DSlp4_1
	LD	A,(DE)
	INC	DE
	CP	","
	JR	NZ,DSlpQ_1
	JR	DSlp2_1
DSlpQ_1	POP	DE
DSlpQ11	LD	HL,(MemoryAdr)
	LD	A,H
	CP	#41
	JP	C,BadMemory
	ADC	HL,DE
	JR	Z,$+5
	JP	C,BadMemory
	LD	(MemoryAdr),HL
	LD	HL,(CurrentORG)
	ADD	HL,DE
	LD	(CurrentORG),HL
	DJNZ	DSlpQ11
	RET 
DSf1_1	POP	BC
	LD	HL,(MemoryAdr)
	LD	A,H
	CP	#41
	JP	C,BadMemory
	ADC	HL,BC
	JR	Z,$+5
	JP	C,BadMemory
	LD	(MemoryAdr),HL
	LD	HL,(CurrentORG)
	ADD	HL,BC
	LD	(CurrentORG),HL
	RET 
;
 _mCollectInfo_addEnd