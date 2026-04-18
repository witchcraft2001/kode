 _mCollectInfo_addStart
;
;[]================================================================================[]
; Main block Kode located: #0000 - #79FF
; Buffers editor: #7A00 - #7F1F
; Machine stack: #7F20 - #7FFF
; Text pages: #8000 - #FFFF (32kb)
;[]================================================================================[]

; Kode BIOS from #0000

	IFNDEF NEW_VERSION : DEFINE NEW_VERSION 1 : ENDIF
	IF NEW_VERSION : DEFINE NEW_ADDR #4000 : ELSE : DEFINE NEW_ADDR 0 : ENDIF

rst00:	JP	MousDrv	; Rst 00h mouse driver
	BLOCK 8-$, #FF

rst08:	DI		; Rst 08h bios calls
	PUSH	AF
	SUB	A
	OUT	(SYS_PORT.ON),A
	POP	AF
	DI 
	RET
	BLOCK #10-$, #FF	

rst10:	DI 
	EX	AF,AF'
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT2),A
	LD	(SaveSP+1),SP
	LD	SP,#BFFF
	EX	AF,AF'
	RST	#08
	EX	AF,AF'
SaveSP:	LD	SP,#0000
	POP	AF
	OUT	(SLOT2),A
	EX	AF,AF'
	EI 
	RET 
	BLOCK #30-$, #FF

rst30:	JP	KeybDrv	; Rst 30h keyboard driver
	BLOCK #38-$, #FF

rst38:	DI 
	PUSH	IY	; Rst 38h main interrupt
	PUSH	IX
	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	EX	AF,AF'
	EXX 
	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	CALL	ScanDrv
KeybFlg:	LD	A,#00
	OR	A
	JR	NZ,IntExit
	LD	A,(MousFlg)
	OR	A
	CALL	NZ,Refresh
	LD	A,(CurILFl)
	OR	A
	CALL	NZ,PrnILCr
	LD	A,(CurFlag)
	OR	A
	CALL	NZ,PrnCurs
IntExit:
	POP	AF
	POP	BC
	POP	DE
	POP	HL
	EXX 
	EX	AF,AF'
	POP	AF
	POP	BC
	POP	DE
	POP	HL
	POP	IX
	POP	IY
	EI 
	RETI 

; Cursor about' InputLine
PrnILCr:
	LD	A,(Timer)														; Delay blink
	DEC	A
	CALL	Z,PutILCr
	LD	(Timer),A
	RET 

CurILFl:	BYTE	#00													; Flag 00-disable/01-enable
Timer:	BYTE	#01													; Timer
Flag:	BYTE	#00													; Flag 00-none/01
CursPos:	WORD	#0000												; Position

PutILCr	LD	A,(Flag)
	CPL 
	LD	(Flag),A
PILCurs	LD	DE,(CursPos)
	LD	(CrPs+1),DE
	BIT	7,E
	JR	NZ,cre
	LD	A,E
	CP	#50
	JR	NC,cre
	LD	A,D
	CP	#1F
	JR	NC,cre
	LD	C,#B4
	SUB	A
	CALL	Rst10t
	LD	A,(Flag)
	OR	A
	LD	B,#1B
	JR	Z,NoILC
	LD	B,#5B
	LD	A,(InsertMode)
	RRA 
	JR	C,NoILC
	LD	B,#9B
NoILC	LD	C,#B5
	SUB	A
	CALL	Rst10t
cre	LD	A,#01
	LD	(CurILFl),A
	LD	A,#0C
	RET 

ResILCr	LD	A,(CurILFl)
	OR	A
	RET	Z
	LD	A,#FF
	LD	(Flag),A
	INC	A
	LD	(CurILFl),A
	LD	A,#0C
	LD	(Timer),A
CrPs	LD	DE,#0000
	BIT	7,E
	RET	NZ
	LD	A,E
	CP	#50
	RET	NC
	LD	A,D
	CP	#1F
	RET	NC
	LD	C,#B4
	SUB	A
	RST	#10
	LD	B,#1B
	LD	C,#B5
	SUB	A
	RST	#10
	RET 

; Cursor text window
PrnCurs	LD	A,(Timer)
	DEC	A
	CALL	Z,PutCurs
	LD	(Timer),A
	RET 

CurFlag	DEFB	#00					; 00-disable/01-enable

PutCurs	LD	A,(Flag)
	CPL 
	LD	(Flag),A
	PUSH	IX
	LD	IX,TxtWtab
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(IX+#1D)				;1text page
	OUT	(SLOT2),A
CursPXY	LD	DE,#0000					;Cursor pos
	LD	A,D
	INC	A
	CP	(IX+#04)
	JR	NC,SetCext				; Window
	LD	A,E
	BIT	7,A					; Screen
	JR	NZ,SetCext
	CP	#50
	JR	NC,SetCext				; Screen
	INC	A
	CP	(IX+#02)
	JR	NC,SetCext
	LD	A,D
	CP	#1F
	JR	NC,SetCext				; Screen
	LD	C,#B4
	SUB	A
	CALL	Rst10t
	LD	A,(Flag)
	OR	A
	LD	B,#1B
	JR	Z,NoCurs
	LD	B,#5B
	LD	A,(InsertMode)
	RRA 
	JR	C,NoCurs
	LD	B,#9B
NoCurs	LD	C,#B5
	SUB	A
	CALL	Rst10t
SetCext	POP	AF
	OUT	(SLOT2),A
	POP	IX
	LD	A,#0C
	RET 
Rst10t	EX	AF,AF'
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(BuffPg5)
	OUT	(SLOT2),A
	LD	(SaveSP1),SP
	LD	SP,#BFFF
	EX	AF,AF'
	RST	#08
SaveSP1+1: LD	SP,#0000
	POP	AF
	OUT	(SLOT2),A
	RET 

; Cursor on screen
SetCurs	LD	A,(CurFlag)
	OR	A
	RET	NZ
	PUSH	IX
	LD	IX,TxtWtab
	IN	A,(SLOT2)
	PUSH	AF
	LD	A,(IX+#1D)				;1text page
	OUT	(SLOT2),A
	LD	HL,(UpLinePg)
	LD	BC,(CurLine)
	LD	A,L
	ADD	A,(IY+#06)
	LD	E,A
	LD	A,H
	ADC	A,#00
	LD	D,A
	OR	A
	EX	DE,HL
	SBC	HL,BC
	JR	Z,SCex
	JR	C,SCex
	ADD	HL,BC
	EX	DE,HL
	OR	A
	SBC	HL,BC
	JR	Z,$+4
	JR	NC,SCex
	LD	A,(IY+#00)				; Xpos.window
	CP	#FF			
	JR	Z,SCex			
	ADD	A,(IX+#01)				; Xpos window
	INC	A			
	LD	E,A			
	LD	A,(IY+#01)				; Ypos.window
	ADD	A,(IX+#03)				; Ypos window
	INC	A			
	LD	D,A			
	LD	(CursPXY+1),DE			
	INC	A			
	CP	(IX+#04)			
	JR	NC,SetCurE				; Window
	LD	A,E			
	BIT	7,A					; Screen
	JR	NZ,SetCurE			
	CP	#50			
	JR	NC,SetCurE				; Screen
	INC	A			
	CP	(IX+#02)			
	JR	NC,SetCurE			
	LD	A,D			
	CP	#1F			
	JR	NC,SetCurE				; Screen
	LD	C,#B4
	SUB	A
	RST	#10
	LD	B,#5B
	LD	A,(InsertMode)
	RRA 
	JR	C,$+4
	LD	B,#9B
	LD	C,#B5
	SUB	A
	RST	#10
SetCurE	LD	A,#01
	LD	(CurFlag),A
	LD	A,#0C
	LD	(Timer),A
SCex	POP	AF
	OUT	(SLOT2),A
	POP	IX
	RET 
; Disable cursor
ResCurs	LD	A,(CurFlag)
	OR	A
	RET	Z
	LD	A,#FF
	LD	(Flag),A
	INC	A
	LD	(CurFlag),A
	LD	A,#0C
	LD	(Timer),A
	LD	DE,(CursPXY+1)
	LD	A,E
	BIT	7,A					; Screen
	RET	NZ			
	CP	#50			
	RET	NC					; Internal operation
	LD	A,D			
	CP	#1F			
	RET	NC					; Screen
	PUSH	IX
	PUSH	BC
	LD	C,#B4
	SUB	A
	RST	#10
	LD	B,#1B
	LD	C,#B5
	SUB	A
	RST	#10
	POP	BC
	POP	IX
	RET 

	INCLUDE	'KeybDrv.asm'
	INCLUDE	'MouseDrv.asm'
	INCLUDE	'MainUNIT.asm'
	INCLUDE	'DeskTop.asm'
	INCLUDE	'DeskTop2.asm'
	INCLUDE	'Windows.asm'
	INCLUDE	'TextEdit.asm'
	INCLUDE	'TextEdit2.asm'
	INCLUDE	'TextEdit3.asm'
	INCLUDE	'SyntaxExt.asm'
	INCLUDE	'Function.asm'
	INCLUDE	'Function2.asm'
	INCLUDE	'Function3.asm'
	INCLUDE	'TextIO.asm'
FILLend_KodeMain	EQU $
;---------------------------------------------------------------------/*/
 ; !fixit
	; Include "asm2pass.z80",#18
	; Include "asm2pass2.z80",#19
	; Include "asm2pass3.z80",#1a
 ; !fixit
 _mCollectInfo_addEnd
