import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../data/local/app_database.dart';
import '../data/local/inspection_dao.dart';
import '../data/remote/inspection_api.dart';
import 'sync_engine.dart';

/// WorkManager entry point and registration for the 15-minute background sync
/// on Android.
const kBackgroundSyncTask = 'fieldsync.periodicSync';

/// Runs in a separate background isolate started by WorkManager (Android).
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    WidgetsFlutterBinding.ensureInitialized();
    final db = await AppDatabase.open();
    try {
      final report = await SyncEngine(
        InspectionDao(db),
        HttpInspectionApi(),
      ).syncNow();
      // Returning false asks WorkManager to retry with its own back-off.
      return report.failed == 0;
    } finally {
      await db.close();
    }
  });
}

/// Schedules a sync every 15 minutes (the Android minimum), only when the
/// device has network, so field data reaches the server even if the app is
/// never reopened.
Future<void> registerBackgroundSync() async {
  if (!Platform.isAndroid) return; // iOS uses BGTaskScheduler; see README.
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    kBackgroundSyncTask,
    kBackgroundSyncTask,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}
