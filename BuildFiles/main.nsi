; Script to install fixes and enhancements for GTA IV Complete Edition.

VIProductVersion "1.0.0.0"
VIAddVersionKey "ProductName" "Fixer for Grand Theft Auto IV Complete Edition"
VIAddVersionKey "Comments" "Only for Grand Theft Auto IV Complete Edition"
VIAddVersionKey "CompanyName" "Fusion Team"
VIAddVersionKey "LegalTrademarks" "Fixer for Grand Theft Auto IV Complete Edition is a trademark of Fusion Team"
VIAddVersionKey "LegalCopyright" "Copyright Fusion Team"
VIAddVersionKey "FileDescription" "Fixer for Grand Theft Auto IV Complete Edition"
VIAddVersionKey "FileVersion" "1.0.0"

ManifestDPIAware true

SetCompressor lzma

Unicode True

BrandingText ""

CRCCheck on

!include FileFunc.nsh
!include LogicLib.nsh
!include NSISpcre.nsh
!include Sections.nsh
!include nsDialogs.nsh
!include MUI2.nsh

!insertmacro REMatches

; The name of the installer
Name "Fixer for Grand Theft Auto IV Complete Edition"

; The file to write
OutFile "..\Binaries\data\main.exe"

RequestExecutionLevel admin

Function RelGotoPage
  IntCmp $R9 0 0 Move Move
    StrCmp $R9 "X" 0 Move
      StrCpy $R9 "120"
 
  Move:
  SendMessage $HWNDPARENT "0x408" "$R9" ""
FunctionEnd

SpaceTexts None

;All Variables
Var DisplayDPI
Var AspectRatio
Var Label
Var VidMemCheckbox
Var VidMemCheckboxState
Var VidMemField
Var VidMemAmount
Var Windowed
Var WindowedState
Var AdditionalCommandline
Var CommandlineOptions
Var CommandlineOptionsState
Var forceolddxvk
Var forceolddxvkstate
Var setaspectratio
Var setaspectratiostate
Var rrInstallStatus


;--------------------------------

; Pages

; text for mui pages
!define MUI_UI "${__FILEDIR__}\ui.exe"
!define MUI_ICON "${__FILEDIR__}\icon.ico"
	
	; Header
	!define MUI_WELCOMEFINISHPAGE_BITMAP_STRETCH FitControl

	; Welcome page
	!define MUI_WELCOMEPAGE_TITLE "Fixer for Grand Theft Auto IV Complete Edition"
	!define MUI_WELCOMEPAGE_TEXT "This installer provides an easy and automated way to install fixes in Grand Theft Auto IV Complete Edition.$\r$\n$\r$\nClick Next to continue with the installation."
	
	; License page
	!define MUI_PAGE_HEADER_TEXT "Information"
    !define MUI_PAGE_HEADER_SUBTEXT "Details about this modification."
	!define MUI_LICENSEPAGE_TEXT_TOP " "
	!define MUI_LICENSEPAGE_TEXT_BOTTOM " "
	!define MUI_LICENSEPAGE_BUTTON "Next"
	
	; Components page
	!define MUI_COMPONENTSPAGE_TEXT_TOP "Select the components you want to install:"
	!define MUI_COMPONENTSPAGE_TEXT_INSTTYPE " "
	!define MUI_COMPONENTSPAGE_TEXT_DESCRIPTION_TITLE "Component description"
	!define MUI_COMPONENTSPAGE_TEXT_DESCRIPTION_INFO "Hover your mouse over a component to see its description"
	
	; Directory page
	!define MUI_DIRECTORYPAGE_TEXT_TOP "Select your game folder (Note: Folder with GTAIV.exe should automatically detected be and inputted here, if not, input it manually)"
	!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "Select the folder where GTAIV.exe is located"
	; Finish page
	!define MUI_FINISHPAGE_TITLE "Installation complete"
	!define MUI_FINISHPAGE_TEXT "You can now launch the game! Press finish to exit the installer."

!define MUI_PAGE_CUSTOMFUNCTION_SHOW DPIbanner
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${__FILEDIR__}\info.rtf"
!insertmacro MUI_PAGE_COMPONENTS
Page custom OptionsPage OptionsPageLeave
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_PAGE_CUSTOMFUNCTION_SHOW DPIbanner
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

