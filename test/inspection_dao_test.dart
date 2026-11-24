import 'package:fieldsync_offline/data/local/app_database.dart';
import 'package:fieldsync_offline/data/local/inspection_dao.dart';
import 'package:fieldsync_offline/models/inspection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  late InspectionDao dao;

  setUp(() async {
    db = await openTestDb();
    dao = InspectionDao(db);
  });
  tearDown(() => db.close());

  test('row round-trip keeps every field', () async {
    final item = fakeInspection('a').copyWith(
      nextRetryAt: () => DateTime(2026, 2, 2),
      lastError: () => 'boom',
    );
    await dao.upsert(item);

    final loaded = (await dao.all()).single;
    expect(loaded.toRow(), item.toRow());
  });

  test(
    'dueForSync returns pending and expired retryable failures only',
    () async {
      final now = DateTime(2026, 1, 1, 12);
      await dao.upsert(fakeInspection('pending'));
      await dao.upsert(fakeInspection('synced', status: SyncStatus.synced));
      await dao.upsert(
        fakeInspection(
          'retry-due',
          status: SyncStatus.failed,
        ).copyWith(nextRetryAt: () => now.subtract(const Duration(minutes: 1))),
      );
      await dao.upsert(
        fakeInspection(
          'retry-later',
          status: SyncStatus.failed,
        ).copyWith(nextRetryAt: () => now.add(const Duration(minutes: 5))),
      );
      await dao.upsert(fakeInspection('rejected', status: SyncStatus.failed));

      final due = (await dao.dueForSync(now)).map((e) => e.id).toSet();

      expect(due, {'pending', 'retry-due'});
      expect(await dao.countUnsynced(), 4);
    },
  );

  test('resetInterrupted moves stuck syncing rows back to pending', () async {
    await dao.upsert(fakeInspection('x', status: SyncStatus.syncing));
    await dao.resetInterrupted();
    expect((await dao.all()).single.syncStatus, SyncStatus.pending);
  });
}
