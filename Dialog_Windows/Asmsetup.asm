 _mCollectInfo_addStart
;[]===========================================================[]
; Procedure
InitSetUp
	CALL	InitText
	LD	A,(EditMode)
	OR	A
	JR	Z,$+7
	LD	A,#01
	LD	(EditMode),A
	LD	A,(InsertMode)
	OR	A
	JR	Z,$+7
	LD	A,#01
	LD	(InsertMode),A
	LD	A,(SynHghLght)
	OR	A
	JR	Z,$+7
	LD	A,#01
	LD	(SynHghLght),A
	LD	A,(KeyPad)
	OR	A
	JR	Z,$+7
	LD	A,#01
	LD	(KeyPad),A
	XOR	#01
	LD	(KeyPad1),A
	LD	A,(LabSize)
	CP	#21
	JR	C,$+4
	LD	A,#20
	LD	(LabSize),A
	LD	A,(TabSize)
	CP	#21
	JR	C,$+4
	LD	A,#20
	LD	(TabSize),A
	LD	A,(OvrwrtBlck)
	OR	A
	JR	Z,$+7
	LD	A,#01
	LD	(OvrwrtBlck),A
	LD	A,(HiddMouse)
	OR	A
	JR	Z,$+7
	LD	A,#01
	LD	(HiddMouse),A
	LD	A,(OptimalTAB)
	OR	A
	JR	Z,$+7
	LD	A,#01
	LD	(OptimalTAB),A
	LD	A,(TABimpWidth)
	CP	#04
	JR	Z,InitTabW
	CP	#08
	JR	Z,InitTabW
	LD	A,#08
	LD	(TABimpWidth),A
InitTabW
	CP	#04		; Sync cluster state with loaded width
	JR	NZ,InitTabW8
	LD	A,#01
	LD	(TABimpW4),A
	XOR	A
	LD	(TABimpW8),A
	JR	InitTabWE
InitTabW8
	XOR	A
	LD	(TABimpW4),A
	INC	A
	LD	(TABimpW8),A
InitTabWE
	LD	A,(WinPutMode)
	OR	A
	JR	Z,$+7
	LD	A,#01
	LD	(WinPutMode),A
	LD	HL,TextBuff
	LD	BC,#0000
	LD	A,(ColTxtWin)
	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-4
	AND	#F0
	LD	B,A
	LD	C,#0F
	LD	A,(ColLabel)
	AND	C
	OR	B
	LD	(ColLabel),A
	LD	(CSLabel),A
	LD	A,(ColMnemon)
	AND	C
	OR	B
	LD	(ColMnemon),A
	LD	(CSMnemon),A
	LD	A,(ColComment)
	AND	C
	OR	B
	LD	(ColComment),A
	LD	(CSComment),A
	LD	A,(ColBrace)
	AND	C
	OR	B
	LD	(ColBrace),A
	LD	(CSBrace),A
	LD	A,(ColString)
	AND	C
	OR	B
	LD	(ColString),A
	LD	(CSString),A
	LD	A,(ColNumber)
	AND	C
	OR	B
	LD	(ColNumber),A
	LD	(CSNumber),A
	LD	A,(SynHghLght)
	OR	A
	RET	NZ
	LD	A,(ColTxtWin)
	LD	(CSLabel),A
	LD	(CSMnemon),A
	LD	(CSComment),A
	LD	(CSBrace),A
	LD	(CSString),A
	LD	(CSNumber),A
	RET
;[]===========================================================[]
InitText
	LD	DE,SetupBuff
InitSet1
	LD	A,(DE)
	INC	DE
	CP	#FF
	RET	Z
	CP	#21
	JR	C,InitSet1
	LD	BC,InitSet2
	PUSH	BC
	RES	5,A
	CP	"E"
	JR	Z,InitSetE
	CP	"B"
	JR	Z,InitSetB
	CP	"D"
	JR	Z,InitSetD
	CP	"T"
	JR	Z,InitSetT
	CP	"S"
	JR	Z,InitSetS
	CP	"M"
	JR	Z,InitSetM
	POP	BC
InitSet2
	LD	A,(DE)
	INC	DE
	CP	#FF
	RET	Z
	CP	#0A
	JR	NZ,InitSet2
	JR	InitSet1
InitSetE
	LD	HL,InitE
	LD	C,E
	LD	B,D