Function DPIbanner
	StrCpy $DisplayDPI 96
	System::Call USER32::GetDpiForSystem()i.r0
	${If} $0 U<= 0
    	System::Call USER32::GetDC(i0)i.r1
    	System::Call GDI32::GetDeviceCaps(ir1,i88)i.r0
    	System::Call USER32::ReleaseDC(i0,ir1)
	${EndIf}
	${If} $0 > 168
		StrCpy $DisplayDPI 192
	${ElseIf} $0 > 144
		StrCpy $DisplayDPI 168
	${ElseIf} $0 > 120
		StrCpy $DisplayDPI 144
	${ElseIf} $0 > 96
		StrCpy $DisplayDPI 120
	${EndIf}
	StrCpy $0 ""
	
    ${NSD_SetImage} $mui.WelcomePage.Image "$EXEDIR\Resources\Banners\banner$DisplayDPI.bmp" $mui.WelcomePage.Image.Bitmap
    ${NSD_SetImage} $mui.FinishPage.Image "$EXEDIR\Resources\Banners\banner$DisplayDPI.bmp" $mui.FinishPage.Image.Bitmap
	
FunctionEnd

;--------------------------------

; The stuff to install

ComponentText "Select components to install." "Description of components:" "The mods already selected here are recommended for the best experience."

Section "-CreateTempFolder"
	SetOutPath $INSTDIR
	CreateDirectory "$EXEDIR\Resources\.temp"
SectionEnd

Section "-ExeCheck"
	SetOutPath $INSTDIR
	InitPluginsDir
  ${GetFileVersion} "$INSTDIR\GTAIV.exe" $5
  
  ${If} $5 =~ "1.0.*.0" 
	MessageBox MB_RETRYCANCEL "Game version is incompatible, please use the latest version of the game, or select folder with latest version." IDRETRY retryfolder IDCANCEL installerfail_1
	DetailPrint "Game version is incompatible, please use the latest version of the game."
  ${EndIf}

  ${If} $5 == ""
	MessageBox MB_RETRYCANCEL "Game executable invalid or not found, please select a proper directory." IDRETRY retryfolder IDCANCEL installerfail_1
	DetailPrint "Game executable invalid or not found, please select a proper directory."
  ${EndIf}
  
  Goto ExeOK
  
  retryfolder:
  StrCpy $R9 -1
  Call RelGotoPage
  Abort
  
  installerfail_1:
  DetailPrint "Cancelling installation."
  Abort
  
  ExeOK:
SectionEnd

Section "FusionFix" ff
	SectionIn RO
	
	SetOutPath $INSTDIR

	NScurl::http GET "http://github.com/ThirteenAG/GTAIV.EFLC.FusionFix/releases/latest/download/GTAIV.EFLC.FusionFix.zip" "$EXEDIR\Resources\.temp\FusionFix.zip" /CANCEL /RESUME /END
	
	nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\FusionFix.zip"'

SectionEnd

	Section "DXVK" dxvk
	SetOutPath "$EXEDIR\Resources\.temp"
	nsExec::Exec "$EXEDIR\Resources\External\vkinfo.bat"
	SetOutPath "$INSTDIR"
	nsExec::ExecToStack '"$EXEDIR\Resources\External\external.exe" "$EXEDIR\Resources\.temp\vkinfo.txt"'
	Pop $9
	Pop $9
	${If} $9 == "1"
	${AndIfNot} $forceolddxvkstate == ${BST_CHECKED}
		NScurl::http GET "https://api.github.com/repos/sTc2201/dxvk/releases/latest" "$EXEDIR\Resources\.temp\dxvk.json" /SILENT
		DetailPrint "Latest version of DXVK is supported, installing..."
		nsJSON::Set /file "$EXEDIR\Resources\.temp\dxvk.json"
  		ClearErrors
  		nsJSON::Get "assets" /index 0 /index 12 /end
  		${If} ${Errors}
    		DetailPrint `error, probably rate limited. won't install dxvk`
		${Else}
			Pop $0
  		${EndIf}
		NScurl::http GET "$0" "$EXEDIR\Resources\.temp\DXVK.tar.gz" /CANCEL /RESUME /END
		SetOutPath "$EXEDIR\Resources\.temp"
		nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\DXVK.tar.gz" -odxvk'
		SetOutPath "$INSTDIR"
		CopyFiles "$EXEDIR\Resources\.temp\dxvk\x32\d3d9.dll" "$INSTDIR" 
	${ElseIf} $9 == "2"
	${OrIf} $forceolddxvkstate == ${BST_CHECKED}
		DetailPrint "Latest version of DXVK is not supported, however older async version is. Installing..."
		NScurl::http GET "https://github.com/Sporif/dxvk-async/releases/download/1.10.3/dxvk-async-1.10.3.tar.gz" "$EXEDIR\Resources\.temp\DXVK.tar.gz" /CANCEL /RESUME /END
		SetOutPath "$EXEDIR\Resources\.temp"
		nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\DXVK.tar.gz" -odxvk'
		nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\dxvk\dxvk-async-1.10.3.tar" -odxvk'
		SetOutPath "$INSTDIR"
		CopyFiles "$EXEDIR\Resources\.temp\dxvk\dxvk-async-1.10.3\x32\d3d9.dll" "$INSTDIR" 
	${Else}
		Goto dxvkfail
	${EndIf}
	
	${If} $setaspectratiostate == ${BST_CHECKED}
		nsExec::ExecToStack "$EXEDIR\Resources\External\external.exe"
		Pop $9
		Pop $AspectRatio
		DetailPrint "Screen aspect ratio is $AspectRatio"
		FileOpen $9 "$INSTDIR\dxvk.conf" w
		FileWrite $9 "d3d9.forceAspectRatio = $\"$AspectRatio$\""
		FileClose $9
	${EndIf}
	Goto dxvkfinish
	
	dxvkfail:
	MessageBox MB_OK "Your system does not support DXVK, it will not be installed" IDOK dxvkfinish
	
	dxvkfinish:
	SectionEnd

