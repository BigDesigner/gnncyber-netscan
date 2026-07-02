import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _cveDb;
  Database? _historyDb;

  Future<void> init() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _cveDb = await _initCveDb();
    _historyDb = await _initHistoryDb();
  }

  Future<Database> _initCveDb() async {
    final docsDir = await getApplicationSupportDirectory();
    final dbPath = join(docsDir.path, 'cve_db.sqlite');

    // Always check if we need to copy the latest DB from assets
    // For now, we will just copy it if it doesn't exist
    if (!await File(dbPath).exists()) {
      try {
        final data = await rootBundle.load('assets/cve_db.sqlite');
        final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(dbPath).writeAsBytes(bytes, flush: true);
      } catch (e) {
        print('Error copying CVE DB from assets: $e');
      }
    }

    return await databaseFactory.openDatabase(dbPath);
  }

  Future<Database> _initHistoryDb() async {
    final docsDir = await getApplicationSupportDirectory();
    final dbPath = join(docsDir.path, 'history.sqlite');

    return await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE scans (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              timestamp TEXT,
              target TEXT,
              active_hosts INTEGER,
              open_ports INTEGER
            )
          ''');
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> findCveForService(String serviceName, String version) async {
    if (_cveDb == null) return null;
    
    // Very simple exact match for this PoC. 
    // In a real scenario, we might use LIKE or partial matches.
    final List<Map<String, dynamic>> maps = await _cveDb!.query(
      'cve_data',
      where: 'service = ? AND version = ?',
      whereArgs: [serviceName, version],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> saveScanHistory(String timestamp, String target, int activeHosts, int openPorts) async {
    if (_historyDb == null) return;
    await _historyDb!.insert(
      'scans',
      {
        'timestamp': timestamp,
        'target': target,
        'active_hosts': activeHosts,
        'open_ports': openPorts,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    if (_historyDb == null) return [];
    return await _historyDb!.query('scans', orderBy: 'id DESC');
  }
}
