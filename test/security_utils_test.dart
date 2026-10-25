import 'package:flutter_test/flutter_test.dart';
import 'package:netscan/security_utils.dart';

void main() {
  // Attack Class: OS Command Injection / RCE via openExternalUrl bridge (H-01)
  group('[RCE-002] sanitizeExternalUrl', () {
    test('Positive Control: legitimate scanned web interfaces are accepted', () {
      // Default ports are canonicalized away by Uri (http:80 / https:443).
      expect(sanitizeExternalUrl('http://192.168.1.1:80'), 'http://192.168.1.1');
      expect(sanitizeExternalUrl('http://192.168.1.1:8080'), 'http://192.168.1.1:8080');
      expect(sanitizeExternalUrl('https://10.0.0.5:8443'), 'https://10.0.0.5:8443');
      expect(sanitizeExternalUrl('https://router.local/admin'), 'https://router.local/admin');
    });

    test('Negative Control: cmd.exe metacharacter chaining is rejected', () {
      const payloads = [
        'https://x&calc.exe',
        'http://1.1.1.1|whoami',
        'http://1.1.1.1^&calc',
        'http://1.1.1.1/a%26calc',
        'http://1.1.1.1/"&calc&"',
        'http://1.1.1.1/!PATH!',
        'http://1.1.1.1;calc',
        'http://1.1.1.1/a b',
        'http://1.1.1.1/\nc',
        'http://1.1.1.1/`calc`',
        'http://1.1.1.1/(calc)',
      ];
      for (final p in payloads) {
        expect(sanitizeExternalUrl(p), isNull, reason: 'Accepted shell payload: $p');
      }
    });

    test('Negative Control: non-web schemes, UNC and local paths are rejected', () {
      const payloads = [
        'file:///C:/Windows/System32/calc.exe',
        r'\\attacker\share\evil.exe',
        'C:/Windows/System32/calc.exe',
        'javascript:alert(1)',
        'ms-settings:',
        'smb://attacker/share',
        'http://user:pass@1.1.1.1',
        'http://',
        '',
      ];
      for (final p in payloads) {
        expect(sanitizeExternalUrl(p), isNull, reason: 'Accepted unsafe target: $p');
      }
      expect(sanitizeExternalUrl(null), isNull);
    });
  });

  // Attack Class: CSV / Formula Injection via attacker-controlled banners (M-01 / L-06)
  group('[INJ-003] csvCell', () {
    test('Positive Control: plain values are quoted unchanged', () {
      expect(csvCell('nginx/1.22.0'), '"nginx/1.22.0"');
      expect(csvCell(443), '"443"');
      expect(csvCell(null), '""');
    });

    test('Negative Control: embedded quotes cannot break out of the cell', () {
      expect(csvCell('x","=1+1'), '"x"",""=1+1"');
    });

    test('Negative Control: formula triggers are neutralized', () {
      for (final p in ['=HYPERLINK("http://evil")', '+cmd', '-2+3', '@SUM(A1)', '\t=1', '\r=1']) {
        expect(csvCell(p).startsWith('"\''), isTrue, reason: 'Formula not neutralized: $p');
      }
    });
  });

  // Attack Class: Resource exhaustion / type confusion via saveSettings bridge (L-05)
  group('[DOS-001] sanitizeSettings', () {
    test('Clamps numeric bounds and drops unknown keys', () {
      final s = sanitizeSettings({
        'maxThreads': 999999,
        'timeoutMs': -5,
        'bannerGrabbing': 'yes',
        'themeMode': '<script>',
        'injected': 'payload',
      });
      expect(s['maxThreads'], kMaxThreads);
      expect(s['timeoutMs'], kMinTimeoutMs);
      expect(s['bannerGrabbing'], isTrue);
      expect(s['themeMode'], 'system');
      expect(s.containsKey('injected'), isFalse);
    });

    test('Coerces double/string numerics without throwing', () {
      final s = sanitizeSettings({'maxThreads': 128.0, 'timeoutMs': '750'});
      expect(s['maxThreads'], 128);
      expect(s['timeoutMs'], 750);
    });
  });
}
