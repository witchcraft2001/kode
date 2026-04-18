/*
;
;
; ------------[main prebuild]------------;
	LUA PASS1
	 -- configure path to packer
		detected_os = Detect_os()
		print ("OS detected:", detected_os)
		print ()

		if detected_os == "Windows" then
				pack_prog = "src\\bin\\hrust.exe Build\\Bin\\temp\\MAIN.PAK Build\\Bin\\temp\\MAIN.BIN"
			elseif detected_os == "MacOS" then 
				pack_prog = "src/bin/mhmt -hst -zxh Build/Bin/temp/MAIN.BIN Build/Bin/temp/MAIN.PAK"
			elseif detected_os == "Linux" then
				pack_prog = "src/bin/mhmt -hst -zxh Build/Bin/temp/MAIN.BIN Build/Bin/temp/MAIN.PAK"
		end


	 -- build packed MAIN and run a dry pass for Set_Pictures.asm
		if (os.execute("sjasmplus -Wall --msg=war --nologo --syntax=w --fullpath --lst=Build/Prebuilds.LST TASM_BIN.ASM")) then
				print("--[     TASM_Build.asm Prebuild DONE     ]--")
			if (os.execute(pack_prog)) then
				print("--[     Hrusting MAIN.BIN DONE     ]--")
				print(" ")
			else
				print("--[     Hrusting MAIN.BIN ERROR!!!     ]--")
				os.exit(1)
			end	
		else
			print("--[     TASM_Build.asm Prebuild ERROR!!!     ]--")
			os.exit(1)
		end
	ENDLUA
;---------------------------------------;

; [MAIN's referenses]----------; for getting labels and
	MMU 2 e, 18		; Page 18 in 2 and check on
	ORG COMPILE_ADDR.MAIN
	INCLUDE 'src/bios/ROM/SETUP/MAIN.asm'
;---------------------------------------;



; Building page 8 of sprinter rom
; -----------------[exp]-----------------
	MMU		0 e, 8						; Page 8 in 0 and check on
	ORG		COMPILE_ADDR.EXP
 	OUTPUT	'Build/Bin/EXP.BIN'
		INCLUDE	'src/bios/EXP/EXP.asm'
	OUTEND	
;---------------------------------------



; Building page 0 of sprinter rom
; -----------------[rom]-----------------
	MMU		0 e, 0						; Page 0 in 0 and check on
	ORG		ROM_MAP.ROM
	OUTPUT	'Build/Bin/ROM.BIN'
		INCLUDE 'src/bios/ROM/ROM.asm'
	OUTEND	
;---------------------------------------
*/
; Define save_bin 1
 IF SAVE_BIN
	includelua 'shared_includes/LUA/Functions.LUA'
	include 'shared_includes/constants/SP2000.inc'
	include 'MemMap.inc'
	include 'shared_includes/constants/bios_equ.inc'
	include 'shared_includes/constants/dss_equ.inc'
	include 'shared_includes/macroses/macros.z80'
	include 'version.inc'
	; Device sprinter
 ENDIF
/*
 DEFINE SAVE_BIN 0

;
 DEFINE _mPATH "build/bin/
 DEFINE _mFILE \bBinFile.bin";
;
 DEFINE _mFILEonly _mTERM _mFILE

 DISPLAY _mPATH _mFILE
 DISPLAY _mFILEonly
;
 DEFINE _rQuote \b";
 DEFINE _lQuote " \b;
 DEFINE _tFile 

 DEFINE _cmdHRUST		'Tools\\hrust.exe '
 DEFINE _cmdMHMTmac		'Tools/mhmt -hst -zxh '
 DEFINE _cmdMHMTlin		'Tools/mhmt -hst -zxh '

 DEFINE _pathHRUSTprg	'Tools'
 DEFINE _pathPACKfile 	'Build/HST'
 DEFINE _pathBINfile	'Build/Bin/New'
;
 DEFINE _fileTasmMain	'_TasmMain.bin'
 DEFINE _fileDialogWindows	'_DialogWN.bin'
 DEFINE _fileMenuBar	'_MenuBar.bin'
 DEFINE _fileCommand	'_Command.bin'
 DEFINE _filePrepare	'_Prepare.bin'
*/


 DEFINE _fnamePrepare	'build/bin/Prepare.bin'
 DEFINE _fnameTasmMain	'build/bin/TasmMain.bin'
 DEFINE _fnameDialogWindows	'build/bin/DialogWN.bin'
 DEFINE _fnameMenuBar	'build/bin/MenuBar.bin'
 DEFINE _fnameCommand	'build/bin/Command.bin'
 DEFINE _fnameCompiler	'build/bin/Compiler.bin'

