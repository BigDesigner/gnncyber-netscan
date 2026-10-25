# Bootstrap Instructions

This document provides verified setup and execution instructions for developers.

## Tech Stack
- **Primary Language**: Dart / HTML / JS (**Verified**)
- **Framework**: Flutter (**Verified**)
- **Package Manager**: flutter pub (**Verified**)

## Setup & Validation Commands

| Command | Purpose | Requires Installed Tool | Notes |
|---|---|---|---|
| `flutter pub get` | Install dependencies | Flutter SDK | Run this first. |
| `flutter run -d windows` | Run the app on Windows | Flutter SDK | Requires Windows build tools. |
| `flutter build windows` | Build the app for production | Flutter SDK | Output is in `build\windows\x64\runner\Release`. |
| `flutter analyze` | Run static analysis | Flutter SDK | Ensures code quality. |
| `flutter test` | Run unit tests | Flutter SDK | |

## CI/CD Pipelines
- **Pipeline Name**: Build and Release (in `.github/workflows/build.yml`)
- **Triggers**: Push to `main` when `setup.iss` or `pubspec.yaml` changes.
- **Jobs**: `build-windows`, `build-macos`, `create-release`.

## Deployment
- Windows relies on Inno Setup via `setup.iss` to package the executable.
- macOS creates a simple `.zip` bundle.
