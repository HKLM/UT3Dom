Name "UT3Dom 1.x CleanUp Tool"
InstallDir "$PROGRAMFILES\Unreal Tournament 3"
InstallDirRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{BFA90209-7AFF-4DB6-8E4B-E57305751AD7}" "InstallLocation"
OutFile "G:\dev\UT3Dom1xCleanUp.exe"
Icon "C:\Program Files\NSIS\Contrib\Graphics\Icons\orange-uninstall.ico"
RequestExecutionLevel user
SetCompressor /FINAL /SOLID lzma

!include "LogicLib.nsh"
!include "FileFunc.nsh"
!insertmacro GetParameters
!insertmacro GetOptions
!insertmacro GetExeName
VIProductVersion "1.0.0.1"
VIAddVersionKey "ProductName" "UT3Dom 1.x CleanUp Tool"
VIAddVersionKey "Comments" "Uninstalls older versions of UT3Dom in preperation for version 2.0 or newer. Use /KeepMaps=true to keep your old published stock domination maps."
VIAddVersionKey "FileDescription" "Uninstalls older versions of UT3Dom in preperation for version 2.0 or newer. Use /KeepMaps=true to keep your old published stock domination maps."
VIAddVersionKey "FileVersion" "1.0.0.1"
VIAddVersionKey "ProductVersion" "2.0.0.0"
VIAddVersionKey "LegalCopyright" "© 2009"