Section "Various Fixes" vf
	NScurl::http GET "https://api.github.com/repos/valentyn-l/GTAIV.EFLC.Various.Fixes/releases/latest" "$EXEDIR\Resources\.temp\vf.json" /SILENT
	nsJSON::Set /file "$EXEDIR\Resources\.temp\vf.json"
  	ClearErrors
  	nsJSON::Get "assets" /index 0 /index 12 /end
  	${If} ${Errors}
    	DetailPrint `error, probably rate limited. won't install various fixes`
	${Else}
		Pop $0
  	${EndIf}
	NScurl::http GET "$0" "$EXEDIR\Resources\.temp\VariousFixes.zip" /CANCEL /RESUME /END
	nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\VariousFixes.zip"'

SectionEnd

Section "Project2DFX" p2dfx
	NScurl::http GET "https://github.com/ThirteenAG/III.VC.SA.IV.Project2DFX/releases/download/gtaiv/IV.Project2DFX.zip" "$EXEDIR\Resources\.temp\p2dfx.zip" /CANCEL /RESUME /END
	SetOutPath "$INSTDIR\plugins"
	nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\p2dfx.zip"'
	SetOutPath $INSTDIR
	Delete "$INSTDIR\plugins\readme.txt"
SectionEnd

Section "Ash_735's Higher Resolution Vehicle Pack" vp
NScurl::http GET "https://files.gamebanana.com/mods/complete_edition_vehicle_pack.zip" "$EXEDIR\Resources\.temp\vehiclepack.zip" /CANCEL /RESUME /END
SetOutPath "$INSTDIR\update"
nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\vehiclepack.zip"'
SetOutPath "$INSTDIR"
WriteINIStr "$INSTDIR\plugins\GTAIV.EFLC.FusionFix.ini" BudgetedIV VehicleBudget 120000000
SectionEnd

Section "Ash_735's Higher Resolution Miscellaneous Pack" mp
NScurl::http GET "https://files.gamebanana.com/mods/ash_hires_misc11.zip" "$EXEDIR\Resources\.temp\miscpack.zip" /CANCEL /RESUME /END
nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\miscpack.zip"'
SectionEnd

SectionGroup /e "Console Visuals"

Section "Fusion Console Vegetation"
NScurl::http GET "https://github.com/Tomasak/Console-Visuals/releases/download/release/Fusion.Console.Vegetation.zip" "$EXEDIR\Resources\.temp\Fusion.Console.Vegetation.zip" /CANCEL /RESUME /END
nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\Fusion.Console.Vegetation.zip"'
SectionEnd

Section "Console Select Menu"
NScurl::http GET "https://github.com/gennariarmando/iv-console-select-menu/releases/latest/download/ConsoleSelectMenuIV.zip" "$EXEDIR\Resources\.temp\Console.Select.Menu.zip" /CANCEL /RESUME /END
nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\Console.Select.Menu.zip"'
SectionEnd

