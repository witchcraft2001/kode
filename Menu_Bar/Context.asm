 _mCollectInfo_addStart
; Context help in status line
NoConTxt        EQU #00
CTnew           EQU #01
CTopen          EQU #02
CTsave          EQU #03
CTsaveAs        EQU #04
CTsaveAll       EQU #05
CTprint         EQU #06
CTprintSet	EQU #07
CTexit          EQU #08
CTcut           EQU #09
CTcutapp        EQU #0A
CTcopy          EQU #0B
CTappnd         EQU #0C
CTpaste         EQU #0D
CTclear         EQU #0E
CTshowClip	EQU #0F
CTfind          EQU #10
CTreplace       EQU #11
CTsearchAg	EQU #12
CTgotoLine	EQU #13
CTrun           EQU #14
CTparam         EQU #15
CTcompile       EQU #16
CTmake          EQU #17
CTprimFile	EQU #18
CTclPrFile	EQU #19
CTinfo          EQU #1A
CTsymbList	EQU #1B
CTquitDeb       EQU #1C
CTeditor        EQU #1D
CTcolor         EQU #1E
CTsavsetup	EQU #1F
CTtile          EQU #20
CTcascade       EQU #21
CTcloseAll	EQU #22
CTrefrDisp	EQU #23
CTlist          EQU #24
CTeditorH       EQU #25
CTcompileH	EQU #26
CTwindowH       EQU #27
CTversionH	EQU #28
CTfindD         EQU #29
CTreplD         EQU #2A
CTcaseD         EQU #2B
CTwholD         EQU #2C
CTregulD        EQU #2D
CTpromtD        EQU #2E
CTforwD         EQU #2F
CTbackD         EQU #30
CTglobD         EQU #31
CTselcD         EQU #32
CTfrCrD         EQU #33
CTentrD         EQU #34
CThelpD         EQU #35
CTcancD         EQU #36
CTokD           EQU #37
CTmovresiz	EQU #38
CTfindBD        EQU #39
CTreplBD        EQU #3A
CTopenFl        EQU #3B
CTwinlistD	EQU #3C
CTfileinpD	EQU #3D
CTfileboxD	EQU #3E
CTopenD         EQU #3F
CTreplfD        EQU #40
CTstopD         EQU #41
CTimportD       EQU #42
CTinsMD         EQU #43
CTovrwrtD       EQU #44
CTsyntD         EQU #45
CTeditD         EQU #46
CTlabTD         EQU #47
CTtabD          EQU #48
CTlabelD        EQU #49
CTkeypadD       EQU #4A
CTbox1D         EQU #4B
CTbox2D         EQU #4C
CTpal1D         EQU #4D
CTpal2D         EQU #4E
CTopttabD       EQU #4F

; Addresses
StLlist:
        DEFW slMain
        DEFW sl01
        DEFW sl02
        DEFW sl03
        DEFW sl04
        DEFW sl05
        DEFW sl06
        DEFW sl07
        DEFW sl08
        DEFW sl09
        DEFW sl0A
        DEFW sl0B
        DEFW sl0C
        DEFW sl0D
        DEFW sl0E
        DEFW sl0F
        DEFW sl10
        DEFW sl11
        DEFW sl12
        DEFW sl13
        DEFW sl14
        DEFW sl15
        DEFW sl16
        DEFW sl17
        DEFW sl18
        DEFW sl19
        DEFW sl1A
        DEFW sl1B
        DEFW sl1C
        DEFW sl1D
        DEFW sl1E
        DEFW sl1F
        DEFW sl20
        DEFW sl21
        DEFW sl22
        DEFW sl23
        DEFW sl24
        DEFW sl25
        DEFW sl26
        DEFW sl27
        DEFW sl28
        DEFW sl29
        DEFW sl2A
        DEFW sl2B
        DEFW sl2C
        DEFW sl2D
        DEFW sl2E
        DEFW sl2F
        DEFW sl30
        DEFW sl31
        DEFW sl32
        DEFW sl33
        DEFW sl34
        DEFW sl35
        DEFW sl36
        DEFW sl37
        DEFW sl38
        DEFW sl39
        DEFW sl3A
        DEFW sl3B
        DEFW sl3C
        DEFW sl3D
        DEFW sl3E
        DEFW sl3F
        DEFW sl40
        DEFW sl41
        DEFW sl42
        DEFW sl43
        DEFW sl44
        DEFW sl45
        DEFW sl46
        DEFW sl47
        DEFW sl48
        DEFW sl49
        DEFW sl4A
        DEFW sl4B
        DEFW sl4C
        DEFW sl4D
        DEFW sl4E
        DEFW sl4F

