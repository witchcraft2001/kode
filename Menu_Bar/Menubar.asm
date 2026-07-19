 _mCollectInfo_addStart
; Initialize menubar,menubar table for mouse
InitMenuBar
	SUB	A
	LD	(CurMBox),A
	LD	(BarFlag),A
	INC	A
	LD	(CurMenu),A	;Current menu is begin
	LD	IX,BarTabl
	LD	HL,ReCompBuff
	LD	DE,MenuTab
	LD	B,#00		; B=begin x coords
	LD	A,(ColMenuBar)
	LD	C,A		;C=color menubar
	LD	(HL),#20
	INC	HL
	LD	(HL),C
	INC	HL
	INC	B
InBarL1	LD	(HL),#20
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(IX+#00),B	; Left x coords
	INC	IX
	INC	B
	LD	A,(DE)		;Get name submenu
InBarL2	INC	DE
	CP	"~"		;Flag hot key
	CALL	Z,Bhotkey
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	INC	B
	LD	A,(DE)
	OR	A
	JR	NZ,InBarL2
	LD	(HL),#20
	INC	HL
	LD	(HL),C
	INC	HL
	INC	B
	LD	(IX+#00),B	; Right x coords
	INC	IX
	INC	DE
	LD	A,(DE)		; Hot key calls
	LD	(IX+#00),A
	INC	IX
	INC	DE
	LD	A,(DE)		; Address window labels
	LD	(IX+#00),A
	INC	IX
	INC	DE
	LD	A,(DE)
	LD	(IX+#00),A
	INC	IX
	INC	DE
	LD	A,(DE)		; 0 - end menubar
	OR	A
	JR	NZ,InBarL1
	LD	(IX+#00),#80	; #80-end mouse table
	LD	A,#50
	SUB	B
	JR	Z,InBarEx
	LD	B,A		;Fill to end screen
	LD	(HL),#20
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-5
InBarEx	LD	IX,ReCompBuff + NEW_ADDR*2 ; Put menubar by screen
	LD	HL,#0150
	LD	DE,#0000
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	CALL	SetMBar		;Set bar invert
	RET 

Bhotkey	PUSH	DE
	LD	A,(ColMenuBar)
	AND	#0F
	LD	D,A
	LD	A,(ColBhotkey)	; Set/res color hot key
	XOR	D
	XOR	C
	LD	C,A
	POP	DE
	LD	A,(DE)
	INC	DE
	RET 

; Set by screen menubar current invert
SetBarI	LD	A,(BarFlag)
	OR	A
	RET	NZ
	INC	A
	LD	(BarFlag),A
	LD	HL,BarTabl
	LD	A,(CurMenu)	; Get current menu
	DEC	A
	LD	C,A		;*5
	ADD	A,A
	ADD	A,A
	ADD	A,C
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
	LD	E,(HL)		;Xo
	INC	HL
	LD	D,#00		;Y = 0
	LD	A,(HL)
	SUB	E		; Xi-xo=lenx
	LD	L,A
	LD	H,#01		; Len y
	LD	(RBrIlen+1),HL
	LD	(RBrIpos+1),DE
	PUSH	AF		; Save lenx
	LD	IX,ReCompBuff + NEW_ADDR*2	; Get name menu
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B2
	SUB	A
	RST	#10
	POP	AF		; Reset lenx
	LD	HL,ReCompBuff
	LD	B,A
	LD	A,(ColInvr)
	LD	C,A
SetInvB	INC	HL
	LD	A,(HL)		;Set invert
	AND	#0F
	OR	C
	LD	(HL),A
	INC	HL
	DJNZ	SetInvB
	LD	IX,ReCompBuff + NEW_ADDR*2	; Put name with invert
	LD	HL,(RBrIlen+1)
	LD	DE,(RBrIpos+1)
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	RET 

BarFlag	DEFB	#00	; Flag barinvert 00-no/01-yes

; Res by screen menubar current invert
ResBarI	LD	A,(BarFlag)
	OR	A
	RET	Z
	SUB	A
	LD	(BarFlag),A
	LD	IX,ReCompBuff + NEW_ADDR*2	;Get name with invert
RBrIlen	LD	HL,#0000
RBrIpos	LD	DE,#0000
	LD	A,L
	PUSH	AF
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B2
	SUB	A
	RST	#10
	POP	AF
	LD	HL,ReCompBuff
	LD	B,A
	LD	A,(ColMenuBar)
	AND	#F0
	LD	C,A
ResInvB	INC	HL
	LD	A,(HL)		;Set invert
	AND	#0F
	OR	C
	LD	(HL),A
	INC	HL
	DJNZ	ResInvB
	LD	IX,ReCompBuff + NEW_ADDR*2	; Put name with invert
	LD	HL,(RBrIlen+1)
	LD	DE,(RBrIpos+1)
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	RET 

; Set invert in menubox
SetBoxI	LD	HL,BoxTabl+4
	LD	A,(CurMBox)
	DEC	A
	ADD	A,A		;*6
	LD	C,A
	ADD	A,A
	ADD	A,C
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
	LD	E,(HL)
	INC	HL
	LD	A,(HL)
	INC	HL
	LD	D,(HL)
	SUB	E		; Xi-xo=lenx
	LD	L,A
	LD	H,#01		; Len y
	LD	(RBxIlen+1),HL
	LD	(RBxIpos+1),DE
	PUSH	AF		; Save lenx
	LD	IX,ReCompBuff + NEW_ADDR*2	; Get name menu
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B2
	SUB	A
	RST	#10
	POP	AF		; Reset lenx
	LD	HL,ReCompBuff
	LD	B,A
	LD	A,(ColInvr)
	LD	C,A
SetInvX	INC	HL
	LD	A,(HL)		;Set invert
	AND	#0F
	OR	C
	LD	(HL),A
	INC	HL
	DJNZ	SetInvX
	LD	IX,ReCompBuff + NEW_ADDR*2	; Put name with invert
	LD	HL,(RBxIlen+1)
	LD	DE,(RBxIpos+1)
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	RET 

; Res by screen menubox current invert
ResBoxI	LD	IX,ReCompBuff + NEW_ADDR*2	;Get name with invert
RBxIlen	LD	HL,#0000
RBxIpos	LD	DE,#0000
	LD	A,L
	PUSH	AF
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B2
	SUB	A
	RST	#10
	POP	AF
	LD	HL,ReCompBuff
	LD	B,A
	LD	A,(ColMenuBar)
	AND	#F0
	LD	C,A
ResInvX	INC	HL
	LD	A,(HL)		;Set invert
	AND	#0F
	OR	C
	LD	(HL),A
	INC	HL
	DJNZ	ResInvX
	LD	IX,ReCompBuff + NEW_ADDR*2	; Put name with invert
	LD	HL,(RBxIlen+1)
	LD	DE,(RBxIpos+1)
	IN	A,(SLOT1)
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	RET 

CurMenu	DEFB	#00	; Current mark menu
CurMBox	DEFB	#00	; Current mark menubox

; Format menubar table:
; Name (end - 0),keyboard combination,address window labels
; 0 - end table
MenuTab	DEFB	"~F~ile",0,033
	DEFW	FileWin
	DEFB	"~E~dit",0,018
	DEFW	EditWin
	DEFB	"~S~earch",0,031
	DEFW	SrchWin
	DEFB	"~R~un",0,019
	DEFW	RunWin
	DEFB	"~C~ompile",0,046
	DEFW	CompWin
	DEFB	"~D~ebug",0,032
	DEFW	DebWin
	DEFB	"~O~ptions",0,024
	DEFW	OptnWin
	DEFB	"~W~indows",0,017
	DEFW	WindWin
	DEFB	"~H~elp",0,035
	DEFW	HelpWin
	DEFB	#00

; Main block +menubar+
MenuBarExe
	LD	HL,what
	LD	DE,MBexit	; Menu bar exit
	PUSH	DE
	LD	A,(HL)		; Get event
	INC	HL
	CP	evMouseFr	;Fire mouse
	JP	Z,MBmouse
	CP	evKeyboard	;Press key
	JR	Z,MBkeys
	CP	evCombKey	;Press comb.key
	JR	Z,MBcbkey
MenuExt	POP	DE
	RET 

; Menu bar keys event
MBkeys	LD	A,(HL)
	CP	#1B		;Esc
	JP	Z,CloseBx
	CP	#0D		;Enter
	JR	NZ,MBkeysN
	LD	A,(CurMBox)	; If not box then open
	OR	A
	JP	Z,OpenBox
	LD	IX,BoxTabl-2	; Search element
	LD	DE,#0006
	LD	A,(CurMBox)
	LD	B,A
	ADD	IX,DE
	DJNZ	$-2
	JP	BxEnter

MBkeysN	LD	L,A
	LD	A,(CurMBox)
	OR	A
	RET	Z
	LD	IX,BoxTabl-2
	LD	BC,#0006
	LD	H,B
	LD	A,L		; Search element menu
	RES	5,A
MBkeys1	INC	H
	ADD	IX,BC
	BIT	7,(IX+#00)
	RET	NZ
	CP	(IX+#04)
	JR	NZ,MBkeys1
	JP	BxHotEx

MBcbkey	INC	HL
	LD	A,(HL)
	CP	#44		;F10
	JP	Z,SetMBar
	CP	72	; Curs up
	JR	Z,MBup
	CP	80	;Curs down
	JP	Z,MBdown
	CP	75	;<-
	JP	Z,MBleft
	CP	77	;->
	JP	Z,MBright
	CP	71	;Home
	JP	Z,MBhome
	CP	79	;End
	JP	Z,MBend
	; Top-menu accelerators share numeric codes with some Ctrl+letter keys.
	; Match them only for a real Alt combination (what+1, bit 3), so e.g.
	; Alt+O opens Options while Ctrl+X remains available for Cut.
	DEC	HL
	BIT	3,(HL)
	INC	HL
	JP	Z,MenuExt
	LD	IX,BarTabl-5
	LD	BC,#0005
	LD	H,B
MBcbLp	INC	H		; Search hot key
	ADD	IX,BC
	BIT	7,(IX+#00)
	JP	NZ,MBoxExt
	CP	(IX+#02)
	JR	NZ,MBcbLp
	LD	A,(CurMenu)
	CP	H
	JR	NZ,MBcbnxt
	LD	A,(CurMBox)
	OR	A
	RET	NZ		; Box is open
MBcbnxt	LD	A,H
	LD	(CurMenu),A
	CALL	SetMBar
	CALL	ResBarI
	CALL	SetBarI
	CALL	ClosBox
	CALL	OpenBox
	RET 

; Cursor up
MBup	LD	A,(CurMBox)
	OR	A
	CALL	Z,OpenBox	;Not box
	LD	A,(CurMBox)
	DEC	A
	JR	NZ,MBupNxt
	LD	IX,BoxTabl-2
	LD	BC,#0006
	LD	A,B
	DEC	A
MBupLp	INC	A	; Search last element
	ADD	IX,BC
	BIT	7,(IX+#00)
	JR	Z,MBupLp
MBupNxt	LD	(CurMBox),A
	LD	B,A
	LD	IX,BoxTabl-2
	LD	DE,#0006
	ADD	IX,DE
	DJNZ	$-2
	PUSH	IX
	CALL	ResBoxI
	CALL	SetBoxI
	POP	IX
	LD	A,(IX+#05)
	CALL	PutStatusLn
	RET 
; Cursor down
MBdown	LD	A,(CurMBox)
	OR	A
	JP	Z,OpenBox
	LD	A,(CurMBox)
	INC	A
	LD	IX,BoxTabl-2
	LD	BC,#0006
	LD	H,B	; Test by last element
MBdnLp	INC	H
	ADD	IX,BC
	BIT	7,(IX+#00)
	JR	Z,MBdnLp
	CP	H
	JR	NZ,$+4
	LD	A,#01
	JR	MBupNxt
; Cursor left
MBleft	LD	A,(CurMenu)
	DEC	A
	JR	NZ,MBlfNxt
	LD	IX,BarTabl-5
	LD	BC,#0005
	LD	A,B
	DEC	A
MBlfLp	INC	A		; Search last element
	ADD	IX,BC
	BIT	7,(IX+#00)
	JR	Z,MBlfLp
MBlfNxt	LD	(CurMenu),A
	CALL	ResBarI
	CALL	SetBarI
	LD	A,(CurMBox)
	OR	A
	RET	Z
	CALL	ClosBox
	CALL	OpenBox
	RET 
; Cursor right
MBright	LD	A,(CurMenu)
	INC	A
	LD	IX,BarTabl-5
	LD	BC,#0005
	LD	H,B
MBrgLp	INC	H		; Test by last element
	ADD	IX,BC
	BIT	7,(IX+#00)
	JR	Z,MBrgLp
	CP	H
	JR	NZ,$+4
	LD	A,#01
	JR	MBlfNxt
; Home
MBhome	LD	A,(CurMBox)
	OR	A
	RET	Z
	DEC	A
	RET	Z
	LD	A,#01
	JP	MBupNxt
; End
MBend	LD	A,(CurMBox)
	OR	A
	RET	Z
	LD	H,A
	LD	IX,BoxTabl-2
	LD	BC,#0006
	LD	A,B
	DEC	A
MBendLp	INC	A	; Search last element
	ADD	IX,BC
	BIT	7,(IX+#00)
	JR	Z,MBendLp
	CP	H
	RET	Z
	JP	MBupNxt

; Menu bar mouse event
MBmouse	LD	E,(HL)		; Get mouse coords in de
	INC	HL
	LD	D,(HL)
	LD	A,D
	CP	#1F
	JP	Z,MenuExt
	OR	A
	JR	NZ,MBmousB	; Y<>0 then test by box open
	LD	IX,BarTabl-5
	LD	BC,#0005
	LD	H,B
	LD	A,E		; Search element menu
MBmous1	INC	H
	ADD	IX,BC
	BIT	7,(IX+#00)
	JP	NZ,CloseBx
	CP	(IX+#00)
	JR	C,MBmous1	; <xo
	CP	(IX+#01)
	JR	NC,MBmous1	; >xi
	LD	A,(CurMenu)
	CP	H
	JR	NZ,MBopenB
	LD	A,(CurMBox)	; Test by current open menu
	OR	A
	JP	NZ,SetMBar
MBopenB	LD	A,H		;Found element
	LD	(CurMenu),A
	CALL	SetMBar
	CALL	ClosBox
	CALL	ResBarI
	CALL	SetBarI
	CALL	OpenBox
	RET 

; Test mouse coords by box place
MBmousB	LD	A,(CurMBox)
	OR	A
	JP	Z,MBoxExt	;No box
	LD	IX,BoxTabl
	LD	A,E
	CP	(IX+#00)
	JP	C,CloseBx	; <xo
	CP	(IX+#01)
	JP	NC,CloseBx	; >xi
	LD	A,D
	CP	(IX+#02)
	JP	C,CloseBx	; <yo
	CP	(IX+#03)
	JP	NC,CloseBx	; >yi
	DEC	IX
	DEC	IX
	LD	BC,#0006
	LD	H,B
MBloopB	INC	H
	ADD	IX,BC
	BIT	7,(IX+#00)
	RET	NZ
	LD	A,D
	CP	(IX+#02)
	JR	NZ,MBloopB
	LD	A,E		; Search element box
	CP	(IX+#00)
	JR	C,MBloopB	; <xo
	CP	(IX+#01)
	JR	NC,MBloopB	; >xi
BxHotEx	LD	A,(CurMBox)
	CP	H
	JR	Z,BxEnter	; Box element is set
	LD	A,H
	LD	(CurMBox),A
	PUSH	IX
	CALL	ResBoxI
	CALL	SetBoxI
	POP	IX
	LD	A,(IX+#05)
	CALL	PutStatusLn
	LD	B,#04
	HALT 
	DJNZ	$-1
BxEnter	LD	A,(IX+#03)
	CALL	TstCmnd
	RET	Z		;Command is close
	LD	HL,what
	LD	(HL),evCommand
	INC	HL
	LD	A,(IX+#03)
	LD	(HL),A
	SUB	A
	DEC	A
	LD	(Cobject),A	;Returned to first object
MBoxExt	POP	DE
CloseBx	CALL	ClosBox
	LD	A,NoConTxt
	CALL	PutStatusLn
	LD	A,#04
	RST	#00
	LD	IX,TxtWtab
	BIT	7,(IX+#00)
	RET	NZ
	CALL	ResMBar
	CALL	SetCurs
	RET 

; Menu box exit
MBexit	LD	HL,what
	LD	(HL),evNothing
	LD	A,#04
	RST	#00
	RET 

; Menubox "file"
; Format menubox
; #00 - next string - next:keyboard combination,genered command
; #fe - empty string
; #ff - end menubox
; Command,"name",0,context
; Char in ~ ~ - hot key
FileWin	DEFB	cmNew,"~N~ew           F4",0,CTnew
	DEFB	cmOpen,"~O~pen...       F3",0,CTopen
	DEFB	cmSave,"~S~ave          F2",0,CTsave
	DEFB	cmSaveAs,"Save ~a~s...",0,CTsaveAs
	DEFB	cmSaveAll,"Save a~l~l",0,CTsaveAll
	DEFB	#FE
	DEFB	cmPrint,"~P~rint",0,CTprint
	DEFB	cmPrintSt,"Printer se~t~up...",0,CTprintSet
	DEFB	#FE
	DEFB	cmExit,"~E~xit       Alt+X",0,CTexit
	DEFB	#FF

EditWin	DEFB	cmCut,"~C~ut              Ctrl+X",0,CTcut
	DEFB   cmCutAppnd,"C~u~t&Append    Shift+Del",0,CTcutapp
	DEFB	cmCopy,"C~o~py             Ctrl+C",0,CTcopy
	DEFB	cmAppend,"~A~ppend         Ctrl+Ins",0,CTappnd
	DEFB	cmPaste,"~P~aste            Ctrl+V",0,CTpaste
	DEFB	cmClear,"C~l~ear               Del",0,CTclear
	DEFB	#FF

SrchWin	DEFB	cmFind,"~F~ind...              F7",0,CTfind
	DEFB   cmReplace,"~R~eplace...           F8",0,CTreplace
       DEFB cmSearchAg,"~S~earch again   Shift+F7",0,CTsearchAg
	DEFB	#FE
       DEFB cmGoToLine,"~G~o to line...  Shift+F8",0,CTgotoLine
	DEFB	#FF

RunWin	DEFB	cmRun,"~R~un        Ctrl+F9",0,CTrun
	DEFB	cmParam,"~P~arameters...",0,CTparam
	DEFB	#FF

CompWin	DEFB	cmInfo,"~I~nformation...",0,CTinfo
	DEFB	#FF

DebWin	DEFB	cmSymbList,"~S~ymbol list...",0,CTsymbList
	DEFB	#FE
	DEFB	cmQuitDeb,"~Q~uit to debugger",0,CTquitDeb
	DEFB	#FF

OptnWin	DEFB	cmEditor,"~E~ditor...",0,CTeditor
	DEFB	cmColors,"~C~olors...",0,CTcolor
	DEFB	#FE
	DEFB	cmSavSetUp,"~S~ave setup      ",0,CTsavsetup
	DEFB	#FF

WindWin	DEFB	cmTile,"~T~ile",0,CTtile
	DEFB	cmCascade,"~C~ascade",0,CTcascade
	DEFB	cmCloseAll,"Close ~a~ll",0,CTcloseAll
	DEFB	cmRefrDisp,"~R~efresh display",0,CTrefrDisp
	DEFB	#FE
	DEFB	cmList,"~L~ist...       Alt+0",0,CTlist
	DEFB	#FF

HelpWin	DEFB	cmEditorH,"~E~ditor...",0,CTeditorH
	DEFB	cmWindowH,"~W~indows...",0,CTwindowH
	DEFB	#FE
	DEFB	cmAboutH,"~A~bout version...",0,CTversionH
	DEFB	#FF
; Genered menubar table for work
; Format: +0 - xo coord
; +1 - xi coord
; +2 - keyboard combination
; +3,4 - address window label
BarTabl	BLOCK	46,#00

; Genered menubox table for work
; Format: window position
; +0 - xo coord
; +1 - xi coord
; +2 - yo coord
; +3 - yi coord
; Element position +04 of begin
; +0 - xo coord
; +1 - xi coords
; +2 - y coords
; +3 - genered command
; +4 - hot key
; +5 - element context
BoxTabl	DEFS	53,#00

; Open menu box
; Input parameters:
; (curmenu)-number menubox
OpenBox	LD	B,#01
	LD	HL,BarTabl	; Search begin menu
	LD	A,(CurMenu)
	DEC	A
	LD	C,A		;*5
	ADD	A,A
	ADD	A,A
	ADD	A,C
	ADD	A,L
	LD	L,A
	JR	NC,$+3
	INC	H
PutMenu	PUSH	IY
	LD	IY,BoxTabl	; Generes menubox mouse table
	LD	IX,BoxData
	LD	A,(HL)
	DEC	A
	INC	HL
	LD	(IY+#00),A	; Xo position menubox
	INC	A
	LD	(IX+#02),A	; Xo for element box
	LD	(IY+#02),B	; Yo position menubox
	LD	(IX+#04),B	; Temp y posit for element box
	INC	HL
	INC	HL
	LD	A,(HL)		; Address window label
	LD	(IX+#00),A	; Save opisatel
	INC	HL
	LD	H,(HL)
	LD	(IX+#01),H
	LD	L,A
	CALL	GetLenB		; Get in de len y,x menubox
	LD	A,E		; Xi position menubox
	SUB	#02
	LD	(IX+#05),A	; Len x without frame
	LD	A,E
	ADD	A,(IY+#00)
	LD	(IY+#01),A
	DEC	A
	LD	(IX+#03),A	; Xi for element box
	LD	A,D
	ADD	A,(IY+#02)	; Yi position menubox
	LD	(IY+#03),A

	CALL	SaveBox		; Get box place

	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg4)	;Page buffer
	OUT	(SLOT3),A
;Begin put box with shadow
	LD	HL,WinBoxBuff+4800
	LD	BC,#0004
	ADD	IY,BC		; Begin window labels
	EXX 
	LD	HL,WinBoxBuff
	LD	A,(IX+#05)	; Len box x
	INC	A
	INC	A
	ADD	A,A
	LD	E,A
	LD	D,#00
	ADD	HL,DE
	EXX 
	LD	A,(ColMenuBar)
	LD	C,A

	LD	(HL),#DA	; First line
	INC	HL
	LD	(HL),C
	INC	HL
	LD	B,(IX+#05)	; Len box x
	LD	A,#C4
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	LD	(HL),#BF
	INC	HL
	LD	(HL),C
	INC	HL
	EXX			;First line without shadow
	LD	A,(HL)
	INC	HL
	EXX 
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
	LD	(HL),A
	INC	HL
	EXX 
	LD	A,(HL)
	INC	HL
	ADD	HL,DE
	EXX 
	LD	(HL),A
	INC	HL

	LD	E,(IX+#00)
	LD	D,(IX+#01)
;Main cycle box
MainPutBox
	INC	(IX+#04)	; Increment y coord element
	LD	A,(DE)
	INC	DE
	CP	#FE
	JR	NZ,PutBln2
	LD	(HL),#C3
	INC	HL
	LD	(HL),C
	INC	HL
	LD	B,(IX+#05)
	LD	A,#C4
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	LD	(HL),#B4
	INC	HL
	LD	(HL),C
	INC	HL
	EXX 
	LD	A,(HL)
	INC	HL
	INC	HL
	EXX 
	LD	(HL),A
	INC	HL
	LD	(HL),#07
	INC	HL
	EXX 
	LD	A,(HL)
	INC	HL
	INC	HL
	ADD	HL,DE
	EXX 
	LD	(HL),A
	INC	HL
	LD	(HL),#07
	INC	HL
	JR	MainPutBox

PutBln2	CP	#FF
	JP	Z,BoxExit
	LD	B,A
	LD	A,(IX+#02)
	LD	(IY+#00),A
	INC	IY
	LD	A,(IX+#03)
	LD	(IY+#00),A
	INC	IY
	LD	A,(IX+#04)
	LD	(IY+#00),A
	INC	IY
	LD	A,B
	LD	(IY+#00),A
	INC	IY
	CALL	TstCmnd
	JR	Z,HidCmnd
	LD	(HL),#B3
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),#20
	INC	HL
	LD	(HL),C
	INC	HL
	LD	B,#00
PutBln3	LD	A,(DE)
	INC	DE
	CP	"~"
	JR	NZ,PutB33
	CALL	Bhotkey		;Print hot key
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	INC	DE
	INC	B
	RES	5,A
	LD	(IY+#00),A	; Put hot key in table
	INC	IY
	CALL	Bhotkey

PutB33	LD	(HL),A		;Put name element
	INC	HL
	LD	(HL),C
	INC	HL
	INC	B
	LD	A,(DE)
	OR	A
	JR	NZ,PutBln3+1
	INC	DE
	LD	A,(DE)		;Put element context
	INC	DE
	LD	(IY+#00),A
	INC	IY
	LD	A,(IX+#05)	;Len element
	DEC	A
	SUB	B
	LD	B,A
	LD	(HL),#20
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-5
	LD	(HL),#B3
	INC	HL
	LD	(HL),C
	INC	HL
	EXX 
	LD	A,(HL)
	INC	HL
	INC	HL
	EXX 
	LD	(HL),A
	INC	HL
	LD	(HL),#07
	INC	HL
	EXX 
	LD	A,(HL)
	INC	HL
	INC	HL
	ADD	HL,DE
	EXX 
	LD	(HL),A
	INC	HL
	LD	(HL),#07
	INC	HL
	JP	MainPutBox

HidCmnd	LD	A,(ColHiddenC)
	LD	B,A
	LD	A,C
	AND	#F0
	OR	B
	LD	B,A
	LD	A,C
	EX	AF,AF'
	LD	(HL),#B3
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),#20
	INC	HL
	LD	(HL),B
	INC	HL
	LD	C,#00
PutBln4	LD	A,(DE)
	INC	DE
	CP	"~"
	JR	Z,PutBln4
	LD	(HL),A
	INC	HL
	LD	(HL),B
	INC	HL
	INC	C
	LD	A,(DE)
	OR	A
	JR	NZ,PutBln4+1
	INC	DE
	LD	(IY+#00),#FF	;Not hot key
	INC	IY
	LD	A,(DE)
	INC	DE
	LD	(IY+#00),A	;Put element context
	INC	IY
	LD	A,(IX+#05)
	DEC	A
	SUB	C
	LD	C,B
	LD	B,A
	LD	(HL),#20
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-5
	LD	(HL),#B3
	INC	HL
	EX	AF,AF'
	LD	C,A
	LD	(HL),C
	INC	HL
	EXX 
	LD	A,(HL)
	INC	HL
	INC	HL
	EXX 
	LD	(HL),A
	INC	HL
	LD	(HL),#07
	INC	HL
	EXX 
	LD	A,(HL)
	INC	HL
	INC	HL
	ADD	HL,DE
	EXX 
	LD	(HL),A
	INC	HL
	LD	(HL),#07
	INC	HL
	JP	MainPutBox

BoxExit	LD	(IY+#00),#80	;End table
	LD	(HL),#C0
	INC	HL
	LD	(HL),C
	INC	HL
	LD	B,(IX+#05)
	LD	A,#C4
	LD	(HL),A
	INC	HL
	LD	(HL),C
	INC	HL
	DJNZ	$-4
	LD	(HL),#D9
	INC	HL
	LD	(HL),C
	INC	HL
	EXX		; Put box shadow
	LD	A,(HL)
	INC	HL
	INC	HL
	EXX 
	LD	(HL),A
	INC	HL
	LD	(HL),#07
	INC	HL
	EXX		; Put box shadow
	LD	A,(HL)
	INC	HL
	INC	HL
	EXX 
	LD	(HL),A
	INC	HL
	LD	(HL),#07
	INC	HL
; Print down shadow
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
	LD	(HL),A
	INC	HL
	LD	B,(IX+#05)	; Full len box
	INC	B
	INC	B

WinSh	EXX 
	LD	A,(HL)
	INC	HL
	INC	HL
	EXX 
	LD	(HL),A
	INC	HL
	LD	(HL),#07
	INC	HL
	DJNZ	WinSh

	POP	AF
	OUT	(SLOT3),A
	CALL	PutBox
	POP	IY
	SUB	A
	INC	A
	LD	(CurMBox),A
	CALL	SetBoxI		;Set box invert
	LD	IX,BoxTabl+4
	LD	A,(IX+#05)
	CALL	PutStatusLn
	RET 

; Get len menubox
; Input: hl-address window label
; Output: d-len y,e-len x
GetLenB	LD	DE,#0204
	LD	B,E
	DEC	B
GetLnL1	LD	A,(HL)
	INC	HL
	CP	#FF		; End
	RET	Z
	CP	#FE		; Empty line
	JR	Z,AddLine
GetLnL2	INC	B
	LD	A,(HL)
	INC	HL
	CP	"~"		; Hot key
	JR	Z,GetLnL2+1
	OR	A		; End string
	JR	NZ,GetLnL2
	INC	HL
	LD	A,B
	CP	E
	JR	C,AddLine
	LD	E,B
AddLine	INC	D
	LD	B,#03
	JR	GetLnL1

SaveBox	PUSH	IX
	PUSH	DE
	CALL	ResCurs
	POP	DE
	INC	E		; With shadow
	INC	E
	INC	D
	LD	L,(IY+#00)	; Posit wind
	LD	H,(IY+#02)
	LD	A,L
	ADD	A,E
	CP	#52		; Test by out of screen
	JR	C,GetBnxt
	SUB	#52
	LD	L,A
	LD	A,(IX+#02)
	SUB	L
	LD	(IX+#02),A
	LD	A,(IX+#03)
	SUB	L
	LD	(IX+#03),A
	LD	A,(IY+#00)
	SUB	L
	LD	(IY+#00),A
	LD	A,(IY+#01)
	SUB	L
	LD	(IY+#01),A
	LD	A,#52
	SUB	E
	LD	L,A
GetBnxt	EXX 
	CALL	GetMousInfo
	EXX 
	LD	IX,WinBoxBuff	; Address box buffers
	LD	A,(BuffPg4)	;Page buffer
	LD	B,A
	LD	C,#B2
	SUB	A
	EX	DE,HL
	LD	(BoxLen+1),HL
	LD	(BoxPos+1),DE
	RST	#10
	CALL	GetMousInfo
	POP	IX
	RET 

PutBox	PUSH	IX
	CALL	GetMousInfo
	LD	IX,WinBoxBuff+4800  ; Address box buffers
BoxLen	LD	HL,#0000	; Len box
BoxPos	LD	DE,#0000	; Pos box
	LD	A,(BuffPg4)	;Page buffer
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	CALL	GetMousInfo
	POP	IX
	RET 

BoxData
CurBox	DEFW	#0000	;+0,+1
Xo	DEFB	#00
Xi	DEFB	#00
Ypos	DEFB	#00
Xlen	DEFB	#00

; Close box and restore box place
ClosBox	LD	A,(CurMBox)
	OR	A
	RET	Z
	CALL	GetMousInfo
	LD	IX,WinBoxBuff	; Address box buffers
	LD	HL,(BoxLen+1)	; Len box
	LD	DE,(BoxPos+1)	; Pos box
	LD	A,(BuffPg4)	;Page buffer
	LD	B,A
	LD	C,#B3
	SUB	A
	RST	#10
	CALL	GetMousInfo
	SUB	A
	LD	(CurMBox),A
	LD	A,#01
	RST	#00
	RET 
;
 _mCollectInfo_addEnd
