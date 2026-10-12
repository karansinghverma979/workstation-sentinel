# ⚙️ Configuration & Tuning Guide

This guide details how to customize countdown durations, power actions, warning dialogs, and OS power policies in `workstation-sentinel`.

---

## 1. Changing the Inactivity Timeout

By default, `workstation-sentinel` waits **30 minutes** before executing a shutdown.

To change this, open [`sentinel.ps1`](../sentinel.ps1) and modify the `param` block:

```powershell
param(
    # Set timeout in minutes (e.g., 15, 30, 45, 60)
    [int]$TimeoutMinutes = 45,

    # Set warning countdown duration in seconds before power cut
    [int]$WarningSeconds = 60,

    [switch]$Status,
    [switch]$Test
)
```

### Recommended Durations by Use Case

| Profile | Timeout | Ideal For |
| :--- | :---: | :--- |
| **Strict Power Saver** | **15 Minutes** | Laptop users focused on maximum battery preservation. |
| **Standard Workstation** | **30 Minutes** | *(Default)* Balances coffee breaks with reliable power-off. |
| **Developer / Creative** | **45–60 Minutes** | Prevents unwanted shutdowns during extended discussions or lunch breaks. |

---

## 2. Choosing the Power Action: Shutdown vs. Hibernate

By default, the script executes a full clean shutdown (`shutdown.exe /s /f`). 

If you prefer **Hibernate** (which saves your open windows and browser tabs to SSD before cutting power to 0 Watts), edit line 88 of [`sentinel.ps1`](../sentinel.ps1):

### Default: Clean Full Shutdown
```powershell
& shutdown.exe /s /f /t $WarningSeconds /c "workstation-sentinel: Unattended for $TimeoutMinutes min. Powering off."
```

### Alternative: Safe Hibernate (Saves State to Disk)
```powershell
& shutdown.exe /h
```
*(Note: Windows `shutdown.exe /h` does not support `/t` countdown timers. If using `/h`, sleep `$WarningSeconds` before executing).*

---

## 3. Synchronizing Windows Display Timeout

To ensure optimal battery life, your Windows screen display timeout should be shorter than the sentinel timeout:

```text
0 min (User walks away)
  │
15 min (Windows turns display off to save panel power)
  │
30 min (workstation-sentinel verifies continuous lock -> Initiates Shutdown)
```

You can set your display timeout to **15 minutes** natively using `powercfg` in PowerShell:

```powershell
# Set screen off after 15 minutes (900 seconds) on both AC and Battery:
powercfg /change monitor-timeout-ac 15
powercfg /change monitor-timeout-dc 15
```

---

## 4. Re-Applying Changes

After editing [`sentinel.ps1`](../sentinel.ps1), **no reinstallation is required**. 

Windows Task Scheduler points directly to the script file on disk; your new parameters will take effect the very next time the workstation locks.
