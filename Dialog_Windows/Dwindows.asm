 _mCollectInfo_addStart
;[]===========================================================[]
DopenFl	DEFW	#0310
	DEFW	#1930
	DEFB	"Open a file",0

	DEFB	FileBox		; About'object
	DEFW	#0403		; Yo,xo
	DEFB	#0D		; Leny
	DEFB	"~F~iles",0,CTfileboxD ; Name list box,context

	DEFB	FileInfo
	DEFW	#1503	; Yo,xo
	DEFB	#2A	; Len x

	DEFB	Button
	DEFW	#0524
	DEFB	"  ~O~pen  ",0,cmOpenFile,CTopenD

	DEFB	Button
	DEFW	#0824
	DEFB	" ~R~eplac ",0,cmReplaceF,CTreplfD

	DEFB	Button
	DEFW	#0B24
	DEFB	" ~I~mport ",0,cmImport,CTimportD

	DEFB	Button
	DEFW	#0E24
	DEFB	" Cancel ",0,cmCancel,CTcancD

	DEFB	Button
	DEFW	#1124
	DEFB	"  Help  ",0,cmCancel,CThelpD

	DEFB	FileInput
	DEFW	#0205
	DEFB	"~N~ame:",0,#17,CTfileinpD
	DEFW	FileBuf

	DEFB	#FF
;[]===========================================================[]
DsaveFl	DEFW	#0310
	DEFW	#1930
	DEFB	"Save file as",0

	DEFB	FileBox		; About'object
	DEFW	#0403		; Yo,xo
	DEFB	#0D		; Leny
	DEFB	"~F~iles",0,CTfileboxD ; Name list box,context

	DEFB	FileInfo
	DEFW	#1503	; Yo,xo
	DEFB	#2A	; Len x

	DEFB	Button
	DEFW	#0524
	DEFB	"  ~S~ave  ",0,cmSaveFile,CTopenD

	DEFB	Button
	DEFW	#0924
	DEFB	"  Save   ",0,cmSaveFile,CTopenD

	DEFB	Button
	DEFW	#0D24
	DEFB	" Cancel ",0,cmCancel,CTcancD

	DEFB	Button
	DEFW	#1124
	DEFB	"  Help  ",0,cmCancel,CThelpD

	DEFB	FileInput
	DEFW	#0205
	DEFB	"~N~ame:",0,#17,CTfileinpD
	DEFW	FileBuf

	DEFB	#FF

FileBuf	DEFB	#80	;Max input symbols
	DEFB	#00	; Readystring
	DEFB	#00	; Pos x
	DEFB	#00	; Add x
	DEFB	#00	; Inp.symb
FileIL	DEFS	#80,0

FileMask DEFB	"*.*",0,"     "
DIRmask	 DEFB	"*.*",0
;[]===========================================================[]
Dprocess
	DEFW	#0A10,#0A30	; Ypos,xpos,ylen,xlen
	DEFB	"Converter",0	; Name window

	DEFB	TextLine	; About'object ~ ~
	DEFW	#0210		; Ypos,xpos
	DEFB	"Converting file:",0	; (0-end)

	DEFB	TextLine	; About'object ~ ~
	DEFW	#0303		; Ypos,xpos
ConName	DEFS	#2A," "		; Be name
	DEFB	0

	DEFB	ProcesLine	; About'object ~ process~
	DEFW	#0504		; Ypos,xpos
	DEFB	#28		;Xlen
	DEFW	FileBytes	; With MAX count- 32
	DEFW	CurrBytes	; With current.count- 32
ConCall	DEFW	#0000		; Working program

	DEFB	Button		; About'object ~button~
	DEFW	#0714		; Ypos,xpos
	DEFB	"  ~S~top  ",0	; Button (0 - )
	DEFB	cmCancel	; Command
	DEFB	CTstopD		; Internal operation

	DEFB	#FF		; Descriptor.window
