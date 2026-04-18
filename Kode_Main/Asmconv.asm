 _mCollectInfo_addStart
;[]===========================================================[]
; Procedure conversion text in TAS file
;[]===========================================================[]
ConvTXTtoTAS
	LD	IX,TxtWtab	; Table window descriptors
	BIT	7,(IX+#00)	; 7=1 - open 1 window
	JR	NZ,ConvNxt
	CALL	OnlySyntax	; Syntax-highlight last line
	CALL	PutString	; Insert it in text
	CALL	ResCurs		; Disable cursor
ConvNxt	LD	HL,KeyBuff+#21	; Pages new text
	LD	A,(HL)		; Page 1
	INC	HL
	LD	(textpg1+1),A	; Number 1 pages text
	LD	A,(HL)		; Page 2
	LD	(textpg2+1),A	; Number 2 pages text
	CALL	ResMBar		; Disable.MenuBar
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	LD	HL,ConTXTTAS	; Procedure from process
	LD	(ConCall),HL
	LD	DE,ConName	; Name for.window
	PUSH	DE
	LD	B,#2A
	LD	A,#20
	LD	(DE),A		; Internal operation
	INC	DE
	DJNZ	$-2
	POP	DE
	LD	HL,FileName-1	; With
	PUSH	HL
	LD	BC,#00FF
	INC	C		; Count length name
	INC	HL
	LD	A,(HL)
	OR	A
	JR	NZ,$-4
	POP	HL
	INC	HL
	LD	A,#2A		; Buffers- name
	SUB	C
	JR	NC,connmok	; NC
	NEG			; On how many not
	ADD	A,L
	LD	L,A
	JR	NC,$+3		; To name
	INC	H
	INC	HL		;+..
	INC	HL
	LD	C,#28		; Ax name - 2
	LD	A,"."
	LD	(DE),A		; In
	INC	DE
	LD	(DE),A
	INC	DE
	JR	connmno
connmok	SRL	A		; Internal operation
	ADD	A,E
	LD	E,A
	JR	NC,$+3		; In buffer
	INC	D
connmno	LDIR			; Copy
	POP	AF
	OUT	(SLOT2),A
	LD	E,L
	LD	D,H
	LD	B,#04
ext1	DEC	HL
	LD	A,(HL)
	CP	"."
	JR	Z,extf
	DJNZ	ext1
	EX	DE,HL
	DEC	HL
extf	INC	HL
	LD	(HL),"T"	; Set s TAS
	INC	HL
	LD	(HL),"X"
	INC	HL
	LD	(HL),"T"
	INC	HL
	SUB	A		; Header
	LD	(HL),A
	CALL	InitWin		; Descriptor new window
	LD	HL,FileName	; Name
	CALL	InitNam		; Place name window in.names
	CALL	HiddWin		; Disable current.window
	CALL	PutTextWn	; Open new window
	LD	HL,WindGrp
	CALL	OpenGroup	; Groups
	LD	A,NoConTxt	; Internal operation
	CALL	PutStatusLn	; Status line
	SUB	A
	LD	L,A
	LD	H,L
	LD	(ReadFlag),A	; Flag
	LD	(CountWind),A	; Count-in open text.windows
	INC	A
	LD	(LstByte+1),A	; Byte
	LD	(EquipLn),HL	; Count-in.lines
	LD	(BegTXTstr),HL	; Start next. TXT
	LD	(RealBytes),HL	; Count-in
	LD	HL,#8040
	LD	(BegTASstr),HL	; Next. TAS
	LD	HL,FreeWin	; Windows
	SUB	A
	LD	B,#0F		; Max count-in windows
	BIT	7,(HL)		; Count count-in open windows
	INC	HL
	JR	Z,$+3
	INC	A
	DJNZ	$-6
	LD	(CountOpenW),A	; Count-in already open windows
	PUSH	IY
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)	; Enable system DOS
	OUT	(SLOT0),A		; In 0 page
	LD	BC,#7FFD														; !fixit #7ffd
	LD	A,#10		; Enable. ports vg93
	OUT	(C),A
	LD	IX,#0000	; FilePointer=
	LD	HL,#0000
	LD	A,(FileHandle)	; File handle
	LD	B,#02
	LD	C,#15		; Function DOS: Move_FP
	RST	#10
	LD	(FileBytes),IX	; Internal operation
	LD	(FileBytes+2),HL
	LD	IX,#0000	; Filepointer=0
	LD	HL,#0000
	LD	A,(FileHandle)	; File handle
	LD	B,H
	LD	C,#15		; Function DOS: Move_FP
	RST	#10
	LD	BC,#7FFD														; !fixit #7ffd
	SUB	A		; Disable. ports vg93
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A		; Restore 0 page
	POP	IY

	LD	HL,Dprocess	; Window with
	CALL	DialogW		; Open

	CALL	ResCurs		; Disable cursor
	CALL	CloseFl		; File
	LD	A,(textpg1+1)	; 2 pages text
	OUT	(SLOT2),A
	LD	A,(textpg2+1)
	OUT	(SLOT3),A
	CALL	ReCompileStr	; Current.line
	CALL	OnlySyntax	; Syntax-highlight it without printing
	CALL	InitPage	; Page
	LD	IX,TxtWtab	; Table window descriptors
	CALL	PutIPage	; Store in window page
	CALL	RefrWin		; Refresh screen in buffer
	LD	HL,FrameSl  ; Pointer on frame selected window
	CALL	PutFram	    ; Draw frame
	CALL	PutShad		; Draw shadow
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(BuffPg4)
	OUT	(SLOT3),A
	CALL	PutWork	; Set window in
	POP	AF
	OUT	(SLOT3),A
	CALL	PutBuff	; Copy in.area
	CALL	SetCurs	; Enable.cursor
	LD	HL,FreeWin
	SUB	A
	LD	B,#0F
	BIT	7,(HL)		; Count count-in open windows
	INC	HL
	JR	Z,$+3
	INC	A
	DJNZ	$-6
	CP	#0F
	RET	C		; Less 15 - Okey
	LD	A,cmNew		; Already 15
	CALL	CloseCmnd	; Command New
	LD	A,NoConTxt	; Internal operation
	CALL	PutStatusLn	; Status line
	RET 