InitS1	LD	A,(DE)
	CP	#21
	RET	C
	LD	A,(HL)
	OR	A
	JR	Z,InitF1
	LD	A,(DE)
	RES	5,A
	CP	(HL)
	JR	NZ,NxtIn1
	INC	HL
	INC	DE
	JR	InitS1
NxtIn1	INC	HL
	LD	A,(HL)
	OR	A
	JR	NZ,NxtIn1
	INC	HL
	INC	HL
	INC	HL
	LD	A,(HL)
	OR	A
	RET	Z
	LD	E,C
	LD	D,B
	JR	InitS1
InitF1	LD	A,(DE)
	INC	DE
	CP	"="
	RET	NZ
	CALL	GivNumb
	RET	C
	LD	A,(DE)
	CP	#0D
	JR	Z,InitF2
	CP	#20
	RET	NZ
InitF2	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	LD	A,LX
	LD	(BC),A
	RET 
InitSetB
	LD	HL,InitB
	JR	InitSet
InitSetD
	LD	HL,InitD
	JR	InitSet
InitSetT
	LD	HL,InitT
	JR	InitSet
InitSetS
	LD	HL,InitS
	JR	InitSet
InitSetM
	LD	HL,InitM
InitSet	LD	C,E
	LD	B,D
InitSt1	LD	A,(DE)
	CP	#21
	RET	C
	LD	A,(HL)
	OR	A
	JR	Z,InitSF1
	LD	A,(DE)
	RES	5,A
	CP	(HL)
	JR	NZ,NxtInt1
	INC	HL
	INC	DE
	JR	InitSt1
NxtInt1	INC	HL
	LD	A,(HL)
	OR	A
	JR	NZ,NxtInt1
	INC	HL
	INC	HL
	INC	HL
	LD	A,(HL)
	OR	A
	RET	Z
	LD	E,C
	LD	D,B
	JR	InitSt1
InitSF1	LD	A,(DE)
	INC	DE
	CP	"="
	RET	NZ
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	BC
	LD	A,(BC)
	DEC	BC
	CP	#FF
	JR	Z,TwoCol1
	CP	#0F
	JR	Z,Ink1
InitSF2	LD	A,(DE)
	INC	DE
	CP	#FF
	RET	Z
	CP	#0D
	RET	Z
	CP	#21
	RET	C
	CP	","
	JR	NZ,InitSF2
	CALL	GivNumb
	RET	C
	LD	A,(DE)
	CP	#0D
	JR	Z,InitSF3
	CP	#20
	RET	NZ
InitSF3	LD	A,LX
	CP	#08
	RET	NC
	RLA 
	RLA 
	RLA 
	RLA 
	AND	#F0
	LD	(BC),A
	RET 
TwoCol1	CALL	GivNumb
	RET	C
TwoC1	LD	A,(DE)
	INC	DE
	CP	#0D
	JR	Z,TwoCol2
	CP	","
	JR	Z,TwoCol2
	CP	#20
	JR	Z,TwoC1
	RET 
TwoCol2	LD	A,(BC)
	AND	#F0
	LD	HX,A
	LD	A,LX
	CP	#10
	RET	NC
	OR	HX
	LD	(BC),A
	LD	A,(DE)
	CP	#0D
	RET	Z
	CALL	GivNumb
	RET	C
	LD	A,(DE)
	CP	#0D
	JR	Z,TwoC2
	CP	#20
	RET	NZ
TwoC2	LD	A,(BC)
	AND	#0F
	LD	HX,A
	LD	A,LX
	CP	#08
	RET	NC
	RLA 
	RLA 
	RLA 
	RLA 
	AND	#F0
	OR	HX
	LD	(BC),A
	RET 
Ink1	CALL	GivNumb
	RET	C
	LD	A,(DE)
	CP	#0D
	JR	Z,Ink2
	CP	#20
	JR	Z,Ink2
	CP	#2C
	RET	NZ
Ink2	LD	A,LX
	; Store full 8-bit attribute byte; the writer (GetColors) now emits
	; the whole byte rather than just the low nibble, so the round-trip
	; preserves user-selected high-nibble bits (e.g. brightness).
	LD	(BC),A
	RET

