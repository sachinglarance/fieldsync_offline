import 'package:fieldsync_offline/data/local/app_database.dart';
import 'package:fieldsync_offline/data/local/inspection_dao.dart';
import 'package:fieldsync_offline/data/remote/inspection_api.dart';
import 'package:fieldsync_offline/models/inspection.dart';
import 'package:fieldsync_offline/sync/connectivity_monitor.dart';
import 'package:fieldsync_offline/sync/sync_engine.dart';
import 'package:fieldsync_offline/viewmodels/inspection_list_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

class OfflineMonitor implements ConnectivityMonitor {
  @override
  Future<bool> isOnline() async => false;
  @override
  Stream<bool> get onStatusChange => const Stream.empty();
}

class ExplodingApi implements InspectionApi {
  @override
  Future<int> upload(Inspection inspection) async =>
      throw StateError('bad JSON');
}

void main() {
  late AppDatabase db;
  setUp(() async => db = await openTestDb());
  tearDown(() => db.close());

  test(
    'an unexpected sync error is reported and does not leave isSyncing stuck',
    () async {
      final dao = InspectionDao(db);
      final vm = InspectionListViewModel(
        dao: dao,
        engine: SyncEngine(dao, ExplodingApi()),
        connectivity: OfflineMonitor(),
      );
      await vm.init();
      await vm.save(fakeInspection('a'));

      await vm.sync();

      expect(vm.isSyncing, isFalse);
      expect(vm.message, contains('Sync failed'));
      expect(vm.items.single.id, 'a');
    },
  );
}
