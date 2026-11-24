import 'dart:async';

import 'package:fieldsync_offline/data/local/app_database.dart';
import 'package:fieldsync_offline/data/local/inspection_dao.dart';
import 'package:fieldsync_offline/data/remote/inspection_api.dart';
import 'package:fieldsync_offline/models/inspection.dart';
import 'package:fieldsync_offline/sync/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

class FakeApi implements InspectionApi {
  final failIds = <String, SyncException>{};
  final uploaded = <String>[];
  Completer<void>? gate;

  @override
  Future<int> upload(Inspection inspection) async {
    await gate?.future;
    final error = failIds[inspection.id];
    if (error != null) throw error;
    uploaded.add(inspection.id);
    return uploaded.length;
  }
}

void main() {
  late AppDatabase db;
  late InspectionDao dao;
  late FakeApi api;
  final now = DateTime(2026, 1, 1, 12);
  late SyncEngine engine;

  setUp(() async {
    db = await openTestDb();
    dao = InspectionDao(db);
    api = FakeApi();
    engine = SyncEngine(dao, api, clock: () => now);
  });
  tearDown(() => db.close());

  test('uploads pending records and marks them synced', () async {
    await dao.upsert(fakeInspection('a'));
    await dao.upsert(fakeInspection('b'));

    final report = await engine.syncNow();

    expect(report.uploaded, 2);
    final all = await dao.all();
    expect(
      all.every((i) => i.syncStatus == SyncStatus.synced && i.remoteId != null),
      isTrue,
    );
  });

  test('retryable failure schedules a back-off; rejected failure waits for manual retry', () async {
    await dao.upsert(fakeInspection('net'));
    await dao.upsert(fakeInspection('bad'));
    api.failIds['net'] = const SyncException('timeout');
    api.failIds['bad'] = const SyncException('422', retryable: false);

    final report = await engine.syncNow();

    expect(report.failed, 2);
    final byId = {for (final i in await dao.all()) i.id: i};
    expect(byId['net']!.nextRetryAt, now.add(const Duration(seconds: 30)));
    expect(byId['bad']!.nextRetryAt, isNull);
    expect(byId['bad']!.lastError, '422');

    await engine.retry(byId['bad']!);
    api.failIds.remove('bad');
    expect((await engine.syncNow()).uploaded, 1);
  });

  test('overlapping syncNow calls upload each record once', () async {
    await dao.upsert(fakeInspection('a'));
    api.gate = Completer();

    final first = engine.syncNow();
    final second = engine.syncNow();
    api.gate!.complete();

    expect((await second).skipped, isTrue);
    expect((await first).uploaded, 1);
    expect(api.uploaded, ['a']);
  });

  test('backoff grows exponentially and is capped at one hour', () {
    expect(SyncEngine.backoff(1), const Duration(seconds: 30));
    expect(SyncEngine.backoff(3), const Duration(minutes: 2));
    expect(SyncEngine.backoff(20), const Duration(hours: 1));
  });
}
