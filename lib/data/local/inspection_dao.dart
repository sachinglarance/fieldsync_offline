import 'package:sqflite/sqflite.dart';

import '../../models/inspection.dart';
import 'app_database.dart';

class InspectionDao {
  InspectionDao(AppDatabase database) : _db = database.db;
  final Database _db;

  Future<void> upsert(Inspection inspection) => _db.insert(
    'inspections',
    inspection.toRow(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  Future<List<Inspection>> all() async {
    final rows = await _db.query('inspections', orderBy: 'created_at DESC');
    return rows.map(Inspection.fromRow).toList();
  }

  /// Records that should be uploaded now: pending ones, plus retryable failed
  /// ones whose back-off window has passed. Failed rows with no retry time
  /// were rejected by the server and wait for a manual retry.
  Future<List<Inspection>> dueForSync(DateTime now) async {
    final rows = await _db.query(
      'inspections',
      where: "sync_status = 'pending' OR (sync_status = 'failed' AND next_retry_at IS NOT NULL AND next_retry_at <= ?)",
      whereArgs: [now.millisecondsSinceEpoch],
      orderBy: 'created_at ASC',
    );
    return rows.map(Inspection.fromRow).toList();
  }

  Future<int> countUnsynced() async {
    final res = await _db.rawQuery(
      "SELECT COUNT(*) AS c FROM inspections WHERE sync_status != 'synced'",
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  /// A crash mid-upload can leave rows stuck in `syncing`; reset them.
  Future<void> resetInterrupted() => _db.update('inspections', {
    'sync_status': SyncStatus.pending.name,
  }, where: "sync_status = 'syncing'");

  Future<void> delete(String id) =>
      _db.delete('inspections', where: 'id = ?', whereArgs: [id]);
}