;[]===========================================================[]
Dfind	DEFW	#040D		; Y,x position window
	DEFW	#1836		; Y,x len window
	DEFB	"Find",0	; Name window

	DEFB	ClRadioBut	; Object claster radio buttons
	DEFW	#0404		; Y,x position claster
	DEFW	#0216		; Len y,x claster
	DEFB	"Options",0	;Name claster
	DEFB	"~C~ase sensetive",0 ;Name elements
	DEFB	CTcaseD		;Context help
	DEFW	CaseSenset	; Memory ceil
	DEFB	"~W~hole words only",0
	DEFB	CTwholD		;Context help
	DEFW	WordOnly
	DEFB	0		;End claster

	DEFB	ClCheckBut	; Object claster check buttons
	DEFW	#041D		; Y,x position claster
	DEFW	#0213		; Len y,x claster
	DEFB	"Scope",0	;Name claster
	DEFB	"~G~lobal",0	;Name elements
	DEFB	CTglobD		;Context help
	DEFW	FGlobal		; Memory ceil
	DEFB	"~S~elected text",0
	DEFB	CTselcD		;Context help
	DEFW	FSelText
	DEFB	0		;End claster

	DEFB	ClCheckBut	; Object claster check buttons
	DEFW	#0A04		; Y,x position claster
	DEFW	#0212		; Len y,x claster
	DEFB	"Direction",0	;Name claster
	DEFB	"~F~orward",0	;Name elements
	DEFB	CTforwD		;Context help
	DEFW	FForward	; Memory ceil
	DEFB	"~B~ackward",0
	DEFB	CTbackD		;Context help
	DEFW	FBackward
	DEFB	0		;End claster

	DEFB	ClCheckBut	; Object claster check buttons
	DEFW	#0A1D		; Y,x position claster
	DEFW	#0212		; Len y,x claster
	DEFB	"Origin",0	;Name claster
	DEFB	"From c~u~rsor",0  ;Name elements
	DEFB	CTfrCrD		;Context help
	DEFW	FFromCur	; Memory ceil
	DEFB	"~E~ntire scope",0
	DEFB	CTentrD		;Context help
	DEFW	FEntScope
	DEFB	0		;End claster

	DEFB	ClRadioBut	; Object claster radio buttons
	DEFW	#1012		; Y,x position claster
	DEFW	#0112		; Len y,x claster
	DEFB	"Search mode",0	;Name claster
	DEFB	"~L~abels only",0  ;Name elements
	DEFB	CTlabelD	;Context help
	DEFW	LabelOnly	; Memory ceil
	DEFB	0		;End claster

	DEFB	Button		; Object button
	DEFW	#150B		; Y,x position button
	DEFB	"  Help  ",0  ;Name elements
	DEFB	cmCancel
	DEFB	CThelpD		;Context help

	DEFB	Button		; Object button
	DEFW	#1517		; Y,x position button
	DEFB	" Cancel ",0  ;Name elements
	DEFB	cmCancel
	DEFB	CTcancD		;Context help

	DEFB	Button		; Object button
	DEFW	#1523		; Y,x position button
	DEFB	"  F~i~nd  ",0	;Name elements
	DEFB	cmOkey
	DEFB	CTfindBD	;Context help

	DEFB	InputLine	; Object input line
	DEFW	#0204		; Pos y,x from begin window
	DEFB	"~T~ext to find:",0 ; Name ojects
	DEFB	#21		; Len input line in window
	DEFB	CTfindD		;Context help
	DEFW	FindBuf		; Address input line

	DEFB	#FF		; End dialog wind
