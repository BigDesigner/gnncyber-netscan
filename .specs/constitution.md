# Constitution

This document outlines the engineering standards, architecture rules, UI design requirements, and versioning rules for GNNscan.

---

## Architectural Rules

### Hybrid Separation of Concerns
1. **Frontend (assets/web/):**
   - Strictly manages visual presentation, user inputs, configurations tabs, and local UI simulations.
   - Built on a single-page architecture using Tailwind CSS and Geist/JetBrains Mono fonts.
   - Must not execute native network sockets or directly read local database files.
2. **Backend (lib/):**
   - Implements native Dart concurrency, file storage (JSON databases), and network socket execution.
   - Communicates with the Frontend by resolving WebView Javascript Channel invocations and calling JS global callbacks.

---

## Visual and Brand Standards
Refer to [DESIGN.md](file:///c:/Users/bigde/.antigravity/GNNscan/cyber_tactical_operations/DESIGN.md) for the complete Style Guide.
- **Brand Personality:** Brutalist-Technical, clinical, high-density, authoritative.
- **Colors:** AMOLED Black foundation (`#131314`), Electric Blue (`#00F0FF`) primary accent, Emerald Green (`#72FF70`) for success status, Signal Red (`#FFB4AB`) for alerts.
- **Typography:** Geist for functional UI labels and JetBrains Mono for all monospace technical data (IPs, hashes, ports, logs).
- **Shapes:** Strict **Sharp (0px)** corners. Rounded corners are prohibited (`border-radius: 0`).
- **Dividers:** 1px solid lines (`#1A1A1C` or `#262629`).

---

## Code Quality Standards

### Dart Code Guidelines
- Prefer asynchronous-await over raw futures chains.
- Handle socket exceptions (`SocketException`) gracefully and format them as readable log streams for the UI.
- Close sockets and server connections in `finally` blocks to prevent memory/resource leaks.

### Versioning and commits
- Project versions follow semantic versioning. The current stable is `2.4.0`.
- Commit messages follow the Conventional Commits specification.
  - Example: `feat(engine): add concurrent TCP scan handler`
