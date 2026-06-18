# Bootstrap Specs

This document contains instructions to configure, initialize, compile, and run the GNNscan application.

---

## Prerequisites
- **Flutter SDK:** Version `3.41.9` or higher.
- **Dart SDK:** Version `3.11.5` or higher.
- **Windows Target:**
  - Visual Studio 2022 (with "Desktop development with C++" workload installed).
  - Microsoft Edge WebView2 Runtime (pre-installed on Windows 11).
  - Windows Developer Mode enabled (for symlink support).
- **iOS Target:**
  - macOS with Xcode installed.
  - CocoaPods.

---

## Setup and Run Instructions

### 1. Resolve Dependencies
Download and configure all dependencies declared in `pubspec.yaml`:
```bash
flutter pub get
```

### 2. Run the App Locally
Run GNNscan on a connected target device (e.g. Windows desktop):
```bash
flutter run -d windows
```
To run on iOS simulator or device (requires macOS):
```bash
flutter run -d ios
```

### 3. Compile Production Releases
To compile optimized standalone builds:
- **Windows Binary:**
  ```bash
  flutter build windows
  ```
  The build output will be located at `build/windows/x64/runner/Release/`.
- **iOS Binary (No code sign):**
  ```bash
  flutter build ios --no-codesign
  ```
  The build output will be located at `build/ios/archive/`.

---

## CI/CD and Installer Pipeline

### GitHub Actions Pipeline
The pipeline is defined in `.github/workflows/build.yml`. It triggers automatically on push to the `main` branch.
- Windows runner: Compiles the Flutter app for Windows, installs Inno Setup, and runs `iscc setup.iss` to output `GNNscan_Setup.exe`.
- macOS runner: Compiles the Flutter app for iOS.

### Inno Setup Installer Compilation
To compile the Windows installer executable locally, install Inno Setup 6+ and run:
```bash
iscc setup.iss
```
This packages all release files from `build/windows/x64/runner/Release/` into a single installer.
