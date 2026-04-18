 _mCollectInfo_addStart
; Org #c000

; Byte "rl (iy+",0,") "
; BYTE #FD,#CB,#00,#16
; BYTE #04,#03,#02; commands; number in PASS1tab; ?
;
; Operands id:
; 0 -
; 1 -
; 2 - 8 bit jump operand (jr, djnz)
; 3 -
; 4 -
; 5 -
; 6 -
; 7 -
;
;
; Cmd_tbl.chr.
; Cmd_tbl.cmd.

 MODULE CMD_TBL

; Disp #c000
_m_start	EQU	$

CHR:

.A:	BYTE	#03,"ADD   ",#20,#1B
	WORD	CMD.add
	BYTE	#03,"ADC   ",#20,#13
	WORD	CMD.adc
	BYTE	#03,"AND   ",#20,#0F
	WORD	CMD.And
	BYTE	#05,"ACOFF ",#20,#00
	WORD	CMD.acoff
	BYTE	#00,"      ",#20,#00
	WORD	#0000
	BYTE	#00,"      ",#20,#00
	WORD	#0000
	BYTE	#00,"      ",#20,#00
	WORD	#0000
	BYTE	#00,"      ",#20,#00
	WORD	#0000

.B:	BYTE	#03,"BIT   ",#20,#0A
	WORD	CMD.bit
	BYTE	#00,"      ",#20,#00
	WORD	#0000
	BYTE	#00,"      ",#20,#00
	WORD	#0000
	BYTE	#00,"      ",#20,#00
	WORD	#0000
	BYTE	#00,"      ",#20,#00
	WORD	#0000

.C:	BYTE	#02,"CP    ",#20,#0F
	WORD	CMD.cp
	BYTE	#03,"CPD   ",#20,#00
	WORD	CMD.cpd
	BYTE	#04,"CPDR  ",#20,#00
	WORD	CMD.cpdr
	BYTE	#03,"CPI   ",#20,#00
	WORD	CMD.cpi
	BYTE	#04,"CPIR  ",#20,#00
	WORD	CMD.cpir
	BYTE	#03,"CPL   ",#20,#00
	WORD	CMD.cpl
	BYTE	#03,"CCF   ",#20,#00
	WORD	CMD.ccf
	BYTE	#04,"CALL  ",#20,#09
	WORD	CMD.call
	BYTE	#05,"COUNT ",#20,#00
	WORD	CMD.Count
	BYTE	#04,"COPY  ",#20,#00
	WORD	CMD.copy
	BYTE	#00,"      ",#20,#00
	WORD	#0000
	BYTE	#00,"      ",#20,#00
	WORD	#0000
	BYTE	#00,"      ",#20,#00
	WORD	#0000
	BYTE	#00,"      ",#20,#00
	WORD	#0000

.D:	BYTE	#02,"DI    ",#20,#00
	WORD	CMD.di
	BYTE	#03,"DAA   ",#20,#00
	WORD	CMD.daa
	BYTE	#04,"DJNZ  ",#20,#01
	WORD	CMD.djnz
	BYTE	#03,"DEC   ",#20,#14
	WORD	CMD.dec
	BYTE	#03,"DUP   ",#20,#01
	WORD	CMD.dup
	BYTE	#04,"DEFB  ",#80,#01
	WORD	CMD.defb
	BYTE	#04,"DEFW  ",#20,#01
	WORD	CMD.defw
	BYTE	#04,"DEFD  ",#20,#01
	WORD	CMD.defd
	BYTE	#04,"DEFS  ",#20,#01
	WORD	CMD.defs
	BYTE	#02,"DB    ",#80,#01
	WORD	CMD.db
	BYTE	#02,"DW    ",#20,#01
	WORD	CMD.dw
	BYTE	#02,"DD    ",#20,#01
	WORD	CMD.dd
	BYTE	#02,"DS    ",#20,#01
	WORD	CMD.ds
	BYTE	#00,"      ",#20,#00
	WORD	#0000
	BYTE	#00,"      ",#20,#00
	WORD	#0000
	BYTE	#00,"      ",#20,#00
	WORD	#0000
	BYTE	#00,"      ",#20,#00
	WORD	#0000

.E:	BYTE	#03,"EQU    ",#01
	WORD	CMD.equ
	BYTE	#04,"EDUP   ",#00
	WORD	CMD.edup
	BYTE	#02,"EI     ",#00
	WORD	CMD.ei
	BYTE	#03,"EXX    ",#00
	WORD	CMD.exx
	BYTE	#02,"EX     ",#05
	WORD	CMD.ex
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.F:	BYTE	#04,"FILL   ",#00
	WORD	CMD.fill
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.G:	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.H:	BYTE	#04,"HALT   ",#00
	WORD	CMD.halt
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.I:	BYTE	#02,"IM     ",#01
	WORD	CMD.im
	BYTE	#03,"INC    ",#14
	WORD	CMD.inc
	BYTE	#03,"IND    ",#00
	WORD	CMD.ind
	BYTE	#04,"INDR   ",#00
	WORD	CMD.indr
	BYTE	#03,"INI    ",#00
	WORD	CMD.ini
	BYTE	#04,"INIR   ",#00
	WORD	CMD.inir
	BYTE	#02,"IN     ",#08
	WORD	CMD.in
	BYTE	#03,"INF    ",#00
	WORD	CMD.inf
	BYTE	#07,"INCLUDE",#01
	WORD	CMD.Include
	BYTE	#06,"INCBIN ",#01
	WORD	CMD.Incbin
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.J:	BYTE	#02,"JR     ",#05
	WORD	CMD.jr
	BYTE	#02,"JP     ",#0C
	WORD	CMD.jp
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.K:	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.L:	BYTE	#03,"LDD    ",#00
	WORD	CMD.Ldd
	BYTE	#04,"LDDR   ",#00
	WORD	CMD.Lddr
	BYTE	#03,"LDI    ",#00
	WORD	CMD.Ldi
	BYTE	#04,"LDIR   ",#00
	WORD	CMD.Ldir
	BYTE	#02,"LD     ",#8B
	WORD	CHR.Lpl
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.Lpl:	BYTE	"A",#14
	WORD	CMD.ld_a
	BYTE	"B",#11
	WORD	CMD.ld_b
	BYTE	"C",#0F
	WORD	CMD.ld_c
	BYTE	"D",#11
	WORD	CMD.ld_d
	BYTE	"E",#0F
	WORD	CMD.ld_e
	BYTE	"H",#1D
	WORD	CMD.ld_h
	BYTE	"L",#1B
	WORD	CMD.ld_l
	BYTE	"(",#21
	WORD	CMD.ld_SK
	BYTE	"S",#05
	WORD	CMD.ld_s
	BYTE	"I",#05
	WORD	CMD.ld_i
	BYTE	"R",#01
	WORD	CMD.ld_r

.M:	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.N:	BYTE	#03,"NOP    ",#00
	WORD	CMD.Nop
	BYTE	#03,"NEG    ",#00
	WORD	CMD.Neg
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.O:	BYTE	#03,"ORG    ",#01
	WORD	CMD.Org
	BYTE	#02,"OR     ",#0F
	WORD	CMD.Or
	BYTE	#03,"OUT    ",#09
	WORD	CMD.out
	BYTE	#04,"OUTD   ",#00
	WORD	CMD.outd
	BYTE	#04,"OTDR   ",#00
	WORD	CMD.otdr
	BYTE	#04,"OUTI   ",#00
	WORD	CMD.outi
	BYTE	#04,"OTIR   ",#00
	WORD	CMD.otir
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.P:	BYTE	#05,"PHASE  ",#01
	WORD	CMD.phase
	BYTE	#04,"PUSH   ",#06
	WORD	CMD.push
	BYTE	#03,"POP    ",#06
	WORD	CMD.pop
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.Q:	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.R:	BYTE	#04,"RETN   ",#00
	WORD	CMD.retn
	BYTE	#04,"RETI   ",#00
	WORD	CMD.reti
	BYTE	#03,"RET  ",#80,#20,#09
	WORD	CMD.ret
	BYTE	#03,"RST    ",#01
	WORD	CMD.rst
	BYTE	#03,"RLD    ",#00
	WORD	CMD.rld
	BYTE	#03,"RRD    ",#00
	WORD	CMD.rrd
	BYTE	#04,"RLCA   ",#00
	WORD	CMD.rlca
	BYTE	#03,"RLC    ",#0A
	WORD	CMD.rlc
	BYTE	#04,"RRCA   ",#00
	WORD	CMD.rrca
	BYTE	#03,"RRC    ",#0A
	WORD	CMD.rrc
	BYTE	#03,"RLA    ",#00
	WORD	CMD.rla
	BYTE	#02,"RL     ",#0A
	WORD	CMD.rl
	BYTE	#03,"RRA    ",#00
	WORD	CMD.rra
	BYTE	#02,"RR     ",#0A
	WORD	CMD.rr
	BYTE	#03,"RES    ",#0A
	WORD	CMD.res
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.S:	BYTE	#03,"SCF    ",#00
	WORD	CMD.scf
	BYTE	#03,"SUB    ",#0F
	WORD	CMD.sub
	BYTE	#03,"SBC    ",#13
	WORD	CMD.sbc
	BYTE	#03,"SLA    ",#0A
	WORD	CMD.sla
	BYTE	#03,"SRA    ",#0A
	WORD	CMD.sra
	BYTE	#03,"SLI    ",#0A
	WORD	CMD.sli
	BYTE	#03,"SRL    ",#0A
	WORD	CMD.srl
	BYTE	#03,"SET    ",#0A
	WORD	CMD.set
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.T:	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.U:	BYTE	#07,"UNPHASE",#00
	WORD	CMD.unphase
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.V:	BYTE	#05,"VFILL  ",#00
	WORD	CMD.vfill
	BYTE	#05,"VCOPY  ",#00
	WORD	CMD.vcopy
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.W:	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.X:	BYTE	#03,"XOR    ",#0F
	WORD	CMD.Xor
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.Y:	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

