 _mCollectInfo_addStart

; Stable lightweight syntax highlighter.
; No file I/O, no dynamic profile loading.

SyntaxExtTry:
	CALL	SynSetupLineColors
	CALL	SynDetectLang
	LD	(SynLang),A
	OR	A
	RET	Z
	CALL	SynHighlightComments
	CALL	SynHighlightCKeywords
	RET

SynSetupLineColors:
	LD	A,(CSComment)
	LD	(TmpColC),A
	LD	A,(CSMnemon)
	LD	(TmpColM),A
	LD	A,(CSLabel)
	LD	(TmpColL),A
	LD	A,(ColTxtWin)
	BIT	0,(IY-#04)
	JR	Z,SynSLC0
	LD	A,(ColSelTxt)
	LD	(TmpColC),A
	LD	(TmpColM),A
	LD	(TmpColL),A
SynSLC0:
	LD	(SynBaseColor),A
	LD	C,A
	LD	B,(IY+#02)
	LD	A,B
	OR	A
	RET	Z
	LD	HL,TextBuff+1
SynSLC1:
	LD	(HL),C
	INC	HL
	INC	HL
	DJNZ	SynSLC1
	RET

; A: 0 none, 1 c/cpp/h, 2 asm-like, 3 bat/cmd, 4 make
SynDetectLang:
	CALL	SynGetCurrName
	LD	HL,SynNameBuf
	LD	DE,#0000
SynDLp:
	LD	A,(HL)
	OR	A
	JR	Z,SynDDone
	CP	#5C
	JR	Z,SynDReset
	CP	'/'
	JR	Z,SynDReset
	CP	'.'
	JR	NZ,SynDNxt
	INC	HL
	LD	D,H
	LD	E,L
	JR	SynDLp
SynDReset:
	LD	DE,#0000
SynDNxt:
	INC	HL
	JR	SynDLp
SynDDone:
	LD	A,D
	OR	E
	JR	Z,SynDNone
	LD	H,D
	LD	L,E
	LD	DE,SynExtC
	CALL	SynExtEq
	JR	Z,SynIsC
	LD	DE,SynExtH
	CALL	SynExtEq
	JR	Z,SynIsC
	LD	DE,SynExtCpp
	CALL	SynExtEq
	JR	Z,SynIsC
	LD	DE,SynExtHpp
	CALL	SynExtEq
	JR	Z,SynIsC
	LD	DE,SynExtBat
	CALL	SynExtEq
	JR	Z,SynIsBat
	LD	DE,SynExtCmd
	CALL	SynExtEq
	JR	Z,SynIsBat
	LD	DE,SynExtMk
	CALL	SynExtEq
	JR	Z,SynIsMake
	LD	DE,SynExtMak
	CALL	SynExtEq
	JR	Z,SynIsMake
	LD	DE,SynExtMake
	CALL	SynExtEq
	JR	Z,SynIsMake
	LD	DE,SynExtAsm
	CALL	SynExtEq
	JR	Z,SynIsAsm
	LD	DE,SynExtZ80
	CALL	SynExtEq
	JR	Z,SynIsAsm
	LD	DE,SynExtZas
	CALL	SynExtEq
	JR	Z,SynIsAsm
	LD	DE,SynExtTas
	CALL	SynExtEq
	JR	Z,SynIsAsm
	LD	DE,SynExtInc
	CALL	SynExtEq
	JR	Z,SynIsAsm
	LD	DE,SynExtS
	CALL	SynExtEq
	JR	Z,SynIsAsm
SynDNone:
	XOR	A
	RET
SynIsC:
	LD	A,#01
	RET
SynIsAsm:
	LD	A,#02
	RET
SynIsBat:
	LD	A,#03
	RET
SynIsMake:
	LD	A,#04
	RET

SynHighlightComments:
	LD	A,(SynLang)
	CP	#01
	JR	Z,SynComC
	CP	#02
	JR	Z,SynComAsm
	CP	#03
	JR	Z,SynComBat
	CP	#04
	JR	Z,SynComMake
	RET

SynComAsm:
	LD	A,';'
	JP	SynPaintFromChar

SynComMake:
	LD	A,'#'
	JP	SynPaintFromChar

SynComBat:
	LD	B,(IY+#02)
	LD	HL,TextBuff
SynBatLp:
	LD	A,B
	OR	A
	RET	Z
	LD	A,(HL)
	CP	':'
	JR	NZ,SynBatRem
	INC	HL
	INC	HL
	DEC	B
	LD	A,B
	OR	A
	RET	Z
	LD	A,(HL)
	CP	':'
	JR	NZ,SynBatStepBack
	DEC	HL
	DEC	HL
	INC	B
	CALL	SynPaintToEnd
	RET
SynBatStepBack:
	DEC	HL
	DEC	HL
	INC	B
SynBatRem:
	CALL	SynRemAtPos
	JR	NC,SynBatPaint
	INC	HL
	INC	HL
	DEC	B
	JR	SynBatLp
SynBatPaint:
	CALL	SynPaintToEnd
	RET

SynComC:
	LD	B,(IY+#02)
	LD	HL,TextBuff
SynCCLp:
	LD	A,B
	OR	A
	RET	Z
	LD	A,(HL)
	CP	'/'
	JR	NZ,SynCCNext
	INC	HL
	INC	HL
	DEC	B
	LD	A,B
	OR	A
	RET	Z
	LD	A,(HL)
	CP	'/'
	JR	Z,SynCCMark
	CP	'*'
	JR	Z,SynCCMark
	DEC	HL
	DEC	HL
	INC	B
	JR	SynCCNext
SynCCMark:
	DEC	HL
	DEC	HL
	INC	B
	CALL	SynPaintToEnd
	RET
SynCCNext:
	INC	HL
	INC	HL
	DEC	B
	JR	SynCCLp

SynPaintFromChar:
	LD	C,A
	LD	B,(IY+#02)
	LD	HL,TextBuff
SynPFC0:
	LD	A,B
	OR	A
	RET	Z
	LD	A,(HL)
	CP	C
	JR	Z,SynPFC1
	INC	HL
	INC	HL
	DEC	B
	JR	SynPFC0
SynPFC1:
	CALL	SynPaintToEnd
	RET

SynPaintToEnd:
	LD	A,(TmpColC)
	INC	HL
SynPTE0:
	LD	(HL),A
	INC	HL
	INC	HL
	DEC	B
	JR	NZ,SynPTE0
	RET

SynRemAtPos:
	LD	A,(HL)
	CALL	SynToUpper
	CP	'R'
	JR	NZ,SynRemNo
	INC	HL
	INC	HL
	LD	A,(HL)
	CALL	SynToUpper
	CP	'E'
	JR	NZ,SynRemNoBack1
	INC	HL
	INC	HL
	LD	A,(HL)
	CALL	SynToUpper
	CP	'M'
	JR	NZ,SynRemNoBack2
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	OR	A
	RET
SynRemNoBack2:
	DEC	HL
	DEC	HL
SynRemNoBack1:
	DEC	HL
	DEC	HL
SynRemNo:
	SCF
	RET

SynHighlightCKeywords:
	LD	A,(SynLang)
	CP	#01
	RET	NZ
	LD	B,(IY+#02)
	LD	HL,TextBuff
SynKWLp:
	LD	A,B
	OR	A
	RET	Z
	INC	HL
	LD	A,(HL)
	DEC	HL
	LD	C,A
	LD	A,(SynBaseColor)
	CP	C
	JR	NZ,SynKWNext
	LD	A,(HL)
	CALL	SynIsWordStart
	JR	C,SynKWNext
	PUSH	BC
	PUSH	HL
	CALL	SynCollectWord
	POP	HL
	POP	BC
	JR	C,SynKWNext
	LD	DE,SynCKeywords
	CALL	SynWordInList
	JR	NZ,SynKWNext
	LD	A,(TmpColM)
	CALL	SynColorWord
	LD	A,(SynTokenLen)
	LD	E,A
	LD	D,#00
	ADD	HL,DE
	ADD	HL,DE
	LD	A,B
	SUB	E
	LD	B,A
	JR	SynKWLp
SynKWNext:
	INC	HL
	INC	HL
	DEC	B
	JR	SynKWLp

SynCollectWord:
	LD	DE,SynToken
	XOR	A
	LD	(SynTokenLen),A
	LD	A,B
	LD	C,A
SynCWLp:
	LD	A,C
	OR	A
	JR	Z,SynCWEnd
	LD	A,(HL)
	CALL	SynIsWordChar
	JR	C,SynCWEnd
	LD	A,(HL)
	CALL	SynToLower
	LD	(DE),A
	INC	DE
	INC	HL
	INC	HL
	DEC	C
	LD	A,(SynTokenLen)
	INC	A
	LD	(SynTokenLen),A
	CP	#17
	JR	C,SynCWLp
SynCWEnd:
	XOR	A
	LD	(DE),A
	LD	A,(SynTokenLen)
	OR	A
	SCF
	RET	Z
	OR	A
	RET

SynWordInList:
	LD	A,(DE)
	OR	A
	JR	Z,SynWNo
SynWSp:
	LD	A,(DE)
	OR	A
	JR	Z,SynWNo
	CP	','
	JR	Z,SynWS1
	CP	' '
	JR	Z,SynWS1
	JR	SynWCmp
SynWS1:
	INC	DE
	JR	SynWSp
SynWCmp:
	PUSH	DE
	LD	HL,SynToken
	LD	A,(SynTokenLen)
	LD	C,A
SynWCmpL:
	LD	A,C
	OR	A
	JR	Z,SynWEndChk
	LD	A,(DE)
	OR	A
	JR	Z,SynWNoPop
	CP	','
	JR	Z,SynWNoPop
	CP	' '
	JR	Z,SynWNoPop
	CALL	SynToLower
	CP	(HL)
	JR	NZ,SynWNoPop
	INC	DE
	INC	HL
	DEC	C
	JR	SynWCmpL
SynWEndChk:
	LD	A,(DE)
	OR	A
	JR	Z,SynWYes
	CP	','
	JR	Z,SynWYes
	CP	' '
	JR	Z,SynWYes
SynWNoPop:
	POP	DE
SynWSkip:
	LD	A,(DE)
	OR	A
	JR	Z,SynWNo
	CP	','
	JR	Z,SynWGo
	INC	DE
	JR	SynWSkip
SynWGo:
	INC	DE
	JR	SynWordInList
SynWYes:
	POP	DE
	XOR	A
	RET
SynWNo:
	LD	A,#01
	OR	A
	RET

SynColorWord:
	PUSH	AF
	LD	A,(SynTokenLen)
	LD	C,A
	POP	AF
	INC	HL
SynClrL:
	LD	(HL),A
	INC	HL
	INC	HL
	DEC	C
	JR	NZ,SynClrL
	RET

SynIsWordStart:
	CP	'_'
	JR	Z,SynIWSY
	CP	'A'
	JR	C,SynIWSN
	CP	'Z'+1
	JR	C,SynIWSY
	CP	'a'
	JR	C,SynIWSN
	CP	'z'+1
	JR	C,SynIWSY
SynIWSN:
	SCF
	RET
SynIWSY:
	OR	A
	RET

SynIsWordChar:
	CALL	SynIsWordStart
	RET	NC
	CP	'0'
	JR	C,SynIWCN
	CP	'9'+1
	JR	C,SynIWCY
SynIWCN:
	SCF
	RET
SynIWCY:
	OR	A
	RET

SynExtEq:
	LD	A,(DE)
	OR	A
	JR	Z,SynExtEqEnd
	LD	B,A
	LD	A,(HL)
	CALL	SynToLower
	CP	B
	RET	NZ
	INC	HL
	INC	DE
	JR	SynExtEq
SynExtEqEnd:
	LD	A,(HL)
	OR	A
	RET	Z
	CP	':'
	RET	Z
	CP	' '
	RET	Z
	CP	#09
	RET	Z
	SCF
	RET

SynToLower:
	CP	'A'
	RET	C
	CP	'Z'+1
	RET	NC
	SET	5,A
	RET

SynToUpper:
	CP	'a'
	RET	C
	CP	'z'+1
	RET	NC
	RES	5,A
	RET

; Copy current window full name/path into SynNameBuf.
SynGetCurrName:
	LD	IX,TxtWtab
	BIT	7,(IX+#00)
	JR	Z,SynGN0
	LD	HL,SynNameBuf
	XOR	A
	LD	(HL),A
	RET
SynGN0:
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	LD	A,(IX+#00)
	AND	#0F
	INC	A
	LD	B,A
	LD	HL,NameTab-#80
	LD	DE,#0080
SynGN1:
	ADD	HL,DE
	DJNZ	SynGN1
	LD	DE,SynNameBuf
	LD	B,#3F
SynGN2:
	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	OR	A
	JR	Z,SynGN3
	DJNZ	SynGN2
	XOR	A
	LD	(DE),A
SynGN3:
	POP	AF
	OUT	(SLOT2),A
	RET

; Compatibility stub for old call sites.
NotComm:
	RET

SynExtBusy:	DEFB	#00
SynBaseColor:	DEFB	#00
SynLang:	DEFB	#00
SynTokenLen:	DEFB	#00
SynToken:	DEFS	24,0
SynNameBuf:	DEFS	64,0

SynExtC:	DEFB	"c",0
SynExtH:	DEFB	"h",0
SynExtCpp:	DEFB	"cpp",0
SynExtHpp:	DEFB	"hpp",0
SynExtBat:	DEFB	"bat",0
SynExtCmd:	DEFB	"cmd",0
SynExtMk:	DEFB	"mk",0
SynExtMak:	DEFB	"mak",0
SynExtMake:	DEFB	"make",0
SynExtAsm:	DEFB	"asm",0
SynExtZ80:	DEFB	"z80",0
SynExtZas:	DEFB	"zas",0
SynExtTas:	DEFB	"tas",0
SynExtInc:	DEFB	"inc",0
SynExtS:	DEFB	"s",0

SynCKeywords:
	DEFB	"if,else,for,while,do,switch,case,default,break,continue,return,"
	DEFB	"struct,enum,typedef,const,static,extern,volatile,unsigned,signed,"
	DEFB	"int,char,long,short,float,double,void,sizeof,goto,register",0

 _mCollectInfo_addEnd
