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
	CALL	SynEnsureProfileLoaded
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
	CALL	SynCacheBlockIX
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
	CALL	SynEnsureProfileLoaded
	LD	A,#01
	LD	(SynRenderLangValid),A
	CALL	SynCacheBlockIX
	JR	SynExtRun
SynExtRun:
	CALL	SynHighlightComments
	CALL	SynHighlightStrings
	CALL	SynHighlightNumbers
	CALL	SynHighlightKeywords
	CALL	SynHighlightBrackets
	RET

; Detect and load the syntax profile once before a multi-line render pass,
; then seed block-comment state with the new profile already active.
SynPrepareRender:
	CALL	SynDetectLang
	LD	(SynLang),A
	LD	(SynRenderLang),A
	OR	A
	JR	Z,SynPRReady
	CALL	SynEnsureProfileLoaded
	CALL	SynSeedBlockFromTop
SynPRReady:
	LD	A,#01
	LD	(SynRenderLangValid),A
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
	LD	A,(CSString)
	LD	(TmpColS),A
	LD	A,(CSNumber)
	LD	(TmpColN),A
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
	LD	(TmpColS),A
	LD	(TmpColN),A
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
	; SynDetectLangViaIndex scans SynIndexBuf which lives in
	; Dialog_Windows_PG2; page it in for the duration of the scan.
	; SynPageDp2Out preserves AF, so the post-call OR A still sees the
	; success flag returned by SynDetectLangViaIndex.
	CALL	SynPageDp2In
	CALL	SynDetectLangViaIndex
	CALL	SynPageDp2Out
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
	LD	DE,#00FF			; SynIndexBuf is 256 bytes; reserve 1 for null
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
	JR	NZ,SynHKRun
	LD	HL,SynKeywords2
	LD	A,(HL)
	OR	A
	RET	Z
SynHKRun:
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
	CP	'#'
	JR	Z,SynKWCollect
	CALL	SynIsWordStart
	JR	C,SynKWNext
SynKWCollect:
	PUSH	BC
	PUSH	HL
	CALL	SynCollectWord
	POP	HL
	POP	BC
	JR	C,SynKWNext
	LD	A,(SynKeywords1)
	OR	A
	JR	Z,SynKWSecond
	LD	DE,SynKw1Idx
	PUSH	HL
	CALL	SynWordInListIdx
	POP	HL
	JR	NZ,SynKWSecond
	LD	A,(TmpColM)
	JR	SynKWPaint
SynKWSecond:
	LD	A,(SynKeywords2)
	OR	A
	JR	Z,SynKWSkipWord
	LD	DE,SynKw2Idx
	PUSH	HL
	CALL	SynWordInListIdx
	POP	HL
	JR	NZ,SynKWSkipWord
	LD	A,(TmpColL)
SynKWPaint:
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

; Look up SynToken in a sorted+indexed keyword list.
; In:  DE = idx buffer (56 bytes — 28 boundary pointers built by
;      SynBuildKwIndex / SynRebuildKwIndex)
;      SynToken / SynTokenLen — token to match (already lowered if profile
;      is case-insensitive)
; Out: Z if SynToken matches some keyword; NZ otherwise. HL is clobbered.
SynWordInListIdx:
	LD	A,(SynToken)			; first letter
	OR	A
	JR	Z,SynWIxNo			; empty token
	PUSH	DE
	CALL	SynLetterBucket			; A = bucket
	POP	DE
	; HL = idx + 2*A
	ADD	A,A
	LD	L,A
	LD	H,#00
	ADD	HL,DE
	; Read bucket start and the following boundary (exclusive end).
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	LD	(SynKwEnd),BC
SynWIxLp:
	LD	HL,(SynKwEnd)
	OR	A
	SBC	HL,DE
	JR	Z,SynWIxNo			; empty bucket / end of range
	LD	A,(DE)
	OR	A
	JR	Z,SynWIxNo
	; Full compare SynToken vs current word (case already aligned)
	PUSH	DE
	LD	HL,SynToken
	LD	A,(SynTokenLen)
	LD	B,A				; B = remaining chars to compare