;[]===========================================================[]
; Procedure conversion in TAS line
; On:
; ----
; On exit:
; CY
ConTXTTAS
	LD	IX,(RealBytes)	; Count-in byte
	LD	HL,(BegTXTstr)	; Next
	LD	DE,ReCompBuff	; Internal operation
	LD	BC,#00F0	; Internal operation
LstByte	LD	A,#00		; Byte
	OR	A
	SCF 
	RET	Z
	LD	A,H
	OR	A
	CALL	Z,ReadBlock	; New block
	RET	C		; Error
	LD	A,HX
	OR	LX
	SCF 
	RET	Z		; Internal operation
	IN	A,(SLOT2)
	PUSH	AF		; Save. 2 and 3 page
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(SymbPg1)
	OUT	(SLOT2),A
	LD	A,(SymbPg2)
	OUT	(SLOT3),A
	PUSH	HL
	ADD	HL,BC		; Check, text
	POP	HL		; Not end block
	CALL	C,AddBlock	; If,then next
	JP	C,ConvExt	; Error
	LD	A,HX
	OR	A
	JR	NZ,ConvCyc
	LD	A,LX
	CP	#F0
	CALL	C,AddBlock
	LD	A,HX
	OR	A
	JR	NZ,ConvCyc
	LD	A,LX
	CP	#F0
	JR	NC,ConvCyc
	LD	C,LX
ConvCyc	LD	B,C
ConvTA1	LD	A,(HL)		; 0
	OR	A
	JR	Z,MoveCEx
	INC	HL
	DEC	IX
	CP	#0D
	JR	Z,MoveCEx
	CP	#09
	JR	NZ,ConvTA3
	LD	C,#08
ConvTB0	LD	A,HX
	OR	LX
	JR	Z,ConvTB1
	LD	A,(HL)
	CP	#09
	JR	NZ,ConvTB1
	LD	A,C
	ADD	A,#08
	LD	C,A
	INC	HL
	DEC	IX
	JR	ConvTB0
ConvTB1	PUSH	BC		; Internal operation
	LD	A,E
	AND	#F8
	ADD	A,C
	LD	C,A
	LD	A,(LabSize)
	LD	B,A		; Size for labels
	SUB	A
	ADD	A,B
	CP	C
	JR	NC,ConvTA2
	EX	AF,AF'
	LD	A,(TabSize)
	LD	B,A		; Size
	EX	AF,AF'
	ADD	A,B
	CP	C
	JR	C,$-2