GivNumb	LD	LX,#00
GivNum1	LD	A,(DE)
	CP	#30
	CCF 
	RET	NC
	CP	#3A
	RET	NC
	SUB	#30
	LD	HX,A
	LD	A,LX
	ADD	A,A
	RET	C
	ADD	A,A
	RET	C
	ADD	A,A
	RET	C
	ADD	A,LX
	RET	C
	ADD	A,LX
	RET	C
	ADD	A,HX
	RET	C
	LD	LX,A
	INC	DE
	JR	GivNum1

InitE	DEFB	"TEXTEDIT",0
	DEFW	EditMode
	DEFB	"EDITMODE",0
	DEFW	InsertMode
	DEFB	"SYNTAXHIGHLIGHT",0
	DEFW	SynHghLght
	DEFB	"KEYPAD",0
	DEFW	KeyPad
	DEFB	"LABELTABSIZE",0
	DEFW	LabSize
	DEFB	"TABSIZE",0
	DEFW	TabSize
	DEFB	"OVERWRITEBLOCKS",0
	DEFW	OvrwrtBlck
	DEFB	"HIDDENMOUSE",0
	DEFW	HiddMouse
	DEFB	"OPTIMALTAB",0
	DEFW	OptimalTAB
	DEFB	"TABDISPLAYIMPORTWIDTH",0
	DEFW	TABimpWidth
	DEFB	"WINDOWSPUTMODE",0
	DEFW	WinPutMode
	DEFB	0
InitB
	DEFB	"MENU",0
	DEFW	ColMenuBar
	DEFB	"HIGHLIGHT",0
	DEFW	ColInvr
	DEFB	"HOTKEYS",0
	DEFW	ColBhotkey
	DEFB	"HIDDENCOMMAND",0
	DEFW	ColHiddenC
	DEFB	0
InitD
	DEFB	"WORKDESK",0
	DEFW	ColDeskTop
	DEFB	"DIALOGWINDOWS",0
	DEFW	ColDialWn
	DEFB	"FRAMESELECT",0
	DEFW	ColDialFr
	DEFB	"FRAMEMVRS",0
	DEFW	ColDialFrM
	DEFB	"HIGHTLIGHT",0
	DEFW	ColDialInv
	DEFB	"HOTKEYS",0
	DEFW	ColDhotkey
	DEFB	"INPUTLINE",0
	DEFW	ColInpLine
	DEFB	"FILEINPUTLINE",0
	DEFW	ColFileInp
	DEFB	"FILEBOX",0
	DEFW	ColFileBox
	DEFB	"FBHIGHTLIGHT",0
	DEFW	ColFileBxI
	DEFB	"FBHIGHTLIGHTHD",0
	DEFW	ColFileBHI
	DEFB	"LISTBOX",0
	DEFW	ColListBox
	DEFB	"LBHIGHTLIGHT",0
	DEFW	ColLstBoxI
	DEFB	"LBHIGHTLIGHTHD",0
	DEFW	ColLstBxHI
	DEFB	"FILEINFO",0
	DEFW	ColFileInf
	DEFB	"BUTTONS",0
	DEFW	ColButton
	DEFB	0
InitT
	DEFB	"TEXTWINDOWS",0
	DEFW	ColTxtWin
	DEFB	"FRAMESELECT",0
	DEFW	ColNormFr
	DEFB	"FRAMEMVRS",0
	DEFW	ColMoveFr
	DEFB	"FRAMEUNSEL",0
	DEFW	ColHiddFr
	DEFB	0
InitS
	DEFB	"Z",#18,#10,"KEYWORDS",0
	DEFW	ColMnemon
	DEFB	"KEYWORDS2",0
	DEFW	ColLabel
	DEFB	"COMMENTS",0
	DEFW	ColComment
	DEFB	"BRACKETS",0
	DEFW	ColBrace
	DEFB	"STRINGS",0
	DEFW	ColString
	DEFB	"NUMBERS",0
	DEFW	ColNumber
	; Legacy aliases — let .set files written before the rename still load.
	DEFB	"MNEMONIC",0
	DEFW	ColMnemon
	DEFB	"LABELS",0
	DEFW	ColLabel
	DEFB	0
InitM
	DEFB	"WINDOWSATTRIBUTS",0
	DEFW	ColWindAtr
	DEFB	"SCROLLBAR",0
	DEFW	ColScrlBar
	DEFB	"PROCESSLINE",0
	DEFW	ColProcess
	DEFB	"SELECTEDTEXT",0
	DEFW	ColSelTxt
	DEFB	"REPLACEDTEXT",0
	DEFW	ColReplTxt
	DEFB	0
