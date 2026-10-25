# ADR 0001: Initial Technology Stack

- **Status**: Accepted
- **Confidence**: Verified
- **Date**: 2026-07-07

## Context
The project is a cross-platform desktop application built for network security scanning. We needed a UI framework capable of rendering complex, brutalist HTML/CSS and a backend capable of low-level networking (ping, socket connections).

## Decision
- **Core App Framework**: Flutter (`pubspec.yaml`).
- **Web UI Engine**: `flutter_inappwebview` rendering local `assets/web/index.html`.
- **Backend Logic**: Dart Core with raw TCP Sockets and HTTP Server for local bridging.
- **Database**: SQLite (`cve_db.sqlite`) for local offline vulnerability matching.

## Consequences
- High control over network requests via Dart.
- Flexible, high-performance UI using standard web technologies.
- Requires managing an XSS-safe bridge between Dart and JS (`htmlEscape()`).

## Evidence
- `pubspec.yaml`
- `assets/web/index.html`
- `lib/scan_engine.dart`
