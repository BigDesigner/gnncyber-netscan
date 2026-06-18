# ADR 0004: CI/CD Pipeline Configuration

* **Status:** Accepted
* **Confidence:** Verified

## Context
Compiling multi-platform builds (Windows `.exe` and iOS `.app`/`.ipa`) is complex. The user has specified that compiling builds will be managed via GitHub Actions CI/CD workflows, pushing the source repository directly to `https://github.com/BigDesigner/GNNscan.git`.

## Decision
We implement a **GitHub Actions Build Pipeline** (`.github/workflows/build.yml`):
- **Trigger:** On push to `main` branch or manual invocation (`workflow_dispatch`).
- **Windows Job (`windows-latest`):**
  - Sets up Flutter SDK.
  - Generates Flutter Windows release binaries (`flutter build windows`).
  - Compiles the Inno Setup installer script (`iscc setup.iss`) to produce `GNNscan_Setup.exe`.
  - Uploads the setup executable as a build artifact.
- **iOS Job (`macos-latest`):**
  - Sets up Flutter and Xcode environment.
  - Builds the iOS release bundles (`flutter build ios --no-codesign`).
  - Uploads the compiled application folders as artifacts.

## Consequences
- **Pros:**
  - Automated build delivery directly from GitHub push.
  - Decoupled developer environment (avoids local Xcode/Inno Setup compiler requirements).
- **Cons:**
  - Code signing on iOS is skipped by default (`--no-codesign`) since it requires Apple Developer Portal certificates. The user must sign it manually if they want to distribute to devices outside simulators/test environments.