;[]===========================================================[]
; Procedure
SaveSetUp
	CALL	InitSetTxt
	EX	DE,HL
	LD	(HL),#FF
	INC	HL
	LD	(HL),#FF
	DEC	HL
	LD	DE,SetupBuff
	OR	A
	SBC	HL,DE
	LD	(SetUpLn+1),HL
	PUSH	IY
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)	; Enable system DOS
	OUT	(SLOT0),A		; In 0 page
	LD	BC,#7FFD														; !fixit #7ffd
	LD	A,#10		; Enable. ports vg93
	OUT	(C),A
; Temporarily move to the launch directory so KODE.SET is always created
; in the same place as the loader reads it from, regardless of where the
; user has navigated during the session. PathCur is restored at SaveSte.
	LD	HL,TempDirBuf
	CALL	CaptureDir	; save user's current dir into TempDirBuf
	LD	HL,LaunchPathBuf
	CALL	RestoreDir	; ChDir back to the launch dir
	LD	HL,SetUpName	; Internal operation
	SUB	A		; Internal operation
	LD	C,Dss.Create	; Function DOS: Create File
	RST	ToDSS
	LD	(FileHandle),A	; File handle
	JR	C,SaveSte
	LD	HL,SetupBuff	; Memory
SetUpLn	LD	DE,#0000
	LD	A,(FileHandle)	; File handle
	LD	C,#14		; Function DOS: Write
	RST	#10
	JR	C,SaveSte
	LD	A,(FileHandle)	; File handle
	LD	C,#12		; Function DOS: Close File
	RST	#10
SaveSte	EX	AF,AF'
	LD	HL,TempDirBuf	; restore user's current dir
	CALL	RestoreDir
	LD	BC,#7FFD														; !fixit #7ffd
	SUB	A		; Disable. ports vg93
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A		; Restore 0 page
	POP	IY		; Restore.register
	EX	AF,AF'
	RET
InitSetTxt
	LD	HL,SetupLst
	LD	DE,SetupBuff
SaveSet1
	LDI 
	LD	A,(HL)
	INC	A
	RET	Z
	DEC	A
	JR	NZ,SaveSet1
	INC	HL
	LD	A,(HL)
	INC	HL
	OR	A
	PUSH	AF
	CALL	Z,GetCeils
	POP	AF
	CALL	NZ,GetColors
	JR	SaveSet1
GetCeils
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	A,(BC)
	JR	GetNUM8
GetColors
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	A,(BC)
	INC	BC
	EX	AF,AF'
	LD	A,(BC)
	LD	B,A
	EX	AF,AF'
	LD	C,A
	LD	A,B
	CP	#FF
	JR	Z,TwoCol
	CP	#F0
	JR	Z,Paper
	; Ink-only slot: emit full attribute byte so the high nibble (bright/
	; extended bits) survives the save/load round-trip. The reader (Ink2)
	; stores the whole byte as-is.
	LD	A,C
	CALL	GetNUM8
	LD	A,","
	LD	(DE),A
	INC	DE
	JR	None
Paper	CALL	None
	LD	A,","
	LD	(DE),A
	INC	DE
	LD	A,C
	RRA 
	RRA 
	RRA 
	RRA 
	AND	#0F
	JR	GetNUM8
TwoCol	LD	A,C
	AND	#0F
	CALL	GetNUM8
	LD	A,","
	LD	(DE),A
	INC	DE
	LD	A,C
	RRA 
	RRA 
	RRA 
	RRA 
	AND	#0F
	JR	GetNUM8
None	EX	DE,HL
	LD	(HL),"N"
	INC	HL
	LD	(HL),"o"
	INC	HL
	LD	(HL),"n"
	INC	HL
	LD	(HL),"e"
	INC	HL
	EX	DE,HL
	RET 
GetNUM8
	PUSH	BC
	LD	C,#00
	LD	B,#2F
	INC	B
	SUB	100
	JR	NC,$-3
	ADD	A,100
	EX	AF,AF'
	LD	A,B
	CP	#30
	JR	Z,$+4
	SET	0,C
	BIT	0,C
	JR	Z,$+4
	LD	(DE),A
	INC	DE
	EX	AF,AF'
	LD	B,#2F
	INC	B
	SUB	10
	JR	NC,$-3
	ADD	A,10
	EX	AF,AF'
	LD	A,B
	CP	#30
	JR	Z,$+4
	SET	0,C
	BIT	0,C
	JR	Z,$+4
	LD	(DE),A
	INC	DE
	EX	AF,AF'
	ADD	A,#30
	LD	(DE),A
	INC	DE
	POP	BC
	RET 
