; Target fixture: print one marker, then return a nonzero exit code.
	ORG #0000
	BYTE 'EXE',1
	DWORD #0200
	WORD End-Code,0,0,0,#4000,#4000,#7FFF
	BLOCK #0200-$,0
	DISP #4000
Code	LD	HL,Message
	LD	C,#5C
	RST	#10
	LD	BC,#0741
	RST	#10
Message	BYTE 'TARGET_PASS',13,10,0
End	ENT
