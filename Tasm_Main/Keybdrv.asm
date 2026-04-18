 _mCollectInfo_addStart
; Scan code driver routine
; Z84.SIO.Ch_A.Ctrl - state:
; 0 = 0 byte not
; 0 = 1 byte
; Z84.SIO.Ch_A.Data - with

KeybDrv:
        OR	A
        JR	Z,InitScanDrv
        DEC	A
        JR	Z,ClearBuff
        DEC	A
        JR	Z,GetKeys
        RET 
	
; COM for ScanCode
InitScanDrv:
	LD	A,#00
	OUT	(Z84.SIO.Ch_A.Ctrl),A
	;
	LD	A,#01
	OUT	(Z84.SIO.Ch_A.Ctrl),A
	LD	A,#00			;#18
	OUT	(Z84.SIO.Ch_A.Ctrl),A
	;
	LD	A,#03
	OUT	(Z84.SIO.Ch_A.Ctrl),A
	LD	A,#C1
	OUT	(Z84.SIO.Ch_A.Ctrl),A
	;
	LD	A,#04
	OUT	(Z84.SIO.Ch_A.Ctrl),A
	LD	A,#05			;#07
	OUT	(Z84.SIO.Ch_A.Ctrl),A
	;
	LD	A,#05
	OUT	(Z84.SIO.Ch_A.Ctrl),A
	LD	A,#60
	OUT	(Z84.SIO.Ch_A.Ctrl),A
	RET 

; Clear keys buffer
ClearBuff:
	LD	HL,KeyBuff
	LD	(BegBuff),HL
	LD	(EndBuff),HL
	LD	B,#20
	SUB	A
	LD	(HL),A
	INC	HL
	DJNZ	$-2
	LD	L,A
	LD	H,L
	LD	(KeyFlag),HL
	RET 

; Get pressed keys from buffer
; Output: z - not pressed
; Nz - pressed:
; H = asciicode
; L = scancode
; De = keyflag
GetKeys:
	DI 
	LD	HL,(BegBuff)
	LD	DE,(KeyFlag)
	LD	BC,(EndBuff)
	LD	A,L
	SUB	C
	JR	Z,GetKeyE
	LD	C,(HL)
	INC	L
	LD	B,(HL)
	INC	L
	LD	A,L
	AND	#1F
	LD	L,A
	LD	(BegBuff),HL
	LD	L,C
	LD	H,B
	LD	A,B
	OR	C
GetKeyE:
	EI 
	RET 

ScanDrv:
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(CnTxtPg)
	OUT	(SLOT2),A
	CALL	GetScan
	POP	AF
	OUT	(SLOT2),A
	RET 

GetScan:
	LD	IX,KeyFlag
	SUB	A
	LD	(KeybFlg+1),A