;[]===========================================================[]
Dreplac	DEFW	#020D,#1B36
	DEFB	"Replace",0

	DEFB	InputLine
	DEFW	#0408
	DEFB	"~N~ew text:",0,#21,CTreplD
	DEFW	ReplBuf

	DEFB	ClRadioBut
	DEFW	#0604,#0316
	DEFB	"Options",0
	DEFB	"~C~ase sensetive",0,CTcaseD
	DEFW	CaseSenset
	DEFB	"~W~hole words only",0,CTwholD
	DEFW	WordOnly
	DEFB	"~P~romt on replace",0,CTpromtD
	DEFW	PromtRepl
	DEFB	0

	DEFB	ClCheckBut
	DEFW	#061D,#0213
	DEFB	"Scope",0
	DEFB	"~G~lobal",0,CTglobD
	DEFW	FGlobal
	DEFB	"~S~elected text",0,CTselcD
	DEFW	FSelText
	DEFB	0

	DEFB	ClCheckBut
	DEFW	#0D04,#0212
	DEFB	"Direction",0
	DEFB	"~F~orward",0,CTforwD
	DEFW	FForward
	DEFB	"~B~ackward",0,CTbackD
	DEFW	FBackward
	DEFB	0

	DEFB	ClCheckBut
	DEFW	#0D1D,#0213
	DEFB	"Origin",0
	DEFB	"From c~u~rsor",0,CTfrCrD
	DEFW	FFromCur
	DEFB	"~E~ntire scope",0,CTentrD
	DEFW	FEntScope
	DEFB	0

	DEFB	ClRadioBut	; Object claster radio buttons
	DEFW	#1312		; Y,x position claster
	DEFW	#0112		; Len y,x claster
	DEFB	"Search mode",0	;Name claster
	DEFB	"~L~abels only",0  ;Name elements
	DEFB	CTlabelD	;Context help
	DEFW	LabelOnly	; Memory ceil
	DEFB	0		;End claster

	DEFB	Button
	DEFW	#1805
	DEFB	"  Help  ",0,cmCancel,CThelpD

	DEFB	Button
	DEFW	#1811
	DEFB	" Cancel ",0,cmCancel,CTcancD

	DEFB	Button
	DEFW	#181D
	DEFB	" Rep~A~ll ",0,cmYes,CTreplBD

	DEFB	Button
	DEFW	#1829
	DEFB	" ~R~eplac ",0,cmOkey,CTreplBD

	DEFB	InputLine
	DEFW	#0204
	DEFB	"~T~ext to find:",0,#21,CTfindD
	DEFW	FindBuf

	DEFB	#FF
;[]===========================================================[]
Dgotoln	DEFW	#0C16
	DEFW	#0724
	DEFB	"Go to line number",0

	DEFB	Button
	DEFW	#0404
	DEFB	"  Help  ",0,cmCancel,CThelpD

	DEFB	Button
	DEFW	#040E
	DEFB	" Cancel ",0,cmCancel,CTcancD

	DEFB	Button
	DEFW	#0418
	DEFB	"  ~G~oTo  ",0,cmOkey,CTreplBD

	DEFB	InputLine
	DEFW	#0205
	DEFB	"~I~nput line number:  ",0,#06,CTfindD
	DEFW	LineBuf

	DEFB	#FF
;[]===========================================================[]
DeditorO
	DEFW	#030E,#1A34
	DEFB	"Editor options",0

	DEFB	ClRadioBut
	DEFW	#0204,#0417
	DEFB	"Editor",0
	DEFB	"~I~nsert mode",0,CTinsMD
	DEFW	InsertMode
	DEFB	"Over~w~rite blocks",0,CTovrwrtD
	DEFW	OvrwrtBlck
	DEFB	"~S~yntax highlight",0,CTsyntD
	DEFW	SynHghLght
	DEFB	"T~r~uncate line",0,CTeditD
	DEFW	EditMode
	DEFB	0

	DEFB	ClCheckBut
	DEFW	#021F,#020F
	DEFB	"Keyboard",0
	DEFB	"~A~ qwerty",0,CTkeypadD
	DEFW	KeyPad1
	DEFB	"~B~ dvorak",0,CTkeypadD
	DEFW	KeyPad
	DEFB	0

	DEFB	ClRadioBut
	DEFW	#0A0D,#0118
	DEFB	"Mouse",0
	DEFB	"Auto ~h~idden mouse",0,CTkeypadD
	DEFW	HiddMouse
	DEFB	0

	DEFB	ClRadioBut
	DEFW	#0F0D,#0118
	DEFB	"Export",0
	DEFB	"O~p~timal tabulation",0,CTopttabD
	DEFW	OptimalTAB
	DEFB	0

	DEFB	InputLine
	DEFW	#1409
	DEFB	"~L~abel tab size:",0,#03,CTlabTD
	DEFW	LabBuff

	DEFB	InputLine
	DEFW	#141F
	DEFB	"~T~ab size:",0,#03,CTtabD
	DEFW	TabBuff

	DEFB	Button
	DEFW	#170A
	DEFB	"  Help  ",0,cmCancel,CThelpD

	DEFB	Button
	DEFW	#1716
	DEFB	" Cancel ",0,cmCancel,CTcancD

	DEFB	Button
	DEFW	#1722
	DEFB	"   ~O~k   ",0,cmOkey,CTokD
	DEFB	#FF
