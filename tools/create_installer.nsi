; NSIS скрипт для Tournament Clock
; Вызов: makensis -DDIST_DIR="path\to\dist" -DVERSION="1.0.0" create_installer.nsi

!define APP_NAME "Tournament Clock"
!define COMPANY_NAME "Tournament Clock"

; Подключаем MUI2 (графический интерфейс)
!include "MUI2.nsh"

Unicode true
SetCompressor /SOLID lzma
RequestExecutionLevel user

; Параметры передаются из PowerShell
!ifndef DIST_DIR
    !define DIST_DIR "."
!endif

!ifndef VERSION
    !define VERSION "1.0.0"
!endif

!define INSTALLER_NAME "TournamentClock_${VERSION}_Setup.exe"

OutFile "${INSTALLER_NAME}"
InstallDir "$LOCALAPPDATA\TournamentClock"

; Страницы мастера установки
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "Russian"
!insertmacro MUI_LANGUAGE "English"

Caption "Установка ${APP_NAME} v${VERSION}"

Section "Основное приложение"
    SetOutPath "$INSTDIR"
    
    ; Копируем всё из папки dist (собранный Flutter)
    File "${DIST_DIR}\*"
    
    ; Ярлык на рабочий стол
    CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\tournament_clock.exe"
    
    ; Ярлык в меню Пуск
    CreateDirectory "$SMPROGRAMS\TournamentClock"
    CreateShortCut "$SMPROGRAMS\TournamentClock\${APP_NAME}.lnk" "$INSTDIR\tournament_clock.exe"
    CreateShortCut "$SMPROGRAMS\TournamentClock\Uninstall.lnk" "$INSTDIR\uninstall.exe"
    
    ; Запись в реестр для удаления
    WriteUninstaller "$INSTDIR\uninstall.exe"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
        "DisplayName" "${APP_NAME}"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
        "UninstallString" "$INSTDIR\uninstall.exe"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
        "DisplayVersion" "${VERSION}"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
        "Publisher" "${COMPANY_NAME}"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
        "InstallLocation" "$INSTDIR"
    
SectionEnd

Section "Uninstall"
    ; Удаляем ярлыки
    Delete "$DESKTOP\${APP_NAME}.lnk"
    Delete "$SMPROGRAMS\TournamentClock\${APP_NAME}.lnk"
    Delete "$SMPROGRAMS\TournamentClock\Uninstall.lnk"
    RMDir "$SMPROGRAMS\TournamentClock"
    
    ; Удаляем файлы
    Delete "$INSTDIR\*"
    RMDir "$INSTDIR"
    
    ; Удаляем из реестра
    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
SectionEnd
