;
	ORG	#6000
 _mCollectInfo_addStart
;
	IN	A,(SLOT2)
	PUSH	AF
	LD	(TxtPg1+1),A
	IN	A,(SLOT3)
	PUSH	AF
	LD	(TxtPg2+1),A

	SUB	A
	LD	(HighAdr),A
	LD	(HighPost),A
	LD	HL,#FDFE			; !hardcode
	LD	(FreeSymbol),HL
	CALL	SetSymbPg
	INC	HL
	LD	(HL),A
	INC	HL
	LD	DE,#FE01			; !hardcode
	LD	BC,#01FF			; !hardcode
	LD	(HL),L
	LDIR 
	
	LD	HL,#0000
	LD	(CurString),HL
	LD	(FreePost),HL
	LD	(MemoryAdr),HL
	LD	(CurrentORG),HL
	LD	HL,StrNumber
	LD	B,#05
	LD	A,#30
	LD	(HL),A
	INC	HL
	DJNZ	$-2
	POP	AF
	OUT	(SLOT3),A
	POP	AF
	OUT	(SLOT2),A
	LD	HL,#8040
	LD	(AdrCurString),HL
CompileLp:
	CALL	TestEscape
	CALL	CompileString
	CALL	NextString
TxtPg1:	LD	A,#00
	OUT	(SLOT2),A
TxtPg2:	LD	A,#00
	OUT	(SLOT3),A
	LD	HL,(AdrCurString)
	LD	E,(HL)
	LD	D,#00
	ADD	HL,DE
	LD	(AdrCurString),HL
	LD	A,(HL)
	OR	A
	JR	NZ,CompileLp
	CALL	PostMain
	RET 
TestEscape:
	RET 
NextString:
	LD	HL,(CurString)
	INC	HL
	LD	(CurString),HL
	LD	HL,StrNumber+4
	LD	B,#05
NxtStrL:	INC	(HL)
	LD	A,(HL)
	CP	#3A
	RET	C
	LD	(HL),"0"
	DEC	HL
	DJNZ	NxtStrL
	RET 
StrNumber:
	DEFS	5," "
;[]==========================================================[]
; ASM in machine
; On:
; PAGE0 - ASM table
; Iy - asmdata
; HL - ASM
CompileString:
	LD	(StackSave),SP	; Save stack
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
	JR	Z,NoLabel	; 0-absence labels
	LD	A,(DE)
	CP	#41
	JP	C,LabelBegNum
	CALL	AppendLabel
	LD	A,(DE)
	INC	DE
	OR	A
	RET	Z
	CP	";"
	RET	Z
	CP	#20
	JP	NC,UnknownChar