.Z:	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000
	BYTE	#00,"       ",#00
	WORD	#0000

; ===============================================================
;

	; Include "comma-j.z80",#09
	; Include "comml-r.z80",#0a
	; Include "comms-x.z80",#0b

;
; [] [] [] [] [] [] []
; [] [] [] [] [] [] []
; [] [] [] [] [] [] []
;

; Format data
; 00..11 - command
; 12..15 - commands
; 16 - commands
; 17 -;number handler; ?????
; 18 (3..0) - number handler prog001 - prog015

; Comma-j.z80
;===============================================================
CMD:

.add:	BYTE	"ADD A,A     "
	BYTE	#87,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"ADD A,B     "
	BYTE	#80,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"ADD A,C     "
	BYTE	#81,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"ADD A,D     "
	BYTE	#82,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"ADD A,E     "
	BYTE	#83,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"ADD A,H     "
	BYTE	#84,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"ADD A,L     "
	BYTE	#85,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"ADD A,HX    "
	BYTE	#DD,#84,#00,#00
	BYTE	#02,#00,#40
	BYTE	"ADD A,HY    "
	BYTE	#FD,#84,#00,#00
	BYTE	#02,#00,#40
	BYTE	"ADD A,LX    "
	BYTE	#DD,#85,#00,#00
	BYTE	#02,#00,#40
	BYTE	"ADD A,LY    "
	BYTE	#FD,#85,#00,#00
	BYTE	#02,#00,#40
	BYTE	"ADD A,(HL)  "
	BYTE	#86,#00,#00,#00
	BYTE	#01,#00,#60

	BYTE	"ADD HL,BC   "
	BYTE	#09,#00,#00,#00
	BYTE	#01,#00,#50
	BYTE	"ADD HL,DE   "
	BYTE	#19,#00,#00,#00
	BYTE	#01,#00,#50
	BYTE	"ADD HL,HL   "
	BYTE	#29,#00,#00,#00
	BYTE	#01,#00,#50
	BYTE	"ADD HL,SP   "
	BYTE	#39,#00,#00,#00
	BYTE	#01,#00,#50
	BYTE	"ADD IX,BC   "
	BYTE	#DD,#09,#00,#00
	BYTE	#02,#00,#50
	BYTE	"ADD IX,DE   "
	BYTE	#DD,#19,#00,#00
	BYTE	#02,#00,#50
	BYTE	"ADD IX,IX   "
	BYTE	#DD,#29,#00,#00
	BYTE	#02,#00,#50
	BYTE	"ADD IX,SP   "
	BYTE	#DD,#39,#00,#00
	BYTE	#02,#00,#50
	BYTE	"ADD IY,BC   "
	BYTE	#FD,#09,#00,#00
	BYTE	#02,#00,#50
	BYTE	"ADD IY,DE   "
	BYTE	#FD,#19,#00,#00
	BYTE	#02,#00,#50
	BYTE	"ADD IY,IY   "
	BYTE	#FD,#29,#00,#00
	BYTE	#02,#00,#50
	BYTE	"ADD IY,SP   "
	BYTE	#FD,#39,#00,#00
	BYTE	#02,#00,#50

	BYTE	"ADD A,(IX+",0,")"
	BYTE	#DD,#86,#00,#00
	BYTE	#02,#03,#05
	BYTE	"ADD A,(IY+",0,")"
	BYTE	#FD,#86,#00,#00
	BYTE	#02,#03,#05
	BYTE	"ADD A,",0,"     "
	BYTE	#C6,#00,#00,#00
	BYTE	#01,#00,#03

.adc:	BYTE	"ADC A,A     "
	BYTE	#8F,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"ADC A,B     "
	BYTE	#88,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"ADC A,C     "
	BYTE	#89,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"ADC A,D     "
	BYTE	#8A,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"ADC A,E     "
	BYTE	#8B,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"ADC A,H     "
	BYTE	#8C,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"ADC A,L     "
	BYTE	#8D,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"ADC A,HX    "
	BYTE	#DD,#8C,#00,#00
	BYTE	#02,#00,#40
	BYTE	"ADC A,HY    "
	BYTE	#FD,#8C,#00,#00
	BYTE	#02,#00,#40
	BYTE	"ADC A,LX    "
	BYTE	#DD,#8D,#00,#00
	BYTE	#02,#00,#40
	BYTE	"ADC A,LY    "
	BYTE	#FD,#8D,#00,#00
	BYTE	#02,#00,#40
	BYTE	"ADC A,(HL)  "
	BYTE	#8E,#00,#00,#00
	BYTE	#01,#00,#60

	BYTE	"ADC HL,BC   "
	BYTE	#ED,#4A,#00,#00
	BYTE	#02,#00,#50
	BYTE	"ADC HL,DE   "
	BYTE	#ED,#5A,#00,#00
	BYTE	#02,#00,#50
	BYTE	"ADC HL,HL   "
	BYTE	#ED,#6A,#00,#00
	BYTE	#02,#00,#50
	BYTE	"ADC HL,SP   "
	BYTE	#ED,#7A,#00,#00
	BYTE	#02,#00,#50
	BYTE	"ADC A,(IX+",0,")"
	BYTE	#DD,#8E,#00,#00
	BYTE	#02,#03,#05
	BYTE	"ADC A,(IY+",0,")"
	BYTE	#FD,#8E,#00,#00
	BYTE	#02,#03,#05
	BYTE	"ADC A,",0,"     "
	BYTE	#CE,#00,#00,#00
	BYTE	#01,#00,#03

.And:	BYTE	"AND A       "
	BYTE	#A7,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"AND B       "
	BYTE	#A0,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"AND C       "
	BYTE	#A1,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"AND D       "
	BYTE	#A2,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"AND E       "
	BYTE	#A3,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"AND H       "
	BYTE	#A4,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"AND HX      "
	BYTE	#DD,#A4,#00,#00
	BYTE	#02,#00,#20
	BYTE	"AND HY      "
	BYTE	#FD,#A4,#00,#00
	BYTE	#02,#00,#20
	BYTE	"AND L       "
	BYTE	#A5,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"AND LX      "
	BYTE	#DD,#A5,#00,#00
	BYTE	#02,#00,#20
	BYTE	"AND LY      "
	BYTE	#FD,#A5,#00,#00
	BYTE	#02,#00,#20
	BYTE	"AND (HL)    "
	BYTE	#A6,#00,#00,#00
	BYTE	#01,#00,#40
	BYTE	"AND (IX+",0,")  "
	BYTE	#DD,#A6,#00,#00
	BYTE	#02,#03,#02
	BYTE	"AND (IY+",0,")  "
	BYTE	#FD,#A6,#00,#00
	BYTE	#02,#03,#02
	BYTE	"AND ",0,"       "
	BYTE	#E6,#00,#00,#00
	BYTE	#01,#00,#01

.acoff:	BYTE	"ACOFF       "
	BYTE	#40,#00,#00,#00
	BYTE	#01,#00,#00

	BLOCK	19*4,0

;===============================================================
.bit:	BYTE	"BIT ",0,",A     "
	BYTE	#CB,#47,#00,#00
	BYTE	#02,#00,#0E				; Byte #02,#00,#0e
	BYTE	"BIT ",0,",B     "
	BYTE	#CB,#40,#00,#00
	BYTE	#02,#00,#0E				; Byte #02,#00,#0e
	BYTE	"BIT ",0,",C     "
	BYTE	#CB,#41,#00,#00
	BYTE	#02,#00,#0E				; Byte #02,#00,#0e
	BYTE	"BIT ",0,",D     "
	BYTE	#CB,#42,#00,#00
	BYTE	#02,#00,#0E				; Byte #02,#00,#0e
	BYTE	"BIT ",0,",E     "
	BYTE	#CB,#43,#00,#00
	BYTE	#02,#00,#0E				; Byte #02,#00,#0e
	BYTE	"BIT ",0,",H     "
	BYTE	#CB,#44,#00,#00
	BYTE	#02,#00,#0E				; Byte #02,#00,#0e
	BYTE	"BIT ",0,",L     "
	BYTE	#CB,#45,#00,#00
	BYTE	#02,#00,#0E				; Byte #02,#00,#0e
	BYTE	"BIT ",0,",(HL)  "
	BYTE	#CB,#46,#00,#00
	BYTE	#02,#00,#0E				; Byte #02,#00,#0e
	BYTE	"BIT ",0,",(IX+",0,")"
	BYTE	#DD,#CB,#00,#46
	BYTE	#04,#08,#0F				; Byte #03,#03,#0f
	BYTE	"BIT ",0,",(IY+",0,")"
	BYTE	#FD,#CB,#00,#46
	BYTE	#04,#08,#0F				; Byte #03,#03,#0f

	BLOCK	19*4,0
