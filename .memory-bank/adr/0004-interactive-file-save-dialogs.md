# ADR 0004: Interactive File Save Dialogs via FilePicker

- **Status**: Accepted
- **Confidence**: Verified
- **Date**: 2026-08-05

## Context
Previously, exporting PDF, JSON, CSV reports or terminal logs automatically saved files directly into the system Documents directory without user input, leading to poor UX when users preferred specific destination folders.

## Decision
- Integrated `file_picker` package (`FilePicker.saveFile`).
- Replaced direct `getApplicationDocumentsDirectory()` paths in `main.dart` handlers (`saveLogs`, `exportHistory`, `saveExportFile`, `exportSingleScanPdf`).
- Retained auto-generated default file names (`GNNcyber_History_*.pdf`, `netscan_export_*.json`) while prompting users with a native OS Save File Dialog.

## Consequences
- Enhanced user control over export file management across Windows and macOS.
- User cancellation gracefully halts file write operations without throwing exceptions.

## Evidence
- `pubspec.yaml`
- `lib/main.dart`
