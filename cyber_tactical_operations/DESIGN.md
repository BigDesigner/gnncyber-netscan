---
name: Cyber-Tactical Operations
colors:
  surface: '#131314'
  surface-dim: '#131314'
  surface-bright: '#3a393a'
  surface-container-lowest: '#0e0e0f'
  surface-container-low: '#1c1b1c'
  surface-container: '#201f20'
  surface-container-high: '#2a2a2b'
  surface-container-highest: '#353436'
  on-surface: '#e5e2e3'
  on-surface-variant: '#b9cacb'
  inverse-surface: '#e5e2e3'
  inverse-on-surface: '#313031'
  outline: '#849495'
  outline-variant: '#3b494b'
  surface-tint: '#00dbe9'
  primary: '#dbfcff'
  on-primary: '#00363a'
  primary-container: '#00f0ff'
  on-primary-container: '#006970'
  inverse-primary: '#006970'
  secondary: '#ecffe3'
  on-secondary: '#003907'
  secondary-container: '#13ff43'
  on-secondary-container: '#007117'
  tertiary: '#fff3f2'
  on-tertiary: '#680008'
  tertiary-container: '#ffcec9'
  on-tertiary-container: '#c00119'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#7df4ff'
  primary-fixed-dim: '#00dbe9'
  on-primary-fixed: '#002022'
  on-primary-fixed-variant: '#004f54'
  secondary-fixed: '#72ff70'
  secondary-fixed-dim: '#00e639'
  on-secondary-fixed: '#002203'
  on-secondary-fixed-variant: '#00530e'
  tertiary-fixed: '#ffdad6'
  tertiary-fixed-dim: '#ffb3ad'
  on-tertiary-fixed: '#410003'
  on-tertiary-fixed-variant: '#930010'
  background: '#131314'
  on-background: '#e5e2e3'
  surface-variant: '#353436'
typography:
  display-tech:
    fontFamily: Geist
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-sm:
    fontFamily: Geist
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  body-md:
    fontFamily: Geist
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  data-mono:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  data-mono-bold:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
  label-xs:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 12px
spacing:
  unit: 4px
  gutter: 8px
  margin: 12px
  panel-padding: 8px
  row-height-sm: 24px
  row-height-md: 32px
---

## Brand & Style
This design system is engineered for high-stakes defensive security operations. The brand personality is clinical, authoritative, and high-velocity. It targets security analysts and threat hunters who require immediate, unadorned access to raw data.

The aesthetic is **Brutalist-Technical**. It rejects soft curves and consumer-grade friendliness in favor of raw efficiency, sharp edges, and high information density. The UI should evoke the feeling of a mission-critical terminal—focused exclusively on telemetry, logs, and network topology. There are no marketing flourishes; every pixel must serve a functional purpose.

## Colors
The palette is built on an **AMOLED Black** foundation to reduce eye strain during long shifts and maximize contrast for technical data.

- **Primary (Electric Blue):** Used for active states, interactive nodes, and primary action highlights.
- **Secondary (Emerald Green):** Dedicated to "Clean" status, secure protocols, and successful system pings.
- **Tertiary (Signal Red):** Reserved strictly for high-severity alerts, breach detections, and critical failures.
- **Surface Palette:** Uses deep charcoals (#121214) and "Obsidian" (#0A0A0B) to create subtle hierarchy without breaking the dark-room utility.
- **Data Accents:** Cyber-yellow (#F0FF00) may be used for warnings or mid-level priority telemetry.

## Typography
The system utilizes a dual-font approach to separate UI navigation from technical telemetry.

1.  **Geist:** Used for functional UI labels, headers, and navigation. It provides a clean, "developer-tool" feel that remains legible at small sizes.
2.  **JetBrains Mono:** The workhorse for all technical data. Every IP address, hash, packet payload, and log entry must be rendered in monospace to ensure visual alignment and character clarity (distinguishing `0` from `O` and `l` from `1`).

Line heights are tightened to 1.2x - 1.4x to support high-density data tables without sacrificing vertical scanning.

## Layout & Spacing
The layout uses a **Fluid Technical Grid** optimized for 27"+ 4K monitors. It favors a multi-pane tiling system rather than floating modals.

- **Structure:** A 24-column grid allows for complex dashboarding. Sidebars are collapsible to maximize the "Main Stage" telemetry view.
- **Density:** Spacing is based on a tight 4px base unit. Margins between panels are kept to a minimum (8px) to fit as much data as possible on a single viewport.
- **Responsive:** On smaller screens, the layout collapses into a single-column stack, but the primary target is desktop-class environments.
- **Scrollbars:** Custom ultra-thin "stealth" scrollbars that only appear on hover to prevent visual noise.

## Elevation & Depth
This design system avoids shadows entirely to maintain a "flat-terminal" Brutalist aesthetic. Depth is communicated through **Tonal Layering** and **Border Logic**:

- **Level 0 (Base):** #000000 (Pure Black).
- **Level 1 (Panels):** #0A0A0B with a 1px solid border of #1A1A1C.
- **Level 2 (Active/Hover):** Surface color shifts to #161618 with a primary-colored accent border.
- **Indicators:** High-contrast glows (bloom effect) are used sparingly for critical alerts to pull the eye toward specific data points without using 3D shadows.

## Shapes
The shape language is strictly **Sharp (0px)**. Rounded corners are prohibited to maintain the professional, engineered look of a precision instrument.

- **Containers:** All boxes, buttons, and inputs are hard-edged rectangles.
- **Dividers:** 1px solid lines using #1A1A1C or #262629.
- **Active States:** Indicated by a 2px interior border or a solid block of primary color.

## Components

### Buttons & Controls
- **Action Buttons:** Rectangle, no radius. Solid #00F0FF background with black text for primary actions. Ghost/Bordered for secondary.
- **Status Chips:** Small, rectangular tags with monospace text. `[ SECURE ]` in green, `[ BREACH ]` in red. Use square brackets as part of the label for a CLI feel.
- **Input Fields:** Dark background (#050505), 1px border (#1A1A1C). On focus, the border glows Electric Blue.

### Data Tables
- **Grid Lines:** Vertical and horizontal lines enabled by default.
- **Row Hover:** Entire row highlights with a subtle shift to #121214.
- **Cells:** Use `data-mono` for all values. Column headers are `label-xs` with a subtle bottom border.

### Visualizations
- **Charts:** Line charts use 1px stroke widths with no area fill. Nodes are small 3x3px squares.
- **Network Graph:** Nodes are sharp squares; edges are 1px dim grey lines, turning Electric Blue on active traffic.

### Layout Panels
- **Header:** Global breadcrumbs and "System Status" telemetry (CPU/Memory/Uptime) in the top right.
- **Inspector:** A permanent right-hand panel for drilling into specific log entries or packet headers.