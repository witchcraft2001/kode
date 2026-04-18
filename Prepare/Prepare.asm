 _mCollectInfo_addStart
;
 MODULE KODE_PREPARE

	; Ifndef _includedsp2000
	; Include 'shared_includes/constants/sp2000.inc'
	; Include 'shared_includes/constants/bios_equ.inc'
	; Include 'shared_includes/constants/dss_equ.inc'
	; Org #9000
	; Endif

Buffer	EQU	$-#1000

	LD	(sp_save),SP
	LD	SP,Prepare.stackPoint

	LD	DE,#1F00
	LD	C,BIOS.LP_SET_PLACE				; Setup current in
	RST	ToBIOS

	LD	HL,STRING
	LD	BC,#50*256 + BIOS.LP_PRINT_LINE6		; On screen without
	LD	D,0
	RST	ToBIOS

	CALL	GEN_PALETTE_ONE
;
; [ ]
	LD	HL,Buffer					; Data palette
	LD	DE,#0000					; Count and color
	LD	BC,#FF*256 + BIOS.PIC_SET_PAL			; Setup palette
	LD	A,4					; Number palette
	RST	ToBIOS

	LD	HL,Buffer					; Data palette
	LD	DE,#0000					; Count and color
	LD	BC,#FF*256 + BIOS.PIC_SET_PAL			; Setup palette
	LD	A,6					; Number palette
	RST	ToBIOS

	LD	HL,Buffer + #200				; Data palette
	LD	DE,#8080					; Count and color
	LD	BC,#FF*256 + BIOS.PIC_SET_PAL			; Setup palette
	LD	A,7					; Number palette
	RST	ToBIOS
;---------------------------------------------------------[]
;
	CALL	GEN_PALETTE_TWO
;
; [ ]
	LD	HL,Buffer					; Data palette
	LD	DE,#0000					; Count and color
	LD	BC,#FF*256 + BIOS.PIC_SET_PAL			; Setup palette
	LD	A,5					; Number palette
	RST	ToBIOS

	LD	HL,Buffer					; Data palette
	LD	DE,#8000					; Count and color
	LD	BC,#FF*256 + BIOS.PIC_SET_PAL			; Setup palette
	LD	A,7					; Number palette
	RST	ToBIOS
;---------------------------------------------------------[]
/*
; DE
WIN_GET_ZG:
	LD HL,ZG_ADRESS
	LD BC,#0800
	LDIR
	AND A
	RET
*/
; !FIXIT and not from - can BIOS.WIN_GET_ZG
	SUB	A
	OUT	(SYS_PORT.ON),A

	LD	DE,Buffer                                             ; Pointer on 2Kb data for font from
	PUSH    DE
        LD      C,BIOS.WIN_GET_ZG
        RST     ToBIOS_18
        
	SUB	A
	OUT	(SYS_PORT.OFF),A
;
; [] for #8600..87FF #FF
	LD	HL,Buffer + #600
	LD	A,#FF
.loop1:	LD	(HL),A
	INC	H
	LD	(HL),A
	DEC	H
	INC	L
	JR	NZ,.loop1
;--[]
;
	POP	DE					; Pointer on 2Kb data font
	LD	A,#5B					; Number font
	LD	C,BIOS.WIN_SET_ZG				; Setup font
	RST	ToBIOS

;
; [] for #8000..87FF #FF
	LD	HL,Buffer					; Pointer on 2Kb data font
	LD	BC,#0800
	LD	E,#FF
	PUSH	HL

.loop2:	LD	(HL),E
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,.loop2
;--[]
;
	POP	DE					; Pointer on 2Kb data font
	LD	A,#9B					; Number font
	LD	C,BIOS.WIN_SET_ZG				; Setup font
	RST	ToBIOS

sp_save+1:	
	LD	SP,0
	RET

GEN_PALETTE_ONE:
	LD	HL,PALETTE
	LD	DE,Buffer
	LD	C,#08

.loop1:	LD	B,#10
.loop2:	PUSH	BC
	PUSH	HL
	LDI
	LDI
	LDI
	LDI
	POP	HL
	POP	BC
	DJNZ	.loop2
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	DEC	C
	JR	NZ,.loop1

	LD	HL,Buffer
	LD	BC,#0200
	LDIR
	RET

GEN_PALETTE_TWO:
	LD	HL,PALETTE
	LD	DE,Buffer
	LD	B,#08
.loop5:	PUSH	BC
	PUSH	HL
	LD	BC,#0040
	LDIR
	POP	HL
	POP	BC
	DJNZ	.loop5

	LD	HL,Buffer
	LD	BC,#0200
	LDIR
	RET

PALETTE:	DZ	#00, #00, #00
		DZ	#A8, #00, #00
		DZ	#00, #A8, #00
		DZ	#A8, #A8, #00
		DZ	#00, #00, #A8
		DZ	#A8, #00, #A8
		DZ	#00, #54, #A8
		DZ	#A8, #A8, #A8
		DZ	#54, #54, #54
		DZ	#FC, #54, #54
		DZ	#54, #FC, #54
		DZ	#FC, #FC, #54
		DZ	#54, #54, #FC
		DZ	#FC, #54, #FC
		DZ	#54, #FC, #FC
		DZ	#FC, #FC, #FC


STRING:	DZ	'Kode v ',_progVERSION,', Sprinter Team, ',_luaBUILD_DATEfull

 ENDMODULE
;
 _mCollectInfo_addEnd