;[]===========================================================[]
SetupLst
	DEFB	#0D,#0A
	DEFB	"  [///Editor options///]",#0D,#0A
	DEFB	#0D,#0A
	DEFB	"     eTextEdit=",0,0
	DEFW	EditMode
	DEFB	#0D,#0A
	DEFB	"     eEditMode=",0,0
	DEFW	InsertMode
	DEFB	#0D,#0A
	DEFB	"     eSyntaxHighLight=",0,0
	DEFW	SynHghLght
	DEFB	#0D,#0A
	DEFB	"     eKeyPad=",0,0
	DEFW	KeyPad
	DEFB	#0D,#0A
	DEFB	"     eLabelTabSize=",0,0
	DEFW	LabSize
	DEFB	#0D,#0A
	DEFB	"     eTabSize=",0,0
	DEFW	TabSize
	DEFB	#0D,#0A
	DEFB	#0D,#0A
	DEFB	"     eOverwriteBlocks=",0,0
	DEFW	OvrwrtBlck
	DEFB	#0D,#0A
	DEFB	#0D,#0A
	DEFB	"     eHiddenMouse=",0,0
	DEFW	HiddMouse
	DEFB	#0D,#0A
	DEFB	#0D,#0A
	DEFB	"     eOptimalTab=",0,0
	DEFW	OptimalTAB
	DEFB	#0D,#0A
	DEFB	#0D,#0A
	DEFB	"     eTabDisplayImportWidth=",0,0
	DEFW	TABimpWidth
	DEFB	#0D,#0A
	DEFB	#0D,#0A
	DEFB	"     eWindowsPutMode=",0,0
	DEFW	WinPutMode
	DEFB	#0D,#0A
	DEFB	#0D,#0A
	DEFB	#0D,#0A
	DEFB	"  [///Colors///]",#0D,#0A
	DEFB	#0D,#0A
	DEFB	"     dWorkDesk=",0,1
	DEFW	ColDeskTop
	DEFB	#0D,#0A
	DEFB	#0D,#0A
	DEFB	"     bMenu=",0,1
	DEFW	ColMenuBar
	DEFB	#0D,#0A
	DEFB	"     bHighlight=",0,1
	DEFW	ColInvr
	DEFB	#0D,#0A
	DEFB	"     bHotKeys=",0,1
	DEFW	ColBhotkey
	DEFB	#0D,#0A
	DEFB	"     bHiddenCommand=",0,1
	DEFW	ColHiddenC
	DEFB	#0D,#0A
	DEFB	#0D,#0A
	DEFB	"     dDialogWindows=",0,1
	DEFW	ColDialWn
	DEFB	#0D,#0A
	DEFB	"     dFrameSelect=",0,1
	DEFW	ColDialFr
	DEFB	#0D,#0A
	DEFB	"     dFrameMvRs=",0,1
	DEFW	ColDialFrM
	DEFB	#0D,#0A
	DEFB	"     dHightlight=",0,1
	DEFW	ColDialInv
	DEFB	#0D,#0A
	DEFB	"     dHotKeys=",0,1
	DEFW	ColDhotkey
	DEFB	#0D,#0A
	DEFB	"     dInputLine=",0,1
	DEFW	ColInpLine
	DEFB	#0D,#0A
	DEFB	"     dFileInputLine=",0,1
	DEFW	ColFileInp
	DEFB	#0D,#0A
	DEFB	"     dFileBox=",0,1
	DEFW	ColFileBox
	DEFB	#0D,#0A
	DEFB	"     dFBhightlight=",0,1
	DEFW	ColFileBxI
	DEFB	#0D,#0A
	DEFB	"     dFBhightlightHd=",0,1
	DEFW	ColFileBHI
	DEFB	#0D,#0A
	DEFB	"     dListBox=",0,1
	DEFW	ColListBox
	DEFB	#0D,#0A
	DEFB	"     dLBhightlight=",0,1
	DEFW	ColLstBoxI
	DEFB	#0D,#0A
	DEFB	"     dLBhightlightHd=",0,1
	DEFW	ColLstBxHI
	DEFB	#0D,#0A
	DEFB	"     dFileInfo=",0,1
	DEFW	ColFileInf
	DEFB	#0D,#0A
	DEFB	"     dButtons=",0,1
	DEFW	ColButton
	DEFB	#0D,#0A
	DEFB	#0D,#0A
	DEFB	"     tTextWindows=",0,1
	DEFW	ColTxtWin
	DEFB	#0D,#0A
	DEFB	"     tFrameSelect=",0,1
	DEFW	ColNormFr
	DEFB	#0D,#0A
	DEFB	"     tFrameMvRs=",0,1
	DEFW	ColMoveFr
	DEFB	#0D,#0A
	DEFB	"     tFrameUnsel=",0,1
	DEFW	ColHiddFr
	DEFB	#0D,#0A
	DEFB	#0D,#0A
	DEFB	"     sKeywords=",0,1
	DEFW	ColMnemon
	DEFB	#0D,#0A
	DEFB	"     sKeywords2=",0,1
	DEFW	ColLabel
	DEFB	#0D,#0A
	DEFB	"     sComments=",0,1
	DEFW	ColComment
	DEFB	#0D,#0A
	DEFB	"     sBrackets=",0,1
	DEFW	ColBrace
	DEFB	#0D,#0A
	DEFB	"     sStrings=",0,1
	DEFW	ColString
	DEFB	#0D,#0A
	DEFB	"     sNumbers=",0,1
	DEFW	ColNumber
	DEFB	#0D,#0A
	DEFB	#0D,#0A
	DEFB	"     mWindowsAttributs=",0,1
	DEFW	ColWindAtr
	DEFB	#0D,#0A
	DEFB	"     mScrollBar=",0,1
	DEFW	ColScrlBar
	DEFB	#0D,#0A
	DEFB	"     mProcessLine=",0,1
	DEFW	ColProcess
	DEFB	#0D,#0A
	DEFB	"     mSelectedText=",0,1
	DEFW	ColSelTxt
	DEFB	#0D,#0A
	DEFB	"     mReplacedText=",0,1
	DEFW	ColReplTxt
	DEFB	#0D,#0A
	DEFB	#0D,#0A
	DEFB	#FF
