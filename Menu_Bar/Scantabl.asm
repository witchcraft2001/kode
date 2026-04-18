 _mCollectInfo_addStart
;
count	DEFL	#0000

; Scan code table
ScanTbl:	DB	#00,#00		; #00
	DB	#43,#00		; #01 f9
	BLOCK	2		; #02
	DB	#3F,#00		; #03 f5
	DB	#3D,#00		; #04 f3
	DB	#3B,#00		; #05 f1
	DB	#3C,#00		; #06 f2
	DB	#86,#00		; #07 f12
	BLOCK	2		; #08
	DB	#44,#00		; #09 f10
	DB	#42,#00		; #0a f8
	DB	#40,#00		; #0b f6
	DB	#3E,#00		; #0c f4
	DB	#0F,#00		; #0d tab
	DB	#29,#00		; #0e ~
	DB	#00,#00		; #0f

	BLOCK	2		; #10
	DB	#38,#38		; #11 left alt/right alt
	DB	#2A,#00		; #12 left shift
	BLOCK	2		; #13
	DB	#1D,#1D		; #14 left ctrl/right ctrl
	DB	#10,#00		; #15 q
	DB	#02,#00		; #16 1
	BLOCK	6		; #17,18,19
	DB	#2C,#00		; #1a z
	DB	#1F,#00		; #1b s
	DB	#1E,#00		; #1c a
	DB	#11,#00		; #1d w
	DB	#03,#00		; #1e 2
	BLOCK	2		; #1f

	BLOCK	2		; #20
	DB	#2E,#00		; #21 c
	DB	#2D,#00		; #22 x
	DB	#20,#00		; #23 d
	DB	#12,#00		; #24 e
	DB	#05,#00		; #25 4
	DB	#04,#00		; #26 3
	BLOCK	4		; #27,28
	DB	#39,#00		; #29 space
	DB	#2F,#00		; #2a pe
	DB	#21,#00		; #2b f
	DB	#14,#00		; #2c t
	DB	#13,#00		; #2d r
	DB	#06,#00		; #2e 5
	BLOCK	2		; #2f

	BLOCK	2		; #30
	DB	#31,#00		; #31 n
	DB	#30,#00		; #32 b
	DB	#23,#00		; #33 h
	DB	#22,#00		; #34 g
	DB	#15,#00		; #35 y
	DB	#07,#00		; #36 6
	BLOCK	6		; #37,38,39
	DB	#32,#00		; #3a m
	DB	#24,#00		; #3b j
	DB	#16,#00		; #3c u
	DB	#08,#00		; #3d 7
	DB	#09,#00		; #3e 8
	BLOCK	2		; #3f

	BLOCK	2		; #40
	DB	#33,#00		; #41 ,
	DB	#25,#00		; #42 k
	DB	#17,#00		; #43 i
	DB	#18,#00		; #44 o
	DB	#0B,#00		; #45 0
	DB	#0A,#00		; #46 9
	BLOCK	4		; #47,48
	DB	#34,#00		; #49 .
	DB	#35,#35		; #4a //
	DB	#26,#00		; #4b l
	DB	#27,#00		; #4c ;
	DB	#19,#00		; #4d p
	DB	#0C,#00		; #4e -
	BLOCK	2		; #4f

	BLOCK	4		; #50,51
	DB	#28,#00		; #52 "
	BLOCK	2		; #53
	DB	#1A,#00		; #54 [
	DB	#0D,#00		; #55 =
	BLOCK	4		; #56,57
	DB	#3A,#00		; #58 caps lock
	DB	#36,#00		; #59 right shift
	DB	#1C,#1C		; #5a enter/nenter
	DB	#1B,#00		; #5b ]
	BLOCK	2		; #5c
	DB	#2B,#00		; #5d \
	BLOCK	4		; #5e,5f

	BLOCK	12		; #60-65
	DB	#0E,#00		; #66 back space
	BLOCK	4		; #67,68
	DB	#4F,079		; #69 n1/end
	BLOCK	2		; #6a
	DB	#4B,075		; #6b n4/left
	DB	#47,071		; #6c n7/home
	BLOCK	6		; #6d-6f

	DB	#52,#52		; #70 n0/insert
	DB	#53,#53		; #71 ndel/delete
	DB	#50,#50		; #72 n2/down
	DB	#4C,#00		; #73 n5
	DB	#4D,077		; #74 n6/right
	DB	#48,072		; #75 n8/up
	DB	#01,#00		; #76 esc
	DB	#45,#00		; #77 num lock
	DB	#85,#00		; #78 f11
	DB	#4E,#00		; #79 n+
	DB	#51,#51		; #7a n3/pagedn
	DB	#4A,#00		; #7b n-
	DB	#54,#00		; #7c n*
	DB	#49,073		; #7d n9/pageup
	DB	#46,#00		; #7e scroll lock
	BLOCK	2		; #7f

	BLOCK	6		; #80-82
	DB	#41,#00		; #83 f7