ConvTA2	SUB	E
	LD	B,A
	LD	A,#20
	LD	(DE),A
	INC	E
	DJNZ	$-2
	POP	BC
	LD	A,HX
	OR	LX
	JR	NZ,ConvTA1
	JR	MoveCE1
ConvTA3
	LD	(DE),A
	INC	E
	DJNZ	ConvTA1
	JR	MoveCE1
MoveCEx	LD	A,(HL)		; Byte
	LD	(LstByte+1),A
	INC	HL
	DEC	IX
MoveCE1	LD	(RealBytes),IX	; Save..length
	LD	(BegTXTstr),HL	; Next.text
	SUB	A
	LD	(DE),A
	PUSH	IY
	LD	IY,ConvData	; Data
	LD	A,(CnTxtPg)	; Program conversion
	OUT	(SLOT2),A
	LD	(IY+#00),E	; Page
	LD	A,(AsmTabPg)	; Table Z80 commands
	OUT	(SLOT3),A
	CALL	ConvSyntax	; Syntax-highlight line
	CALL	CompTxtStr	; Line
	POP	IY
textpg1	LD	A,#00		; 1 page text
	OUT	(SLOT2),A
textpg2	LD	A,#00		; 2 page text
	OUT	(SLOT3),A
	LD	HL,(BegTASstr)	; Next.TAS
	LD	A,(CompBuff)	; Internal operation
	LD	C,A
	LD	B,#00
	PUSH	HL
	ADD	HL,BC		; Check TAS window
	POP	HL
	JR	C,NxtTxtWind	; If,then next. TAS window
	LD	DE,CompBuff
	EX	DE,HL
	LDIR			; Copy line
	SUB	A
	LD	(DE),A
	LD	(BegTASstr),DE	; Next.TAS
	LD	(EndText),DE
	LD	HL,(EquipLn)	; Count-in lines in file
	INC	HL		;+1
	LD	(EquipLn),HL
	LD	HL,(CurFPoint)
	LD	DE,(BegTXTstr)
	RES	7,D
	ADD	HL,DE
	LD	(CurrBytes),HL
	LD	HL,(CurFPoint+2)
	JR	NC,$+3
	INC	HL
	LD	(CurrBytes+2),HL
	POP	AF		; Restore. 2 and 3 pages
	OUT	(SLOT3),A
	POP	AF
	OUT	(SLOT2),A
	OR	A
	RET 
NxtTxtWind			; Next.TAS window
	PUSH	BC
	CALL	GetMemory	; Get free pages
	POP	BC
	JP	C,ConvExt	; None memory
	PUSH	BC
	LD	HL,CompBuff
	LD	DE,FuncBuffer
	LDIR 
	CALL	ReCompileStr	; Current.line
	CALL	OnlySyntax	; Syntax-highlight it without printing
	CALL	InitPage	; Page
	LD	IX,TxtWtab
	CALL	PutIPage	; Store in window page
	PUSH	IX
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	CALL	ClsDial+3
	POP	AF
	OUT	(SLOT2),A
	POP	IX
	CALL	PrnTxtW		; Print window on screen
	POP	BC		; Internal operation
	LD	HL,CountWind	; Count-in windows
	INC	(HL)		;+1
	LD	A,(CountOpenW)	; Count-in already. windows
	ADD	A,(HL)
	CP	#10
	JP	Z,ConvExt1	; Window
	LD	A,(KeyBuff+#21)
	LD	(textpg1+1),A	; Pages new window
	LD	A,(KeyBuff+#22)
	LD	(textpg2+1),A
	PUSH	BC
	SUB	A		; Header
	CALL	InitWin		; Descriptor new window
	LD	HL,FileName	; Name
	CALL	InitNam		; Place name window in.names
	LD	IX,TxtWtab+#26
	RES	6,(IX+#00)	; Window
	LD	HL,FrameHd ; Pointer on frame window
	CALL	PutFram	    ; Draw frame
	CALL	PrnTxtW	    ; Print window on screen
	LD	IX,TxtWtab
	CALL	GetTxtW	    ; With screen from-under.window
	CALL	Rectang	    ; Internal operation
	LD	HL,FrameSl  ; Pointer on frame selected window
	CALL	PutFram	    ; Draw frame
	CALL	PutShad	    ; Draw shadow
	CALL	PrnTxtW	    ; Print window on screen
	IN	A,(SLOT2)
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	LD	A,(BuffPg5)	;Page buffer
	OUT	(SLOT3),A
	LD	IX,DialData
	CALL	SavDial
	CALL	PutDialSh
	CALL	PutDial
	POP	BC
	LD	A,B
	OUT	(SLOT3),A
	LD	A,C
	OUT	(SLOT2),A
	POP	BC
	LD	HL,FuncBuffer
	LD	DE,#8040
	LDIR			; Copy.line
	SUB	A
	LD	(DE),A
	LD	(BegTASstr),DE	; Next.TAS
	LD	(EndText),DE
	LD	HL,(CurFPoint)
	LD	DE,(BegTXTstr)
	RES	7,D
	ADD	HL,DE
	LD	(CurrBytes),HL
	LD	HL,(CurFPoint+2)
	JR	NC,$+3
	INC	HL
	LD	(CurrBytes+2),HL
	OR	A
ConvExt	EX	AF,AF'
	POP	AF
	OUT	(SLOT3),A		; Restore. 2 and 3 pages
	POP	AF
	OUT	(SLOT2),A
	EX	AF,AF'
	RET 
ConvExt1
	LD	A,(KeyBuff+#20)	; Text.pages
	LD	C,#C3		; Free pages
	RST	#10
	SCF 
	JR	ConvExt
;[]===========================================================[]
; Procedure part
; On:
; IX - byte (<#F0)
; HL
; On exit:
; IX - new count-in byte in
; HL
AddBlock
	LD	A,(ReadFlag)	; Flag
	OR	A
	RET	NZ		; NZ - all file
	PUSH	IY
	PUSH	DE
	PUSH	BC
	LD	DE,#8000	; Copy last line
	LD	C,LX		; Text in start
	LD	B,E
	PUSH	DE
	LDIR 
	SUB	A
	LD	(DE),A
	LD	C,E
	LD	B,D
	LD	L,A
	LD	H,L
	OR	A
	SBC	HL,BC		; Count how many byte end
	EX	DE,HL		; Block -> DE (count-in.byte)
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)	; Enable system DOS
	OUT	(SLOT0),A		; In 0 page
	LD	BC,#7FFD														; !fixit #7ffd
	LD	A,#10		; Enable. ports vg93
	OUT	(C),A
	PUSH	HL
	PUSH	DE
	LD	IX,#0000	; Current.offset.in file
	LD	HL,#0000
	LD	B,#01
	LD	A,(FileHandle)	; File handle
	LD	C,#15		; Function DOS: Move_FP
	RST	#10
	PUSH	IX		; Current.offset.in file
	POP	DE
	EX	DE,HL
	LD	BC,(RealBytes)	; Then
	OR	A
	SBC	HL,BC
	LD	(CurFPoint),HL
	EX	DE,HL
	JR	NC,$+3
	DEC	HL
	LD	(CurFPoint+2),HL
	POP	DE
	POP	HL
	LD	A,(FileHandle)	; File handle
	LD	C,#13		; Function DOS: Read
	RST	#10
	LD	(ReadFlag),A	; Flag
	EX	AF,AF'
	LD	IX,(RealBytes)
	ADD	IX,DE		; IX - count-in byte
	LD	BC,#7FFD														; !fixit #7ffd
	SUB	A		; Disable. ports vg93
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A		; Restore 0 page
	POP	HL
	POP	BC
	POP	DE
	POP	IY
	EX	AF,AF'
	RET 
;[]===========================================================[]
; Procedure part
; On:
; --------
; On exit:
; IX - new count-in byte in
; HL
ReadBlock
	IN	A,(SLOT2)
	PUSH	AF
	IN	A,(SLOT3)
	PUSH	AF
	LD	A,(SymbPg1)
	OUT	(SLOT2),A
	LD	A,(SymbPg2)
	OUT	(SLOT3),A
	PUSH	IY
	PUSH	DE
	PUSH	BC
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)	; Enable system DOS
	OUT	(SLOT0),A		; In 0 page
	LD	BC,#7FFD														; !fixit #7ffd
	LD	A,#10		; Enable. ports vg93
	OUT	(C),A
	LD	IX,#0000	; Current.offset.in file
	LD	HL,#0000
	LD	B,#01
	LD	A,(FileHandle)	; File handle
	LD	C,#15		; Function DOS: Move_FP
	RST	#10
	LD	(CurFPoint),IX
	LD	(CurFPoint+2),HL	; Current.offset. in file
	LD	HL,#8000	; Start block
	LD	E,L		; Block
	LD	D,H
	LD	A,(FileHandle)	; File handle
	LD	C,#13		; Function DOS: Read
	RST	#10
	LD	(ReadFlag),A	; Flag
	EX	AF,AF'
	PUSH	DE
	POP	IX		; IX - count-in byte
	LD	BC,#7FFD														; !fixit #7ffd
	SUB	A		; Disable. ports vg93
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A		; Restore 0 page
	POP	BC
	POP	DE
	POP	IY
	POP	AF
	OUT	(SLOT3),A
	POP	AF
	OUT	(SLOT2),A
	EX	AF,AF'
	LD	HL,#8000	; Text
	RET 
;[]===========================================================[]
; For conversion
ConvData		; Iy point
	DEFB	#00	; Internal operation
	DEFB	#00	; Flag conversion
	DEFB	#00	; Labels
	DEFB	#00	; Commands
	DEFB	#00	; Internal operation
ReadFlag		; Flag
	DEFB	#00	; 00 - not all,01 -.all
CountWind		; Count open windows (with 0) in
	DEFB	#00	; Conversion
CountOpenW		; Count already open windows
	DEFB	#00	; Conversion
BegTXTstr		; Internal operation
	DEFW	#0000	; If >0 then must next.block
BegTASstr		; And byte
	DEFW	#0000	; Internal operation
RealBytes		; Count-in block
	DEFW	#0000	; From
FileBytes
	DEFS	4,0	; Internal operation
CurrBytes
	DEFS	4,0	; Current.offset in file
CurFPoint
	DEFS	4,0	; Current FilePointer
;[]===========================================================[]
; Procedure conversion TAS in file
;[]===========================================================[]
ConvTAStoTXT
	LD	IX,TxtWtab	; Table window descriptors
	CALL	OnlySyntax	; Syntax-highlight last line
	CALL	PutString	; Insert it in text
	CALL	ResCurs		; Disable cursor
	CALL	ResMBar		; Disable.MenuBar
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	LD	HL,ConTASTXT	; From process
	LD	(ConCall),HL
	LD	DE,ConName	; Name for.window
	PUSH	DE
	LD	B,#2A
	LD	A,#20
	LD	(DE),A		; Internal operation
	INC	DE
	DJNZ	$-2
	POP	DE
	LD	HL,FileName-1	; With
	PUSH	HL
	LD	BC,#00FF
	INC	C		; Count length name
	INC	HL
	LD	A,(HL)
	OR	A
	JR	NZ,$-4
	POP	HL
	INC	HL
	LD	A,#2A		; Buffers- name
	SUB	C
	JR	NC,con1		; NC
	NEG			; On how many not
	ADD	A,L
	LD	L,A
	JR	NC,$+3		; To name
	INC	H
	INC	HL		;+..
	INC	HL
	LD	C,#28		; Ax name - 2
	LD	A,"."
	LD	(DE),A		; In
	INC	DE
	LD	(DE),A
	INC	DE
	JR	con2
con1	SRL	A		; Internal operation
	ADD	A,E
	LD	E,A
	JR	NC,$+3		; In buffer
	INC	D
con2	LDIR			; Copy
	POP	AF
	OUT	(SLOT2),A
	LD	HL,#0000
	LD	(FileBytes+2),HL	; With 16
	LD	(CurrBytes+2),HL
	LD	H,#80
	LD	(BegTXTstr),HL	; Start next. TXT
	LD	L,#40
	LD	(BegTASstr),HL	; Start next. TAS
	LD	HL,(EndText)
	RES	7,H
	INC	HL
	LD	(FileBytes),HL	; Internal operation
	PUSH	IY
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)	; Enable system DOS
	OUT	(SLOT0),A		; In 0 page
	LD	BC,#7FFD														; !fixit #7ffd
	LD	A,#10		; Enable. ports vg93
	OUT	(C),A
	LD	HL,FileName	; Internal operation
	SUB	A		; Internal operation
	LD	C,#0A		; Function DOS: Create File
	RST	#10
	LD	(FileHandle),A	; File handle
	EX	AF,AF'
	LD	BC,#7FFD														; !fixit #7ffd
	SUB	A		; Disable. ports vg93
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A		; Restore 0 page
	POP	IY
	EX	AF,AF'
	JR	C,ConATex	; Error

	LD	HL,Dprocess	; Window with
	CALL	DialogW		; Open

ConATex	CALL	ResCurs		; Disable cursor
	CALL	CloseFl		; File
	LD	IX,TxtWtab	; Table window descriptors
	LD	A,(IX+#1D)	; 2 pages text
	OUT	(SLOT2),A
	LD	A,(IX+#1E)
	OUT	(SLOT3),A
	CALL	SetNewName	; New name window
	CALL	ReCompileStr	; Current.line
	CALL	OnlySyntax	; Syntax-highlight it without printing
	LD	(IY+#17),#01	; Readyfile
	CALL	SetCurs		; Enable.cursor
	CALL	PrintInfo+4
	RET 
;[]===========================================================[]
; Procedure conversion TAS in TXT line
; On:
; ----
; On exit:
; CY
ConTASTXT
	IN	A,(SLOT2)		; Save 2 and 3 pages
	LD	C,A
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	IX,TxtWtab	; Table window descriptors
	LD	A,(IX+#1D)	; 2 pages text
	OUT	(SLOT2),A
	LD	A,(IX+#1E)
	OUT	(SLOT3),A
	LD	HL,(BegTASstr)	; Copy current. TAS line
	LD	DE,CompBuff	; In
	LD	A,(HL)		; Internal operation
	OR	A
	JR	Z,ConvWRT	; 0 - TAS
	LD	C,A
	LD	B,#00
	LDIR			; Copy
	LD	(BegTASstr),HL	; Next. TAS
	RES	7,H		;-#8000
	LD	(CurrBytes),HL	; Count-in byte
	LD	A,(CnTxtPg)	; Program conversion
	OUT	(SLOT2),A
	LD	A,(AsmTabPg)	; Table Z80 commands
	OUT	(SLOT3),A
	CALL	ConvDeComp	; TAS line in TXT
	CALL	TABcorrect	; Internal operation
	LD	HL,(BegTXTstr)	; Next.TXT
	PUSH	HL		; BC
	ADD	HL,BC		; Check on text
	POP	HL		; Buffers
	CALL	C,WriteBlock	; CY
	LD	DE,CompBuff	; Where text
	EX	DE,HL
	LD	A,(SymbPg1)	; Enable.pages text. buffers
	OUT	(SLOT2),A
	LD	A,(SymbPg2)
	OUT	(SLOT3),A
	LDIR			; Copy text.line
	LD	(BegTXTstr),DE	; Next.text
	OR	A		; Cy - 0
ConvATe	POP	BC
	LD	A,B
	OUT	(SLOT3),A		; Restore. 2 and 3 pages
	LD	A,C
	OUT	(SLOT2),A
	RET 
ConvWRT	CALL	WriteBlock	; Block
	SCF			; CY - flag end
	JR	ConvATe		; Exit
;[]===========================================================[]
; Procedure write block text
; On:
; -------------
; On exit:
; HL - text
WriteBlock
	PUSH	BC		; Save.length
	IN	A,(SLOT2)
	LD	C,A		; Save. 2 and 3 page
	IN	A,(SLOT3)
	LD	B,A
	PUSH	BC
	LD	A,(SymbPg1)	; Enable.2 page.with
	OUT	(SLOT2),A
	LD	A,(SymbPg2)
	OUT	(SLOT3),A
	PUSH	IY
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)	; Enable system DOS
	OUT	(SLOT0),A		; In 0 page
	LD	BC,#7FFD														; !fixit #7ffd
	LD	A,#10		; Enable. ports vg93
	OUT	(C),A
	LD	HL,#8000	; Internal operation
	LD	DE,(BegTXTstr)	; #8000
	RES	7,D		; =
	LD	A,D
	OR	E		; Check, =0
	LD	A,(FileHandle)	; File handle
	LD	C,#14		; Function DOS: Write
	CALL	NZ,#0010	; If =0,then not
	EX	AF,AF'
	LD	BC,#7FFD														; !fixit #7ffd
	SUB	A		; Disable. ports vg93
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A		; Restore 0 page
	POP	IY
	POP	BC
	LD	A,B		; Restore. 2 and 3 pages
	OUT	(SLOT3),A
	LD	A,C
	OUT	(SLOT2),A
	POP	BC		; Restore.length current
	EX	AF,AF'
	LD	HL,#8000	; New BegTXTstr
	RET 
;[]===========================================================[]
 _mCollectInfo_addEnd
