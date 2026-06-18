# System Coherence

This document outlines the operational patterns, constraints, safety rules, and validation protocols for GNNscan. It enforces architecture coherence across agent invocations.

---

## Operating Mode and Protocols

### Mode Detection & Execution
- **Mode Detection:** Detect `CI=true` environment variable at startup.
  - If present: Set execution mode to **CI Mode** (non-interactive).
  - Otherwise: Set execution mode to **Interactive Mode**.
- **Interactive Mode Rules:**
  - Changes must stop and request review if critical decisions are unconfirmed.
  - Staging and commits require user review and explicit command approval.
- **CI Mode Rules:**
  - Discovery approval gates and interactive blocks are skipped.
  - Missing credentials or dirty worktree warnings are recorded as environment bugs.
  - A summary log is written to `.memory-bank/changelog/ci-run-summary.md`.

### Session Start Protocol
1. Load `.memory-bank/active-session.json`.
2. Inspect the git worktree and check branch name.
3. Validate memory areas and locate active tasks.
4. Update `timestamp` and `worktree_status` fields.

---

## Context and Consistency Protection

### Context Drift Prevention
- Refer to `.specs/constitution.md` for coding style and testing boundaries.
- Refer to `.specs/boundary-conditions.md` for safety limits (BOLA, admin access, network timeouts).
- Before introducing new packages, verify compatibility with both Windows and iOS platforms.

### Decision Verification Protocol
- All architectural decisions must be documented as numbered ADRs in `.memory-bank/adr/`.
- If a decision relies on a fact that cannot be verified in the codebase:
  - Mark it as `Unconfirmed`.
  - In Interactive Mode, stop and ask the user before writing implementation code.
  - In CI Mode, record it as a proposed decision needing human review.

---

## Pre-Change / Post-Change Checklists

### Pre-Change Checklist
1. Review the active task checklist in `.tasks/pipeline.md` or `task.md`.
2. Ensure the local git state matches the expected baseline.
3. Verify that the changes do not violate platform compatibility constraints.

### Post-Change Checklist
1. Verify compiles and runs using target platform commands.
2. Ensure no application secrets or absolute hardcoded developer paths are left in the source code.
3. Add a log entry to `.memory-bank/changelog/verified-worklog.md`.
4. Update `.tasks/pipeline.md` or `task.md`.
5. Prepare a commit message and `git add` file list.
