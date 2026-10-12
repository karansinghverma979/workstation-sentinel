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

# Dynamically resolve and inject script path for portable installation
$sentinelScriptPath = Join-Path $scriptDir "sentinel.ps1"
$xmlContent = Get-Content -Path $xmlPath -Raw
$updatedXml = $xmlContent -replace 'File "[^"]*sentinel\.ps1"', "File `"$sentinelScriptPath`""
Set-Content -Path $xmlPath -Value $updatedXml -Encoding Unicode

Write-Host "Registering $taskName in Windows Task Scheduler..." -ForegroundColor Cyan
$result = & schtasks.exe /create /tn $taskName /xml $xmlPath /f

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[SUCCESS] $taskName has been successfully registered!" -ForegroundColor Green
    Write-Host "Trigger: Automatically fires whenever the PC is locked." -ForegroundColor Gray
    Write-Host "Timeout: Shuts down after 30 minutes unattended." -ForegroundColor Gray
    Write-Host "Logs: $scriptDir\sentinel.log" -ForegroundColor Gray
} else {
    Write-Host "`n[ERROR] Failed to register task. Exit code: $LASTEXITCODE" -ForegroundColor Red
}

Write-Host "`nPress any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