SynWIxCmp:
	LD	A,B
	OR	A
	JR	Z,SynWIxCmpEnd
	LD	A,(DE)
	OR	A
	JR	Z,SynWIxCmpFail
	CP	','
	JR	Z,SynWIxCmpFail
	CP	' '
	JR	Z,SynWIxCmpFail
	CP	(HL)
	JR	NZ,SynWIxCmpFail
	INC	DE
	INC	HL
	DEC	B
	JR	SynWIxCmp
SynWIxCmpEnd:
	; Token consumed; current word must end here (NUL/','/space) for match
	LD	A,(DE)
	OR	A
	JR	Z,SynWIxYes
	CP	','
	JR	Z,SynWIxYes
	CP	' '
	JR	Z,SynWIxYes
SynWIxCmpFail:
	POP	DE
	; Skip rest of current word until ','
SynWIxSkip:
	LD	A,(DE)
	OR	A
	JR	Z,SynWIxNo
	CP	','
	JR	Z,SynWIxNext
	INC	DE
	JR	SynWIxSkip
SynWIxNext:
	INC	DE				; consume ','
	JR	SynWIxLp
SynWIxYes:
	POP	DE				; restore the saved entry pointer
	XOR	A
	RET
SynWIxNo:
	LD	A,#01
	OR	A
	RET

