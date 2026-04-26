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
	CALL	SynSeedBlockAtCursor
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
	CALL	SynEnsureProfileLoaded
	CALL	SynHighlightKeywords
	CALL	SynHighlightBrackets
	RET

SynSetupLineColors:
	LD	A,(CSComment)
	LD	(TmpColC),A
	LD	A,(CSMnemon)
	LD	(TmpColM),A
	LD	A,(CSLabel)
	LD	(TmpColL),A
	LD	A,(CSBrace)
	LD	(TmpColB),A
	LD	A,(ColTxtWin)
	LD	HL,SynLineAttr
	BIT	6,(HL)
	JR	Z,SynSLC0
SynSLSel:
	LD	A,(ColSelTxt)
	LD	(TmpColC),A
	LD	(TmpColM),A
	LD	(TmpColL),A
	LD	(TmpColB),A
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

; Detect language for the current window.
; On exit: A = 1 if a profile matched (SynProfileName filled with e.g. "c.syn"),
;          A = 0 if no profile matched (no highlighting).
SynDetectLang:
	XOR	A
	LD	(SynProfileName),A		; clear any previous profile name
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
	; DE = extension pointer in SynNameBuf (0 if no extension)
	PUSH	DE
	CALL	SynLoadIndexIfNeeded
	POP	DE
	LD	A,(SynIndexLoaded)
	CP	#01
	JR	NZ,SynDTryDirect
	PUSH	DE
	CALL	SynDetectLangViaIndex
	POP	DE
	OR	A
	RET	NZ