ScanLp1:
	IN	A,(Z84.SIO.Ch_A.Ctrl)
	RRA 
	RET	NC
	IN	A,(Z84.SIO.Ch_A.Data)
	CP	#E1
	JP	Z,PausBrk
	CP	#E0
	JR	NZ,ScnNxt1
	SET	1,(IX+#02)
	IN	A,(Z84.SIO.Ch_A.Ctrl)
	RRA 
	RET	NC
	IN	A,(Z84.SIO.Ch_A.Data)
ScnNxt1	CP	#F0
	JR	NZ,ScnNxt2
	SET	2,(IX+#02)
	IN	A,(Z84.SIO.Ch_A.Ctrl)
	RRA 
	RET	NC
	IN	A,(Z84.SIO.Ch_A.Data)
ScnNxt2:
	LD	L,A
	LD	H,#00
	ADD	HL,HL
	LD	DE,ScanTbl
	ADD	HL,DE
	BIT	1,(IX+#02)
	JR	Z,$+3
	INC	HL
	LD	C,(HL)
	LD	HL,ScanLp2
	PUSH	HL
	SET	3,(IX+#02)
	LD	A,C
	CP	#1D
	JP	Z,ExmCtrl
	CP	#2A
	JP	Z,LfShift
	CP	#36
	JP	Z,RgShift
	CP	#38
	JP	Z,ExamAlt
	CP	#3A
	JP	Z,CpsLock
	CP	#45
	JP	Z,NumLock
	CP	#46
	JP	Z,ScrLock
	RES	3,(IX+#02)
	CP	#52
	JP	Z,Insert
	CP	#1C
	JP	Z,ExamEnt
	CP	#39
	JP	Z,ExamSpc
	POP	HL
ScanLp2:
	BIT	2,(IX+#02)
	JR	NZ,NxtScan
	BIT	3,(IX+#02)
	JR	NZ,NxtScan
	CALL	GetTabl
	LD	B,#00
	ADD	HL,BC
	ADD	HL,BC
	LD	B,(HL)
	INC	HL
	LD	C,(HL)
	CALL	TestAlt
	LD	A,B
	OR	C
	JR	Z,NxtScan
PutScan:
	LD	HL,(EndBuff)
	LD	DE,(BegBuff)
	LD	A,E
	SUB	L
	AND	#1F
	CP	#1E
	JR	Z,NxtScan
	LD	(HL),C
	INC	L
	LD	(HL),B
	INC	L
	LD	A,L
	AND	#1F
	LD	L,A
	LD	(EndBuff),HL
NxtScan:
	RES	1,(IX+#02)
	RES	2,(IX+#02)
	LD	A,#01
	LD	(KeybFlg+1),A
	LD	(KeyPres+1),A
	JP	ScanLp1

TestAlt:
	BIT	3,(IX+#01)
	JR	NZ,TstAlt0
	BIT	1,(IX+#00)
	JR	NZ,TstAlt0
	LD	A,(NumBuff)
	OR	A
	RET	Z
	JR	TstAlt2
TstAlt0:
	LD	A,C
	CP	120
	RET	C
	CP	130
	RET	NC
	CP	129
	LD	B,#00
	JR	Z,TstAlt1
	SUB	120
	INC	A
	LD	B,A
TstAlt1:
	LD	HL,NumBuff
	INC	(HL)
	LD	C,(HL)
	LD	A,(HL)
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
	LD	(HL),B
	LD	A,C
	CP	#03
	JR	NZ,TstAltE
TstAlt2:
	CALL	GetBufN
	LD	B,C
	LD	A,#00
	LD	(NumBuff),A
	LD	HL,PutScan
	JR	NC,$+5
TstAltE:
	LD	HL,NxtScan
	EX	(SP),HL
	RET 

GetBufN:
	LD	HL,NumBuff
	LD	B,(HL)
	LD	C,#00
GetBfN1:
	INC	HL
	LD	A,C
	ADD	A,A
	LD	C,A
	ADD	A,A
	RET	C
	ADD	A,A
	RET	C
	ADD	A,C
	RET	C
	ADD	A,(HL)
	RET	C
	LD	C,A
	DJNZ	GetBfN1
	RET 

NumBuff:	DEFS	4,0

PausBrk:
	LD	A,(IX+#00)
	XOR	#08
	LD	(IX+#00),A
Paus1:
	IN	A,(Z84.SIO.Ch_A.Ctrl)
	RRA 
	JR	NC,Paus1
	IN	A,(Z84.SIO.Ch_A.Data)
	CP	#77
	RET	Z
	JR	Paus1

; Action with control
ExmCtrl:
	BIT	2,(IX+#02)
	JR	NZ,ResCtrl
	SET	2,(IX+#01)
	BIT	1,(IX+#02)
	RET	NZ
	SET	0,(IX+#00)
	RET 

ResCtrl:
	RES	2,(IX+#01)
	BIT	1,(IX+#02)
	RET	NZ
	RES	0,(IX+#00)
	RET 

; Action with alt
ExamAlt:
	BIT	2,(IX+#02)
	JR	NZ,ResAlt
	SET	3,(IX+#01)
	BIT	1,(IX+#02)
	RET	NZ
	SET	1,(IX+#00)
	RET 

ResAlt:
	RES	2,(IX+#02)
	RES	3,(IX+#02)
	RES	3,(IX+#01)
	BIT	1,(IX+#02)
	RET	NZ
	RES	1,(IX+#00)
	RET 

; Action with shift
LfShift:
	BIT	2,(IX+#02)
	JR	NZ,ResLsh
	SET	1,(IX+#01)
	JR	ExamRus

ResLsh:
	RES	1,(IX+#01)
	JR	ExamRus

RgShift	BIT	2,(IX+#02)
	JR	NZ,ResRsh
	SET	0,(IX+#01)
	JR	ExamRus

ResRsh:
	RES	0,(IX+#01)

ExamRus:
	LD	A,(IX+#01)	; Test by leftshift+rghtshift
	AND	#03		; (rus mode)
	CP	#03
	RET	NZ
	LD	A,(IX+#00)
	XOR	#04
	LD	(IX+#00),A
ExmRus1:
	BIT	2,A
	LD	HL,Rtxt
	JR	NZ,$+5
	LD	HL,Etxt
	LD	DE,TextBuff-3
	PUSH	DE
	LDI 
	LDI 
	LDI 
	LD	DE,#004D
	LD	C,#84
	CALL	Rst10t
	POP	HL
	LD	BC,#0386
	CALL	Rst10t
	RET 

Rtxt:	DEFB	"rus"
Etxt:	DEFB	"   "

ExamEnt:
	LD	A,(IX+#01)
	AND	#03
	RET	Z
	RES	2,(IX+#00)
	SET	3,(IX+#02)
	LD	A,(IX+#00)
	JR	ExmRus1

ExamSpc:
	LD	A,(IX+#01)
	AND	#03
	RET	Z
	SET	2,(IX+#00)
	SET	3,(IX+#02)
	LD	A,(IX+#00)
	JR	ExmRus1

Insert:
	LD	A,(IX+#00)
	AND	#03
	RET	NZ
	LD	A,(IX+#01)
	AND	#0F
	RET	NZ
	SET	3,(IX+#02)
	BIT	2,(IX+#02)
	JR	Z,Insert1
	RES	7,(IX+#00)
	RET 

Insert1:
	SET	7,(IX+#00)
	LD	A,(IX+#01)
	XOR	#80
	LD	(IX+#01),A
	LD	A,(InsertMode)
	XOR	#01
	LD	(InsertMode),A
	RET 

CpsLock:
	BIT	2,(IX+#02)
	JR	Z,CpsLoc1
	RES	6,(IX+#00)
	RET 

CpsLoc1:
	SET	6,(IX+#00)
	LD	A,(IX+#01)
	XOR	#40
	LD	(IX+#01),A
	RET 

NumLock:
	BIT	2,(IX+#02)
	JR	Z,NumLoc1
	RES	5,(IX+#00)
	RET 

NumLoc1:
	SET	5,(IX+#00)
	LD	A,(IX+#01)
	XOR	#20
	LD	(IX+#01),A
	RET 

ScrLock:
	BIT	2,(IX+#02)
	JR	Z,ScrLoc1
	RES	4,(IX+#00)
	RET 

ScrLoc1:
	SET	4,(IX+#00)
	LD	A,(IX+#01)
	XOR	#10
	LD	(IX+#01),A
	RET 

GetTabl:
	LD	HL,AltTabl	; Alt+ table
	BIT	3,(IX+#01)
	RET	NZ
	LD	HL,CtrlTab	; Ctrl+ table
	BIT	2,(IX+#01)
	RET	NZ
	BIT	2,(IX+#00)
	JR	NZ,RusTabl

	LD	HL,ASCItb1	; Ascii small char table
	BIT	6,(IX+#01)
	JR	Z,$+5
	LD	HL,ASCItb2	; Ascii big char table
	LD	A,(IX+#01)
	AND	#03
	RET	Z
	LD	HL,ShftTb1	; Shift small char table
	BIT	6,(IX+#01)
	RET	NZ
	LD	HL,ShftTb2	; Shift big char table
	RET 

RusTabl:
	LD	A,(KeyPad)
	OR	A
	JR	NZ,RusTbl1
	LD	HL,ASCrus1	; Ascii small char table
	BIT	6,(IX+#01)
	JR	Z,$+5
	LD	HL,ASCrus2	; Ascii big char table
	LD	A,(IX+#01)
	AND	#03
	RET	Z
	LD	HL,Shfrus1	; Shift small char table
	BIT	6,(IX+#01)
	RET	NZ
	LD	HL,Shfrus2	; Shift big char table
	RET 
; Internal operation
RusTbl1:
	LD	HL,ASCRUS1	; Ascii small char table
	BIT	6,(IX+#01)
	JR	Z,$+5
	LD	HL,ASCRUS2	; Ascii big char table
	LD	A,(IX+#01)
	AND	#03
	RET	Z
	LD	HL,ShfRUS1	; Shift small char table
	BIT	6,(IX+#01)
	RET	NZ
	LD	HL,ShfRUS2	; Shift big char table
	RET 

BegBuff:	DEFW	KeyBuff
EndBuff:	DEFW	KeyBuff

KeyFlag:	DEFB #00	; Press or not press
; D7-insert
; D6-caps lock
; D5-num lock
; D4-scroll lock
; D3-pause flag
; D2-sys reg
; D1-left alt
; D0-left ctrl
	DEFB #00	; Current lock
; D7-insert
; D6-caps lock
; D5-num lock
; D4-scroll lock
; D3-alt
; D2-ctrl
; D1-left shift
; D0-right shift
	DEFB #00	;Flag
; D0-rus/lat table
; D1-upgrade code
; D2-otjata
;
 _mCollectInfo_addEnd