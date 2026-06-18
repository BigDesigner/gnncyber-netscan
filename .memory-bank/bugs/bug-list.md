# Bug List

This document lists environment warnings, known compilation errors, lint issues, and runtime blockers.

---

## Active Issues

### Symlink Support Warning
- **Type:** Environment Warning
- **Description:** Flutter requires symlink support to build desktop plugins on Windows. Without Developer Mode enabled, `flutter pub get` fails or warns.
- **Evidence:** `Building with plugins requires symlink support. Please enable Developer Mode in your system settings.`
- **Confidence:** Verified
- **Status:** Open (Mitigated for CI)
- **Suggested Next Action:** The user must enable Developer Mode locally. This will not affect GitHub Actions since runners execute with administrator/developer privileges by default.