;[]===========================================================[]
; Capture DSS current drive+directory into the buffer at HL, in a format
; suitable to be passed back to Dss.ChDir (i.e. "X:\PATH\0"). Preserves
; all registers the caller cares about.
; On entry: HL = destination buffer (at least 260 bytes, in this page).
; Requires: DOSpage at SLOT0, this page (Dialog_Windows_PG2) in any slot.
CaptureDir
	PUSH	BC
	PUSH	DE
	PUSH	HL		; save destination pointer
	LD	C,Dss.CurDisk
	RST	ToDSS		; A = current drive (0='A', 1='B', ...)
	ADD	A,'A'
	POP	HL		; restore destination pointer
	PUSH	HL		; keep for final pop
	LD	(HL),A
	INC	HL
	LD	(HL),':'
	INC	HL
	LD	(HL),0		; HL now points to where CurDir should append
	LD	C,Dss.CurDir
	RST	ToDSS		; writes "\PATH\0" starting at HL
	POP	HL
	POP	DE
	POP	BC
	RET
;[]===========================================================[]
; ChDir to the path stored in buffer at HL. Used to restore a previously
; captured directory around a file-save operation.
; On entry: HL = ASCIIZ path buffer (e.g. "X:\PATH").
; Requires: DOSpage at SLOT0, this page in any slot.
RestoreDir
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	C,Dss.ChDir
	RST	ToDSS
	POP	HL
	POP	DE
	POP	BC
	RET
;[]===========================================================[]
SetUpName:
	DEFB	"KODE.SET",0
;[]===========================================================[]
; Full path (drive + directory) the editor was launched from. Captured
; once at loader startup and used as the anchor for the KODE.SET file
; so it always stays next to where Kode was originally started, even if
; the user navigates elsewhere in the current session.
LaunchPathBuf:
	BLOCK	256,0
; Scratch buffer for saving the user's current directory around the
; settings-save operation, so we can restore PathCur afterwards.
TempDirBuf:
	BLOCK	256,0