Section -UninstallSection
	HideWindow
	SetAutoClose true
	${GetParameters} $R0
  ClearErrors
  ${GetOptions} $R0 "/KeepMaps=" $0
	ClearErrors
	SetShellVarContext current
	StrCpy $R1 0
	${Do}
		Delete "$INSTDIR\UTDomHelp.htm"
		Delete "$INSTDIR\UTMultiTeam-Readme.txt"
		Delete "$INSTDIR\Config\UTDom.ini"
		Delete "$INSTDIR\Localization\DEU\DOM-Cinder.deu"
		Delete "$INSTDIR\Localization\DEU\DOM-Condemned.deu"
		Delete "$INSTDIR\Localization\DEU\UTDom.deu"
		Delete "$INSTDIR\Localization\DEU\VDOM-Downtown.deu"
		Delete "$INSTDIR\Localization\ESN\DOM-Cinder.esn"
		Delete "$INSTDIR\Localization\ESN\DOM-Condemned.esn"
		Delete "$INSTDIR\Localization\ESN\UTDom.esn"
		Delete "$INSTDIR\Localization\ESN\VDOM-Downtown.esn"
		Delete "$INSTDIR\Localization\FRA\DOM-Cinder.fra"
		Delete "$INSTDIR\Localization\FRA\DOM-Condemned.fra"
		Delete "$INSTDIR\Localization\FRA\UTDom.fra"
		Delete "$INSTDIR\Localization\FRA\VDOM-Downtown.fra"
		Delete "$INSTDIR\Localization\INT\DOM-Cinder.int"
		Delete "$INSTDIR\Localization\INT\DOM-Condemned.int"
		Delete "$INSTDIR\Localization\INT\UTDom.int"
		Delete "$INSTDIR\Localization\INT\UTMultiTeam.int"
		Delete "$INSTDIR\Localization\INT\VDOM-Downtown.int"
		Delete "$INSTDIR\Localization\ITA\DOM-Cinder.ita"
		Delete "$INSTDIR\Localization\ITA\DOM-Condemned.ita"
		Delete "$INSTDIR\Localization\ITA\UTDom.ita"
		Delete "$INSTDIR\Localization\ITA\VDOM-Downtown.ita"
		Delete "$INSTDIR\Localization\RUS\DOM-Cinder.rus"
		Delete "$INSTDIR\Localization\RUS\DOM-Condemned.rus"
		Delete "$INSTDIR\Localization\RUS\UTDom.rus"
		Delete "$INSTDIR\Localization\RUS\VDOM-Downtown.rus"
		Delete "$INSTDIR\Published\CookedPC\DOM_Content.upk"
		Delete "$INSTDIR\Published\CookedPC\DOM_MTContent.upk"
		Delete "$INSTDIR\Published\CookedPC\UTDom.u"
		Delete "$INSTDIR\Published\CookedPC\UTDomUI.u"
		Delete "$INSTDIR\Published\CookedPC\UTDomWebAdmin.u"
		Delete "$INSTDIR\Published\CookedPC\UTMultiTeam.u"
		Delete "$INSTDIR\Published\CookedPC\UTMultiTeamContent.u"
		Delete "$INSTDIR\Published\CookedPC\UI_UT3Dom.upk"
		Delete "$INSTDIR\Published\CookedPC\UTMT_Content.upk"
		StrCmp "$0" "true" +30 0
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\CDOM-Contrast.ini"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\CDOM-Contrast.ut3"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\CDOM-Contrast_LOC_int.upk"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-AKI.ini"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-AKI.ut3"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-AKI_LOC_int.upk"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Apodos.ini"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Apodos.ut3"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Apodos_LOC_int.upk"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Cidom.ini"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Cidom.ut3"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Cidom_LOC_int.upk"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Cinder.ini"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Cinder.ut3"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Cinder_LOC_int.upk"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Condemned.ini"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Condemned.ut3"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Condemned2.ini"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Condemned2.ut3"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Condemned2_LOC_int.upk"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Condemned_LOC_int.upk"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Ghardhen.ini"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Ghardhen.ut3"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Ghardhen_LOC_int.upk"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Lament.ini"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Lament.ut3"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\DOM-Lament_LOC_int.upk"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\VDOM-Downtown.ini"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\VDOM-Downtown.ut3"
		Delete "$INSTDIR\Published\CookedPC\CustomMaps\VDOM-Downtown_LOC_int.upk"
		Delete "$INSTDIR\Published\CookedPC\Script\UTDom.u"
		Delete "$INSTDIR\Published\CookedPC\Script\UTDomUI.u"
		Delete "$INSTDIR\Published\CookedPC\Script\UTDomWebAdmin.u"
		Delete "$INSTDIR\Published\CookedPC\Script\UTMultiTeam.u"
		Delete "$INSTDIR\Published\CookedPC\Script\UTMultiTeamContent.u"
		Delete "$INSTDIR\Published\CookedPC\UI\UI_UT3Dom.upk"
		Delete "$INSTDIR\Published\CookedPC\UTMultiTeam\UTMT_Content.upk"
		Delete "$INSTDIR\Unpublished\CookedPC\DOM_Content.upk"
		Delete "$INSTDIR\Unpublished\CookedPC\DOM_MTContent.upk"
		Delete "$INSTDIR\Unpublished\CookedPC\UTMT_Content.upk"
		Delete "$INSTDIR\Unpublished\CookedPC\UTDom.u"
		Delete "$INSTDIR\Unpublished\CookedPC\UTDomUI.u"
		Delete "$INSTDIR\Unpublished\CookedPC\UTDomWebAdmin.u"
		Delete "$INSTDIR\Unpublished\CookedPC\UTMultiTeam.u"
		Delete "$INSTDIR\Unpublished\CookedPC\UTMultiTeamContent.u"
		Delete "$INSTDIR\Unpublished\CookedPC\Script\UTDom.u"
		Delete "$INSTDIR\Unpublished\CookedPC\Script\UTDomUI.u"
		Delete "$INSTDIR\Unpublished\CookedPC\Script\UTDomWebAdmin.u"
		Delete "$INSTDIR\Unpublished\CookedPC\Script\UTMultiTeam.u"
		Delete "$INSTDIR\Unpublished\CookedPC\Script\UTMultiTeamContent.u"
		Delete "$INSTDIR\Unpublished\CookedPC\UI\UI_UT3Dom.upk"
		Delete "$INSTDIR\Unpublished\CookedPC\UTMultiTeam\UTMT_Content.upk"
		Delete "$INSTDIR\CookedPC\DOM_Content.upk"
		Delete "$INSTDIR\CookedPC\DOM_MTContent.upk"
		Delete "$INSTDIR\CookedPC\UTMT_Content.upk"
		Delete "$INSTDIR\CookedPC\UTDom.u"
		Delete "$INSTDIR\CookedPC\UTDomUI.u"
		Delete "$INSTDIR\CookedPC\UTDomWebAdmin.u"
		Delete "$INSTDIR\CookedPC\UTMultiTeam.u"
		Delete "$INSTDIR\CookedPC\UTMultiTeamContent.u"
		Delete "$INSTDIR\CookedPC\UI_UT3Dom.upk"
		Delete "$INSTDIR\CookedPC\Script\UTDom.u"
		Delete "$INSTDIR\CookedPC\Script\UTDomUI.u"
		Delete "$INSTDIR\CookedPC\Script\UTDomWebAdmin.u"
		Delete "$INSTDIR\CookedPC\Script\UTMultiTeam.u"
		Delete "$INSTDIR\CookedPC\Script\UTMultiTeamContent.u"
		Delete "$INSTDIR\CookedPC\UI\UI_UT3Dom.upk"
		Delete "$INSTDIR\CookedPC\UTMultiTeam\UTMT_Content.upk"
		Delete "$INSTDIR\Uninstall UT3Dom.exe"
		IntOp $R1 $R1 + 1
		IntCmp $R1 2 0 +2 +2
		SetShellVarContext all
		StrCpy $INSTDIR "$DOCUMENTS\My Games\Unreal Tournament 3\UTGame"
	${LoopUntil} $R1 >= 3

	IfSilent +2
	MessageBox MB_OK "Done!"
	; Delete self
	${GetExeName} $R0
	Delete "$R0"
SectionEnd

