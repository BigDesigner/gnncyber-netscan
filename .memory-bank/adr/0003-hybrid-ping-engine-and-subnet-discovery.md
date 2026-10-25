# ADR 0003: Hybrid Host Discovery Engine & Native Subnet Auto-Detection

- **Status**: Accepted
- **Confidence**: Verified
- **Date**: 2026-08-03

## Context
Standard TCP Connect scanning was unreliable on hosts with ICMP-only response profiles or corporate firewalls blocking probe ports. Additionally, users had to manually input CIDR subnet notations.

## Decision
- **Subnet Auto-Detection**: Implemented `NetworkInterfaceHelper` in pure Dart/OS CLI to dynamically enumerate local network interfaces and calculate active CIDR ranges.
- **Hybrid Ping Engine**: Modified `ScanEngine._pingHost` to execute a multi-stage discovery strategy:
  1. ARP cache check
  2. Native OS ICMP Echo Request (`ping -n 1 -w 400` / `ping -c 1 -W 1`)
  3. Common TCP Connect fallback (ports 80, 443, 22, 445, 139, 3389)
- **Security Control**: Enforced strict Regex IP validation (`ipRegex`) prior to `Process.run('ping', ...)` to prevent OS command injection.

## Consequences
- Dramatically improved host discovery accuracy on internal subnets.
- Eliminates manual user subnet calculation.
- Guaranteed protection against command injection vulnerabilities.

## Evidence
- `lib/network_interface_helper.dart`
- `lib/scan_engine.dart`
- `assets/web/index.html`