; Format
; Status line table:
; Name (end - 0)
; #ff - end table
; Command,"name",0,keyboard combination
; If "name"=0 then no name
; If command=txt then only text
Txt	EQU	#FE
; Char in ~ ~ - hot key

slMain:	DEFB cmHelpDesk,		"~F1~ Help",	0,#3B
	DEFB cmSave,		"~F2~ Save",	0,#3C
	DEFB cmOpen,		"~F3~ Open",	0,#3D
	DEFB cmNew,		"~F4~ New",	0,#3E
	DEFB cmLocMenuK,		"~Alt+F10~ LocMenu",0,113
	DEFB cmExit,				0,45
	DEFB cmClosTxtW,				0,106
	DEFB cmMovReSiz,				0,98
	DEFB cmNxtTxtWn,				0,#40
	DEFB cmPrvTxtWn,				0,89
	DEFB cmZoom,				0,#3F
	DEFB cmList,				0,129
	DEFB cmFind,				0,#41
	DEFB cmReplace,				0,#42
	DEFB cmSearchAg,				0,90
	DEFB cmGoToLine,				0,91
	DEFB cmCut,				0,151
	DEFB cmCutAppnd,				0,#03
	DEFB cmCopy,				0,150
	DEFB cmAppend,				0,#01
	DEFB cmPaste,				0,153
	DEFB cmClear,				0,154
	DEFB #FF

sl01:	DEFB cmHelpBox,		"~F1~ Help",	0,#3B
	DEFB Txt,#B3,		" Create an empty text file "
	DEFB 			"in a new window"
	DEFB #FF
sl02:	DEFB cmHelpBox,		"~F1~ Help",0,#3B
	DEFB Txt,#B3,		" Open file in a new text"
	DEFB 			" window"
	DEFB #FF
sl03:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Save current text"
	DEFB " file with current name"
	DEFB #FF
sl04:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Save current text"
	DEFB " file with another name"
	DEFB #FF
sl05:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Save all modified text"
	DEFB " files with current names"
	DEFB #FF
sl06:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Print current text"
	DEFB " file to printer"
	DEFB #FF
sl07:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Select current settings for"
	DEFB " printer"
	DEFB #FF
sl08:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Exit to DOS"
	DEFB #FF
sl09:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Cut and place selected block"
	DEFB " text into buffer"
	DEFB #FF
sl0A:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Cut and append selected block"
	DEFB " text into buffer"
	DEFB #FF
sl0B:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Copy selected block"
	DEFB " text into buffer"
	DEFB #FF
sl0C:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Append selected block"
	DEFB " text into buffer"
	DEFB #FF
sl0D:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Copy text block"
	DEFB " from buffer to cursor position"
	DEFB #FF
sl0E:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Delete selected block"
	DEFB " text"
	DEFB #FF
sl0F:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," View content"
	DEFB " Clipboard"
	DEFB #FF
sl10:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Set search options"
	DEFB " in text"
	DEFB #FF
sl11:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Set search options"
	DEFB " and replace in text"
	DEFB #FF
sl12:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Continue search with current"
	DEFB " options"
	DEFB #FF
