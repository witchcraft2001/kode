 _mCollectInfo_addStart
;[]===========================================================[]
;Event file input line
EFileInp
	LD	HL,what	; Events list
	LD	A,(HL)
	INC	HL
	CP	evMouseFr
	JP	Z,EImouse
	CP	evKeyboard
	JP	Z,EFIkeys
	CP	evCombKey
	JP	Z,EIcombK
	CP	evCommand
	JP	Z,FIcmmnd
	CP	evMessage
	RET	NZ
	LD	A,(HL)
	INC	HL
	CP	msGtFileNm
	JP	Z,GtFileNm
	CP	msPtFileIn
	RET	NZ
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	JR	PtFLInf

FIcmmnd	LD	A,(HL)
	CP	cmOpenFile
	JP	Z,GtFileNm
	CP	cmReplaceF
	JP	Z,GtFileNm
	CP	cmImport
	JP	Z,GtFileNm
	CP	cmSaveFile
	JP	Z,OpFile
	RET 

PtFLInf	SUB	A
	LD	(OpenFl+1),A
	EX	DE,HL
	ADD	HL,HL	;*20
	ADD	HL,HL
	PUSH	HL
	ADD	HL,HL
	ADD	HL,HL
	POP	DE
	ADD	HL,DE
	LD	(NameNum+1),HL
	LD	A,H
	ADD	A,#C0
	LD	H,A
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(SymbPg1)
	OUT	(SLOT3),A
	LD	DE,ReCompBuff
	LD	BC,20
	PUSH	DE
	LDIR 
	POP	HL
	POP	AF
	OUT	(SLOT3),A
	LD	DE,FileIL
	PUSH	HL
	LD	C,19
	ADD	HL,BC
	LD	C,B
	BIT	4,(HL)
	POP	HL
	JR	NZ,IFI00
	LD	A,(FMenuFlg)
	OR	A
	JR	Z,FImesEx
	JR	EndIF1
IFI00	LD	A,#01
	LD	(OpenFl+1),A
	LD	BC,#0800
IFI0	LD	A,(HL)
	CP	#20
	JR	Z,IFI1
	INC	HL
	LD	(DE),A
	INC	DE
	INC	C
	DJNZ	IFI0
	LD	A,B
	OR	A
	JR	Z,IFI2-2
IFI1	INC	HL
	DJNZ	$-1
	LD	B,#03
IFI2	LD	A,(HL)
	CP	#20
	JR	Z,EndIF
	LD	A,"."
	LD	(DE),A
	INC	DE
	INC	C
IFI4	LD	A,(HL)
	INC	HL
	LD	(DE),A
	INC	DE
	INC	C
	DJNZ	IFI4
EndIF	LD	A,'\' 
	LD	(DE),A
	INC	DE
	INC	C
FImesEx	LD	HL,FileMask
	LD	B,#0C
EndIF0	LD	A,(HL)
	OR	A
	JR	Z,EndIF1
	LD	(DE),A
	INC	HL
	INC	DE
	INC	C
	DJNZ	EndIF0
EndIF1	SUB	A
	LD	(DE),A
	PUSH	IY
	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	PUSH	HL
	POP	IY
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	(HL),C
	CALL	PrnInLn
	POP	IY
	RET 

GtFileNm
OpenFl	LD	A,#00
	OR	A
	JP	NZ,OpFile
NameNum	LD	HL,#0000
	LD	A,H
	ADD	A,#C0
	LD	H,A
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(SymbPg1)
	OUT	(SLOT3),A
	LD	DE,ReCompBuff
	LD	BC,20
	PUSH	DE
	LDIR 
	POP	HL
	POP	AF
	OUT	(SLOT3),A
	LD	DE,FileIL
	PUSH	HL
	LD	C,19
	ADD	HL,BC
	LD	C,B
	BIT	4,(HL)
	POP	HL
	JP	NZ,IFI00
	LD	BC,#0800
