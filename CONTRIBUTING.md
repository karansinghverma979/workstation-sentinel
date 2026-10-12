# 🤝 Contributing to workstation-sentinel

Thank you for contributing to `workstation-sentinel`! We welcome bug fixes, documentation improvements, and feature proposals that adhere to our core architectural invariants.

---

## 🏛️ Core Architectural Invariants

Before submitting a Pull Request, verify that your code honors these fundamental design constraints:

1. **Zero-Overhead Event-Driven Model**: The sentinel must **never** run as a persistent background daemon while the user is actively working. It must remain 100% dormant until triggered by a lock event.
2. **Epistemic Zero-Trust Session Checks**: Never assume `[Process]::GetCurrentProcess().SessionId` matches the interactive user session. Tasks running as `NT AUTHORITY\SYSTEM` live in Session 0.
3. **Portable Paths**: Never hardcode local user paths (e.g. `C:\Users\...`). Always resolve paths dynamically using `$PSScriptRoot`, `$HOME`, or environment variables.
4. **Clean Abort Safety**: Any unlock or user presence detection must terminate the script immediately with exit code 0 and zero side effects.

---

## 🛠️ Development & Testing Workflow

### 1. Fork & Clone
```bash
git clone https://github.com/your-username/workstation-sentinel.git
cd workstation-sentinel
```

### 2. Verify Code Style
Ensure your PowerShell scripts adhere to standard formatting and PSScriptAnalyzer best practices:
```powershell
# Run basic syntax verification
pwsh -Command "Get-Command -Syntax (Get-Item .\sentinel.ps1)"
```

### 3. Run Dry-Run Tests
Always test changes locally using the built-in test mode:
```powershell
powershell -ExecutionPolicy Bypass -File .\sentinel.ps1 -Test
```

---

## 📝 Pull Request Checklist

* [ ] Scripts maintain CRLF line endings (enforced via `.gitattributes`).
* [ ] No local logs (`sentinel.log`) or credential dumps are committed.
* [ ] Changes have been tested on Windows 10 and/or Windows 11.
* [ ] Documentation in `README.md` and `docs/` has been updated in lockstep.