sl13:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Set cursor to specified"
	DEFB " text line"
	DEFB #FF
sl14:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Run compiled"
	DEFB " program"
	DEFB #FF
sl15:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Set options for"
	DEFB " program launch"
	DEFB #FF
sl16:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Compile current"
	DEFB " text file"
	DEFB #FF
sl17:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Compile current"
	DEFB " text file to disk as .exe"
	DEFB #FF
sl18:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Select from text files"
	DEFB " primary file"
	DEFB #FF
sl19:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Clear primary file"
	DEFB " file"
	DEFB #FF
sl1A:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," View information about"
	DEFB " compilation"
	DEFB #FF
sl1B:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," View symbol table"
	DEFB #FF
sl1C:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Exit to debugger"
	DEFB #FF
sl1D:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Set options for"
	DEFB " text editing"
	DEFB #FF
sl1E:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Set color"
	DEFB " palette"
	DEFB #FF
sl1F:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Save current settings and "
	DEFB "color palette"
	DEFB #FF
sl20:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Tile windows evenly across"
	DEFB " screen"
	DEFB #FF
sl21:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Cascade windows across"
	DEFB " screen"
	DEFB #FF
sl22:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Close all windows"
	DEFB #FF
sl23:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Refresh screen"
	DEFB #FF
sl24:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Select window from list"
	DEFB #FF
sl25:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Get help for"
	DEFB " text editing"
	DEFB #FF
sl26:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Get help for"
	DEFB " compiler"
	DEFB #FF
sl27:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Get help for"
	DEFB " window operations"
	DEFB #FF
sl28:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Get help about"
	DEFB " Kode version"
	DEFB #FF
sl29:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Find matching character group in text",#FF
sl2A:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Replace found character group with ..",#FF
sl2B:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Case-sensitive search letters",#FF
sl2C:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Match whole words only",#FF
sl2D:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Search with logical expressions",#FF
sl2E:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Ask before replacing character group",#FF
sl2F:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Search direction toward end of text",#FF
sl30:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Search direction toward start of text",#FF
sl31:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Search in whole text",#FF
sl32:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Search in selected text block",#FF
sl33:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Search starting from current cursor position",#FF
sl34:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Search from text boundary",#FF
sl35:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Get help for current dialog window",#FF
sl36:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Cancel performed actions",#FF
sl37:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Confirm performed actions and execute current command",#FF
sl38:	DEFB Txt,"~",#18,#19,#1B,#1A,"~ Move  "
	DEFB "~Shift+",#18,#19,#1B,#1A,"~ ReSize  "
	DEFB "~Enter~ Done  ~Esc~ Cancel",#FF
sl39:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Start search",#FF
sl3A:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Start search and replace",#FF
sl3B:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Open file under cursor",#FF
sl3C:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," List of open text windows",#FF
sl3D:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," File name input line",#FF
sl3E:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Current directory file list",#FF
sl3F:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Open selected file in new window",#FF
sl40:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Open selected file in current window",#FF
sl41:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Stop current operation",#FF
sl42:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Open and convert text file in new window",#FF
sl43:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Character input mode: insert or overwrite",#FF
sl44:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Block input mode: insert or overwrite",#FF
sl45:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Syntax highlight while typing text",#FF
sl46:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Text editing mode",#FF
sl47:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Tab size for Kode labels",#FF
sl48:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Tab size for Kode commands",#FF
sl49:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Search similar symbol string only in label field",#FF
sl4A:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Russian keyboard layout",#FF
sl4B:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Color group list",#FF
sl4C:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Current group color list",#FF
sl4D:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Ink color for current object",#FF
sl4E:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Paper color for current object",#FF
sl4F:	DEFB cmHelpBox,"~F1~ Help",0,#3B
	DEFB Txt,#B3," Tab optimization during export to file",#FF
;
 _mCollectInfo_addEnd
