;[]===========================================================[]
; Command-line file open. CmdTailBuf is filled by the KodeEXE loader
; (KodeEXE.asm) from the PSP argument buffer pointed to by IX at EXE
; entry: [0] = tail length, [1..] = args text, space-separated, NUL-
; terminated (program name already stripped by DSS).
;
; CmdLineOpen parses the first whitespace-delimited token as a filename,
; opens it (Dss.Open) and builds its absolute path into FileName, mirroring
; FindFile (Dialog_Windows/Dialogwn5.asm). Called from Kode_Main/Mainunit.asm
; (CmdStartup) once at startup, with DialogPg2 already paged into SLOT3
; (see SynPageDp2In / SynPageDp2Out in Kode_Main/SyntaxExt.asm).
;
; In:  DialogPg2 mapped in SLOT3.
; Out: A=0 - no argument given, nothing else touched.
;      A=1 - file opened: FileHandle = DSS handle, FileName = absolute path.
;      A=2 - file not found: FileName = absolute path, ready for creation
;            on first Save.
CmdTokMax	EQU	#40
CmdTailBuf:	BLOCK	#80,0			; PSP tail, copied in by the loader
CmdTokBuf:	BLOCK	CmdTokMax+1,0		; First token, uppercased, ASCIIZ
CmdRes:		BYTE	#00
CmdHnd:		BYTE	#00
;[]===========================================================[]
CmdLineOpen
	LD	HL,CmdTailBuf
	LD	A,(HL)
	OR	A
	RET	Z				; Empty tail (A=0)
	LD	B,A				; B = remaining tail length
	INC	HL
CmdSkipSp
	LD	A,B
	OR	A
	JR	Z,CmdNoArg			; Ran off end - whitespace only
	LD	A,(HL)
	CP	#21
	JR	NC,CmdTok0			; Found first token char
	INC	HL
	DEC	B
	JR	CmdSkipSp
CmdNoArg
	XOR	A
	RET
CmdTok0
	LD	DE,CmdTokBuf
	LD	C,CmdTokMax
CmdTokLp
	LD	A,B
	OR	A
	JR	Z,CmdTokEnd
	LD	A,(HL)
	CP	#21
	JR	C,CmdTokEnd			; Space/ctrl ends the token
	CP	#40
	JR	C,CmdTokSt
	RES	5,A				; Uppercase, as FindFile does
CmdTokSt
	LD	(DE),A
	INC	HL
	INC	DE
	DEC	B
	LD	A,C
	OR	A
	JR	Z,CmdTokEnd			; Token buffer full
	DEC	C
	JR	CmdTokLp
CmdTokEnd
	XOR	A
	LD	(DE),A				; NUL-terminate the token

	PUSH	IY
	PUSH	IX
	IN	A,(SLOT0)
	PUSH	AF
	LD	A,(DOSpage)			; Enable system DOS in 0 page
	OUT	(SLOT0),A
	LD	BC,#7FFD
	LD	A,#10				; Enable ports vg93
	OUT	(C),A

	LD	HL,CmdTokBuf			; DSS resolves a relative name
	SUB	A				; against the shell's current dir
	LD	C,Dss.Open
	RST	ToDSS
	LD	(CmdHnd),A
	LD	A,#01				; Assume opened
	JR	NC,CmdGotHn
	LD	A,#02				; Not found - create on first save
CmdGotHn
	LD	(CmdRes),A

; Build the absolute path into FileName, mirroring FindFile (Dialog_Windows/
; Dialogwn5.asm): "X:" + current dir (unless the token already carries a
; drive letter or is rooted with '\') + the token itself.
; NB: DSS does not preserve HL across RST ToDSS - CurDir is an LDI loop that
; leaves HL inside the system DIRSPEC buffer - so the cursor is reloaded after
; every call, exactly as CaptureDir and FindFile do.
	LD	HL,FileName
	LD	A,(CmdTokBuf+1)
	CP	':'
	JR	Z,CmdCopyTok			; Token has drive - copy verbatim
	LD	C,Dss.CurDisk
	RST	ToDSS				; A = current drive (0='A',...)
	ADD	A,'A'
	LD	HL,FileName			; Reload - CurDisk trashed HL
	LD	(HL),A				; "X"
	INC	HL
	LD	(HL),':'			; "X:"
	INC	HL
	LD	A,(CmdTokBuf)
	CP	'\'
	JR	Z,CmdCopyTok			; Root-relative: "X:" + token
	LD	(HL),0
	PUSH	HL
	LD	C,Dss.CurDir
	RST	ToDSS				; Writes "\PATH",0 starting at (HL)
	POP	HL				; Reload - CurDir trashed HL
CmdFindEnd
	LD	A,(HL)
	OR	A
	JR	Z,CmdEndFound
	INC	HL
	JR	CmdFindEnd
CmdEndFound
	DEC	HL
	LD	A,(HL)
	INC	HL
	CP	'\'
	JR	Z,CmdCopyTok
	LD	(HL),'\'
	INC	HL
CmdCopyTok
	EX	DE,HL				; DE = destination cursor in FileName
	LD	HL,CmdTokBuf
CmdCopyLp
	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	OR	A
	JR	NZ,CmdCopyLp

	LD	BC,#7FFD
	SUB	A				; Disable ports vg93
	OUT	(C),A
	POP	AF
	OUT	(SLOT0),A			; Restore 0 page
	POP	IX
	POP	IY

	LD	A,(CmdRes)
	CP	#02
	RET	Z				; Not found - FileName ready, no handle
	LD	A,(CmdHnd)
	LD	(FileHandle),A
	LD	A,#01
	RET
;[]===========================================================[]