;[]===========================================================[]
Dcolors	DEFW	#0506
	DEFW	#1644
	DEFB	"Colors",0

	DEFB	ListBox		; About'object
	DEFW	#0203,#0E0E	; Yo,xo,leny,lenx
	DEFB	"~G~roup",0,CTbox1D ; Name list box,context
	DEFW	GroupList	; List

	DEFB	PResident1

	DEFB	ListBox		; About'object
	DEFW	#0216,#0B0F	; Yo,xo,leny,lenx
	DEFB	"~I~tem",0,CTbox2D ; Name list box,context
	DEFW	ItemList1	; List

	DEFB	PResident2
	DEFW	ColList1

	DEFB	PalleteBox	; About'object
	DEFW	#022B,#0404	; Yo,xo,leny,lenx
	DEFB	"~F~oreground",0,CTpal1D
	DEFB	#0F
	DEFW	ColList1

	DEFB	PalleteBox	; About'object
	DEFW	#0C2B,#0204	; Yo,xo,leny,lenx
	DEFB	"~B~ackround",0,CTpal2D
	DEFB	#F0
	DEFW	ColList1

	DEFB	TestColor
	DEFW	#0F17,ColList1
	DEFB	"Text Text Text Text",0

	DEFB	Button
	DEFW	#1311
	DEFB	"  Help  ",0,cmCancel,CThelpD

	DEFB	Button
	DEFW	#131D
	DEFB	" Cancel ",0,cmCancel,CTcancD

	DEFB	Button
	DEFW	#1329
	DEFB	"   ~O~k   ",0,cmOkey,CTokD
	DEFB	#FF

GroupList
	DEFB	"Desktop",#0D
	DEFB	"Browser",#0D
	DEFB	"Dialog window",#0D
	DEFB	"Text window",#0D
	DEFB	"Syntaxis",#0D
	DEFB	"Miscellaneous",#0D
	DEFB	0

ItemTab	DEFW	ItemList1,ColList1
	DEFW	ItemList2,ColList2
	DEFW	ItemList3,ColList3
	DEFW	ItemList4,ColList4
	DEFW	ItemList5,ColList5
	DEFW	ItemList6,ColList6

ItemList1
	DEFB	"Work desk",#0D
	DEFB	0
ItemList2
	DEFB	"Menu",#0D
	DEFB	"Highlight",#0D
	DEFB	"Hot keys",#0D
	DEFB	"Hidden command",#0D
	DEFB	0
ItemList3
	DEFB	"Window",#0D
	DEFB	"Frame (select)",#0D
	DEFB	"Frame (mv/rs)",#0D
	DEFB	"Highlight",#0D
	DEFB	"Hot keys",#0D
	DEFB	"Input line",#0D
	DEFB	"File input line",#0D
	DEFB	"File box",#0D
	DEFB	"FB highlight",#0D
	DEFB	"FB highlight hd",#0D
	DEFB	"List box",#0D
	DEFB	"LB highlight",#0D
	DEFB	"LB highlight hd",#0D
	DEFB	"File info",#0D
	DEFB	"Buttons",#0D
	DEFB	0
ItemList4
	DEFB	"Window",#0D
	DEFB	"Frame (select)",#0D
	DEFB	"Frame (mv/rs)",#0D
	DEFB	"Frame (unsel)",#0D
	DEFB	0
ItemList5
	DEFB	"Z80 mnemoic",#0D
	DEFB	"Labels",#0D
	DEFB	"Comments",#0D
	DEFB	0
