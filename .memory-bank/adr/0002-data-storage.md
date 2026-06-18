# ADR 0002: Data Storage Strategy

* **Status:** Accepted
* **Confidence:** Verified

## Context
GNNscan needs to save past scanning configurations, settings, custom scripts, and scan logs. The storage engine must work on both Windows (desktop) and iOS (mobile) without complex SQLite compiler configuration or platform-specific native plugins that could trigger compilation failures.

## Decision
We select **Lightweight JSON Files** stored in the local application documents directory:
- We will use `path_provider` to locate the documents directory (`getApplicationDocumentsDirectory()`).
- Data will be saved as formatted JSON strings into `gnnscan_history.json` and `gnnscan_config.json`.
- A simple Dart manager (`history_db.dart`) will read and write these files using Dart's asynchronous `File` operations.

## Consequences
- **Pros:**
  - Simple, robust, and zero-configuration on both Windows and iOS.
  - Zero compiler issues. Easy to backup or export.
- **Cons:**
  - Reading the entire file into memory is required. This is acceptable since typical scan histories are small (less than 10MB).
