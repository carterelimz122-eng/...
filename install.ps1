# FiveM Mirror Installer - Safe Version
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "        FiveM Mirror Installer         " -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Check admin rights
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Host "⚠ Administrator rights required!" -ForegroundColor Yellow
    Write-Host "   Re-running as administrator..." -ForegroundColor Yellow
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Write-Host "✓ Running as administrator" -ForegroundColor Green
Write-Host ""

# Download DLL
$dllUrl = "https://github.com/nova/fivem-mirror/raw/main/FiveMMirror.dll"
$dllPath = "$env:TEMP\FiveMMirror_$(Get-Random).dll"

Write-Host "📥 Downloading FiveM Mirror..." -ForegroundColor Green
try {
    Invoke-WebRequest -Uri $dllUrl -OutFile $dllPath -UseBasicParsing
    Write-Host "✓ Download complete!" -ForegroundColor Green
} catch {
    Write-Host "✗ Download failed!" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""

# Check for System Informer
$siPaths = @(
    "C:\Program Files\SystemInformer\SystemInformer.exe",
    "C:\Program Files (x86)\SystemInformer\SystemInformer.exe",
    "$env:USERPROFILE\Downloads\SystemInformer.exe"
)

$siFound = $false
foreach ($path in $siPaths) {
    if (Test-Path $path) {
        $siPath = $path
        $siFound = $true
        break
    }
}

if (-not $siFound) {
    Write-Host "⚠ System Informer not found!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please download and install:" -ForegroundColor White
    Write-Host "1. Go to: https://github.com/winsiderss/systeminformer" -ForegroundColor Cyan
    Write-Host "2. Download SystemInformer-2.1.0-x64.zip" -ForegroundColor Cyan
    Write-Host "3. Extract and run SystemInformer.exe" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Then run this installer again." -ForegroundColor White
    pause
    exit 1
}

Write-Host "✓ System Informer found: $siPath" -ForegroundColor Green
Write-Host ""

# Start CMD and inject
Write-Host "🚀 Starting FiveM Mirror..." -ForegroundColor Cyan

# Create CMD window
$cmdProcess = Start-Process cmd.exe -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 1

# Inject DLL
try {
    Start-Process $siPath -ArgumentList "-inject:$($cmdProcess.Id)", "`"$dllPath`"" -Wait -WindowStyle Hidden
    Write-Host "✅ Mirror successfully activated!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to start mirror!" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "          HOW TO USE                   " -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "• Make sure FiveM is running" -ForegroundColor White
Write-Host "• Mirror window should appear" -ForegroundColor White
Write-Host "• F6 = Change FPS (60, 120, 144, 240)" -ForegroundColor White
Write-Host "• F7 = Toggle fullscreen" -ForegroundColor White
Write-Host "• F9 = Show/hide tray icon" -ForegroundColor White
Write-Host ""
Write-Host "To stop: Close the hidden CMD window" -ForegroundColor Yellow
Write-Host ""

# Keep window open
Write-Host "Press any key to close this window..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
