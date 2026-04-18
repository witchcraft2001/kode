 _mCollectInfo_addStart
;
;[]===========================================================[]
; Dossyspage equ #3a
; Dialpg1 equ #3b
; Dialpg2 equ #3c
; Ctpage equ #3d
; Helppage equ #3e
; Asmtablepg equ #3f

; Page, where DOS
DOSsyspage	EQU 0
; Pages windows and handler
DialPg1         EQU 0
DialPg2         EQU 0
; Page, where
CTpage          EQU 0
HelpPage        EQU 0
; Page with
AsmTablePg	EQU 0

;[]===========================================================[]
;
; !HARDCODE

; For (len 256b)
FuncBuffer	EQU #7900
; For lines in andSM (len 256b)
CompBuff        EQU #7A00
; For decompilation ASM lines in text (len 512b)
ReCompBuff	EQU #7B00
; For lines (len 512b)
TextBuff        EQU #7D00
; (len 32b)
KeyBuff         EQU #7F00
; Window box buffer by buffpage4-5
WinBoxBuff	EQU #C000
;[]===========================================================[]
; Internal operation
evNothing       EQU #00	; None events
evMouseFr       EQU #01	; Pressed button mouse
evKeyboard	EQU #02	; Pressed
evCombKey       EQU #03	; Pressed
evCommand       EQU #04	; Commands
evMessage       EQU #05	; Internal operation
;[]===========================================================[]
; Commands Kode ()
cmNew           EQU #00
cmOpen          EQU #01
cmSave          EQU #02
cmSaveAs        EQU #03
cmSaveAll       EQU #04
cmPrint         EQU #05
cmPrintSt       EQU #06
cmExit          EQU #07
cmCut           EQU #08
cmCutAppnd	EQU #09
cmCopy          EQU #0A
cmAppend        EQU #0B
cmPaste         EQU #0C
cmClear         EQU #0D
cmFind          EQU #0E
cmReplace       EQU #0F
cmSearchAg	EQU #10
cmGoToLine	EQU #11
cmRun           EQU #12
cmParam         EQU #13
cmCompile       EQU #14
cmMake          EQU #15
cmPrmFile       EQU #16
cmClrPrmFl	EQU #17
cmInfo          EQU #18
cmSymbList	EQU #19
cmQuitDeb       EQU #1A
cmEditor        EQU #1B
cmColors        EQU #1C
cmSavSetUp	EQU #1D
cmTile          EQU #1E
cmCascade       EQU #1F
cmCloseAll	EQU #20
cmRefrDisp	EQU #21
cmList          EQU #22
cmEditorH       EQU #23
cmCompileH	EQU #24
cmWindowH       EQU #25
cmAboutH        EQU #26
cmHelpDesk	EQU #27
cmHelpBox       EQU #28
cmLocMenuM	EQU #29
cmLocMenuK	EQU #2A
cmClosTxtW	EQU #2B
cmMovReSiz	EQU #2C
cmNxtTxtWn	EQU #2D
cmPrvTxtWn	EQU #2E
cmZoom          EQU #2F
cmDelWind       EQU #30
cmOpenFile	EQU #31
cmReplaceF	EQU #32
cmSaveFile	EQU #33
cmImport        EQU #34
cmExport        EQU #35
cmOkey          EQU #36
cmCancel        EQU #37
cmYes           EQU #38
cmNo            EQU #39
cmSelect        EQU #3A
;[]===========================================================[]
; ()
msPtFileIn	EQU #80
msGtFileNm	EQU #81
msChangeDR	EQU #82
msHiddInvr	EQU #83
msNewElem       EQU #84
msNewList       EQU #85
msNewColor	EQU #86
msNewTest       EQU #87
;[]===========================================================[]
; Kode
KodeStart: DI 
	LD	(SaveStk+1),SP
	LD	SP,#7FFF	;Begin machine stack
	LD	IY,IYpoint
	LD	A,#C0		;Close page from 04000h
	OUT	(PORT_Y),A
	SUB	A		; Border color
	OUT	(BorderColor),A
	CALL	InitMem		;Initialize memory
	JP	C,exit
	LD	HL,#2050
	LD	D,#00
	LD	E,D
	LD	B,D
	LD	C,#89
	RST	#10		;Clear screen border color

	SUB	A
	RST	#00		;Initialized mouse

	SUB	A
	RST	#30		; Init scancode

	LD	A,#01		; Set mouse by screen
	RST	#00

	CALL	InitSetup
	LD	A,#04
	LD	(LabSize),A
	LD	(TabSize),A
	CALL	InitEvent	;Initialize event
	CALL	InitBar		; Initialize menu bar
	CALL	InitDeskTop	; Initialize desk top
	CALL	InitStLine	; Initialize status line