/*
	mGETosNAME '_OSname'
	mGETfullNAME '_fnameTasmMain', _pathBINfile, _fileTasmMain, _OSname
	
  DISPLAY _fnameTasmMain
  DISPLAY _OSname
*/

; ----------------------------------------------------------[tasm main]
	ORG TasmMain.ORG
         _mCollectInfo_begin
 IF SAVE_BIN : OUTPUT _fnameTasmMain : ENDIF
	include 'Tasm_Main/Tasm_Main.asm'
	_mSIZE_INFO <"TasmMain:">, TasmMain.ORG, $, 2, 1
 IF SAVE_BIN : OUTEND : ENDIF
;--------------------------------------------------------------------;


; -----------------------------------------------------[dialog windows]
	ORG Dialog_Windows_PG1.ORG
 IF SAVE_BIN : OUTPUT _fnameDialogWindows : ENDIF
	include 'Dialog_Windows/Dialog_Windows_PG1.asm'
	_mSIZE_INFO <"Dlg_Win 1:">, Dialog_Windows_PG1.ORG, $, 1, 0
	BLOCK Dialog_Windows_PG1.ORG+#4000-$,0

	include 'Dialog_Windows/Dialog_Windows_PG2.asm'   
	_mSIZE_INFO <"Dlg_Win 2:">, Dialog_Windows_PG1.ORG+#4000, $, 1, 0
 IF SAVE_BIN : OUTEND : ENDIF
;--------------------------------------------------------------------;


; -----------------------------------------------------------[menu bar]
	ORG Menu_Bar_PG1.ORG
 IF SAVE_BIN : OUTPUT _fnameMenuBar : ENDIF
	include 'Menu_Bar/Menu_Bar_PG1.asm'
	_mSIZE_INFO <"Menu Bar 1:">, Menu_Bar_PG1.ORG, $, 1, 0
	BLOCK Menu_Bar_PG1.ORG+#4000-$,0

 	include 'Menu_Bar/Menu_Bar_PG2.asm'
	_mSIZE_INFO <"Menu Bar 2:">, Menu_Bar_PG1.ORG+#4000, $, 1, 0
 IF SAVE_BIN : OUTEND : ENDIF
;--------------------------------------------------------------------;


; ------------------------------------------------------------[command]
	ORG Command.ORG
 IF SAVE_BIN : OUTPUT _fnameCommand : ENDIF
	include 'Command/Command.asm'
	_mSIZE_INFO <"Command:">, Command.ORG, $, 1, 0
 IF SAVE_BIN : OUTEND : ENDIF
;--------------------------------------------------------------------;


; -----------------------------------------------------------[compiler] ; !todo
; Org asmcompiler.org
; If save_bin : output _fnamecompiler : endif
; Include 'compiler/compiler.asm'
; _msize_info <"compiler:">, asmcompiler.org, $, 2, 0
; If save_bin : outend : endif
;--------------------------------------------------------------------;


; ------------------------------------------------------------[prepare]
	ORG Prepare.ORG
 IF SAVE_BIN : OUTPUT _fnamePrepare : ENDIF
	include 'Prepare/Prepare.asm'
	_mSIZE_INFO <"Prepare:">, Prepare.ORG, $, 1, 2
 IF SAVE_BIN : OUTEND : ENDIF
;--------------------------------------------------------------------;
;
 _mCollectInfo_end