 _mCollectInfo_addStart
;[]===========================================================[]
; Working screen
InitDeskTop
	CALL	ClearDesk
	LD	HL,TxtWtab	; Delete table windows
	LD	(HL),#80
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	LD	HL,NameTab	; Delete table names
	LD	DE,NameTab+1
	LD	BC,1919         ; !hardcode label - nametab
	LD	(HL),#00
	LDIR 
	POP	AF
	OUT	(SLOT2),A
	LD	A,cmNew		; Open command New
	CALL	OpenCmnd
	LD	HL,FreeWin	; Table
	LD	DE,TwistNm	; Table
	LD	B,#0F		; Free windows
WnNumLp	LD	A,#0F
	SUB	B
	LD	(HL),A
	INC	HL
	LD	(DE),A
	INC	DE
	DJNZ	WnNumLp
	RET 
ClearDesk
	LD	DE,#0100	; Set current pos for print
	LD	C,#84
	RST	#10
	LD	B,#1E
	LD	A,(ColDeskTop)
	LD	C,A
InDesk1	PUSH	BC
	LD	A,#B0
	LD	E,C
	LD	B,#50
	LD	C,#81
	RST	#10		; Put line
	POP	BC
	DJNZ	InDesk1
	RET 
;[]===========================================================[]
; Procedure open new text window by command -New
NewText	CALL	GetMemory	; Get free pages
	JP	C,NoSpace	; None memory
	CALL	ResMBar
	LD	IX,TxtWtab
	BIT	7,(IX+#00)
	JR	NZ,NewTn
	CALL	OnlySyntax
	CALL	PutString
	CALL	ResCurs
NewTn	SUB	A		; Header
	CALL	InitWin		; Descriptor new window
	LD	HL,Noname
	CALL	InitNam		; Place name window in.names
	CALL	HiddWin		; Disable current.window
	CALL	PutTextWn	; Open new window
	LD	HL,WindGrp
	CALL	OpenGroup	; Groups
	LD	HL,MarkGrp
	CALL	CloseGroup
	LD	HL,(EqClipLn)
	LD	A,H
	OR	L
	JR	Z,$+7
	LD	A,cmPaste
	CALL	OpenCmnd	; Open command Paste
	LD	A,NoConTxt
	CALL	PutStatusLn	; Status line
	CALL	OnlySyntax	; Line
	CALL	SetCurs		; Enable.cursor
	LD	A,#04
	RST	#00
	LD	HL,FreeWin
	SUB	A
	LD	B,#0F
	BIT	7,(HL)	; Count count-in open windows
	INC	HL
	JR	Z,$+3
	INC	A
	DJNZ	$-6
	CP	#0F
	RET	C		; Less 9 - Okey
	LD	A,cmNew		; Already 9
	CALL	CloseCmnd	; Command New
	LD	A,NoConTxt	; Internal operation
	CALL	PutStatusLn	; Status line
	RET 

; Commands, / / window (#FF-)
WindGrp	DEFB	cmSave,cmSaveAs,cmSaveAll,cmPrint
	DEFB	cmFind,cmReplace,cmTile
	DEFB	cmCascade,cmCloseAll,cmGoToLine,cmClosTxtW
	DEFB	cmNxtTxtWn,cmPrvTxtWn,cmMovReSiz,cmLocMenuM
	DEFB	cmLocMenuK,cmOpenFile,cmZoom,cmSearchAg,#FF
;===============================================================
; Procedure close text window
ClosTxW	CALL	OnlySyntax
	CALL	PutString
	LD	A,(IY+#17)
	OR	A
	JR	NZ,ClosTxN
	CALL	SureWin
	LD	HL,what
	LD	A,(HL)
	INC	HL
	CP	evCommand
	RET	NZ
	LD	A,(HL)
	CP	cmCancel
	RET	Z
ClosTxN	CALL	ResCurs
	LD	IX,TxtWtab	; Table descriptors windows
	CALL	ResTxtW		; Window with screen
	LD	A,(IX+#1C)	; Text.pages
	LD	C,#C3		; Free pages
	PUSH	IX
	RST	#10
	POP	IX
	LD	HL,FreeWin
	LD	A,(IX+#00)
	AND	#0F
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
	RES	7,(HL)		; Free window
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	LD	HL,NameTab-#80
	LD	DE,#0080
	LD	A,(IX+#00)
	AND	#0F
	INC	A
	LD	B,A
	ADD	HL,DE		; Search name window
	DJNZ	$-1
	SUB	A
	LD	(HL),A		; Its
	POP	AF
	OUT	(SLOT2),A
	CALL	ResetWn		; Descriptor from table
	LD	IX,TxtWtab
	BIT	7,(IX+#00)
	JR	NZ,ClName3
	LD	A,(IX+#1D)
	OUT	(SLOT2),A
	LD	A,(IX+#1E)
	OUT	(SLOT3),A
	CALL	GetTxtW
	LD	HL,FrameSl
	CALL	PutFram
	CALL	PutShad
	CALL	PrnTxtW
	CALL	ReCompileStr
	CALL	OnlySyntax
	CALL	SetCurs
	LD	HL,MarkGrp
	LD	DE,(EquipMr)
	LD	A,D
	OR	E
	PUSH	AF
	CALL	Z,CloseGroup
	POP	AF
	CALL	NZ,OpenGroup
ClName3	LD	HL,FreeWin
	SUB	A
	LD	B,#0F
	BIT	7,(HL)	; Count count-in open windows
	INC	HL
	JR	Z,$+3
	INC	A
	DJNZ	$-6
	OR	A
	JR	NZ,ClosExt	; Already 0
	LD	HL,WindGrp
	CALL	CloseGroup	; Groups
	LD	HL,MarkGrp
	CALL	CloseGroup
	LD	A,cmPaste	; Already 9
	CALL	CloseCmnd	; Command New
	CALL	SetMBar
ClosExt	LD	A,cmNew
	CALL	OpenCmnd	; Open command New
	LD	A,NoConTxt	; Internal operation
	CALL	PutStatusLn	; Status line
	CALL	RefrWin		; Refresh
	LD	A,#04		; Internal operation
	RST	#00
	LD	HL,what	; Field events
	LD	(HL),evNothing
	RET 
;===============================================================
;Text window table
;Format:
; +00 - (0-14 number window)
; Bit7 - end table ,bit6 is select
; +01 - xo position window by screen
; +02 - xi position window by screen
; +03 - yo position window by screen
; +04 - yi position window by screen
;
; +05 - x position close button
; +06 - y position close button
; +07 - x position button open to full screen
; +08 - y position button open to full screen
; +09 - xo position move window
; +0a - xi position move window
; +0b - y position move window
; +0c - x position resize window
; +0d - y position resize window
; +0e - x position line up
; +0f - y position line up
; +10 - x position vertical scrollbar
; +11 - yo position vertical scrollbar
; +12 - yi position vertical scrollbar
; +13 - x position line down
; +14 - y position line down
; +15 - x position line scroll left
; +16 - y position line scroll left
; +17 - xo position horizontal scrollbar
; +18 - xi position horizontal scrollbar
; +19 - y position horizontal scrollbar
; +1a - x position line scroll right
; +1b - y position line scroll right
;
; +1c - indeficator text pages
; +1d - first text page
; +1e - second text page
; +1f,20 - address swop buffer
; +21 - buffer page
; +22 - pevios xo position
; +23 - pevios xi position
; +24 - pevios yo position
; +25 - pevios yi position
;End table: code >#80
TxtWtab	DEFB	#80
	DEFS	#26*15,0

; Procedure, descriptor window
InitWin	LD	IX,TxtWtab
	PUSH	AF
	CALL	IsrtWin		; In. place under window
	LD	HL,FreeWin-1	; Search window
	INC	HL
	BIT	7,(HL)		; 7bit window
	JR	NZ,$-3
	LD	A,(HL)		; Number window
	SET	7,(HL)		; Flag
	BIT	7,(IX+#00)
	LD	(IX+#00),A	; Number window
	JR	Z,PutWinNxt
; Window
PutFrstWn
	LD	(IX+#01),#00	;Xo pos
	LD	(IX+#02),#50	;Xi pos
	LD	(IX+#03),#01	;Yo pos
	LD	(IX+#04),#1F	;Yi pos
	JP	PtLabel
PutWinNxt
	LD	A,(WinPutMode)
	OR	A
	JP	Z,PutCascade
	LD	HL,FreeWin
	SUB	A
	LD	B,#0F
	BIT	7,(HL)	; Count count-in open windows
	INC	HL
	JR	Z,$+3
	INC	A
	DJNZ	$-6
	LD	HL,TileTab
	LD	DE,#0000
	LD	B,A
	ADD	HL,DE
	INC	DE
	INC	DE
	INC	DE
	INC	DE
	DJNZ	$-5
	LD	IX,TxtWtab	; Table window descriptors
	LD	DE,#0026
	ADD	IX,DE
	BIT	7,(IX+#00)  ; Search same window
	JR	Z,$-6
	LD	DE,-#0026   ; Refresh window down by table
	PUSH	IX
PtTile2	ADD	IX,DE
	LD	A,(HL)		;Ypos
	INC	HL
	INC	A
	LD	(IX+#03),A
	LD	A,(HL)		;Xpos
	INC	HL
	LD	(IX+#01),A
	LD	A,(HL)		;Ylen
	INC	HL
	ADD	A,(IX+#03)
	LD	(IX+#04),A
	LD	A,(HL)		;Xlen
	INC	HL
	ADD	A,(IX+#01)
	LD	(IX+#02),A
	LD	A,(IX+#1D)
	OUT	(SLOT2),A
	LD	A,(IX+#1E)
	OUT	(SLOT3),A
	CALL	InsWatr
	BIT	6,(IX+#00)
	JR	Z,PtTile2
	ADD	IX,DE
	LD	A,(HL)		;Ypos
	INC	HL
	INC	A
	LD	(IX+#03),A
	LD	A,(HL)		;Xpos
	INC	HL
	LD	(IX+#01),A
	LD	A,(HL)		;Ylen
	INC	HL
	ADD	A,(IX+#03)
	LD	(IX+#04),A
	LD	A,(HL)		;Xlen
	INC	HL
	ADD	A,(IX+#01)
	LD	(IX+#02),A
	POP	IX
	CALL	NewDisplay
	LD	IX,TxtWtab
	JR	PtLabel
PutCascade
	LD	E,(IX+#27)	;Xo prev window
	LD	D,(IX+#28)	;Xi prev window
	LD	C,(IX+#29)	;Yo prev window
	LD	B,(IX+#2A)	;Yi prev window
	LD	A,E
	BIT	7,A		; Window for screen
	JP	NZ,PutFrstWn
	INC	A
	CP	#50
	JR	NZ,$+3		; Out of screen
	DEC	A
	LD	(IX+#01),A	;Xo pos
	LD	A,D
	CP	#51
	JP	NC,PutFrstWn	  ; Out of screen
	INC	A
	CP	#51
	JR	NZ,$+3		; Out of screen
	DEC	A
	LD	(IX+#02),A	;Xi pos
	LD	A,C
	INC	A
	CP	#1F
	JR	NZ,$+3		; Out of screen
	DEC	A
	LD	(IX+#03),A	;Yo pos
	LD	A,B
	CP	#20
	JP	NC,PutFrstWn	  ; Out of screen
	INC	A
	CP	#20
	JR	NZ,$+3		; Out of screen
	DEC	A
	LD	(IX+#04),A	;Yi pos
	LD	A,(IX+#02)
	SUB	(IX+#01)	; Check window
	CP	#19		; X
	JR	NC,PtNext1
	LD	A,(IX+#02)
	SUB	#19
	LD	(IX+#01),A
PtNext1	LD	A,(IX+#04)
	SUB	(IX+#03)
	CP	#05		; Y
	JR	NC,PtLabel
	LD	A,(IX+#04)
	SUB	#05
	LD	(IX+#03),A
PtLabel	SET	6,(IX+#00)	; Work window
	LD	A,(KeyBuff+#20)
	LD	HL,(KeyBuff+#21)
	LD	(IX+#1C),A	;Page indificator
	LD	(IX+#1D),L	;Page 1
	LD	(IX+#1E),H	;Page 2
	LD	HL,AddrBf-2	; Search in table
	LD	DE,WindPg1-1	; Buffers for window
	LD	A,(IX+#00)	; Page buffers
	AND	#0F		; In reg.and-number window
	INC	DE
	SUB	#03
	JR	NC,$-3
	ADD	A,#03
	INC	A
	LD	B,A
	INC	HL
	INC	HL
	DJNZ	$-2
	LD	A,(DE)		; Number pages
	LD	E,(HL)		; Offset start buffers
	INC	HL
	LD	D,(HL)
	LD	(IX+#1F),E	;Address buffer
	LD	(IX+#20),D	;
	LD	(IX+#21),A	; Buffer page
	LD	A,(IX+#1D)	; 1 text page
	OUT	(SLOT2),A
	LD	A,(IX+#1E)	; 2 text page
	OUT	(SLOT3),A
	POP	AF
	OR	A
	JR	NZ,NoHead
	LD	HL,FHeader
	LD	DE,#8000
	LD	BC,#0044
	LDIR 
NoHead	LD	HL,TextBuff
	LD	A,(ColTxtWin)
	LD	(HL),C
	INC	HL
	LD	(HL),A
	INC	HL
	DJNZ	$-4
	LD	A,(IX+#01)
	LD	(IX+#22),A	; Previos coords
	LD	A,(IX+#02)
	LD	(IX+#23),A
	LD	A,(IX+#03)
	LD	(IX+#24),A
	LD	A,(IX+#04)
	LD	(IX+#25),A
; Close button coord
InsWatr	LD	A,(IX+#01)	;Xo pos
	ADD	A,#03
	LD	(IX+#05),A	;X close button
	LD	A,(IX+#03)	;Yo pos
	LD	(IX+#06),A	;Y close button
; Open to full screen coord
	LD	A,(IX+#02)	;Xi pos
	SUB	#04
	LD	(IX+#07),A	;X button open full
	LD	A,(IX+#03)	;Yo pos
	LD	(IX+#08),A	;Y button open full
; Move window coord
	LD	A,(IX+#01)	;Xo pos
	LD	(IX+#09),A	; Xo pos move
	LD	A,(IX+#02)	;Xi pos
	LD	(IX+#0A),A	; Xi pos move
	LD	A,(IX+#03)	;Yo pos
	LD	(IX+#0B),A	; Y pos move
; Resize window coord
	LD	A,(IX+#02)	;Xi pos
	DEC	A
	LD	(IX+#0C),A	; X pos resize
	LD	A,(IX+#04)	;Yi pos
	DEC	A
	LD	(IX+#0D),A	; Y pos resize
; Line up
	LD	A,(IX+#02)	;Xi pos
	DEC	A
	LD	(IX+#0E),A	; X line up
	LD	A,(IX+#03)	;Yo pos
	INC	A
	LD	(IX+#0F),A	; Y line up
; Vertical scrollbar
	LD	A,(IX+#02)	;Xi pos
	DEC	A
	LD	(IX+#10),A	;X vert.scrlb
	LD	A,(IX+#03)	;Yo pos
	ADD	A,#02
	LD	(IX+#11),A	;Yo vert.scrlb
	LD	A,(IX+#04)	;Yi pos
	SUB	#02
	LD	(IX+#12),A	;Yi vert.scrlb
; Line down
	LD	A,(IX+#02)	;Xi pos
	DEC	A
	LD	(IX+#13),A	; X line down
	LD	A,(IX+#04)	;Yi pos
	SUB	#02
	LD	(IX+#14),A	; Y line down
; Scroll left
	LD	A,(IX+#01)	;Xo pos
	ADD	A,#15
	LD	(IX+#15),A	;X scrl.lf
	LD	A,(IX+#04)	;Yi pos
	DEC	A
	LD	(IX+#16),A	;Y scrl.lf
; Horizontal scrollbar
	LD	A,(IX+#01)	;Xo pos
	ADD	A,#16
	LD	(IX+#17),A	;Xi hor.scrlb
	LD	A,(IX+#02)	;Xi pos
	SUB	#02
	LD	(IX+#18),A	;Yo hor.scrlb
	LD	A,(IX+#04)	;Yi pos
	DEC	A
	LD	(IX+#19),A	;Yi hor.scrlb
; Scroll right
	LD	A,(IX+#02)	;Xi pos
	SUB	#02
	LD	(IX+#1A),A	; X line scrl.rg
	LD	A,(IX+#04)	;Yi pos
	DEC	A
	LD	(IX+#1B),A	; Y line scrl.rg
	LD	A,(IX+#01)
	INC	A
	LD	(IY+#03),A	;Xposwind
	LD	A,(IX+#02)
	SUB	(IX+#01)
	SUB	#02
	LD	(IY+#05),A	;Xlenwind
	LD	A,(IX+#03)
	INC	A
	LD	(IY+#04),A	;Yposwind
	LD	A,(IX+#04)
	SUB	(IX+#03)
	SUB	#02
	LD	(IY+#06),A	;Ylenwind
	LD	A,#FF
	LD	(IY+#1C),A
	LD	(IY+#1D),A
	LD	(IY+#20),A
	LD	(IY+#21),A
	RET 
;Address for swop (shift from begin page)
AddrBf	DEFW	#0000		; From start buffers
	DEFW	#1500
	DEFW	#2A00

FreeWin	DEFS	15,0		 ; Free windows
	DEFB	#40

; Name for commands -New- (0-)
Noname	DEFB	"NONAME.TXT",0

FHeader	DEFB	"KODEv0.70",0
	DEFW	#0000	;Temp ceil
	DEFB	#00
	DEFB	0,0,0	; Estring,tempadd,tempx
	DEFB	0,0,0	; Xposcurs,yposcurs,inpsymb
	DEFB	0,0,0,0	; Xwin,ywin,xlen,ylen
	DEFB	0,0,0,0,0 ; Addx,syntflg,llabel,lcmnd,largum
	DEFW	0000	; Curline
	DEFW	#8040	; Prevpage
	DEFW	#0000	; Nextpage
	DEFW	#8043	; Endtext
	DEFW	#8040	; Begstring
	DEFB	1,1	; Readystr,readyfile
	DEFW	#0001	; Count-in lines
	DEFW	#0000	; Emp Vbar address
	DEFW	#0000	; Temp vbar pos
	DEFW	#0000	; Emp Hbar address
	DEFW	#0000	; Temp hbar pos
	DEFW	#0000	;Up line page for bar
	DEFB	#00	; Proecflag
	DEFW	#0000	;Temp prev page
	DEFW	#0000	;Temp up line
	DEFB	#00	; Temp y pos
	DEFB	#00	; Temp x pos
	DEFB	#00	; Temp addx pos
	DEFW	#0000	; Count-in.lines
	DEFS	#02,0
	DEFB	#03,#02,#03,0	; First string
TileTab
; Single window
	DEFB	#00,#00,#1E,#50
; Window
	DEFB	#00,#00,#0F,#50
	DEFB	#0F,#00,#0F,#50
; Window
	DEFB	#00,#00,#0F,#28
	DEFB	#0F,#00,#0F,#28
	DEFB	#00,#28,#1E,#28
; Window
	DEFB	#00,#00,#0F,#28
	DEFB	#0F,#00,#0F,#28
	DEFB	#00,#28,#0F,#28
	DEFB	#0F,#28,#0F,#28
; Windows
	DEFB	#00,#00,#0A,#28
	DEFB	#0A,#00,#0A,#28
	DEFB	#14,#00,#0A,#28
	DEFB	#00,#28,#0F,#28
	DEFB	#0F,#28,#0F,#28
; Windows
	DEFB	#00,#00,#0A,#28
	DEFB	#0A,#00,#0A,#28
	DEFB	#14,#00,#0A,#28
	DEFB	#00,#28,#0A,#28
	DEFB	#0A,#28,#0A,#28
	DEFB	#14,#28,#0A,#28
; Windows
	DEFB	#00,#00,#07,#28
	DEFB	#07,#00,#07,#28
	DEFB	#0E,#00,#08,#28
	DEFB	#16,#00,#08,#28
	DEFB	#00,#28,#0A,#28
	DEFB	#0A,#28,#0A,#28
	DEFB	#14,#28,#0A,#28
; Windows
	DEFB	#00,#00,#08,#28
	DEFB	#08,#00,#08,#28
	DEFB	#10,#00,#07,#28
	DEFB	#17,#00,#07,#28
	DEFB	#00,#28,#07,#28
	DEFB	#07,#28,#07,#28
	DEFB	#0E,#28,#08,#28
	DEFB	#16,#28,#08,#28
; Windows
	DEFB	#00,#00,#0A,#1B
	DEFB	#0A,#00,#0A,#1B
	DEFB	#14,#00,#0A,#1B
	DEFB	#00,#1B,#0A,#1A
	DEFB	#0A,#1B,#0A,#1A
	DEFB	#14,#1B,#0A,#1A
	DEFB	#00,#35,#0A,#1B
	DEFB	#0A,#35,#0A,#1B
	DEFB	#14,#35,#0A,#1B
; Windows
	DEFB	#00,#00,#08,#1B
	DEFB	#08,#00,#08,#1B
	DEFB	#10,#00,#07,#1B
	DEFB	#17,#00,#07,#1B
	DEFB	#00,#1B,#0A,#1A
	DEFB	#0A,#1B,#0A,#1A
	DEFB	#14,#1B,#0A,#1A
	DEFB	#00,#35,#0A,#1B
	DEFB	#0A,#35,#0A,#1B
	DEFB	#14,#35,#0A,#1B
; Windows
	DEFB	#00,#00,#07,#1B
	DEFB	#07,#00,#07,#1B
	DEFB	#0E,#00,#08,#1B
	DEFB	#16,#00,#08,#1B
	DEFB	#00,#1B,#08,#1A
	DEFB	#08,#1B,#08,#1A
	DEFB	#10,#1B,#07,#1A
	DEFB	#17,#1B,#07,#1A
	DEFB	#00,#35,#0A,#1B
	DEFB	#0A,#35,#0A,#1B
	DEFB	#14,#35,#0A,#1B
; Windows
	DEFB	#00,#00,#07,#1B
	DEFB	#07,#00,#07,#1B
	DEFB	#0E,#00,#08,#1B
	DEFB	#16,#00,#08,#1B
	DEFB	#00,#1B,#08,#1A
	DEFB	#08,#1B,#08,#1A
	DEFB	#10,#1B,#07,#1A
	DEFB	#17,#1B,#07,#1A
	DEFB	#00,#35,#07,#1B
	DEFB	#07,#35,#07,#1B
	DEFB	#0E,#35,#08,#1B
	DEFB	#16,#35,#08,#1B
; Windows
	DEFB	#00,#00,#06,#1B
	DEFB	#06,#00,#06,#1B
	DEFB	#0C,#00,#06,#1B
	DEFB	#12,#00,#06,#1B
	DEFB	#18,#00,#06,#1B
	DEFB	#00,#1B,#08,#1A
	DEFB	#08,#1B,#08,#1A
	DEFB	#10,#1B,#07,#1A
	DEFB	#17,#1B,#07,#1A
	DEFB	#00,#35,#07,#1B
	DEFB	#07,#35,#07,#1B
	DEFB	#0E,#35,#08,#1B
	DEFB	#16,#35,#08,#1B
; Windows
	DEFB	#00,#00,#06,#1B
	DEFB	#06,#00,#06,#1B
	DEFB	#0C,#00,#06,#1B
	DEFB	#12,#00,#06,#1B
	DEFB	#18,#00,#06,#1B
	DEFB	#00,#1B,#06,#1A
	DEFB	#06,#1B,#06,#1A
	DEFB	#0C,#1B,#06,#1A
	DEFB	#12,#1B,#06,#1A
	DEFB	#18,#1B,#06,#1A
	DEFB	#00,#35,#07,#1B
	DEFB	#07,#35,#07,#1B
	DEFB	#0E,#35,#08,#1B
	DEFB	#16,#35,#08,#1B
; Windows
	DEFB	#00,#00,#06,#1B
	DEFB	#06,#00,#06,#1B
	DEFB	#0C,#00,#06,#1B
	DEFB	#12,#00,#06,#1B
	DEFB	#18,#00,#06,#1B
	DEFB	#00,#1B,#06,#1A
	DEFB	#06,#1B,#06,#1A
	DEFB	#0C,#1B,#06,#1A
	DEFB	#12,#1B,#06,#1A
	DEFB	#18,#1B,#06,#1A
	DEFB	#00,#35,#06,#1B
	DEFB	#06,#35,#06,#1B
	DEFB	#0C,#35,#06,#1B
	DEFB	#12,#35,#06,#1B
	DEFB	#18,#35,#06,#1B
;[]===========================================================[]
; Get 2 pages under text
GetMemory
	LD	BC,#02C2	; Get block of 2 pages
	RST	#10
	RET	C		; No memory
	LD	HL,KeyBuff+#20	;Get listing pages (2pages)
	LD	(HL),A
	INC	HL
	LD	C,#C5
	RST	#10
	OR	A
	RET 
;[]===========================================================[]
; Procedure in table names name new window
; (if name already,then to name its number)
InitNam	LD	IX,TxtWtab
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	PUSH	HL
	LD	HL,TwistNm
	LD	B,#0F
	RES	7,(HL)
	INC	HL
	DJNZ	$-3
	POP	HL
	CALL	SearchN		; Search
	PUSH	BC		; In reg.B=0 none,B=1
	PUSH	HL
	LD	A,(IX+#00)	; Number window
	AND	#0F
	INC	A
	LD	B,A
	LD	HL,NameTab-#80
	LD	DE,#0080
	ADD	HL,DE		; Buffers for name
	DJNZ	$-1
	EX	DE,HL
	POP	HL
	LDI			; Copy its
	LD	A,(HL)
	OR	A
	JR	NZ,$-4
	EX	DE,HL
	LD	B,C
	POP	AF
	OR	A
	JR	Z,MakeNex	; None
	LD	(HL),#BA	;:
	INC	HL
	DEC	B
	EX	DE,HL
	LD	HL,TwistNm-1
	INC	HL
	BIT	7,(HL)
	JR	NZ,$-3
	LD	A,(HL)
	SET	7,(HL)
	EX	DE,HL
	CP	#0A
	JR	C,$+8
	SUB	#0A
	LD	(HL),"1"
	INC	HL
	DEC	B
	ADD	A,"0"		; Number name
	LD	(HL),A
	INC	HL
	DEC	B
	SUB	A
MakeNex	LD	(HL),A
	INC	HL
	DEC	B
	JR	Z,$+6
	LD	(HL),A		; Fill end table
	INC	HL
	DJNZ	$-2
	POP	AF
	OUT	(SLOT2),A
	RET 
; Procedure search names windows
; On: HL- name
; On exit: B-0 none B=1
SearchN	LD	DE,NameTab	; Start table names
	LD	BC,#0080	; It
SnameMn	LD	A,(DE)
	OR	A
	JR	Z,SnameN1
	RET	M		; Table
	PUSH	HL
	PUSH	DE
SnameLp	INC	DE
	CP	(HL)
	INC	HL
	JR	NZ,SnameNx
	LD	A,(DE)		;:
	OR	A
	JP	M,FoundNm
	JR	NZ,SnameLp
	LD	A,#BA		;:
	LD	(DE),A
	INC	DE
	LD	A,"0"
	LD	(DE),A
	INC	DE
	SUB	A
	LD	(DE),A
	LD	HL,TwistNm
	JR	SnameN0
FoundNm	LD	HL,TwistNm
	INC	DE
	PUSH	BC
	LD	B,#00
	LD	A,(DE)
FoundM1	INC	DE
	SUB	#30
	LD	C,A
	LD	A,B
	ADD	A,A
	LD	B,A
	ADD	A,A
	ADD	A,A
	ADD	A,B
	ADD	A,C
	LD	B,A
	LD	A,(DE)
	OR	A
	JR	NZ,FoundM1
	LD	A,B
	POP	BC
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
SnameN0	SET	7,(HL)
	SET	0,B
SnameNx	POP	DE
	POP	HL
SnameN1	LD	A,E
	ADD	A,C
	LD	E,A
	JR	NC,SnameMn
	INC	D
	JR	SnameMn
;[]===========================================================[]
TwistNm	DEFS	15,0	; Table
;[]===========================================================[]
; Procedure Local Menu from
LcMenuK	POP	DE
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(CnTxtPg)
	OUT	(SLOT2),A
	CALL	LcMenuKe
	POP	AF
	OUT	(SLOT2),A
	RET 
;[]===========================================================[]
; Procedure Local Menu from mouse
LcMenuM	POP	DE
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(CnTxtPg)
	OUT	(SLOT2),A
	CALL	LcMenuMe
	POP	AF
	OUT	(SLOT2),A
	RET 
 _mCollectInfo_addEnd