MainCyc	CALL	handleEvent	;Get event
	SUB	A		;Beginner object
	DEC	A
ObjLoop	INC	A		;Begin object is 0
	LD	(Cobject),A
	LD	HL,ObjList
	ADD	A,A		;*2
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	OR	H
	JR	Z,MainCyc	; 0-end object list
	LD	(callOBJ),HL
callOBJ+1: CALL	#0000
Cobject+1: LD	A,#00
	JR	ObjLoop
/*
; []===========================================================[] ; !fixit )))
	BYTE	' - Kode v ',_progVERSION,' - '
	BYTE	' Last issue ',_luaBUILD_DATEfull,' '
	BYTE	' Programmed by Anton Enin '
	BYTE	' All rights reserved. Sprinter Team '
;[]===========================================================[]
*/
; List object (first object is select)
ObjList
	WORD	MenuBar
	WORD	DeskTop
	WORD	StatusL
	WORD	#0000
;[]===========================================================[]
; Get select or noselect object
; Input: hl-address object
; Output: z-select
; Nz-noselect
GetOBJC	PUSH	DE
	EX	DE,HL
	LD	HL,(ObjList)
	OR	A
	SBC	HL,DE
	POP	DE
	RET 
; Set select or noselect object
; Input: hl-address object
SetOBJC	PUSH	IX
	PUSH	DE
	PUSH	BC
	LD	IX,ObjList
	PUSH	IX
	EX	DE,HL
	LD	HL,ReCompBuff
	PUSH	HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