; Ascii small char table
ASCItb1:
	BLOCK	2
	DB	#1B,#01		;Esc
	DB	0x31,#02
	DB	0x32,#03
	DB	0x33,#04
	DB	0x34,#05
	DB	0x35,#06
	DB	0x36,#07
	DB	0x37,#08
	DB	0x38,#09
	DB	0x39,#0A
	DB	0x30,#0B
	DB	0x2D,#0C
	DB	0x3D,#0D
	DB	#08,#0E		; Back space
	DB	#09,#0F		;Tab
	DB	0x71,#10
	DB	0x77,#11
	DB	0x65,#12
	DB	0x72,#13
	DB	0x74,#14
	DB	0x79,#15
	DB	0x75,#16
	DB	0x69,#17
	DB	0x6F,#18
	DB	0x70,#19
	DB	0x5B,#1A
	DB	0x5D,#1B
	DB	#0D,#1C		;Enter
	BLOCK	2		; Left ctrl
	DB	0x61,#1E
	DB	0x73,#1F
	DB	0x64,#20
	DB	0x66,#21
	DB	0x67,#22
	DB	0x68,#23
	DB	0x6A,#24
	DB	0x6B,#25
	DB	0x6C,#26
	DB	0x3B,#27
	DB	0x27,#28
	DB	0x60,#29
	BLOCK	2		; Left shift
	DB	0x5C,#2B
	DB	0x7A,#2C
	DB	0x78,#2D
	DB	0x63,#2E
	DB	0x76,#2F
	DB	0x62,#30
	DB	0x6E,#31
	DB	0x6D,#32
	DB	0x2C,#33
	DB	0x2E,#34
	DB	0x2F,#35
	BLOCK	2		; Right shift
	DB	#00,#37		; Print screen
	BLOCK	2		;Alt
	DB	0x20,#39
	BLOCK	2		; Caps lock
	DB	#00,#3B		;F1
	DB	#00,#3C		;F2
	DB	#00,#3D		;F3
	DB	#00,#3E		;F4
	DB	#00,#3F		;F5
	DB	#00,#40		;F6
	DB	#00,#41		;F7
	DB	#00,#42		;F8
	DB	#00,#43		;F9
	DB	#00,#44		;F10
	BLOCK	2		; Num lock
	BLOCK	2		; Scroll lock
	DB	000,#47
	DB	000,#48
	DB	000,#49
	DB	0x2D,#4A
	DB	000,#4B
	DB	000,#4C
	DB	000,#4D
	DB	0x2B,#4E
	DB	000,#4F
	DB	000,#50
	DB	000,#51
	DB	000,#52
	DB	#00,#53		;Del

	DB	0x2A,#09		;54

count = #5500
	DUP 48
	 WORD	count
count = count + #100
	EDUP 

	DB	#00,#85		; F11 ; ?????
	DB	#00,#86		; F12 ; ?????

