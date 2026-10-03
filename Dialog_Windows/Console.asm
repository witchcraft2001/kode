; Shared console snapshot, also assembled in the initial EXE loader.
; ConDss and ConCopy are resident wrappers; state stays with the caller.
ConsoleGrab
	LD	C,Dss.GetVMod
	CALL	ConDss
	LD	(ConsoleMode),A
	LD	A,B
	LD	(ConsolePage),A
	LD	C,Dss.Cursor
	CALL	ConDss			; before BIOS copy moves the cursor
	LD	(ConsolePos),DE
	LD	C,#B2
	CALL	ConCopy
	CALL	ConsoleLocate
	LD	A,#01
	LD	(ConsoleReady),A
	RET
ConsoleRestore
	LD	A,(ConsoleReady)
	OR	A
	RET	Z
	LD	A,(ConsolePage)
	LD	B,A
	LD	A,(ConsoleMode)
	LD	C,Dss.SetVMod
	CALL	ConDss
	LD	C,#B3
	CALL	ConCopy
ConsoleLocate
	LD	DE,(ConsolePos)
	LD	C,Dss.Locate
	JP	ConDss			; cursor is restored last
ConsoleState
ConsoleReady	DEFB	#00
ConsoleMode	DEFB	#03
ConsolePage	DEFB	#00
ConsolePos	DEFW	#0000
ConsoleStateEnd