ItemList6
	DEFB	"Window atr",#0D
	DEFB	"Scroll bar",#0D
	DEFB	"Process line",#0D
	DEFB	"Selected text",#0D
	DEFB	"Replace text",#0D
	DEFB	0
ColorList
ColList1
	DEFS	2,0
ColList2
	DEFS	8,0
ColList3
	DEFS	30,0
ColList4
	DEFS	8,0
ColList5
	DEFS	6,0
ColList6
	DEFS	10,0
; []===========================================================[]; !TODO window (position text)
DWnList	DEFW	#0515
	DEFW	#1525
	DEFB	"Window list",0

	DEFB	Button
	DEFW	#0819
	DEFB	" ~D~elete ",0,cmDelWind,CTcancD

	DEFB	Button
	DEFW	#0C19
	DEFB	" Cancel ",0,cmCancel,CTcancD

	DEFB	Button
	DEFW	#1019
	DEFB	"  Help  ",0,cmCancel,CThelpD

	DEFB	ListBox		; About'object
	DEFW	#0203,#0F0F	; Yo,xo,leny,lenx
	DEFB	"~W~indows",0,CTwinlistD ; Name list box,context
	DEFW	FuncBuffer	; List

	DEFB	Button
	DEFW	#0419
	DEFB	"   ~O~k   ",0,cmOkey,CTokD

	DEFB	#FF
;[]===========================================================[]
DaboutV:; Defw #0819
	BYTE	25			; Window by X by
	BYTE	07			; Window by Y by

; Defw #0f1e
	BYTE	30,16			; Window, window
	DEFB	"About version",0

	DEFB	TextLine
	BYTE	4,2			; Window: number, number
	DEFB	'TURBO ASSEMBLER v ',_progVERSION,0
	DEFB	TextLine
	BYTE	13,3
	DEFB	"by:",0
	DEFB	TextLine
	BYTE	10,4
	DEFB	"Enin Anton",0
	DEFB	TextLine
	BYTE	7,6
	DEFB	"Latest issue by:",0	; Latest issue by: anatoliy belyanskiy
	DEFB	TextLine
	BYTE	5,7
	DEFB	"Anatoliy Belyanskiy,",0
	DEFB	TextLine
	BYTE	10,8
	DEFB	_luaBUILD_DATEfull,0
	DEFB	TextLine
	BYTE	5,10
	DEFB	"All rights reserved,",0
	DEFB	TextLine
	BYTE	8,11
	DEFB	"Sprinter Team.",0
	DEFB	Button
	BYTE	11,13
	DEFB	"   ~O~k   ",0,cmOkey,CTokD
	DEFB	#FF
;[]===========================================================[]
DpromtR	DEFW	#0C15
	DEFW	#0725
	DEFB	"Information",0

	DEFB	Button
	DEFW	#040E
	DEFB	"   ~N~o   ",0,cmNo,CTokD

	DEFB	Button
	DEFW	#0419
	DEFB	" Cancel ",0,cmCancel,CTokD

	DEFB	TextLine
	DEFW	#0207
	DEFB	"Replace this occurrence?",0

	DEFB	Button
	DEFW	#0404
	DEFB	"  ~Y~es  ",0,cmYes,CTokD

	DEFB	#FF
;[]===========================================================[]
DclearB	DEFW	#0C15
	DEFW	#0725
	DEFB	"Information",0

	DEFB	Button
	DEFW	#040E
	DEFB	"   ~N~o   ",0,cmNo,CTokD

	DEFB	Button
	DEFW	#0419
	DEFB	" Cancel ",0,cmCancel,CTokD

	DEFB	TextLine
	DEFW	#0207
	DEFB	"Delete this occurrence?",0

	DEFB	Button
	DEFW	#0404
	DEFB	"  ~Y~es  ",0,cmYes,CTokD

	DEFB	#FF