; Ascii big char table
ASCItb2:
	BLOCK	2
	DB	#1B,#01		;Esc
	DB	0x31,#02		
	DB	0x32,#03		
	DB	0x33,#04		
	DB	0x34,#05		
	DB	0x35,#06		
	DB	0x36,#07		
	DB	0x37,#08		
	DB	0x38,#09		
	DB	0x39,#0A		
	DB	0x30,#0B		
	DB	0x2D,#0C		
	DB	0x3D,#0D		
	DB	#08,#0E		; Back space
	DB	#09,#0F		;Tab
	DB	0x51,#10		
	DB	0x57,#11		
	DB	0x45,#12		
	DB	0x52,#13		
	DB	0x54,#14		
	DB	0x59,#15		
	DB	0x55,#16		
	DB	0x49,#17		
	DB	0x4F,#18		
	DB	0x50,#19		
	DB	0x5B,#1A		
	DB	0x5D,#1B		
	DB	#0D,#1C		;Enter
	BLOCK	2		; Left ctrl
	DB	0x41,#1E
	DB	0x53,#1F
	DB	0x44,#20
	DB	0x46,#21
	DB	0x47,#22
	DB	0x48,#23
	DB	0x4A,#24
	DB	0x4B,#25
	DB	0x4C,#26
	DB	0x3B,#27
	DB	0x27,#28
	DB	0x60,#29
	BLOCK	2		; Left shift
	DB	0x5C,#2B
	DB	0x5A,#2C
	DB	0x58,#2D
	DB	0x43,#2E
	DB	0x56,#2F
	DB	0x42,#30
	DB	0x4E,#31
	DB	0x4D,#32
	DB	0x2C,#33
	DB	0x2E,#34
	DB	0x2F,#35
	BLOCK	2		; Right shift
	DB	#00,#37		; Print screen
	BLOCK	2		;Alt
	DB	0x20,#39
	BLOCK	2		; Caps lock
	DB	#00,#3B		;F1
	DB	#00,#3C		;F2
	DB	#00,#3D		;F3
	DB	#00,#3E		;F4
	DB	#00,#3F		;F5
	DB	#00,#40		;F6
	DB	#00,#41		;F7
	DB	#00,#42		;F8
	DB	#00,#43		;F9
	DB	#00,#44		;F10
	BLOCK	2		; Num lock
	BLOCK	2		; Scroll lock
	DB	000,#47
	DB	000,#48
	DB	000,#49
	DB	0x2D,#4A
	DB	000,#4B
	DB	000,#4C
	DB	000,#4D
	DB	0x2B,#4E
	DB	000,#4F
	DB	000,#50
	DB	000,#51
	DB	000,#52
	DB	#00,#53		;Del

	DB	0x2A,#09		;54

count = #5500
	DUP 48
	 WORD	count
count = count+#100
	EDUP 

	DB	#00,#85		; F11 ; ?????
	DB	#00,#86		; F12 ; ?????

; Shift table 1
ShftTb1:
	BLOCK	2	
	DB	#1B,#01		;Esc
	DB	0x21,#02		
	DB	0x40,#03		
	DB	0x23,#04		
	DB	0x24,#05		
	DB	0x25,#06		
	DB	0x5E,#07		
	DB	0x26,#08		
	DB	0x2A,#09		
	DB	0x28,#0A		
	DB	0x29,#0B		
	DB	0x5F,#0C		
	DB	0x2B,#0D		
	DB	#08,#0E		; Back space
	DB	#00,146		;Tab
	DB	0x71,#10		
	DB	0x77,#11		
	DB	0x65,#12		
	DB	0x72,#13		
	DB	0x74,#14		
	DB	0x79,#15		
	DB	0x75,#16		
	DB	0x69,#17		
	DB	0x6F,#18		
	DB	0x70,#19		
	DB	0x7B,#1A		
	DB	0x7D,#1B		
	DB	#0D,#1C		;Enter
	BLOCK	2		; Left ctrl
	DB	0x61,#1E
	DB	0x73,#1F
	DB	0x64,#20
	DB	0x66,#21
	DB	0x67,#22
	DB	0x68,#23
	DB	0x6A,#24
	DB	0x6B,#25
	DB	0x6C,#26
	DB	0x3A,#27
	DB	#22,#28
	DB	0x7E,#29
	BLOCK	2		; Left shift
	DB	0x7C,#2B
	DB	0x7A,#2C
	DB	0x78,#2D
	DB	0x63,#2E
	DB	0x76,#2F
	DB	0x62,#30
	DB	0x6E,#31
	DB	0x6D,#32
	DB	0x3C,#33
	DB	0x3E,#34
	DB	0x3F,#35
	BLOCK	2		; Right shift
	DB	#00,#37		; Print screen
	BLOCK	2		;Alt
	DB	0x20,#39
	BLOCK	2		; Caps lock
	DB	#00,#54		;F1
	DB	#00,#55		;F2
	DB	#00,#56		;F3
	DB	#00,#57		;F4
	DB	#00,#58		;F5
	DB	#00,#59		;F6
	DB	#00,#5A		;F7
	DB	#00,#5B		;F8
	DB	#00,#5C		;F9
	DB	#00,#5D		;F10
	BLOCK	2		; Num lock
	BLOCK	2		; Scroll lock
	DB	000,147
	DB	000,142
	DB	000,#49
	DB	0x2D,#4A
	DB	000,143
	DB	000,#4C
	DB	000,145
	DB	0x2B,#4E
	DB	000,148
	DB	000,144
	DB	000,#51
	DB	000,153
	DB	000,151		;Del

	DB	0x2A,#09		;54