;[]===========================================================[]
; Cold SyntaxExt buffers paged out of KodeMain into Dialog_Windows_PG2 to
; free space in the always-resident main page. Callers in SyntaxExt.asm
; must page DialogPg2 into SLOT3 before reading/writing these buffers
; (the helpers SynPageDp2In / SynPageDp2Out wrap that paging dance).
;
;   SynBackupSlot — LRU cache for the previously-active syntax profile.
;     Layout MUST mirror SynActiveSlot in SyntaxExt.asm; the two are
;     byte-swapped wholesale by SynSwapSlots.
SynBackupSlot:
SynLoadedProfBk:	BLOCK	20,0
SynLC1Bk:	BLOCK	4,0
SynLC2Bk:	BLOCK	4,0
SynBrBk:	BLOCK	12,0
SynSDBk:	BLOCK	4,0
SynCSBk:	BLOCK	1,0
SynHBCBk:	BLOCK	1,0
SynKw1Bk:	BLOCK	384,0
SynKw2Bk:	BLOCK	128,0
SynBackupSlotEnd:

;   SynFileBuf — read-once scratch for .syn profile content; reused as
;     output buffer during SynBuildKwIndex counting sort.
SynFileBuf:	BLOCK	640,0

;   SynIndexBuf — read-once scratch for SYNTAX\INDEX.LST content; lookups
;     run directly against this buffer.
SynIndexBuf:	BLOCK	256,0

;[]===========================================================[]
; Pascal syntax scanners are kept in this cold page because KodeMain must
; remain below #7700 (the EXE startup trampoline occupies #F700/#7700).
; Called while Dialog_Windows_PG2 is already mapped by SynLoadProfile.
SynDetectBlockComPg2:
	XOR	A
	LD	(SynHasBlockCom),A
	LD	HL,SynLineCom2
	LD	A,(HL)
	CP	'/'
	JR	NZ,SynDetectBlockPasPg2
	INC	HL
	LD	A,(HL)
	CP	'*'
	JR	NZ,SynDetectBlockPasPg2
	INC	HL
	LD	A,(HL)
	OR	A
	JR	NZ,SynDetectBlockPasPg2
	LD	A,#01
	LD	(SynHasBlockCom),A
	RET
SynDetectBlockPasPg2:
	LD	HL,SynLineCom2
	LD	A,(HL)
	CP	'{'
	RET	NZ
	INC	HL
	LD	A,(HL)
	OR	A
	RET	NZ
	LD	A,#02
	LD	(SynHasBlockCom),A
	RET

; Counting-sort the keyword CSV in place (by first letter) and build the
; first-letter range index. Done once per profile load. SynFileBuf is used as
; scratch: bytes 0..26 hold per-bucket byte counts during phase 1, and
; bytes 27.. hold the sorted output buffer during phase 3.
;
; In:  HL = keyword buffer (ASCIIZ CSV)
;      DE = idx buffer (56 bytes — 28 boundary pointers)
SynBuildKwIndex:
	LD	(SynBKISrc),HL
	LD	(SynBKIIdx),DE
	LD	A,(HL)
	OR	A
	RET	Z
	; --- Phase 0: clear scratch counters (27 bytes at SynFileBuf) ---
	LD	HL,SynFileBuf
	LD	D,H
	LD	E,L
	INC	DE
	LD	BC,26
	LD	(HL),0
	LDIR
	; --- Phase 1: count bytes per bucket ---
	LD	HL,(SynBKISrc)
SynBKI1Lp:
	LD	A,(HL)
	OR	A
	JR	Z,SynBKI1End
	LD	(SynBKICur),HL
	CALL	SynLetterBucket
	LD	(SynBKIBkt),A
	LD	HL,(SynBKICur)
	LD	B,#00				; word length
SynBKI1WordLp:
	LD	A,(HL)
	OR	A
	JR	Z,SynBKI1WordEnd
	CP	','
	JR	Z,SynBKI1WordEnd
	INC	HL
	INC	B
	JR	SynBKI1WordLp
SynBKI1WordEnd:
	; B = word_len. Add (B+1) to SynFileBuf[bucket].
	PUSH	HL
	LD	A,(SynBKIBkt)
	LD	HL,SynFileBuf
	LD	E,A
	LD	D,#00
	ADD	HL,DE
	LD	A,(HL)
	ADD	A,B
	INC	A
	LD	(HL),A
	POP	HL
	; Skip ',' if present
	LD	A,(HL)
	OR	A
	JR	Z,SynBKI1End
	INC	HL
	JR	SynBKI1Lp
