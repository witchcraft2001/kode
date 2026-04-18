;--[]
; --------------[get date]
 LUA PASS1						; !TODO and to
	date, month, year = Get_date_RU(sj.get_define("__DATE__"))
	yearShort = string.sub(year, 3,4)
 ENDLUA	
 LUA ALLPASS
 	sj.insert_define("_luaBUILD_YEAR", "'" .. year .. "'")
	sj.insert_define("_luaBUILD_DATE", "'" .. date .. "." .. month .. "." .. yearShort .. "'")
	sj.insert_define("_luaBUILD_DATEfull", "'" .. date .. "." .. month .. "." .. year .. "'")
 ENDLUA
;----------------------[]

; ---------------[version]
 DEFINE _progVERSION	'0.71'
;----------------------[]

; -----------------[mouse]
 DEFINE MOUSE_COM_BAUD		0		; 1 - 2485, 2 - 4807, else - 1215 (default)
 DEFINE MOUSE_INT_ENABLED	0
 ; Define mouse_read_port_timeout 1280
;
 IF MOUSE_COM_BAUD = 1
MOUSE_BAUD:
.multiplier_1			EQU %0100'0000 	; First multiplier = 16
.multiplier_2			EQU 22		; Multiplier = 22. 875000/1*2=2485
 ELSEIF	MOUSE_COM_BAUD = 2
MOUSE_BAUD:
.multiplier_1			EQU %0000'0000	; First multiplier = 1
.multiplier_2			EQU 182 	; Multiplier = 182. 875000/1*2=4807
 ELSE
MOUSE_BAUD:
.multiplier_1			EQU %0100'0000	; First multiplier = 16
.multiplier_2			EQU 45		; Multiplier = 45. 875000/1*2=1215
 ENDIF
;----------------------[]
