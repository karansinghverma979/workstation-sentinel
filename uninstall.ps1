<#
.SYNOPSIS
    Unregisters and removes workstation-sentinel from Windows Task Scheduler.
#>

$taskName = "workstation-sentinel"

# Check for Administrator elevation
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Elevating permissions to remove Task Scheduler job..." -ForegroundColor Cyan
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Write-Host "Removing $taskName from Windows Task Scheduler..." -ForegroundColor Cyan
$result = & schtasks.exe /delete /tn $taskName /f

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[SUCCESS] $taskName has been removed from your system." -ForegroundColor Green
} else {
    Write-Host "`n[NOTICE] Task was not found or already removed." -ForegroundColor Yellow
}

Write-Host "`nPress any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
