 _mCollectInfo_addStart
;[]===========================================================[]
; Function - Replace
ReplTxt	SUB	A
	LD	(FoundFlg),A
	LD	(ReplAfl+1),A
	INC	A
	LD	(ReplFlg+1),A
	LD	HL,Dreplac
	CALL	DialogW
	LD	HL,what		; Field events
	LD	A,(HL)
	LD	(HL),evNothing
	INC	HL
	CP	evCommand
	RET	NZ
	LD	A,(HL)		; Window by command Cancel
	CP	cmCancel
	RET	Z
	CP	cmOkey
	JR	Z,Search
	LD	A,#01
	LD	(ReplAfl+1),A
	JR	Search
;[]===========================================================[]
; Function - Find
; Procedure search in
FindTxt	SUB	A
	LD	(FoundFlg),A
	LD	(ReplFlg+1),A
	LD	(ReplAfl+1),A
	LD	HL,Dfind	; Window
	CALL	DialogW
	LD	HL,what		; Field events
	LD	A,(HL)
	LD	(HL),evNothing
	INC	HL
	CP	evCommand
	RET	NZ
	LD	A,(HL)		; Window by command Cancel
	CP	cmCancel
	RET	Z		; Exit
Search	CALL	InitFind	; Search
NxtSrch	CALL	OnlySyntax	; Syntax-highlight last line
	CALL	PutString	; Insert it in text
	CALL	ResCurs		; Disable cursor
	LD	A,(FBackward)	; Search
	OR	A
	JP	NZ,FindBckwrd	; Search by to
