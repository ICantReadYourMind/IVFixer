VIProductVersion "1.0.0.0"
VIAddVersionKey "ProductName" "Fixer for Grand Theft Auto IV Complete Edition"
VIAddVersionKey "Comments" "Only for Grand Theft Auto IV Complete Edition"
VIAddVersionKey "CompanyName" "Fusion Team"
VIAddVersionKey "LegalTrademarks" "Fixer for Grand Theft Auto IV Complete Edition is a trademark of Fusion Team"
VIAddVersionKey "LegalCopyright" "Copyright Fusion Team"
VIAddVersionKey "FileDescription" "Fixer for Grand Theft Auto IV Complete Edition"
VIAddVersionKey "FileVersion" "1.0.0"

!define MUI_ICON "${__FILEDIR__}\icon.ico"

!include MUI2.nsh
!include LogicLib.nsh

; The name of the installer
Name "IVFixer"

; The file to write
OutFile "..\Binaries\IVFixer.exe"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

; Build Unicode installer
Unicode True

; The default installation directory
InstallDir $EXEDIR

!insertmacro MUI_PAGE_INSTFILES

; The stuff to install
Section ""
	InitPluginsDir

  SetOutPath $EXEDIR\data
  
  ReadINIStr $1 $EXEDIR\data\version.ini Version ver
  Delete version.ini
  NScurl::http GET "https://github.com/ICantReadYourMind/IVFixer/releases/download/instupdate/version.ini" "$EXEDIR\data\version.ini" /CANCEL /RESUME /END
  ReadINIStr $0 $EXEDIR\data\version.ini Version ver
  SetOutPath $EXEDIR
  ${If} $0 > $1
  ;RMDir /r "$EXEDIR\data"
  NScurl::http GET "https://github.com/ICantReadYourMind/IVFixer/releases/download/instupdate/InstallerUpdate.zip" "$EXEDIR\InstallerUpdate.zip" /CANCEL /RESUME /END
  nsisunz::UnzipToLog InstallerUpdate.zip "$EXEDIR"
  Delete InstallerUpdate.zip
  ${EndIf}

  ExecWait "$EXEDIR\data\main.exe"
  
SectionEnd