Function .onInit
	HideWindow
	ClearErrors
	ReadRegStr $1 HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{E26B14B1-A35B-4F41-A585-5DEF4A0D2153}" "InstallLocation"
	IfErrors +4
	StrLen $2 "$1"
	IntCmp $2 4 0 0 +2
		Abort
	ClearErrors
	IfFileExists "$INSTDIR\Binaries\UT3.exe" End 
	ReadRegStr $1 HKEY_CURRENT_USER "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\InstallShield_{BFA90209-7AFF-4DB6-8E4B-E57305751AD7}" "InstallLocation"
	IfErrors +2
	IfFileExists "$1\Binaries\UT3.exe" FoundIt	
	ClearErrors
	ReadRegStr $1 HKEY_CURRENT_USER "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\InstallShield_{BFA90209-7AFF-4DB6-8E4B-E57305751AD7}" "InstallLocation"
	IfErrors +2
	IfFileExists "$1\Binaries\UT3.exe" FoundIt	
	ClearErrors
	ReadRegStr $1 HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{BFA90209-7AFF-4DB6-8E4B-E57305751AD7}" "InstallLocation"
	IfErrors +2
	IfFileExists "$1\Binaries\UT3.exe" FoundIt
	ClearErrors
	ReadRegStr $1 HKEY_LOCAL_MACHINE "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{BFA90209-7AFF-4DB6-8E4B-E57305751AD7}" "InstallLocation"
	IfErrors +2
	IfFileExists "$1\Binaries\UT3.exe" FoundIt
	ClearErrors
	ReadRegStr $1 HKEY_CURRENT_USER "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\InstallShield_{C019D439-E7F8-49EB-85FA-6D0C8CCBDA23}" "InstallLocation"
	IfErrors +2
	IfFileExists "$1\Binaries\UT3.exe" FoundIt
	ClearErrors
	ReadRegStr $1 HKEY_CURRENT_USER "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\InstallShield_{C019D439-E7F8-49EB-85FA-6D0C8CCBDA23}" "InstallLocation"
	IfErrors +2
	IfFileExists "$1\Binaries\UT3.exe" FoundIt
	ClearErrors
	ReadRegStr $1 HKEY_CURRENT_USER "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\InstallShield_{A007C579-B78D-4FDE-A85A-16987A251E53}" "InstallLocation"
	IfErrors +2
	IfFileExists "$1\Binaries\UT3.exe" FoundIt
	ClearErrors
	ReadRegStr $1 HKEY_CURRENT_USER "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\InstallShield_{A007C579-B78D-4FDE-A85A-16987A251E53}" "InstallLocation"
	IfErrors +2
	IfFileExists "$1\Binaries\UT3.exe" FoundIt
	ClearErrors
	ReadRegStr $1 HKEY_CURRENT_USER "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\InstallShield_{FDBBAF14-5ED8-49B7-A5BE-1C35668B074D}" "InstallLocation"
	IfErrors +2
	IfFileExists "$1\Binaries\UT3.exe" FoundIt
	ClearErrors
	ReadRegStr $1 HKEY_CURRENT_USER "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\InstallShield_{FDBBAF14-5ED8-49B7-A5BE-1C35668B074D}" "InstallLocation"
	IfErrors +2
	IfFileExists "$1\Binaries\UT3.exe" FoundIt
	ClearErrors
	ReadRegStr $1 HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{C019D439-E7F8-49EB-85FA-6D0C8CCBDA23}" "InstallLocation"
	IfErrors +2
	IfFileExists "$1\Binaries\UT3.exe" FoundIt
	ClearErrors
	ReadRegStr $1 HKEY_LOCAL_MACHINE "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{C019D439-E7F8-49EB-85FA-6D0C8CCBDA23}" "InstallLocation"
	IfErrors +2
	IfFileExists "$1\Binaries\UT3.exe" FoundIt
	ClearErrors
	ReadRegStr $1 HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{A007C579-B78D-4FDE-A85A-16987A251E53}" "InstallLocation"
	IfErrors +2
	IfFileExists "$1\Binaries\UT3.exe" FoundIt
	ClearErrors
	ReadRegStr $1 HKEY_LOCAL_MACHINE "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{A007C579-B78D-4FDE-A85A-16987A251E53}" "InstallLocation"
	IfErrors +2
	IfFileExists "$1\Binaries\UT3.exe" FoundIt
	ClearErrors
	ReadRegStr $1 HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{FDBBAF14-5ED8-49B7-A5BE-1C35668B074D}" "InstallLocation"
	IfErrors +2
	IfFileExists "$1\Binaries\UT3.exe" FoundIt
	ClearErrors
	ReadRegStr $1 HKEY_LOCAL_MACHINE "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{FDBBAF14-5ED8-49B7-A5BE-1C35668B074D}" "InstallLocation"
	IfErrors +2
	IfFileExists "$1\Binaries\UT3.exe" FoundIt 
	Abort "Failed to locate your Unreal Tournament 3 installation.$\r$\nYou may have to re-install UT3 to fix your registry entries."
	FoundIt:
		StrCpy $INSTDIR $1
	End:
		ClearErrors
		
FunctionEnd
