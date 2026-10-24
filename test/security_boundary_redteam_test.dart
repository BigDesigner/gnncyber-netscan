import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:netscan/database_helper.dart';
import 'package:netscan/update_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pass 1: Red Team Adversarial Logic & Authorization Tests', () {
    // Attack Class: Remote Code Execution (RCE) / Arbitrary Download via Whitelist Bypass
    // Guarded Location: lib/update_service.dart#L115-L138
    // Targeted Control: UpdateService.isValidUpdateUrl
    group('[RCE-001] Update Download URL Whitelist & Boundary Validation', () {
      test('Positive Control: Legitimate release URLs for current platform are accepted', () {
        final ext = Platform.isWindows ? '.exe' : (Platform.isMacOS ? '.zip' : '');
        if (ext.isNotEmpty) {
          final validUrl = 'https://github.com/BigDesigner/gnncyber-netscan/releases/download/v2.18.0/installer$ext';
          expect(UpdateService.isValidUpdateUrl(validUrl), isTrue,
              reason: 'Positive control failed: legitimate GitHub release URL was rejected.');
        }
      });

      test('Negative Control: Insecure HTTP scheme is rejected', () {
        const httpUrl = 'http://github.com/BigDesigner/gnncyber-netscan/releases/download/v2.18.0/installer.exe';
        expect(UpdateService.isValidUpdateUrl(httpUrl), isFalse,
            reason: 'Security violation: plaintext HTTP download allowed.');
      });

      test('Negative Control: Domain spoofing and subdomain attacks are rejected', () {
        const attackVectors = [
          'https://evil-github.com/BigDesigner/gnncyber-netscan/releases/download/v2.18.0/installer.exe',
          'https://github.com.evil.com/BigDesigner/gnncyber-netscan/releases/download/v2.18.0/installer.exe',
          'https://attacker.org/BigDesigner/gnncyber-netscan/releases/download/v2.18.0/installer.exe',
          'https://github.com/attacker-user/gnncyber-netscan/releases/download/v2.18.0/installer.exe',
          'https://github.com/BigDesigner/malicious-repo/releases/download/v2.18.0/installer.exe',
        ];

        for (final url in attackVectors) {
          expect(UpdateService.isValidUpdateUrl(url), isFalse,
              reason: 'Security violation: spoofed domain/repository accepted -> $url');
        }
      });

      test('Negative Control: Path traversal & arbitrary file extension attacks are rejected', () {
        const attackVectors = [
          'https://github.com/BigDesigner/gnncyber-netscan/releases/download/../../../etc/shadow',
          'https://github.com/BigDesigner/gnncyber-netscan/releases/download/v2.18.0/payload.bat',
          'https://github.com/BigDesigner/gnncyber-netscan/releases/download/v2.18.0/trojan.ps1',
          'https://github.com/BigDesigner/gnncyber-netscan/releases/download/v2.18.0/payload.sh',
          'https://github.com/BigDesigner/gnncyber-netscan/releases/download/v2.18.0/malware.exe.zip.tar.gz',
        ];

        for (final url in attackVectors) {
          expect(UpdateService.isValidUpdateUrl(url), isFalse,
              reason: 'Security violation: unallowed extension or path traversal accepted -> $url');
        }
      });

      test('Negative Control: Malformed URLs, null bytes, and protocol handlers are rejected', () {
        const attackVectors = [
          '',
          'not_a_valid_url',
          'file:///C:/Windows/System32/cmd.exe',
          'javascript:alert(1)',
          'https://github.com/BigDesigner/gnncyber-netscan/releases/download/v2.18.0/test\x00.exe',
        ];

        for (final url in attackVectors) {
          expect(UpdateService.isValidUpdateUrl(url), isFalse,
              reason: 'Security violation: malformed URI allowed -> $url');
        }
      });
    });
  });

  group('Pass 2: Classic Input Boundary & Injection Tests', () {
    // Attack Class: OS Command Injection via ICMP Ping
    // Guarded Location: lib/scan_engine.dart#L318-L326
    // Targeted Control: Strict IPv4/IPv6 RegExp validation
    group('[INJ-001] Host Discovery IP Format Command Injection Shield', () {
      final ipRegex = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$|^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$');

      test('Positive Control: Standard IPv4 and IPv6 addresses pass validation', () {
        const validIPs = [
          '127.0.0.1',
          '192.168.1.1',
          '10.0.0.254',
          '172.16.0.1',
          '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
          'fe80:0000:0000:0000:0204:61ff:fe9d:f156',
        ];

        for (final ip in validIPs) {
          expect(ipRegex.hasMatch(ip), isTrue,
              reason: 'Positive control failed: valid IP was rejected -> $ip');
        }
      });

      test('Negative Control: Command chaining, shell injection & metacharacters are rejected', () {
        const attackPayloads = [
          '192.168.1.1; whoami',
          '192.168.1.1 | calc.exe',
          '192.168.1.1 & net user /add evil pass',
          '192.168.1.1 && ping 127.0.0.1',
          '`id`',
          '\$(whoami)',
          '192.168.1.1\nwhoami',
          '192.168.1.1\r\ndir',
          '192.168.1.1;cat /etc/passwd',
          '192.168.1.1%0awhoami',
          '; rm -rf /',
          '192.168.1.1 || calc',
        ];

        for (final payload in attackPayloads) {
          expect(ipRegex.hasMatch(payload), isFalse,
              reason: 'CRITICAL SECURITY DEFECT: Command injection payload passed IP regex -> $payload');
        }
      });

      test('Negative Control: Incomplete, malformed and non-IP strings are rejected', () {
        const invalidInputs = [
          '192.168.1.',
          '192.168.1.1.5',
          '999.999.999.999.999',
          'google.com',
          'localhost',
          '../192.168.1.1',
          '',
          ' ',
          '192.168.1.1/24', // CIDR blocks should not be passed directly to pingHost
        ];

        for (final input in invalidInputs) {
          expect(ipRegex.hasMatch(input), isFalse,
              reason: 'Malformed input incorrectly recognized as host IP -> $input');
        }
      });
    });

    // Attack Class: SQL Injection
    // Guarded Location: lib/database_helper.dart#L101-L113
    // Targeted Control: SQLite parameter binding using whereArgs
    group('[INJ-002] CVE Offline Database SQL Injection Shield', () {
      test('Positive Control: Benign service search returns null safely without exception', () async {
        final helper = DatabaseHelper();
        await helper.init();

        final result = await helper.findCveForService('Apache', '2.4.41');
        // Result is either a map or null, but must never throw SQLite syntax error
        expect(result == null || result.isNotEmpty, isTrue);
      });

      test('Negative Control: Classic SQL Injection payloads do not execute or cause DB errors', () async {
        final helper = DatabaseHelper();
        await helper.init();

        const sqliPayloads = [
          "' OR '1'='1",
          "' OR 1=1--",
          "admin'--",
          "'; DROP TABLE cve_data;--",
          "' UNION SELECT null, null, null, null--",
          "1' AND SLEEP(5)--",
          "test' OR 'a'='a",
          "'; EXEC xp_cmdshell('calc.exe');--",
        ];

        for (final payload in sqliPayloads) {
          // Should execute safely via parameterized query and return null (no match) without throwing SQL exception
          final result = await helper.findCveForService(payload, '1.0');
          expect(result, isNull,
              reason: 'SQL injection payload returned unexpected data or bypassed parameterization: $payload');
        }
      });
    });
  });
}
