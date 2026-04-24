; ================================================================
;                          K O D E
;                    Text Editor for Sprinter
; ================================================================
;
; Based on original Kode source tree
; with IDE-specific features removed
;
; ================================================================
;

;[]================================================================================[]
;
; Kode v0.70
; Last version 0.70 by enin anton in 29.03.99,
; Next version by anatoliy belyanskiy, sprinter team, 2023
;
;[]================================================================================[]

; [ ]----------; for getting labels and
; MMU 2 e, 18; page 18 in 2 and check on

	includelua 'shared_includes/LUA/Functions.LUA'
	include 'shared_includes/constants/SP2000.inc'
	include 'MemMap.inc'
	include 'shared_includes/constants/bios_equ.inc'
	include 'shared_includes/constants/dss_equ.inc'
	include 'shared_includes/macroses/macros.z80'
	include 'version.inc'
	; Device sprinter

 DEFINE SAVE_BIN 0                                                    ; Without for getting labels
 DEFINE COLLECT_INFO 1
	INCLUDE 'KODE_BIN.asm'
;-------------------------------------------------;

;-------------------------------------------------;
	ORG 0
 OUTPUT 'build/KODE.EXE'
	DISP KodeEXE.ORG-exe_header.Size
exe_header equ $
 BYTE	'EXE'				; 0-2 EXE signature
 BYTE	1				; 3   EXE format version (1 = current; 0 = deprecated)
 DWORD	exeLoader.Start - exe_header		; 4-7 code offset in file (Low addr, High addr)
 WORD	exeLoader.Size			; 8-9  primary loader size (0 - no loader)
 WORD	0,0,0				; 10-15 reserved
 WORD	exeLoader.Start			; 16-17 load address in memory
 WORD	exeLoader.Start			; 18-19 entry point (Reg. PC)
 WORD	KodeEXE.stackPoint			; 20-21 initial stack (Reg. SP)
 BLOCK	10,' '				; 23-XXX for in HEX
 BYTE	'Kode Editor     '	
 BYTE	'     v ',_progVERSION,'     '
 BYTE	'Coded in 1999 by'
 BYTE	'  Enin  Anton.  '
 BYTE	'  Resurrected & '
 BYTE	'  modified by   '
 BYTE	'    Anatoliy    '
 BYTE	'   Belyanskiy,  '
 BYTE	' Sprinter Team  '
 BYTE	'      ',_luaBUILD_YEAR,'      '
.Size equ $-exe_header			; 512 size EXE
;-------------------------------------------------;

; _mcollectinfo_addstart

