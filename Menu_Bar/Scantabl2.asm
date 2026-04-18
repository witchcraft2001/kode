 _mCollectInfo_addStart
; Ascii small char table (rus)
ASCRUS1:	BLOCK	2
	DB	#1B,#01	;Esc
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
	DB	0xED,#0D
	DB	#08,#0E	; Back space
	DB	#09,#0F	;Tab
	DB	0xEF,#10
	DB	0xA2,#11
	DB	0xA5,#12
	DB	0xE0,#13
	DB	0xE2,#14
	DB	0xEB,#15
	DB	0xE3,#16
	DB	0xA8,#17
	DB	0xAE,#18
	DB	0xAF,#19
	DB	0xE8,#1A
	DB	0xE9,#1B
	DB	#0D,#1C	;Enter
	BLOCK	2	; Left ctrl
	DB	0xA0,#1E
	DB	0xE1,#1F
	DB	0xA4,#20
	DB	0xE4,#21
	DB	0xA3,#22
	DB	0xE5,#23
	DB	0xA9,#24
	DB	0xAA,#25
	DB	0xAB,#26
	DB	0xE7,#27
	DB	0x27,#28
	DB	0xEA,#29
	BLOCK	2	; Left shift
	DB	0xEE,#2B
	DB	0xA7,#2C
	DB	0xEC,#2D
	DB	0xE6,#2E
	DB	0xA6,#2F
	DB	0xA1,#30
	DB	0xAD,#31
	DB	0xAC,#32
	DB	0x2C,#33
	DB	0x2E,#34
	DB	0x2F,#35
	BLOCK	2	; Right shift
	DB	#00,#37	; Print screen
	BLOCK	2	;Alt
	DB	0x20,#39
	BLOCK	2	; Caps lock
	DB	#00,#3B	;F1
	DB	#00,#3C	;F2
	DB	#00,#3D	;F3
	DB	#00,#3E	;F4
	DB	#00,#3F	;F5
	DB	#00,#40	;F6
	DB	#00,#41	;F7
	DB	#00,#42	;F8
	DB	#00,#43	;F9
	DB	#00,#44	;F10
	BLOCK	2	; Num lock
	BLOCK	2	; Scroll lock
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
	DB	#00,#53	;Del

	DB	0x2A,#09	;54
	
count = #5500
	DUP	48
	 WORD	count
count = count + #100
	EDUP

	DB	#00,#85	;F11
	DB	#00,#86	;F12

; Ascii big char table (rus)
ASCRUS2:	BLOCK	2
	DB	#1B,#01	;Esc
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
	DB	0x9D,#0D
	DB	#08,#0E	; Back space
	DB	#09,#0F	;Tab
	DB	0x9F,#10
	DB	0x82,#11
	DB	0x85,#12
	DB	0x90,#13
	DB	0x92,#14
	DB	0x9B,#15
	DB	0x93,#16
	DB	0x88,#17
	DB	0x8E,#18
	DB	0x8F,#19
	DB	0x98,#1A
	DB	0x99,#1B
	DB	#0D,#1C	;Enter
	BLOCK	2	; Left ctrl
	DB	0x80,#1E
	DB	0x91,#1F
	DB	0x84,#20
	DB	0x94,#21
	DB	0x83,#22
	DB	0x95,#23
	DB	0x89,#24
	DB	0x8A,#25
	DB	0x8B,#26
	DB	0x97,#27
	DB	0x27,#28
	DB	0x9A,#29
	BLOCK	2	; Left shift
	DB	0x9E,#2B
	DB	0x87,#2C
	DB	0x9C,#2D
	DB	0x96,#2E
	DB	0x86,#2F
	DB	0x81,#30
	DB	0x8D,#31
	DB	0x8C,#32
	DB	0x2C,#33
	DB	0x2E,#34
	DB	0x2F,#35
	BLOCK	2	; Right shift
	DB	#00,#37	; Print screen
	BLOCK	2	;Alt
	DB	0x20,#39
	BLOCK	2	; Caps lock
	DB	#00,#3B	;F1
	DB	#00,#3C	;F2
	DB	#00,#3D	;F3
	DB	#00,#3E	;F4
	DB	#00,#3F	;F5
	DB	#00,#40	;F6
	DB	#00,#41	;F7
	DB	#00,#42	;F8
	DB	#00,#43	;F9
	DB	#00,#44	;F10
	BLOCK	2	; Num lock
	BLOCK	2	; Scroll lock
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
	DB	#00,#53	;Del

	DB	0x2A,#09	;54

count = #5500
	DUP	48
	 WORD	count
