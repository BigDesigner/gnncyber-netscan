# ADR 0003: Host Discovery Method

* **Status:** Accepted
* **Confidence:** Verified

## Context
A network scanner needs to verify if hosts are online before scanning their ports. Standard tools use ICMP Echo Requests (pings). However, creating raw sockets for ICMP requests requires administrator/root permissions on Windows and is restricted by Apple on iOS.

## Decision
We select **TCP Connect Ping** for host discovery:
- For each target IP address, GNNscan will attempt to open a TCP socket connection to a set of highly common ports (e.g. 22, 80, 443, 445) with a short timeout (e.g. 200ms).
- If a socket successfully connects or is rejected (e.g. Connection Refused), the host is considered online. Only if the connection times out is the host considered offline.
- If a hostname is provided (e.g. google.com), we resolve it to an IP address using DNS lookup (`InternetAddress.lookup`) and scan that IP directly.

## Consequences
- **Pros:**
  - Works out-of-the-box on both iOS and Windows without requiring administrator/root permissions.
  - Less likely to be flagged by security tools or antiviruses as suspicious network activity.
- **Cons:**
  - Slightly more network traffic than simple ICMP packets, but still highly efficient when parallelized.
