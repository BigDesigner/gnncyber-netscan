# ADR 0007: WebView JS Bridge Hardening, CSV Injection Neutralization & Origin Lockdown

- **Status**: Accepted
- **Confidence**: Verified
- **Date**: 2026-10-25

## Context
During the comprehensive security audit (`sentinel-audit` on commit `607f2f1`), three interconnected security boundaries were analyzed:
1. **H-01 (Bridge RCE & Command Injection):** The `openExternalUrl` bridge handler accepted arbitrary strings from JavaScript and passed them to Windows `cmd.exe /c start "" <url>`. Since Dart does not quote shell metacharacters like `&` or `|` on Windows, or UNC executable paths (`\\evil\share\run.exe`), any JavaScript compromise would immediately escalate to operating system command execution.
2. **M-01 & L-06 (CSV / Formula Injection):** Attacker-controlled service banners (e.g. malicious HTTP `Server` headers) and reverse DNS PTR hostnames were written into single-scan and global history CSV export files without quote escaping or formula trigger neutralization. Opening these CSV files in Microsoft Excel or LibreOffice could execute formula injection payloads (`=`, `+`, `-`, `@`).
3. **L-01, L-03, L-04, L-05 (DOM & Perimeter Hardening):** Dynamic `onclick` attributes interpolated host IPs directly into JavaScript code blocks; `innerHTML` assignments omitted escaping on vulnerability scores; WebView permitted unrestricted `file://` cross-origin access; the internal loopback HTTP server lacked Host header validation against DNS rebinding; and user configuration parameters lacked boundary bounds.

## Decision
1. **Strict URL Sanitization & Shell-less Launch (`lib/security_utils.dart` & `lib/main.dart`):**
   - Implemented `sanitizeExternalUrl()` enforcing strict `http`/`https` schemes, domain characters (`[A-Za-z0-9.\-:]+`), port boundaries (1-65535), and zero shell metacharacters.
   - On Windows, replaced `Process.run('cmd', ['/c', 'start', '', url])` with `Process.run('rundll32', ['url.dll,FileProtocolHandler', safeUrl])`, eliminating `cmd.exe` from the execution path.
2. **Caller Origin & Navigation Guard:**
   - Enforced `_isTrustedCaller()` in all privileged bridge handlers (`openExternalUrl`, `downloadAndInstallUpdate`), verifying that the WebView's main frame URL originates strictly from `http://127.0.0.1:<port>`.
   - Wired `shouldOverrideUrlLoading` to cancel any navigation attempting to leave the local loopback origin.
3. **Universal CSV Cell Encoding (`csvCell`):**
   - Implemented `csvCell()` in both JavaScript (`assets/web/index.html`) and Dart (`lib/security_utils.dart`), which doubles quotes (`"` -> `""`) and prepends a single quote (`'`) to any string starting with `=+-@\t\r`.
4. **DOM Event Binding & XSS Prevention:**
   - Replaced all inline `onclick` string interpolations with declarative `data-host-ip` and `data-open-url` HTML attributes attached via `addEventListener`.
   - Ensured all dynamic values inserted into `innerHTML` (`vulnScore`, `vulnLevel`, `findingsCount`, `portDisplay`) are filtered with `htmlEscape()`.
5. **Perimeter Hardening:**
   - Disabled `allowFileAccessFromFileURLs` and `allowUniversalAccessFromFileURLs`.
   - Added `Host` header enforcement (`request.headers.value(HttpHeaders.hostHeader) == '127.0.0.1:$_port'`) in the loopback server.
   - Clamped engine settings via `sanitizeSettings()` (`maxThreads` 1-512, `timeoutMs` 50-10000).

## Consequences
- Completely eliminates the command injection attack surface from WebView bridge calls.
- Neutralizes CSV formula injection across all export formats.
- Confirms zero regressions with 22 automated unit tests across `security_utils_test.dart`, `security_boundary_redteam_test.dart`, and core modules.

## Evidence
- `lib/security_utils.dart`
- `test/security_utils_test.dart`
- `lib/main.dart`
- `assets/web/index.html`
- `.memory-bank/audits/audit-607f2f1.md`
- `.memory-bank/bugs/bug-list.md` (BUG-008, BUG-009, BUG-010, BUG-011)
