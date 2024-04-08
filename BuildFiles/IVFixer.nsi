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
Section "" ;No components page, name is not important
	InitPluginsDir

  ; Set output path to the installation directory.
  SetOutPath $EXEDIR\data
  
  ;RMDir /r "$EXEDIR\data"
  
  ReadINIStr $1 $EXEDIR\data\version.ini Version ver
  Delete version.ini
  NSISdl::download https://github.com/ICantReadYourMind/IVFixer/releases/latest/download/version.ini version.ini
  ReadINIStr $0 $EXEDIR\data\version.ini Version ver
  SetOutPath $EXEDIR
  ${If} $0 > $1
  NSISdl::download https://github.com/ICantReadYourMind/IVFixer/releases/latest/download/InstallerUpdate.zip InstallerUpdate.zip
  nsisunz::UnzipToLog InstallerUpdate.zip "$EXEDIR"
  Delete InstallerUpdate.zip
  ${EndIf}
  
  ; Put file there
  ExecWait "$EXEDIR\data\main.exe"
  
SectionEnd