SynDTryDirect:
	; INDEX.LST had no match (or it's missing) — try loading <ext>.syn
	; directly from the SYNTAX directory. No-ext files (like "makefile")
	; only resolve through INDEX.LST.
	LD	A,D
	OR	E
	JR	Z,SynDNoMatch
	CALL	SynBuildExtProfileName
	LD	A,#01
	RET
SynDNoMatch:
	XOR	A
	RET

; Load SYNTAX\INDEX.LST into SynIndexBuf once per session.
; SynIndexLoaded: 0 = not attempted, 1 = success, #FF = failed (don't retry).
SynLoadIndexIfNeeded:
	LD	A,(SynIndexLoaded)
	OR	A
	RET	NZ
	LD	DE,SynIndexBuf
	LD	(SynLFDst),DE
	LD	DE,#017F
	LD	(SynLFMax),DE
	LD	HL,SynPathIndex
	CALL	SynLoadFileToBuf
	JR	C,SynLI_Fail
	LD	A,#01
	LD	(SynIndexLoaded),A
	RET
SynLI_Fail:
	LD	A,#FF
	LD	(SynIndexLoaded),A
	RET

; In: DE = pointer to filename extension in SynNameBuf (0 if no extension —
;         use whole filename for matching, covers e.g. "makefile").
; Out: A = 1 if a profile matched (SynProfileName is filled with the name
;         from INDEX.LST, e.g. "c.syn"), 0 if nothing matched.
SynDetectLangViaIndex:
	LD	A,D
	OR	E
	JR	NZ,SynDVI_HasExt
	LD	DE,SynNameBuf
SynDVI_HasExt:
	LD	HL,SynIndexBuf
SynDVI_LineLp:
	LD	A,(HL)
	OR	A
	JR	Z,SynDVI_NotFound
	CP	#0D
	JR	Z,SynDVI_NextLine
	CP	#0A
	JR	Z,SynDVI_NextLine
	CP	';'
	JR	Z,SynDVI_SkipLine
	CP	'#'
	JR	Z,SynDVI_SkipLine
	PUSH	HL				; save start of line (profile name)
SynDVI_SeekEq:
	LD	A,(HL)
	OR	A
	JR	Z,SynDVI_BadLine
	CP	#0D
	JR	Z,SynDVI_BadLine
	CP	#0A
	JR	Z,SynDVI_BadLine
	CP	'='
	JR	Z,SynDVI_FoundEq
	INC	HL
	JR	SynDVI_SeekEq
SynDVI_BadLine:
	POP	HL
	JR	SynDVI_SkipLine
SynDVI_FoundEq:
	INC	HL
	CALL	SynExtInCsvList
	JR	NZ,SynDVI_NoMatch
	POP	HL				; HL = start of profile name
	CALL	SynCopyProfileName		; copy to SynProfileName
	LD	A,#01
	RET
SynDVI_NoMatch:
	POP	HL
SynDVI_SkipLine:
	LD	A,(HL)
	OR	A
	JR	Z,SynDVI_NotFound
	CP	#0D
	JR	Z,SynDVI_NextLine
	CP	#0A
	JR	Z,SynDVI_NextLine
	INC	HL
	JR	SynDVI_SkipLine
SynDVI_NextLine:
	INC	HL
	JR	SynDVI_LineLp
SynDVI_NotFound:
	XOR	A
	RET

; Build SynProfileName = "<ext>.syn" from the extension pointer at DE.
; DE must be non-zero. Lowercases the extension so matching against a
; filesystem stored as .SYN still works on case-sensitive setups.
SynBuildExtProfileName:
	LD	HL,SynProfileName
	LD	B,#0F				; leave room for ".syn\0"
SynBEP_Lp:
	LD	A,B
	OR	A
	JR	Z,SynBEP_App
	LD	A,(DE)
	CP	#21				; stop on null, control chars, and space
	JR	C,SynBEP_App
	CP	'.'
	JR	Z,SynBEP_App
	CALL	SynToLower
	LD	(HL),A
	INC	HL
	INC	DE
	DEC	B
	JR	SynBEP_Lp
SynBEP_App:
	LD	(HL),'.'
	INC	HL
	LD	(HL),'s'
	INC	HL
	LD	(HL),'y'
	INC	HL
	LD	(HL),'n'
	INC	HL
	LD	(HL),0
	RET

; Copy profile name at HL (terminated by '=', 0, CR, LF) to SynProfileName.
; Null-terminates. Limits to buffer size.
SynCopyProfileName:
	LD	DE,SynProfileName
	LD	B,#13				; 19 chars max (+ 1 for null = 20)
SynCPN_Lp:
	LD	A,B
	OR	A
	JR	Z,SynCPN_End
	LD	A,(HL)
	OR	A
	JR	Z,SynCPN_End
	CP	'='
	JR	Z,SynCPN_End
	CP	#0D
	JR	Z,SynCPN_End
	CP	#0A
	JR	Z,SynCPN_End
	LD	(DE),A
	INC	DE
	INC	HL
	DEC	B
	JR	SynCPN_Lp
SynCPN_End:
	XOR	A
	LD	(DE),A
	RET

; Check whether null-terminated string at DE matches any comma-separated
; token in the list at HL. Tokens end at ',', 0, CR, or LF. Case-insensitive.
; Out: Z if any token matches, NZ if no match. Preserves DE. HL advanced.
SynExtInCsvList:
SynECL_Tok:
	PUSH	DE
SynECL_Cmp:
	LD	A,(HL)
	OR	A
	JR	Z,SynECL_TokEnd
	CP	','
	JR	Z,SynECL_TokEnd
	CP	#0D
	JR	Z,SynECL_TokEnd
	CP	#0A
	JR	Z,SynECL_TokEnd
	CALL	SynToLower
	LD	B,A
	LD	A,(DE)
	OR	A
	JR	Z,SynECL_Mismatch
	CALL	SynToLower
	CP	B
	JR	NZ,SynECL_Mismatch
	INC	HL
	INC	DE
	JR	SynECL_Cmp
SynECL_TokEnd:
	LD	A,(DE)
	OR	A
	JR	Z,SynECL_Match
SynECL_Mismatch:
	POP	DE
SynECL_Skip:
	LD	A,(HL)
	OR	A
	JR	Z,SynECL_End
	CP	#0D
	JR	Z,SynECL_End
	CP	#0A
	JR	Z,SynECL_End
	CP	','
	JR	Z,SynECL_NextTok
	INC	HL
	JR	SynECL_Skip
SynECL_NextTok:
	INC	HL
	JR	SynECL_Tok
SynECL_Match:
	POP	DE
	XOR	A
	RET
SynECL_End:
	LD	A,#01
	OR	A
	RET

; Scan for SynLineCom1 / SynLineCom2 patterns in the current line and paint
; from the match to end of line. If the profile declares a /*..*/ block
; comment (SynHasBlockCom=1), delegate to SynComC which handles both the
; "//" line comment and block state tracking.
SynHighlightComments:
	LD	A,(SynLang)
	OR	A
	RET	Z
	LD	A,(SynHasBlockCom)
	OR	A
	JR	NZ,SynComC
	LD	HL,SynLineCom1
	CALL	SynPaintFromStr
	LD	HL,SynLineCom2
	CALL	SynPaintFromStr
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

; Scan SynWorkBuf for the first occurrence of the null-terminated pattern at
; HL (1-3 chars typically). If found, paint TmpColC from the match position to
; end of line via SynPaintToEnd. Case-insensitive. No-op on empty pattern.
SynPaintFromStr:
	LD	A,(HL)
	OR	A
	RET	Z
	PUSH	IX
	PUSH	HL
	POP	IX
	LD	A,(SynLineLen)
	LD	B,A
	OR	A
	JR	Z,SynPFS_Exit
	LD	HL,(SynWorkBuf)
SynPFS_ScanLp:
	PUSH	HL
	PUSH	BC
	LD	C,B
	PUSH	IX
	POP	DE
SynPFS_MLp:
	LD	A,(DE)
	OR	A
	JR	Z,SynPFS_Hit
	LD	A,C
	OR	A
	JR	Z,SynPFS_Miss
	LD	A,(DE)
	CALL	SynToLower
	LD	B,A
	LD	A,(HL)
	CALL	SynToLower
	CP	B
	JR	NZ,SynPFS_Miss
	INC	HL
	INC	HL
	INC	DE
	DEC	C
	JR	SynPFS_MLp
SynPFS_Miss:
	POP	BC
	POP	HL
	INC	HL
	INC	HL
	DEC	B
	JR	NZ,SynPFS_ScanLp
SynPFS_Exit:
	POP	IX
	RET
SynPFS_Hit:
	POP	BC
	POP	HL
	CALL	SynPaintToEnd
	POP	IX
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
	PUSH	HL
	CALL	SynWordInList
	POP	HL
	JR	NZ,SynKWSkipWord
	LD	A,(SynKwColor)
	PUSH	HL
	CALL	SynColorWord
	POP	HL
SynKWSkipWord:
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

; Paint bracket characters listed in SynBrackets with TmpColB — only on
; chars still at SynBaseColor so we don't overpaint comments or strings.
SynHighlightBrackets:
	LD	A,(SynLineLen)
	OR	A
	RET	Z
	LD	B,A
	LD	HL,(SynWorkBuf)
SynHBLp:
	INC	HL
	LD	A,(HL)
	DEC	HL
	LD	C,A
	LD	A,(SynBaseColor)
	CP	C
	JR	NZ,SynHBNext
	LD	A,(HL)
	; Linear search through SynBrackets ASCIIZ list. Tiny list (<=7 chars)
	; so a per-char loop is simpler than a lookup table.
	PUSH	HL
	PUSH	BC
	LD	C,A
	LD	HL,SynBrackets
SynHBSc:
	LD	A,(HL)
	OR	A
	JR	Z,SynHBNoMatch
	CP	C
	JR	Z,SynHBMatch
	INC	HL
	JR	SynHBSc
SynHBNoMatch:
	POP	BC
	POP	HL
	JR	SynHBNext
SynHBMatch:
	POP	BC
	POP	HL
	INC	HL
	LD	A,(TmpColB)
	LD	(HL),A
	DEC	HL
SynHBNext:
	INC	HL
	INC	HL
	DEC	B
	JR	NZ,SynHBLp
	RET

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

; Seed SynCBlockOpen with state entering the first visible line.
; Assumes SynLang already set; walks UpLinePg lines from #8040.
SynSeedBlockFromTop:
	XOR	A
	LD	(SynCBlockOpen),A
	LD	A,(SynHasBlockCom)
	OR	A
	RET	Z
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
	LD	C,(IX+#00)
	LD	B,#00
	ADD	IX,BC
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

; Seed SynCBlockOpen with state entering the cursor line (BegString).
; Only runs for profiles that declare /*..*/ block comments. Walks #8040..BegString.
SynSeedBlockAtCursor:
	XOR	A
	LD	(SynCBlockOpen),A
	LD	A,(SynHasBlockCom)
	OR	A
	RET	Z
	LD	IX,#8040
	LD	DE,(BegString)
SynSBACLp:
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
	JR	SynSBACLp

; Reload the profile if SynProfileName differs from SynLoadedProf.
SynEnsureProfileLoaded:
	LD	HL,SynProfileName
	LD	DE,SynLoadedProf
	CALL	SynStrEq
	RET	Z
	; Different profile — copy new name into SynLoadedProf and (re)load.
	LD	HL,SynProfileName
	LD	DE,SynLoadedProf
	CALL	SynStrCopy20
	CALL	SynLoadProfile
	RET

; Load the profile identified by SynProfileName. Clears all per-profile
; state first so switching between profiles is clean.
SynLoadProfile:
	XOR	A
	LD	(SynKeywords1),A
	LD	(SynKeywords2),A
	LD	(SynLineCom1),A
	LD	(SynLineCom2),A
	LD	(SynHasBlockCom),A
	LD	(SynCaseSensitive),A
	; Default brackets = "()[]" if profile doesn't specify brackets= line.
	LD	HL,SynBracketsDefault
	LD	DE,SynBrackets
	CALL	SynStrCopyZ
	LD	A,(SynProfileName)
	OR	A
	RET	Z				; empty name — nothing to load
	; Build SYNTAX\<name> into SynProfilePath.
	LD	HL,SynDirPrefix
	LD	DE,SynProfilePath
	CALL	SynStrCopyZ
	DEC	DE				; overwrite the null from prefix
	LD	HL,SynProfileName
	CALL	SynStrCopyZ
	; Read the file.
	LD	HL,SynFileBuf
	LD	(SynLFDst),HL
	LD	HL,#03F0
	LD	(SynLFMax),HL
	LD	HL,SynProfilePath
	CALL	SynLoadFileToBuf
	RET	C
	CALL	SynParseProfileBuf
	CALL	SynDetectBlockCom
	RET

; Compare null-terminated strings at HL and DE. Z if equal, NZ if not.
; Preserves HL, DE.
SynStrEq:
	PUSH	HL
	PUSH	DE
SynSE_Lp:
	LD	A,(DE)
	LD	B,A
	LD	A,(HL)
	CP	B
	JR	NZ,SynSE_Ne
	OR	A
	JR	Z,SynSE_Eq
	INC	HL
	INC	DE
	JR	SynSE_Lp
SynSE_Eq:
	POP	DE
	POP	HL
	XOR	A
	RET
SynSE_Ne:
	POP	DE
	POP	HL
	LD	A,#01
	OR	A
	RET

; Copy null-terminated string from HL to DE (including null).
; On exit: HL, DE advanced past the null.
SynStrCopyZ:
SynSCZ_Lp:
	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	OR	A
	JR	NZ,SynSCZ_Lp
	RET

; Copy up to 20 bytes from HL to DE (SynProfileName size). Stops at null.
SynStrCopy20:
	LD	B,#14
SynSC20_Lp:
	LD	A,B
	OR	A
	JR	Z,SynSC20_End
	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	OR	A
	JR	Z,SynSC20_Ret
	DEC	B
	JR	SynSC20_Lp
SynSC20_End:
	XOR	A
	LD	(DE),A
SynSC20_Ret:
	RET

; Set SynHasBlockCom=1 iff SynLineCom2 contains exactly the two chars "/*".
SynDetectBlockCom:
	XOR	A
	LD	(SynHasBlockCom),A
	LD	HL,SynLineCom2
	LD	A,(HL)
	CP	'/'
	RET	NZ
	INC	HL
	LD	A,(HL)
	CP	'*'
	RET	NZ
	INC	HL
	LD	A,(HL)
	OR	A
	RET	NZ
	LD	A,#01
	LD	(SynHasBlockCom),A
	RET

; Load HL=<filename path> into (SynLFDst) for up to (SynLFMax) bytes,
; null-terminating after actual bytes read. Wraps file I/O with a
; CaptureDir/RestoreDir(LaunchPathBuf) pair so SYNTAX\*.SYN resolves
; relative to the KODE.EXE launch directory regardless of where the
; user has navigated. CF=0 on success, CF=1 on failure.
SynLoadFileToBuf:
	LD	(SynRelPath),HL			; stash relative path before any paging
	PUSH	IY
	; Page Dialog_Windows_PG2 into SLOT3 (so LaunchPathBuf/TempDirBuf are
	; reachable) AND DOSpage into SLOT0 (so RST #10 hits the DSS dispatcher).
	; CaptureDir/RestoreDir explicitly require DOSpage at SLOT0.
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(DialogPg2)
	OUT	(SLOT3),A
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)
	OUT	(SLOT0),A
	LD	BC,#7FFD
	LD	A,#10
	OUT	(C),A				; enable VG93
	; Save user's current dir, ChDir to launch dir (DSS-page is in SLOT0
	; now, so RST #10 inside CaptureDir/RestoreDir hits DSS dispatcher).
	LD	HL,TempDirBuf
	CALL	CaptureDir
	LD	HL,LaunchPathBuf
	CALL	RestoreDir
	; File I/O with relative path (DSS now in launch dir).
	LD	HL,(SynRelPath)
	LD	A,#01
	LD	C,#11
	RST	#10
	JR	C,SynLFFail
	LD	(SynProfHnd),A
	LD	HL,(SynLFDst)
	LD	DE,(SynLFMax)
	LD	A,(SynProfHnd)
	LD	C,#13
	RST	#10
	JR	C,SynLFCloseFail
	LD	HL,(SynLFDst)
	ADD	HL,DE
	XOR	A
	LD	(HL),A
	LD	A,(SynProfHnd)
	LD	C,#12
	RST	#10
	XOR	A
	LD	(SynLFRet),A
	JR	SynLFTeardown
SynLFCloseFail:
	LD	A,(SynProfHnd)
	LD	C,#12
	RST	#10
SynLFFail:
	LD	A,#01
	LD	(SynLFRet),A
SynLFTeardown:
	; Restore user's original directory while still in DOS state.
	LD	HL,TempDirBuf
	CALL	RestoreDir
	; Disable VG93, restore SLOT0 and SLOT3.
	LD	BC,#7FFD
	XOR	A
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A
	POP	AF
	OUT	(SLOT3),A
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
	JR	NZ,SynPPLC1
	CALL	SynParseCaseSensitive
	JR	SynPPSkip
SynPPLC1:
	; "line_comment=" — must check BEFORE "line_comment2=" since the
	; 14-char prefix of that line wouldn't match "line_comment=" (the '=' at
	; position 13 differs from '2'), so either order works.
	PUSH	HL
	LD	DE,SynKeyLC1
	CALL	SynLineStartsWith
	POP	HL
	JR	NZ,SynPPLC2
	CALL	SynCopyValueLC1
	JR	SynPPSkip
SynPPLC2:
	PUSH	HL
	LD	DE,SynKeyLC2
	CALL	SynLineStartsWith
	POP	HL
	JR	NZ,SynPPBR
	CALL	SynCopyValueLC2
	JR	SynPPSkip
SynPPBR:
	PUSH	HL
	LD	DE,SynKeyBrackets
	CALL	SynLineStartsWith
	POP	HL
	JR	NZ,SynPPSkip
	CALL	SynCopyValueBrackets
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

SynCopyValueLC1:
	LD	DE,SynLineCom1
	JR	SynCopyValueLineCom
SynCopyValueLC2:
	LD	DE,SynLineCom2
SynCopyValueLineCom:
	PUSH	DE
	CALL	SynSeekEq
	POP	DE
	RET	C
	LD	B,#03				; up to 3 chars (+ 1 null = buffer of 4)
SynCVL0:
	LD	A,B
	OR	A
	JR	Z,SynCVLEnd
	LD	A,(HL)
	OR	A
	JR	Z,SynCVLEnd
	CP	#0D
	JR	Z,SynCVLEnd
	CP	#0A
	JR	Z,SynCVLEnd
	LD	(DE),A
	INC	DE
	INC	HL
	DEC	B
	JR	SynCVL0
SynCVLEnd:
	XOR	A
	LD	(DE),A
	RET

; Parse "brackets=..." value (up to 7 chars) into SynBrackets buffer.
SynCopyValueBrackets:
	LD	DE,SynBrackets
	PUSH	DE
	CALL	SynSeekEq
	POP	DE
	RET	C
	LD	B,#07				; up to 7 bracket chars (+ 1 null = buffer of 8)
SynCVB0:
	LD	A,B
	OR	A
	JR	Z,SynCVBEnd
	LD	A,(HL)
	OR	A
	JR	Z,SynCVBEnd
	CP	#0D
	JR	Z,SynCVBEnd
	CP	#0A
	JR	Z,SynCVBEnd
	LD	(DE),A
	INC	DE
	INC	HL
	DEC	B
	JR	SynCVB0
SynCVBEnd:
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
SynIndexLoaded:	DEFB	#00		; 0=not attempted, 1=loaded ok, #FF=load failed
SynLFDst:	DEFW	#0000		; destination buffer for SynLoadFileToBuf
SynLFMax:	DEFW	#0000		; max bytes to read for SynLoadFileToBuf
SynRelPath:	DEFW	#0000		; relative path saved across page swaps in SynLoadFileToBuf
SynHasBlockCom:	DEFB	#00		; 1 if profile uses /*..*/ block comments
SynLineCom1:	DEFS	4,0		; line-comment pattern 1 (up to 3 chars + null)
SynLineCom2:	DEFS	4,0		; line-comment pattern 2 (or "/*" block opener)
SynBrackets:	DEFS	8,0		; bracket chars to highlight (up to 7 + null)
SynToken:	DEFS	24,0
SynNameBuf:	DEFS	64,0
SynWorkBuf:	DEFW	#0000
SynKwPtr:	DEFW	#0000
SynProfileName:	DEFS	20,0		; profile file name from INDEX.LST (e.g. "c.syn")
SynLoadedProf:	DEFS	20,0		; cached name of profile currently loaded
SynProfilePath:	DEFS	32,0		; constructed full path "SYNTAX\<name>"
SynKeywords1:	DEFS	512,0
SynKeywords2:	DEFS	256,0
SynFileBuf:	DEFS	1024,0
SynIndexBuf:	DEFS	384,0

SynPathIndex:	DEFB	"SYNTAX\\INDEX.LST",0
SynDirPrefix:	DEFB	"SYNTAX\\",0

SynKeyKw1:	DEFB	"keywords=",0
SynKeyKw2:	DEFB	"keywords2=",0
SynKeyCase:	DEFB	"case_sensitive=",0
SynKeyLC1:	DEFB	"line_comment=",0
SynKeyLC2:	DEFB	"line_comment2=",0
SynKeyBrackets:	DEFB	"brackets=",0
SynBracketsDefault:	DEFB	"()[]",0

 _mCollectInfo_addEnd