;===============================================================
.cp:	BYTE	"CP A        "
	BYTE	#BF,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"CP B        "
	BYTE	#B8,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"CP C        "
	BYTE	#B9,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"CP D        "
	BYTE	#BA,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"CP E        "
	BYTE	#BB,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"CP H        "
	BYTE	#BC,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"CP L        "
	BYTE	#BD,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"CP HX       "
	BYTE	#DD,#BC,#00,#00
	BYTE	#02,#00,#20
	BYTE	"CP HY       "
	BYTE	#FD,#BC,#00,#00
	BYTE	#02,#00,#20
	BYTE	"CP LX       "
	BYTE	#DD,#BD,#00,#00
	BYTE	#02,#00,#20
	BYTE	"CP LY       "
	BYTE	#FD,#BD,#00,#00
	BYTE	#02,#00,#20
	BYTE	"CP (HL)     "
	BYTE	#BE,#00,#00,#00
	BYTE	#01,#00,#40
	BYTE	"CP (IX+",0,")   "
	BYTE	#DD,#BE,#00,#00
	BYTE	#02,#03,#02
	BYTE	"CP (IY+",0,")   "
	BYTE	#FD,#BE,#00,#00
	BYTE	#02,#03,#02
	BYTE	"CP ",0,"        "
	BYTE	#FE,#00,#00,#00
	BYTE	#01,#00,#01
 
.cpd:	BYTE	"CPD         "
	BYTE	#ED,#A9,#00,#00
	BYTE	#02,#00,#00
.cpdr:	BYTE	"CPDR        "
	BYTE	#ED,#B9,#00,#00
	BYTE	#02,#00,#00
.cpi:	BYTE	"CPI         "
	BYTE	#ED,#A1,#00,#00
	BYTE	#02,#00,#00
.cpir:	BYTE	"CPIR        "
	BYTE	#ED,#B1,#00,#00
	BYTE	#02,#00,#00

.cpl:	BYTE	"CPL         "
	BYTE	#2F,#00,#00,#00
	BYTE	#01,#00,#00
.ccf:	BYTE	"CCF         "
	BYTE	#3F,#00,#00,#00
	BYTE	#01,#00,#00

.call:	BYTE	"CALL C,",0,"    "
	BYTE	#DC,#00,#00,#00
	BYTE	#01,#01,#03
	BYTE	"CALL M,",0,"    "
	BYTE	#FC,#00,#00,#00
	BYTE	#01,#01,#03
	BYTE	"CALL P,",0,"    "
	BYTE	#F4,#00,#00,#00
	BYTE	#01,#01,#03
	BYTE	"CALL Z,",0,"    "
	BYTE	#CC,#00,#00,#00
	BYTE	#01,#01,#03
	BYTE	"CALL NC,",0,"   "
	BYTE	#D4,#00,#00,#00
	BYTE	#01,#01,#06
	BYTE	"CALL NZ,",0,"   "
	BYTE	#C4,#00,#00,#00
	BYTE	#01,#01,#06
	BYTE	"CALL PE,",0,"   "
	BYTE	#EC,#00,#00,#00
	BYTE	#01,#01,#06
	BYTE	"CALL PO,",0,"   "
	BYTE	#E4,#00,#00,#00
	BYTE	#01,#01,#06
	BYTE	"CALL ",0,"      "
	BYTE	#CD,#00,#00,#00
	BYTE	#01,#01,#01

.Count:	BYTE	"COUNT       "
	BYTE	#52,#00,#00,#00
	BYTE	#01,#00,#00

.copy:	BYTE	"COPY        "
	BYTE	#6D,#00,#00,#00
	BYTE	#01,#00,#00

	BLOCK	19*4,0
;===============================================================
.di:	BYTE	"DI          "
	BYTE	#F3,#00,#00,#00
	BYTE	#01,#00,#00

.daa:	BYTE	"DAA         "
	BYTE	#27,#00,#00,#00
	BYTE	#01,#00,#00

.djnz:	BYTE	"DJNZ ",0,"      "
	BYTE	#10,#00,#00,#00
	BYTE	#01,#02,#01

.dec:	BYTE	"DEC A       "
	BYTE	#3D,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"DEC B       "
	BYTE	#05,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"DEC C       "
	BYTE	#0D,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"DEC D       "
	BYTE	#15,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"DEC E       "
	BYTE	#1D,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"DEC H       "
	BYTE	#25,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"DEC L       "
	BYTE	#2D,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"DEC HX      "
	BYTE	#DD,#25,#00,#00
	BYTE	#02,#00,#20
	BYTE	"DEC HY      "
	BYTE	#FD,#25,#00,#00
	BYTE	#02,#00,#20
	BYTE	"DEC LX      "
	BYTE	#DD,#2D,#00,#00
	BYTE	#02,#00,#20
	BYTE	"DEC LY      "
	BYTE	#FD,#2D,#00,#00
	BYTE	#02,#00,#20
	BYTE	"DEC (HL)    "
	BYTE	#35,#00,#00,#00
	BYTE	#01,#00,#40

	BYTE	"DEC BC      "
	BYTE	#0B,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"DEC DE      "
	BYTE	#1B,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"DEC HL      "
	BYTE	#2B,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"DEC SP      "
	BYTE	#3B,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"DEC IX      "
	BYTE	#DD,#2B,#00,#00
	BYTE	#02,#00,#20
	BYTE	"DEC IY      "
	BYTE	#FD,#2B,#00,#00
	BYTE	#02,#00,#20

	BYTE	"DEC (IX+",0,")  "
	BYTE	#DD,#35,#00,#00
	BYTE	#02,#03,#02
	BYTE	"DEC (IY+",0,")  "
	BYTE	#FD,#35,#00,#00
	BYTE	#02,#03,#02

.dup:	BYTE	"DUP ",0,"       "
	BYTE	#00,#00,#00,#00
	BYTE	#00,#0D,#01

.defb:	BYTE	"DEFB        "
	BYTE	#00,#00,#00,#00
	BYTE	#00,#11,#0D
.defw:	BYTE	"DEFW        "
	BYTE	#00,#00,#00,#00
	BYTE	#00,#12,#0D
.defd:	BYTE	"DEFD        "
	BYTE	#00,#00,#00,#00
	BYTE	#00,#13,#0D
.defs:	BYTE	"DEFS        "
	BYTE	#00,#00,#00,#00
	BYTE	#00,#14,#0D

.db:	BYTE	"DB          "
	BYTE	#00,#00,#00,#00
	BYTE	#00,#11,#0D
.dw:	BYTE	"DW          "
	BYTE	#00,#00,#00,#00
	BYTE	#00,#12,#0D
.dd:	BYTE	"DD          "
	BYTE	#00,#00,#00,#00
	BYTE	#00,#13,#0D
.ds:	BYTE	"DS          "
	BYTE	#00,#00,#00,#00
	BYTE	#00,#14,#0D

	BLOCK	19*4,0
;===============================================================
.equ:
	BYTE	"EQU ",0,"       "
	BYTE	#00,#00,#00,#00
	BYTE	#00,#0C,#01

.edup:	BYTE	"EDUP        "
	BYTE	#00,#00,#00,#00
	BYTE	#00,#0E,#00

.ei:	BYTE	"EI          "
	BYTE	#FB,#00,#00,#00
	BYTE	#01,#00,#00

.exx:	BYTE	"EXX         "
	BYTE	#D9,#00,#00,#00
	BYTE	#01,#00,#00

.ex:	BYTE	"EX AF,AF'   "
	BYTE	#08,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"EX DE,HL    "
	BYTE	#EB,#00,#00,#00
	BYTE	#01,#00,#50
	BYTE	"EX (SP),HL  "
	BYTE	#E3,#00,#00,#00
	BYTE	#01,#00,#70
	BYTE	"EX (SP),IX  "
	BYTE	#DD,#E3,#00,#00
	BYTE	#02,#00,#70
	BYTE	"EX (SP),IY  "
	BYTE	#FD,#E3,#00,#00
	BYTE	#02,#00,#70

	BLOCK	19*4,0
;===============================================================
.fill:	BYTE	"FILL        "
	BYTE	#49,#00,#00,#00
	BYTE	#01,#00,#00

	BLOCK	19*4,0
	BLOCK	19*4,0