Section "Console Peds"
NScurl::http GET "https://github.com/Tomasak/Console-Visuals/releases/download/release/Console.Peds.zip" "$EXEDIR\Resources\.temp\Console.Peds.zip" /CANCEL /RESUME /END
nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\Console.Peds.zip"'
SectionEnd

Section "Console Loading Screens"
NScurl::http GET "https://github.com/Tomasak/Console-Visuals/releases/download/release/Console.Loading.Screens.zip" "$EXEDIR\Resources\.temp\Console.Loading.Screens.zip" /CANCEL /RESUME /END
nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\Console.Loading.Screens.zip"'
SectionEnd

Section "Console Lights"
NScurl::http GET "https://github.com/Tomasak/Console-Visuals/releases/download/release/Console.Lights.zip" "$EXEDIR\Resources\.temp\Console.Lights.zip" /CANCEL /RESUME /END
nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\Console.Lights.zip"'
SectionEnd

Section /o "Console HUD"
NScurl::http GET "https://github.com/Tomasak/Console-Visuals/releases/download/release/Console.HUD.zip" "$EXEDIR\Resources\.temp\Console.HUD.zip" /CANCEL /RESUME /END
nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\Console.HUD.zip"'
SectionEnd

Section "Console Fences"
NScurl::http GET "https://github.com/Tomasak/Console-Visuals/releases/download/release/Console.Fences.zip" "$EXEDIR\Resources\.temp\Console.Fences.zip" /CANCEL /RESUME /END
nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\Console.Fences.zip"'
SectionEnd

Section "Console Clothing"
NScurl::http GET "https://github.com/Tomasak/Console-Visuals/releases/download/release/Console.Clothing.zip" "$EXEDIR\Resources\.temp\Console.Clothing.zip" /CANCEL /RESUME /END
nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\Console.Clothing.zip"'
SectionEnd

Section "Console Anims"
NScurl::http GET "https://github.com/Tomasak/Console-Visuals/releases/download/release/Console.Anims.zip" "$EXEDIR\Resources\.temp\Console.Anims.zip" /CANCEL /RESUME /END
nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\Console.Anims.zip"'
SectionEnd

SectionGroupEnd