count = #5500
	DUP 48
	 WORD	count
count = count + #100
	EDUP 

	DB	#00,#87		; F11 ; ?????
	DB	#00,#88		; F12 ; ?????

; Shift table 2
ShftTb2:
	BLOCK	2	
	DB	#1B,#01		;Esc
	DB	0x21,#02		
	DB	0x40,#03		
	DB	0x23,#04		
	DB	0x24,#05		
	DB	0x25,#06		
	DB	0x5E,#07		
	DB	0x26,#08		
	DB	0x2A,#09		
	DB	0x28,#0A		
	DB	0x29,#0B		
	DB	0x5F,#0C		
	DB	0x2B,#0D		
	DB	#08,#0E		; Back space
	DB	#00,146		;Tab
	DB	0x51,#10		
	DB	0x57,#11		
	DB	0x45,#12		
	DB	0x52,#13		
	DB	0x54,#14		
	DB	0x59,#15		
	DB	0x55,#16		
	DB	0x49,#17		
	DB	0x4F,#18		
	DB	0x50,#19		
	DB	0x7B,#1A		
	DB	0x7D,#1B		
	DB	#0D,#1C		;Enter
	BLOCK	2		; Left ctrl
	DB	0x41,#1E
	DB	0x53,#1F
	DB	0x44,#20
	DB	0x46,#21
	DB	0x47,#22
	DB	0x48,#23
	DB	0x4A,#24
	DB	0x4B,#25
	DB	0x4C,#26
	DB	0x3A,#27
	DB	#22,#28		;"
	DB	0x7E,#29
	BLOCK	2		; Left shift
	DB	0x7C,#2B
	DB	0x5A,#2C
	DB	0x58,#2D
	DB	0x43,#2E
	DB	0x56,#2F
	DB	0x42,#30
	DB	0x4E,#31
	DB	0x4D,#32
	DB	0x3C,#33
	DB	0x3E,#34
	DB	0x3F,#35
	BLOCK	2		; Right shift
	DB	#00,#37		; Print screen
	BLOCK	2		;Alt
	DB	0x20,#39
	BLOCK	2		; Caps lock
	DB	#00,#54		;F1
	DB	#00,#55		;F2
	DB	#00,#56		;F3
	DB	#00,#57		;F4
	DB	#00,#58		;F5
	DB	#00,#59		;F6
	DB	#00,#5A		;F7
	DB	#00,#5B		;F8
	DB	#00,#5C		;F9
	DB	#00,#5D		;F10
	BLOCK	2		; Num lock
	BLOCK	2		; Scroll lock
	DB	000,147
	DB	000,142
	DB	000,#49
	DB	0x2D,#4A
	DB	000,143
	DB	000,#4C
	DB	000,145
	DB	0x2B,#4E
	DB	000,148
	DB	000,144
	DB	000,#51
	DB	000,153
	DB	000,151		;Del

	DB	0x2A,#09		;54

count = #5500
	DUP 48
	 WORD	count
count = count + #100
	EDUP 

	DB	#00,#87		; F11 ; ?????
	DB	#00,#88		; F12 ; ?????

