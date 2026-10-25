# System Coherence

This document outlines the core operational rules, versioning standards, and coherence boundaries for all AI agents and developers interacting with this project.

## Session Start Protocol
1. Verify operating mode (Interactive vs. CI).
2. Check `active-session.json` to resume state.
3. Review `.tasks/pipeline.md` and `.tasks/handoff.md`.

## Versioning & Release Discipline
- **Single Source of Truth**: The `VERSION` file in the project root is the sole authority for the project's semver.
- **Automated Synchronization**: Never manually edit versions across `pubspec.yaml`, `setup.iss`, `index.html`, etc. Always run `python scripts/sync_version.py <NEW_VERSION>`.
- **Pre-Push Validation**: Always run `python scripts/sync_version.py --check` prior to pushing to ensure zero version drift.

## Worktree & Branch Awareness
- Agents must detect and respect the current git branch (`main`).
- Agents must refuse to perform destructive operations on a dirty worktree in Interactive mode without explicit user approval.
- Context drift is prevented by strictly reading from `.specs/` and `.memory-bank/` instead of assuming project history.

## Pre-Change & Post-Change Checklists
- **Pre-Change**: Review `.specs/boundary-conditions.md` to ensure constraints are met. Verify stack and environment variables.
- **Post-Change**: Ensure code compiles/builds (`flutter analyze`, `flutter test`). Verify changes against `.specs/constitution.md`.

## Validation Rules
- Recommend validation commands (`flutter analyze`, `flutter test`, `python scripts/sync_version.py --check`) rather than running them automatically, unless explicitly requested.

## Handoff & Concurrency
- Use `.tasks/handoff.md` to pass context between sessions.
- Respect `concurrency_lock` in `active-session.json` if multiple agents operate simultaneously.

## Unconfirmed Decision Protocol
- Any architectural, security, or deployment assumption that cannot be verified against repository files must be marked as `Unconfirmed`.
- In Interactive mode, `Unconfirmed` critical decisions require explicit user approval.
- In CI mode, they are logged as `Proposed` ADRs for human review.
