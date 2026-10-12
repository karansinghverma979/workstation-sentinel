# 🩺 Troubleshooting & Diagnostics

This guide covers common diagnostic commands, log inspection, and troubleshooting steps for `workstation-sentinel`.

---

## 1. Quick Verification Commands

Run these directly from an interactive PowerShell terminal:

### A. Check Real-Time Lock Status
```powershell
powershell -ExecutionPolicy Bypass -File .\sentinel.ps1 -Status
```
* **Output**: `Workstation Locked State: False` (while you are on the desktop).
* **If it shows `True` while unlocked**: Verify whether a background `LogonUI.exe` process is stuck using `Get-Process LogonUI`.

### B. Run the 15-Second Dry Run
```powershell
powershell -ExecutionPolicy Bypass -File .\sentinel.ps1 -Test
```
* Tests the 5-second polling loop and logs diagnostics without executing a shutdown.

### C. Verify Task Scheduler Registration
```powershell
schtasks /query /tn "workstation-sentinel" /fo LIST /v
```
* Check that **Status** shows `Ready`.
* Check that **Task To Run** points to your dynamic script path.

---

## 2. Inspecting the Audit Log

`workstation-sentinel` logs all lifecycle events to `sentinel.log` in its root folder:

```powershell
Get-Content -Path .\sentinel.log -Tail 20
```

### Healthy Log Example (User Returns Early):
```text
[2026-10-13 14:00:00] Sentinel activated. Timeout: 30 min (1800s). Warning: 60s.
[2026-10-13 14:04:12] Workstation unlocked after 250 seconds (4.2 min). Sentinel safely aborted.
```

### Healthy Log Example (Unattended Shutdown):
```text
[2026-10-13 14:00:00] Sentinel activated. Timeout: 30 min (1800s). Warning: 60s.
[2026-10-13 14:30:00] Threshold reached (30 min unattended). Initiating graceful shutdown.
```

---

## 3. Emergency Abort

If the 60-second shutdown warning appears on screen and you want to prevent the shutdown:

Press `Win + R`, type:
```cmd
shutdown /a
```
and press **Enter**.

Windows will immediately display a notification stating: *"Logoff is cancelled"*.

---

## 4. Common Issues & Solutions

### Task does not trigger when locking with `Win + L`
1. Open Windows Event Viewer (`eventvwr.msc`).
2. Navigate to: **Applications and Services Logs** $\rightarrow$ **Microsoft** $\rightarrow$ **Windows** $\rightarrow$ **TaskScheduler** $\rightarrow$ **Operational**.
3. If the operational log is disabled, right-click it and choose **Enable Log**.
4. Lock the workstation (`Win + L`), wait 10 seconds, unlock, and check for **Event ID 100** (Task Started) for `workstation-sentinel`.

### Task fails with "Access is Denied" during installation
* Ensure you approve the Windows UAC confirmation dialog when running [`install.ps1`](../install.ps1). Registering a task under `NT AUTHORITY\SYSTEM` requires local Administrator privileges.

### Shutdown closed unsaved work
* `workstation-sentinel` is designed to power off machines that have been abandoned for 30 minutes. If your workflow involves long unattended jobs (e.g. 2-hour video rendering or model training), increase the timeout to **60 or 90 minutes** in [`docs/configuration.md`](configuration.md).
