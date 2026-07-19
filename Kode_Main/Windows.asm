 _mCollectInfo_addStart
;===============================================================
; In and on screen new window
; On: none
PutTextWn
	LD	IX,TxtWtab	; Pointer on first windows
	BIT	7,(IX+#00)
	RET	NZ		; Windows none
	CALL	GetTxtW	    ; With screen from-under.window
	CALL	Rectang	    ; Internal operation
	LD	HL,FrameSl  ; Pointer on frame selected window
	CALL	PutFram	    ; Draw frame
	CALL	PutShad	    ; Draw shadow
	CALL	PrnTxtW	    ; Print window on screen
	RET 
;===============================================================
; Paint in table window in window
SelcWin	LD	IX,TxtWtab  ; Table window descriptors
	LD	HL,FrameSl  ; Pointer on frame selected window
	CALL	PutFram	    ; Draw frame
	CALL	PrnTxtW	    ; Print window on screen
	RET 
;===============================================================
; Paint window in window
HiddWin	LD	IX,TxtWtab+#26; Table window descriptors
	BIT	7,(IX+#00)    ; Single window
	RET	NZ	    ; Windows none
	RES	6,(IX+#00)  ; Window
	LD	HL,FrameHd ; Pointer on frame window
	CALL	PutFram	    ; Draw frame
	CALL	PrnTxtW	    ; Print window on screen
	RET 
;===============================================================
; Paint window in window
MoveWin	LD	IX,TxtWtab  ; Table window descriptors
	LD	HL,FrameMv  ; Pointer on frame. window
	CALL	PutFram	    ; Draw frame
	CALL	PrnTxtW	    ; Print window on screen
	RET 
;===============================================================
; Window
RefrWin:	IN	A,(SLOT3)
	PUSH	AF		; Save.page4
	LD	A,(BuffPg4)
	OUT	(SLOT3),A		; Enable
; Clear in buffer
	LD	HL,WinBoxBuff+5100  ; Place
	LD	E,L
	LD	D,H
	LD	B,#80
	LD	C,#B0
	LD	A,(ColDeskTop)	; Color DeskTop
	LD	(HL),C		; Byte DeskTop
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-4

	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
	LD	B,#13
	LD	D,D
	LD	A,#00
	LD	L,L
	LD	A,(DE)
	LD	(HL),A
	LD	B,B
	INC	H
	INC	D
	DJNZ	$-9

	EI 
	LD	IX,TxtWtab  ; Table window descriptors
	LD	BC,#0026
RefrLp1	ADD	IX,BC
	BIT	7,(IX+#00)  ; Search same window
	JR	Z,RefrLp1
	LD	BC,-#0026   ; Refresh window down by table
RefrLp2	ADD	IX,BC
	BIT	6,(IX+#00)
	JR	NZ,RefrWex  ; Same window
	PUSH	BC
	CALL	GetWork	    ; Take from under window for shadow (from )
	CALL	PutShad	    ; Draw shadow
	CALL	PutWork	    ; Copy in..area.window
	POP	BC
	JR	RefrLp2
RefrWex	CALL	GetWork	; From under
	POP	AF
	OUT	(SLOT3),A
	RET 
; From buffers. info. from-under window (for shadow)
GetWork	LD	E,(IX+#01)	;Xo pos
	LD	D,(IX+#03)	;Yo pos
	LD	A,(IX+#02)
	SUB	E
	ADD	A,#02		; Shadow
	LD	L,A		;Xlen
	LD	A,(IX+#04)
	SUB	D
	INC	A		; Shadow
	LD	H,A		;Ylen
	CALL	ExCoordG	; Validity coordinates
	CALL	GetBufA		; Get in buffer (DE)
	LD	B,H		; In BC
	LD	A,L
	ADD	A,A
	LD	(g1),A
	LD	L,A
	LD	H,#00
	LD	(g2),HL
	LD	HL,WinBoxBuff+10200 ; Internal operation
	DI			; From buffers in WinBoxbuff
	EXX 
	CALL	GetMousInfo
	EXX 
GetWrL1:	LD	D,D
g1+1:	LD	A,#00
	LD	L,L
	LD	A,(DE)
	LD	(HL),A
	LD	B,B
	LD	A,B
g2+1:	LD	BC,#0000
	ADD	HL,BC
	LD	BC,#00A4	; Next.line
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
	LD	B,A
	DJNZ	GetWrL1
	EI 
	RET 
; In. info. from-under window
ResWork	LD	E,(IX+#01)	;Xo pos
	LD	D,(IX+#03)	;Yo pos
	LD	A,(IX+#02)
	SUB	E
	ADD	A,#02		; Shadow
	LD	L,A		;Xlen
	LD	A,(IX+#04)
	SUB	D
	INC	A		; Shadow
	LD	H,A		;Ylen
	CALL	ExCoordG	; Validity coordinates
	CALL	GetBufA		; Get in buffer (DE)
	LD	B,H		; In BC
	LD	A,L
	ADD	A,A
	LD	(r1),A
	LD	L,A
	LD	H,#00
	LD	(r2),HL
	LD	HL,WinBoxBuff+10200 ; Internal operation
	DI			; From WinBoxbuff
	EXX 
	CALL	GetMousInfo
	EXX 
ResWrL1:	LD	D,D
r1+1:	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
	LD	A,B
r2+1:	LD	BC,#0000
	ADD	HL,BC
	LD	BC,#00A4	; Next.line
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
	LD	B,A
	DJNZ	ResWrL1
	EI 
	RET 
; Window in
PutWork:	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(IX+#21)
	OUT	(SLOT2),A		; Page.,where window
	LD	L,(IX+#1F)	; Buffers
	LD	H,(IX+#20)
	LD	BC,#8000	; !HARDCODE; window
	ADD	HL,BC
	PUSH	HL		; HL=,where window
	LD	E,(IX+#01)	;Xo pos
	LD	D,(IX+#03)	;Yo pos
	LD	A,(IX+#02)
	SUB	E
	ADD	A,#02		; Shadow
	LD	L,A		;Xlen
	LD	A,(IX+#04)
	SUB	D
	INC	A		; Shadow
	LD	H,A		;Ylen
	PUSH	HL
	LD	H,#00
	SLA	L
	LD	(p2),HL
	POP	HL
	LD	B,#00
	BIT	7,E		;Xo pos
	JR	Z,$+11
	LD	A,E		; Start window for screen
	LD	E,B
	NEG		; In and-on how many window for screen
	LD	C,A	; Save
	SUB	L	; Window=-visible part
	NEG 
	LD	L,A	; Visible part

	LD	A,E
	ADD	A,L		; +len x
	CP	#53		; Test by out for x pos
	JR	C,$+6
	LD	A,#50
	SUB	E
	LD	L,A	; HL= by X
				; Window for screen
	LD	A,D		;Yo pos
	ADD	A,H		; +len y
	CP	#1F
	JR	C,$+6		; Okey
	LD	A,#1F
	SUB	D
	LD	H,A		; Normal len y
	SLA	C
	PUSH	BC
	CALL	GetBufA		; Get in buffer (DE)
	LD	A,L		; Y in B
	ADD	A,L
	LD	(p1),A
	LD	A,H
	POP	BC
	POP	HL
	ADD	HL,BC
	LD	B,A
	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
pwl:	LD	D,D
p1+1:	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
	LD	A,B
	LD	BC,#00A4	; Next.line
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
p2+1:	LD	BC,#0000
	ADD	HL,BC
	LD	B,A
	DJNZ	pwl
	EI 
	POP	AF
	OUT	(SLOT2),A
	RET 
; Procedure getting addresses in
; On: DE - Y,X coord
; On exit: DE
GetBufA:	PUSH	HL
	LD	HL,WinBoxBuff+5100-#A4	; !hardcode
	LD	C,E
	LD	B,D
	LD	DE,#00A4
	ADD	HL,DE
	DJNZ	$-1
	ADD	HL,BC
	ADD	HL,BC
	EX	DE,HL
	POP	HL
	RET 
;===============================================================
; Procedure pages text
; 28*78 page
InitPage
	CALL	OnlySyntax
	LD	A,(ReadyStr)	; Was not touched
	OR	A
	CALL	Z,PutString
	LD	A,#01
	LD	(SynRenderPass),A
	CALL	SynPrepareRender
	LD	A,(IY+#02)
	LD	(initA1+3),A
	LD	A,(IY-#04)
	LD	(initA2+3),A
	LD	A,(IY+#05)
	LD	(initA3+3),A
	LD	(IY+#05),#4E
	LD	IX,(AdrPage)
	LD	B,#1C
	LD	C,#00
	EXX
	LD	DE,WinBoxBuff+10200	; !hardcode
	EXX
InitPg1	LD	A,(IX+#00)
	OR	A
	JR	Z,initA1
	PUSH	IX
	PUSH	BC
	LD	HL,ReCompBuff
	LD	E,LX
	LD	D,HX
	INC	DE
	INC	DE
	PUSH	HL
	CALL	ReCompile
	POP	HL
	PUSH	HL
	CALL	SyntaxExtLine
	POP	HL
	LD	A,(IY+#07)
	ADD	A,A
	LD	L,A
	JR	NC,$+3
	INC	H
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	PUSH	HL
	EXX 
	POP	HL
	LD	BC,#009C
	LDIR 
	EXX 
	POP	AF
	OUT	(SLOT3),A
	POP	BC
	POP	IX
	LD	E,(IX+#00)
	LD	D,#00
	ADD	IX,DE
	INC	C
	DJNZ	InitPg1
initA1	LD	(IY+#02),#00
initA2	LD	(IY-#04),#00
initA3	LD	(IY+#05),#00
	XOR	A
	LD	(SynRenderPass),A
	LD	(SynRenderLangValid),A
	LD	A,B
	OR	A
	RET	Z
;Clear down screen
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT3),A
	LD	A,(ColTxtWin)
	EXX 
	EX	DE,HL
	EXX 
InitEmp	EXX 
	LD	B,#4E
	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-4
	EXX 
	DJNZ	InitEmp
	POP	AF
	OUT	(SLOT3),A
	RET 
;===============================================================
; Procedure in window pages
PutIPage
	IN	A,(SLOT2)		;Save pages
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,(BuffPg5)	; Buffer init page
	OUT	(SLOT2),A
	LD	A,(IX+#21)	; Page window
	OUT	(SLOT3),A
	LD	L,(IX+#1F)	; Address wind place
	LD	H,(IX+#20)
	LD	BC,#C002	; Page shift
	ADD	HL,BC
	LD	DE,#8000+10200	; Address init page ; !hardcode
	EX	DE,HL
	LD	A,(IX+#04)
	SUB	(IX+#03)
	SUB	#02
	LD	B,A
	LD	A,(IX+#02)
	SUB	(IX+#01)	; Len x window
	ADD	A,#02
	ADD	A,A
	LD	C,A		; Full len with shadow & atr
	SUB	#08
	LD	(lenW+1),A
	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
PutIPg1	LD	A,E
	ADD	A,C
	LD	E,A
	JR	NC,$+3
	INC	D
	LD	D,D
lenW	LD	A,#00		;Len string
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
	LD	A,L
	ADD	A,#9C		; Len init string
	LD	L,A
	JR	NC,$+3
	INC	H
	DJNZ	PutIPg1
	EI 
	POP	BC
	LD	A,B		; Reset pages
	OUT	(SLOT3),A
	LD	A,C
	OUT	(SLOT2),A
	RET 
;===============================================================
; Internal operation
;===============================================================
	DEFINE _WINDOWisSelected	0xC9,0xBB,0xC8,0xBC,0xCD,0xBA,0xB5,0xC6
	DEFINE _WINDOWisUnSelected	0xDA,0xBF,0xC0,0xD9,0xC4,0xB3,0xB4,0xC3
	DEFINE _WINDOWisMoving	0xDA,0xBF,0xC0,0xD9,0xC4,0xB3,0xB4,0xC3
; For windows
FrameSl:
	DEFB	_WINDOWisSelected	; Window
	DEFW	ColNormFr			; Its color
FrameHd:
	DEFB	_WINDOWisUnSelected	; Not window
	DEFW	ColHiddFr			; Its color
FrameMv:
	DEFB	_WINDOWisMoving		; Window
	DEFW	ColMoveFr			; Its color

; Procedure window
; On: IX - descriptor
Rectang:
	IN	A,(SLOT3)		; Save page 4
	PUSH	AF
	LD	A,(IX+#21)	; Number page.buffers
	OUT	(SLOT3),A
	LD	L,(IX+#1F)	; Offset from start page
	LD	H,(IX+#20)
	LD	BC,#C000		; Page. with #C000; !HARDCODE
	ADD	HL,BC
	LD	A,(ColTxtWin)	; Color text window
	LD	C,A
	LD	A,(IX+#02)
	SUB	(IX+#01)		; Window X
	LD	E,A
	LD	A,(IX+#04)
	SUB	(IX+#03)		; Window Y
	LD	B,A
RectLp	LD	D,B		; Save len y
	LD	B,E		; Len x
	LD	A,#20
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	INC	HL		; Place for shadow
	INC	HL
	INC	HL
	INC	HL
	LD	B,D
	DJNZ	RectLp
	POP	AF		; Reset page 4
	OUT	(SLOT3),A
	RET 
; Procedure on window
; On: IX - descriptor
; HL - descriptor
PutFram	PUSH	IY
	PUSH	HL
	POP	IY		; Descriptor in IY
	IN	A,(SLOT3)		; Save page 4
	PUSH	AF
	LD	A,(IX+#21)	; Buffer text page
	OUT	(SLOT3),A
	LD	L,(IX+#1F)	; Offset from start page
	LD	H,(IX+#20)
	LD	BC,#C000	; Page. with #C000; !HARDCODE
	ADD	HL,BC
	LD	(TempAd1+1),HL
	LD	C,(IY+#08)
	LD	B,(IY+#09)
	LD	A,(BC)		; Color
	LD	C,A
	LD	A,(ColTxtWin)
	AND	#F0
	OR	C
	LD	C,A		;Color frame
	LD	A,(IX+#02)
	SUB	(IX+#01)	; Len x window
	SUB	#02
	LD	E,A
	LD	D,#00
; Line
	LD	A,(IY+#00)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	B,E
	LD	A,(IY+#04)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	LD	A,(IY+#01)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
; Window
	LD	A,(IX+#04)
	SUB	(IX+#03)	; Len y window-2
	SUB	#02
	LD	B,A
	LD	A,(IY+#05)
FrameLp	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	ADD	HL,DE
	ADD	HL,DE
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	DJNZ	FrameLp
; Line
	LD	A,(IY+#02)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	LD	B,E
	LD	A,(IY+#04)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	LD	A,(IY+#03)
	LD	(HL),A
	INC	HL
	LD	(HL),C
	CALL	PutWatr
	POP	AF		; Reset page 4
	OUT	(SLOT3),A
	POP	IY		; Reset iy
	RET 
; Procedure output in window close,,name
; On: IX - descriptor
PutWatr
; Name
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	LD	A,(IX+#00)	; Name window
	AND	#0F		; Its number
	INC	A
	LD	B,A
	LD	HL,NameTab-#80
	LD	DE,#0080
	ADD	HL,DE		; Search name
	DJNZ	$-1
	PUSH	HL		; HL- name
	LD	C,#FF
	INC	C
	LD	A,(HL)		; Count its length (.C)
	INC	HL
	OR	A
	JR	NZ,$-4
	POP	HL
	LD	A,(IX+#02)
	SUB	(IX+#01)	; Window by X
	SUB	#14		; 2 -a window
	SUB	C
	PUSH	AF		; Save.Carry flag+reg.and
	JR	NC,$+3
	SUB	A		; Name
	ADD	A,#12
	SRL	A		; Place
	LD	E,A		; Name
	LD	D,#00
	PUSH	HL
TempAd1	LD	HL,#0000	; Start buffers
	ADD	HL,DE
	ADD	HL,DE
	EX	DE,HL
	POP	HL
	LD	A,#20		; Internal operation
	LD	(DE),A
	INC	DE
	INC	DE
	POP	AF		; Reset carry flag
	JR	NC,putname	; Name
	NEG			; ABS(count-in.)
	ADD	A,#02		; +place for
	LD	C,A
	ADD	HL,BC		; New start name
	LD	A,'.'
	LD	(DE),A
	INC	DE
	INC	DE
	LD	(DE),A
	INC	DE
	INC	DE
putname	LD	A,(HL)		; Copy from table name
namemv	RES	7,A
	INC	HL
	LD	(DE),A
	INC	DE
	INC	DE
	LD	A,(HL)
	OR	A
	JR	NZ,namemv
	LD	A,#20
	LD	(DE),A
	POP	AF
	OUT	(SLOT2),A
; Number window
	LD	HL,(TempAd1+1)	; Start window in memory
	PUSH	HL
	LD	A,(IX+#02)
	SUB	(IX+#01)	; Window by X
	SUB	#07		; Position window from end
	LD	C,A
	LD	B,#00
	ADD	HL,BC
	ADD	HL,BC
	LD	A,(IX+#00)	; Take number window
	AND	#0F
	CP	#09
	JR	C,$+10
	SUB	#0A
	DEC	HL
	DEC	HL
	LD	(HL),'1'
	INC	HL
	INC	HL
	ADD	A,'1'
	LD	(HL),A
	POP	HL
	BIT	6,(IX+#00)
	RET	Z		; Window not (without )
; Button close
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	A,(IY+#06)	; Button close window
	LD	(HL),A
	INC	HL
	INC	HL
	LD	(HL),#FE
	INC	HL
	LD	A,(ColWindAtr)
	LD	C,A
	LD	A,(HL)
	AND	#F0
	OR	C
	LD	(HL),A
	INC	HL
	LD	A,(IY+#07)
	LD	(HL),A
; Button
	LD	A,(IX+#02)
	SUB	(IX+#01)
	SUB	#09
	LD	C,A
	LD	B,#00
	ADD	HL,BC
	ADD	HL,BC
	LD	A,(IY+#06)	; Position
	LD	(HL),A
	INC	HL
	INC	HL
	LD	(HL),#12
	INC	HL
	LD	A,(ColWindAtr)
	LD	C,A
	LD	A,(HL)
	AND	#F0
	OR	C
	LD	(HL),A
	INC	HL
	LD	A,(IY+#07)
	LD	(HL),A
; Vertical scrollbar
	LD	HL,(TempAd1+1)
	LD	A,(ColScrlBar)
	LD	C,A
	LD	A,(IX+#02)
	SUB	(IX+#01)	; Len x
	ADD	A,A
	LD	E,A
	LD	D,#00		; In
	ADD	HL,DE		; End first line
	INC	HL
	INC	HL
	INC	HL
	INC	HL		; Shadow
	DEC	DE
	DEC	DE
	ADD	HL,DE
	LD	(HL),#1E
	INC	HL
	LD	(HL),C
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	A,(IX+#04)
	SUB	(IX+#03)	; Y
	SUB	#04
	LD	B,A
	LD	A,#B1
ScrlBr1	ADD	HL,DE
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	DJNZ	ScrlBr1
	ADD	HL,DE
	LD	(HL),#1F
	INC	HL
	LD	(HL),C
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
; Horizontal scrollbar
	INC	HL
	INC	HL
	PUSH	IY
	PUSH	HL
	LD	IY,IYpoint
	CALL	PutInfo
	POP	HL
	POP	IY
	LD	DE,#0D*2 ; Window
	ADD	HL,DE
	LD	A,(IY+#06)
	LD	(HL),A
	LD	E,#0A
	ADD	HL,DE
	LD	A,(IY+#07)
	LD	(HL),A
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	A,(ColScrlBar)
	LD	C,A
	LD	(HL),#11
	INC	HL
	LD	(HL),C
	INC	HL
	LD	A,(IX+#02)
	SUB	(IX+#01)
	SUB	#18
	LD	B,A
	LD	A,#B1
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	LD	(HL),#10
	INC	HL
	LD	(HL),C
; Procedure and printing SCROLLBAR in window
; Put vertical bar
	LD	HL,(UpLinePg)
	PUSH	HL
	LD	A,(IX+#04)
	SUB	(IX+#03)
	SUB	#02
	LD	C,A
	LD	B,#00
	ADD	HL,BC
	EX	DE,HL
	LD	HL,(EquipLn)
	SBC	HL,DE
	POP	DE
	JR	NC,PutBr1
	LD	HL,(EquipLn)
	OR	A
	SBC	HL,BC
	EX	DE,HL
	JR	NC,PutBr1
	LD	DE,#0000
PutBr1	LD	A,(IX+#04)
	SUB	(IX+#03)
	SUB	#05
	LD	C,A
	CALL	Mult16X8	; Curline*lenscrollbar=a32
	EX	DE,HL
	EX	AF,AF'
	LD	HL,(EquipLn)	; A24/equipln
	LD	A,(IX+#04)
	SUB	(IX+#03)
	SUB	#02
	LD	C,A
	LD	B,#00
	OR	A
	SBC	HL,BC
	JR	NC,$+5
	LD	HL,(EquipLn)
	EX	AF,AF'
	EX	DE,HL
	LD	C,L
	LD	L,H
	LD	H,A
	CALL	Divis24X16
	ADD	A,(IX+#03)
	ADD	A,#02
	LD	D,A
	SUB	(IX+#03)
	LD	E,(IX+#02)
	DEC	E
	LD	(TmpVBarP),DE
	LD	B,A
	LD	HL,(TempAd1+1)
	LD	A,(IX+#02)
	SUB	(IX+#01)
	ADD	A,#02
	ADD	A,A
	LD	E,A
	LD	D,#00
	ADD	HL,DE
	DJNZ	$-1
	ADD	HL,DE
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	LD	(HL),#FE
	LD	(TmpVBarA),HL
; Put horizontal bar
	PUSH	IY
	LD	IY,IYpoint
	LD	E,(IY+#07)
	POP	IY
	LD	A,(IX+#02)
	SUB	(IX+#01)
	LD	D,A
	SUB	#02
	SUB	240		;Max len string
	NEG 
	PUSH	AF
	CP	E
	JR	NC,$+3
	LD	E,A
	LD	A,D
	SUB	25
	LD	C,A
	CALL	Mult8X8		; Curline*lenscrollbar=a16
	POP	AF
	LD	C,A		; Max addx
	CALL	Divis16X8
	LD	A,(IX+#01)	; Offset from start
	ADD	A,L
	ADD	A,22
	LD	E,A
	SUB	(IX+#01)
	EX	AF,AF'
	LD	A,(IX+#04)
	DEC	A
	LD	D,A
	LD	(TmpHBarP),DE
	SUB	(IX+#03)
	LD	B,A
	LD	HL,(TempAd1+1)
	LD	A,(IX+#02)
	SUB	(IX+#01)
	ADD	A,#02
	ADD	A,A
	LD	E,A
	LD	D,#00
	ADD	HL,DE
	DJNZ	$-1
	EX	AF,AF'
	ADD	A,A
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
	LD	(HL),#FE
	LD	(TmpHBarA),HL
	RET 

; Procedure output in shadow window
; On: IX - descriptor
PutShad	IN	A,(SLOT2)
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC		; Save page 3&4
	LD	A,(IX+#21)	;Buffer swop
	OUT	(SLOT2),A
	LD	A,(BuffPg4)	;Page buffer
	OUT	(SLOT3),A
	LD	L,(IX+#1F)	;Address buffer
	LD	H,(IX+#20)
	LD	BC,#8000	; Shift page ; !hardcode
	ADD	HL,BC
	LD	A,(IX+#02)
	SUB	(IX+#01)
	LD	E,A
	LD	D,#00
	ADD	HL,DE
	ADD	HL,DE
	EXX 
	LD	E,A		; Window X
	BIT	7,(IX+#01)
	JR	Z,ExShad1	; Screen
	LD	A,(IX+#01)
	NEG		; In and-on how many window for screen
	SUB	E	; Window=-visible part
	NEG 
	LD	E,A	; Visible part
ExShad1	LD	D,#00
	LD	HL,WinBoxBuff+10200 ; !hardcode
	ADD	HL,DE
	ADD	HL,DE

 DUP 3				; !FIXIT can?
	LD	A,(HL)		; Line without shadow
	INC	HL
	EXX 
	LD	(HL),A
	INC	HL
	EXX 
 EDUP
	LD	A,(HL)
	INC	HL
	EXX 
	LD	(HL),A
	INC	HL

; Window
	LD	A,(IX+#04)
	SUB	(IX+#03)
	DEC	A
	LD	B,A		; Window Y-1
ShadLp	ADD	HL,DE
	ADD	HL,DE
	EXX 
	ADD	HL,DE
	ADD	HL,DE

	LD	A,(HL)
	INC	HL
	EXX 
	LD	(HL),A
	INC	HL
	EXX 

	LD	A,(HL)
	INC	HL
	EXX 
	AND	#07
	JR	NZ,$+4
	LD	A,#07
	LD	(HL),A
	INC	HL
	EXX 

	LD	A,(HL)
	INC	HL
	EXX 
	LD	(HL),A
	INC	HL
	EXX 

	LD	A,(HL)
	INC	HL
	EXX 
	AND	#07
	JR	NZ,$+4
	LD	A,#07
	LD	(HL),A
	INC	HL
	DJNZ	ShadLp

	ADD	HL,DE	; For shadow
	ADD	HL,DE
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	EXX 
	ADD	HL,DE	; Internal operation
	ADD	HL,DE
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	EXX 
	LD	B,E
ShadLp1	EXX 
	DEC	HL	; With end
	LD	A,(HL)
	EXX 
	DEC	HL
	AND	#07
	JR	NZ,$+4
	LD	A,#07
	LD	(HL),A
	EXX 
	DEC	HL
	LD	A,(HL)
	EXX 
	DEC	HL
	LD	(HL),A
	DJNZ	ShadLp1
	EXX		; Without

 DUP 3				; !FIXIT can?
	DEC	HL
	LD	A,(HL)
	EXX 
	DEC	HL
	LD	(HL),A
	EXX 
 EDUP

	DEC	HL
	LD	A,(HL)
	EXX 
	DEC	HL
	LD	(HL),A
	POP	BC		; Reset page 3 & 4
	LD	A,C
	OUT	(SLOT2),A
	LD	A,B
	OUT	(SLOT3),A
	RET 
; Procedure getting data from under window
; On: IX - descriptor
GetTxtW	PUSH	IX
	CALL	GetMousInfo
	LD	E,(IX+#01)	;Xo pos
	LD	D,(IX+#03)	;Yo pos
	LD	A,(IX+#02)
	SUB	E
	ADD	A,#02		; Shadow
	LD	L,A		;Xlen
	LD	A,(IX+#04)
	SUB	D
	INC	A		; Shadow
	LD	H,A		;Ylen
	CALL	ExCoordG	; Validity coordinates
	LD	IX,WinBoxBuff+10200	; Wind buffer
	LD	A,(BuffPg4)	;Page buffer
	LD	B,A
	LD	C,#B2
	SUB	A
	RST	#10
	CALL	GetMousInfo
	POP	IX
	RET 
; Coordinates and window working
ExCoordG
	BIT	7,E
	JR	Z,ExCoor1	; Screen
	LD	A,E
	NEG		; In and-on how many window for screen
	SUB	L	; Window=-visible part
	NEG 
	LD	L,A	; Visible part
	LD	E,#00
ExCoor1	LD	A,D
	ADD	A,H
	CP	#1F	; Screen
	RET	C
	LD	A,#1F
	SUB	D
	LD	H,A		; Normal len y
	RET 
; Procedure data from under window
; On: IX - descriptor
ResTxtW	PUSH	IX
	CALL	GetMousInfo
	LD	E,(IX+#01)	;Xo pos
	LD	D,(IX+#03)	;Yo pos
	LD	A,(IX+#02)
	SUB	E
	ADD	A,#02		; Shadow
	LD	L,A		;Xlen
	LD	A,(IX+#04)
	SUB	D
	INC	A		; Shadow
	LD	H,A		;Ylen
	CALL	ExCoordG	; Validity coordinates
	LD	IX,WinBoxBuff+10200	; Wind buffer ; !hardcode
	LD	A,(BuffPg4)	;Page buffer
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	CALL	GetMousInfo
	POP	IX
	RET 
; Procedure output on screen window with its
; On: IX - descriptor
PrnTxtW	PUSH	IY
	PUSH	IX
	PUSH	IX
	POP	IY		; IY=descriptor
	LD	L,(IY+#1F)	; Buffers
	LD	H,(IY+#20)
	LD	BC,#C000
	ADD	HL,BC
	PUSH	HL
	POP	IX		; IX=,where window
	LD	E,(IY+#01)	;Xo pos
	LD	D,(IY+#03)	;Yo pos
	LD	A,(IY+#02)
	SUB	E
	ADD	A,#02		; Shadow
	LD	L,A		;Xlen
	LD	A,(IY+#04)
	SUB	D
	INC	A		; Shadow
	LD	H,A		;Ylen
	LD	A,(IY+#21)     ;Page buffer
	LD	B,A
	CALL	ExamOut		; Coordinates
	LD	C,#B3
	EXX 
	CALL	GetMousInfo
	EXX 
	SUB	A
	RST	#10
	CALL	GetMousInfo
	LD	A,#01
	RST	#00
	POP	IX
	POP	IY
	RET 
; Coordinates on validity
ExamOut	BIT	7,E		;Xo pos
	CALL	NZ,OutScLf	; Start window for screen
	LD	A,E
	ADD	A,L		; +len x
	CP	#53		; Test by out for x pos
	CALL	NC,OutScRg	; Window for screen
	LD	A,D		;Yo pos
	ADD	A,H		; +len y
	CP	#1F
	RET	C		; Okey
	LD	A,#1F
	SUB	D
	LD	H,A		; Normal len y
	RET 
; Coordinates start window
OutScLf	IN	A,(SLOT2)
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,(IY+#21)	;Window buffer
	OUT	(SLOT2),A
	LD	A,(BuffPg4)	;Page buffer
	OUT	(SLOT3),A
	LD	A,E
	NEG		; In and-on how many window for screen
	LD	C,A	; Save
	SUB	L	; Window=-visible part
	NEG 
	LD	L,A	; Visible part
	LD	E,#00
	PUSH	HL
	PUSH	DE
	SLA	C
	LD	E,C
	LD	D,#00	; DE=offset from start window (with )
	LD	(ol1+1),DE
	LD	B,H		; Len y
	SLA	L
	LD	A,L
	LD	(ol2+1),A
	LD	H,D
	LD	(ol3+1),HL	; HL=
	LD	L,(IY+#1F)
	LD	H,(IY+#20)
	LD	A,H
	ADD	A,#80
	LD	H,A
	LD	DE,WinBoxBuff	; In new
	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
OutLf0	PUSH	BC
ol1	LD	BC,#0000
	ADD	HL,BC	; Internal operation
	LD	D,D
ol2	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
ol3	LD	BC,#0000
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
	ADD	HL,BC
	POP	BC
	DJNZ	OutLf0
	EI 
	POP	DE
	POP	HL
	POP	BC
	LD	A,B
	OUT	(SLOT3),A
	LD	A,C
	OUT	(SLOT2),A
	LD	IX,WinBoxBuff
	LD	A,(BuffPg4)
	LD	B,A
	RET 
; Window for screen
OutScRg	IN	A,(SLOT2)
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,(IY+#21)	; Place window
	OUT	(SLOT2),A
	LD	A,(BuffPg4)	;Page buffer
	OUT	(SLOT3),A
	PUSH	DE
	LD	A,#50
	SUB	E
	LD	C,L
	SLA	C
	LD	L,A
	ADD	A,A
	LD	E,A
	LD	(or1+1),A
	LD	D,#00	; DE= by X
	LD	B,D	; BC= by X
	LD	(or2+1),DE
	LD	(or3+1),BC
	PUSH	HL
	LD	B,H	; Len y
	LD	L,(IY+#1F)
	LD	H,(IY+#20)
	LD	A,H
	ADD	A,#80
	LD	H,A
	LD	DE,WinBoxBuff	; In new
	DI 
	EXX 
	CALL	GetMousInfo
	EXX 
OutRg0	PUSH	BC
	LD	D,D
or1	LD	A,#00
	LD	L,L
	LD	A,(HL)
	LD	(DE),A
	LD	B,B
	EX	DE,HL
or2	LD	BC,#0000
	ADD	HL,BC
	EX	DE,HL
or3	LD	BC,#0000
	ADD	HL,BC
	POP	BC
	DJNZ	OutRg0
	EI 
	POP	HL
	POP	DE
	POP	BC
	LD	A,B
	OUT	(SLOT3),A
	LD	A,C
	OUT	(SLOT2),A
	LD	IX,WinBoxBuff
	LD	A,(BuffPg4)
	LD	B,A
	RET 
;
 _mCollectInfo_addEnd