; Paint string literals delimited by characters listed in SynStringDelims
; (e.g. " or '). Only the OPENING delimiter is required to be at base
; color (so we never start a string inside a comment); inside the string
; we paint unconditionally, so the string can span chars that other passes
; might have touched.
SynHighlightStrings:
	LD	A,(SynStringDelims)
	OR	A
	RET	Z				; no delims configured for this profile
	LD	A,(SynLineLen)
	OR	A
	RET	Z
	LD	B,A				; B = remaining char-pairs to scan
	LD	HL,(SynWorkBuf)
SynHSScanCh:
	INC	HL
	LD	A,(HL)
	DEC	HL
	LD	C,A				; C = current attribute
	LD	A,(SynBaseColor)
	CP	C
	JR	NZ,SynHSSkipCh			; not at base — skip this char
	LD	A,(HL)				; current char
	LD	C,A
	PUSH	HL
	LD	HL,SynStringDelims
SynHSDelimLp:
	LD	A,(HL)
	OR	A
	JR	Z,SynHSNoDelim
	CP	C
	JR	Z,SynHSStart
	INC	HL
	JR	SynHSDelimLp
SynHSNoDelim:
	POP	HL
	JR	SynHSSkipCh
SynHSStart:
	POP	HL				; HL → opening delim char
	; C = the matched delim character (used as closing delim)
	INC	HL
	LD	A,(TmpColS)
	LD	(HL),A
	DEC	HL
	INC	HL
	INC	HL
	DEC	B
	RET	Z
SynHSInside:
	LD	A,(HL)
	CP	#5C
	JR	Z,SynHSEscape
	CP	C
	JR	Z,SynHSClose
	INC	HL
	LD	A,(TmpColS)
	LD	(HL),A
	DEC	HL
	INC	HL
	INC	HL
	DEC	B
	JR	NZ,SynHSInside
	RET					; ran off line without close — leave as is
SynHSEscape:
	; A backslash protects the following character, including the delimiter.
	INC	HL
	LD	A,(TmpColS)
	LD	(HL),A
	INC	HL
	DEC	B
	RET	Z
	INC	HL
	LD	A,(TmpColS)
	LD	(HL),A
	INC	HL
	DEC	B
	JR	NZ,SynHSInside
	RET
SynHSClose:
	INC	HL
	LD	A,(TmpColS)
	LD	(HL),A
	DEC	HL
	INC	HL
	INC	HL
	DEC	B
	JR	NZ,SynHSScanCh
	RET
SynHSSkipCh:
	INC	HL
	INC	HL
	DEC	B
	JR	NZ,SynHSScanCh
	RET

; Paint complete numeric literals before the keyword pass. Supported forms:
; decimal digits, #/$-prefixed hex digits, C-style 0x/0X hex digits, and an
; attached leading +/- sign.
; A candidate touching an identifier char is rejected as a whole, so #define
; is not mistaken for a hex number while #BC is protected from keyword lookup.
SynHighlightNumbers:
	LD	A,(SynLineLen)
	OR	A
	RET	Z
	LD	B,A				; B = remaining chars
	LD	HL,(SynWorkBuf)
SynHNScan:
	LD	A,B
	OR	A
	RET	Z
	INC	HL
	LD	A,(HL)
	DEC	HL
	LD	C,A
	LD	A,(SynBaseColor)
	CP	C
	JR	NZ,SynHNAdvance
	LD	A,(HL)
	CP	'+'
	JR	Z,SynHNTry
	CP	'-'
	JR	Z,SynHNTry
	CP	'#'
	JR	Z,SynHNTry
	CP	'$'
	JR	Z,SynHNTry
	CP	'0'
	JR	C,SynHNCheckId
	CP	'9'+1
	JR	C,SynHNTry
SynHNCheckId:
	CALL	SynIsIdChar
	JR	C,SynHNAdvance
	; Skip a non-numeric identifier as one unit so digits inside it are never
	; reconsidered as number starts.
SynHNSkipId:
	INC	HL
	INC	HL
	DEC	B
	RET	Z
	INC	HL
	LD	A,(HL)
	DEC	HL
	LD	C,A
	LD	A,(SynBaseColor)
	CP	C
	JR	NZ,SynHNScan
	LD	A,(HL)
	CALL	SynIsIdChar
	JR	NC,SynHNSkipId
	JR	SynHNScan
SynHNTry:
	CALL	SynNumberLength
	OR	A
	JR	Z,SynHNAdvance
	LD	(SynTokenLen),A
	LD	E,A
	LD	D,#00
	LD	A,(TmpColN)
	PUSH	HL
	CALL	SynColorWord
	POP	HL
	ADD	HL,DE
	ADD	HL,DE
	LD	A,B
	SUB	E
	LD	B,A
	JR	SynHNScan
SynHNAdvance:
	INC	HL
	INC	HL
	DEC	B
	JR	NZ,SynHNScan
	RET

; Validate the numeric candidate at HL without painting it.
; In: HL = char/attr pair, B = remaining chars.
; Out: A = full literal length, or 0 if the complete token is not a number.
;      HL and BC are preserved.
SynNumberLength:
	PUSH	HL
	PUSH	BC
	LD	C,B
	LD	E,#00				; accepted length
	LD	A,(HL)
	CP	'+'
	JR	Z,SynNLSign
	CP	'-'
	JR	NZ,SynNLBase
SynNLSign:
	INC	HL
	INC	HL
	DEC	C
	INC	E
	JR	Z,SynNLBad
	LD	A,(HL)
SynNLBase:
	CP	'#'
	JR	Z,SynNLHexPrefix
	CP	'$'
	JR	Z,SynNLHexPrefix
	CP	'0'
	JR	C,SynNLBad
	CP	'9'+1
	JR	NC,SynNLBad
	CP	'0'
	JR	NZ,SynNLDecLoop
	; C/C++ hexadecimal prefix: 0x or 0X. Peek at the second character;
	; ordinary zero-prefixed decimal values stay on the decimal path.
	LD	A,C
	CP	#03
	JR	C,SynNLDecLoop			; need prefix plus at least one digit
	INC	HL
	INC	HL
	LD	A,(HL)
	CALL	SynToLower
	CP	'x'
	JR	NZ,SynNLZeroDec
	INC	HL
	INC	HL
	DEC	C
	DEC	C
	INC	E
	INC	E
	LD	A,(HL)
	CALL	SynIsHexDigit
	JR	C,SynNLBad
	JR	SynNLHexLoop
SynNLZeroDec:
	DEC	HL
	DEC	HL
SynNLDecLoop:
	INC	HL
	INC	HL
	DEC	C
	INC	E
	JR	Z,SynNLOk
	LD	A,(HL)
	CP	'0'
	JR	C,SynNLDecEnd
	CP	'9'+1
	JR	C,SynNLDecLoop
SynNLDecEnd:
	CALL	SynIsIdChar
	JR	NC,SynNLBad			; e.g. 123abc is an identifier, not a number
	JR	SynNLOk
SynNLHexPrefix:
	INC	HL
	INC	HL
	DEC	C
	INC	E
	JR	Z,SynNLBad			; standalone #/$
	LD	A,(HL)
	CALL	SynIsHexDigit
	JR	C,SynNLBad			; prefix must be followed by a hex digit
SynNLHexLoop:
	INC	HL
	INC	HL
	DEC	C
	INC	E
	JR	Z,SynNLOk
	LD	A,(HL)
	CALL	SynIsHexDigit
	JR	NC,SynNLHexLoop
	CALL	SynIsIdChar
	JR	NC,SynNLBad			; reject #define / $label as complete tokens
SynNLOk:
	LD	A,E
	POP	BC
	POP	HL
	RET
SynNLBad:
	XOR	A
	POP	BC
	POP	HL
	RET

; CF=0 if A is an ASCII hexadecimal digit, CF=1 otherwise.
SynIsHexDigit:
	CP	'0'
	JR	C,SynIHDNo
	CP	'9'+1
	JR	C,SynIHDYes
	CALL	SynToLower
	CP	'a'
	JR	C,SynIHDNo
	CP	'f'+1
	JR	C,SynIHDYes
SynIHDNo:
	SCF
	RET
SynIHDYes:
	OR	A
	RET

; CF=0 if A is part of an identifier (letter/digit/'_'/'@'/'?'/'$').
; CF=1 otherwise. Preserves all other registers.
SynIsIdChar:
	CP	'@'
	JR	Z,SynIsIdYes
	CP	'?'
	JR	Z,SynIsIdYes
	CP	'$'
	JR	Z,SynIsIdYes
	JP	SynIsWordChar			; tail-call: returns its CF directly
SynIsIdYes:
	OR	A				; CF=0
	RET

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
	LD	A,(HL)
	CP	'#'
	JR	NZ,SynCWLp
	; '#' is allowed only as a leading keyword character. It remains a
	; separator inside ordinary identifiers and can therefore represent
	; C/C++ preprocessor words such as #include.
	LD	(DE),A
	INC	DE
	INC	HL
	INC	HL
	DEC	C
	LD	A,#01
	LD	(SynTokenLen),A
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
	; Both list bytes and the SynToken bytes are already in matching case
	; (lowered at profile load time when case-insensitive, kept as-is when
	; case-sensitive), so a direct compare is enough.
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
	LD	DE,(AdrPage)
	LD	(SynBlockTarget),DE
	CALL	SynFindCachedBlock
	RET	C
	LD	IX,#8040
	LD	HL,(UpLinePg)
	LD	A,H
	OR	L
	JR	Z,SynSBTDone
SynSBTLp:
	LD	A,(IX+#00)
	OR	A
	RET	Z
	PUSH	HL
	CALL	SynCacheBlockIX
	CALL	SynScanCompLine
	POP	HL
	DEC	HL
	LD	A,H
	OR	L
	JR	Z,SynSBTDone
	LD	C,(IX+#00)
	LD	B,#00
	ADD	IX,BC
	JR	SynSBTLp
SynSBTDone:
	LD	IX,(SynBlockTarget)
	CALL	SynCacheBlockIX
	RET

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
; The recent-line cache makes normal cursor movement and one-line scrolling
; constant-time. A full walk is only a fallback after a jump or cache reset.
SynSeedBlockAtCursor:
	XOR	A
	LD	(SynCBlockOpen),A
	LD	A,(SynHasBlockCom)
	OR	A
	RET	Z
	LD	DE,(BegString)
	LD	(SynBlockTarget),DE
	CALL	SynFindCachedBlock
	RET	C
	LD	DE,(SynBlockTarget)
	LD	IX,#8040
SynSBACLp:
	PUSH	IX
	POP	HL
	OR	A
	SBC	HL,DE
	JR	Z,SynSBACHit
	LD	A,(IX+#00)
	OR	A
	RET	Z
	CALL	SynCacheBlockIX
	CALL	SynScanCompLine
	LD	C,(IX+#00)
	LD	B,#00
	ADD	IX,BC
	JR	SynSBACLp
SynSBACHit:
	CALL	SynCacheBlockIX
	RET

; Store the block-comment state entering the packed line at IX.
; A 64-entry ring covers the current and previous editor viewports.
SynCacheBlockIX:
	LD	A,(SynHasBlockCom)
	OR	A
	RET	Z
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,(SynBlockCacheNext)
	LD	E,A
	LD	D,#00
	LD	H,D
	LD	L,E
	ADD	HL,HL
	ADD	HL,DE				; three bytes per entry
	LD	DE,SynBlockCache
	ADD	HL,DE
	PUSH	IX
	POP	DE
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	A,(SynCBlockOpen)
	LD	(HL),A
	LD	A,(SynBlockCacheNext)
	INC	A
	AND	#3F
	LD	(SynBlockCacheNext),A
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET

; Find the entry state for SynBlockTarget. If the exact line is absent but
; its predecessor is cached, scan only that one predecessor line.
; Out: CF=1 if found, SynCBlockOpen set to the required entry state.
SynFindCachedBlock:
	LD	HL,SynBlockCache
	LD	B,#40
SynFCBLp:
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	A,D
	OR	E
	JR	Z,SynFCBNext
	LD	A,(SynBlockTarget)
	CP	E
	JR	NZ,SynFCBPred
	LD	A,(SynBlockTarget+1)
	CP	D
	JR	Z,SynFCBExact
SynFCBPred:
	PUSH	HL
	PUSH	DE
	LD	A,(DE)
	ADD	A,E
	LD	E,A
	JR	NC,SynFCBNoCarry
	INC	D
SynFCBNoCarry:
	LD	A,(SynBlockTarget)
	CP	E
	JR	NZ,SynFCBNotPred
	LD	A,(SynBlockTarget+1)
	CP	D
	JR	NZ,SynFCBNotPred
	POP	IX
	POP	HL
	LD	A,(HL)
	LD	(SynCBlockOpen),A
	CALL	SynScanCompLine
	LD	IX,(SynBlockTarget)
	CALL	SynCacheBlockIX
	SCF
	RET
SynFCBNotPred:
	POP	DE
	POP	HL
SynFCBNext:
	INC	HL
	DJNZ	SynFCBLp
	OR	A
	RET
SynFCBExact:
	LD	A,(HL)
	LD	(SynCBlockOpen),A
	SCF
	RET

SynInvalidateBlockCache:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	HL,SynBlockCache
	LD	DE,SynBlockCache+1
	LD	BC,191
	LD	(HL),#00
	LDIR
	XOR	A
	LD	(SynBlockCacheNext),A
	POP	HL
	POP	DE
	POP	BC
	RET

; 2-slot LRU cache: profile data in the "active" slot is what runtime code
; reads (SynKeywords1, SynLineCom1, etc.). A second "backup" slot mirrors
; the same fields but at different addresses (SynKw1Bk, SynLC1Bk, ...).
; When the user toggles between two profiles (e.g. C window <-> ASM window)
; we just byte-swap the two slots instead of going to disk.
SynEnsureProfileLoaded:
	LD	HL,SynProfileName
	LD	DE,SynLoadedProf
	CALL	SynStrEq
	RET	Z				; already active — nothing to do
	CALL	SynInvalidateBlockCache
	; Active profile changes from here. Invalidate the per-render-pass
	; language cache so the next paint re-detects via SynDetectLang
	; instead of reusing the previous window's value.
	XOR	A
	LD	(SynRenderLangValid),A
	; Check the backup slot.
	LD	HL,SynProfileName
	LD	DE,SynLoadedProfBk
	CALL	SynStrEq
	JR	NZ,SynEPL_Fresh
	; Wanted profile sits in backup — swap with active, no disk I/O.
	CALL	SynSwapSlots
	; Active keyword buffers now hold sorted data from the previous swap;
	; rebuild the index in place (no sort, single O(N) pass).
	LD	HL,SynKeywords1
	LD	DE,SynKw1Idx
	CALL	SynRebuildKwIndex
	LD	HL,SynKeywords2
	LD	DE,SynKw2Idx
	CALL	SynRebuildKwIndex
	RET
SynEPL_Fresh:
	; Wanted profile is in neither slot. Move whatever active was into
	; backup (becoming the LRU cache entry), then load the new one fresh
	; into active. SynLoadProfile will do the full sort+index for the
	; new profile, so we don't rebuild the index here.
	CALL	SynSwapSlots
	LD	HL,SynProfileName
	LD	DE,SynLoadedProf
	CALL	SynStrCopy20
	CALL	SynLoadProfile
	RET

; Byte-swap the active and backup slots in place. Used to move a cached
; profile into the active position (or push the active one out to backup
; before loading a new one). Backup slot lives in Dialog_Windows_PG2, so
; we page that into SLOT3 for the duration of the swap.
SynSwapSlots:
	CALL	SynPageDp2In
	LD	HL,SynLoadedProf
	LD	DE,SynLoadedProfBk
	LD	BC,SynSlotTotalBytes
SynSwapLp:
	LD	A,(DE)
	LD	(SynSwapTmp),A
	LD	A,(HL)
	LD	(DE),A
	LD	A,(SynSwapTmp)
	LD	(HL),A
	INC	HL
	INC	DE
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,SynSwapLp
	JP	SynPageDp2Out

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
	LD	(SynStringDelims),A		; default: no string highlighting
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
	LD	HL,#027F			; SynFileBuf is 640 bytes; reserve 1 for null
	LD	(SynLFMax),HL
	LD	HL,SynProfilePath
	CALL	SynLoadFileToBuf
	RET	C
	; SynParseProfileBuf reads SynFileBuf (paged out into Dialog_Windows_PG2),
	; and SynBuildKwIndex uses SynFileBuf as scratch. Page DialogPg2 into
	; SLOT3 around all SynFileBuf accesses.
	CALL	SynPageDp2In
	CALL	SynParseProfileBuf
	CALL	SynDetectBlockCom
	LD	A,(SynCaseSensitive)
	OR	A
	JR	NZ,SynLP_NoLower
	LD	HL,SynKeywords1
	CALL	SynLowerCsv
	LD	HL,SynKeywords2
	CALL	SynLowerCsv
SynLP_NoLower:
	LD	HL,SynKeywords1
	LD	DE,SynKw1Idx
	CALL	SynBuildKwIndex
	LD	HL,SynKeywords2
	LD	DE,SynKw2Idx
	CALL	SynBuildKwIndex
	JP	SynPageDp2Out

; Lowercase every byte of an ASCIIZ string in place. ',' and other
; separators stay as-is because SynToLower is a no-op on non-letters.
SynLowerCsv:
	LD	A,(HL)
	OR	A
	RET	Z
	CALL	SynToLower
	LD	(HL),A
	INC	HL
	JR	SynLowerCsv

; Page Dialog_Windows_PG2 into SLOT3 so SynBackupSlot / SynFileBuf /
; SynIndexBuf become accessible. SynDp2SavedSlot3 holds the previous
; mapping for restoration. Callers must pair Dp2In with Dp2Out — and
; must NOT nest pairs (the saved-slot variable is single-shot).
; Preserves AF.
SynPageDp2In:
	PUSH	AF
	IN	A,(SLOT3)
	LD	(SynDp2SavedSlot3),A
	LD	A,(DialogPg2)
	OUT	(SLOT3),A
	POP	AF
	RET
SynPageDp2Out:
	PUSH	AF
	LD	A,(SynDp2SavedSlot3)
	OUT	(SLOT3),A
	POP	AF
	RET

; In:  A = char (any case)
; Out: A = bucket index 0..25 for 'a'..'z', 26 for any non-letter.
SynLetterBucket:
	CALL	SynToLower
	CP	'a'
	JR	C,SynLB_Other
	CP	'z'+1
	JR	NC,SynLB_Other
	SUB	'a'
	RET
SynLB_Other:
	LD	A,26
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

; Rebuild the first-letter range index from already-sorted keyword data. Used
; after a slot swap (sort property is preserved by content swap, only
; pointers need to be rebuilt). Single O(N) pass.
;
; In:  HL = sorted keyword buffer (ASCIIZ CSV)
;      DE = idx buffer (56 bytes)
SynRebuildKwIndex:
	LD	C,#00				; next boundary index to emit
SynRBI_Lp:
	LD	A,(HL)
	OR	A
	JR	Z,SynRBI_End
	CALL	SynLetterBucket
	LD	B,A				; bucket of current word
SynRBI_Fill:
	LD	A,B
	CP	C
	JR	C,SynRBI_SkipBody
	LD	A,L
	LD	(DE),A
	INC	DE
	LD	A,H
	LD	(DE),A
	INC	DE
	INC	C
	JR	SynRBI_Fill
	; Advance HL to next word
SynRBI_SkipBody:
	LD	A,(HL)
	OR	A
	JR	Z,SynRBI_End
	CP	','
	JR	Z,SynRBI_Next
	INC	HL
	JR	SynRBI_SkipBody
SynRBI_Next:
	INC	HL				; consume ','
	JR	SynRBI_Lp
SynRBI_End:
	; Fill all remaining bucket boundaries plus idx[27] with the end pointer.
	LD	A,C
	CP	#1C
	RET	Z
	LD	A,L
	LD	(DE),A
	INC	DE
	LD	A,H
	LD	(DE),A
	INC	DE
	INC	C
	JR	SynRBI_End

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
	JP	Z,SynPPNext
	CP	#0A
	JP	Z,SynPPNext
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
	JR	NZ,SynPPSD
	CALL	SynCopyValueBrackets
	JR	SynPPSkip
SynPPSD:
	PUSH	HL
	LD	DE,SynKeyStringDelims
	CALL	SynLineStartsWith
	POP	HL
	JR	NZ,SynPPSkip
	CALL	SynCopyValueStringDelims
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
	JP	SynPPLine

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

; SynCopyValueKw1/Kw2: append the keyword= value at HL to the kw buffer.
; Multiple "keywords=" lines accumulate into one CSV (we insert a comma
; separator before each subsequent value). BC = one-past-last byte allowed
; for keyword data; we always reserve one trailing slot for the null
; terminator so DE can stop at BC-1 safely.
SynCopyValueKw1:
	LD	DE,SynKeywords1
	LD	BC,SynKeywords1+384
	JR	SynCopyValueCommon
SynCopyValueKw2:
	LD	DE,SynKeywords2
	LD	BC,SynKeywords2+128
SynCopyValueCommon:
	; If buffer non-empty, advance DE to its null terminator and overwrite
	; the null with a separator before appending.
	LD	A,(DE)
	OR	A
	JR	Z,SynCVCSeek			; empty → no separator
SynCVCFindEnd:
	INC	DE
	LD	A,(DE)
	OR	A
	JR	NZ,SynCVCFindEnd
	; DE = current null. Check we have room for ',' + at least one char + null.
	PUSH	HL
	PUSH	DE
	INC	DE
	INC	DE
	OR	A
	SBC	HL,HL				; HL = 0
	ADD	HL,DE
	OR	A
	SBC	HL,BC
	POP	DE
	POP	HL
	JR	NC,SynCVCEnd			; no room — abort with current null intact
	LD	A,','
	LD	(DE),A
	INC	DE
SynCVCSeek:
	PUSH	DE
	PUSH	BC
	CALL	SynSeekEq
	POP	BC
	POP	DE
	JR	C,SynCVCEnd			; no '=' on line → terminate
SynCVC0:
	; Overflow check: DE must be < BC-1 (reserve last byte for null).
	PUSH	HL
	LD	H,B
	LD	L,C
	DEC	HL				; HL = BC - 1
	OR	A
	SBC	HL,DE				; CF set if HL < DE → no room
	POP	HL
	JR	C,SynCVCEnd
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

; Parse "string_delims=..." value (up to 3 chars) into SynStringDelims.
SynCopyValueStringDelims:
	LD	DE,SynStringDelims
	PUSH	DE
	CALL	SynSeekEq
	POP	DE
	RET	C
	LD	B,#03				; up to 3 delimiter chars
SynCVS0:
	LD	A,B
	OR	A
	JR	Z,SynCVSEnd
	LD	A,(HL)
	OR	A
	JR	Z,SynCVSEnd
	CP	#0D
	JR	Z,SynCVSEnd
	CP	#0A
	JR	Z,SynCVSEnd
	LD	(DE),A
	INC	DE
	INC	HL
	DEC	B
	JR	SynCVS0
SynCVSEnd:
	XOR	A
	LD	(DE),A
	RET

; Parse "brackets=..." value (up to 11 chars) into SynBrackets buffer.
SynCopyValueBrackets:
	LD	DE,SynBrackets
	PUSH	DE
	CALL	SynSeekEq
	POP	DE
	RET	C
	LD	B,#0B				; up to 11 bracket chars (+ 1 null = buffer of 12)
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
SynLineLen:	DEFB	#00
SynLineAttr:	DEFB	#00
SynTokenLen:	DEFB	#00
SynProfHnd:	DEFB	#00
SynLFRet:	DEFB	#01
SynIndexLoaded:	DEFB	#00		; 0=not attempted, 1=loaded ok, #FF=load failed
SynLFDst:	DEFW	#0000		; destination buffer for SynLoadFileToBuf
SynLFMax:	DEFW	#0000		; max bytes to read for SynLoadFileToBuf
SynRelPath:	DEFW	#0000		; relative path saved across page swaps in SynLoadFileToBuf
SynSwapTmp:	DEFB	#00		; one-byte scratch used by SynSwapSlots
SynDp2SavedSlot3:	DEFB	#00	; saved SLOT3 mapping for SynPageDp2In/Out
SynBKISrc:	DEFW	#0000		; scratch for SynBuildKwIndex / SynRebuildKwIndex
SynBKIIdx:	DEFW	#0000
SynBKICur:	DEFW	#0000
SynBKIBkt:	DEFB	#00
SynKwEnd:	DEFW	#0000		; exclusive end of current keyword bucket
SynBlockTarget:	DEFW	#0000
SynBlockCacheNext:	DEFB	#00
SynBlockCache:	DEFS	192,0		; 64 entries: line pointer + entry state
SynToken:	DEFS	24,0
SynNameBuf:	DEFS	64,0
SynWorkBuf:	DEFW	#0000
SynProfileName:	DEFS	20,0		; profile file name from INDEX.LST (e.g. "c.syn")
SynProfilePath:	DEFS	32,0		; constructed full path "SYNTAX\<name>"

; --- Active profile slot. Layout MUST match SynBackupSlot below; the two
;     are byte-swapped wholesale by SynSwapSlots. Runtime code reads from
;     these "active" addresses; backup slot is only manipulated by the
;     swap routine.
SynActiveSlot:
SynLoadedProf:	DEFS	20,0		; cached name of profile currently loaded
SynLineCom1:	DEFS	4,0		; line-comment pattern 1 (up to 3 chars + null)
SynLineCom2:	DEFS	4,0		; line-comment pattern 2 (or "/*" block opener)
SynBrackets:	DEFS	12,0		; bracket chars to highlight (up to 11 + null)
SynStringDelims:	DEFS	4,0		; string-literal delimiter chars (up to 3 + null)
SynCaseSensitive:	DEFB	#00
SynHasBlockCom:	DEFB	#00		; 1 if profile uses /*..*/ block comments
SynKeywords1:	DEFS	384,0		; primary keywords CSV (sorted by first letter)
SynKeywords2:	DEFS	128,0		; secondary keywords CSV (sorted by first letter)
SynActiveSlotEnd:
SynSlotTotalBytes	EQU	SynActiveSlotEnd - SynActiveSlot

; --- First-letter index for the active slot. NOT part of the swap region;
;     after a swap, the new active data is already sorted (sort sticks to
;     content), so we just rebuild these pointers in a single O(N) pass.
;     Each index is 28 word boundaries: 27 bucket starts (26 letters plus
;     non-letter starts) and one exclusive end pointer. Empty buckets have
;     equal adjacent boundaries.
SynKw1Idx:	DEFS	56,0
SynKw2Idx:	DEFS	56,0

; SynBackupSlot, SynFileBuf and SynIndexBuf live in Dialog_Windows_PG2 (see
; Dialog_Windows/Asmsetup.asm). They are accessed via SynPageDp2In /
; SynPageDp2Out, which page DialogPg2 into SLOT3 around the access. This
; keeps ~1.5 KB out of the always-resident KodeMain page.

SynPathIndex:	DEFB	"SYNTAX\\INDEX.LST",0
SynDirPrefix:	DEFB	"SYNTAX\\",0

SynKeyKw1:	DEFB	"keywords=",0
SynKeyKw2:	DEFB	"keywords2=",0
SynKeyCase:	DEFB	"case_sensitive=",0
SynKeyLC1:	DEFB	"line_comment=",0
SynKeyLC2:	DEFB	"line_comment2=",0
SynKeyBrackets:	DEFB	"brackets=",0
SynKeyStringDelims:	DEFB	"string_delims=",0
SynBracketsDefault:	DEFB	"()[]",0

 _mCollectInfo_addEnd