; Alt table
AltTabl:
	BLOCK	2     		;00
	DB	#00,149		;01
	DB	#00,120		;02
	DB	#00,121		;03
	DB	#00,122		;04
	DB	#00,123		;05
	DB	#00,124		;06
	DB	#00,125		;07
	DB	#00,126		;08
	DB	#00,127		;09
	DB	#00,128		; 0a
	DB	#00,129		; 0b
	DB	#00,130		; 0c
	DB	#00,131		; 0d
	DB	#08,#0E		; 0e
	DB	#09,#0F		; 0f
	DB	#00,16 		;10
	DB	#00,17 		;11
	DB	#00,18 		;12
	DB	#00,19 		;13
	DB	#00,20 		;14
	DB	#00,21 		;15
	DB	#00,22 		;16
	DB	#00,23 		;17
	DB	#00,24 		;18
	DB	#00,25 		;19
	DB	0x5B,#1A		; 1a
	DB	0x5D,#1B		; 1b
	DB	#0D,#1C		; 1c enter
	DB	#00,00 		; 1d left ctrl
	DB	#00,30 		; 1e
	DB	#00,31 		; 1f
	DB	#00,32 		;20
	DB	#00,33 		;21
	DB	#00,34 		;22
	DB	#00,35 		;23
	DB	#00,36 		;24
	DB	#00,37 		;25
	DB	#00,38 		;26
	DB	0x3B,#27		;27
	DB	0x27,#28		;28
	DB	0x60,#29		;29
	BLOCK	2     		; 2a ;left shift
	DB	#5C,#2B		; 2b
	DB	#00,44 		; 2c
	DB	#00,45 		; 2d
	DB	#00,46 		; 2e
	DB	#00,47 		; 2f
	DB	#00,48 		;30
	DB	#00,49 		;31
	DB	#00,50 		;32
	DB	0x2C,#33		;33
	DB	0x2E,#34		;34
	DB	0x2F,#35		;35
	BLOCK	2     		; 36 right shift
	BLOCK	2     		; 37 print screen
	BLOCK	2     		; 38 alt
	DB	0x20,00 		;39
	BLOCK	2     		; 3a caps lock
	DB	#00,104		; 3b f1
	DB	#00,105		; 3c f2
	DB	#00,106		; 3d f3
	DB	#00,107		; 3e f4
	DB	#00,108		; 3f f5
	DB	#00,109		; 40 f6
	DB	#00,110		; 41 f7
	DB	#00,111		; 42 f8
	DB	#00,112		; 43 f9
	DB	#00,113		; 44 f10
	BLOCK	2		; 45 num lock
	BLOCK	2		; 46 scroll lock
	DB	000,#47
	DB	000,#48
	DB	000,#49
	DB	0x2D,#4A
	DB	000,#4B
	DB	000,#4C
	DB	000,#4D
	DB	0x2B,#4E
	DB	000,#4F
	DB	000,#50
	DB	000,#51
	DB	000,#52
	DB	#00,#53		;Del

	DB	0x2A,#09		;54
	BLOCK	96			;55-84
	DB	#00,139		; 85 ;f11 ; ?????
	DB	#00,140		; 86 ;f12 ; ?????

; Ctrl table
CtrlTab:
	BLOCK	2	;00
	DB	#1B,#01		;Esc
	DB	0x31,#02
	DB	0x32,#03
	DB	0x33,#04
	DB	0x34,#05
	DB	0x35,#06
	DB	0x36,#07
	DB	0x37,#08
	DB	0x38,#09
	DB	0x39,#0A
	DB	0x30,#0B
	DB	0x2D,#0C
	DB	0x3D,#0D
	DB	#00,141		; 0e ;back space
	DB	#09,#0F		; 0f ;tab
	DB	#00,17		;10
	DB	#00,23		;11
	DB	#00,05		;12
	DB	#00,18		;13
	DB	#00,20		;14
	DB	#00,25		;15
	DB	#00,21		;16
	DB	#00,09		;17
	DB	#00,15		;18
	DB	#00,16		;19
	DB	0x5B,#1A
	DB	0x5D,#1B
	DB	#0D,#1C		; 1c ;enter
	BLOCK	2		; 1d ;left ctrl
	DB	#00,01		; 1e
	DB	#00,19		; 1f
	DB	#00,04		;20
	DB	#00,06		;21
	DB	#00,07		;22
	DB	#00,08		;23
	DB	#00,10		;24
	DB	#00,11		;25
	DB	#00,12		;26
	DB	0x3B,#27
	DB	0x27,#28
	DB	0x60,#29
	BLOCK	2; 2a ;left shift
	DB	0x5C,#2B
	DB	#00,26		; 2c
	DB	#00,24		; 2d
	DB	#00,03		; 2e
	DB	#00,27		; 2f
	DB	#00,02		;30
	DB	#00,14		;31
	DB	#00,13		;32
	DB	0x2C,#33
	DB	0x2E,#34
	DB	0x2F,#35
	BLOCK	2; 36 ;right shift
	DB	#00,114		; 37 ;print screen
	BLOCK	2; 38 ;alt
	DB	0x20,#39		;39
	BLOCK	2; 3a ;caps lock
	DB	#00,94		; 3b ;f1
	DB	#00,95		; 3c ;f2
	DB	#00,96		; 3d ;f3
	DB	#00,97		; 3e ;f4
	DB	#00,98		; 3f ;f5
	DB	#00,99		; 40 ;f6
	DB	#00,100		; 41 ;f7
	DB	#00,101		; 42 ;f8
	DB	#00,102		; 43 ;f9
	DB	#00,103		; 44 ;f10
	BLOCK	2; 45 ;num lock
	BLOCK	2; 46 ;scroll lock
	DB	#00,119		; 47 home
	DB	#00,155		;48
	DB	#00,132		; 49 ;pgup
	BLOCK	2		; 4a
	DB	#00,116		; 4b <-
	BLOCK	2		; 4c
	DB	#00,115		; 4d ->
	BLOCK	2		; 4e
	DB	#00,117		; 4f ;end
	DB	#00,156		;50
	DB	#00,118		; 51 ;pgdn
	DB	#00,150		;52
	DB	#00,154		; 53 ;del

	DB	0x2A,#09		;54
	BLOCK	96			;55-84
	DB	#00,137		; 85 ;f11 ; ?????
	DB	#00,138		; 86 ;f12 ; ?????

