<#
.SYNOPSIS
    workstation-sentinel - Monitors lock state and triggers graceful shutdown if left unattended.
.DESCRIPTION
    Runs when the workstation is locked. Periodically verifies if the system is still locked.
    If unlocked, exits immediately with zero disruption.
    If still locked after TimeoutMinutes, initiates a clean, graceful system shutdown.
#>

param(
    [int]$TimeoutMinutes = 30,
    [int]$WarningSeconds = 60,
    [switch]$Status,
    [switch]$Test
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$logFile = Join-Path $scriptDir "sentinel.log"

function Write-SentinelLog {
    param([string]$Message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $entry = "[$timestamp] $Message"
    try {
        Add-Content -Path $logFile -Value $entry -ErrorAction SilentlyContinue
    } catch {}
    Write-Output $entry
}

function Test-IsWorkstationLocked {
    # In Windows 10/11, LogonUI.exe is spawned exclusively when the workstation
    # is locked, at the sign-in screen, or awaiting PIN/password input.
    # The moment a user unlocks or signs in, Windows immediately terminates LogonUI.exe.
    $logonProc = Get-Process LogonUI -ErrorAction SilentlyContinue
    return [bool]$logonProc
}

if ($Status) {
    $locked = Test-IsWorkstationLocked
    Write-Output "Workstation Locked State: $locked"
    exit 0
}

if ($Test) {
    Write-SentinelLog "Starting in TEST MODE. Lock check interval: 5s, Test duration: 15s."
    $elapsed = 0
    while ($elapsed -lt 15) {
        Start-Sleep -Seconds 5
        $elapsed += 5
        $locked = Test-IsWorkstationLocked
        Write-SentinelLog "Elapsed: ${elapsed}s | Locked: $locked"
        if (-not $locked) {
            Write-SentinelLog "Workstation unlocked. Test complete (Aborted)."
            exit 0
        }
    }
    Write-SentinelLog "Test timeout reached. In live mode, shutdown would trigger here."
    exit 0
}

# --- Production Sentinel Loop ---
Write-SentinelLog "Sentinel activated. Timeout: $TimeoutMinutes min ($($TimeoutMinutes * 60)s). Warning: ${WarningSeconds}s."

$totalSeconds = $TimeoutMinutes * 60
$checkInterval = 10
$elapsedSeconds = 0

# Initial verification: If started while unlocked, abort immediately
if (-not (Test-IsWorkstationLocked)) {
    Write-SentinelLog "Workstation is NOT locked at startup. Self-terminating immediately."
    exit 0
}

while ($elapsedSeconds -lt $totalSeconds) {
    Start-Sleep -Seconds $checkInterval
    $elapsedSeconds += $checkInterval

    # If the user unlocked the PC, abort immediately!
    if (-not (Test-IsWorkstationLocked)) {
        Write-SentinelLog "Workstation unlocked after $elapsedSeconds seconds ($([math]::Round($elapsedSeconds/60, 1)) min). Sentinel safely aborted."
        exit 0
    }
}

# Timer expired and screen is STILL locked: Trigger graceful shutdown
Write-SentinelLog "Threshold reached ($TimeoutMinutes min unattended). Initiating graceful shutdown."

& shutdown.exe /s /f /t $WarningSeconds /c "workstation-sentinel: System was locked and unattended for $TimeoutMinutes minutes. Powering off to save battery. Run 'shutdown /a' to cancel."
