;[]===========================================================[]
; Build/Run integration engine (Dialog_Windows_PG2). Entered as BldEntry
; from the resident dispatch stub in Kode_Main/Mainunit.asm, which has mapped
; this page (DialogPg2) into SLOT3 first.
;
; Delegates all "decide what to launch" logic to BuildScan.asm (included at
; the end of this file) and spawns the child via Dss.Exec. Runs dialogs via
; the resident DialogW; does file probes and EXEC inside a DOS sandwich
; (DOSpage->SLOT0 + #7FFD=#10), bracketed by directory save/restore so the
; editor's working directory survives a child that ChDirs.
;
; Verdict returned in A to the stub: 0 done, 1 SaveAll+resume, 2 repaint.
; Actions in A on entry: 0 Run, 1 Parameters, 2 Build, 3 Target, 4 ShowLog,
; #7F resume-after-SaveAll.
;[]===========================================================[]
BldEntry
	CP	#7F
	JR	Z,BeDisp		; resume - keep BldAct, BldSkip already set
	LD	(BldAct),A
	XOR	A
	LD	(BldSkip),A
BeDisp	LD	A,(BldAct)
	OR	A
	JP	Z,BldDoRun
	DEC	A
	JP	Z,BldDoParm
	DEC	A
	JP	Z,BldDoBuild
	DEC	A
	JP	Z,BldDoTarg
	JP	BldDoShow
;[]===========================================================[]
; Verdict exits (RET out of BldEntry to the stub).
BldV0	XOR	A
	RET
BldRetV	RET			; A already holds the verdict
;[]===========================================================[]
; Build (mode 0) and Run (mode 1) share this flow.
BldDoBuild
	LD	A,#00
	JR	BldBR
BldDoRun
	LD	A,#01
BldBR	LD	(BldBRmode),A
	CALL	BldAskSave
	OR	A
	JR	Z,BrGo
	DEC	A
	JR	Z,BldV0			; Cancel -> abort
	LD	A,#01
	JR	BldRetV			; Yes -> save and resume
BrGo	CALL	BldGetDir
	CALL	BldSaveEditor
	CALL	BldDosIn
	JR	C,BrDirErr
	LD	A,(BldBRmode)
	CALL	BldDecide
	LD	(BldFound),A
	OR	A
	JR	NZ,BrNoExec
BrExec	CALL	ConsoleRestore
	CALL	BldExecCon
	JR	BrNoExec
BrDirErr	LD	A,#03
	LD	(BldFound),A
BrNoExec	CALL	BldDosOut
	CALL	BldResetKey		; after Main is back in SLOT0, even on load failure
	LD	A,(BldFound)		; grab console only if a child actually ran
	OR	A
	JR	NZ,BrReinit
	LD	A,(BldErrF)
	OR	A
	JR	NZ,BrReinit
	CALL	ConsoleGrab		; include output and non-zero exit message
	LD	A,(BldErr)
	OR	A
	CALL	NZ,BldWaitKode		; pause only for a non-zero child exit code
BrReinit
	CALL	BldReInit
	LD	A,(BldRestoreErr)
	OR	A
	LD	HL,BldMCwd
	JR	NZ,BrMsg
	LD	A,(BldFound)
	OR	A
	JR	Z,BrErrChk
	CP	#02
	LD	HL,BldMIo
	JR	Z,BrMsg
	LD	HL,BldMDir
	JR	NC,BrMsg
	LD	A,(BldBRmode)		; nothing found
	OR	A
	LD	HL,BldMNoBuild
	JR	Z,BrMsg
	LD	HL,BldMNoRun
BrMsg	CALL	BldMessage
	JP	BldV0			; BldReInit already restored the saved screen
BrErrChk
	LD	A,(BldErrF)
	OR	A
	JP	Z,BldV0			; child ran; saved screen is already restored
	CALL	BldExecErrMsg
	JP	BldV0
;[]===========================================================[]
; Parameters... - edit the session args string (never persisted).
BldDoParm
	LD	HL,FuncBuffer		; prefill input buffer from BldParams
	LD	(HL),#40		; max input symbols
	INC	HL
	XOR	A
	LD	(HL),A			; ready flag
	INC	HL
	LD	(HL),A			; pos x
	INC	HL
	LD	(HL),A			; add x
	INC	HL
	LD	A,(BldParams)		; current length
	LD	(HL),A
	INC	HL			; -> text area (FuncBuffer+5)
	LD	DE,BldParams+1
BpPre	LD	A,(DE)
	LD	(HL),A
	OR	A
	JR	Z,BpPreD
	INC	DE
	INC	HL
	JR	BpPre
BpPreD	LD	HL,DbldParm
	CALL	DialogW
	LD	HL,what
	LD	A,(HL)
	INC	HL
	CP	evCommand
	JP	NZ,BldV0
	LD	A,(HL)
	CP	cmCancel
	JP	Z,BldV0
	LD	A,(FuncBuffer+4)	; input length
	LD	(BldParams),A
	LD	HL,FuncBuffer+5
	LD	DE,BldParams+1
	LD	B,A
BpRb	LD	A,B
	OR	A
	JR	Z,BpRbD
	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	DEC	B
	JR	BpRb
BpRbD	XOR	A
	LD	(DE),A			; NUL-terminate args
	JP	BldV0
;[]===========================================================[]
; Target... - scan MAKEFILE, pick a target, run "MAKE.EXE <target>".
BldDoTarg
	CALL	BldAskSave
	OR	A
	JR	Z,BtGo
	DEC	A
	JP	Z,BldV0
	LD	A,#01
	JP	BldRetV
BtGo	CALL	BldGetDir
	CALL	BldDosIn
	LD	A,#03
	JR	C,BtBad
	XOR	A			; mode 0 - collect targets
	CALL	BldScanMk
	JR	C,BtNoMk
	LD	(BldTgtCnt),A
	XOR	A
	LD	(BldNoMk),A
	JR	BtAfter
BtNoMk	LD	A,(BldIoErr)
	OR	A
	LD	A,#01
	JR	Z,BtBad
	INC	A
BtBad	LD	(BldNoMk),A
BtAfter	CALL	BldDosOut
	LD	A,(BldRestoreErr)
	OR	A
	LD	HL,BldMCwd
	JR	NZ,BtMsg
	LD	A,(BldNoMk)
	OR	A
	JR	Z,BtHave
	CP	#02
	LD	HL,BldMIo
	JR	Z,BtMsg
	LD	HL,BldMDir
	JR	NC,BtMsg
	LD	HL,BldMNoMake
BtMsg	CALL	BldMessage
	JP	BldV0
BtHave	LD	A,(BldTgtCnt)
	OR	A
	JR	NZ,BtShow
	LD	HL,BldMNoTgt
	CALL	BldMessage
	JP	BldV0
BtShow	LD	HL,DbldTarg
	CALL	DialogW
	LD	HL,what
	LD	A,(HL)
	INC	HL
	CP	evCommand
	JP	NZ,BldV0
	LD	A,(HL)
	CP	cmCancel
	JP	Z,BldV0
	INC	HL
	LD	A,(HL)			; selected list index (what+2)
	CALL	BldNthTgt		; -> BldTgtName
	JP	C,BldV0
	LD	HL,BldNMkSp		; "MAKE.EXE "
	CALL	BldStrCpy
	LD	HL,BldTgtName
	CALL	BldStrCat
	CALL	BldGetDir
	CALL	BldSaveEditor
	CALL	BldDosIn
	JP	C,BrDirErr
	XOR	A
	LD	(BldFound),A		; join the same post-EXEC path as Build/Run
	JP	BrExec
;[]===========================================================[]
; Show console log - blit the saved console page, wait a key, repaint.
BldDoShow
	LD	A,(ConsoleReady)
	OR	A
	JP	Z,BldV0
	CALL	BldSaveEditor
	CALL	ConsoleRestore
	CALL	BldWaitKode
	CALL	BldReInit
	JP	BldV0
;[]===========================================================[]
; Save-modified prompt. Out: A=0 continue, A=1 abort, A=2 save-then-resume.
BldAskSave
	LD	A,(BldSkip)
	OR	A
	JR	Z,BasAsk
	CALL	BldAnyMod		; save cancelled or failed: do not launch
	JR	NZ,BasAbort
	JR	BasCont
BasAsk
	CALL	BldAnyMod
	JR	Z,BasCont		; nothing modified
	CALL	BldPatchSure
	LD	HL,DsureWn
	CALL	DialogW
	LD	HL,what
	LD	A,(HL)
	INC	HL
	CP	evCommand
	JR	NZ,BasAbort
	LD	A,(HL)
	CP	cmYes
	JR	Z,BasSave
	CP	cmNo
	JR	Z,BasCont
BasAbort
	LD	A,#01
	RET
BasSave	LD	A,#01
	LD	(BldSkip),A
	LD	A,#02
	RET
BasCont	XOR	A
	RET
;[]===========================================================[]
; Any window modified? Walk TxtWtab (stride #26), test each window's
; ReadyFile (#8027, in that window's text page 1 at SLOT2). Z = none.
BldAnyMod
	IN	A,(SLOT2)
	PUSH	AF
	LD	IX,TxtWtab
BamLp	BIT	7,(IX+#00)
	JR	NZ,BamNone		; end of table
	LD	A,(IX+#1D)		; window's text page 1
	OUT	(SLOT2),A
	LD	A,(ReadyFile)
	OR	A
	JR	Z,BamMod		; 0 = modified
	LD	DE,#0026
	ADD	IX,DE
	JR	BamLp
BamMod	POP	AF
	OUT	(SLOT2),A
	LD	A,#01			; NZ = at least one modified
	OR	A
	RET
BamNone	POP	AF
	OUT	(SLOT2),A
	XOR	A			; Z = none
	RET
;[]===========================================================[]
; Patch DsureWn's SurName (PG1) with the fixed save prompt.
; SurName is a fixed 36-byte field inside the descriptor stream: the
; parser lands on the next object right after it, so bytes 0..34 must
; stay non-zero and the terminator belongs to the last byte only.
BldPatchSure
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	LD	DE,SurName
	LD	A,#20
	LD	B,35
BpsFill	LD	(DE),A
	INC	DE
	DJNZ	BpsFill
	XOR	A
	LD	(DE),A
	LD	HL,BldTxMod
	LD	DE,SurName
BpsCp	LD	A,(HL)
	OR	A
	JR	Z,BpsDone
	LD	(DE),A
	INC	HL
	INC	DE
	JR	BpsCp
BpsDone	POP	AF
	OUT	(SLOT2),A
	RET
;[]===========================================================[]
; Current window's full directory -> BldDirBuf (only roots keep trailing '\').
; No '\' -> empty (skip ChDir, use current DSS dir).
BldGetDir
	LD	A,(TxtWtab)
	BIT	7,A
	JR	NZ,BgdEmpty
	AND	#0F
	INC	A
	LD	B,A
	LD	HL,NameTab-#80
	LD	DE,#0080
BgdName	ADD	HL,DE
	DJNZ	BgdName
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	LD	DE,BldDirBuf
	LD	B,#7F
BgdRead	LD	A,(HL)
	RES	7,A
	LD	(DE),A
	INC	HL
	INC	DE
	OR	A
	JR	Z,BgdReadEnd
	DJNZ	BgdRead
	XOR	A
	LD	(DE),A
BgdReadEnd
	POP	AF
	OUT	(SLOT2),A
	LD	HL,BldDirBuf
	LD	DE,#0000
BgdSc	LD	A,(HL)
	OR	A
	JR	Z,BgdEnd
	CP	'\'
	JR	NZ,BgdNx
	LD	D,H
	LD	E,L
	INC	DE
BgdNx	INC	HL
	JR	BgdSc
BgdEnd	LD	A,D
	OR	E
	JR	NZ,BgdTrim
BgdEmpty
	XOR	A
	LD	(BldDirBuf),A
	RET
BgdTrim	EX	DE,HL
	LD	DE,BldDirBuf+3		; retain the slash in X:\ or \
	PUSH	HL
	OR	A
	SBC	HL,DE
	POP	HL
	JR	Z,BgdNul
	LD	DE,BldDirBuf+1
	PUSH	HL
	OR	A
	SBC	HL,DE
	POP	HL
	JR	Z,BgdNul
	DEC	HL			; DSS requires no trailing slash in subdirs
BgdNul	LD	(HL),#00
	LD	A,(BldDirBuf)
	CP	'a'
	RET	C
	CP	'z'+1
	RET	NC
	SUB	#20
	LD	(BldDirBuf),A
	RET
;[]===========================================================[]
; DOS sandwich: DOSpage->SLOT0, VG93 on, save cwd and enter the project dir.
; Dss.ChDir uses SLOT3 as a directory workspace. Its path must therefore live
; in resident SLOT1, and the call must return through resident BldDssTramp;
; passing BldDirBuf in SLOT3 directly makes LOADDIR replace both the argument
; and return code, causing the warm reset seen for subdirectories.
BldDosIn
	LD	(BldSavIY),IY		; save IY in memory, NOT on the stack: BldDosIn's
					; RET would otherwise pop the pushed IY (the POP is
					; stranded in BldDosOut). DSS calls clobber IY.
	IN	A,(SLOT3)		; capture DialogPg2 for BldDssTramp (SLOT0 still
	LD	(BldTrS3),A		; = KodeMain here; #08FE readable only pre-swap)
	IN	A,(SLOT0)
	LD	(BldSavS0),A
	LD	A,(DOSpage)
	OUT	(SLOT0),A
	LD	BC,#7FFD
	LD	A,#10
	OUT	(C),A			; enable VG93
	LD	HL,TempDirBuf
	CALL	SynCaptureDir		; resident buffer survives DSS paging
	LD	A,(BldDirBuf)
	OR	A
	RET	Z			; unnamed file - retain current cwd
	LD	HL,BldDirBuf
	CALL	BldCopyStable
	LD	C,Dss.ChDir
	CALL	BldDssTramp
	RET
BldDosOut
	LD	HL,TempDirBuf		; child may have changed cwd
	CALL	BldCopyStable
	LD	C,Dss.ChDir
	CALL	BldDssTramp
	JR	C,BdoErr
	XOR	A
BdoErr	LD	(BldRestoreErr),A
	LD	BC,#7FFD
	SUB	A
	OUT	(C),A			; VG93 off
	LD	A,(BldSavS0)
	OUT	(SLOT0),A
	LD	IY,(BldSavIY)		; restore Kode's IY (saved by BldDosIn in memory)
	RET
BldSavIY	DEFW	#0000
;[]===========================================================[]
; EXEC the built command line, wait for the child, report the exit code.
; Sets BldErrF: 1 = load error (child never ran), 0 = ran.
BldExecCon
	; EXEC keeps the command pointer until after it has used SLOT3 for PATH and
	; directory traversal. Keep the command in resident SLOT1 for that interval.
	LD	HL,BldCmdBuf
	CALL	BldCopyStable
	; VG93 is forced on (#7FFD=#10) for the file probes, but Dss.Exec repages
	; SLOT3 via #E2 and #7FFD also selects the #C000 page, so a forced #10
	; fights EXEC's paging -> the child loads mis-mapped and the machine
	; resets instantly. call_shell (FM) never sets #7FFD around EXEC. Disable
	; it only for the EXEC call, then restore #10 for BldDosOut's ChDir.
	LD	BC,#7FFD
	XOR	A
	OUT	(C),A
	LD	B,#00
	LD	C,Dss.Exec
	LD	(BldSavSP),SP		; belt-and-braces around the DSS process switch
	EI				; match FM call_shell: DSS/child run with IRQs on
	CALL	BldDssTramp
	DI				; back to Kode's interrupts-off after
	LD	SP,(BldSavSP)		; restore SP
	PUSH	AF			; keep EXEC's CF/error code
	LD	BC,#7FFD		; re-enable VG93 for the trailing ChDir/console
	LD	A,#10
	OUT	(C),A
	POP	AF
	JR	NC,BecOk
	LD	(BldErr),A
	LD	A,#01
	LD	(BldErrF),A
	RET
BecOk	LD	(BldErr),A		; EXEC already returns the child exit code
	XOR	A
	LD	(BldErrF),A
	LD	A,(BldErr)
	OR	A
	RET	Z			; success: return to Kode without a prompt
BecMsg	LD	HL,BldTxExit		; "Exit code "
	LD	DE,BldExMsg
	CALL	BldCopyZ
	LD	A,(BldErr)
	CALL	GetNUM8			; decimal at DE, advances DE
	LD	HL,BldTxPress		; " - press any key",CR,LF,0
	CALL	BldCopyZ
	LD	HL,BldExMsg
	LD	C,Dss.PChars
	CALL	BldDssTramp
	; NOTE: the key wait is NOT done here. Dss.WaitKey polls the DSS keyboard
	; buffer (HEAD/HOST), which only fills when the DSS interrupt handler runs
	; KEYSCAN - and that handler is gated off (#C127 in page #FE != #AA) while
	; Kode owns the machine, so Dss.WaitKey hangs forever. The caller waits via
	; Kode's own RST #30 poll (BldWaitKode) after leaving the DOS sandwich.
	RET
;[]===========================================================[]
; Copy an ASCIIZ string from HL to resident ReCompBuff (#7B00, SLOT1), then
; return HL=ReCompBuff. Keep FuncBuffer target lists intact across ChDir.
BldCopyStable
	LD	DE,ReCompBuff
BcsLp	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	OR	A
	JR	NZ,BcsLp
	LD	HL,ReCompBuff
	RET
;[]===========================================================[]
; Build "Exec error NNN" into BldExMsg and show it.
BldExecErrMsg
	LD	HL,BldTxErr		; "Exec error "
	LD	DE,BldExMsg
	CALL	BldCopyZ
	LD	A,(BldErr)
	CALL	GetNUM8
	XOR	A
	LD	(DE),A			; terminate
	LD	HL,BldExMsg
	JR	BldMessage
;[]===========================================================[]
; Copy ASCIIZ (HL)->(DE). Leaves DE AT the written NUL (so callers can
; overwrite it to append). Preserves nothing but is used sequentially.
BldCopyZ
	LD	A,(HL)
	LD	(DE),A
	OR	A
	RET	Z
	INC	HL
	INC	DE
	JR	BldCopyZ
;[]===========================================================[]
; Copy the Nth (#0D-separated) FuncBuffer entry to BldTgtName. In: A = index.
BldNthTgt
	LD	HL,BldTgtCnt
	CP	(HL)
	CCF
	RET	C
	LD	HL,FuncBuffer
	OR	A
	JR	Z,BntCp
	LD	B,A
BntSk	LD	A,(HL)
	INC	HL
	CP	#0D
	JR	NZ,BntSk
	DJNZ	BntSk
BntCp	LD	DE,BldTgtName
BntCp1	LD	A,(HL)
	CP	#0D
	JR	Z,BntEnd
	OR	A
	JR	Z,BntEnd
	LD	(DE),A
	INC	HL
	INC	DE
	JR	BntCp1
BntEnd	XOR	A
	LD	(DE),A
	RET
;[]===========================================================[]
; Show a one-line message via DbldMsg (patch BldMsgTxt in PG1). In: HL=ASCIIZ.
BldMessage
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(DialogPg1)
	OUT	(SLOT2),A
	PUSH	HL
	LD	HL,BldMsgTxt		; blank the 29-char field
	LD	B,#1D
	LD	A,#20
BmFill	LD	(HL),A
	INC	HL
	DJNZ	BmFill
	POP	HL
	LD	DE,BldMsgTxt		; copy text (without its NUL) over the blanks
BmCp	LD	A,(HL)
	OR	A
	JR	Z,BmDone
	LD	(DE),A
	INC	HL
	INC	DE
	JR	BmCp
BmDone	POP	AF
	OUT	(SLOT2),A
	LD	HL,DbldMsg
	JP	DialogW
;[]===========================================================[]
	INCLUDE "Console.asm"
;[]===========================================================[]
; Save the editor before either EXEC or Show log changes the video mode.
BldSaveEditor
	CALL	ResCurs
	LD	A,(MSbutt)		; retain the opening button until its release
	PUSH	AF
	LD	A,#02
	RST	#00
	POP	AF
	LD	(MSbutt),A
	LD	C,Dss.GetVMod
	CALL	ConDss
	LD	(BldSavVM),A
	LD	A,B
	LD	(BldSavVP),A
	JP	GetBuff
;[]===========================================================[]
; Poll explicitly with IRQs off: mouse packets and fresh PS/2 make events.
; Drain the opening event, ignore autorepeat, and consume the closing release.
BldWaitKode
	DI
	CALL	ScanDrv
	LD	A,#01
	RST	#30
	CALL	BldMouseUp
	LD	A,(ScanPress)
	LD	(BldWaitPress),A
BwkLp	CALL	ScanDrv
	CALL	GetMousInfo
	LD	A,(MSbutt)
	AND	#03
	JR	NZ,BwkDone
	LD	A,(BldWaitPress)
	LD	HL,ScanPress
	CP	(HL)
	JR	Z,BwkLp
BwkDone	CALL	ScanDrv
	LD	A,(ScanDown)
	OR	A
	JR	NZ,BwkDone
	CALL	BldMouseUp
	JP	InitEvent
;[]===========================================================[]
; Re-init video / mouse / scancode after a child (mirror the KodeStart tail).
BldReInit
	CALL	BldRestoreVM		; resident wrapper returns with IRQs off
	LD	A,#01
	OUT	(RGMOD),A
	LD	A,#C0
	OUT	(PORT_Y),A
	XOR	A
	OUT	(BorderColor),A
	; Re-establish Kode's 80x32 screen window exactly as KodeStart does. The DSS
	; console disturbs the screen geometry; without this the editor redraws with
	; the wrong layout (doubled text, missing menu bar). #89 = clear/define
	; window, HL = #2050 (32 rows x 80 cols), DE = origin, B = 0.
	LD	HL,#2050
	LD	D,#00
	LD	E,D
	LD	B,D
	LD	C,#89
	RST	#10
	XOR	A
	RST	#00			; mouse init
	XOR	A
	RST	#30			; scancode init
	LD	A,#01
	RST	#00			; mouse tracks screen
	CALL	InitEvent		; clear stale key/event and refresh mouse state
	CALL	InitBar			; restore rows outside the work-area buffer
	CALL	ResMBar			; InitBar selects File; return to inactive desktop
	CALL	InitStLine
	CALL	PutBuff			; restore the editor work area saved before EXEC
	CALL	SetCurs
	RET
;[]===========================================================[]
; Engine data (Dialog_Windows_PG2)
BldAct		DEFB	#00
BldSkip		DEFB	#00		; 1 = save prompt already answered
BldBRmode	DEFB	#00		; 0 Build / 1 Run
BldFound	DEFB	#00		; 0 found, 1 absent, 2 I/O error, 3 ChDir error
BldErrF		DEFB	#00		; 1 = Exec load error
BldErr		DEFB	#00		; exec error / child exit code
BldNoMk		DEFB	#00
BldTgtCnt	DEFB	#00
BldRestoreErr	DEFB	#00
BldSavS0	DEFB	#00
BldSavSP	DEFW	#0000		; SP saved across Dss.Exec (child may corrupt it)
BldSavVM	DEFB	#00		; Kode's video mode, saved around a child
BldSavVP	DEFB	#00		; Kode's screen page, saved around a child
BldDirBuf	DEFS	128,0		; "X:\DIR\",0 (or empty)
BldTgtName	DEFS	25,0
BldExMsg	DEFS	40,0		; "Exit code NNN - press any key"

BldTxExit	DEFB	"Exit code ",0
BldTxPress	DEFB	" - press any key",#0D,#0A,0
BldTxErr	DEFB	"Exec error ",0
BldNMkSp	DEFB	"MAKE.EXE ",0
BldTxMod	DEFB	"    Modified files exist.",0
BldMIo		DEFB	"File I/O error",0
BldMDir		DEFB	"Cannot enter project dir",0
BldMCwd		DEFB	"Cannot restore directory",0
BldMNoBuild	DEFB	"No BUILD.BAT or MAKEFILE",0
BldMNoMake	DEFB	"No MAKEFILE",0
BldMNoRun	DEFB	"No RUN.BAT or run target",0
BldMNoTgt	DEFB	"MAKEFILE has no targets",0
;[]===========================================================[]
	INCLUDE	"BuildScan.asm"
;[]===========================================================[]
