import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/local/inspection_dao.dart';
import '../models/inspection.dart';
import '../sync/connectivity_monitor.dart';
import '../sync/sync_engine.dart';

class InspectionListViewModel extends ChangeNotifier {
  InspectionListViewModel({
    required this._dao,
    required this._engine,
    required this._connectivity,
  });

  final InspectionDao _dao;
  final SyncEngine _engine;
  final ConnectivityMonitor _connectivity;
  StreamSubscription<bool>? _sub;

  List<Inspection> items = const [];
  bool isOnline = false;
  bool isSyncing = false;
  String? message;

  int get unsyncedCount =>
      items.where((i) => i.syncStatus != SyncStatus.synced).length;

  Future<void> init() async {
    isOnline = await _connectivity.isOnline();
    _sub = _connectivity.onStatusChange.listen((online) {
      final cameOnline = online && !isOnline;
      isOnline = online;
      notifyListeners();
      if (cameOnline) sync(); // auto-sync as soon as the network returns
    });
    await _reload();
    if (isOnline) await sync();
  }

  Future<void> _reload() async {
    items = await _dao.all();
    notifyListeners();
  }

  /// Saves locally first (works fully offline), then syncs if possible.
  Future<void> save(Inspection inspection) async {
    await _dao.upsert(inspection);
    await _reload();
    if (isOnline) unawaited(sync());
  }

  /// Runs one sync and reports the result as a snackbar message. Unexpected
  /// errors are shown too, and never leave the sync button stuck disabled.
  Future<void> sync() async {
    if (isSyncing) return;
    isSyncing = true;
    message = null;
    notifyListeners();
    try {
      final report = await _engine.syncNow();
      if (!report.skipped && (report.uploaded > 0 || report.failed > 0)) {
        message =
            '${report.uploaded} synced'
            '${report.failed > 0 ? ', ${report.failed} failed (will retry)' : ''}';
      }
    } catch (e) {
      message = 'Sync failed: $e';
    } finally {
      isSyncing = false;
      await _reload();
    }
  }

  Future<void> retry(Inspection item) async {
    await _engine.retry(item);
    await _reload();
    if (isOnline) await sync();
  }

  Future<void> delete(Inspection item) async {
    await _dao.delete(item.id);
    await _reload();
  }

  void clearMessage() => message = null;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