;===============================================================
.halt:	BYTE	"HALT        "
	BYTE	#76,#00,#00,#00
	BYTE	#01,#00,#00

	BLOCK	19*4,0
;===============================================================
.im:	BYTE	"IM ",0,"        "
	BYTE	#ED,#46,#00,#00
	BYTE	#02,#05,#01

.inc:	BYTE	"INC A       "
	BYTE	#3C,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"INC B       "
	BYTE	#04,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"INC C       "
	BYTE	#0C,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"INC D       "
	BYTE	#14,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"INC E       "
	BYTE	#1C,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"INC H       "
	BYTE	#24,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"INC L       "
	BYTE	#2C,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"INC HX      "
	BYTE	#DD,#24,#00,#00
	BYTE	#02,#00,#20
	BYTE	"INC HY      "
	BYTE	#FD,#24,#00,#00
	BYTE	#02,#00,#20
	BYTE	"INC LX      "
	BYTE	#DD,#2C,#00,#00
	BYTE	#02,#00,#20
	BYTE	"INC LY      "
	BYTE	#FD,#2C,#00,#00
	BYTE	#02,#00,#20
	BYTE	"INC (HL)    "
	BYTE	#34,#00,#00,#00
	BYTE	#01,#00,#40

	BYTE	"INC BC      "
	BYTE	#03,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"INC DE      "
	BYTE	#13,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"INC HL      "
	BYTE	#23,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"INC SP      "
	BYTE	#33,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"INC IX      "
	BYTE	#DD,#23,#00,#00
	BYTE	#02,#00,#20
	BYTE	"INC IY      "
	BYTE	#FD,#23,#00,#00
	BYTE	#02,#00,#20

	BYTE	"INC (IX+",0,")  "
	BYTE	#DD,#34,#00,#00
	BYTE	#02,#03,#02
	BYTE	"INC (IY+",0,")  "
	BYTE	#FD,#34,#00,#00
	BYTE	#02,#03,#02

.ind:	BYTE	"IND         "
	BYTE	#ED,#AA,#00,#00
	BYTE	#02,#00,#00
.indr:	BYTE	"INDR        "
	BYTE	#ED,#BA,#00,#00
	BYTE	#02,#00,#00
.ini:	BYTE	"INI         "
	BYTE	#ED,#A2,#00,#00
	BYTE	#02,#00,#00
.inir:	BYTE	"INIR        "
	BYTE	#ED,#B2,#00,#00
	BYTE	#02,#00,#00

.in:	BYTE	"IN A,(C)    "
	BYTE	#ED,#78,#00,#00
	BYTE	#02,#00,#50
	BYTE	"IN B,(C)    "
	BYTE	#ED,#40,#00,#00
	BYTE	#02,#00,#50
	BYTE	"IN C,(C)    "
	BYTE	#ED,#48,#00,#00
	BYTE	#02,#00,#50
	BYTE	"IN D,(C)    "
	BYTE	#ED,#50,#00,#00
	BYTE	#02,#00,#50
	BYTE	"IN E,(C)    "
	BYTE	#ED,#58,#00,#00
	BYTE	#02,#00,#50
	BYTE	"IN H,(C)    "
	BYTE	#ED,#60,#00,#00
	BYTE	#02,#00,#50
	BYTE	"IN L,(C)    "
	BYTE	#ED,#68,#00,#00
	BYTE	#02,#00,#50
	BYTE	"IN A,(",0,")    "
	BYTE	#DB,#00,#00,#00
	BYTE	#01,#00,#04

.inf:	BYTE	"INF         "				; In (c)
	BYTE	#ED,#70,#00,#00
	BYTE	#02,#00,#00

.Include:	BYTE	"INCLUDE     "
	BYTE	#00,#00,#00,#00
	BYTE	#00,#0F,#0D
.Incbin:	BYTE	"INCBIN      "
	BYTE	#00,#00,#00,#00
	BYTE	#00,#10,#0D

	BLOCK	19*4,0
;===============================================================
.jr:	BYTE	"JR C,",0,"      "
	BYTE	#38,#00,#00,#00
	BYTE	#01,#02,#03
	BYTE	"JR Z,",0,"      "
	BYTE	#28,#00,#00,#00
	BYTE	#01,#02,#03
	BYTE	"JR NC,",0,"     "
	BYTE	#30,#00,#00,#00
	BYTE	#01,#02,#06
	BYTE	"JR NZ,",0,"     "
	BYTE	#20,#00,#00,#00
	BYTE	#01,#02,#06
	BYTE	"JR ",0,"        "
	BYTE	#18,#00,#00,#00
	BYTE	#01,#02,#01

.jp:	BYTE	"JP (HL)     "
	BYTE	#E9,#00,#00,#00
	BYTE	#01,#00,#40
	BYTE	"JP (IX)     "
	BYTE	#DD,#E9,#00,#00
	BYTE	#02,#00,#40
	BYTE	"JP (IY)     "
	BYTE	#FD,#E9,#00,#00
	BYTE	#02,#00,#40

	BYTE	"JP C,",0,"      "
	BYTE	#DA,#00,#00,#00
	BYTE	#01,#01,#03
	BYTE	"JP M,",0,"      "
	BYTE	#FA,#00,#00,#00
	BYTE	#01,#01,#03
	BYTE	"JP P,",0,"      "
	BYTE	#F2,#00,#00,#00
	BYTE	#01,#01,#03
	BYTE	"JP Z,",0,"      "
	BYTE	#CA,#00,#00,#00
	BYTE	#01,#01,#03
	BYTE	"JP NC,",0,"     "
	BYTE	#D2,#00,#00,#00
	BYTE	#01,#01,#06
	BYTE	"JP NZ,",0,"     "
	BYTE	#C2,#00,#00,#00
	BYTE	#01,#01,#06
	BYTE	"JP PE,",0,"     "
	BYTE	#EA,#00,#00,#00
	BYTE	#01,#01,#06
	BYTE	"JP PO,",0,"     "
	BYTE	#E2,#00,#00,#00
	BYTE	#01,#01,#06
	BYTE	"JP ",0,"        "
	BYTE	#C3,#00,#00,#00
	BYTE	#01,#01,#01

	BLOCK	19*4,0
	BLOCK	19*4,0
;===============================================================
;

;
; [] [] [] [] [] [] []
; [] [] [] [] [] [] []
; [] [] [] [] [] [] []
;

; Comml-r.z80
;===============================================================
.Ldd:
	BYTE	"LDD         "
	BYTE	#ED,#A8,#00,#00
	BYTE	#02,#00,#00
.Lddr:
	BYTE	"LDDR        "
	BYTE	#ED,#B8,#00,#00
	BYTE	#02,#00,#00
.Ldi:
	BYTE	"LDI         "
	BYTE	#ED,#A0,#00,#00
	BYTE	#02,#00,#00
.Ldir:
	BYTE	"LDIR        "
	BYTE	#ED,#B0,#00,#00
	BYTE	#02,#00,#00

.ld_a:
	BYTE	"LD A,A      "
	BYTE	#7F,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD A,B      "
	BYTE	#78,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD A,C      "
	BYTE	#79,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD A,D      "
	BYTE	#7A,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD A,E      "
	BYTE	#7B,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD A,H      "
	BYTE	#7C,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD A,HX     "
	BYTE	#DD,#7C,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD A,HY     "
	BYTE	#FD,#7C,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD A,L      "
	BYTE	#7D,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD A,LX     "
	BYTE	#DD,#7D,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD A,LY     "
	BYTE	#FD,#7D,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD A,I      "
	BYTE	#ED,#57,#00,#00
	BYTE	#02,#00,#30
	BYTE	"LD A,R      "
	BYTE	#ED,#5F,#00,#00
	BYTE	#02,#00,#30
	BYTE	"LD A,(BC)   "
	BYTE	#0A,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"LD A,(DE)   "
	BYTE	#1A,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"LD A,(HL)   "
	BYTE	#7E,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"LD A,(IX+",0,") "
	BYTE	#DD,#7E,#00,#00
	BYTE	#02,#03,#05
	BYTE	"LD A,(IY+",0,") "
	BYTE	#FD,#7E,#00,#00
	BYTE	#02,#03,#05
	BYTE	"LD A,(",0,")    "
	BYTE	#3A,#00,#00,#00
	BYTE	#01,#01,#04
	BYTE	"LD A,",0,"      "
	BYTE	#3E,#00,#00,#00
	BYTE	#01,#00,#03