; Ascii small char table (rus)
ASCrus1	BLOCK	2	
	DB	#1B,#01		;Esc
	DB	0x31,#02		
	DB	0x32,#03		
	DB	0x33,#04		
	DB	0x34,#05		
	DB	0x35,#06		
	DB	0x36,#07		
	DB	0x37,#08		
	DB	0x38,#09		
	DB	0x39,#0A		
	DB	0x30,#0B		
	DB	0x2D,#0C		
	DB	0x3D,#0D		
	DB	#08,#0E		; Back space
	DB	#09,#0F		;Tab
	DB	0xA9,#10		
	DB	0xE6,#11		
	DB	0xE3,#12		
	DB	0xAA,#13		
	DB	0xA5,#14		
	DB	0xAD,#15		
	DB	0xA3,#16		
	DB	0xE8,#17		
	DB	0xE9,#18		
	DB	0xA7,#19		
	DB	#E5,#1A		; X
	DB	#EA,#1B		; Internal operation
	DB	#0D,#1C		;Enter
	BLOCK	2		; Left ctrl
	DB	0xE4,#1E
	DB	0xEB,#1F
	DB	0xA2,#20
	DB	0xA0,#21
	DB	0xAF,#22
	DB	0xE0,#23
	DB	0xAE,#24
	DB	0xAB,#25
	DB	0xA4,#26
	DB	#A6,#27
	DB	#ED,#28
	DB	0x60,#29
	BLOCK	2		; Left shift
	DB	0x5C,#2B
	DB	0xEF,#2C
	DB	0xE7,#2D
	DB	0xE1,#2E
	DB	0xAC,#2F
	DB	0xA8,#30
	DB	0xE2,#31
	DB	0xEC,#32
	DB	#A1,#33
	DB	#EE,#34
	DB	0x2F,#35
	BLOCK	2		; Right shift
	DB	#00,#37		; Print screen
	BLOCK	2		;Alt
	DB	0x20,#39
	BLOCK	2		; Caps lock
	DB	#00,#3B		;F1
	DB	#00,#3C		;F2
	DB	#00,#3D		;F3
	DB	#00,#3E		;F4
	DB	#00,#3F		;F5
	DB	#00,#40		;F6
	DB	#00,#41		;F7
	DB	#00,#42		;F8
	DB	#00,#43		;F9
	DB	#00,#44		;F10
	BLOCK	2		; Num lock
	BLOCK	2		; Scroll lock
	DB	000,#47
	DB	000,#48
	DB	000,#49
	DB	0x2D,#4A
	DB	000,#4B
	DB	000,#4C
	DB	000,#4D
	DB	0x2B,#4E
	DB	000,#4F
	DB	000,#50
	DB	000,#51
	DB	000,#52
	DB	#00,#53		;Del

	DB	0x2A,#09		;54

count = #5500
	DUP 48
	 WORD	count
count = count + #100
	EDUP 

	DB	#00,#85		; F11 ; ?????
	DB	#00,#86		; F12 ; ?????

