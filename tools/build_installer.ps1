# Build Tournament Clock + NSIS Installer

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Build Tournament Clock + Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$PROJECT_ROOT = Split-Path -Parent $PSScriptRoot
$NSIS_PATH = "C:\Users\Lenovo\NSIS"
$env:Path += ";$NSIS_PATH"

# STEP 1: Check Flutter
Write-Host "[1/4] Checking Flutter..." -ForegroundColor Yellow
try {
    flutter --version | Out-Null
    Write-Host "OK: Flutter found" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Flutter not found!" -ForegroundColor Red
    pause
    exit 1
}
Write-Host ""

# STEP 2: Build Windows
Write-Host "[2/4] Building Windows version..." -ForegroundColor Yellow
Write-Host ""
Set-Location $PROJECT_ROOT
flutter build windows --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    pause
    exit 1
}
Write-Host "OK: Windows version built" -ForegroundColor Green
Write-Host ""

# STEP 3: Prepare installer files
Write-Host "[3/4] Preparing installer files..." -ForegroundColor Yellow

# Get version from pubspec.yaml
$pubspec = Get-Content "pubspec.yaml" -Raw
$versionMatch = [regex]::Match($pubspec, "version:\s+(\d+\.\d+\.\d+)")
if ($versionMatch.Success) {
    $VERSION = $versionMatch.Groups[1].Value
} else {
    $VERSION = "1.0.0"
}

# Create temp directory
$DIST_DIR = Join-Path $PROJECT_ROOT "build\installer_dist"
if (Test-Path $DIST_DIR) { Remove-Item $DIST_DIR -Recurse -Force }
New-Item -ItemType Directory -Path $DIST_DIR | Out-Null

# Copy built files
$SOURCE_DIR = Join-Path $PROJECT_ROOT "build\windows\x64\runner\Release"
Copy-Item "$SOURCE_DIR\*" -Destination $DIST_DIR -Recurse -Force

Write-Host "OK: Files copied (version $VERSION)" -ForegroundColor Green
Write-Host "DIST_DIR=$DIST_DIR" -ForegroundColor Gray
Write-Host "VERSION=$VERSION" -ForegroundColor Gray
Write-Host ""

# STEP 4: Create installer
Write-Host "[4/4] Creating installer..." -ForegroundColor Yellow

$TOOLS_DIR = Join-Path $PROJECT_ROOT "tools"
$NSIS_SCRIPT = Join-Path $TOOLS_DIR "create_installer.nsi"
$MAKENSIS = Join-Path $NSIS_PATH "makensis.exe"

Write-Host "Running: $MAKENSIS -DDIST_DIR=`"$DIST_DIR`" -DVERSION=`"$VERSION`" $NSIS_SCRIPT" -ForegroundColor Gray

& $MAKENSIS -DDIST_DIR="$DIST_DIR" -DVERSION="$VERSION" $NSIS_SCRIPT

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create installer!" -ForegroundColor Red
    pause
    exit 1
}

# Clean up temp directory
Remove-Item $DIST_DIR -Recurse -Force

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DONE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installer: TournamentClock_${VERSION}_Setup.exe" -ForegroundColor White
Write-Host "Path: $TOOLS_DIR" -ForegroundColor Gray
Write-Host ""
Write-Host "To run the app:" -ForegroundColor Yellow
Write-Host "  - Double-click desktop shortcut" -ForegroundColor Gray
Write-Host "  - Or: %LOCALAPPDATA%\TournamentClock\tournament_clock.exe" -ForegroundColor Gray
Write-Host ""
pause