NoLabel:	BIT	1,(IY+#00)	; None commands
	RET	NZ
	LD	HL,(CurrentORG)
	LD	(BegAdrStrng),HL
	LD	A,(DE)		; Internal operation
	INC	DE
	CP	' '
	JR	C,$-4
; And #3f
	LD	HX,A		; Byte addresses
	LD	A,(DE)
	INC	DE
	LD	LX,A		; Byte addresses

	LD	A,#0F		; !fixit
	OUT	(SLOT3),A

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
	JP	Z,AsmPrgr
	LD	HL,CompileTab
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
CompileTab:
	DEFW	AsmPrg0
	DEFW	AsmPrg1
	DEFW	AsmPrg2
	DEFW	AsmPrg3
	DEFW	AsmPrg4
	DEFW	AsmPrg5
	DEFW	AsmPrg6
	DEFW	AsmPrg7
	DEFW	AsmPrg8
	DEFW	AsmPrg9
	DEFW	AsmPrgA
	DEFW	AsmPrgB
	DEFW	AsmPrgC
	DEFW	AsmPrgD
	DEFW	AsmPrgE
	DEFW	AsmPrgF
	DEFW	AsmPr10
	DEFW	AsmPr11
	DEFW	AsmPr12
	DEFW	AsmPr13
	DEFW	AsmPr14

; No argument
AsmPrgr:	EXX 
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
AsmPrg0:	SET	5,(IY+#00)
	CALL	GetArgument
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
AsmPrg1:	SET	5,(IY+#00)
	SET	4,(IY+#00)
	CALL	GetArgument
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
AsmPrg2:	SET	4,(IY+#00)
	CALL	GetArgument
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
AsmPrg3:	SET	3,(IY+#00)
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
	EX	AF,AF'
	LD	(HL),A
	POP	HL
	LD	BC,#0003
	ADD	HL,BC
	LD	(MemoryAdr),HL
	LD	HL,(CurrentORG)
	ADD	HL,BC
	LD	(CurrentORG),HL
	RET 

;(rr+....),....
AsmPrg4:	SET	3,(IY+#00)
	CALL	GetArgument
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
	LD	(MemoryAdr),HL
	LD	HL,(CurrentORG)
	ADD	HL,BC
	LD	(CurrentORG),HL
	EXX 
	INC	DE
	RES	3,(IY+#00)
	SET	5,(IY+#00)
	CALL	GetArgument
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

; Im
AsmPrg5:	SET	7,(IY+#00)
	CALL	GetArgument
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
AsmPrg6:	SET	7,(IY+#00)
	CALL	GetArgument
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
AsmPrg7:	SET	7,(IY+#00)
	CALL	GetArgument
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
AsmPrg8:	SET	7,(IY+#00)
	CALL	GetArgument
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
	RES	7,(IY+#00)
	SET	3,(IY+#00)
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
AsmPrg9:	SET	7,(IY+#00)
	CALL	GetArgument
	LD	(MemoryAdr),HL
	LD	(CurrentORG),HL
	LD	A,(DE)
	CP	","
	JP	Z,SyntaxError
PutPost:	LD	HL,(FreePost)
	CALL	SetPostPg
	LD	(HL),#47
	INC	HL
	LD	A,(MemPage3)
	LD	(HL),A
	INC	HL
	EX	DE,HL
	LD	HL,(MemoryAdr)
	LD	BC,(CurrentORG)
	OR	A
	SBC	HL,BC
	EX	DE,HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	A,(MemoryAdr+1)
	LD	(HL),A
	INC	HL
	LD	(HighAdr),A
	CALL	ResPostPg
	LD	(FreePost),HL
	RET 

; Disp
AsmPrgA:	SET	7,(IY+#00)
	CALL	GetArgument
	LD	(CurrentORG),HL
	LD	A,(DE)
	CP	","
	JP	Z,SyntaxError
	JR	PutPost

; Ent:
AsmPrgB:	LD	HL,(MemoryAdr)
	LD	(MemoryAdr),HL
	JR	PutPost

; Equ
AsmPrgC:	BIT	6,(IY+#00)
	JP	Z,SyntaxError
	SET	7,(IY+#00)
	CALL	GetArgument
	EX	DE,HL
	LD	HL,(AdrLabA+1)
	CALL	SetSymbPg
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	RET 

; Dup
AsmPrgD:	SET	7,(IY+#00)
	CALL	GetArgument
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
AsmPrgE:	POP	DE
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
AsmPrgF:	RET 						; ?????

; Incbin
AsmPr10:	RET 						; ?????

; Defb
AsmPr11:	SET	5,(IY+#00)
	EXX 
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

DEFBlp3	INC	DE
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
AsmPr12:	SET	5,(IY+#00)
	SET	4,(IY+#00)
	EXX 
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
AsmPr13:	RET  						; ?????

; Defs
AsmPr14:	SET	7,(IY+#00)
	CALL	GetArgument
	LD	A,H
	OR	L
	JP	Z,IllegCount
	PUSH	HL
	LD	BC,CompBuff
DEFSlp1:	LD	A,(DE)
	INC	DE
	CP	","
	JR	NZ,DEFSfill
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

DEFSfill:	CP	#20
	JR	C,DEFSfl1
	CP	";"
	JP	NZ,SyntaxError
DEFSfl1:	LD	A,C
	OR	A
	JR	Z,$+4
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
;[]==========================================================[]
	INCLUDE	'COMPILER2.ASM'
;[]==========================================================[]
SetMemPg:	LD	A,H
	INC	A
	JR	NZ,SetMem1
	PUSH	HL
	PUSH	BC
	LD	B,A
	OR	A
	ADC	HL,BC
	POP	BC
	POP	HL
	JR	Z,$+5
	JP	C,BadMemory
	LD	A,(MemPage2)
	OUT	(SLOT2),A
	LD	A,(MemPage3)
	OUT	(SLOT3),A
	RET 

SetMem1:	LD	A,H
	CP	#BF
	JR	C,SetMem2
	LD	A,(MemPage2)
	OUT	(SLOT2),A
	LD	A,(MemPage3)
	OUT	(SLOT3),A
	RET 
	
SetMem2:	CP	#40
	JP	C,BadMemory
	ADD	A,#40
	LD	H,A
	LD	A,(MemPage1)
	OUT	(SLOT2),A
	LD	A,(MemPage2)
	OUT	(SLOT3),A
	RET 
;[]==========================================================[]
SetSymbPg:
	LD	A,H
	CP	#81
	JR	C,EndPage
	LD	A,(SymbPg2)
	OUT	(SLOT2),A
	LD	A,(SymbPg1)
	OUT	(SLOT3),A
	SUB	A
	LD	(SubSymb+1),A
	RET 

EndPage:	CP	#41
	JR	C,EndPage1
	ADD	A,#40
	LD	H,A
	LD	A,(SymbPg3)
	OUT	(SLOT2),A
	LD	A,(SymbPg2)
	OUT	(SLOT3),A
	LD	A,#40
	LD	(SubSymb+1),A
	RET 

EndPage1:	SET	7,H
	LD	A,(SymbPg4)
	OUT	(SLOT2),A
	LD	A,(SymbPg3)
	OUT	(SLOT3),A
	LD	A,#80
	LD	(SubSymb+1),A
	RET 
;[]==========================================================[]
SetPostPg:
	IN	A,(SLOT2)
	LD	(Post1+1),A
	IN	A,(SLOT3)
	LD	(Post2+1),A
	LD	A,H
	CP	#81
	JR	C,EndPPg
	LD	A,(PostPg2)
	OUT	(SLOT2),A
	LD	A,(PostPg1)
	OUT	(SLOT3),A
	SUB	A
	LD	(PostSub+1),A
	LD	(PstSub1+1),A
	RET 

EndPPg:	CP	#41
	JR	C,EndPPg1
	ADD	A,#40
	LD	H,A
	LD	A,(PostPg3)
	OUT	(SLOT2),A
	LD	A,(PostPg2)
	OUT	(SLOT3),A
	LD	A,#40
	LD	(PostSub+1),A
	LD	(PstSub1+1),A
	RET 

EndPPg1:	SET	7,H
	LD	A,(PostPg4)
	OUT	(SLOT2),A
	LD	A,(PostPg3)
	OUT	(SLOT3),A
	LD	A,#80
	LD	(PostSub+1),A
	LD	(PstSub1+1),A
	RET 

ResPostPg:
	LD	A,H
PostSub:	SUB	#00
	LD	H,A
Post1:	LD	A,#00
	OUT	(SLOT2),A
Post2:	LD	A,#00
	OUT	(SLOT3),A
	RET 
ResPostPg1:
	LD	A,H
PstSub1:	SUB	#00
	LD	H,A
	RET
;[]==========================================================[]
AdrCurString:	DEFW	#0000
CurString:	DEFW	#0000
CurrentORG:	DEFW	#0000
MemoryAdr:	DEFW	#0000
BegAdrStrng:	DEFW	#0000
FreeSymbol:	DEFW	#0000
FreePost:		DEFW	#0000
HighPost:		DEFB	#00
HighAdr:		DEFB	#00
StackSave:	DEFW	#0000

SymbPg1:		DEFB	#ED
SymbPg2:		DEFB	#EE
SymbPg3:		DEFB	#EF
SymbPg4:		DEFB	#F0

PostPg1:		DEFB	#F1
PostPg2:		DEFB	#F2
PostPg3:		DEFB	#F3
PostPg4:		DEFB	#F4

MemPage1:		DEFB	#20
MemPage2:		DEFB	#21
MemPage3:		DEFB	#22

; !fixit
BadMemory:
SyntaxError
IllegForwrd
IllegNumber
IllegINTNum
IllegRSTNum
IllegBITNum
IllegDirect
NeedExpress
UnknownChar
LabelBegNum
LongSymbol
SymbolDefin
MissGuote
WrongShort
ValueOut
ArOverflow
IllegCount
DivByZero:
	LD	SP,(StackSave)
	RET 
SaveLabel:
	DEFW	#0000
CantCountP:
NotDefinedP:
WrongShortP:
	RET 

FuncBuffer	EQU #7D00			; !fixit
CompBuff		EQU #7E00			; !fixit
;
 _mCollectInfo_addEnd