; Ascii big char table (rus)
ASCrus2:
	BLOCK	2	
	DB	#1B,#01		;Esc
	DB	0x31,#02		
	DB	0x32,#03		
	DB	0x33,#04		
	DB	0x34,#05		
	DB	0x35,#06		
	DB	0x36,#07		
	DB	0x37,#08		
	DB	0x38,#09		
	DB	0x39,#0A		
	DB	0x30,#0B		
	DB	0x2D,#0C		
	DB	0x3D,#0D		
	DB	#08,#0E		; Back space
	DB	#09,#0F		;Tab
	DB	0x89,#10		
	DB	0x96,#11		
	DB	0x93,#12		
	DB	0x8A,#13		
	DB	0x85,#14		
	DB	0x8D,#15		
	DB	0x83,#16		
	DB	0x98,#17		
	DB	0x99,#18		
	DB	0x87,#19		
	DB	#95,#1A		
	DB	#9A,#1A		
	DB	#0D,#1C		;Enter
	BLOCK	2		; Left ctrl
	DB	0x94,#1E
	DB	0x9B,#1F
	DB	0x82,#20
	DB	0x80,#21
	DB	0x8F,#22
	DB	0x90,#23
	DB	0x8E,#24
	DB	0x8B,#25
	DB	0x84,#26
	DB	#86,#27
	DB	#9D,#28
	DB	0x60,#29
	BLOCK	2		; Left shift
	DB	0x5C,#2B
	DB	0x9F,#2C
	DB	0x97,#2D
	DB	0x91,#2E
	DB	0x8C,#2F
	DB	0x88,#30
	DB	0x92,#31
	DB	0x9C,#32
	DB	#81,#33
	DB	#9E,#34
	DB	0x2F,#35
	BLOCK	2		; Right shift
	DB	#00,#37		; Print screen
	BLOCK	2		;Alt
	DB	0x20,#39
	BLOCK	2		; Caps lock
	DB	#00,#3B		;F1
	DB	#00,#3C		;F2
	DB	#00,#3D		;F3
	DB	#00,#3E		;F4
	DB	#00,#3F		;F5
	DB	#00,#40		;F6
	DB	#00,#41		;F7
	DB	#00,#42		;F8
	DB	#00,#43		;F9
	DB	#00,#44		;F10
	BLOCK	2		; Num lock
	BLOCK	2		; Scroll lock
	DB	000,#47
	DB	000,#48
	DB	000,#49
	DB	0x2D,#4A
	DB	000,#4B
	DB	000,#4C
	DB	000,#4D
	DB	0x2B,#4E
	DB	000,#4F
	DB	000,#50
	DB	000,#51
	DB	000,#52
	DB	#00,#53		;Del

	DB	0x2A,#09		;54

count = #5500
	DUP 48
	 WORD	count
count = count + #100
	EDUP 

	DB	#00,#85		; F11 ; ?????
	DB	#00,#86		; F12 ; ?????

; Shift table 1 (rus)
Shfrus1:
	BLOCK	2	
	DB	#1B,#01		;Esc
	DB	0x21,#02		
	DB	#22,#03		
	DB	0x2F,#04		
	DB	0x23,#05		
	DB	0x3A,#06		
	DB	0x2C,#07		
	DB	0x2E,#08		
	DB	0x3B,#09		
	DB	0x3F,#0A		
	DB	0x25,#0B		
	DB	0x5F,#0C		
	DB	0x2B,#0D		
	DB	#08,#0E		; Back space
	DB	#00,146		;Tab
	DB	0xA9,#10		
	DB	0xE6,#11		
	DB	0x65,#12		
	DB	0xAA,#13		
	DB	0xA5,#14		
	DB	0xAD,#15		
	DB	0xA3,#16		
	DB	0xE8,#17		
	DB	0xE9,#18		
	DB	0xA7,#19		
	DB	#E5,#1A		
	DB	#EA,#1B		
	DB	#0D,#1C		;Enter
	BLOCK	2		; Left ctrl
	DB	0xE4,#1E
	DB	0xEB,#1F
	DB	0xA2,#20
	DB	0xA0,#21
	DB	0xAF,#22
	DB	0xE0,#23
	DB	0xAE,#24
	DB	0xAB,#25
	DB	0xA4,#26
	DB	#A6,#27
	DB	#ED,#28
	DB	0x7E,#29
	BLOCK	2		; Left shift
	DB	0x7C,#2B
	DB	0xEF,#2C
	DB	0xE7,#2D
	DB	0xE1,#2E
	DB	0xAC,#2F
	DB	0xA8,#30
	DB	0xE2,#31
	DB	0xEC,#32
	DB	#A1,#33
	DB	#EE,#34
	DB	0x3F,#35
	BLOCK	2		; Right shift
	DB	#00,#37		; Print screen
	BLOCK	2		;Alt
	DB	0x20,#39
	BLOCK	2		; Caps lock
	DB	#00,#54		;F1
	DB	#00,#55		;F2
	DB	#00,#56		;F3
	DB	#00,#57		;F4
	DB	#00,#58		;F5
	DB	#00,#59		;F6
	DB	#00,#5A		;F7
	DB	#00,#5B		;F8
	DB	#00,#5C		;F9
	DB	#00,#5D		;F10
	BLOCK	2		; Num lock
	BLOCK	2		; Scroll lock
	DB	000,147
	DB	000,142
	DB	000,#49
	DB	0x2D,#4A
	DB	000,143
	DB	000,#4C
	DB	000,145
	DB	0x2B,#4E
	DB	000,148
	DB	000,144
	DB	000,#51
	DB	000,153
	DB	000,151		;Del

	DB	0x2A,#09		;54