;[]===========================================================[]
DimprtP	DEFW	#0B15
	DEFW	#0825
	DEFB	"Information",0

	DEFB	Button
	DEFW	#050E
	DEFB	"   ~N~o   ",0,cmNo,CTokD

	DEFB	Button
	DEFW	#0519
	DEFB	" Cancel ",0,cmCancel,CTokD

	DEFB	TextLine
	DEFW	#0207
	DEFB	"File is not TAS format.",0

	DEFB	TextLine
	DEFW	#030F
	DEFB	"Import?",0

	DEFB	Button
	DEFW	#0504
	DEFB	"  ~Y~es  ",0,cmYes,CTokD

	DEFB	#FF
;[]===========================================================[]
DsureWn	DEFW	#0B15
	DEFW	#0829
	DEFB	"Information",0
	DEFB	TextLine
	DEFW	#0203
SurName	DEFS	36,0
	DEFB	TextLine
	DEFW	#0312
	DEFB	"Save?",0
	DEFB	Button
	DEFW	#0510
	DEFB	"   ~N~o   ",0,cmNo,CTokD
	DEFB	Button
	DEFW	#051B
	DEFB	" Cancel ",0,cmCancel,CTcancD
	DEFB	Button
	DEFW	#0505
	DEFB	"  ~Y~es   ",0,cmYes,CTokD
	DEFB	#FF
TmpSurN	DEFB	"File  has been modify"
;[]===========================================================[]
Dexists	DEFW	#0B15
	DEFW	#0828
	DEFB	"Information",0

	DEFB	TextLine
	DEFW	#0207
FLName	DEFS	28," "
	DEFB	0

	DEFB	TextLine
	DEFW	#0310
	DEFB	"Overwrite?",0
	DEFB	Button
	DEFW	#0510
	DEFB	"   ~N~o   ",0,cmNo,CTokD
	DEFB	Button
	DEFW	#051B
	DEFB	" Cancel ",0,cmCancel,CTcancD
	DEFB	Button
	DEFW	#0505
	DEFB	"  ~Y~es   ",0,cmYes,CTokD
	DEFB	#FF
TmpFLN	DEFB	"File  exists."
;[]===========================================================[]
Dunform	DEFW	#0C0E
	DEFW	#0734
	DEFB	"Error",0

	DEFB	TextLine
	DEFW	#0205
	DEFB	"File is not TAS format."
	DEFB	"Use function IMPORT.",0

	DEFB	Button
	DEFW	#0416
	DEFB	"   ~O~k   ",0,cmOkey,CTokD

	DEFB	#FF
;[]===========================================================[]
Dnotfnd	DEFW	#0C16
	DEFW	#0724
	DEFB	"Error",0

	DEFB	TextLine
	DEFW	#0206
	DEFB	"Search string not found.",0

	DEFB	Button
	DEFW	#040E
	DEFB	"   ~O~k   ",0,cmOkey,CTokD

	DEFB	#FF
;[]===========================================================[]
Dnotxtsp
	DEFW	#0C16
	DEFW	#0724
	DEFB	"Error",0

	DEFB	TextLine
	DEFW	#0206
	DEFB	"No space in this window.",0

	DEFB	Button
	DEFW	#040E
	DEFB	"   ~O~k   ",0,cmOkey,CTokD

	DEFB	#FF
;[]===========================================================[]
Dnobfspc
	DEFW	#0C16
	DEFW	#0724
	DEFB	"Error",0

	DEFB	TextLine
	DEFW	#0208
	DEFB	"No space in buffer.",0

	DEFB	Button
	DEFW	#040E
	DEFB	"   ~O~k   ",0,cmOkey,CTokD

	DEFB	#FF
;[]===========================================================[]
Dnospace
	DEFW	#0C16
	DEFW	#0724
	DEFB	"Error",0

	DEFB	TextLine
	DEFW	#0208
	DEFB	"Warning!!! No memory!!!",0

	DEFB	Button
	DEFW	#040E
	DEFB	"   ~O~k   ",0,cmOkey,CTokD

	DEFB	#FF
;[]===========================================================[]
; Table names (name max=128b)
;End table: code - #80
NameTab	DEFS	1920,0	; Table name (128byte name) ; !hardcode
	DEFB	#80
;
 _mCollectInfo_addEnd