SectionGroup /e "Radio Restoration" grp1
Section "-Base Files" radiorestorer
	SetOutPath $INSTDIR
   ;Archive hash check
	
	redownload:
	
	RMDir /r "$EXEDIR\Resources\Radio Restorer\"
	
	NScurl::http GET "https://github.com/Tomasak/GTA-Downgraders/releases/download/data/data1.dat" "$EXEDIR\Resources\Radio Restorer\data1.dat" /CANCEL /RESUME /END
	NScurl::http GET "https://github.com/Tomasak/GTA-Downgraders/releases/download/data/patch1.dat" "$EXEDIR\Resources\Radio Restorer\patch1.dat" /CANCEL /RESUME /END
	NScurl::http GET "https://github.com/Tomasak/GTA-Downgraders/releases/download/data/patch2.dat" "$EXEDIR\Resources\Radio Restorer\patch2.dat" /CANCEL /RESUME /END
	NScurl::http GET "https://github.com/Tomasak/GTA-Downgraders/releases/download/data/hashes.ini" "$EXEDIR\Resources\Radio Restorer\hashes.ini" /CANCEL /RESUME /END
  
	; DetailPrint "Checking hashes of archives..."
	; FindFirst $6 $7 "$EXEDIR\Resources\Radio Restorer\*.dat"
	; loop:
	; StrCmp $7 "" done
	; HashInfo::GetFileCRCHash "CRC-32" "$EXEDIR\Resources\Radio Restorer\$7"
	; Pop $8
	; ReadINIStr $9 "$EXEDIR\Resources\Radio Restorer\hashes.ini" "Archives" "$7"
	; ${If} $9 != $8
		; MessageBox MB_RETRYCANCEL "Hashes of DATs incorrect, press yes to redownload archives or cancel to cancel the installation of radio restorer" IDRETRY redownload IDCANCEL installerfail_1
	; ${EndIf}
	; DetailPrint "Hash of $7 is $8 [CORRECT]"
	; FindNext $6 $7
	; Goto loop
	; done:
	; FindClose $0
	
  ${If} ${FileExists} "$INSTDIR\update\pc\audio\config\game.dat16"
  MessageBox MB_YESNO "Radio files detected in overload folder! It is likely an older version of the Radio Restoration mod was installed. If you want to remove old files, press yes. WARNING: This will also remove previously installed audio mods." IDYES true IDNO false
  true:
	RMDir /r "$INSTDIR\update\pc\audio\"
	RMDir /r "$INSTDIR\update\tlad\pc\audio\"
	RMDir /r "$INSTDIR\update\tbogt\pc\audio\"
	DetailPrint "Old files successfully deleted!"
	Goto next
  false:
	DetailPrint "Keeping old files may cause issues in the future."
  ${EndIf}
  
    nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\Radio Restorer\data1.dat"'
  
  next:
  
  HashInfo::GetFileCRCHash "CRC-32" "$INSTDIR\pc\audio\sfx\radio_beat_95.rpf"
  Pop $3
  HashInfo::GetFileCRCHash "CRC-32" "$INSTDIR\pc\audio\sfx\radio_ny_classics.rpf"
  Pop $4
  
  ${If} $3 != "FA77D2CB"
	MessageBox MB_RETRYCANCEL "CRC of one or more radio RPF files is incorrect! Please select an unmodded game folder." IDRETRY retryfolder IDCANCEL installerfail_1
	DetailPrint "CRC of one or more RPF files is incorrect!"
  ${EndIf}
  
  ${If} $4 != "76BFB272"
	MessageBox MB_RETRYCANCEL "CRC of one or more radio RPF files is incorrect! Please select an unmodded game folder." IDRETRY retryfolder IDCANCEL installerfail_1
	DetailPrint "CRC of one or more RPF files is incorrect!"
  ${EndIf}
  
  retrydeltapatch:
  DetailPrint "Patching radio_beat_95.rpf..."
  DetailPrint "Patching radio_ny_classics.rpf..."
  vpatch::vpatchfile "$EXEDIR\Resources\Radio Restorer\patch1.dat" "$INSTDIR\pc\audio\sfx\radio_beat_95.rpf" "$INSTDIR\update\pc\audio\sfx\radio_beat_95.rpf"
  vpatch::vpatchfile "$EXEDIR\Resources\Radio Restorer\patch2.dat" "$INSTDIR\pc\audio\sfx\radio_ny_classics.rpf" "$INSTDIR\update\pc\audio\sfx\radio_ny_classics.rpf"
  
  ReadINIStr $8 "$EXEDIR\Resources\Radio Restorer\hashes.ini" "RPFs" "radio_beat_95.rpf"
  HashInfo::GetFileCRCHash "CRC-32" "$INSTDIR\update\pc\audio\sfx\radio_beat_95.rpf"
  Pop $9
  ${If} "$8" != "$9"
	MessageBox MB_RETRYCANCEL "CRC of one or more patched RPF files is incorrect!" IDRETRY retrydeltapatch IDCANCEL installerfail_2
	DetailPrint "CRC of one or more patched RPF files is incorrect!"
  ${EndIf}
  DetailPrint "Hash of radio_beat_95.rpf = $8 [CORRECT]"
  
  ReadINIStr $8 "$EXEDIR\Resources\Radio Restorer\hashes.ini" "RPFs" "radio_ny_classics.rpf"
  HashInfo::GetFileCRCHash "CRC-32" "$INSTDIR\update\pc\audio\sfx\radio_ny_classics.rpf"
  Pop $9
  ${If} "$8" != "$9"
	MessageBox MB_RETRYCANCEL "CRC of one or more patched RPF files is incorrect!" IDRETRY retrydeltapatch IDCANCEL installerfail_2
	DetailPrint "CRC of one or more patched RPF files is incorrect!"
  ${EndIf}
  DetailPrint "Hash of radio_ny_classics.rpf = $8 [CORRECT]"
  StrCpy $rrInstallStatus "1"
  
  Goto downgradeend
  
  installerfail_1:
  DetailPrint "Cancelling installation."
  StrCpy $rrInstallStatus "0"
  Goto downgradeend
  
  retryfolder:
  StrCpy $R9 -1
  Call RelGotoPage
  Abort

  installerfail_2:
  DetailPrint "Installation cancelled, deleting all related files..."
  RMDir /r $EXEDIR\Resources\.temp
  RMDir /r $INSTDIR\update\pc\audio
  RMDir /r $INSTDIR\update\tlad\pc\audio
  RMDir /r $INSTDIR\update\tbogt\pc\audio
  RMDir /r $INSTDIR\update\common\text
  Delete $INSTDIR\update\tbogt\pc\e2_radio.xml
  Delete $INSTDIR\update\tbogt\pc\e2_audio.xml
  Delete $INSTDIR\update\tlad\pc\e1_radio.xml
  StrCpy $rrInstallStatus "0"
  DetailPrint "Radio Restorer nstallation failed. All files related to radio restorer have been deleted. This has also deleted any previous audio/radio mods you may have had..."
  
  downgradeend:
SectionEnd

Section /o "Do not install" g1o0
SectionEnd

Section "Pre-cut songs" g1o1
SectionIn RO
SectionEnd

Section  "Post-cut songs" g1o2

SectionEnd

Section  "Restored beta songs" g1o3
SectionEnd

Section "-Options" opRR
	${If} $rrInstallStatus == "1"
		${If} ${SectionIsSelected} ${g1o1}
		${AndIf} ${SectionIsSelected} ${g1o2}
		${AndIf} ${SectionIsSelected} ${g1o3}
			NScurl::http GET "https://github.com/Tomasak/GTA-Downgraders/releases/download/data/opALL.dat" "$EXEDIR\Resources\Radio Restorer\opALL.dat" /CANCEL /RESUME /END
			nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\Radio Restorer\opALL.dat"'
		${EndIf}
		
		${If} ${SectionIsSelected} ${g1o1}
		${AndIf} ${SectionIsSelected} ${g1o2}
		${AndIfNot} ${SectionIsSelected} ${g1o3}
		NScurl::http GET "https://github.com/Tomasak/GTA-Downgraders/releases/download/data/opCLASSIC.dat" "$EXEDIR\Resources\Radio Restorer\opCLASSIC.dat" /CANCEL /RESUME /END
			nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\Radio Restorer\opCLASSIC.dat"'
		${EndIf}
		
		${If} ${SectionIsSelected} ${g1o1}
		${AndIfNot} ${SectionIsSelected} ${g1o2}
		${AndIfNot} ${SectionIsSelected} ${g1o3}
			NScurl::http GET "https://github.com/Tomasak/GTA-Downgraders/releases/download/data/opVANILLA.dat" "$EXEDIR\Resources\Radio Restorer\opVANILLA.dat" /CANCEL /RESUME /END
			nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\Radio Restorer\opVANILLA.dat"'
		${EndIf}
		
		${If} ${SectionIsSelected} ${g1o1}
		${AndIf} ${SectionIsSelected} ${g1o3}
		${AndIfNot} ${SectionIsSelected} ${g1o2}
			NScurl::http GET "https://github.com/Tomasak/GTA-Downgraders/releases/download/data/opVANILLABETA.dat" "$EXEDIR\Resources\Radio Restorer\opVANILLABETA.dat" /CANCEL /RESUME /END
			nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\Radio Restorer\opVANILLABETA.dat"'
		${EndIf}
	${EndIf}
	
SectionEnd

Section /o "Split radios" g1o4
	NScurl::http GET "https://github.com/Tomasak/GTA-Downgraders/releases/download/data/opSPLITbase.dat" "$EXEDIR\Resources\Radio Restorer\opSPLITbase.dat" /CANCEL /RESUME /END
	nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\Radio Restorer\opSPLITbase.dat"'
	${If} ${SectionIsSelected} ${g1o3}
		NScurl::http GET "https://github.com/Tomasak/GTA-Downgraders/releases/download/data/opSPLITBETA.dat" "$EXEDIR\Resources\Radio Restorer\opSPLITBETA.dat" /CANCEL /RESUME /END
		nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\Radio Restorer\opSPLITBETA.dat"'
	${Else}
		NScurl::http GET "https://github.com/Tomasak/GTA-Downgraders/releases/download/data/opSPLITVANILLA.dat" "$EXEDIR\Resources\Radio Restorer\opSPLITVANILLA.dat" /CANCEL /RESUME /END
		nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\Radio Restorer\opSPLITVANILLA.dat"'
	${EndIf}
SectionEnd

SectionGroupEnd

Section "-Commandline"
	${If} $CommandLineOptionsState == ${BST_CHECKED}
		${If} ${FileExists} "$INSTDIR\commandline.txt"
			Delete "$INSTDIR\commandline.txt"
		${EndIf}
		FileOpen $4 "$INSTDIR\commandline.txt" w
		FileSeek $4 0 END
		${If} $VidMemCheckboxState == ${BST_CHECKED}
			FileWrite $4 "-availablevidmem $VidMemAmount"
		${EndIf}
		${If} $WindowedState == ${BST_CHECKED}
			FileWrite $4 "$\r$\n"
			FileWrite $4 "-windowed"
		${EndIf}
		FileWrite $4 "$\r$\n$AdditionalCommandline"
		FileClose $4
	${EndIf}