.ld_b:
	BYTE	"LD B,A      "
	BYTE	#47,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD B,B      "
	BYTE	#40,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD B,C      "
	BYTE	#41,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD B,D      "
	BYTE	#42,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD B,E      "
	BYTE	#43,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD B,H      "
	BYTE	#44,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD B,HX     "
	BYTE	#DD,#44,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD B,HY     "
	BYTE	#FD,#44,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD B,L      "
	BYTE	#45,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD B,LX     "
	BYTE	#DD,#45,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD B,LY     "
	BYTE	#FD,#45,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD B,(HL)   "
	BYTE	#46,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"LD B,(IX+",0,") "
	BYTE	#DD,#46,#00,#00
	BYTE	#02,#03,#05
	BYTE	"LD B,(IY+",0,") "
	BYTE	#FD,#46,#00,#00
	BYTE	#02,#03,#05
	BYTE	"LD BC,(",0,")   "
	BYTE	#ED,#4B,#00,#00
	BYTE	#02,#01,#07
	BYTE	"LD BC,",0,"     "
	BYTE	#01,#00,#00,#30
	BYTE	#01,#01,#06
	BYTE	"LD B,",0,"      "
	BYTE	#06,#00,#00,#00
	BYTE	#01,#00,#03

.ld_c:
	BYTE	"LD C,A      "
	BYTE	#4F,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD C,B      "
	BYTE	#48,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD C,C      "
	BYTE	#49,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD C,D      "
	BYTE	#4A,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD C,E      "
	BYTE	#4B,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD C,H      "
	BYTE	#4C,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD C,HX     "
	BYTE	#DD,#4C,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD C,HY     "
	BYTE	#FD,#4C,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD C,L      "
	BYTE	#4D,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD C,LX     "
	BYTE	#DD,#4D,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD C,LY     "
	BYTE	#FD,#4D,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD C,(HL)   "
	BYTE	#4E,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"LD C,(IX+",0,") "
	BYTE	#DD,#4E,#00,#00
	BYTE	#02,#03,#05
	BYTE	"LD C,(IY+",0,") "
	BYTE	#FD,#4E,#00,#00
	BYTE	#02,#03,#05
	BYTE	"LD C,",0,"      "
	BYTE	#0E,#00,#00,#00
	BYTE	#01,#00,#03

.ld_d:
	BYTE	"LD D,A      "
	BYTE	#57,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD D,B      "
	BYTE	#50,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD D,C      "
	BYTE	#51,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD D,D      "
	BYTE	#52,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD D,E      "
	BYTE	#53,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD D,H      "
	BYTE	#54,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD D,HX     "
	BYTE	#DD,#54,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD D,HY     "
	BYTE	#FD,#54,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD D,L      "
	BYTE	#55,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD D,LX     "
	BYTE	#DD,#55,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD D,LY     "
	BYTE	#FD,#55,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD D,(HL)   "
	BYTE	#56,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"LD D,(IX+",0,") "
	BYTE	#DD,#56,#00,#00
	BYTE	#02,#03,#05
	BYTE	"LD D,(IY+",0,") "
	BYTE	#FD,#56,#00,#00
	BYTE	#02,#03,#05
	BYTE	"LD DE,(",0,")   "
	BYTE	#ED,#5B,#00,#00
	BYTE	#02,#01,#07
	BYTE	"LD DE,",0,"     "
	BYTE	#11,#00,#00,#00
	BYTE	#01,#01,#06
	BYTE	"LD D,",0,"      "
	BYTE	#16,#00,#00,#00
	BYTE	#01,#00,#03

.ld_e:
	BYTE	"LD E,A      "
	BYTE	#5F,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD E,B      "
	BYTE	#58,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD E,C      "
	BYTE	#59,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD E,D      "
	BYTE	#5A,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD E,E      "
	BYTE	#5B,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD E,H      "
	BYTE	#5C,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD E,HX     "
	BYTE	#DD,#5C,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD E,HY     "
	BYTE	#FD,#5C,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD E,L      "
	BYTE	#5D,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD E,LX     "
	BYTE	#DD,#5D,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD E,LY     "
	BYTE	#FD,#5D,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD E,(HL)   "
	BYTE	#5E,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"LD E,(IX+",0,") "
	BYTE	#DD,#5E,#00,#00
	BYTE	#02,#03,#05
	BYTE	"LD E,(IY+",0,") "
	BYTE	#FD,#5E,#00,#00
	BYTE	#02,#03,#05
	BYTE	"LD E,",0,"      "
	BYTE	#1E,#00,#00,#00
	BYTE	#01,#00,#03

.ld_h:
	BYTE	"LD H,A      "
	BYTE	#67,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD H,B      "
	BYTE	#60,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD H,C      "
	BYTE	#61,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD H,D      "
	BYTE	#62,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD H,E      "
	BYTE	#63,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD H,H      "
	BYTE	#64,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD H,L      "
	BYTE	#65,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD H,(HL)   "
	BYTE	#66,#00,#00,#00
	BYTE	#01,#00,#60

	BYTE	"LD HX,A     "
	BYTE	#DD,#67,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD HX,B     "
	BYTE	#DD,#60,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD HX,C     "
	BYTE	#DD,#61,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD HX,D     "
	BYTE	#DD,#62,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD HX,E     "
	BYTE	#DD,#63,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD HX,HX    "
	BYTE	#DD,#64,#00,#00
	BYTE	#02,#00,#50
	BYTE	"LD HX,LX    "
	BYTE	#DD,#65,#00,#00
	BYTE	#02,#00,#50

	BYTE	"LD HY,A     "
	BYTE	#FD,#67,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD HY,B     "
	BYTE	#FD,#60,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD HY,C     "
	BYTE	#FD,#61,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD HY,D     "
	BYTE	#FD,#62,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD HY,E     "
	BYTE	#FD,#63,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD HY,HY    "
	BYTE	#FD,#64,#00,#00
	BYTE	#02,#00,#50
	BYTE	"LD HY,LY    "
	BYTE	#FD,#65,#00,#00
	BYTE	#02,#00,#50
	BYTE	"LD H,(IX+",0,") "
	BYTE	#DD,#66,#00,#00
	BYTE	#02,#03,#05
	BYTE	"LD H,(IY+",0,") "
	BYTE	#FD,#66,#00,#00
	BYTE	#02,#03,#05
	BYTE	"LD HL,(",0,")   "
	BYTE	#2A,#00,#00,#00
	BYTE	#01,#01,#07
	BYTE	"LD HL,",0,"     "
	BYTE	#21,#00,#00,#00
	BYTE	#01,#01,#06
	BYTE	"LD HX,",0,"     "
	BYTE	#DD,#26,#00,#00
	BYTE	#02,#00,#06
	BYTE	"LD HY,",0,"     "
	BYTE	#FD,#26,#00,#00
	BYTE	#02,#00,#06
	BYTE	"LD H,",0,"      "
	BYTE	#26,#00,#00,#00
	BYTE	#01,#00,#03
	
.ld_l:
	BYTE	"LD L,A      "
	BYTE	#6F,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD L,B      "
	BYTE	#68,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD L,C      "
	BYTE	#69,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD L,D      "
	BYTE	#6A,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD L,E      "
	BYTE	#6B,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD L,H      "
	BYTE	#6C,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD L,L      "
	BYTE	#6D,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"LD L,(HL)   "
	BYTE	#6E,#00,#00,#00
	BYTE	#01,#00,#60

	BYTE	"LD LX,A     "
	BYTE	#DD,#6F,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD LX,B     "
	BYTE	#DD,#68,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD LX,C     "
	BYTE	#DD,#69,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD LX,D     "
	BYTE	#DD,#6A,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD LX,E     "
	BYTE	#DD,#6B,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD LX,HX    "
	BYTE	#DD,#6C,#00,#00
	BYTE	#02,#00,#50
	BYTE	"LD LX,LX    "
	BYTE	#DD,#6D,#00,#00
	BYTE	#02,#00,#50

	BYTE	"LD LY,A     "
	BYTE	#FD,#6F,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD LY,B     "
	BYTE	#FD,#68,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD LY,C     "
	BYTE	#FD,#69,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD LY,D     "
	BYTE	#FD,#6A,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD LY,E     "
	BYTE	#FD,#6B,#00,#00
	BYTE	#02,#00,#40
	BYTE	"LD LY,HY    "
	BYTE	#FD,#6C,#00,#00
	BYTE	#02,#00,#50
	BYTE	"LD LY,LY    "
	BYTE	#FD,#6D,#00,#00
	BYTE	#02,#00,#50
	BYTE	"LD L,(IX+",0,") "
	BYTE	#DD,#6E,#00,#00
	BYTE	#02,#03,#05
	BYTE	"LD L,(IY+",0,") "
	BYTE	#FD,#6E,#00,#00
	BYTE	#02,#03,#05
	BYTE	"LD LX,",0,"     "
	BYTE	#DD,#2E,#00,#00
	BYTE	#02,#00,#06
	BYTE	"LD LY,",0,"     "
	BYTE	#FD,#2E,#00,#00
	BYTE	#02,#00,#06
	BYTE	"LD L,",0,"      "
	BYTE	#2E,#00,#00,#00
	BYTE	#01,#00,#03

