# ADR 0006: Single Source of Truth Version Management & Synchronization

- **Status**: Accepted
- **Confidence**: Verified
- **Date**: 2026-10-25

## Context
Previously, version bumps required manually updating multiple independent files:
- `pubspec.yaml`
- `setup.iss`
- `lib/update_service.dart` (`kAppVersion`)
- `assets/web/index.html` (header badge, settings, about modals)
- `CHANGELOG.md`
- `.github/workflows/build.yml`

This manual propagation led to desynchronization (e.g., UI displaying `v2.15.0-STABLE` even when the app was bumped to `v2.17.0`).

## Decision
1. **Root `VERSION` File:** Introduced `VERSION` at the project root as the single authority for semantic versioning (e.g., `2.18.0`).
2. **Automated Synchronizer (`scripts/sync_version.py`):**
   - Implemented a unified script to propagate the version from `VERSION` across:
     - `VERSION`
     - `assets/version.txt`
     - `lib/version.dart` (`kAppVersion`)
     - `pubspec.yaml` (`version: X.Y.Z+build`)
     - `setup.iss` (`#define MyAppVersion "X.Y.Z"`)
     - `assets/web/index.html` (header badge, about, and update panels)
     - `CHANGELOG.md` (ensures `## vX.Y.Z` section exists)
3. **Dynamic UI Binding:**
   - Gave the header version badge `id="header-app-version"` in `index.html`.
   - Wired `loadSettingsFromDart` to dynamically update this badge from `settings.appVersion` (`kAppVersion`), preventing stale UI text.
4. **CI/CD Enforcement:**
   - Added `python scripts/sync_version.py --check` step to `.github/workflows/build.yml` to automatically fail CI if any file's version deviates from `VERSION`.

## Consequences
- Eliminates human error during releases.
- Guarantees 100% version consistency across desktop binaries, installer, UI, and release tags.
- Bumping versions now requires a single command: `python scripts/sync_version.py <NEW_VERSION>`.

## Evidence
- `VERSION`
- `scripts/sync_version.py`
- `lib/version.dart`
- `assets/version.txt`
- `.github/workflows/build.yml`
- `assets/web/index.html`
