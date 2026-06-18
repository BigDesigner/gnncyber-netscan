# ADR 0001: Initial Stack Selection

* **Status:** Accepted
* **Confidence:** Verified

## Context
We need to build a high-performance network scanning tool (IP, port, domain discovery) that runs on both Windows and iOS. The user has pre-designed a set of brutalist templates using Google Stitch that use HTML, Tailwind CSS, Google Fonts (Geist and JetBrains Mono), and Material Symbols.

## Decision
We select a **Hybrid Flutter + WebView** architecture:
- **Core Framework:** Flutter (Dart) as the cross-platform platform runner.
- **UI Render Layer:** Local single-page HTML application rendered in a full-screen `flutter_inappwebview` instance.
- **Scan Engine:** Native Dart sockets (`dart:io`) executing concurrent network pings, domain lookups, and port scans.
- **Javascript Bridge:** Native WebView Javascript Channels allowing bidirectional messaging between UI forms and the Dart engine.

## Consequences
- **Pros:**
  - Preserves 100% of the designed brutalist styling, fonts, and responsiveness from Google Stitch without rewriting views in Flutter.
  - Sockets execution remains native and highly concurrent using Dart asynchronous loops.
- **Cons:**
  - Relies on MS Edge WebView2 runtime on Windows and WKWebView on iOS.