IFI01	LD	A,(HL)
	CP	#20
	JR	Z,IFI11
	INC	HL
	LD	(DE),A
	INC	DE
	INC	C
	DJNZ	IFI01
	LD	A,B
	OR	A
	JR	Z,IFI21-2
IFI11	INC	HL
	DJNZ	$-1
	LD	B,#03
IFI21	LD	A,(HL)
	CP	#20
	JR	Z,EndIF11
	LD	A,"."
	LD	(DE),A
	INC	DE
	INC	C
IFI41	LD	A,(HL)
	INC	HL
	LD	(DE),A
	INC	DE
	INC	C
	DJNZ	IFI41
EndIF11	PUSH	IY
	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	PUSH	HL
	POP	IY
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	(HL),C
	CALL	PrnInLn
	POP	IY
	LD	A,#01
	LD	(OpenFl+1),A
FIex	LD	HL,what
	LD	A,(HL)
	CP	evMessage
	RET	Z
	LD	(HL),evNothing
	RET 

EFIkeys	BIT	7,(IX+#01)
	JP	Z,EIkeys
	LD	A,(HL)
	CP	#0D
	JP	NZ,EIkeys
	LD	HL,what
	LD	(HL),evNothing
OpFile	SUB	A
	LD	(OpenFl+1),A
	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	INC	HL
	LD	(HL),#01	; Ready string
	INC	HL
	LD	(HL),A		; Pos x
	INC	HL
	LD	(HL),A		; Add x
	INC	HL
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,FIex
	LD	C,A
	LD	B,#00
	LD	E,L
	LD	D,H
	ADD	HL,BC
	LD	(HL),B
	LD	B,C
FindSl	DEC	HL
	LD	A,(HL)
	CP	'\' 
	JR	Z,ChangeDIR
	DJNZ	FindSl
PutNewM	LD	A,C
	CP	#0D
	RET	NC		
	PUSH	HL
	LD	B,C
	LD	E,#00
FindMsk	LD	A,(HL)
	INC	HL
	CP	"?"
	JR	Z,MskEx
	CP	"*"
	JR	Z,MskEx
	CP	"."
	JR	NZ,$+4
	SET	0,E
	DJNZ	FindMsk
	BIT	0,E
	JR	NZ,MskEx
	LD	(HL),"."
	INC	HL
	INC	C
	LD	(HL),"T"
	INC	HL
	INC	C
	LD	(HL),"A"
	INC	HL
	INC	C
	LD	(HL),"S"
	INC	C
	PUSH	BC
	PUSH	IY
	LD	L,(IX+#09)
	LD	H,(IX+#0A)
	PUSH	HL
	POP	IY
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	A,(HL)
	ADD	A,#04
	LD	(HL),A
	CALL	PrnInLn
	POP	IY
	POP	BC
MskEx	POP	HL
	LD	A,C
	CP	#0D
	RET	NC
	LD	A,B
	OR	A
	JR	Z,FindFile	
	LD	DE,FileMask
	LD	B,#00
	LDIR 
	SUB	A
	LD	(DE),A
	JP	FIexitMs
ChangeDIR
	INC	HL
	PUSH	HL
	LD	A,C
	SUB	B
	LD	C,A
	PUSH	BC
	LD	C,B
	LD	B,#00
	LD	HL,ReCompBuff
	EX	DE,HL
	PUSH	DE
	LDIR 
	SUB	A
	LD	(DE),A
	POP	HL
	PUSH	IY
	PUSH	IX
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)
	OUT	(SLOT0),A
	LD	BC,#7FFD
	LD	A,#10
	OUT	(C),A
	LD	C,#1D
	RST	#10
	LD	BC,#7FFD
	SUB	A
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A
	POP	IX
	POP	IY
	POP	BC
	POP	HL
	LD	A,C
	OR	A
	JP	NZ,PutNewM
	JR	FIexitMs
FindFile
	LD	DE,FileName
	LD	A,(FMenuFlg)
	OR	A
	JR	NZ,FindF1
	PUSH	IY
	PUSH	IX
	PUSH	HL
	PUSH	DE
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)
	OUT	(SLOT0),A
	LD	BC,#7FFD
	LD	A,#10
	OUT	(C),A
	SUB	A		
	LD	C,#11		; Open file
	RST	#10
	PUSH	AF
	LD	C,#02
	RST	#10
	LD	HL,FileName
	ADD	A,"A"
	LD	(HL),A
	INC	HL
	LD	(HL),":"
	INC	HL
	LD	C,#1E
	RST	#10
	LD	BC,#7FFD
	SUB	A
	OUT	(C),A
	POP	AF
	EX	AF,AF'
	POP	AF
	OUT	(SLOT0),A
	POP	DE
	POP	HL
	POP	IX
	POP	IY
	EX	AF,AF'
	JR	C,FIexitMs
	LD	(FileHandle),A
	DEC	DE
	INC	DE
	LD	A,(DE)
	OR	A
	JR	NZ,$-3
	DEC	DE
	LD	A,(DE)
	INC	DE
	CP	'\' 
	JR	Z,$+6
	LD	A,'\' 
	LD	(DE),A
	INC	DE
FindF1	LD	A,(HL)
movenam	INC	HL
	CP	#40
	JR	C,$+4
	RES	5,A
	LD	(DE),A
	INC	DE
	LD	A,(HL)
	OR	A
	JR	NZ,movenam
	LD	(DE),A
	LD	HL,what
	LD	A,(HL)
	CP	evCommand
	RET	Z
	LD	(HL),evCommand
	INC	HL
	LD	(HL),cmOkey
	RET 
FIexitMs
	LD	HL,what
	LD	(HL),evMessage
	INC	HL
	LD	(HL),msChangeDR
	CALL	TransMessage
	RET 
;[]===========================================================[]
GetDIR	LD	(IX+#12),#01
	CALL	RsFileBxI
	PUSH	IY
	IN	A,(SLOT0)
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	BC,#7FFD
	LD	A,#10
	OUT	(C),A
	LD	A,(SymbPg1)
	OUT	(SLOT3),A
	LD	A,(DOSpage)
	OUT	(SLOT0),A
	LD	HL,#C000
	LD	(NxtFile+1),HL
	SUB	A
	LD	(IX+#0B),A
	LD	(IX+#0C),A
	LD	(DMflag+1),A
	LD	HL,FileMask
	LD	A,#21
	CALL	FindFiles
	LD	HL,DIRmask
	LD	A,#10
	LD	(DMflag+1),A
	CALL	FindFiles
	LD	HL,(NxtFile+1)
	LD	B,41
	SUB	A
	LD	(HL),A
	INC	HL
	DJNZ	$-2
	LD	(IX+#07),A
	LD	(IX+#08),A
	LD	(IX+#09),A
	LD	(IX+#0A),A
	LD	BC,#7FFD
	OUT	(C),A
	POP	BC
	LD	A,B
	OUT	(SLOT3),A
	LD	A,C
	OUT	(SLOT0),A
	POP	IY
	CALL	PrnFileBox
	LD	A,(IX+#0B)
	OR	(IX+#0C)
	JR	Z,GetDIRe
	BIT	7,(IX+#01)
	PUSH	AF
	CALL	NZ,StFileBxI
	POP	AF
	CALL	Z,HdFileBxI
GetDIRe	CALL	FileBoxBar
	LD	HL,what
	SUB	A
	LD	(HL),evMessage
	INC	HL
	LD	(HL),msPtFileIn
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HL),A
	CALL	TransMessage
	RET 

FindFiles
	LD	DE,ReCompBuff
	LD	BC,#0019
	PUSH	DE
	PUSH	IX
	RST	#10
	POP	IX
	POP	HL
	RET	C
	SUB	A
	LD	(DIRexit+1),A
NxtFile	LD	DE,#0000
	PUSH	HL
	LD	BC,32
	ADD	HL,BC
	LD	B,(HL)
	INC	HL
	LD	A,(HL)
	INC	HL
	LD	C,(HL)
	POP	HL
	CP	"."
	JR	NZ,DMflag
	LD	A,C
	CP	#20
	JR	Z,NxtMovF+4
DMflag	LD	A,#00
	OR	A
	JR	Z,nxtf10
	LD	A,B
	CP	#10
	JR	NZ,NxtMovF+4
nxtf10	PUSH	HL
	LD	BC,33
	ADD	HL,BC
	LD	C,11
	LDIR 
	POP	HL
	LD	C,22
	ADD	HL,BC
	LDI 
	LDI 
	LDI 
	LDI 
	INC	HL
	INC	HL
	LDI 
	LDI 
	LDI 
	LDI 
	LDI 
	INC	(IX+#0B)
	JR	NZ,NxtMovF
	INC	(IX+#0C)
NxtMovF	LD	(NxtFile+1),DE
	LD	DE,ReCompBuff
	LD	BC,#001A
	PUSH	DE
	PUSH	IX
	RST	#10
	POP	IX
	POP	HL
	JP	C,DIRexit
	LD	DE,(NxtFile+1)
	PUSH	HL
	LD	BC,32
	ADD	HL,BC
	LD	B,(HL)
	INC	HL
	LD	A,(HL)
	INC	HL
	LD	C,(HL)
	POP	HL
	CP	"."
	JR	NZ,nxtfl1
	LD	A,C
	CP	"."
	JR	NZ,nxtfl1
	LD	A,#01
	LD	(DIRexit+1),A
	LD	DE,ReCompBuff + #80
	PUSH	HL
	LD	BC,33
	ADD	HL,BC
	LD	C,11
	LDIR 
	POP	HL
	LD	C,22
	ADD	HL,BC
	LDI 
	LDI 
	LDI 
	LDI 
	INC	HL
	INC	HL
	LDI 
	LDI 
	LDI 
	LDI 
	LDI 
	INC	(IX+#0B)
	JR	NZ,NxtMovF+4
	INC	(IX+#0C)
	JR	NxtMovF+4

nxtfl1	LD	A,(DMflag+1)
	OR	A
	JR	Z,nxtfl2
	LD	A,B
	CP	#10
	JR	NZ,NxtMovF
nxtfl2	PUSH	HL
	LD	BC,33
	ADD	HL,BC
	LD	C,11
	LDIR 
	POP	HL
	LD	C,22
	ADD	HL,BC
	LDI 
	LDI 
	LDI 
	LDI 
	INC	HL
	INC	HL
	LDI 
	LDI 
	LDI 
	LDI 
	LDI 
	INC	(IX+#0B)
	JP	NZ,NxtMovF
	INC	(IX+#0C)
	JP	NxtMovF

DIRexit	LD	A,#00
	OR	A
	RET	Z
	LD	HL,ReCompBuff+#80
	LD	DE,(NxtFile+1)
	LD	BC,20
	LDIR 
	LD	(NxtFile+1),DE
	RET 
;[]===========================================================[]
; Event file info
EFileInfo
	LD	HL,what
	LD	A,(HL)
	INC	HL
	CP	evMessage
	RET	NZ
	LD	A,(HL)
	INC	HL
	CP	msGtFileNm
	JR	Z,EFInfo
	CP	msPtFileIn
	RET	NZ
EFInfo	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(CurInfo+1),DE
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	PUSH	IY
	PUSH	IX
	PUSH	IX
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)
	OUT	(SLOT0),A
	LD	C,#02
	RST	#10
	LD	HL,ReCompBuff
	ADD	A,"A"
	LD	(HL),A
	INC	HL
	LD	(HL),":"
	INC	HL
	LD	C,#1E
	RST	#10
	POP	AF
	OUT	(SLOT0),A
	POP	IY
	LD	IX,DialData
	LD	A,(IY+#02)
	SUB	(IX+#00)
	INC	A
	LD	C,A
	LD	A,(IY+#04)
	SUB	(IX+#01)
	LD	B,A
	PUSH	BC
	CALL	GetPutA
	LD	(Finfo1+2),DE
	LD	HL,ReCompBuff
	LD	A,(IY+#03)
	SUB	(IY+#02)
	SUB	#02
	LD	B,A
FilInf1	LD	A,(HL)
	OR	A
	JR	Z,FilInf0
	INC	HL
	LD	(DE),A
	INC	DE
	INC	DE
	DJNZ	FilInf1
	LD	A,B
	OR	A
	JR	Z,PtInfN
FilInf0	LD	A,'\' 
	DEC	HL
	CP	(HL)
	INC	HL
	JR	Z,FilInf2-3
	LD	(DE),A
	INC	DE
	INC	DE
	DEC	B
	JR	Z,PtInfN
	LD	HL,FileMask
FilInf2	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,FilInf3
	LD	(DE),A
	INC	DE
	INC	DE
	DJNZ	FilInf2
	LD	A,B
	OR	A
	JR	Z,PtInfN
FilInf3	LD	A,#20
	LD	(DE),A
	INC	DE
	INC	DE
	DJNZ	$-3
PtInfN
CurInfo	LD	HL,#0000
	ADD	HL,HL
	ADD	HL,HL
	PUSH	HL
	ADD	HL,HL
	ADD	HL,HL
	POP	DE
	ADD	HL,DE
	LD	A,H
	ADD	A,#C0
	LD	H,A
	LD	A,(SymbPg1)
	OUT	(SLOT3),A
	LD	DE,ReCompBuff
	LD	C,20
	LDIR 
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	POP	BC
	INC	B
	CALL	GetPutA
	LD	(Finfo2+2),DE
	LD	HL,ReCompBuff
	LD	A,(HL)
	OR	A
	JR	NZ,EFI
	LD	A,(IY+#03)
	SUB	(IY+#02)
	SUB	#02
	LD	B,A
	LD	A,#20
	LD	(DE),A
	INC	DE
	INC	DE
	DJNZ	$-3
	JR	Finfo1
EFI	PUSH	HL
	LD	BC,#080C
EFI0	LD	A,(HL)
	CP	#20
	JR	Z,EFI1
	INC	HL
	LD	(DE),A
	INC	DE
	INC	DE
	DEC	C
	DJNZ	EFI0
EFI1	LD	A,B
	OR	A
	JR	Z,EFI2-2
	INC	HL
	DJNZ	$-1
	LD	B,#03
EFI2	LD	A,(HL)
	CP	#20
	JR	NZ,EFI3
	INC	HL
	LD	(DE),A
	INC	DE
	INC	DE
	DEC	C
	DJNZ	EFI2
EFI3	LD	A,B
	OR	A
	JR	Z,EndFI
	LD	A,"."
	LD	(DE),A
	INC	DE
	INC	DE
	DEC	C
EFI4	LD	A,(HL)
	INC	HL
	LD	(DE),A
	INC	DE
	INC	DE
	DEC	C
	DJNZ	EFI4
EndFI	LD	A,C
	OR	A
	JR	Z,EndFI1
	LD	B,C
	LD	A,#20
	LD	(DE),A
	INC	DE
	INC	DE
	DJNZ	$-3
EndFI1	INC	DE
	INC	DE
	POP	HL
	PUSH	HL
	LD	C,15
	ADD	HL,BC
	CALL	GetFileLen
	POP	HL
	INC	DE
	INC	DE
	INC	DE
	INC	DE
	LD	BC,11
	ADD	HL,BC
	CALL	GetTimeData
Finfo1	LD	IX,#0000
	LD	E,(IY+#02)
	INC	E
	LD	D,(IY+#04)
	PUSH	DE
	LD	A,(IY+#03)
	SUB	(IY+#02)
	SUB	#02
	LD	L,A
	LD	H,#01
	CALL	PutDialLn
Finfo2	LD	IX,#0000
	POP	DE
	INC	D
	LD	A,(IY+#03)
	SUB	(IY+#02)
	SUB	#02
	LD	L,A
	LD	H,#01
	CALL	PutDialLn
	POP	IX
	POP	IY
	POP	AF
	OUT	(SLOT3),A
	RET 

GetFileLen
	PUSH	IY
	PUSH	HL
	POP	IY
	BIT	4,(IY+#04)
	JP	NZ,PDirectory
	RES	7,(IY+#04)
	LD	L,(IY+#00)
	LD	H,(IY+#01)
	EXX 
	LD	L,(IY+#02)
	LD	H,(IY+#03)
	EXX 
	LD	BC,#CA00
	EXX 
	LD	BC,#3B9A	;1'000'000'000
	EXX 
	CALL	GetLenN32
	LD	BC,#E100
	EXX 
	LD	BC,#05F5	;100'000'000
	EXX 
	CALL	GetLenN32
	LD	BC,#9680
	EXX 
	LD	BC,#0098	;10'000'000
	EXX 
	CALL	GetLenN32
	LD	BC,#4240
	EXX 
	LD	BC,#000F	;1'000'000
	EXX 
	CALL	GetLenN32
	LD	BC,#86A0
	EXX 
	LD	BC,#0001	;100'000
	EXX 
	CALL	GetLenN32
	LD	BC,10000	;10'000
	EXX 
	LD	BC,#0000	;100'000
	EXX 
	CALL	GetLenN32
	LD	BC,1000		;1'000
	CALL	GetLenN16
	LD	BC,100		;100
	CALL	GetLenN16
	LD	BC,10		;10
	CALL	GetLenN16
	LD	A,L
	ADD	A,"0"
	LD	(DE),A
	INC	DE
	INC	DE
	POP	IY
	RET 
GetLenN32
	LD	A,#2F
	OR	A
GetLn32	INC	A
	SBC	HL,BC
	EXX 
	SBC	HL,BC
	EXX 
	JR	NC,GetLn32
	ADD	HL,BC
	EXX 
	ADC	HL,BC
	EXX 
	CP	#30
	JR	Z,$+6
	SET	7,(IY+#04)
	BIT	7,(IY+#04)
	JR	NZ,$+4
	LD	A,#20
	LD	(DE),A
	INC	DE
	INC	DE
	RET 
GetLenN16
	LD	A,#2F
	OR	A
	INC	A
	SBC	HL,BC
	JR	NC,$-3
	ADD	HL,BC
	CP	#30
	JR	Z,$+6
	SET	7,(IY+#04)
	BIT	7,(IY+#04)
	JR	NZ,$+4
	LD	A,#20
	LD	(DE),A
	INC	DE
	INC	DE
	RET 
PDirectory
	INC	DE
	INC	DE
	LD	HL,DirText
	LD	B,#09
	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	INC	DE
	DJNZ	$-5
	POP	IY
	RET 
DirText	DEFB	"DIRECTORY"

GetTimeData
	PUSH	IY
	PUSH	HL
	POP	IY
	EX	DE,HL

	LD	A,(IY+#02)
	AND	#1F		; Internal operation
	CALL	GetData
	LD	(HL),"."
	INC	HL
	INC	HL
	LD	C,(IY+#02)	
	LD	B,(IY+#03)
       DUP     #05
	SRL	B
	RR	C
       EDUP 
	LD	A,C
	AND	#0F
	CALL	GetData
	LD	(HL),"."
	INC	HL
	INC	HL
	LD	A,(IY+#03)	
	SRL	A
	ADD	A,80
	SUB	100
	JR	NC,$+4
	ADD	A,100
	CALL	GetData
	INC	HL
	INC	HL
	INC	HL
	INC	HL

	LD	A,(IY+#01)	
	AND	#F8
	RRA 
	RRA 
	RRA 
	CALL	GetData
	LD	(HL),":"
	INC	HL
	INC	HL
	LD	C,(IY+#00)	
	LD	B,(IY+#01)
       DUP     #05
	SRL	B
	RR	C
       EDUP 
	LD	A,C
	AND	#3F
	CALL	GetData
	EX	DE,HL
	POP	IY
	RET 
GetData	LD	B,#2F
	INC	B
	SUB	10
	JR	NC,$-3
	ADD	A,10
	LD	(HL),B
	INC	HL
	INC	HL
	ADD	A,"0"
	LD	(HL),A
	INC	HL
	INC	HL
	RET 
;[]===========================================================[]
EProcess
	PUSH	IX
	LD	DE,EProcNx	
	PUSH	DE
	LD	L,(IX+#0A)	; Internal operation
	LD	H,(IX+#0B)	
	JP	(HL)
EProcNx	POP	IX
	PUSH	AF
	PUSH	IX
	LD	L,(IX+#08)	
	LD	H,(IX+#09)
	LD	C,(IX+#06)	; Current.position
	LD	B,(IX+#07)
	LD	E,(HL)		; Internal operation
	INC	HL
	LD	D,(HL)
	INC	HL
	PUSH	DE
	POP	IX
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	CALL	Divis32		
	LD	A,LX
	POP	IX
	LD	B,A
	LD	A,(IX+#03)
	SUB	(IX+#02)
	LD	C,A
	CP	B
	LD	A,B
	JR	NC,$+3
	LD	A,C
	SUB	(IX+#05)	
	JP	Z,ProcEx1
	LD	B,A		; Position output
	LD	C,(IX+#05)
	ADD	A,C
	LD	(IX+#05),A	
	LD	A,(IX+#02)	;Xo
	ADD	A,C		; Current.position
	LD	E,A
	LD	D,(IX+#04)	; Current.position
	PUSH	DE
	PUSH	BC
	BIT	7,(IX+#03)	;Xi
	JR	NZ,ProcExt
	BIT	7,E
	JR	Z,proc1
	LD	A,E
	NEG 
	SUB	B
	NEG 
	JR	Z,ProcExt
	JP	M,ProcExt
	LD	B,A
	LD	E,#00
proc1	LD	A,E
	CP	#50
	JR	NC,ProcExt
	ADD	A,B
	CP	#50
	JR	C,proc2
	LD	A,#50
	SUB	E
	LD	B,A
proc2	LD	A,D
	CP	#1F
	JR	NC,ProcExt
	PUSH	IX
	PUSH	BC
	LD	C,#84		
	RST	#10
	POP	BC		; Current

 IF NEW_VERSION
	LD	A,0xDB
 ELSE
	LD	A,"-"
 ENDIF
 
	LD	C,#82
	RST	#10		
	POP	IX
ProcExt	POP	HL		; ()
	POP	BC		
	PUSH	IX
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	LD	IX,DialData
	LD	A,C
	SUB	(IX+#00)
	LD	C,A
	LD	A,B
	SUB	(IX+#01)
	LD	B,A
	CALL	GetPutA
	LD	B,H

 IF NEW_VERSION
	LD	A,0xDB
 ELSE
	LD	A,"-"
 ENDIF
 
	LD	(DE),A
	INC	DE
	INC	DE
	DJNZ	$-3
	POP	AF
	OUT	(SLOT3),A
	POP	IX
ProcEx1	POP	AF
	RET	NC		
	LD	HL,what
	LD	(HL),evCommand
	INC	HL
	LD	(HL),cmOkey
	RET 
;[]===========================================================[]
 _mCollectInfo_addEnd