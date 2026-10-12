<#
.SYNOPSIS
    Installs and registers workstation-sentinel in Windows Task Scheduler.
#>

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$xmlPath = Join-Path $scriptDir "register_task.xml"
$taskName = "workstation-sentinel"

# Check for Administrator elevation
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Elevating permissions to register Task Scheduler job..." -ForegroundColor Cyan
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# Dynamically resolve and inject script path
$sentinelScriptPath = Join-Path $scriptDir "sentinel.ps1"
$xmlContent = Get-Content -Path $xmlPath -Raw
# Strip <?xml ...?> declaration header to prevent in-memory MSXML encoding conflict
$xmlContent = $xmlContent -replace '<\?xml.*?\?>\s*', ''
$resolvedXml = $xmlContent -replace 'File "[^"]*sentinel\.ps1"', "File `"$sentinelScriptPath`""

Write-Host "Registering $taskName in Windows Task Scheduler..." -ForegroundColor Cyan
try {
    $null = Register-ScheduledTask -TaskName $taskName -Xml $resolvedXml -Force -ErrorAction Stop
    Write-Host "`n[SUCCESS] $taskName has been successfully registered!" -ForegroundColor Green
    Write-Host "Trigger: Automatically fires whenever the PC is locked." -ForegroundColor Gray
    Write-Host "Timeout: Shuts down after 30 minutes unattended." -ForegroundColor Gray
    Write-Host "Logs: $scriptDir\sentinel.log" -ForegroundColor Gray
} catch {
    Write-Host "`n[ERROR] Failed to register task: $_" -ForegroundColor Red
}

Write-Host "`nPress any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
