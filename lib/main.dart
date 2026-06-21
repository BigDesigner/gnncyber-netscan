import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'history_db.dart';
import 'scan_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GnnscanApp());
}

class GnnscanApp extends StatelessWidget {
  const GnnscanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GNNscan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  HttpServer? _server;
  int _port = 0;
  InAppWebViewController? _webViewController;
  ScanEngine? _activeScanEngine;
  DateTime? _scanStartTime;
  WebViewEnvironment? _webViewEnvironment;
  bool _envInitDone = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _initWebViewEnvironment();
    await _startLocalServer();
  }

  Future<void> _initWebViewEnvironment() async {
    if (!kIsWeb && Platform.isWindows) {
      try {
        final availableVersion = await WebViewEnvironment.getAvailableVersion();
        if (availableVersion != null) {
          final appSupportDir = await getApplicationSupportDirectory();
          final userDataPath = '${appSupportDir.path}${Platform.pathSeparator}WebView2Data';
          _webViewEnvironment = await WebViewEnvironment.create(
            settings: WebViewEnvironmentSettings(
              userDataFolder: userDataPath,
            ),
          );
        }
      } catch (e) {
        debugPrint('Failed to initialize WebViewEnvironment: $e');
      }
    }
    if (mounted) {
      setState(() {
        _envInitDone = true;
      });
    }
  }

  @override
  void dispose() {
    _server?.close();
    super.dispose();
  }

  // Starts a local HTTP server on an available loopback port to serve index.html
  Future<void> _startLocalServer() async {
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      setState(() {
        _port = _server!.port;
      });

      _server!.listen((HttpRequest request) async {
        final path = request.uri.path;
        
        String assetPath = '';
        if (path == '/' || path == '/index.html') {
          assetPath = 'assets/web/index.html';
        } else {
          final cleanPath = path.startsWith('/') ? path.substring(1) : path;
          if (cleanPath == 'app.png' || cleanPath == 'gnnecosystem-logo.png') {
            assetPath = 'assets/$cleanPath';
          } else {
            assetPath = 'assets/web/$cleanPath';
          }
        }

        try {
          final ByteData data = await rootBundle.load(assetPath);
          final buffer = data.buffer.asUint8List();
          
          if (assetPath.endsWith('.html')) {
            request.response.headers.contentType = ContentType.html;
          } else if (assetPath.endsWith('.png')) {
            request.response.headers.contentType = ContentType.parse('image/png');
          } else if (assetPath.endsWith('.jpg') || assetPath.endsWith('.jpeg')) {
            request.response.headers.contentType = ContentType.parse('image/jpeg');
          } else if (assetPath.endsWith('.ico')) {
            request.response.headers.contentType = ContentType.parse('image/x-icon');
          } else if (assetPath.endsWith('.css')) {
            request.response.headers.contentType = ContentType.parse('text/css');
          } else if (assetPath.endsWith('.js')) {
            request.response.headers.contentType = ContentType.parse('application/javascript');
          }

          request.response.add(buffer);
        } catch (e) {
          request.response.statusCode = HttpStatus.notFound;
          request.response.write('Asset not found: $e');
        }
        await request.response.close();
      });
    } catch (e) {
      debugPrint('Failed to start local server: $e');
    }
  }

  // Helper to run JS on the webview controller
  void _runJavaScript(String jsCode) {
    _webViewController?.evaluateJavascript(source: jsCode);
  }

  @override
  Widget build(BuildContext context) {
    if (_port == 0 || (!kIsWeb && Platform.isWindows && !_envInitDone)) {
      return const Scaffold(
        backgroundColor: Color(0xFF131314),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00F0FF)),
          ),
        ),
      );
    }

    final initialUrl = WebUri("http://127.0.0.1:$_port/index.html");

    return Scaffold(
      backgroundColor: const Color(0xFF131314),
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: initialUrl),
          webViewEnvironment: _webViewEnvironment,
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            useOnLoadResource: true,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
          ),
          onWebViewCreated: (controller) {
            _webViewController = controller;
            _setupJavaScriptHandlers(controller);
          },
          onConsoleMessage: (controller, consoleMessage) {
            debugPrint("WEBVIEW CONSOLE: ${consoleMessage.message}");
          },
        ),
      ),
    );
  }

  void _setupJavaScriptHandlers(InAppWebViewController controller) {
    // 1. startScan
    controller.addJavaScriptHandler(
      handlerName: 'startScan',
      callback: (args) async {
        final data = args[0] as Map<String, dynamic>;
        final target = data['target'] as String;
        final module = data['module'] as String;

        final settings = await HistoryDb.loadSettings();
        final maxThreads = settings['maxThreads'] as int? ?? 64;
        final timeoutMs = settings['timeoutMs'] as int? ?? 500;
        final enableBanner = settings['bannerGrabbing'] as bool? ?? true;

        _scanStartTime = DateTime.now();

        // Temporary data holders to construct final history record
        final Map<String, Map<String, dynamic>> discoveredHostsData = {};
        int findingsCount = 0;

        _activeScanEngine = ScanEngine(
          targetInput: target,
          module: module,
          maxThreads: maxThreads,
          timeout: Duration(milliseconds: timeoutMs),
          enableBannerGrabbing: enableBanner,
          onLog: (timestamp, type, msg) {
            final escapedMsg = msg.replaceAll("'", "\\'").replaceAll('"', '\\"');
            _runJavaScript("window.gnnscan.onLogReceived('$timestamp', '$type', '$escapedMsg')");
          },
          onHostDiscovered: (ip, label, isUp, mac, vendor) {
            discoveredHostsData[ip] = {
              'ip': ip,
              'label': label,
              'isUp': isUp,
              'mac': mac,
              'vendor': vendor,
              'ports': []
            };
            _runJavaScript("window.gnnscan.onHostDiscovered('$ip', '$label', $isUp, '$mac', '$vendor')");
          },
          onPortDiscovered: (ip, port, protocol, state, service, version, vulnScore, vulnLevel) {
            findingsCount++;
            if (discoveredHostsData[ip] != null) {
              final portsList = discoveredHostsData[ip]!['ports'] as List<dynamic>;
              portsList.add({
                'port': port,
                'protocol': protocol,
                'state': state,
                'service': service,
                'version': version,
                'vulnScore': vulnScore,
                'vulnLevel': vulnLevel
              });
            }
            _runJavaScript(
              "window.gnnscan.onPortDiscovered('$ip', $port, '$protocol', '$state', '$service', '$version', '$vulnScore', '$vulnLevel')"
            );
          },
          onProgress: (progress) {
            _runJavaScript("window.gnnscan.onProgressUpdate($progress)");
          },
          onFinished: () async {
            final durationMs = DateTime.now().difference(_scanStartTime!).inMilliseconds;
            
            // Build history item
            final historyItem = {
              'target': target,
              'module': module,
              'timestamp': DateTime.now().toLocal().toString().substring(0, 19),
              'durationMs': durationMs,
              'findingsCount': findingsCount,
              'status': _activeScanEngine != null && !_activeScanEngine!.isAborted ? 'COMPLETED' : 'ABORTED',
              'resultData': discoveredHostsData,
              'scanHost': Platform.localHostname
            };

            await HistoryDb.saveHistoryItem(historyItem);

            _runJavaScript("window.gnnscan.onScanFinished()");
            _activeScanEngine = null;
          },
        );

        // Run engine in background
        _activeScanEngine!.run();
        return true;
      },
    );

    // 2. stopScan
    controller.addJavaScriptHandler(
      handlerName: 'stopScan',
      callback: (args) {
        _activeScanEngine?.abort();
        return true;
      },
    );

    // 3. loadSettings
    controller.addJavaScriptHandler(
      handlerName: 'loadSettings',
      callback: (args) async {
        final settings = await HistoryDb.loadSettings();
        settings['hostname'] = Platform.localHostname;
        return settings;
      },
    );

    // 4. saveSettings
    controller.addJavaScriptHandler(
      handlerName: 'saveSettings',
      callback: (args) async {
        final settings = args[0] as Map<String, dynamic>;
        return await HistoryDb.saveSettings(settings);
      },
    );

    // 5. loadHistory
    controller.addJavaScriptHandler(
      handlerName: 'loadHistory',
      callback: (args) async {
        return await HistoryDb.loadHistory();
      },
    );

    // 6. clearHistory
    controller.addJavaScriptHandler(
      handlerName: 'clearHistory',
      callback: (args) async {
        await HistoryDb.clearHistory();
        return true;
      },
    );

    // 7. saveLogs (Saves terminal logs to text file)
    controller.addJavaScriptHandler(
      handlerName: 'saveLogs',
      callback: (args) async {
        try {
          final logsText = args[0] as String;
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/gnnscan_terminal_logs_${DateTime.now().millisecondsSinceEpoch}.txt');
          await file.writeAsString(logsText);
          return file.path;
        } catch (e) {
          return null;
        }
      },
    );

    // 8. exportHistory (Exports history to CSV or JSON file)
    controller.addJavaScriptHandler(
      handlerName: 'exportHistory',
      callback: (args) async {
        try {
          final format = args[0] as String;
          final history = await HistoryDb.loadHistory();
          final directory = await getApplicationDocumentsDirectory();
          
          if (format == 'json') {
            final file = File('${directory.path}/gnnscan_export_${DateTime.now().millisecondsSinceEpoch}.json');
            await file.writeAsString(jsonEncode(history), flush: true);
            return file.path;
          } else {
            // CSV
            final file = File('${directory.path}/gnnscan_export_${DateTime.now().millisecondsSinceEpoch}.csv');
            final csvBuffer = StringBuffer();
            csvBuffer.writeln('Target,Module,Timestamp,DurationMs,FindingsCount,Status,OperatorHost');
            for (var item in history) {
              final scanHost = item['scanHost'] ?? 'UNKNOWN';
              csvBuffer.writeln('${item['target']},${item['module']},${item['timestamp']},${item['durationMs']},${item['findingsCount']},${item['status']},$scanHost');
            }
            await file.writeAsString(csvBuffer.toString(), flush: true);
            return file.path;
          }
        } catch (e) {
          return null;
        }
      },
    );

    // 9. openExternalUrl (Opens a URL in the system's default browser)
    controller.addJavaScriptHandler(
      handlerName: 'openExternalUrl',
      callback: (args) async {
        try {
          final urlString = args[0] as String;
          if (Platform.isWindows) {
            await Process.run('cmd', ['/c', 'start', '', urlString]);
          } else if (Platform.isMacOS) {
            await Process.run('open', [urlString]);
          } else if (Platform.isLinux) {
            await Process.run('xdg-open', [urlString]);
          }
          return true;
        } catch (_) {
          return false;
        }
      },
    );

    // 10. saveExportFile (Saves single scan details export files to Documents directory)
    controller.addJavaScriptHandler(
      handlerName: 'saveExportFile',
      callback: (args) async {
        try {
          final fileName = args[0] as String;
          final content = args[1] as String;
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/$fileName');
          await file.writeAsString(content, flush: true);
          return file.path;
        } catch (_) {
          return null;
        }
      },
    );
  }
}
