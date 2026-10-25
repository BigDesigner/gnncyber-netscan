# ADR 0002: GitHub Actions CI/CD Pipeline

- **Status**: Accepted (Updated)
- **Confidence**: Verified
- **Date**: 2026-07-07 (Updated 2026-10-25)

## Context
The project needs automated builds for multi-platform distribution (Windows `.exe` via Inno Setup and macOS `.zip`) upon new version releases, while ensuring compliance with GitHub Actions runner environments.

## Decision
- Use GitHub Actions (`.github/workflows/build.yml`) to orchestrate the build process.
- **Node 24 Migration**: All core workflow actions upgraded to native Node 24 runtime (`actions/checkout@v5`, `actions/setup-python@v6`, `actions/upload-artifact@v7`, `actions/download-artifact@v8`, `softprops/action-gh-release@v3`), completely removing deprecated Node 20 runtime warnings.
- **Redundant Steps Removal**: Removed unnecessary `actions/setup-node` steps from Windows and macOS Flutter jobs.
- **Version Enforcement**: Added `python scripts/sync_version.py --check` in `check-version` job to guarantee all project files match `VERSION`.
- Trigger builds specifically when changes are pushed to `main` branch with a new tag in `CHANGELOG.md` / `VERSION`.

## Consequences
- Clean, warning-free GitHub Actions execution.
- Prevents accidental release of desynchronized version binaries.
- Automates the creation of GitHub Releases with attached artifacts.

## Evidence
- `.github/workflows/build.yml`
- `scripts/sync_version.py`