;[]===========================================================[]
; Procedure search by to text
FindFrwrd
	SUB	A
	LD	(DirectF+1),A
	LD	HL,#8040	; Start TAS
	LD	C,A		; Number
	LD	B,C
	LD	E,A		; Offset by X
	LD	A,(FFromCur)
	OR	A		; 0 - search text
	JR	Z,EntScop
	LD	HL,(BegString)	; Current. TAS
	LD	BC,(CurLine)	; Number current
	LD	A,(IY+#00)	;Xcurs
	ADD	A,(IY+#07)	;Xadd
	INC	A
	LD	E,A		; Offset by X
EntScop	LD	A,E
	LD	(BeginAddX),A	; Offset by X from start
	LD	(BeginFind),HL	; For search
	LD	E,#00
	LD	L,E		; Nop
	LD	H,L
	LD	A,(CaseSenset)
	OR	A		; NZ and
	JR	NZ,YsCase1
	LD	HL,CorrChar
	LD	E,#CD
YsCase1	LD	A,E
	LD	(CrCall1),A
	LD	(CrCall1+1),HL
	LD	A,(LabelOnly)
	OR	A
	JR	Z,FindFr1
	LD	A,(BeginAddX)
	OR	A
	JR	Z,FindFr0
	SUB	A
	LD	(BeginAddX),A
	LD	HL,(BeginFind)
	LD	E,(HL)
	LD	D,A
	ADD	HL,DE
	LD	(BeginFind),HL
FindFr0	LD	HL,FLNxtStr
	LD	A,(FGlobal)
	OR	A
	JR	NZ,FindFr2
	LD	HL,FLNxtStrS
	JR	FindFr2
FindFr1	LD	HL,FNextStr
	LD	A,(FGlobal)
	OR	A
	JR	NZ,$+5
	LD	HL,FNextStrS
FindFr2	LD	(Fnxtcl1+1),HL
	LD	(Fnxtcl2+1),HL
	DEC	BC
Fnxtcl1	CALL	#0000
	JP	C,NotFound
	LD	DE,ReCompBuff+#FF ; Internal operation
	LD	A,(BeginAddX)	; Offset from start
	ADD	A,E
	LD	E,A
FndForw
	LD	HL,FuncBuffer+#FF ; With search
FndFrw1	INC	L
	INC	E
	LD	A,(HL)
	OR	A		; 0 - search
	JP	Z,FoundStr	; Line
	LD	A,(DE)
	OR	A		; 0 - current
	JR	NZ,FndFrw2
Fnxtcl2	CALL	#0000		; Procedure search next.page
	JP	C,NotFound	; CY - text
	LD	DE,ReCompBuff+#FF ; Start
	JR	FndForw
FndFrw2	LD	A,(DE)
CrCall1	CALL	CorrChar
	CP	(HL)		; Internal operation
	JR	Z,FndFrw1	;=
	JR	FndForw		;<>
; Procedure next. in -All text
FNextStr			; For text
	LD	HL,(BeginFind)	; Search next.line
	LD	A,(HL)
	OR	A
	JR	NZ,DeCompS
	SCF			; CY - text
	RET 
FNextStrS			; For lines
	LD	HL,(BeginFind)	; Current. search
	LD	D,#00
FNxtSS1	LD	A,(HL)
	OR	A
	SCF 
	RET	Z
	INC	HL
	BIT	6,(HL)		; 6 - selection
	DEC	HL
	JR	NZ,DeCompS	; Internal operation
	SUB	A
	LD	(BeginAddX),A	; Offset. by X = 0
	LD	E,(HL)		; Internal operation
	ADD	HL,DE
	INC	BC
	JR	FNxtSS1
; Procedure decompilation TAS in TXT line
DeCompS	INC	BC
	PUSH	BC
	LD	DE,CompBuff	; For decompilation
	LD	C,(HL)		; Internal operation
	LD	B,E
	LDIR			; Copy
	LD	(BeginFind),HL	; Next
	IN	A,(SLOT2)		; Save. 2 and 3 pages
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,(CnTxtPg)	; Program conversion
	OUT	(SLOT2),A
	LD	A,(AsmTabPg)	; Table Z80 commands
	OUT	(SLOT3),A
	CALL	ConvDeComp	; TAS line in TXT
	POP	BC
	LD	A,B
	OUT	(SLOT3),A		; Restore. 2 and 3 pages
	LD	A,C
	OUT	(SLOT2),A
	LD	A,#02
	RST	#30		; Check Key Buffer
	POP	BC
	RET	Z		; Not
	LD	A,L
	DEC	A		; Be 1
	RET	NZ
	LD	A,H
	CP	#1B		; #1b escape
	JP	Z,BreakPush
	OR	A
	RET 
; Procedure next. in -Labels only
FLNxtStr			; For in
	LD	HL,(BeginFind)	; Search next.line
	LD	D,#00
FLNxSS1	LD	A,(HL)
	OR	A
	SCF			; CY - text
	RET	Z
	INC	HL
	BIT	0,(HL)		; Labels
	DEC	HL
	JR	NZ,DeCompL	; Internal operation
	LD	E,(HL)		; Internal operation
	ADD	HL,DE
	INC	BC
	JR	FLNxSS1
FLNxtStrS			; For in
	LD	HL,(BeginFind)	; Current. search
	LD	D,#00
FLNSSS1	LD	A,(HL)
	OR	A
	SCF 
	RET	Z
	INC	HL
	BIT	6,(HL)		; 6 - selection
	DEC	HL
	JR	Z,FLNSSS2	; Not
	INC	HL
	BIT	0,(HL)		; 0 - labels
	DEC	HL
	JR	NZ,DeCompL
FLNSSS2	LD	E,(HL)		; Internal operation
	ADD	HL,DE
	INC	BC
	JR	FLNSSS1
; Procedure decompilation labels
DeCompL	INC	BC
	PUSH	BC
	LD	DE,ReCompBuff	; For decompilation
	LD	A,(HL)
	LD	C,A
	SUB	#03
	JR	Z,DeCmpL2+1
	LD	B,A
	PUSH	HL
	INC	HL
	INC	HL
DeCmpL1	LD	A,(HL)
	CP	#20
	JR	C,DeCmpL2
	CP	";"
	JR	Z,DeCmpL2
	LD	(DE),A
	INC	HL
	INC	E
	DJNZ	DeCmpL1
DeCmpL2	POP	HL
	SUB	A
	LD	(DE),A
	LD	B,A
	ADD	HL,BC
	LD	(BeginFind),HL	; Next
	LD	A,#02
	RST	#30		; Check Key Buffer
	POP	BC
	RET	Z		; Not
	LD	A,L
	DEC	A		; Be 1
	RET	NZ
	LD	A,H
	CP	#1B		; #1b escape
	JP	Z,BreakPush
	OR	A
	RET 
;[]===========================================================[]
; Procedure search by to text
FindBckwrd
	LD	A,#01
	LD	(DirectF+1),A
	LD	HL,(EndText)	; TAS
	LD	BC,(EquipLn)	; Count-in lines
	LD	E,#FF		; Offset by X
	LD	A,(FFromCur)
	OR	A		; 0 - search text
	JR	Z,EntScp1
	LD	HL,(BegString)	; Current. TAS
	LD	E,(HL)
	LD	D,#00
	ADD	HL,DE
	LD	BC,(CurLine)	; Number current
	INC	BC
	LD	A,(IY+#00)	;Xcurs
	ADD	A,(IY+#07)	;Xadd
	LD	E,A		; Offset by X
EntScp1	LD	A,E
	LD	(BeginAddX),A	; Offset by X from start
	LD	(BeginFind),HL	; For search
	LD	E,#00
	LD	L,E		; Nop
	LD	H,L
	LD	A,(CaseSenset)
	OR	A		; NZ and
	JR	NZ,YsCase2
	LD	HL,CorrChar
	LD	E,#CD
YsCase2	LD	A,E
	LD	(CrCall2),A
	LD	(CrCall2+1),HL
	LD	A,(LabelOnly)
	OR	A
	JR	Z,FindBk1
	LD	HL,FLPrvStr
	LD	A,(FGlobal)
	OR	A
	JR	NZ,FindBk2
	LD	HL,FLPrvStrS
	JR	FindBk2
FindBk1	LD	HL,FPrevStr
	LD	A,(FGlobal)
	OR	A
	JR	NZ,$+5
	LD	HL,FPrevStrS
FindBk2	LD	(Fprvcl1+1),HL
	LD	(Fprvcl2+1),HL
Fprvcl1	CALL	#0000
	JP	C,NotFound
	LD	A,(BeginAddX)	; Offset from start
	CP	E
	JR	NC,$+3
	LD	E,A
FndBack
findend	LD	HL,#0000	; Buffers with search
FndBck1	DEC	L
	DEC	E
	LD	A,(HL)
	OR	A		; 0 - search
	JP	Z,FoundStr	; Line
	LD	A,(DE)
	OR	A		; 0 - current
	JR	NZ,FndBck2
Fprvcl2	CALL	#0000		; Procedure search next.page
	JP	C,NotFound	; CY - text
	JR	FndBack
FndBck2	LD	A,(DE)
CrCall2	CALL	CorrChar
	CP	(HL)		; Internal operation
	JR	Z,FndBck1	;=
	JR	FndBack		;<>
; Procedure. in -All text
FPrevStr			; For text
	LD	HL,(BeginFind)	; Search.line
	DEC	HL
	LD	A,(HL)
	OR	A
	SCF 
	RET	Z
	DEC	A
	LD	E,A
	LD	D,#00
	OR	A
	SBC	HL,DE
	DEC	BC
	JR	ReCompS
FPrevStrS			; For lines
	LD	HL,(BeginFind)	; Current. search
	LD	D,#00
FPrvSS1	DEC	HL
	LD	A,(HL)
	OR	A
	SCF 
	RET	Z
	DEC	A
	LD	E,A
	OR	A
	SBC	HL,DE
	DEC	BC
	INC	HL
	BIT	6,(HL)
	DEC	HL
	JR	NZ,ReCompS
	LD	A,#FF
	LD	(BeginAddX),A	; Offset. by X = 0
	JR	FPrvSS1		; Internal operation
; Procedure decompilation TAS in TXT line
ReCompS	PUSH	BC
	LD	(BeginFind),HL	; Internal operation
	LD	DE,CompBuff	; For decompilation
	LD	C,(HL)		; Internal operation
	LD	B,E
	LDIR			; Copy
	IN	A,(SLOT2)		; Save. 2 and 3 pages
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,(CnTxtPg)	; Program conversion
	OUT	(SLOT2),A
	LD	A,(AsmTabPg)	; Table Z80 commands
	OUT	(SLOT3),A
	CALL	ConvDeComp	; TAS line in TXT
	POP	BC
	LD	A,B
	OUT	(SLOT3),A		; Restore. 2 and 3 pages
	LD	A,C
	OUT	(SLOT2),A
	PUSH	HL		; Buffers
	LD	A,#02
	RST	#30		; Check Key Buffer
	POP	DE		; DE - buffers
	POP	BC
	RET	Z		; Not
	LD	A,L
	DEC	A		; Be 1
	RET	NZ
	LD	A,H
	CP	#1B		; #1b escape
	JP	Z,BreakPush
	OR	A
	RET 
; Procedure next. in -Labels only
FLPrvStr			; For in
	LD	HL,(BeginFind)	; Search next.line
	LD	D,#00
FLPrSS1	DEC	HL
	LD	A,(HL)
	OR	A
	SCF 
	RET	Z
	DEC	A
	LD	E,A
	OR	A
	SBC	HL,DE
	DEC	BC
	INC	HL
	BIT	0,(HL)		; Labels
	DEC	HL
	JR	NZ,ReCompL	; Internal operation
	LD	A,#FF
	LD	(BeginAddX),A	; Offset. by X = 0
	JR	FLPrSS1
FLPrvStrS			; For in
	LD	HL,(BeginFind)	; Current. search
	LD	D,#00
FLPSSS1	DEC	HL
	LD	A,(HL)
	OR	A
	SCF 
	RET	Z
	DEC	A
	LD	E,A		; Internal operation
	OR	A
	SBC	HL,DE
	DEC	BC
	INC	HL
	BIT	6,(HL)		; 6 - selection
	DEC	HL
	JR	Z,FLPSSS2	; Not
	INC	HL
	BIT	0,(HL)		; 0 - labels
	DEC	HL
	JR	NZ,ReCompL
FLPSSS2	LD	A,#FF
	LD	(BeginAddX),A	; Offset. by X = 0
	JR	FLPSSS1
; Procedure decompilation labels
ReCompL	PUSH	BC
	LD	(BeginFind),HL	; Internal operation
	LD	DE,ReCompBuff	; For decompilation
	LD	A,(HL)
	SUB	#03
	JR	Z,ReCmpL2+1
	LD	B,A
	INC	HL
	INC	HL
ReCmpL1	LD	A,(HL)
	CP	#20
	JR	C,ReCmpL2
	CP	";"
	JR	Z,ReCmpL2
	LD	(DE),A
	INC	HL
	INC	E
	DJNZ	ReCmpL1
ReCmpL2	SUB	A
	LD	(DE),A
	PUSH	DE
	LD	A,#02
	RST	#30		; Check Key Buffer
	POP	DE
	POP	BC
	RET	Z		; Not
	LD	A,L
	DEC	A		; Be 1
	RET	NZ
	LD	A,H
	CP	#1B		; #1b escape
	JP	Z,BreakPush
	OR	A
	RET 
	RET 
;[]===========================================================[]
; Procedure to
CorrChar
	CP	#61
	RET	C
	CP	#7B
	JR	NC,CorrCh1
	RES	5,A
	RET 
CorrCh1	CP	#A0
	RET	C
	CP	#B0
	JR	NC,CorrCh2
	RES	5,A
	RET 
CorrCh2	CP	#E0
	RET	C
	CP	#F0
	JR	NC,CorrCh3
	SUB	#50
	RET 
CorrCh3	CP	#F2
	RET	NC
	RES	0,A
	RET 
;[]===========================================================[]
; Procedure copy search in
InitFind		; Copy line in
	LD	HL,FindBuf+4	; Internal operation
	LD	DE,FuncBuffer	; Internal operation
	LD	A,(HL)		; Internal operation
	INC	HL
	OR	A
	JR	Z,CopySpc	; 0
	LD	B,A
	LD	A,(CaseSenset)	; Z - with
	OR	A
	JR	NZ,CopyFndN
CopyFnd0			; Without.and
	LD	A,(HL)
	CALL	CorrChar	; Internal operation
	LD	(DE),A
	INC	HL
	INC	E
	DJNZ	CopyFnd0
	JR	CopyEnd		; 0 - search
CopyFndN
	LD	C,B		; With.and
	LD	B,#00
	LDIR 
CopyEnd	LD	(findend+1),DE
CopySpc	SUB	A		; 0 - search
	LD	(DE),A
	LD	(FuncBuffer-1),A
	LD	(ReCompBuff-1),A
	RET 
;[]===========================================================[]
FindBuf	DEFB	120	;Max input symbols
	DEFB	#00	; Readystring
	DEFB	#00	; Pos x
	DEFB	#00	; Add x
	DEFB	#00	; Inp.symb
	DEFS	120,0

ReplBuf	DEFB	120	;Max input symbols
	DEFB	#00	; Readystring
	DEFB	#00	; Pos x
	DEFB	#00	; Add x
	DEFB	#00	; Inp.symb
	DEFS	120,0

FoundFlg
	DEFB	#00
BeginFind
	DEFW	#0000
BeginAddX
	DEFB	#00
CaseSenset
	DEFB	#01
WordOnly
	DEFB	#00
PromtRepl
	DEFB	#01
FForward
	DEFB	#01
FBackward
	DEFB	#00
FGlobal
	DEFB	#01
FSelText
	DEFB	#00
FFromCur
	DEFB	#00
FEntScope
	DEFB	#01
LabelOnly
	DEFB	#00
;[]===========================================================[]
NotFound
	CALL	PrintPage
	LD	A,(ReplFlg+1)
	OR	A
	JR	Z,NtFound
	LD	A,(ReplAfl+1)
	OR	A
	JR	Z,NtFound
	LD	A,(FoundFlg)
	OR	A
	RET	NZ
NtFound	LD	HL,Dnotfnd
	JP	DialogW
;[]===========================================================[]
BreakPush
	POP	HL
	JP	PrintPage
;[]===========================================================[]
FoundStr
	LD	A,(WordOnly)
	OR	A
	JR	Z,ReplFlg
	LD	IX,FndForw
	LD	A,(DirectF+1)
	OR	A
	JR	Z,$+6
	LD	IX,FndBack
	PUSH	DE
	LD	A,E
	SUB	L
	LD	E,A
	DEC	DE
	LD	A,(DE)
	CALL	CorrChar
	POP	DE
	CP	#30
	JR	C,WordOk
	CP	#3A
	JR	C,WordNo
	CP	#40
	JR	C,WordOk
	CP	#5B
	JR	C,WordNo
	CP	#80
	JR	C,WordOk
	CP	#A0
	JR	C,WordNo
	CP	#F0
	JR	NZ,WordNo
WordOk	LD	A,(DE)
	CALL	CorrChar
	CP	#30
	JR	C,ReplFlg
	CP	#3A
	JR	C,WordNo
	CP	#40
	JR	C,ReplFlg
	CP	#5B
	JR	C,WordNo
	CP	#80
	JR	C,ReplFlg
	CP	#A0
	JR	C,WordNo
	CP	#F0
	JR	Z,ReplFlg
WordNo	JP	(IX)

ReplFlg	LD	A,#00
	OR	A
	JR	NZ,Replace
Found	LD	(IY+#07),#00
	LD	A,E
	SUB	L
	LD	D,A
	SUB	(IY+#05)
	JR	C,Found1
Found0	LD	E,A
	LD	A,(IY+#07)
	ADD	A,Step
	LD	(IY+#07),A
	LD	(IY-#02),A
	LD	A,E
	SUB	Step
	JR	NC,Found0
Found1	LD	A,D
	SUB	(IY+#07)
	LD	(IY+#00),A	; Position
	LD	(IY-#01),A	; Position
	LD	HL,(BeginFind)
DirectF	LD	A,#00
	OR	A
	JR	NZ,NoSub
	DEC	HL
	LD	E,(HL)
	INC	HL
	LD	D,#00
	SBC	HL,DE
NoSub	LD	(BegString),HL
	LD	(CurLine),BC
	LD	B,(IY+#06)
	SRL	B
	SRL	B
	LD	C,#00
	LD	D,C
	JR	Z,Found3
Found2	DEC	HL
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,Found3
	LD	E,A
	SBC	HL,DE
	INC	C
	DJNZ	Found2
Found3	LD	(IY+#01),C
	LD	(AdrPage),HL
	LD	HL,(CurLine)
	LD	B,D
	OR	A
	SBC	HL,BC
	LD	(UpLinePg),HL
	CALL	PrintPage
	CALL	PrintInfo
	RET 
; Procedure
Replace	LD	A,#01
	LD	(FoundFlg),A
	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	A,E		; ()
	SUB	L		; Search
	LD	E,A		; Start search
	LD	(svDE1+1),DE
	LD	HL,(BeginFind)
	LD	A,(DirectF+1)
	OR	A
	JR	NZ,NoSub1
	DEC	HL
	LD	E,(HL)
	INC	HL
	LD	D,#00
	SBC	HL,DE
NoSub1	LD	(BegString),HL
	LD	A,(PromtRepl)	; Flag output.window
	OR	A
	JR	Z,Replac0	; 0 - not
	POP	BC
	POP	DE
	POP	HL
	PUSH	HL
	PUSH	DE
	PUSH	BC
	CALL	Found
	LD	A,(svDE1+1)
	LD	E,A
	LD	D,#00
	LD	HL,TextBuff
	ADD	HL,DE		; Line in
	ADD	HL,DE		; Buffer
	LD	A,(findend+1)	; Internal operation
	OR	A
	JR	Z,Repl0
	LD	B,A		; Line
	LD	A,(ColReplTxt)
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-3
	CALL	PrintS		; On screen
Repl0	LD	HL,DpromtR
	CALL	DialogW
	CALL	Syntax		; Line
	LD	HL,what		; Field events
	LD	(HL),evNothing
	INC	HL
	LD	A,(HL)		; Window by command Cancel
	CP	cmCancel
	POP	BC
	POP	DE
	POP	HL
	RET	Z
	PUSH	HL
	PUSH	DE
	PUSH	BC
	CP	cmYes
	SCF 
	JP	NZ,ReplAll
Replac0	LD	HL,(BegString)	; Internal operation
	LD	DE,CompBuff	; For decompilation
	LD	C,(HL)		; Internal operation
	LD	B,E
	LDIR			; Copy
	IN	A,(SLOT2)		; Save. 2 and 3 pages
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,(CnTxtPg)	; Program conversion
	OUT	(SLOT2),A
	LD	A,(AsmTabPg)	; Table Z80 commands
	OUT	(SLOT3),A
	CALL	ConvDeComp	; TAS line in TXT
	LD	A,L
	LD	(ReCmpLn+1),A
	POP	BC
	LD	A,B
	OUT	(SLOT3),A		; Restore. 2 and 3 pages
	LD	A,C
	OUT	(SLOT2),A
	LD	HL,ReCompBuff
	LD	DE,TextBuff
	LD	C,#F0
	LD	A,(svDE1+1)
	OR	A
	JR	Z,Replac1
	LD	B,A
Repl1	LD	A,(HL)
	LD	(DE),A
	INC	DE
	INC	DE
	INC	L
	DEC	C
	DJNZ	Repl1
	LD	A,C
	OR	A
	JR	Z,Replac2-1
Replac1	LD	A,(ReplBuf+4)
	OR	A
	JR	Z,Repl22
	LD	B,A
	LD	HL,ReplBuf+5
Repl2	LD	A,(HL)
	LD	(DE),A
	INC	DE
	INC	DE
	INC	HL
	DEC	C
	JR	Z,Replac2
	DJNZ	Repl2
Repl22	LD	HL,(svDE1+1)
	LD	A,(findend+1)
	ADD	A,L
	LD	L,A
ReCmpLn	LD	A,#00
	SUB	L
	JR	Z,Replac2+1
	LD	B,A
Repl3	LD	A,(HL)
	LD	(DE),A
	INC	DE
	INC	DE
	INC	L
	DEC	C
	JR	Z,Replac2
	DJNZ	Repl3
Replac2	SUB	A
	LD	(DE),A
	LD	A,#F0
	SUB	C
	LD	(IY+#02),A	; Page
	LD	A,#50		; Max len x
	ADD	A,(IY+#07)
	SUB	(IY+#02)
	JR	C,Replac3
	JR	Z,Replac3
	EX	DE,HL
	LD	B,A
	LD	A,(ColTxtWin)
	LD	C,A
	SUB	A
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
Replac3	LD	A,(PromtRepl)
	OR	A
	PUSH	AF
	CALL	Z,OnlySyntax
	POP	AF
	CALL	NZ,Syntax
	CALL	PutString
	LD	A,(DirectF+1)
	OR	A
	JR	NZ,$+5
	LD	(BeginFind),HL
	XOR	A
	LD	(ReadyFile),A
	LD	A,(PromtRepl)
	OR	A
	PUSH	AF
	CALL	Z,PrintInfo+4
	POP	AF
	CALL	NZ,PrintInfo
ReplAll	POP	BC
	POP	DE
	POP	HL
	EX	AF,AF'
ReplAfl	LD	A,#00
	OR	A
	JP	Z,Found
	EX	AF,AF'
	PUSH	AF
	PUSH	BC
	CALL	ResCurs
	LD	HL,(BegString)
	LD	A,(DirectF+1)
	OR	A
	JR	NZ,NoAdd1
	LD	E,(HL)
	LD	D,A
	ADD	HL,DE
	LD	(BeginFind),HL
NoAdd1	LD	HL,TextBuff
	LD	DE,ReCompBuff
	LD	A,(IY+#02)
	OR	A
	JR	Z,Replac4
	LD	B,A
	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	HL
	INC	E
	DJNZ	$-5
	SUB	A
Replac4	LD	(DE),A
	POP	BC
	POP	AF
	EX	AF,AF'
	LD	HL,FndBack
svDE1	LD	DE,#0000
	LD	A,(DirectF+1)
	OR	A
	JR	NZ,jpHL
	LD	HL,FndForw
	EX	AF,AF'
	LD	A,(ReplBuf+4)
	JR	NC,$+5
	LD	A,(FindBuf+4)
	ADD	A,E
	JR	C,$+6
	CP	#F1
	JR	C,$+4
	LD	A,#F0
	LD	E,A
	DEC	E
jpHL	JP	(HL)
;[]===========================================================[]
; Function - Search again
NextSearch
	LD	HL,(BeginFind)
	LD	A,H
	OR	L
	RET	Z
	SUB	A
	LD	(FoundFlg),A
	LD	A,(FFromCur)
	PUSH	AF
	LD	A,#01
	LD	(FFromCur),A
	CALL	NxtSrch
	POP	AF
	LD	(FFromCur),A
	RET 
;[]===========================================================[]
; Function - Go to line number
GoToLine
	CALL	OnlySyntax	; Syntax-highlight last line
	CALL	PutString	; Insert it in text
	LD	HL,LineBuf+5
	PUSH	HL
	LD	B,#06
	SUB	A
	LD	(HL),A
	INC	HL
	DJNZ	$-2
	POP	IX
	LD	HL,(CurLine)
	INC	HL
	CALL	Put16Num
	LD	A,B
	LD	(LineBuf+4),A
	LD	HL,Dgotoln
	CALL	DialogW
	LD	HL,what
	LD	A,(HL)
	LD	(HL),evNothing
	INC	HL
	CP	evCommand
	RET	NZ
	LD	A,(HL)
	CP	cmCancel
	RET	Z
	CALL	ResCurs
	LD	HL,LineBuf+4
	LD	C,(HL)
	INC	HL
	PUSH	HL
	LD	B,#00
	ADD	HL,BC
	LD	(HL),B
	POP	DE
	CALL	Get16Num
	RET	C
	LD	A,H
	OR	L
	JR	NZ,$+3
	INC	L
	LD	DE,(EquipLn)
	PUSH	HL
	SBC	HL,DE
	POP	HL
	JR	C,GoTo1
	JR	Z,GoTo1
	EX	DE,HL
GoTo1	DEC	HL
	LD	C,L
	LD	B,H
	LD	(CurLine),HL
	LD	HL,#8040
	LD	D,#00
	LD	A,B
	OR	C
	JR	Z,GoTo3
GoTo2	LD	E,(HL)
	ADD	HL,DE
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,GoTo2
GoTo3	LD	(BegString),HL
	LD	B,(IY+#06)
	SRL	B
	SRL	B
	JR	Z,GoTo5
GoTo4	DEC	HL
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,GoTo5
	LD	E,A
	SBC	HL,DE
	INC	C
	DJNZ	GoTo4
GoTo5	LD	(IY+#01),C
	LD	(AdrPage),HL
	LD	HL,(CurLine)
	LD	B,D
	OR	A
	SBC	HL,BC
	LD	(UpLinePg),HL
	SUB	A
	LD	(IY-#02),A
	LD	(IY-#01),A
	LD	(IY+#00),A
	LD	(IY+#07),A
	CALL	PrintPage
	CALL	PrintInfo
	RET 
Put16Num
	LD	BC,#0000
	LD	DE,10000	;1'000
	CALL	GetDecNum
	LD	DE,1000		;1'000
	CALL	GetDecNum
	LD	DE,100		;100
	CALL	GetDecNum
	LD	DE,10		;10
	CALL	GetDecNum
	LD	A,L
	ADD	A,"0"
	LD	(IX+#00),A
	INC	B
	RET 
GetDecNum
	LD	A,#2F
	OR	A
	INC	A
	SBC	HL,DE
	JR	NC,$-3
	ADD	HL,DE
	CP	#30
	JR	Z,$+4
	SET	0,C
	BIT	0,C
	RET	Z
	LD	(IX+#00),A
	INC	IX
	INC	B
	RET 
Get16Num
	LD	HL,#0000
Get16N1	LD	A,(DE)
	INC	DE
	OR	A
	RET	Z
	CP	#20
	JR	Z,Get16N1
	CP	#30
	RET	C
	CP	#3A
	CCF 
	RET	C
	LD	C,L
	LD	B,H
	ADD	HL,HL
	RET	C
	ADD	HL,HL
	RET	C
	ADD	HL,BC
	RET	C
	ADD	HL,HL
	RET	C
	SUB	#30
	LD	C,A
	LD	B,#00
	ADD	HL,BC
	RET	C
	JR	Get16N1

LineBuf: DEFB	#05
	DEFB	#00	; Readystring
	DEFB	#00	; Pos x
	DEFB	#00	; Add x
	DEFB	#00	; Inp.symb
	DEFS	#06,0
;
 _mCollectInfo_addEnd
