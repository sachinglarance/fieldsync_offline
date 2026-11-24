import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Owns the SQLite connection and schema migrations.
class AppDatabase {
  AppDatabase._(this.db);
  final Database db;

  static const _version = 2;

  /// [factory] and [path] are injectable so tests can use an in-memory FFI DB.
  static Future<AppDatabase> open({
    DatabaseFactory? factory,
    String? path,
  }) async {
    final f = factory ?? databaseFactory;
    final dbPath = path ?? p.join(await f.getDatabasesPath(), 'fieldsync.db');
    final db = await f.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _version,
        onCreate: (db, version) async {
          await _createV1(db);
          await _migrateToV2(db);
        },
        onUpgrade: (db, from, to) async {
          if (from < 2) await _migrateToV2(db);
        },
      ),
    );
    return AppDatabase._(db);
  }

  static Future<void> _createV1(Database db) async {
    await db.execute('''
      CREATE TABLE inspections (
        id TEXT PRIMARY KEY,
        site_name TEXT NOT NULL,
        inspector_name TEXT NOT NULL,
        type TEXT NOT NULL,
        condition TEXT NOT NULL,
        flow_rate_lpm REAL NOT NULL,
        households_served INTEGER NOT NULL,
        notes TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        sync_status TEXT NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        remote_id INTEGER
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_inspections_sync ON inspections(sync_status)',
    );
  }

  /// v2 added retry back-off columns. Kept as a real migration so existing
  /// installs upgrade without losing unsynced field data.
  static Future<void> _migrateToV2(Database db) async {
    await db.execute(
      'ALTER TABLE inspections ADD COLUMN next_retry_at INTEGER',
    );
    await db.execute('ALTER TABLE inspections ADD COLUMN last_error TEXT');
  }

  Future<void> close() => db.close();
}