SectionEnd

Function .onInit
	InitPluginsDir
	SetRegView 32
	ReadRegStr $INSTDIR HKLM "SOFTWARE\Rockstar Games\Grand Theft Auto IV" "InstallFolder"
FunctionEnd

Function .onSelChange
${If} ${SectionIsSelected} ${g1o0}
	SectionSetFlags ${g1o1} 16
	SectionSetFlags ${g1o2} 16
	SectionSetFlags ${g1o3} 16
	SectionSetFlags ${g1o4} 16
	SectionSetFlags ${radiorestorer} 16
${EndIf} 
${IfNot} ${SectionIsSelected} ${g1o0}
	SectionSetFlags ${g1o1} 17
	
	SectionGetFlags ${g1o2} $0
	
	${If} $0 >= 16
		;IntOp $0 $0 - 16
		SectionSetFlags ${g1o2} 1
	${EndIf}
	
	SectionGetFlags ${g1o3} $0

	${If} $0 >= 16
		;IntOp $0 $0 - 16
		SectionSetFlags ${g1o3} 1
	${EndIf}
	
	SectionGetFlags ${g1o4} $0

	${If} $0 >= 16
		;IntOp $0 $0 - 16
		SectionSetFlags ${g1o4} 0
	${EndIf}
	
	SectionSetFlags ${radiorestorer} 17
${EndIf} 
FunctionEnd

Section "-Delete temp files"
RMDir /r "$EXEDIR\Resources\.temp"
RMDir "$EXEDIR\Resources\.temp"
RMDir /r "$EXEDIR\Resources\Radio Restorer"
RMDir "$EXEDIR\Resources\Radio Restorer"
SectionEnd

;Custom options page
Function OptionsPage
	!insertmacro MUI_HEADER_TEXT "Configuration" "Configure various options for GTA IV"

	nsDialogs::Create 1018
	Pop $0
	${If} $0 == error
    	Abort
	${EndIf}

	${NSD_CreateCheckBox} 0 0 100% 8u "Enable commandline options (will delete old commandline.txt file)"
	Pop $CommandlineOptions

	${NSD_CreateText} 160u 10u 10% 10u "2048"
	Pop $VidMemField
	${NSD_CreateCheckBox} 10u 11u 70% 8u "Set custom video memory amount (in MB):"
	Pop $VidMemCheckbox

	${NSD_CreateCheckbox} 10u 21u 100% 8u "Windowed mode (required for Borderless Windowed option in FusionFix))"
	Pop $Windowed
	
	${NSD_CreateLabel} 10u 34u 100% 8u "Additional custom commandline options:"
	Pop $Label
	${NSD_CreateText} 10u 44u 60% 10u ""
	Pop $AdditionalCommandline

	${If} ${SectionIsSelected} ${dxvk}

		${NSD_CreateLabel} 0 59u 100% 8u "Options for DXVK (DO NOT CHANGE UNLESS YOU KNOW WHAT YOU ARE DOING):"
		${NSD_CreateCheckBox} 10u 69u 100% 8u "Force usage of DXVK-async 1.10.3 (recommended if you have an Intel iGPU)"
		Pop $forceolddxvk
		${NSD_CreateCheckBox} 10u 79u 100% 8u "Detect aspect ratio and add to dxvk.conf (not sure if this works on all systems)"
		Pop $setaspectratio

  		SysInfo::GetVideoController_AdapterCompatibility
  		Pop $0
		${If} $0 == "Intel Corporation"
			${NSD_SetState} $forceolddxvk ${BST_CHECKED}
		${EndIf}

	${EndIf}
	EnableWindow $VidMemField 0
	EnableWindow $VidMemCheckbox 0
	EnableWindow $Windowed 0
	EnableWindow $AdditionalCommandline 0
	EnableWindow $Label 0
	${NSD_OnClick} $CommandlineOptions EnableDisableCommandLineOptions
	${NSD_OnClick} $VidMemCheckbox VideoMemoryOptions
	nsDialogs::Show
FunctionEnd

