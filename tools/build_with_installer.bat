@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo ========================================
echo  Сборка Tournament Clock + Установщик
echo ========================================
echo.

; ===== ШАГ 1: Проверка Flutter =====
echo [1/4] Проверка Flutter...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ОШИБКА: Flutter не найден!
    echo Установите Flutter с https://flutter.dev
    pause
    exit /b 1
)
echo OK: Flutter найден
echo.

; ===== ШАГ 2: Сборка Windows =====
echo [2/4] Сборка Windows версии...
echo.
flutter build windows --release

if errorlevel 1 (
    echo ОШИБКА: Сборка не удалась!
    pause
    exit /b 1
)
echo OK: Windows версия собрана
echo.

; ===== ШАГ 3: Подготовка папки для установщика =====
echo [3/4] Подготовка файлов для установщика...

; Получаем версию из pubspec.yaml
for /f "tokens=2 delims: " %%a in ('findstr /r "^version:" pubspec.yaml') do set VERSION=%%a
set VERSION=!VERSION:~0,-1!

; Создаем временную папку
set DIST_DIR=build\installer_dist
if exist "%DIST_DIR%" rmdir /s /q "%DIST_DIR%"
mkdir "%DIST_DIR%"

; Копируем собранный exe и все файлы
xcopy /E /I /Y "build\windows\x64\runner\Release\*" "%DIST_DIR%\"

echo OK: Файлы скопированы (версия !VERSION!)
echo.

; ===== ШАГ 4: Создание установщика =====
echo [4/4] Создание установщика...

; Проверяем, установлен ли NSIS
where makensis >nul 2>&1
if errorlevel 1 (
    echo ОШИБКА: NSIS не найден!
    echo.
    echo Установите NSIS:
    echo 1. Скачайте: https://sourceforge.net/projects/nsis/files/NSIS%203/
    echo 2. Установите
    echo 3. Добавьте в PATH или укажите путь к makensis.exe
    echo.
    pause
    exit /b 1
)

; Создаем установщик
makensis -DDIST_DIR="%DIST_DIR%" -DVERSION="!VERSION!" "create_installer.nsi"

if errorlevel 1 (
    echo ОШИБКА: Не удалось создать установщик!
    pause
    exit /b 1
)

; Убираем временную папку
rmdir /s /q "%DIST_DIR%"

echo.
echo ========================================
echo  ГОТОВО!
echo ========================================
echo.
echo Установщик: TournamentClock_!VERSION!_Setup.exe
echo.
echo Чтобы запустить приложение:
echo  - Двойной клик по ярлыку на рабочем столе
echo  - Или: %LOCALAPPDATA%\TournamentClock\tournament_clock.exe
echo.
pause
