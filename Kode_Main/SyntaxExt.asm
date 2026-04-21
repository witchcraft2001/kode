 _mCollectInfo_addStart

; Stable lightweight syntax highlighter.
; No file I/O, no dynamic profile loading.

SyntaxExtTry:
	LD	A,(IY+#02)
	LD	(SynLineLen),A
	LD	HL,(BegString)
	INC	HL
	LD	A,(HL)
	LD	(SynLineAttr),A
	LD	HL,TextBuff
	LD	(SynWorkBuf),HL
	JP	SyntaxExtTryBuf

; Syntax-highlight an arbitrary decompiled line buffer.
; In: HL = buffer (char,attr,char,attr,...), IX = packed line header
;     (IX+0 = text_len+3, IX+1 = attr byte, bit 6 = selected)
SyntaxExtLine:
	LD	(SynWorkBuf),HL
	LD	A,(IX+#00)
	CP	#03
	JR	NC,SynExLn0
	LD	A,#03
SynExLn0:
	SUB	#03
	LD	(SynLineLen),A
	LD	A,(IX+#01)
	LD	(SynLineAttr),A
	JP	SyntaxExtTryBuf

SyntaxExtTryBuf:
	LD	A,(SynRenderPass)
	OR	A
	JR	NZ,SynExtRender
	CALL	SynSetupLineColors
	CALL	SynDetectLang
	LD	(SynLang),A
	OR	A
	RET	Z
	CALL	SynSeedBlockToCurrent
	JR	SynExtRun

SynExtRender:
	CALL	SynSetupLineColors
	LD	A,(SynRenderLangValid)
	OR	A
	JR	Z,SynExtRDet
	LD	A,(SynRenderLang)
	LD	(SynLang),A
	OR	A
	RET	Z
	JR	SynExtRun

SynExtRDet:
	CALL	SynDetectLang
	LD	(SynLang),A
	LD	(SynRenderLang),A
	LD	A,#01
	LD	(SynRenderLangValid),A
	LD	A,(SynLang)
	OR	A
	RET	Z
	JR	SynExtRun
SynExtRun:
	CALL	SynHighlightComments
	RET

SynSetupLineColors:
	LD	A,(CSComment)
	LD	(TmpColC),A
	LD	A,(CSMnemon)
	LD	(TmpColM),A
	LD	A,(CSLabel)
	LD	(TmpColL),A
	LD	A,(ColTxtWin)
	LD	HL,SynLineAttr
	BIT	6,(HL)
	JR	Z,SynSLC0
SynSLSel:
	LD	A,(ColSelTxt)
	LD	(TmpColC),A
	LD	(TmpColM),A
	LD	(TmpColL),A
SynSLC0:
	LD	(SynBaseColor),A
	LD	C,A
	LD	A,(SynLineLen)
	LD	B,A
	OR	A
	RET	Z
	LD	HL,(SynWorkBuf)
	INC	HL
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
	JP	Z,SynDNone
	LD	H,D
	LD	L,E
	LD	DE,SynExtC
	CALL	SynExtEq
	JP	Z,SynIsC
	LD	DE,SynExtH
	CALL	SynExtEq
	JP	Z,SynIsC
	LD	DE,SynExtCpp
	CALL	SynExtEq
	JP	Z,SynIsC
	LD	DE,SynExtHpp
	CALL	SynExtEq
	JP	Z,SynIsC
	LD	DE,SynExtBat
	CALL	SynExtEq
	JP	Z,SynIsBat
	LD	DE,SynExtCmd
	CALL	SynExtEq
	JP	Z,SynIsBat
	LD	DE,SynExtMk
	CALL	SynExtEq
	JP	Z,SynIsMake
	LD	DE,SynExtMak
	CALL	SynExtEq
	JP	Z,SynIsMake
	LD	DE,SynExtMake
	CALL	SynExtEq
	JP	Z,SynIsMake
	LD	DE,SynExtAsm
	CALL	SynExtEq
	JP	Z,SynIsAsm
	LD	DE,SynExtZ80
	CALL	SynExtEq
	JP	Z,SynIsAsm
	LD	DE,SynExtZas
	CALL	SynExtEq
	JP	Z,SynIsAsm
	LD	DE,SynExtTas
	CALL	SynExtEq
	JP	Z,SynIsAsm
	LD	DE,SynExtInc
	CALL	SynExtEq
	JP	Z,SynIsAsm
	LD	DE,SynExtS
	CALL	SynExtEq
	JP	Z,SynIsAsm
SynDNone:
	LD	HL,SynNameBuf
	LD	DE,SynNmMakefile
	CALL	SynNameEqNoCase
	JR	Z,SynIsMake
	LD	HL,SynNameBuf
	LD	DE,SynNmGnumake
	CALL	SynNameEqNoCase
	JR	Z,SynIsMake
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
	LD	A,(SynLineLen)
	LD	B,A
	LD	HL,(SynWorkBuf)
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
	LD	A,(SynCBlockOpen)
	OR	A
	JR	Z,SynComCScan
	LD	HL,(SynWorkBuf)
	LD	A,(SynLineLen)
	LD	B,A
	CALL	SynPaintToEnd
	CALL	SynFindBlockClose
	RET	C
	XOR	A
	LD	(SynCBlockOpen),A
	RET
SynComCScan:
	LD	A,(SynLineLen)
	LD	B,A
	LD	HL,(SynWorkBuf)
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
	JR	Z,SynCCBlock
	DEC	HL
	DEC	HL
	INC	B
	JR	SynCCNext
SynCCBlock:
	DEC	HL
	DEC	HL
	INC	B
	CALL	SynPaintToEnd
	CALL	SynFindBlockClose
	RET	NC
	LD	A,#01
	LD	(SynCBlockOpen),A
	RET
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
	LD	A,(SynLineLen)
	LD	B,A
	LD	HL,(SynWorkBuf)
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

SynHighlightKeywords:
	LD	HL,SynKeywords1
	LD	A,(HL)
	OR	A
	RET	Z
	LD	A,(TmpColM)
	LD	(SynKwColor),A
	LD	HL,SynKeywords1
	LD	(SynKwPtr),HL
	CALL	SynHighlightKeywordsOne
	LD	HL,SynKeywords2
	LD	A,(HL)
	OR	A
	RET	Z
	LD	A,(TmpColL)
	LD	(SynKwColor),A
	LD	HL,SynKeywords2
	LD	(SynKwPtr),HL
	CALL	SynHighlightKeywordsOne
	RET

SynHighlightKeywordsOne:
	LD	A,(SynLineLen)
	LD	B,A
	LD	HL,(SynWorkBuf)
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
	LD	DE,(SynKwPtr)
	CALL	SynWordInList
	JR	NZ,SynKWNext
	LD	A,(SynKwColor)
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
	LD	A,(SynCaseSensitive)
	OR	A
	JR	NZ,SynCWNoLower
	LD	A,(HL)
	CALL	SynToLower
	JR	SynCWStore
SynCWNoLower:
	LD	A,(HL)
SynCWStore:
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
	LD	B,A
	LD	A,(SynCaseSensitive)
	OR	A
	LD	A,B
	JR	NZ,SynWCmpKeep
	CALL	SynToLower
SynWCmpKeep:
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

SynFindBlockClose:
	LD	A,(SynLineLen)
	LD	B,A
	LD	HL,(SynWorkBuf)
SynFBC0:
	LD	A,B
	OR	A
	SCF
	RET	Z
	LD	A,(HL)
	CP	'*'
	JR	NZ,SynFBCN
	INC	HL
	INC	HL
	DEC	B
	LD	A,B
	OR	A
	SCF
	RET	Z
	LD	A,(HL)
	CP	'/'
	JR	Z,SynFBCF
	DEC	HL
	DEC	HL
	INC	B
SynFBCN:
	INC	HL
	INC	HL
	DEC	B
	JR	SynFBC0
SynFBCF:
	OR	A
	RET

SynSeedBlockFromTop:
	XOR	A
	LD	(SynCBlockOpen),A
	CALL	SynDetectLang
	CP	#01
	RET	NZ
	LD	IX,#8040
	LD	HL,(UpLinePg)
	LD	A,H
	OR	L
	RET	Z
SynSBTLp:
	LD	A,(IX+#00)
	OR	A
	RET	Z
	PUSH	HL
	CALL	SynScanCompLine
	POP	HL
	DEC	HL
	LD	A,H
	OR	L
	RET	Z
	LD	E,(IX+#00)
	LD	D,#00
	ADD	IX,DE
	JR	SynSBTLp

SynScanCompLine:
	LD	A,(IX+#00)
	CP	#03
	RET	C
	SUB	#03
	LD	B,A
	PUSH	IX
	POP	HL
	INC	HL
	INC	HL
SynSCLp:
	LD	A,B
	OR	A
	RET	Z
	LD	A,(SynCBlockOpen)
	OR	A
	JR	Z,SynSCOut
	LD	A,B
	CP	#02
	RET	C
	LD	A,(HL)
	CP	'*'
	JR	NZ,SynSCStep
	INC	HL
	DEC	B
	LD	A,(HL)
	CP	'/'
	JR	NZ,SynSCLp
	XOR	A
	LD	(SynCBlockOpen),A
	INC	HL
	DEC	B
	JR	SynSCLp

SynSCOut:
	LD	A,B
	CP	#02
	RET	C
	LD	A,(HL)
	CP	'/'
	JR	NZ,SynSCStep
	INC	HL
	DEC	B
	LD	A,(HL)
	CP	'/'
	RET	Z
	CP	'*'
	JR	NZ,SynSCLp
	LD	A,#01
	LD	(SynCBlockOpen),A
	INC	HL
	DEC	B
	JR	SynSCLp

SynSCStep:
	INC	HL
	DEC	B
	JR	SynSCLp

SynSeedBlockToCurrent:
	XOR	A
	LD	(SynCBlockOpen),A
	LD	A,(SynLang)
	CP	#01
	RET	NZ
	LD	IX,(AdrPage)
	LD	DE,(BegString)
SynSBCLp:
	PUSH	IX
	POP	HL
	OR	A
	SBC	HL,DE
	RET	Z
	LD	A,(IX+#00)
	OR	A
	RET	Z
	CALL	SynScanCompLine
	LD	C,(IX+#00)
	LD	B,#00
	ADD	IX,BC
	JR	SynSBCLp

SynEnsureProfileLoaded:
	LD	A,(SynLang)
	LD	B,A
	LD	A,(SynLoadedLang)
	CP	B
	RET	Z
	LD	A,B
	LD	(SynLoadedLang),A
	CALL	SynLoadProfileForLang
	RET

SynLoadProfileForLang:
	LD	HL,SynKeywords1
	XOR	A
	LD	(HL),A
	LD	HL,SynKeywords2
	LD	(HL),A
	LD	A,(SynLang)
	CP	#01
	JR	NZ,SynLPNoDefC
	LD	HL,SynCKeywords
	LD	DE,SynKeywords1
	CALL	SynCopyCsv
SynLPNoDefC:
	LD	A,(SynLang)
	CP	#01
	JR	Z,SynLP_C
	CP	#02
	JR	Z,SynLP_Asm
	CP	#03
	JR	Z,SynLP_Bat
	CP	#04
	JR	Z,SynLP_Make
	RET
SynLP_C:
	LD	HL,SynPathC
	JR	SynLP_Open
SynLP_Asm:
	LD	HL,SynPathAsm
	JR	SynLP_Open
SynLP_Bat:
	LD	HL,SynPathBat
	JR	SynLP_Open
SynLP_Make:
	LD	HL,SynPathMake
SynLP_Open:
	CALL	SynLoadFileToBuf
	RET	C
	CALL	SynParseProfileBuf
	RET

SynLoadFileToBuf:
	PUSH	IY
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)
	OUT	(SLOT0),A
	LD	BC,#7FFD
	LD	A,#10
	OUT	(C),A
	LD	A,#01
	LD	C,#11
	RST	#10
	JR	C,SynLFFail
	LD	(SynProfHnd),A
	LD	HL,SynFileBuf
	LD	DE,#03F0
	LD	A,(SynProfHnd)
	LD	C,#13
	RST	#10
	JR	C,SynLFCloseFail
	LD	HL,SynFileBuf
	ADD	HL,DE
	XOR	A
	LD	(HL),A
	LD	A,(SynProfHnd)
	LD	C,#12
	RST	#10
	XOR	A
	LD	(SynLFRet),A
	JR	SynLFExit
SynLFCloseFail:
	LD	A,(SynProfHnd)
	LD	C,#12
	RST	#10
SynLFFail:
	LD	A,#01
	LD	(SynLFRet),A
SynLFExit:
	LD	BC,#7FFD
	XOR	A
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A
	POP	IY
	LD	A,(SynLFRet)
	OR	A
	JR	Z,SynLFOk
	SCF
	RET
SynLFOk:
	OR	A
	RET

SynParseProfileBuf:
	LD	HL,SynFileBuf
SynPPLine:
	LD	A,(HL)
	OR	A
	RET	Z
	CP	#0D
	JR	Z,SynPPNext
	CP	#0A
	JR	Z,SynPPNext
	CP	';'
	JR	Z,SynPPSkip
	CP	'#'
	JR	Z,SynPPSkip
	PUSH	HL
	LD	DE,SynKeyKw1
	CALL	SynLineStartsWith
	POP	HL
	JR	NZ,SynPPK2
	CALL	SynCopyValueKw1
	JR	SynPPSkip
SynPPK2:
	PUSH	HL
	LD	DE,SynKeyKw2
	CALL	SynLineStartsWith
	POP	HL
	JR	NZ,SynPPCS
	CALL	SynCopyValueKw2
	JR	SynPPSkip
SynPPCS:
	PUSH	HL
	LD	DE,SynKeyCase
	CALL	SynLineStartsWith
	POP	HL
	JR	NZ,SynPPSkip
	CALL	SynParseCaseSensitive
SynPPSkip:
	LD	A,(HL)
	OR	A
	RET	Z
	CP	#0D
	JR	Z,SynPPNext
	CP	#0A
	JR	Z,SynPPNext
	INC	HL
	JR	SynPPSkip
SynPPNext:
	INC	HL
	JR	SynPPLine

SynLineStartsWith:
	PUSH	HL
SynLSW0:
	LD	A,(DE)
	OR	A
	JR	Z,SynLSWYes
	LD	B,A
	LD	A,(HL)
	CALL	SynToLower
	CP	B
	JR	NZ,SynLSWNo
	INC	HL
	INC	DE
	JR	SynLSW0
SynLSWYes:
	POP	HL
	XOR	A
	RET
SynLSWNo:
	POP	HL
	LD	A,#01
	OR	A
	RET

SynCopyValueKw1:
	LD	DE,SynKeywords1
	JR	SynCopyValueCommon
SynCopyValueKw2:
	LD	DE,SynKeywords2
SynCopyValueCommon:
	PUSH	DE
	CALL	SynSeekEq
	POP	DE
	RET	C
SynCVC0:
	LD	A,(HL)
	OR	A
	JR	Z,SynCVCEnd
	CP	#0D
	JR	Z,SynCVCEnd
	CP	#0A
	JR	Z,SynCVCEnd
	LD	(DE),A
	INC	DE
	INC	HL
	JR	SynCVC0
SynCVCEnd:
	XOR	A
	LD	(DE),A
	RET

SynParseCaseSensitive:
	CALL	SynSeekEq
	RET	C
	LD	A,(HL)
	CP	'1'
	JR	NZ,SynPCS0
	LD	A,#01
	LD	(SynCaseSensitive),A
	RET
SynPCS0:
	XOR	A
	LD	(SynCaseSensitive),A
	RET

SynSeekEq:
SynSE0:
	LD	A,(HL)
	OR	A
	SCF
	RET	Z
	CP	'='
	JR	Z,SynSE1
	CP	#0D
	SCF
	RET	Z
	CP	#0A
	SCF
	RET	Z
	INC	HL
	JR	SynSE0
SynSE1:
	INC	HL
	OR	A
	RET

SynCopyCsv:
SynCSV0:
	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	OR	A
	JR	NZ,SynCSV0
	RET

SynNameEqNoCase:
	PUSH	HL
	PUSH	DE
SynNE0:
	LD	A,(DE)
	OR	A
	JR	Z,SynNEEnd
	LD	B,A
	LD	A,(HL)
	CP	'.'
	JR	Z,SynNENo
	OR	A
	JR	Z,SynNENo
	CALL	SynToLower
	CP	B
	JR	NZ,SynNENo
	INC	HL
	INC	DE
	JR	SynNE0
SynNEEnd:
	LD	A,(HL)
	OR	A
	JR	Z,SynNEYes
	CP	'.'
	JR	Z,SynNEYes
SynNENo:
	POP	DE
	POP	HL
	LD	A,#01
	OR	A
	RET
SynNEYes:
	POP	DE
	POP	HL
	XOR	A
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
	RES	7,A
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
SynLoadedLang:	DEFB	#FF
SynCBlockOpen:	DEFB	#00
SynRenderPass:	DEFB	#00
SynRenderLangValid:	DEFB	#00
SynRenderLang:	DEFB	#00
SynCaseSensitive:	DEFB	#00
SynLineLen:	DEFB	#00
SynLineAttr:	DEFB	#00
SynTokenLen:	DEFB	#00
SynKwColor:	DEFB	#00
SynProfHnd:	DEFB	#00
SynLFRet:	DEFB	#01
SynToken:	DEFS	24,0
SynNameBuf:	DEFS	64,0
SynWorkBuf:	DEFW	#0000
SynKwPtr:	DEFW	#0000
SynKeywords1:	DEFS	512,0
SynKeywords2:	DEFS	256,0
SynFileBuf:	DEFS	1024,0

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

SynNmMakefile:	DEFB	"makefile",0
SynNmGnumake:	DEFB	"gnumakefile",0

SynPathC:	DEFB	"SYNTAX\\C.SYN",0
SynPathAsm:	DEFB	"SYNTAX\\ASM.SYN",0
SynPathBat:	DEFB	"SYNTAX\\BAT.SYN",0
SynPathMake:	DEFB	"SYNTAX\\MAKEFILE.SYN",0

SynKeyKw1:	DEFB	"keywords=",0
SynKeyKw2:	DEFB	"keywords2=",0
SynKeyCase:	DEFB	"case_sensitive=",0

SynCKeywords:
	DEFB	"if,else,for,while,do,switch,case,default,break,continue,return,"
	DEFB	"struct,enum,typedef,const,static,extern,volatile,unsigned,signed,"
	DEFB	"int,char,long,short,float,double,void,sizeof,goto,register",0

 _mCollectInfo_addEnd
