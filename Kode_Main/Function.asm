 _mCollectInfo_addStart
;[]===========================================================[]
; Function - Open a file
OpenFile
	SUB	A
	LD	(FMenuFlg),A
	LD	HL,DopenFl		; Open window
	CALL	DialogW		; Internal operation
	LD	HL,what			; Field events
	LD	A,(HL)
	LD	(HL),evNothing
	INC	HL
	CP	evCommand		; If exit not by command
	RET	NZ				; Exit
	LD	A,(HL)
	CP	cmCancel		; If window
	RET	Z				; Exit
	CP	cmOkey			; Command open new
	JR	Z,OpFileN
	CP	cmReplaceF
	JP	Z,ReplFile
	CP	cmImport
	JP	Z,ImportFile
	CP	cmOpenFile		; Command open new
	JP	NZ,CloseFl
OpFileN	LD	HL,what
	LD	(HL),evNothing
	LD	A,cmNew			; Check on validity
	CALL	TstCmnd		; Commands New
	JP	Z,CloseFl		; Z - not allowed

; Procedure open new text window by command -Open
	CALL	GetMemory	; Get free pages
	JP	C,NoSpace		; None memory
	PUSH	IY			; Save important register
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)		; Enable system DOS
	OUT	(SLOT0),A			; In 0 page
	LD	BC,#7FFD														; !fixit #7ffd
	LD	A,#10			; Enable ports vg93
	OUT	(C),A
	LD	HL,FuncBuffer	; For from
	LD	DE,#0040		; Count-in byte (header)
	LD	A,(FileHandle)	; File handle
	LD	C,#13			; DOS: Read
	RST	ToDSS
	EX	AF,AF'			; If CY - error (and-number)
	LD	BC,#7FFD														; !fixit #7ffd
	SUB	A				; Ports vg93
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A			; 0 page
	POP	IY				; Restore.register
	EX	AF,AF'			; Message from DOS
	JP	C,CloseFile		; Error
	OR	A				; And<>0 then loaded less 040h
	JP	NZ,ConvPromt	; Byte
	LD	HL,FuncBuffer	; For comparison
	LD	DE,FHeader		; Header TAS
	LD	B,#04
	LD	A,(DE)			; Internal operation
	CP	(HL)
	JP	NZ,ConvPromt
	INC	HL
	INC	DE
	DJNZ	$-7
OpenAgn:
	CALL	ResMBar		; Disable.MenuBar
	LD	IX,TxtWtab		; Table window descriptors
	BIT	7,(IX+#00)		; 7=1 - open 1 window
	JR	NZ,OpenNew
	CALL	OnlySyntax	; Syntax-highlight last line
	CALL	PutString	; Insert it in text
	CALL	ResCurs		; Disable cursor
OpenNew:
	LD	HL,KeyBuff+#21
	LD	A,(HL)
	INC	HL
	OUT	(SLOT2),A
	LD	A,(HL)
	OUT	(SLOT3),A
	LD	HL,FuncBuffer
	LD	DE,#8000
	LD	BC,#0040
	LDIR 
	LD	A,#01			; Header not
	CALL	InitWin		; Descriptor new window
	LD	HL,FileName		; Name
	CALL	InitNam		; Place name window in.names
	CALL	HiddWin		; Disable window
	CALL	PutTextWn	; Open new window
	LD	HL,WindGrp
	CALL	OpenGroup	; Groups
	LD	A,NoConTxt		; Internal operation
	CALL	PutStatusLn	; Status line
LoadNew	PUSH	IY		; Save
	PUSH	IX
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)		; Enable system DOS
	OUT	(SLOT0),A			; In 0 page
	LD	BC,#7FFD														; !fixit #7ffd
	LD	A,#10			; Enable. ports vg93
	OUT	(C),A
	LD	HL,#8040		; With current.addresses
	LD	DE,#7FC0		; Internal operation
	LD	A,(FileHandle)	; File handle
	LD	C,#13			; Function DOS: Read
	RST	#10
	LD	BC,#7FFD														; !fixit #7ffd
	SUB	A				; Disable. ports vg93
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A			; Restore 0 page
	POP	IX
	POP	IY				; Restore
	CALL	CloseFl
	LD	HL,#8040
	LD	A,(HL)
	LD	B,#00
	LD	E,B
	LD	D,E
