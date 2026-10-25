# ADR 0005: Secure Update Installer Whitelisting & macOS Fallback

- **Status**: Accepted
- **Confidence**: Verified
- **Date**: 2026-08-05

## Context
During security auditing (`sentinel-audit`), an RCE vulnerability was identified in `downloadAndInstallUpdate` where unvalidated URLs from the WebView JS bridge were passed directly to `Process.start()` / `Process.run()`. Furthermore, macOS updates froze at 100% due to App Sandbox restrictions and lack of UI completion feedback.

## Decision
- Enforced strict URL whitelisting in `UpdateService.isValidUpdateUrl`: Scheme must be `https`, host `github.com`, path starting with `/BigDesigner/gnncyber-netscan/releases/download/`, and file extension matching `.exe` (Windows) or `.zip` (macOS).
- Hardened in v2.18.1: Explicitly reject URLs containing null-byte characters (`\x00`, `%00`) to prevent null-byte string truncation attacks against the path/extension validators. Verified via automated Red Team tests (`test/security_boundary_redteam_test.dart`).
- Hardened in v2.18.2: `downloadAndInstallUpdate` and `openExternalUrl` bridge handlers only execute when the WebView main frame is the bundled loopback UI (`http://127.0.0.1:<port>`); WebView navigation to any other origin is cancelled. Installer signature/hash verification remains open (audit M-02).
- Added fallback extraction using macOS native Archive Utility (`open filePath`) when `unzip` is blocked by Sandbox.
- Updated JS update modal in `index.html` to render clear success guidance upon completion.

## Consequences
- Completely closes the theoretical RCE vector via WebView JavaScript injection.
- Ensures seamless update UX on macOS.

## Evidence
- `lib/update_service.dart`
- `lib/main.dart`
- `assets/web/index.html`
- `.memory-bank/audits/audit-81fc2b8.md`
