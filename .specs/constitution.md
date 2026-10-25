# Engineering Constitution

This document defines the strict engineering standards and agent behavioral expectations for this repository.

## Communication Style Rules
- **No Fluff:** Completely omit introduction sentences, congratulations, apologies, and politeness templates.
- **Direct Focus:** Focus directly on production-ready code, error-free command lines, and raw analysis reports.
- **Error Handling:** When an error is made, do not apologize. Acknowledge the error and directly output the corrected code, command, or file replacement.

## Code Quality Standards
- **Brutalist UI:** A UI change must adhere to the 0px border-radius rule, high contrast neon colors, and monospace data representation.
- **File Integrity:** Preserve all existing comments and docstrings that are unrelated to code changes unless explicitly told otherwise.
- **Agent Verification:** An AI agent MUST verify a file's existence and content via the file system before asserting its existence. Do NOT infer existence purely from discussion summaries.

## Commit Hygiene
- Commits should follow conventional commits pattern (`feat:`, `fix:`, `docs:`, `chore:`).
- CI/CD commits must accurately reflect the change.
