# Verified Worklog

This document tracks completed work, known issues, and validation status based on verified git history and files.

## Completed Work
- Implemented robust architecture separating Dart networking backend from HTML/JS frontend via `flutter_inappwebview`.
- Established `cve_db.sqlite` local offline matching.
- Implemented OUI caching for MAC address resolution, falling back to `macvendors.com` only when not cached (`lib/scan_engine.dart`).
- **Subnet Auto-Detection & Hybrid ICMP Ping (v2.15.0)**: Added native adapter enumeration in `lib/network_interface_helper.dart` and OS-level ICMP ping with strict IP regex security.
- **Interactive Save Dialogs (v2.16.0)**: Integrated `file_picker` for PDF, JSON, CSV, and logs; patched macOS update extraction fallback.
- **Dependency & Lint Maintenance (v2.17.0)**: Upgraded 20 package dependencies; patched DOM XSS in host selection; cleared all `avoid_print` lint warnings with `debugPrint`.
- **Node 24 CI & Single-Source Versioning (v2.18.0)**:
  - Migrated GitHub Actions CI/CD to Node 24 runtime (`checkout@v5`, `setup-python@v6`, `upload-artifact@v7`, `download-artifact@v8`, `action-gh-release@v3`).
  - Removed obsolete `setup-node` runner steps.
  - Implemented root `VERSION` file and `scripts/sync_version.py` automated synchronizer.
  - Dynamically bound UI version display in `index.html` to runtime state.
- **Null-Byte Injection Patch & Red Team Security Hardening (v2.18.1)**:
  - Discovered via `sentinel-qa` that `UpdateService.isValidUpdateUrl()` could accept null bytes (`\x00`, `%00`), risking path truncation.
  - Patched `lib/update_service.dart` to reject any URL containing null byte characters.
  - Added comprehensive Red Team test suite `test/security_boundary_redteam_test.dart` asserting input boundary enforcement for RCE, command injection, and SQL injection.
- **Audit 607f2f1 Remediation (v2.18.2)**:
  - H-01: `openExternalUrl` hardened with `sanitizeExternalUrl` whitelist, `rundll32` launcher (no cmd.exe), trusted-origin caller check and WebView navigation lock (`shouldOverrideUrlLoading`).
  - M-01 / L-06: `csvCell()` encoding in JS single-scan export and Dart global history export.
  - L-01: Inline `onclick` replaced with `data-*` + `addEventListener`; remaining `innerHTML` values escaped.
  - L-03 / L-04 / L-05: `file://` cross-origin access disabled, loopback Host header guard, settings whitelist/clamp (`sanitizeSettings`).
  - New `lib/security_utils.dart` + `test/security_utils_test.dart` (22/22 tests passing).
  - Open: M-02 (installer signature/hash), L-02, L-07, L-08.

## Known Incomplete Work
- None currently blocking. All prior backlog items (Subnet detection, ICMP ping, Single-source versioning) are completed.

## Validation Status
- `python scripts/sync_version.py --check`: Passed (all files match `VERSION`).
- `flutter analyze`: Passed (0 issues found).
- `flutter test`: Passed (all unit tests pass).
- GitHub Actions workflow syntax: Validated.