SynBKI1End:
	; --- Phase 2: prefix-sum byte counters into idx as 27 word entries ---
	LD	HL,(SynBKIIdx)
	LD	DE,SynFileBuf
	LD	BC,#0000			; cumulative
	LD	A,#1B				; 27 entries
SynBKI2Lp:
	LD	(HL),C
	INC	HL
	LD	(HL),B
	INC	HL
	EX	AF,AF'
	LD	A,(DE)
	INC	DE
	ADD	A,C
	LD	C,A
	JR	NC,SynBKI2NoCarry
	INC	B
SynBKI2NoCarry:
	EX	AF,AF'
	DEC	A
	JR	NZ,SynBKI2Lp
	; --- Phase 3: scatter words from src into scratch[27..] ---
	LD	HL,(SynBKISrc)
SynBKI3Lp:
	LD	A,(HL)
	OR	A
	JR	Z,SynBKI3End
	LD	(SynBKICur),HL
	CALL	SynLetterBucket
	LD	(SynBKIBkt),A
	; idx entry addr = idx + 2*bucket
	LD	HL,(SynBKIIdx)
	ADD	A,A
	LD	E,A
	LD	D,#00
	ADD	HL,DE
	; HL = idx entry addr; read current write offset (relative to scratch+27)
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	DEC	HL
	PUSH	HL				; save idx entry addr
	; Compute scratch dst = SynFileBuf+27 + offset
	LD	HL,SynFileBuf+27
	ADD	HL,DE
	LD	DE,(SynBKICur)			; DE = src word ptr
	LD	BC,#0000			; bytes copied
SynBKI3CpLp:
	LD	A,(DE)
	OR	A
	JR	Z,SynBKI3CpEnd
	CP	','
	JR	Z,SynBKI3CpEnd
	LD	(HL),A
	INC	HL
	INC	DE
	INC	BC
	JR	SynBKI3CpLp
SynBKI3CpEnd:
	; Append separator ','
	LD	A,','
	LD	(HL),A
	INC	BC				; BC = word_len + 1
	; Update idx entry: add BC
	POP	HL
	LD	A,(HL)
	ADD	A,C
	LD	(HL),A
	INC	HL
	LD	A,(HL)
	ADC	A,B
	LD	(HL),A
	; Continue with next word (DE points past current word in src)
	EX	DE,HL				; HL = src ptr (just past word body)
	LD	A,(HL)
	OR	A
	JR	Z,SynBKI3End
	INC	HL				; consume ','
	JR	SynBKI3Lp
SynBKI3End:
	; --- Phase 4: copy scratch[27..27+total] back to src; total = idx[26] ---
	LD	HL,(SynBKIIdx)
	LD	BC,52				; 26 buckets * 2 bytes (start of bucket 26)
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	; DE = total bytes after phase 3
	LD	A,D
	OR	E
	JR	Z,SynBKI4Done
	PUSH	DE
	LD	HL,SynFileBuf+27
	LD	DE,(SynBKISrc)
	POP	BC
	PUSH	BC
	LDIR
	POP	BC
	; Replace last ',' with NUL
	LD	HL,(SynBKISrc)
	DEC	BC
	ADD	HL,BC
	LD	(HL),0
SynBKI4Done:
	; --- Phase 5: rebuild idx as absolute range boundaries ---
	; SynFileBuf[i] still holds the original byte count for bucket i.
	LD	HL,(SynBKIIdx)
	LD	DE,SynFileBuf
	LD	BC,(SynBKISrc)			; BC = running zone-start ptr
	LD	A,#1B
SynBKI5Lp:
	EX	AF,AF'
	; idx[i] = current running pointer. Empty buckets naturally have
	; identical start/end boundaries and need no special marker.
	LD	(HL),C
	INC	HL
	LD	(HL),B
	INC	HL
	LD	A,(DE)				; bucket size
	INC	DE
	; BC += A (8-bit add to BC)
	ADD	A,C
	LD	C,A
	JR	NC,SynBKI5NoC
	INC	B
SynBKI5NoC:
	EX	AF,AF'
	DEC	A
	JR	NZ,SynBKI5Lp
	; idx[27] is the exclusive end of the final bucket.
	LD	(HL),C
	INC	HL
	LD	(HL),B
	RET


;[]===========================================================[]
SetupBuff:
	DEFW	#FFFF
;
 _mCollectInfo_addEnd