count = #5500
	DUP 48
	 WORD	count
count = count + #100
	EDUP 

	DB	#00,135		; F11 ; ?????
	DB	#00,136		; F12 ; ?????

; Shift table 2 (rus)
Shfrus2:
	BLOCK	2	
	DB	#1B,#01		;Esc
	DB	0x21,#02		
	DB	#22,#03		
	DB	0x2F,#04		
	DB	0x23,#05		
	DB	0x3A,#06		
	DB	0x2C,#07		
	DB	0x2E,#08		
	DB	0x3B,#09		
	DB	0x3F,#0A		
	DB	0x25,#0B		
	DB	0x5F,#0C		
	DB	0x2B,#0D		
	DB	#08,#0E		; Back space
	DB	#00,146		;Tab
	DB	0x89,#10		
	DB	0x96,#11		
	DB	0x93,#12		
	DB	0x8A,#13		
	DB	0x85,#14		
	DB	0x8D,#15		
	DB	0x83,#16		
	DB	0x98,#17		
	DB	0x99,#18		
	DB	0x87,#19		
	DB	#95,#1A		
	DB	#9A,#1B		
	DB	#0D,#1C		;Enter
	BLOCK	2		; Left ctrl
	DB	0x94,#1E
	DB	0x9B,#1F
	DB	0x82,#20
	DB	0x80,#21
	DB	0x8F,#22
	DB	0x90,#23
	DB	0x8E,#24
	DB	0x8B,#25
	DB	0x84,#26
	DB	#86,#27
	DB	#9D,#28		;"
	DB	0x7E,#29
	BLOCK	2		; Left shift
	DB	0x7C,#2B
	DB	0x9F,#2C
	DB	0x97,#2D
	DB	0x91,#2E
	DB	0x8C,#2F
	DB	0x88,#30
	DB	0x92,#31
	DB	0x9C,#32
	DB	#81,#33
	DB	#9E,#34
	DB	0x3F,#35
	BLOCK	2		; Right shift
	DB	#00,#37		; Print screen
	BLOCK	2		;Alt
	DB	0x20,#39
	BLOCK	2		; Caps lock
	DB	#00,#54		;F1
	DB	#00,#55		;F2
	DB	#00,#56		;F3
	DB	#00,#57		;F4
	DB	#00,#58		;F5
	DB	#00,#59		;F6
	DB	#00,#5A		;F7
	DB	#00,#5B		;F8
	DB	#00,#5C		;F9
	DB	#00,#5D		;F10
	BLOCK	2		; Num lock
	BLOCK	2		; Scroll lock
	DB	000,147
	DB	000,142
	DB	000,#49
	DB	0x2D,#4A
	DB	000,143
	DB	000,#4C
	DB	000,145
	DB	0x2B,#4E
	DB	000,148
	DB	000,144
	DB	000,#51
	DB	000,153
	DB	000,151		;Del

	DB	0x2A,#09		;54

count = #5500
	DUP 48
	 WORD	count
count = count + #100
	EDUP 

	DB	#00,135		; F11 ; ?????
	DB	#00,136		; F12 ; ?????
;
 _mCollectInfo_addEnd