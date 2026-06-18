# Boundary Conditions

This document defines GNNscan's operational boundaries, security limits, performance budgets, and platform execution constraints.

---

## Security and Permission Boundaries

### Low-Privilege Network Scanner
- **Restriction:** GNNscan must not require root/administrator privileges to execute scans.
- **Mechanism:** Avoid raw ICMP (ping) sockets. Use TCP socket connections on common ports (TCP Connect Ping) for host and port discovery.
- **Safety:** Prevents security tools or OS permissions from blocking application launch.

### WebView Sandbox
- **Restriction:** Local assets (HTML/JS) rendered in the WebView must not have unrestricted access to the local filesystem.
- **Mechanism:** Filesystem reading and writing are performed exclusively by the native Dart environment. The WebView must request file saves or data loads through explicit Javascript Channels. No file URLs (`file:///`) are directly exposed to the WebView context. A local loopback `HttpServer` (bound to `127.0.0.1`) is used to serve the files.

---

## Performance and Resource Budgets

### Thread and Pool Limits
- **Max Threads:** The concurrent socket pool size is capped at 256. This prevents Windows/iOS from exhausting socket handles or triggering OS-level denial-of-service protections.
- **Connection Timeout:** The minimum timeout for a socket connection is 100ms; the maximum is 3000ms. The default is 500ms.

---

## Network and Scan Limits
- **Subnet Scope:** Subnet scanning is restricted to a maximum of `/24` ranges (256 IP addresses) per request to prevent execution times from growing excessively.
- **Banner Grab Buffer:** When reading service banners, the application will read a maximum of 1024 bytes before closing the socket. This limits memory usage.