SetOlp	LD	C,(IX+#00)	; Object of list
	INC	IX
	LD	B,(IX+#00)
	INC	IX
	EX	DE,HL
	PUSH	HL
	OR	A
	SBC	HL,BC
	POP	HL
	EX	DE,HL
	JR	Z,SetOlp	;Found current object
	LD	(HL),C
	INC	HL
	LD	(HL),B
	INC	HL
	LD	A,B
	OR	C
	JR	NZ,SetOlp
	POP	HL
	POP	DE
	LD	BC,#0008
	LDIR 
	POP	BC
	POP	DE
	POP	IX
	RET 
;[]===========================================================[]
exit:	CALL	CloseAll
	DI 
	LD	HL,WindGrp
	CALL	CloseGroup	; Groups
	LD	HL,MarkGrp
	CALL	CloseGroup
	CALL	ResCurs
	LD	A,(BuffInd)
	LD	C,#C3
	RST	#08
	LD	A,#02
	RST	#00
	DI 
SaveStk:	LD	SP,#0000
	IN	A,(SLOT1)
	OUT	(SLOT3),A

 IFN NEW_VERSION
	LD	A,#01
	OUT	(SLOT2),A
 ENDIF
	RET 
;[]===========================================================[]
; Memory for Kode:
; 81920 for image. from under text.windows
; 32768 ClipBoard
; 32768 for
; 65536 under table labels
; 49152 under
; : 278528 byte
InitMem:

 IF NEW_VERSION
	LD	BC,#11C2	
 ELSE
	LD	BC,#10C2														; Get block of 18 pages ; !fixit 16 pages
 ENDIF

	RST	#08
	RET	C

	LD	HL,BuffInd														;Get listing pages (8pages)
	LD	(HL),A
	INC	HL
	PUSH	HL
	LD	HL,KeyBuff+#20
	PUSH	HL
	LD	C,#C5
	RST	#08

	POP	HL
	POP	DE
	LD	BC,BuffInd.Size
	LDIR 
	EI 
	OR	A
	RET 

;-----------------------------------------------------------------------[v]
BuffInd:        BYTE	#00			; Block indificator


.Start          EQU	$	
WindPg1:        BYTE	#00			;Logic numbers text buffer pages
WindPg2:        BYTE	#00		
WindPg3:        BYTE	#00		
WindPg4:        BYTE	#00		
WindPg5:        BYTE	#00		

ClipPg1:        BYTE	#00		
ClipPg2:        BYTE	#00		

BuffPg4:        BYTE	#00		
BuffPg5:        BYTE	#00		

SymbPg1:        BYTE	#00			;Logic numbers symbol table pages
SymbPg2:        BYTE	#00		
SymbPg3:        BYTE	#00		
SymbPg4:        BYTE	#00		

MemPage1        BYTE	#00			;Logic numbers
MemPage2        BYTE	#00		
MemPage3        BYTE	#00		

 IF NEW_VERSION
	NOP
 ENDIF

BuffInd.Size	EQU $ - BuffInd.Start
;-----------------------------------------------------------------------[^]


;[]===========================================================[]
; T about'objects
PalleteAr:

; [desktop]
ColDeskTop:     BYTE	#1F,#FF		; Color desktop

; [menu bar]
ColMenuBar:     BYTE	#70,#FF		; Color menu bar
ColInvr:                BYTE	#20,#F0		; Color menu bar invert
ColBhotkey:     BYTE	#04,#0F		; Color menu bar hot key
ColHiddenC:     BYTE	#08,#0F		; Color hidden command

; [dialog windows]
ColDialWn:      BYTE	#70,#FF		; Color dialog window
ColDialFr:      BYTE	#0F,#0F		; Color dialog frame
ColDialFrM:     BYTE	#0A,#0F		; Color move dialog window
ColDialInv:     BYTE	#0F,#0F		; Color dialog window invert
ColDhotkey:     BYTE	#0E,#0F		; Color dialog hot key
ColInpLine:     BYTE	#1F,#FF		; Color input line in dialog window
ColFileInp:     BYTE	#1B,#FF		; Color file input line in dialog window
ColFileBox:     BYTE	#1B,#FF		; Color file box
ColFileBxI:     BYTE	#2F,#FF		; Color file box invert
ColFileBHI:     BYTE	#1E,#FF		; Color file box hidden invert
ColListBox:     BYTE	#17,#FF		; Color list box
ColLstBoxI:     BYTE	#2F,#FF		; Color list box invert
ColLstBxHI:     BYTE	#1E,#FF		; Color list box hidden invert
ColFileInf:     BYTE	#1B,#FF		; Color file info
ColButton:      BYTE	#20,#FF		; Color button

; [text windows]
ColTxtWin:      BYTE	#17,#FF		; Color text window
ColNormFr:      BYTE	#0F,#0F		; Color frame selected window
ColMoveFr:      BYTE	#0A,#0F		; Color move/resize window
ColHiddFr:      BYTE	#08,#0F		; Color no select window

; [syntaxis]
ColMnemon:      BYTE	#1F,#0F		; Color z80 mnemonics
ColLabel:               BYTE	#1E,#0F		; Color labels
ColComment:     BYTE	#1D,#0F		; Color comments

; [miscel]
ColWindAtr:     BYTE	#0A,#0F		; Color close button,zoom button
ColScrlBar:     BYTE	#31,#FF		; Color scrollbars
ColProcess:     BYTE	#00,#0F		; Color process line
ColSelTxt:      BYTE	#70,#FF		; Color selected text
ColReplTxt:     BYTE	#79,#FF		; Color selected text
;[]===========================================================[]
EditMode:               BYTE	#00		; 0-text edit,1-table edit
InsertMode:     BYTE	#01		; 1 - inser,0 - overwrite
OvrwrtBlck:     BYTE	#00		; For:
SynHghLght:     BYTE	#01		; Internal operation
KeyPad:         BYTE	#00		; Internal operation
KeyPad1:                BYTE	#01		; Internal operation
LabSize:                BYTE	#10		; Size for labels
TabSize:                BYTE	#08		; Size

HiddMouse:      BYTE	#00		; 01 - with

OptimalTAB:     BYTE	#01		; 01

WinPutMode:     BYTE	#00		; Text.windows: 0 - / 1

DOSpage:                BYTE	DOSsyspage	; Page with DOS
DialogPg1:      BYTE	DialPg1		; Page windows
DialogPg2:      BYTE	DialPg2		; Page windows
CnTxtPg:                BYTE	CTpage		; Page
HELPpage:               BYTE	HelpPage
AsmTabPg:               BYTE	AsmTablePg	; Page table Z80
;

;[]===========================================================[]
; Procedure open groups commands
; On: HL- list commands (#FF- list)
OpenGroup:
	LD	A,(HL)
	INC	HL
	CP	#FF
	RET	Z
	CALL	OpenCmnd
	JR	OpenGroup
; Procedure open 1 commands
; On: r.A - number commands
OpenCmnd:
	PUSH	HL
	LD	L,A
	LD	H,#00
	LD	E,L
	LD	D,H
	ADD	HL,HL
	ADD	HL,DE
	LD	DE,CmndTable
	ADD	HL,DE
	SUB	A
	INC	A
	LD	(HL),A
	POP	HL
	RET 
; Procedure close groups commands
; On: HL- list commands (#FF- list)
CloseGroup:
	LD	A,(HL)
	INC	HL
	CP	#FF
	RET	Z
	CALL	CloseCmnd
	JR	CloseGroup
; Procedure close 1 commands
; On: r.A - number commands
CloseCmnd:
	PUSH	HL
	LD	L,A
	LD	H,#00
	LD	E,L
	LD	D,H
	ADD	HL,HL
	ADD	HL,DE
	LD	DE,CmndTable
	ADD	HL,DE
	SUB	A
	LD	(HL),A
	POP	HL
	RET 
; Procedure commands
; On: r.A - number commands
; On exit: Z - command not
; NZ - command
TstCmnd:	PUSH	HL
	PUSH	DE
	LD	L,A
	LD	H,#00
	LD	E,L
	LD	D,H
	ADD	HL,HL
	ADD	HL,DE
	LD	DE,CmndTable
	ADD	HL,DE
	LD	A,(HL)
	POP	DE
	POP	HL
	OR	A
	RET 
; Procedure getting addresses program commands
; On: r.A - number commands
; On exit: HL - program
; Z - command not
; NZ - command
GetCmnd:	PUSH	DE
	LD	L,A
	LD	H,#00
	LD	E,L
	LD	D,H
	ADD	HL,HL
	ADD	HL,DE
	LD	DE,CmndTable
	ADD	HL,DE
	LD	A,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	POP	DE
	OR	A
	RET 
;[]===========================================================[]
; Table commands Kode
; Format table:
; +00 - 0 command not
; 1 command
; +01,02 - commands
CmndTable:
	BYTE	#01			; Command new
	WORD	NewText

	BYTE	#01			; Command open
	WORD	OpenFile

	BYTE	#00			; Command save
	WORD	SaveFile

	BYTE	#00			; Command save as
	WORD	SaveFileAs

	BYTE	#00			; Command save all
	WORD	SaveAll

	BYTE	#00			; Command print
	WORD	.ret

	BYTE	#01			; Command printer setup
	WORD	.ret

	BYTE	#01			; Command exit
	WORD	exit

	BYTE	#00			; Command cut
	WORD	CutBlock

	BYTE	#00			; Command cut&append
	WORD	AppCutBlck

	BYTE	#00			; Command copy
	WORD	CopyBlock

	BYTE	#00			; Command append
	WORD	AppBlock

	BYTE	#00			; Command paste
	WORD	PasteBlock

	BYTE	#00			; Command clear
	WORD	ClearBlock

	BYTE	#00			; Command find
	WORD	FindTxt

	BYTE	#00			; Command replace
	WORD	ReplTxt

	BYTE	#00			; Command search again
	WORD	NextSearch

	BYTE	#00			; Command go to line number
	WORD	GoToLine

	BYTE	#00			; Command run
	WORD	.ret

	BYTE	#00			; Command parameters
	WORD	.ret

	BYTE	#00			; Command compile
	WORD	.ret

	BYTE	#00			; Command make
	WORD	.ret

	BYTE	#00			; Command primary file
	WORD	.ret

	BYTE	#00			; Command clear primary file
	WORD	.ret

	BYTE	#00			; Command information
	WORD	.ret

	BYTE	#00			; Command symbol list
	WORD	.ret

	BYTE	#00			; Command quit debugger
	WORD	.ret

	BYTE	#01			; Command editor
	WORD	EditorOpt

	BYTE	#01			; Command colors
	WORD	Colors

	BYTE	#01			; Command save setup
	WORD	SaveSetup

	BYTE	#00			; Command tile
	WORD	Tile

	BYTE	#00			; Command cascade
	WORD	Cascade

	BYTE	#00			; Command close all
	WORD	CloseAll

	BYTE	#01			; Command refrech display
	WORD	RefrDisplay

	BYTE	#01			; Command list
	WORD	WinList

	BYTE	#01			; Command editor help
	WORD	.ret

	BYTE	#01			; Command compile help
	WORD	.ret

	BYTE	#01			; Command window help
	WORD	.ret

	BYTE	#01			; Command about help
	WORD	AboutVr

	BYTE	#01			; Command help from desktop
	WORD	.ret

	BYTE	#01			; Command help from menubox
	WORD	.ret

	BYTE	#00			; Command local menu
	WORD	LcMenuM

	BYTE	#00			; Command local menu
	WORD	LcMenuK

	BYTE	#00			; Command close text win
	WORD	ClosTxW

	BYTE	#00			; Command move resize
	WORD	MovReSizK

	BYTE	#00			; Command next text window
	WORD	NxtTxtW

	BYTE	#00			; Command previos text window
	WORD	PrvTxtW

	BYTE	#00			; Command zoom
	WORD	ZoomWin

	BYTE	#00			; Delete wind
	WORD	.ret

	BYTE	#00			; Command open file
	WORD	.ret

	BYTE	#00			; Command replace file
	WORD	.ret

	BYTE	#00			; Command okey
	WORD	.ret

	BYTE	#00			; Command cancel
	WORD	.ret

	BYTE	#00			; Delete wind
	WORD	.ret

	BYTE	#00			; Delete wind
	WORD	.ret

	BYTE	#00			; Command open file
	WORD	.ret

	BYTE	#00			; Command replace file
	WORD	.ret

	BYTE	#00			; Command okey
	WORD	.ret

	BYTE	#00			; Command cancel
	WORD	.ret

.ret:
	RET 
;[]===========================================================[]
; Handler events
InitEvent
	LD	A,#01
	RST	#30		; Clear keyboard buffer
	LD	A,#04		; Get mouse coord and buttons
	RST	#00
	LD	HL,what
	LD	B,#04
	SUB	A
	LD	(HL),A
	INC	HL
	DJNZ	$-2
	RET 
; Events
handleEvent
	LD	IX,what
	LD	(IX+#00),evNothing		; What=evnoting
	LD	A,#03			;Get mouse coords & buttons
	RST	#00

	OR	A			; Button press
	JR	NZ,ButtPrs
	LD	A,#02			;Get pressed keys
	RST	#30

	RET	Z			; No keys
	LD	A,H
	OR	A
	JR	Z,NewComb			; Press combination
	LD	(IX+#00),evKeyboard
	LD	(IX+#01),A
	RET 
NewComb	LD	(IX+#00),evCombKey		;Keyboard combination
	LD	(IX+#01),D		; Flag press by nopress
	LD	(IX+#02),L		;Pos code
	RET 
ButtPrs	BIT	0,A
	JR	NZ,RgtButt
	LD	(IX+#00),evMouseFr		;Mouse buttons press
	LD	(IX+#01),L		; Coord x
	LD	(IX+#02),H		; Coord y
	RET 
RgtButt	LD	(IX+#00),evCommand
	LD	(IX+#01),cmLocMenuM
	RET 
; Field events Event List
; +00:
; 0 - not event
;
; 1 - event with buttons:
; +02 - current buttons
; +03,04 - position cursor
;
; 2 - new position cursor:
; +02,03 - position cursor
;
; 3 - event with keyboard
; +01 - scancode keys
;
; 4 - event with keyboard combination
; +01 - keyflag current lock
; +02 - number combination
;
; 5 - event with command
; +01 - number command
what:	DEFS   #08,#00			; Field events
;[]===========================================================[]
AboutVr:	LD	HL,DaboutV
	CALL	DialogW
	RET 
;[]===========================================================[]
NoSpace:	LD	HL,Dnospace
	CALL	DialogW
	LD	HL,what
	LD	(HL),evNothing
	LD	SP,#7FFF
	JP	MainCyc
;[]===========================================================[]
; Handler windows
DialogW:	IN	A,(SLOT2)
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	LD	A,(DialogPg2)
	OUT	(SLOT3),A
	CALL	Dialog
	POP	BC
	LD	A,B
	OUT	(SLOT3),A
	LD	A,C
	OUT	(SLOT2),A
	RET 
; Handler Menu Bar
InitBar:
	IN	A,(SLOT2)
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,(CnTxtPg)
	OUT	(SLOT2),A
	LD	A,(HELPpage)
	OUT	(SLOT3),A
	CALL	InitMenuBar
	POP	BC
	LD	A,B
	OUT	(SLOT3),A
	LD	A,C
	OUT	(SLOT2),A
	RET 
MenuBar:
	IN	A,(SLOT2)
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,(CnTxtPg)
	OUT	(SLOT2),A
	LD	A,(HELPpage)
	OUT	(SLOT3),A
	CALL	MenuBarExe
	POP	BC
	LD	A,B
	OUT	(SLOT3),A
	LD	A,C
	OUT	(SLOT2),A
	RET 
SetMBar:
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(CnTxtPg)
	OUT	(SLOT2),A
	LD	A,(BarFlag)
	OR	A
	JR	NZ,SMBe
	CALL	ResCurs
	LD	HL,MenuBar
	CALL	SetOBJC
	CALL	SetBarI
SMBe:	POP	AF
	OUT	(SLOT2),A
	RET 
ResMBar:
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(CnTxtPg)
	OUT	(SLOT2),A
	LD	A,(BarFlag)
	OR	A
	JR	Z,RMBe
	LD	HL,DeskTop
	CALL	SetOBJC
	CALL	ResBarI
RMBe:	POP	AF
	OUT	(SLOT2),A
	RET 
; Handler Status Line
InitStLine:
	IN	A,(SLOT2)
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,(CnTxtPg)
	OUT	(SLOT2),A
	LD	A,(HELPpage)
	OUT	(SLOT3),A
	CALL	InitStatLn
	POP	BC
	LD	A,B
	OUT	(SLOT3),A
	LD	A,C
	OUT	(SLOT2),A
	RET 
PutStatusLn:
	EX	AF,AF'
	IN	A,(SLOT2)
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,(CnTxtPg)
	OUT	(SLOT2),A
	LD	A,(HELPpage)
	OUT	(SLOT3),A
	EX	AF,AF'
	CALL	PutStatLn
	POP	BC
	LD	A,B
	OUT	(SLOT3),A
	LD	A,C
	OUT	(SLOT2),A
	RET 
PrvStatusLn:
	EX	AF,AF'
	IN	A,(SLOT2)
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,(CnTxtPg)
	OUT	(SLOT2),A
	LD	A,(HELPpage)
	OUT	(SLOT3),A
	EX	AF,AF'
	CALL	PrvStatLn
	POP	BC
	LD	A,B
	OUT	(SLOT3),A
	LD	A,C
	OUT	(SLOT2),A
	RET 
StatusL:	IN	A,(SLOT2)
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,(CnTxtPg)
	OUT	(SLOT2),A
	LD	A,(HELPpage)
	OUT	(SLOT3),A
	CALL	StatusLine
	POP	BC
	LD	A,B
	OUT	(SLOT3),A
	LD	A,C
	OUT	(SLOT2),A
	RET 
InitSetup:
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(DialogPg2)
	OUT	(SLOT3),A
	CALL	InitSetUp
	POP	AF
	OUT	(SLOT3),A
	RET 
SaveSetup:
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(DialogPg2)
	OUT	(SLOT3),A
	CALL	SaveSetUp
	POP	AF
	OUT	(SLOT3),A
	RET 
;
 _mCollectInfo_addEnd