.ld_SK:
	BYTE	"LD (BC),A   "
	BYTE	#02,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"LD (DE),A   "
	BYTE	#12,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"LD (HL),B   "
	BYTE	#70,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"LD (HL),C   "
	BYTE	#71,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"LD (HL),D   "
	BYTE	#72,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"LD (HL),E   "
	BYTE	#73,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"LD (HL),H   "
	BYTE	#74,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"LD (HL),L   "
	BYTE	#75,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"LD (HL),A   "
	BYTE	#77,#00,#00,#00
	BYTE	#01,#00,#60
	BYTE	"LD (IX+",0,"),A "
	BYTE	#DD,#77,#00,#00
	BYTE	#02,#03,#0A
	BYTE	"LD (IX+",0,"),B "
	BYTE	#DD,#70,#00,#00
	BYTE	#02,#03,#0A
	BYTE	"LD (IX+",0,"),C "
	BYTE	#DD,#71,#00,#00
	BYTE	#02,#03,#0A
	BYTE	"LD (IX+",0,"),D "
	BYTE	#DD,#72,#00,#00
	BYTE	#02,#03,#0A
	BYTE	"LD (IX+",0,"),E "
	BYTE	#DD,#73,#00,#00
	BYTE	#02,#03,#0A
	BYTE	"LD (IX+",0,"),H "
	BYTE	#DD,#74,#00,#00
	BYTE	#02,#03,#0A
	BYTE	"LD (IX+",0,"),L "
	BYTE	#DD,#75,#00,#00
	BYTE	#02,#03,#0A

	BYTE	"LD (IY+",0,"),A "
	BYTE	#FD,#77,#00,#00
	BYTE	#02,#03,#0A
	BYTE	"LD (IY+",0,"),B "
	BYTE	#FD,#70,#00,#00
	BYTE	#02,#03,#0A
	BYTE	"LD (IY+",0,"),C "
	BYTE	#FD,#71,#00,#00
	BYTE	#02,#03,#0A
	BYTE	"LD (IY+",0,"),D "
	BYTE	#FD,#72,#00,#00
	BYTE	#02,#03,#0A
	BYTE	"LD (IY+",0,"),E "
	BYTE	#FD,#73,#00,#00
	BYTE	#02,#03,#0A
	BYTE	"LD (IY+",0,"),H "
	BYTE	#FD,#74,#00,#00
	BYTE	#02,#03,#0A
	BYTE	"LD (IY+",0,"),L "
	BYTE	#FD,#75,#00,#00
	BYTE	#02,#03,#0A
	BYTE	"LD (IX+",0,"),",0," "
	BYTE	#DD,#36,#00,#00
	BYTE	#02,#04,#09

	BYTE	"LD (IY+",0,"),",0," "
	BYTE	#FD,#36,#00,#00
	BYTE	#02,#04,#09
	BYTE	"LD (",0,"),A    "
	BYTE	#32,#00,#00,#00
	BYTE	#01,#01,#0C
	BYTE	"LD (",0,"),BC   "
	BYTE	#ED,#43,#00,#00
	BYTE	#02,#01,#0B
	BYTE	"LD (",0,"),DE   "
	BYTE	#ED,#53,#00,#00
	BYTE	#02,#01,#0B
	BYTE	"LD (",0,"),HL   "
	BYTE	#22,#00,#00,#00
	BYTE	#01,#01,#0B
	BYTE	"LD (",0,"),SP   "
	BYTE	#ED,#73,#00,#00
	BYTE	#02,#01,#0B
	BYTE	"LD (",0,"),IX   "
	BYTE	#DD,#22,#00,#00
	BYTE	#02,#01,#0B
	BYTE	"LD (",0,"),IY   "
	BYTE	#FD,#22,#00,#00
	BYTE	#02,#01,#0B
	BYTE	"LD (HL),",0,"   "
	BYTE	#36,#00,#00,#00
	BYTE	#01,#00,#08

.ld_s:	BYTE	"LD SP,HL    "
	BYTE	#F9,#00,#00,#00
	BYTE	#01,#00,#50
	BYTE	"LD SP,IX    "
	BYTE	#DD,#F9,#00,#00
	BYTE	#02,#00,#50
	BYTE	"LD SP,IY    "
	BYTE	#FD,#F9,#00,#00
	BYTE	#02,#00,#50
	BYTE	"LD SP,(",0,")   "
	BYTE	#ED,#7B,#00,#00
	BYTE	#02,#01,#07
	BYTE	"LD SP,",0,"     "
	BYTE	#31,#00,#00,#00
	BYTE	#01,#01,#06

.ld_i:	BYTE	"LD I,A      "
	BYTE	#ED,#47,#00,#00
	BYTE	#02,#00,#30
	BYTE	"LD IX,(",0,")   "
	BYTE	#DD,#2A,#00,#00
	BYTE	#02,#01,#07
	BYTE	"LD IY,(",0,")   "
	BYTE	#FD,#2A,#00,#00
	BYTE	#02,#01,#07
	BYTE	"LD IX,",0,"     "
	BYTE	#DD,#21,#00,#00
	BYTE	#02,#01,#06
	BYTE	"LD IY,",0,"     "
	BYTE	#FD,#21,#00,#00
	BYTE	#02,#01,#06

.ld_r:	BYTE	"LD R,A      "
	BYTE	#ED,#4F,#00,#00
	BYTE	#02,#00,#30

	BLOCK	19*4,0
	BLOCK	19*4,0
;===============================================================
.Nop:
	BYTE	"NOP         "
	BYTE	#00,#00,#00,#00
	BYTE	#01,#00,#00
.Neg:
	BYTE	"NEG         "
	BYTE	#ED,#44,#00,#00
	BYTE	#02,#00,#00

	BLOCK	19*4,0
;===============================================================
.Org:
	BYTE	"ORG ",0,"       "
	BYTE	#00,#00,#00,#00
	BYTE	#00,#09,#01

.Or:
	BYTE	"OR A        "
	BYTE	#B7,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"OR B        "
	BYTE	#B0,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"OR C        "
	BYTE	#B1,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"OR D        "
	BYTE	#B2,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"OR E        "
	BYTE	#B3,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"OR H        "
	BYTE	#B4,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"OR HX       "
	BYTE	#DD,#B4,#00,#00
	BYTE	#02,#00,#20
	BYTE	"OR HY       "
	BYTE	#FD,#B4,#00,#00
	BYTE	#02,#00,#20
	BYTE	"OR L        "
	BYTE	#B5,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"OR LX       "
	BYTE	#DD,#B5,#00,#00
	BYTE	#02,#00,#20
	BYTE	"OR LY       "
	BYTE	#FD,#B5,#00,#00
	BYTE	#02,#00,#20
	BYTE	"OR (HL)     "
	BYTE	#B6,#00,#00,#00
	BYTE	#01,#00,#40
	BYTE	"OR (IX+",0,")   "
	BYTE	#DD,#B6,#00,#00
	BYTE	#02,#03,#02
	BYTE	"OR (IY+",0,")   "
	BYTE	#FD,#B6,#00,#00
	BYTE	#02,#03,#02
	BYTE	"OR ",0,"        "
	BYTE	#F6,#00,#00,#00
	BYTE	#01,#00,#01

.out:
	BYTE	"OUT (C),0   "		; !!!!! be under format data be
	BYTE	#ED,#71,#00,#00
	BYTE	#02,#00,#50
	BYTE	"OUT (C),A   "
	BYTE	#ED,#79,#00,#00
	BYTE	#02,#00,#50
	BYTE	"OUT (C),B   "
	BYTE	#ED,#41,#00,#00
	BYTE	#02,#00,#50
	BYTE	"OUT (C),C   "
	BYTE	#ED,#49,#00,#00
	BYTE	#02,#00,#50
	BYTE	"OUT (C),D   "
	BYTE	#ED,#51,#00,#00
	BYTE	#02,#00,#50
	BYTE	"OUT (C),E   "
	BYTE	#ED,#59,#00,#00
	BYTE	#02,#00,#50
	BYTE	"OUT (C),H   "
	BYTE	#ED,#61,#00,#00
	BYTE	#02,#00,#50
	BYTE	"OUT (C),L   "
	BYTE	#ED,#69,#00,#00
	BYTE	#02,#00,#50
	BYTE	"OUT (",0,"),A   "
	BYTE	#D3,#00,#00,#00
	BYTE	#01,#00,#0C

.outd:
	BYTE	"OUTD        "
	BYTE	#ED,#AB,#00,#00
	BYTE	#02,#00,#00
.otdr:
	BYTE	"OTDR        "
	BYTE	#ED,#BB,#00,#00
	BYTE	#02,#00,#00
.outi:
	BYTE	"OUTI        "
	BYTE	#ED,#A3,#00,#00
	BYTE	#02,#00,#00
.otir:
	BYTE	"OTIR        "
	BYTE	#ED,#B3,#00,#00
	BYTE	#02,#00,#00

	BLOCK	19*4,0
;===============================================================
.phase:
	BYTE	"PHASE ",0,"     "
	BYTE	#00,#00,#00,#00
	BYTE	#00,#0A,#01

.push:
	BYTE	"PUSH AF     "
	BYTE	#F5,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"PUSH BC     "
	BYTE	#C5,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"PUSH DE     "
	BYTE	#D5,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"PUSH HL     "
	BYTE	#E5,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"PUSH IX     "
	BYTE	#DD,#E5,#00,#00
	BYTE	#02,#00,#20
	BYTE	"PUSH IY     "
	BYTE	#FD,#E5,#00,#00
	BYTE	#02,#00,#20