Function EnableDisableCommandLineOptions
	${NSD_GetState} $CommandlineOptions $CommandlineOptionsState
	${If} $CommandlineOptionsState != ${BST_CHECKED}
		EnableWindow $VidMemField 0
		EnableWindow $VidMemCheckbox 0
		EnableWindow $Windowed 0
		EnableWindow $AdditionalCommandline 0
		EnableWindow $Label 0
	${ElseIf} $CommandlineOptionsState == ${BST_CHECKED}
		EnableWindow $VidMemCheckbox 1
		EnableWindow $Windowed 1
		EnableWindow $AdditionalCommandline 1
		EnableWindow $Label 1
	${EndIf}
FunctionEnd

Function VideoMemoryOptions
	${NSD_GetState} $VidMemCheckbox $VidMemCheckboxState
	${If} $VidMemCheckboxState == ${BST_CHECKED}
		EnableWindow $VidMemField 1
	${ElseIfNot} $VidMemCheckboxState == ${BST_CHECKED}
		EnableWindow $VidMemField 0
	${EndIf}
FunctionEnd

Function OptionsPageLeave
	${NSD_GetState} $Windowed $WindowedState
	${NSD_GetState} $CommandlineOptions $CommandlineOptionsState
	${NSD_GetState} $VidMemCheckbox $VidMemCheckboxState
	${NSD_GetState} $setaspectratio $setaspectratiostate
	${NSD_GetState} $forceolddxvk $forceolddxvkstate
	${If} $VidMemCheckboxState == ${BST_CHECKED}
		${NSD_GetText} $VidMemField $VidMemAmount
	${EndIf}
	${NSD_GetText} $AdditionalCommandline $AdditionalCommandline
FunctionEnd

LangString desc_g1o0 ${LANG_ENGLISH} "Skips installation of the radio restorer."
LangString desc_g1o1 ${LANG_ENGLISH} "This option restores all songs cut in 2018. Keeps only pre-cut Vladivostok playlist."
LangString desc_g1o2 ${LANG_ENGLISH} "This option keeps post-cut Vladivostok songs alongside pre-cut one."
LangString desc_g1o3 ${LANG_ENGLISH} "This option restores 4 cut songs with working DJ lines"
LangString desc_g1o4 ${LANG_ENGLISH} "Removes IV songs in Episodes on shared radios and vice versa. Makes interiors and lap dance in EFLC play same songs/radios as vanilla EFLC. DOES NOT REMOVE IV EXCLUSIVE STATIONS IN EPISODES AND VICE VERSA"
LangString desc_ff ${LANG_ENGLISH} "FusionFix is a modification for the game that fixes multiple game bugs, adds a file overloader (required for this mod) and more."
LangString desc_dxvk ${LANG_ENGLISH} "DXVK translates DirectX calls to Vulkan. It has been reported to drastically improve performance in GTA IV. However, this isn't the case for all systems, so it might not work."
LangString desc_p2dfx ${LANG_ENGLISH} "Project2DFX is a plugin that adds an LOD-light effect to game's world, making the LOD-world look much better."
LangString desc_vf ${LANG_ENGLISH} "Various Fixes is a mod that fixes various bugs in the game."
LangString desc_vp ${LANG_ENGLISH} "This mod adds higher resolution textures to all the vehicles in the game and its DLCs."
LangString desc_mp ${LANG_ENGLISH} "This mod adds higher resolution textures to various objects such as vending machines."

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${g1o1} $(desc_g1o1)
  !insertmacro MUI_DESCRIPTION_TEXT ${g1o2} $(desc_g1o2)
  !insertmacro MUI_DESCRIPTION_TEXT ${g1o3} $(desc_g1o3)
  !insertmacro MUI_DESCRIPTION_TEXT ${g1o4} $(desc_g1o4)
  !insertmacro MUI_DESCRIPTION_TEXT ${g1o0} $(desc_g1o0)
  !insertmacro MUI_DESCRIPTION_TEXT ${ff} $(desc_ff)
  !insertmacro MUI_DESCRIPTION_TEXT ${dxvk} $(desc_dxvk)
  !insertmacro MUI_DESCRIPTION_TEXT ${vf} $(desc_vf)
  !insertmacro MUI_DESCRIPTION_TEXT ${vp} $(desc_vp)
  !insertmacro MUI_DESCRIPTION_TEXT ${mp} $(desc_mp)
!insertmacro MUI_FUNCTION_DESCRIPTION_END