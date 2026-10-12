# 🔒 Security Policy

## Supported Versions

| Version | Supported          |
| :---    | :---:              |
| 1.0.x   | :white_check_mark: |

---

## Security Model & Privilege Boundaries

`workstation-sentinel` is designed with a defense-in-depth security posture:

1. **Why `NT AUTHORITY\SYSTEM` is Used**:
   * The scheduled task runs with elevated system privileges so it can monitor cross-session lock states on multi-user workstations and execute `shutdown.exe` without prompting non-admin users for credentials.
2. **Zero Inbound Network Surface**:
   * `workstation-sentinel` does not open network ports, communicate with external telemetry endpoints, or accept remote RPC inputs.
3. **No Third-Party Binaries**:
   * The project consists strictly of native PowerShell scripts (`.ps1`) and standard Windows Task Scheduler XML. There are no compiled DLLs or third-party executables.

---

## Reporting a Vulnerability

If you discover a security vulnerability or privilege escalation flaw within `workstation-sentinel`, please do **not** open a public issue.

Instead, report it directly to:
* **Maintainer**: Karan Singh Verma
* **GitHub Advisory**: Submit via private vulnerability reporting on the GitHub repository page.

You will receive an initial response within 48 hours.