.pop:
	BYTE	"POP AF      "
	BYTE	#F1,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"POP BC      "
	BYTE	#C1,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"POP DE      "
	BYTE	#D1,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"POP HL      "
	BYTE	#E1,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"POP IX      "
	BYTE	#DD,#E1,#00,#00
	BYTE	#02,#00,#20
	BYTE	"POP IY      "
	BYTE	#FD,#E1,#00,#00
	BYTE	#02,#00,#20

	BLOCK	19*4,0
	BLOCK	19*4,0
;===============================================================
.retn:
	BYTE	"RETN        "
	BYTE	#ED,#45,#00,#00
	BYTE	#02,#00,#00
.reti:
	BYTE	"RETI        "
	BYTE	#ED,#4D,#00,#00
	BYTE	#02,#00,#00

.ret:
	BYTE	"RET         "
	BYTE	#C9,#00,#00,#00
	BYTE	#01,#00,#00
	BYTE	"RET C       "
	BYTE	#D8,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"RET M       "
	BYTE	#F8,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"RET P       "
	BYTE	#F0,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"RET Z       "
	BYTE	#C8,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"RET NC      "
	BYTE	#D0,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"RET NZ      "
	BYTE	#C0,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"RET PE      "
	BYTE	#E8,#00,#00,#00
	BYTE	#01,#00,#20
	BYTE	"RET PO      "
	BYTE	#E0,#00,#00,#00
	BYTE	#01,#00,#20

.rst:
	BYTE	"RST ",0,"       "
	BYTE	#C7,#00,#00,#00
	BYTE	#01,#06,#01

.rld:
	BYTE	"RLD         "
	BYTE	#ED,#6F,#00,#00
	BYTE	#02,#00,#00
.rrd:
	BYTE	"RRD         "
	BYTE	#ED,#67,#00,#00
	BYTE	#02,#00,#00

.rlca:
	BYTE	"RLCA        "
	BYTE	#07,#00,#00,#00
	BYTE	#01,#00,#00

.rlc:
	BYTE	"RLC A       "
	BYTE	#CB,#07,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RLC B       "
	BYTE	#CB,#00,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RLC C       "
	BYTE	#CB,#01,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RLC D       "
	BYTE	#CB,#02,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RLC E       "
	BYTE	#CB,#03,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RLC H       "
	BYTE	#CB,#04,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RLC L       "
	BYTE	#CB,#05,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RLC (HL)    "
	BYTE	#CB,#06,#00,#00
	BYTE	#02,#00,#40
	BYTE	"RLC (IX+",0,")  "
	BYTE	#DD,#CB,#00,#06
	BYTE	#04,#03,#02
	BYTE	"RLC (IY+",0,")  "
	BYTE	#FD,#CB,#00,#06
	BYTE	#04,#03,#02

.rrca:
	BYTE	"RRCA        "
	BYTE	#0F,#00,#00,#00
	BYTE	#01,#00,#00

.rrc:
	BYTE	"RRC A       "
	BYTE	#CB,#0F,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RRC B       "
	BYTE	#CB,#08,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RRC C       "
	BYTE	#CB,#09,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RRC D       "
	BYTE	#CB,#0A,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RRC E       "
	BYTE	#CB,#0B,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RRC H       "
	BYTE	#CB,#0C,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RRC L       "
	BYTE	#CB,#0D,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RRC (HL)    "
	BYTE	#CB,#0E,#00,#00
	BYTE	#02,#00,#40
	BYTE	"RRC (IX+",0,")  "
	BYTE	#DD,#CB,#00,#0E
	BYTE	#04,#03,#02
	BYTE	"RRC (IY+",0,")  "
	BYTE	#FD,#CB,#00,#0E
	BYTE	#04,#03,#02

.rla:
	BYTE	"RLA         "
	BYTE	#17,#00,#00,#00
	BYTE	#01,#00,#00

.rl:
	BYTE	"RL A        "
	BYTE	#CB,#17,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RL B        "
	BYTE	#CB,#10,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RL C        "
	BYTE	#CB,#11,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RL D        "
	BYTE	#CB,#12,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RL E        "
	BYTE	#CB,#13,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RL H        "
	BYTE	#CB,#14,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RL L        "
	BYTE	#CB,#15,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RL (HL)     "
	BYTE	#CB,#16,#00,#00
	BYTE	#02,#00,#40
	BYTE	"RL (IX+",0,")   "
	BYTE	#DD,#CB,#00,#16
	BYTE	#04,#03,#02
	BYTE	"RL (IY+",0,")   "
	BYTE	#FD,#CB,#00,#16				
	BYTE	#04,#03,#02				

.rra:
	BYTE	"RRA         "
	BYTE	#1F,#00,#00,#00
	BYTE	#01,#00,#00

.rr:
	BYTE	"RR A        "
	BYTE	#CB,#1F,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RR B        "
	BYTE	#CB,#18,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RR C        "
	BYTE	#CB,#19,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RR D        "
	BYTE	#CB,#1A,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RR E        "
	BYTE	#CB,#1B,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RR H        "
	BYTE	#CB,#1C,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RR L        "
	BYTE	#CB,#1D,#00,#00
	BYTE	#02,#00,#10
	BYTE	"RR (HL)     "
	BYTE	#CB,#1E,#00,#00
	BYTE	#02,#00,#40
	BYTE	"RR (IX+",0,")   "
	BYTE	#DD,#CB,#00,#1E
	BYTE	#04,#03,#02
	BYTE	"RR (IY+",0,")   "
	BYTE	#FD,#CB,#00,#1E
	BYTE	#04,#03,#02

.res:
	BYTE	"RES ",0,",A     "
	BYTE	#CB,#87,#00,#00
	BYTE	#02,#00,#0E
	BYTE	"RES ",0,",B     "
	BYTE	#CB,#80,#00,#00
	BYTE	#02,#00,#0E
	BYTE	"RES ",0,",C     "
	BYTE	#CB,#81,#00,#00
	BYTE	#02,#00,#0E
	BYTE	"RES ",0,",D     "
	BYTE	#CB,#82,#00,#00
	BYTE	#02,#00,#0E
	BYTE	"RES ",0,",E     "
	BYTE	#CB,#83,#00,#00
	BYTE	#02,#00,#0E
	BYTE	"RES ",0,",H     "
	BYTE	#CB,#84,#00,#00
	BYTE	#02,#00,#0E
	BYTE	"RES ",0,",L     "
	BYTE	#CB,#85,#00,#00
	BYTE	#02,#00,#0E
	BYTE	"RES ",0,",(HL)  "
	BYTE	#CB,#86,#00,#00
	BYTE	#02,#00,#0E
	BYTE	"RES ",0,",(IX+",0,")"
	BYTE	#DD,#CB,#00,#86
	BYTE	#04,#03,#0F
	BYTE	"RES ",0,",(IY+",0,")"
	BYTE	#FD,#CB,#00,#86
	BYTE	#04,#03,#0F

	BLOCK	19*4,0
;===============================================================
;

;
; [] [] [] [] [] [] []
; [] [] [] [] [] [] []
; [] [] [] [] [] [] []
;

; Comms-x.z80
;===============================================================
.scf:
	BYTE	"SCF         "
	BYTE	#37,#00,#00,#00
	BYTE	#01,#00,#00

.sub:
	BYTE	"SUB A       "
	BYTE	#97,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"SUB B       "
	BYTE	#90,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"SUB C       "
	BYTE	#91,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"SUB D       "
	BYTE	#92,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"SUB E       "
	BYTE	#93,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"SUB H       "
	BYTE	#94,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"SUB HX      "
	BYTE	#DD,#94,#00,#00
	BYTE	#02,#00,#20
	BYTE	"SUB HY      "
	BYTE	#FD,#94,#00,#00
	BYTE	#02,#00,#20
	BYTE	"SUB L       "
	BYTE	#95,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"SUB LX      "
	BYTE	#DD,#95,#00,#00
	BYTE	#02,#00,#20
	BYTE	"SUB LY      "
	BYTE	#FD,#95,#00,#00
	BYTE	#02,#00,#20
	BYTE	"SUB (HL)    "
	BYTE	#96,#00,#00,#00
	BYTE	#01,#00,#40
	BYTE	"SUB (IX+",0,")  "
	BYTE	#DD,#96,#00,#00
	BYTE	#02,#03,#02
	BYTE	"SUB (IY+",0,")  "
	BYTE	#FD,#96,#00,#00
	BYTE	#02,#03,#02
	BYTE	"SUB ",0,"       "
	BYTE	#D6,#00,#00,#00
	BYTE	#01,#00,#01

