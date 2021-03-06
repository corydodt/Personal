; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "Virtual Dub"
!define PRODUCT_VERSION "1.6.5"
!define PRODUCT_PUBLISHER "Avery Lee"
!define PRODUCT_WEB_SITE "http://virtualdub.org"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\auxsetup.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\VirtualDub.exe"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "virtualdub-${PRODUCT_VERSION}-Setup.exe"
InstallDir "$PROGRAMFILES\VirtualDub"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Section "MainSection" SEC01
  SetOutPath "$INSTDIR"
  SetOverwrite try
  File "vdub\auxsetup.exe"
  SetOutPath "$INSTDIR\aviproxy"
  File "vdub\aviproxy\proxyoff.reg"
  File "vdub\aviproxy\proxyon.reg"
  File "vdub\aviproxy\readme.txt"
  SetOutPath "$INSTDIR"
  File "vdub\copying"
  SetOutPath "$INSTDIR\plugins"
  File "vdub\plugins\readme.txt"
  SetOutPath "$INSTDIR"
  File "vdub\vdicmdrv.dll"
  File "vdub\vdremote.dll"
  File "vdub\vdsvrlnk.dll"
  File "vdub\vdub.exe"
  File "vdub\VirtualDub.exe"
  CreateShortCut "$SMPROGRAMS\Virtual Dub.lnk" "$INSTDIR\VirtualDub.exe"
  File "vdub\VirtualDub.vdhelp"
  File "vdub\VirtualDub.vdi"
SectionEnd

Section -AdditionalIcons
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateDirectory "$SMPROGRAMS\Virtual Dub"
  CreateShortCut "$SMPROGRAMS\Virtual Dub\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\Virtual Dub\Uninstall.lnk" "$INSTDIR\uninst.exe"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\auxsetup.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\auxsetup.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd


Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\VirtualDub.vdi"
  Delete "$INSTDIR\VirtualDub.vdhelp"
  Delete "$INSTDIR\VirtualDub.exe"
  Delete "$INSTDIR\vdub.exe"
  Delete "$INSTDIR\vdsvrlnk.dll"
  Delete "$INSTDIR\vdremote.dll"
  Delete "$INSTDIR\vdicmdrv.dll"
  Delete "$INSTDIR\plugins\readme.txt"
  Delete "$INSTDIR\copying"
  Delete "$INSTDIR\aviproxy\readme.txt"
  Delete "$INSTDIR\aviproxy\proxyon.reg"
  Delete "$INSTDIR\aviproxy\proxyoff.reg"
  Delete "$INSTDIR\auxsetup.exe"

  Delete "$SMPROGRAMS\Virtual Dub\Uninstall.lnk"
  Delete "$SMPROGRAMS\Virtual Dub\Website.lnk"
  Delete "$SMPROGRAMS\Virtual Dub.lnk"

  RMDir "$SMPROGRAMS\Virtual Dub"
  RMDir "$INSTDIR\plugins"
  RMDir "$INSTDIR\aviproxy"
  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd
