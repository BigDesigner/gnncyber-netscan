// Security helpers shared by the JavaScript bridge handlers.
// Kept free of Flutter dependencies so they can be unit tested directly.

/// Hard upper bounds for persisted engine settings received from the WebView.
const int kMinThreads = 1;
const int kMaxThreads = 512;
const int kMinTimeoutMs = 50;
const int kMaxTimeoutMs = 10000;

// Strict character whitelist for URLs handed to the OS browser launcher.
// Excludes every shell/cmd metacharacter (& | ^ < > " ' % ! ` ; ( ) whitespace).
final RegExp _safeUrlChars = RegExp(r'^[A-Za-z0-9._~:/\-\[\]]+$');
final RegExp _hostnameChars = RegExp(r'^[A-Za-z0-9.\-:]+$');

/// SECURITY (H-01): Validates a URL requested by the WebView before it is passed
/// to the operating system. Returns a normalized `http`/`https` URL string, or
/// `null` when the input is unsafe (non-web scheme, UNC/file paths, credentials,
/// shell metacharacters, control characters, or malformed host/port).
String? sanitizeExternalUrl(String? raw) {
  if (raw == null) return null;
  final input = raw.trim();
  if (input.isEmpty || input.length > 2048) return null;
  if (!_safeUrlChars.hasMatch(input)) return null;

  final uri = Uri.tryParse(input);
  if (uri == null) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  if (uri.userInfo.isNotEmpty) return null;
  if (uri.host.isEmpty || !_hostnameChars.hasMatch(uri.host)) return null;
  if (uri.hasPort && (uri.port < 1 || uri.port > 65535)) return null;

  return Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: uri.path,
  ).toString();
}

/// SECURITY (M-01 / L-06): Encodes a single CSV cell. Doubles embedded quotes,
/// always wraps the value in quotes, and neutralizes spreadsheet formula
/// triggers (= + - @ TAB CR) by prefixing a single quote.
String csvCell(Object? value) {
  var s = value?.toString() ?? '';
  if (s.isNotEmpty && '=+-@\t\r'.contains(s[0])) {
    s = "'$s";
  }
  return '"${s.replaceAll('"', '""')}"';
}

/// SECURITY (L-05): Sanitizes the settings map received from the WebView.
/// Only whitelisted keys are kept, numeric values are clamped and type-coerced.
Map<String, dynamic> sanitizeSettings(Map<String, dynamic> input) {
  int clampInt(Object? v, int def, int min, int max) {
    final n = v is num ? v.toInt() : int.tryParse(v?.toString() ?? '');
    return (n ?? def).clamp(min, max);
  }

  bool asBool(Object? v, bool def) => v is bool ? v : def;

  final theme = input['themeMode'];
  return {
    'maxThreads': clampInt(input['maxThreads'], 64, kMinThreads, kMaxThreads),
    'timeoutMs': clampInt(input['timeoutMs'], 500, kMinTimeoutMs, kMaxTimeoutMs),
    'aggressive': asBool(input['aggressive'], true),
    'bannerGrabbing': asBool(input['bannerGrabbing'], true),
    'enableOnlineVendorLookup': asBool(input['enableOnlineVendorLookup'], false),
    'themeMode': (theme == 'dark' || theme == 'light' || theme == 'system') ? theme : 'system',
  };
}