.sbc:
	BYTE	"SBC A,A     "
	BYTE	#9F,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"SBC A,B     "
	BYTE	#98,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"SBC A,C     "
	BYTE	#99,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"SBC A,D     "
	BYTE	#9A,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"SBC A,E     "
	BYTE	#9B,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"SBC A,H     "
	BYTE	#9C,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"SBC A,HX    "
	BYTE	#DD,#9C,#00,#00
	BYTE	#02,#00,#40
	BYTE	"SBC A,HY    "
	BYTE	#FD,#9C,#00,#00
	BYTE	#02,#00,#40
	BYTE	"SBC A,L     "
	BYTE	#9D,#00,#00,#00
	BYTE	#01,#00,#30
	BYTE	"SBC A,LX    "
	BYTE	#DD,#9D,#00,#00
	BYTE	#02,#00,#40
	BYTE	"SBC A,LY    "
	BYTE	#FD,#9D,#00,#00
	BYTE	#02,#00,#40
	BYTE	"SBC A,(HL)  "
	BYTE	#9E,#00,#00,#00
	BYTE	#01,#00,#60

	BYTE	"SBC HL,BC   "
	BYTE	#ED,#42,#00,#00
	BYTE	#02,#00,#50
	BYTE	"SBC HL,DE   "
	BYTE	#ED,#52,#00,#00
	BYTE	#02,#00,#50
	BYTE	"SBC HL,HL   "
	BYTE	#ED,#62,#00,#00
	BYTE	#02,#00,#50
	BYTE	"SBC HL,SP   "
	BYTE	#ED,#72,#00,#00
	BYTE	#02,#00,#50

	BYTE	"SBC A,(IX+",0,")"
	BYTE	#DD,#9E,#00,#00
	BYTE	#02,#03,#05
	BYTE	"SBC A,(IY+",0,")"
	BYTE	#FD,#9E,#00,#00
	BYTE	#02,#03,#05
	BYTE	"SBC A,",0,"     "
	BYTE	#DE,#00,#00,#00
	BYTE	#01,#00,#03

.sla:
	BYTE	"SLA A       "
	BYTE	#CB,#27,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SLA B       "
	BYTE	#CB,#20,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SLA C       "
	BYTE	#CB,#21,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SLA D       "
	BYTE	#CB,#22,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SLA E       "
	BYTE	#CB,#23,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SLA H       "
	BYTE	#CB,#24,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SLA L       "
	BYTE	#CB,#25,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SLA (HL)    "
	BYTE	#CB,#26,#00,#00
	BYTE	#02,#00,#40
	BYTE	"SLA (IX+",0,")  "
	BYTE	#DD,#CB,#00,#26
	BYTE	#04,#03,#02
	BYTE	"SLA (IY+",0,")  "
	BYTE	#FD,#CB,#00,#26
	BYTE	#04,#03,#02

.sra:
	BYTE	"SRA A       "
	BYTE	#CB,#2F,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SRA B       "
	BYTE	#CB,#28,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SRA C       "
	BYTE	#CB,#29,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SRA D       "
	BYTE	#CB,#2A,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SRA E       "
	BYTE	#CB,#2B,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SRA H       "
	BYTE	#CB,#2C,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SRA L       "
	BYTE	#CB,#2D,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SRA (HL)    "
	BYTE	#CB,#2E,#00,#00
	BYTE	#02,#00,#40
	BYTE	"SRA (IX+",0,")  "
	BYTE	#DD,#CB,#00,#2E
	BYTE	#04,#03,#02
	BYTE	"SRA (IY+",0,")  "
	BYTE	#FD,#CB,#00,#2E
	BYTE	#04,#03,#02

.sli:
	BYTE	"SLI A       "
	BYTE	#CB,#37,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SLI B       "
	BYTE	#CB,#30,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SLI C       "
	BYTE	#CB,#31,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SLI D       "
	BYTE	#CB,#32,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SLI E       "
	BYTE	#CB,#33,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SLI H       "
	BYTE	#CB,#34,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SLI L       "
	BYTE	#CB,#35,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SLI (HL)    "
	BYTE	#CB,#36,#00,#00
	BYTE	#02,#00,#40
	BYTE	"SLI (IX+",0,")  "
	BYTE	#DD,#CB,#00,#36
	BYTE	#04,#03,#02
	BYTE	"SLI (IY+",0,")  "
	BYTE	#FD,#CB,#00,#36
	BYTE	#04,#03,#02

.srl:
	BYTE	"SRL A       "
	BYTE	#CB,#3F,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SRL B       "
	BYTE	#CB,#38,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SRL C       "
	BYTE	#CB,#39,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SRL D       "
	BYTE	#CB,#3A,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SRL E       "
	BYTE	#CB,#3B,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SRL H       "
	BYTE	#CB,#3C,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SRL L       "
	BYTE	#CB,#3D,#00,#00
	BYTE	#02,#00,#10
	BYTE	"SRL (HL)    "
	BYTE	#CB,#3E,#00,#00
	BYTE	#02,#00,#40
	BYTE	"SRL (IX+",0,")  "
	BYTE	#DD,#CB,#00,#3E
	BYTE	#04,#03,#02
	BYTE	"SRL (IY+",0,")  "
	BYTE	#FD,#CB,#00,#3E
	BYTE	#04,#03,#02

.set:
	BYTE	"SET ",0,",A     "
	BYTE	#CB,#C7,#00,#00
	BYTE	#02,#00,#0E
	BYTE	"SET ",0,",B     "
	BYTE	#CB,#C0,#00,#00
	BYTE	#02,#00,#0E
	BYTE	"SET ",0,",C     "
	BYTE	#CB,#C1,#00,#00
	BYTE	#02,#00,#0E
	BYTE	"SET ",0,",D     "
	BYTE	#CB,#C2,#00,#00
	BYTE	#02,#00,#0E
	BYTE	"SET ",0,",E     "
	BYTE	#CB,#C3,#00,#00
	BYTE	#02,#00,#0E
	BYTE	"SET ",0,",H     "
	BYTE	#CB,#C4,#00,#00
	BYTE	#02,#00,#0E
	BYTE	"SET ",0,",L     "
	BYTE	#CB,#C5,#00,#00
	BYTE	#02,#00,#0E
	BYTE	"SET ",0,",(HL)  "
	BYTE	#CB,#C6,#00,#00
	BYTE	#02,#00,#0E
	BYTE	"SET ",0,",(IX+",0,")"
	BYTE	#DD,#CB,#00,#C6
	BYTE	#04,#03,#0F
	BYTE	"SET ",0,",(IY+",0,")"
	BYTE	#FD,#CB,#00,#C6
	BYTE	#04,#03,#0F

	BLOCK	19*4,0
	BLOCK	19*4,0
;===============================================================
.unphase:
	BYTE	"UNPHASE     "
	BYTE	#00,#00,#00,#00
	BYTE	#00,#0B,#00

	BLOCK	19*4,0
;===============================================================
.vcopy:
	BYTE	"VCOPY       "
	BYTE	#7F,#00,#00,#00
	BYTE	#01,#00,#00
.vfill:
	BYTE	"VFILL       "
	BYTE	#5B,#00,#00,#00
	BYTE	#01,#00,#00

	BLOCK	19*4,0
	BLOCK	19*4,0
;===============================================================
.Xor:
	BYTE	"XOR A       "
	BYTE	#AF,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"XOR B       "
	BYTE	#A8,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"XOR C       "
	BYTE	#A9,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"XOR D       "
	BYTE	#AA,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"XOR E       "
	BYTE	#AB,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"XOR H       "
	BYTE	#AC,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"XOR HX      "
	BYTE	#DD,#AC,#00,#00
	BYTE	#02,#00,#20
	BYTE	"XOR HY      "
	BYTE	#FD,#AC,#00,#00
	BYTE	#02,#00,#20
	BYTE	"XOR L       "
	BYTE	#AD,#00,#00,#00
	BYTE	#01,#00,#10
	BYTE	"XOR LX      "
	BYTE	#DD,#AD,#00,#00
	BYTE	#02,#00,#20
	BYTE	"XOR LY      "
	BYTE	#FD,#AD,#00,#00
	BYTE	#02,#00,#20
	BYTE	"XOR (HL)    "
	BYTE	#AE,#00,#00,#00
	BYTE	#01,#00,#40
	BYTE	"XOR (IX+",0,")  "
	BYTE	#DD,#AE,#00,#00
	BYTE	#02,#03,#02
	BYTE	"XOR (IY+",0,")  "
	BYTE	#FD,#AE,#00,#00
	BYTE	#02,#03,#02
	BYTE	"XOR ",0,"       "
	BYTE	#EE,#00,#00,#00
	BYTE	#01,#00,#01

	BLOCK	19*4,0
	BLOCK	19*4,0
	BLOCK	19*4,0
;===============================================================
;

;
;----[]
_m_end		EQU $	
; Ent

 ENDMODULE
	; Display " -------------[ command ]--------------"
	; Display " start adr end adr size"
	; Display " ",/h,cmd_tbl._m_start, " ", cmd_tbl._m_end, " ", cmd_tbl._m_end - cmd_tbl._m_start
	; Display " --------------------------------------"
	; Display " "
;
 _mCollectInfo_addEnd