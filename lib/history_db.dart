import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HistoryDb {
  static Future<File> _getHistoryFile() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/gnnscan_history.json');
  }

  static Future<File> _getConfigFile() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/gnnscan_config.json');
  }

  // Load all scan histories
  static Future<List<dynamic>> loadHistory() async {
    try {
      final file = await _getHistoryFile();
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      return jsonDecode(contents) as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  // Save a scan history item
  static Future<void> saveHistoryItem(Map<String, dynamic> item) async {
    try {
      final file = await _getHistoryFile();
      final history = await loadHistory();
      
      // Add new item at the beginning
      history.insert(0, item);
      
      // Limit history to 200 items to keep file small
      if (history.length > 200) {
        history.removeRange(200, history.length);
      }
      
      await file.writeAsString(jsonEncode(history), flush: true);
    } catch (e) {
      // Ignore write errors
    }
  }

  // Clear all history
  static Future<void> clearHistory() async {
    try {
      final file = await _getHistoryFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore
    }
  }

  // Load configuration settings
  static Future<Map<String, dynamic>> loadSettings() async {
    try {
      final file = await _getConfigFile();
      if (!await file.exists()) {
        return _getDefaultSettings();
      }
      final contents = await file.readAsString();
      return jsonDecode(contents) as Map<String, dynamic>;
    } catch (e) {
      return _getDefaultSettings();
    }
  }

  // Save configuration settings
  static Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      final file = await _getConfigFile();
      await file.writeAsString(jsonEncode(settings), flush: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic> _getDefaultSettings() {
    return {
      "maxThreads": 64,
      "timeoutMs": 500,
      "aggressive": true,
      "bannerGrabbing": true,
      "enableOnlineVendorLookup": false,
      "themeMode": "system"
    };
  }
}
