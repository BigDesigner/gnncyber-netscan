# Boundary Conditions

This document defines the strict project boundaries, security expectations, and architectural limits.

## Security Constraints
- **XSS Prevention (Verified)**: The project uses WebView (`index.html`) which renders content retrieved from Dart sockets. Every string coming from Dart MUST be filtered using `htmlEscape()` before being written to the DOM to prevent remote execution via banner grabbing.
- **Offline First (Verified)**: The local `cve_db.sqlite` ensures vulnerability matching happens entirely offline without broadcasting network data to third-party endpoints.
- **Privacy (Verified)**: `macvendors.com` is used as a fallback lookup only. The primary `localOuis` mapping prevents leaking internal MAC addresses to the internet unnecessarily.

## Architectural Boundaries
- **UI Logic (Verified)**: Complex UI states must be managed inside HTML/CSS/JS. Dart is only a bridge.
- **Network Logic (Verified)**: Dart is responsible for raw sockets. Do NOT attempt to run WebSockets or AJAX requests directly inside the WebView for port scanning, as the WebView context lacks raw socket capabilities.

## CI/CD Boundaries
- **Triggers (Verified)**: GitHub Actions builds only on `main` branch when setup/pubspec files change.

All unconfirmed assumptions must be marked `Unconfirmed`.