count = count + #100
	EDUP

	DB	#00,#85	;F11
	DB	#00,#86	;F12

; Shift table 1 (rus)
ShfRUS1:	BLOCK	2
	DB	#1B,#01	;Esc
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
	DB	0xED,#0D
	DB	#08,#0E	; Back space
	DB	#00,146	;Tab
	DB	0xEF,#10
	DB	0xA2,#11
	DB	0xA5,#12
	DB	0xE0,#13
	DB	0xE2,#14
	DB	0xEB,#15
	DB	0xE3,#16
	DB	0xA8,#17
	DB	0xAE,#18
	DB	0xAF,#19
	DB	0xE8,#1A
	DB	0xE9,#1B
	DB	#0D,#1C	;Enter
	BLOCK	2	; Left ctrl
	DB	0xA0,#1E
	DB	0xE1,#1F
	DB	0xA4,#20
	DB	0xE4,#21
	DB	0xA3,#22
	DB	0xE5,#23
	DB	0xA9,#24
	DB	0xAA,#25
	DB	0xAB,#26
	DB	0xE7,#27
	DB	0x27,#28
	DB	0xEA,#29
	BLOCK	2	; Left shift
	DB	0xEE,#2B
	DB	0xA7,#2C
	DB	0xEC,#2D
	DB	0xE6,#2E
	DB	0xA6,#2F
	DB	0xA1,#30
	DB	0xAD,#31
	DB	0xAC,#32
	DB	0x2C,#33
	DB	0x2E,#34
	DB	0x3F,#35
	BLOCK	2	; Right shift
	DB	#00,#37	; Print screen
	BLOCK	2	;Alt
	DB	0x20,#39
	BLOCK	2	; Caps lock
	DB	#00,#54	;F1
	DB	#00,#55	;F2
	DB	#00,#56	;F3
	DB	#00,#57	;F4
	DB	#00,#58	;F5
	DB	#00,#59	;F6
	DB	#00,#5A	;F7
	DB	#00,#5B	;F8
	DB	#00,#5C	;F9
	DB	#00,#5D	;F10
	BLOCK	2	; Num lock
	BLOCK	2	; Scroll lock
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
	DB	000,151	;Del

	DB	0x2A,#09	;54

count = #5500
	DUP	48
	 WORD	count
count = count + #100
	EDUP

	DB	#00,135	;F11
	DB	#00,136	;F12

; Shift table 2 (rus)
ShfRUS2:	BLOCK	2
	DB	#1B,#01	;Esc
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
	DB	0x9D,#0D
	DB	#08,#0E	; Back space
	DB	#00,146	;Tab
	DB	0x9F,#10
	DB	0x82,#11
	DB	0x85,#12
	DB	0x90,#13
	DB	0x92,#14
	DB	0x9B,#15
	DB	0x93,#16
	DB	0x88,#17
	DB	0x8E,#18
	DB	0x8F,#19
	DB	0x98,#1A
	DB	0x99,#1B
	DB	#0D,#1C	;Enter
	BLOCK	2	; Left ctrl
	DB	0x80,#1E
	DB	0x91,#1F
	DB	0x84,#20
	DB	0x94,#21
	DB	0x83,#22
	DB	0x95,#23
	DB	0x89,#24
	DB	0x8A,#25
	DB	0x8B,#26
	DB	0x97,#27
	DB	0x27,#28
	DB	0x9A,#29
	BLOCK	2	; Left shift
	DB	0x9E,#2B
	DB	0x87,#2C
	DB	0x9C,#2D
	DB	0x96,#2E
	DB	0x86,#2F
	DB	0x81,#30
	DB	0x8D,#31
	DB	0x8C,#32
	DB	0x2C,#33
	DB	0x2E,#34
	DB	0x3F,#35
	BLOCK	2	; Right shift
	DB	#00,#37	; Print screen
	BLOCK	2	;Alt
	DB	0x20,#39
	BLOCK	2	; Caps lock
	DB	#00,#54	;F1
	DB	#00,#55	;F2
	DB	#00,#56	;F3
	DB	#00,#57	;F4
	DB	#00,#58	;F5
	DB	#00,#59	;F6
	DB	#00,#5A	;F7
	DB	#00,#5B	;F8
	DB	#00,#5C	;F9
	DB	#00,#5D	;F10
	BLOCK	2	; Num lock
	BLOCK	2	; Scroll lock
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
	DB	000,151	;Del

	DB	0x2A,#09	;54
count = #5500
	DUP	48
	 WORD	count
count = count + #100
	EDUP 

	DB	#00,135	;F11
	DB	#00,136	;F12
;
 _mCollectInfo_addEnd