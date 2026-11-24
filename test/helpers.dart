import 'package:fieldsync_offline/data/local/app_database.dart';
import 'package:fieldsync_offline/models/inspection.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<AppDatabase> openTestDb() {
  sqfliteFfiInit();
  return AppDatabase.open(
    factory: databaseFactoryFfi,
    path: inMemoryDatabasePath,
  );
}

Inspection fakeInspection(
  String id, {
  DateTime? at,
  SyncStatus status = SyncStatus.pending,
}) {
  final t = at ?? DateTime(2026, 1, 1);
  return Inspection(
    id: id,
    siteName: 'Site $id',
    inspectorName: 'Ravi',
    type: InspectionType.maintenance,
    condition: PumpCondition.needsRepair,
    flowRateLpm: 12.5,
    householdsServed: 40,
    notes: 'Handle is loose',
    createdAt: t,
    updatedAt: t,
    syncStatus: status,
  );
}
