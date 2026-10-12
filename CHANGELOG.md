# 📋 Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-10-13

### Added
- **Event-Driven Sentinel Engine**: Purely event-triggered monitor (`sentinel.ps1`) executing zero idle CPU/RAM overhead while workstations are active.
- **Cross-Session Lock Detection**: Reliable detection via `LogonUI.exe` process tracking, eliminating Session 0 false positives.
- **Fail-Safe Self-Termination**: Immediate exit upon user authentication/unlock.
- **Emergency Abort Countdown**: 60-second native Windows warning before graceful system shutdown (`shutdown /s /f /t 60`), cancelable via `shutdown /a`.
- **Automated Self-Elevating Installer**: `install.ps1` and `uninstall.ps1` for 1-click Windows Task Scheduler registration under `NT AUTHORITY\SYSTEM`.
- **Dynamic Path Portability**: Task Scheduler XML automatically adopts the host directory path without hardcoded local user strings.
- **Comprehensive Documentation Suite**:
  - `docs/architecture.md`: In-depth sequence diagrams, state machines, and Session 0 topology analysis.
  - `docs/configuration.md`: Customization guide for timeouts, hibernate vs shutdown, and screen sleep sync.
  - `docs/troubleshooting.md`: Diagnostic workflows, event log tracking, and verification tests.
