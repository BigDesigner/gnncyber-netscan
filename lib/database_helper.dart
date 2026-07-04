import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _cveDb;

  Future<void> init() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    try {
      _cveDb = await _initCveDb();
    } catch (e) {
      debugPrint('CVE DB init failed: $e');
    }
  }

  Future<Database> _initCveDb() async {
    final docsDir = await getApplicationSupportDirectory();
    final dbPath = join(docsDir.path, 'cve_db.sqlite');
    final versionPath = join(docsDir.path, 'cve_db_version.txt');

    bool needCopy = false;

    if (!await File(dbPath).exists()) {
      needCopy = true;
    } else {
      try {
        final assetVer = await rootBundle.loadString('assets/cve_db_version.txt');
        String diskVer = '';
        if (await File(versionPath).exists()) {
          diskVer = await File(versionPath).readAsString();
        }
        if (assetVer.trim() != diskVer.trim()) {
          needCopy = true;
        }
      } catch (_) {
        // Fallback: If version check fails for some reason, don't overwrite if db exists
      }
    }

    if (needCopy) {
      try {
        final data = await rootBundle.load('assets/cve_db.sqlite');
        final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(dbPath).writeAsBytes(bytes, flush: true);

        final assetVer = await rootBundle.loadString('assets/cve_db_version.txt');
        await File(versionPath).writeAsString(assetVer.trim(), flush: true);
      } catch (e) {
        debugPrint('Error copying CVE DB from assets: $e');
      }
    }

    return await databaseFactory.openDatabase(dbPath);
  }

  Future<Map<String, dynamic>?> findCveForService(String serviceName, String version) async {
    if (_cveDb == null) return null;
    
    // Use LIKE to make offline CVE matching more forgiving
    final List<Map<String, dynamic>> maps = await _cveDb!.query(
      'cve_data',
      where: 'service LIKE ? AND version LIKE ?',
      whereArgs: ['%$serviceName%', '%$version%'],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
}