ResMark	LD	C,A
	INC	HL
	RES	6,(HL)
	DEC	HL
	ADD	HL,BC
	LD	A,(HL)
	OR	A
	JR	NZ,ResMark
	RES	0,(IY-#04)
	CALL	PrintPage	; Procedure printing
	CALL	PrintInfo
	LD	HL,FreeWin
	SUB	A
	LD	B,#0F
	BIT	7,(HL)			; Count count-in open windows
	INC	HL
	JR	Z,$+3
	INC	A
	DJNZ	$-6
	CP	#0F
	RET	C				; Less 15 - Okey
	LD	A,cmNew			; Already 15
	CALL	CloseCmnd	; Command New
	RET 
; Procedure current on new file
ReplFile
	LD	HL,what
	LD	(HL),evNothing
	LD	IX,TxtWtab		; Table window descriptors
	BIT	7,(IX+#00)		; 7=1 - open 1 window
	JP	NZ,OpFileN
	PUSH	IY			; Save important register
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)		; Enable system DOS
	OUT	(SLOT0),A			; In 0 page
	LD	BC,#7FFD														; !fixit #7ffd
	LD	A,#10			; Enable ports vg93
	OUT	(C),A
	LD	HL,FuncBuffer	; For from
	LD	DE,#0040		; Count-in byte (header)
	LD	A,(FileHandle)	; File handle
	LD	C,#13			; DOS: Read
	RST	#10
	EX	AF,AF'			; If CY - error (and-number)
	LD	BC,#7FFD														; !fixit #7ffd
	SUB	A				; Ports vg93
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A			; 0 page
	POP	IY				; Restore.register
	EX	AF,AF'			; Message from DOS
	JP	C,CloseFile		; Error
	OR	A				; And<>0 then loaded less 040h
	JP	NZ,UnknownF		; Byte
	LD	HL,FuncBuffer	; For comparison
	LD	DE,FHeader		; Header TAS
	LD	B,#04
	LD	A,(DE)			; Internal operation
	CP	(HL)
	JP	NZ,UnknownF		; If none,then on exit
	INC	HL
	INC	DE
	DJNZ	$-7
	CALL	OnlySyntax	; Syntax-highlight last line
	CALL	PutString	; Insert it in text
	LD	A,(IY+#17)		;Ready file
	OR	A
	JR	NZ,ReplNxt
	CALL	SureWin
	LD	HL,what
	LD	A,(HL)
	INC	HL
	CP	evCommand
	JP	NZ,CloseFile
	LD	A,(HL)
	CP	cmCancel
	JP	Z,CloseFile
ReplNxt:
	CALL	ResCurs		; Disable cursor
	LD	IX,TxtWtab
	LD	HL,FuncBuffer
	LD	DE,#8000
	LD	BC,#0040
	LDIR 
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
	ADD	HL,DE			; Search name window
	DJNZ	$-1
	LD	(HL),B
	POP	AF
	OUT	(SLOT2),A
	LD	HL,FileName		; Name
	CALL	InitNam		; Place name window in.names
	CALL	Rectang	    ; Internal operation
	LD	HL,FrameSl 		; Pointer on frame selected window
	CALL	PutFram	    ; Draw frame
	CALL	PrnTxtW	    ; Print window on screen
	CALL	InsWatr
	JP	LoadNew
; Procedure import current in TAS file
ConvPromt
	JP	ImportTXT
	LD	HL,DimprtP
	CALL	DialogW
	LD	HL,what			
	LD	A,(HL)
	LD	(HL),evNothing
	INC	HL
	CP	evCommand		; Exit
	RET	NZ				
	LD	A,(HL)
	CP	cmYes			; Exit
	RET	NZ				
	JP	ImportTXT
ImportFile
	LD	HL,what
	LD	(HL),evNothing
	LD	A,cmNew			; Commands New
	CALL	TstCmnd		; Z - not allowed
	JP	Z,CloseFl		

; Get free pages
	CALL	GetMemory	; None memory
	JP	C,NoSpace		; Save important register
	PUSH	IY			
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)		; In 0 page
	OUT	(SLOT0),A			; !fixit #7ffd
	LD	BC,#7FFD														; Enable ports vg93
	LD	A,#10			
	OUT	(C),A
	LD	HL,FuncBuffer	; Count-in byte (header)
	LD	DE,#0040		; File handle
	LD	A,(FileHandle)	; DOS: Read
	LD	C,#13			
	RST	#10
	EX	AF,AF'			; !fixit #7ffd
	LD	BC,#7FFD														; Ports vg93
	SUB	A				
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A			; Restore.register
	POP	IY				; Message from DOS
	EX	AF,AF'			; Error
	JP	C,CloseFile		; And<>0 then loaded less 040h
	OR	A				; Byte
	JP	NZ,ImportTXT	; For comparison
	LD	HL,FuncBuffer	; Header TAS
	LD	DE,FHeader		
	LD	B,#04
	LD	A,(DE)			
	CP	(HL)
	JP	NZ,ImportTXT	
	INC	HL
	INC	DE
	DJNZ	$-7
	JP	OpenAgn


CloseFile
	LD	A,(KeyBuff+#20)	; Free pages
	LD	C,#C3			
	RST	#10
CloseFl	PUSH	IY		
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)		; In 0 page
	OUT	(SLOT0),A			; !fixit #7ffd
	LD	BC,#7FFD														; Enable. ports vg93
	LD	A,#10			
	OUT	(C),A
	LD	A,(FileHandle)	; Function DOS: Close File
	LD	C,#12			
	RST	#10
	LD	BC,#7FFD														; Disable. ports vg93
	SUB	A				
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A			; Restore.register
	POP	IY				
	RET 

UnknownF
	LD	HL,Dunform
	CALL	DialogW
	JR	CloseFile
; Function - Save

SaveFile
	SUB	A
	LD	(FMenuFlg),A	; Normal save mode
	LD	IX,TxtWtab		
	IN	A,(SLOT2)
	LD	C,A
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	LD	HL,NameTab-#80	
	LD	DE,#0080
	LD	A,(IX+#00)		
	AND	#0F
	INC	A
	LD	B,A
	ADD	HL,DE			
	DJNZ	$-1
	LD	DE,FileName
	LD	A,(HL)			
SaveFl1	INC	HL
	LD	(DE),A
	INC	DE
	LD	A,(HL)
	BIT	7,A				; If,then Save as
	JR	NZ,SaveF11		
	OR	A
	JR	NZ,SaveFl1
	LD	(DE),A
SaveF11	XOR	A
	LD	(DE),A			; force zero-terminated FileName
	LD	A,C
	OUT	(SLOT2),A
	LD	HL,FileName
	LD	DE,Noname		
	LD	B,#0B
SaveFl2	LD	A,(DE)
	INC	DE
	CP	(HL)
	INC	HL
	JR	NZ,SaveFl3
	DJNZ	SaveFl2
	JP	SaveFileAs		; 1 text page
SaveFl3	LD	A,(IX+#1D)	; 1 text page
	OUT	(SLOT2),A
	LD	A,(IX+#1E)		; 2 text page
	OUT	(SLOT3),A
	PUSH	IY
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)		; In 0 page
	OUT	(SLOT0),A			; !fixit #7ffd
	LD	BC,#7FFD														; Enable. ports vg93
	LD	A,#10			
	OUT	(C),A
	LD	HL,FileName		; Internal operation
	LD	DE,ReCompBuff	; Internal operation
	LD	A,#21			; Function DOS: F_First
	LD	C,#19			
	RST	#10
	EX	AF,AF'
	LD	BC,#7FFD														; Disable. ports vg93
	SUB	A				
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A			; Restore.register
	POP	IY				
	EX	AF,AF'
	JP	C,SaveFileAs	
SaveTAS:
	CALL	MakeBackupIfExists
	JP	ExportTXT
	LD	(IY+#17),#01	; Was not touched
	CALL	OnlySyntax
	LD	A,(ReadyStr)	
	OR	A
	CALL	Z,PutString
	CALL	ResCurs
	LD	HL,#8000
	LD	DE,FuncBuffer
	LD	BC,#0040
	LDIR 
	SUB	A
	LD	(IY-#02),A
	LD	(IY-#01),A
	LD	(IY+#00),A		;Xcursor
	LD	(IY+#01),A		;Ycursor
	LD	(IY+#02),A		;Inp.symb
	LD	(IY+#07),A		; Add x
	LD	(IY+#24),A		; Proecflg
	LD	HL,#8040
	LD	(AdrPage),HL
	LD	(BegString),HL
	LD	HL,#0000
	LD	(CurLine),HL
	LD	(UpLinePg),HL
	PUSH	IY
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)		; !fixit #7ffd
	OUT	(SLOT0),A			; Enable. ports vg93
	LD	BC,#7FFD														; !fixit #7ffd
	LD	A,#10			; Internal operation
	OUT	(C),A
	LD	HL,FileName		; Function DOS: Create File
	SUB	A				
	LD	C,#0A			; File handle
	RST	#10
	LD	(FileHandle),A	; Memory
	JR	C,SaveFle
	LD	HL,#8000		; Count-in byte+1
	LD	DE,(EndText)
	INC	DE				; File handle
	RES	7,D
	LD	A,(FileHandle)	
	LD	C,#14			
	RST	#10
	JR	C,SaveFle
	LD	A,(FileHandle)	
	LD	C,#12			
	RST	#10
SaveFle	EX	AF,AF'
	LD	BC,#7FFD														; !fixit #7ffd
	SUB	A				
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A			
	POP	IY				
	EX	AF,AF'
	LD	HL,FuncBuffer
	LD	DE,#8000
	LD	BC,#0040
	LDIR 
	CALL	SetCurs
	CALL	PrintInfo+4	
	LD	HL,what
	LD	(HL),evNothing
	RET 

;------------------------------------------------------------
; Create backup by rename before save.
; 1) Delete old backup if exists.
; 2) Rename source file -> backup name.
; Errors are ignored, main save must continue.
MakeBackupIfExists:
	PUSH	IY
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)
	OUT	(SLOT0),A
	LD	BC,#7FFD
	LD	A,#10
	OUT	(C),A

	CALL	BuildSourceName
	CALL	BuildBackupName
	JR	C,BkpDone

	XOR	A
	LD	HL,BackupName
	LD	C,#0E			; DOS: Delete
	RST	#10			; ignore errors (not exists)

	XOR	A
	LD	HL,BkpSrcName
	LD	DE,BackupName
	LD	C,#10			; DOS: Rename (old->new)
	RST	#10
	JR	NC,BkpDone

	CALL	BkpCopyFallback

BkpDone:
	LD	BC,#7FFD
	XOR	A
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A
	POP	IY
	RET

; Fallback if rename is unsupported/failed: copy source -> backup.
; Expects DOS page and VG93 ports already enabled.
BkpCopyFallback:
	LD	A,#FF
	LD	(BkpSrcH),A
	LD	(BkpDstH),A
	LD	HL,BkpSrcName
	LD	A,#01
	LD	C,#11			; DOS: Open existing (read)
	RST	#10
	JR	C,BkpCF_Fail
	LD	(BkpSrcH),A

	LD	HL,BackupName
	XOR	A
	LD	C,#0A			; DOS: Create backup
	RST	#10
	JR	C,BkpCF_FailCloseSrc
	LD	(BkpDstH),A

BkpCF_Loop:
	LD	HL,FuncBuffer
	LD	DE,#0100
	LD	A,(BkpSrcH)
	LD	C,#13			; DOS: Read
	RST	#10
	JR	C,BkpCF_FailCloseAll
	LD	(BkpRFlg),A
	LD	A,D
	OR	E
	JR	Z,BkpCF_SuccessCloseAll
	PUSH	DE
	LD	HL,FuncBuffer
	POP	DE
	LD	A,(BkpDstH)
	LD	C,#14			; DOS: Write
	RST	#10
	JR	C,BkpCF_FailCloseAll
	LD	A,(BkpRFlg)
	OR	A
	JR	Z,BkpCF_Loop
	JR	BkpCF_SuccessCloseAll

BkpCF_FailCloseAll:
	CALL	BkpCF_DoCloseAll
	SCF
	RET

BkpCF_SuccessCloseAll:
	CALL	BkpCF_DoCloseAll
	OR	A
	RET

BkpCF_FailCloseSrc:
	CALL	BkpCF_DoCloseSrc
	SCF
	RET

BkpCF_Fail:
	SCF
	RET

BkpCF_DoCloseAll:
	LD	A,(BkpDstH)
	CP	#FF
	JR	Z,BkpCF_DoCloseSrc
	LD	C,#12			; DOS: Close
	RST	#10
BkpCF_DoCloseSrc:
	LD	A,(BkpSrcH)
	CP	#FF
	RET	Z
	LD	C,#12			; DOS: Close
	RST	#10
	RET
; Build BackupName from FileName.
; Backup naming rule:
; ext len 1    -> append '__' (test.c -> test.c__)
; ext len 2    -> append '_'  (test.cc -> test.cc_)
; ext len >=3  -> replace last ext char (test.asm -> test.as_)
; If no extension, replace last character of basename.
; Carry set on failure.
BuildBackupName:
	LD	HL,BkpSrcName
	LD	DE,BackupName
	LD	B,#7F
BkpNmCp:
	LD	A,(HL)
	RES	7,A
	LD	(DE),A
	INC	HL
	INC	DE
	OR	A
	JR	Z,BkpNmEnd
	DJNZ	BkpNmCp
	XOR	A
	LD	(DE),A
BkpNmEnd:
	LD	HL,BackupName
	LD	(BkpBasePtr),HL
	LD	HL,#0000
	LD	(BkpDotPtr),HL
	LD	HL,#0000
	LD	(BkpLastPtr),HL
	LD	HL,BackupName
BkpNmScan:
	LD	A,(HL)
	OR	A
	JR	Z,BkpNmDecide
	LD	(BkpLastPtr),HL
	CP	#5C
	JR	Z,BkpNmSep
	CP	'/'
	JR	Z,BkpNmSep
	CP	':'
	JR	Z,BkpNmSep
	CP	'.'
	JR	NZ,BkpNmNext
	LD	(BkpDotPtr),HL
	JR	BkpNmNext
BkpNmSep:
	INC	HL
	LD	(BkpBasePtr),HL
	LD	DE,#0000
	LD	(BkpDotPtr),DE
	DEC	HL
BkpNmNext:
	INC	HL
	JR	BkpNmScan

BkpNmDecide:
	LD	HL,(BkpDotPtr)
	LD	A,H
	OR	L
	JR	Z,BkpNmNoExt
	INC	HL
	LD	A,(HL)
	OR	A
	JR	Z,BkpNmNoExt
	LD	C,#00
BkpExtSeek:
	LD	A,(HL)
	OR	A
	JR	Z,BkpExtClass
	INC	C
	INC	HL
	JR	BkpExtSeek

BkpExtClass:
	LD	A,C
	CP	#01
	JR	Z,BkpExtAppend2
	CP	#02
	JR	Z,BkpExtAppend1
	CP	#03
	JR	NC,BkpExtReplaceLast
	JR	BkpNmNoExt

BkpExtAppend2:
	LD	A,'_'
	LD	(HL),A
	INC	HL
	LD	A,'_'
	LD	(HL),A
	INC	HL
	XOR	A
	LD	(HL),A
	OR	A
	RET

BkpExtAppend1:
	LD	A,'_'
	LD	(HL),A
	INC	HL
	XOR	A
	LD	(HL),A
	OR	A
	RET

BkpExtReplaceLast:
	DEC	HL
	LD	A,'_'
	LD	(HL),A
	OR	A
	RET

BkpNmNoExt:
	LD	HL,(BkpLastPtr)
	LD	A,H
	OR	L
	JR	Z,BkpNmFail
	LD	DE,(BkpBasePtr)
	OR	A
	SBC	HL,DE
	JR	C,BkpNmFail
	LD	HL,(BkpLastPtr)
	LD	A,'_'
	LD	(HL),A
	OR	A
	RET

BkpNmFail:
	SCF
	RET

; Build normalized source path in BkpSrcName.
; Strips trailing :0/:1 window suffix if present.
BuildSourceName:
	LD	HL,FileName
	LD	DE,BkpSrcName
	LD	B,#7F
BSrcCp:
	LD	A,(HL)
	BIT	7,A
	JR	Z,BSrcNoHi
	RES	7,A
	LD	(DE),A
	INC	DE
	XOR	A
	LD	(DE),A
	JR	BSrcEnd

BSrcNoHi:
	CP	#21
	JR	C,BSrcTerm
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	BSrcCp

BSrcTerm:
	XOR	A
	LD	(DE),A
	JR	BSrcEnd
BSrcEnd:
	LD	HL,BkpSrcName
	LD	DE,#0000
BSrcSeek:
	LD	A,(HL)
	OR	A
	JR	Z,BSrcChk
	LD	D,H
	LD	E,L
	INC	HL
	JR	BSrcSeek
BSrcChk:
	LD	A,D
	OR	E
	RET	Z
	LD	A,(DE)
	CP	'0'
	JR	Z,BSrcPrev
	CP	'1'
	RET	NZ
BSrcPrev:
	DEC	DE
	LD	A,(DE)
	CP	':'
	RET	NZ
	XOR	A
	LD	(DE),A
	RET
;[]===========================================================[]

SaveFileAs
	LD	A,#01
	LD	(FMenuFlg),A
	LD	HL,DsaveFl
	CALL	DialogW
	SUB	A
	LD	(FMenuFlg),A	; Leave save-as mode after dialog
	LD	HL,what			
	LD	A,(HL)
	INC	HL
	CP	evCommand		
	RET	NZ				; If window
	LD	A,(HL)
	CP	cmCancel		; Command write current
	RET	Z				
	CP	cmOkey			
	JR	Z,SaveFlN
	CP	cmSaveFile		; Command write current
	RET	NZ
SaveFlN	LD	IX,TxtWtab	; Table window descriptors
	LD	A,(IX+#1D)		; 1 text page
	OUT	(SLOT2),A
	LD	A,(IX+#1E)		; 2 text page
	OUT	(SLOT3),A
	PUSH	IY
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)		; Enable system DOS
	OUT	(SLOT0),A			; In 0 page
	LD	BC,#7FFD														; !fixit #7ffd
	LD	A,#10			; Enable. ports vg93
	OUT	(C),A
	LD	HL,FileName		; Internal operation
	LD	DE,ReCompBuff	; Internal operation
	LD	A,#21			; Internal operation
	LD	C,#19			; Function DOS: F_First
	RST	#10
	EX	AF,AF'
	LD	BC,#7FFD														; !fixit #7ffd
	SUB	A				; Disable. ports vg93
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A			; Restore 0 page
	POP	IY				; Restore.register
	EX	AF,AF'
	JP	SaveTAS

SetNewName
	LD	IX,TxtWtab		; Current window descriptor
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	LD	A,(IX+#00)		; Window number
	AND	#0F
	INC	A
	LD	B,A
	LD	HL,NameTab-#80
	LD	DE,#0080
	ADD	HL,DE			; Current window name slot
	DJNZ	$-1
	LD	DE,FileName
SNcopy	LD	A,(DE)
	LD	(HL),A
	INC	DE
	INC	HL
	OR	A
	JR	NZ,SNcopy
	POP	AF
	OUT	(SLOT2),A
	CALL	SelcWin		; Repaint selected window title
	RET
FMenuFlg
	BYTE	#00			; 00 - menu open, 01 - menu save as
FileHandle
	BYTE	#00			; File handle
FileName
	BLOCK	#80,0		; And name
BkpSrcH
	BYTE	#00
BkpDstH
	BYTE	#00
BkpRFlg
	BYTE	#00
BackupName
	BLOCK	#80,0
BkpSrcName
	BLOCK	#80,0
BkpBasePtr
	DEFW	#0000
BkpDotPtr
	DEFW	#0000
BkpLastPtr
	DEFW	#0000
;[]===========================================================[]
; Window for
SureWin	LD	IX,TxtWtab
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
	ADD	HL,DE			; Search name window
	DJNZ	$-1
	LD	(BegSnam+1),HL
SurNmLp	LD	A,(HL)
	INC	HL
	CP	'\' 
	JR	NZ,$+5
	LD	(BegSnam+1),HL
	BIT	7,A
	JR	NZ,$+5
	OR	A
	JR	NZ,SurNmLp
	LD	DE,SurName
	PUSH	DE
	LD	A,#20
	LD	B,35
	LD	(DE),A
	INC	DE
	DJNZ	$-2
	POP	DE
	DEC	B
BegSnam	LD	HL,#0000
	INC	B
	LD	A,(HL)
	INC	HL
	BIT	7,A
	JR	NZ,$+5
	OR	A
	JR	NZ,$-8
	LD	A,35
	SUB	23
	SUB	B
	SRL	A
	ADD	A,E
	LD	E,A
	JR	NC,$+3
	INC	D
	LD	A,B
	LD	HL,TmpSurN
	LD	BC,#0005
	LDIR 
	LD	C,A
	LD	A,"'"
	LD	(DE),A
	INC	DE
	LD	HL,(BegSnam+1)
	LDIR 
	LD	(DE),A
	INC	DE
	LD	HL,TmpSurN+5
	LD	C,#10
	LDIR 
	POP	AF
	OUT	(SLOT2),A
	LD	HL,DsureWn
	CALL	DialogW
	LD	HL,what
	LD	A,(HL)
	INC	HL
	CP	evCommand
	RET	NZ
	LD	A,(HL)
	CP	cmYes
	RET	NZ
	JP	SaveFile
;[]===========================================================[]
; Function - Save all
SaveAll	LD	IX,TxtWtab
	LD	DE,#0026
	LD	A,(IX+#00)
	AND	#0F
	PUSH	AF
	PUSH	IX
	PUSH	DE
	LD	A,(ReadyFile)
	OR	A
	CALL	Z,SaveFile
	POP	DE
	POP	IX
SaveAll1
	ADD	IX,DE
	BIT	7,(IX+#00)
	JR	NZ,SaveAllE
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(IX+#1D)		; Text pages
	OUT	(SLOT2),A
	LD	A,(ReadyFile)
	EX	AF,AF'
	POP	AF
	OUT	(SLOT2),A
	EX	AF,AF'
	OR	A
	JR	NZ,SaveAll1
	PUSH	DE
	CALL	SetWind
	CALL	SaveFile
	POP	DE
	LD	IX,TxtWtab
	JR	SaveAll1
SaveAllE
	LD	IX,TxtWtab
	POP	AF
	LD	C,A
	LD	A,(IX+#00)
	AND	#0F
	CP	C
	RET	Z
SaveAlE	ADD	IX,DE
	LD	A,(IX+#00)
	AND	#0F
	CP	C
	JR	NZ,SaveAlE
	CALL	SetWind
	RET 
 _mCollectInfo_addEnd
