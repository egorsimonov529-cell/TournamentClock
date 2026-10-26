# Deploy fix for seating booking
$ErrorActionPreference = "Stop"

$Password = "4#9inC3%MYZ84F9f"
$Server = "188.225.81.114"
$User = "user"
$RemoteBase = "/var/www/poker-club/"

Write-Host "`n🚀 Starting deployment..." -ForegroundColor Green

# Try pscp from common locations
$pscpLocations = @(
    "C:\Program Files\PuTTY\pscp.exe",
    "C:\Program Files (x86)\PuTTY\pscp.exe",
    "C:\PuTTY\pscp.exe",
    "pscp.exe"  # If in PATH
)

$pscp = $null
foreach ($loc in $pscpLocations) {
    if (Test-Path $loc) {
        $pscp = $loc
        Write-Host "✅ Found pscp: $pscp" -ForegroundColor Green
        break
    }
}

if (-not $pscp) {
    Write-Host "`n❌ pscp (PuTTY) not found!" -ForegroundColor Red
    Write-Host "Please install PuTTY from: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html" -ForegroundColor White
    Write-Host "Or use WinSCP to upload files manually:`n" -ForegroundColor White
    Write-Host "  Server: $Server" -ForegroundColor Cyan
    Write-Host "  User: $User" -ForegroundColor Cyan
    Write-Host "  Password: $Password" -ForegroundColor Cyan
    Write-Host "  Remote path: $RemoteBase" -ForegroundColor Cyan
    Write-Host "`nFiles to upload:" -ForegroundColor Yellow
    Write-Host "  1. backend\src\routes\tableRoutes.js → /var/www/poker-club/backend/src/routes/" -ForegroundColor White
    Write-Host "  2. backend\check-registration.js → /var/www/poker-club/backend/" -ForegroundColor White
    Write-Host "  3. backend\check-db.sql → /var/www/poker-club/backend/" -ForegroundColor White
    exit 1
}

# Upload files
Write-Host "`n📤 Uploading files..." -ForegroundColor Yellow

try {
    Write-Host "  → tableRoutes.js" -NoNewline
    & $pscp -pw $Password "backend\src\routes\tableRoutes.js" "${User}@${Server}:${RemoteBase}backend\src\routes\"
    Write-Host " ✅" -ForegroundColor Green
} catch {
    Write-Host " ❌ $($_.Exception.Message)" -ForegroundColor Red
}

try {
    Write-Host "  → check-registration.js" -NoNewline
    & $pscp -pw $Password "backend\check-registration.js" "${User}@${Server}:${RemoteBase}backend\"
    Write-Host " ✅" -ForegroundColor Green
} catch {
    Write-Host " ❌ $($_.Exception.Message)" -ForegroundColor Red
}

try {
    Write-Host "  → check-db.sql" -NoNewline
    & $pscp -pw $Password "backend\check-db.sql" "${User}@${Server}:${RemoteBase}backend\"
    Write-Host " ✅" -ForegroundColor Green
} catch {
    Write-Host " ❌ $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n✅ Upload complete!" -ForegroundColor Green
Write-Host "`n📋 Next steps on server:`n" -ForegroundColor Cyan
Write-Host "  SSH to server: ssh $User@$Server" -ForegroundColor White
Write-Host "  Restart backend:" -ForegroundColor White
Write-Host "    cd /var/www/poker-club/backend" -ForegroundColor Gray
Write-Host "    pm2 restart poker-backend --update-env" -ForegroundColor Gray
Write-Host "`n  Check database:" -ForegroundColor White
Write-Host "    node check-registration.js" -ForegroundColor Gray
Write-Host "    # OR" -ForegroundColor Gray
Write-Host "    psql -U poker_club -d poker_club -f check-db.sql" -ForegroundColor Gray