exeLoader.Start:
	DI 
	LD	HL,(#0038)				; Rst #38
	LD	(SAVE_HL),HL
	LD	HL,#C9FB					; Ei : ret
	LD	(#0038),HL				; New rst #38
	LD	A,(IX-#03)				; File handle
	LD	(Fhandle),A				; Save
	CALL	ClearK
	LD	BC,+(ModulesPages.Size)*256+BIOS.GetMem
	RST	ToBIOS					; Must ModulesPages.Size pages memory

	JP	C,No_Space				; CY - none memory
	LD	(FIndef),A				; Pages
	LD	HL,ModulesPages
	LD	C,BIOS.GetMemBlkPages
	RST	ToBIOS					; Pages


	LD	A,(ModulesPages.KodeMain1)			; Enable.with #4000
	OUT	(SLOT2),A
	LD	A,(ModulesPages.KodeMain2)			; Enable.with #8000
	OUT	(SLOT3),A

; !TODO on size, not
; 1 - Prepare ( and )
	LD	HL,#4000	; !HARDCODE
	LD	DE,HSTsize.Prepare				; Internal operation
	LD	A,(Fhandle)
	LD	C,Dss.Read
	RST	ToDSS					; Prepare ()
	JP	C,No_Space				; CY - none memory

	LD	HL,#4000	; !HARDCODE; block
	LD	DE,#9000	; !HARDCODE
	CALL	DePACK					; Prepare
;-[]
	CALL	#9000	; !HARDCODE mem map; Prepare

;
; 2 - KodeMain (2 pages)
	LD	HL,#C100	; !HARDCODE
	LD	DE,HSTsize.KodeMain				; Internal operation
	LD	A,(Fhandle)
	LD	C,Dss.Read
	RST	ToDSS					; Block KodeMain
	JP	C,No_Space				; CY - none memory
	
	LD	HL,#C100	; !HARDCODE; block
	LD	DE,#8000	; !HARDCODE mem map
	CALL	DePACK					; Internal operation
;-[]

	LD	A,(ModulesPages.Dialogwn1)
	OUT	(SLOT2),A
	LD	A,(ModulesPages.Dialogwn2)
	OUT	(SLOT3),A
;
; 3 - Dialogwn (2 pages)
	LD	HL,#4000	; !HARDCODE
	LD	DE,HSTsize.DialogWN				; Internal operation
	LD	A,(Fhandle)
	LD	C,Dss.Read
	RST	ToDSS
	JP	C,No_Space				; CY - none memory

	LD	HL,#4000	; !HARDCODE; block
	LD	DE,#8000	; !HARDCODE mem map
	CALL	DePACK
;-[]

	LD	A,(ModulesPages.Menubar1)
	OUT	(SLOT2),A
	LD	A,(ModulesPages.Menubar2)
	OUT	(SLOT3),A
;
; 4 - Menubar (2 pages)
	LD	HL,#4000	; !HARDCODE
	LD	DE,HSTsize.MenuBar				; Internal operation
	LD	A,(Fhandle)
	LD	C,Dss.Read
	RST	ToDSS
	JP	C,No_Space				; CY - none memory

	LD	HL,#4000	; !HARDCODE; block
	LD	DE,#8000	; !HARDCODE mem map
	CALL	DePACK
;-[]

	LD	A,(ModulesPages.Command)
	OUT	(SLOT2),A
; 
; 5 - Command (1 page)
	LD	HL,#4000	; !HARDCODE
	LD	DE,HSTsize.Command				; Internal operation
	LD	A,(Fhandle)
	LD	C,Dss.Read
	RST	ToDSS
	JP	C,No_Space				; CY - none memory

	LD	HL,#4000	; !HARDCODE; block
	LD	DE,#8000	; !HARDCODE mem map
	CALL	DePACK
;-[]

;
; Ld a,(modulespages.compiler)
; Out (slot2),a
; Ld a,(modulespages.compiler)
; Out (slot3),a
; ;
; 6 - Compiler (2? pages)
; LD HL,#4000
; LD DE,HSTsize.Compiler
; Ld a,(fhandle)
; Ld c,dss.read
; Rst todss
; JP C,No_Space; CY - none memory

; LD HL,#4000; block
; LD DE,#8000
; Call depack
; ;-[]
;

	LD	A,(Fhandle)
	LD	C,Dss.Close
	RST	ToDSS					; Close file

; Page Dialogwn2 so LaunchPathBuf is reachable, then snapshot the KODE.EXE
; directory once via Dss.AppInfo sub-function 1 (returns EXE directory
; regardless of caller's current dir). Fall back to CaptureDir for DSS
; builds that don't support AppInfo. Strip the trailing '\' that AppInfo
; returns, unless the path is just "X:\".
	LD	A,(ModulesPages.Dialogwn2)
	OUT	(SLOT3),A
	LD	HL,LaunchPathBuf
	LD	B,#01				; AppInfo sub-function 1: app path
	LD	C,Dss.AppInfo
	RST	ToDSS
	JR	NC,LaunchPathGot
	LD	HL,LaunchPathBuf
	CALL	CaptureDir
LaunchPathGot:
	LD	HL,LaunchPathBuf
LaunchStripLp:
	LD	A,(HL)
	OR	A
	JR	Z,LaunchStripEnd
	INC	HL
	JR	LaunchStripLp
LaunchStripEnd:
	LD	DE,LaunchPathBuf
	PUSH	HL
	OR	A
	SBC	HL,DE				; HL = length
	LD	A,L
	POP	HL
	CP	#04
	JR	C,LaunchPathOK			; length < 4 → keep "X:\\"
	DEC	HL
	LD	A,(HL)
	CP	#5C
	JR	NZ,LaunchPathOK
	LD	(HL),#00			; drop trailing '\'
LaunchPathOK:

	LD	HL,SetupName
	SUB	A
	LD	C,Dss.Open
	RST	ToDSS
	JR	C,NoSetup

	LD	(Fhandle),A
	LD	IX,#0000
	LD	HL,#0000
	LD	BC,2*256+Dss.Move_FP
	RST	ToDSS

	LD	A,H
	OR	L
	JR	NZ,NoSetup
	LD	A,HX
	CP	#11
	JR	NC,NoSetup
	PUSH	IX
	LD	IX,#0000
	LD	HL,#0000
	LD	BC,#0015
	LD	A,(Fhandle)
	RST	ToDSS

	LD	HL,SetupBuff
	POP	DE
	LD	A,(Fhandle)
	LD	C,Dss.Read
	PUSH	HL
	PUSH	DE
	RST	ToDSS

	POP	DE
	POP	HL
	JP	C,No_Space				; CY - none memory
	ADD	HL,DE
	LD	(HL),#FF
	INC	HL
	LD	(HL),#FF
	LD	A,(Fhandle)
	LD	C,Dss.Close
	RST	ToDSS

NoSetup:	IN	A,(SLOT0)
	PUSH	AF

/*
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	LD	BC,#1FFD					; !fixit #1ffd
	SUB	A
	OUT	(C),A
	LD	C,BIOS.SPRINTER_2
	CALL	#3D14					; !fixit #3d14
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/

	SUB	A
	OUT	(BorderColor),A
	INC	A
	OUT	(RGMOD),A

/*
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	LD	BC,#1FFD					; !fixit #1ffd
	OUT	(C),A
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/

; EXE v1 preserves caller's current dir. Do not issue CurDisk/ChDisk here:
; CHDISK would force curdir back to the root of the current drive and lose
; the working directory the user launched Kode from.

	LD	A,(ModulesPages.KodeMain1)
	OUT	(SLOT0),A
	LD	A,(ModulesPages.KodeMain2)
	OUT	(SLOT3),A
	POP	AF
	LD	(DOSpage),A

	LD	A,(ModulesPages.Dialogwn1)
	LD	(DialogPg1),A
	LD	A,(ModulesPages.Dialogwn2)
	LD	(DialogPg2),A
	LD	A,(ModulesPages.Menubar1)
	LD	(CnTxtPg),A
	LD	A,(ModulesPages.Menubar2)
	LD	(HELPpage),A
	LD	A,(ModulesPages.Command)
	LD	(AsmTabPg),A


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	SUB	A
	LD	BC,#7FFD					; !fixit #7ffd
	OUT	(C),A
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


	LD	HL,FILLend_KodeMain
	LD	DE,FILLend_KodeMain+1
	LD	BC,#FFFF-FILLend_KodeMain
	LD	(HL),A
	LDIR 						; !FIXIT
	
	LD	HL,MoveP
	LD	DE,#F700					; !hardcode mem map
	LD	BC,MoveE-MoveP
	PUSH	DE
	LDIR 
	RET 
SetupName:
	BYTE	"KODE.SET",0
ClearK:	IN	A,(Z84.SIO.Ch_A.Ctrl)
	RRA 
	RET	NC
	IN	A,(Z84.SIO.Ch_A.Data)
	JR	ClearK

;
DePACK:
	INCLUDE 'DEPACK/DePack.asm'
;

;
Fhandle:		BYTE	#00
;

;
ModulesPages:
.KodeMain1:	BYTE	#00
.KodeMain2:	BYTE	#00
.Dialogwn1:	BYTE	#00
.Dialogwn2:	BYTE	#00
.Menubar1:	BYTE	#00
.Menubar2:	BYTE	#00
.Command:		BYTE	#00
.Size		EQU	$-ModulesPages
.CloseByte	BYTE	#00 ; Byte- from pages memory
;

;
; ---------[ self relocating code ]---------;
MoveP:	DI 
	LD	SP,#F6FF					; !hardcode mem map
	IN	A,(SLOT3)
	OUT	(SLOT1),A
	CALL	KodeStart


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	LD	A,#10
	LD	BC,#7FFD					; !fixit #7ffd
	OUT	(C),A
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


	LD	A,(DOSpage)
	OUT	(SLOT0),A

/*
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	LD	BC,#1FFD					; !fixit #1ffd
	SUB	A
	OUT	(C),A
	LD	C,BIOS.SPRINTER_1
	CALL	#3D14					; !fixit #3d14
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/

	SUB	A
	OUT	(BorderColor),A
	INC	A
	OUT	(RGMOD),A


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	LD	BC,#1FFD					; !fixit #1ffd
	OUT	(C),A
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


FIndef+1:	LD	A,#00
	LD	C,BIOS.FreeMem
	RST	ToBIOS
SAVE_HL+1: LD	HL,#0000
	LD	(#0038),HL
No_Space:	LD	B,#00					; !TODO exit with about
	LD	C,Dss.Exit
	RST	ToDSS

MoveE	EQU $
EXEend	EQU $
exeLoader.Size: EQU $ - exeLoader.Start
;------------------------------------------;
; Tmpcount defl 0
HSTsize:
.StartAddr:	EQU $

 ENT
;

;
 DISP 0
	INCBIN 'build/bin/HRUST/Prepare.hst'
.Prepare	EQU $
 ENT
;

;
 DISP 0
	INCBIN 'build/bin/HRUST/KodeMain.hst'
.KodeMain EQU $
 ENT
;

;
 DISP 0
	INCBIN 'build/bin/HRUST/DialogWN.hst'
.DialogWN	EQU $
 ENT
;

;
 DISP 0
	INCBIN 'build/bin/HRUST/MenuBar.hst'
.MenuBar	EQU $
 ENT
;

;
 DISP 0
	INCBIN 'build/bin/HRUST/Command.hst'
.Command	EQU $
	DISPLAY "Current address HRUST: ",/H,$
 ENT
;

;
; Disp 0
; Incbin 'build/bin/hrust/compiler.hst'
; .compiler equ $
; Ent
;

;
	DISPLAY "Prepare	size: ",/A,HSTsize.Prepare
	DISPLAY "KodeMain	size: ",/A,HSTsize.KodeMain
	DISPLAY "DialogWN	size: ",/A,HSTsize.DialogWN
	DISPLAY "MenuBar	size: ",/A,HSTsize.MenuBar
	DISPLAY "Command	size: ",/A,HSTsize.Command
; Display "compiler size: ",/a,hstsize.compiler
 OUTEND
;
; _mcollectinfo_end
