<#
.SYNOPSIS
    Installs and registers workstation-sentinel in Windows Task Scheduler.
#>

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$xmlPath = Join-Path $scriptDir "register_task.xml"
$logPath = Join-Path $scriptDir "install.log"
$taskName = "workstation-sentinel"

function Log-Message {
    param([string]$Msg)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $line = "[$timestamp] $Msg"
    Write-Host $line
    Add-Content -Path $logPath -Value $line -ErrorAction SilentlyContinue
}

# Check for Administrator elevation
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Log-Message "Non-elevated shell detected. Requesting UAC elevation..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Log-Message "Running with Administrator privileges."

# Dynamically resolve and inject script path
$sentinelScriptPath = Join-Path $scriptDir "sentinel.ps1"
$xmlContent = Get-Content -Path $xmlPath -Raw
# Strip <?xml ...?> declaration header to prevent in-memory MSXML encoding conflict
$xmlContent = $xmlContent -replace '<\?xml.*?\?>\s*', ''
$resolvedXml = $xmlContent -replace 'File "[^"]*sentinel\.ps1"', "File `"$sentinelScriptPath`""

Log-Message "Registering $taskName in Windows Task Scheduler..."
try {
    $null = Register-ScheduledTask -TaskName $taskName -Xml $resolvedXml -Force -ErrorAction Stop
    Log-Message "[SUCCESS] $taskName has been successfully registered!"
    Log-Message "Trigger: Automatically fires whenever the PC is locked."
    Log-Message "Timeout: Shuts down after 30 minutes unattended."
} catch {
    Log-Message "[ERROR] Failed to register task: $_"
}

Write-Host "`nPress any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
