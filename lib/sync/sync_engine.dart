import 'dart:math';

import '../data/local/inspection_dao.dart';
import '../data/remote/inspection_api.dart';
import '../models/inspection.dart';

/// Drains the local outbox to the server, with back-off, crash recovery and a
/// single-flight lock.
class SyncReport {
  const SyncReport({this.uploaded = 0, this.failed = 0, this.skipped = false});
  final int uploaded;
  final int failed;

  /// True when another sync was already running.
  final bool skipped;
}

/// Drains the local outbox to the server. Safe to call from the UI,
/// a connectivity change and the background worker; overlapping calls are
/// collapsed into one run.
class SyncEngine {
  SyncEngine(this._dao, this._api, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final InspectionDao _dao;
  final InspectionApi _api;
  final DateTime Function() _now;

  Future<SyncReport>? _inFlight;

  static const _baseDelay = Duration(seconds: 30);
  static const _maxDelay = Duration(hours: 1);

  /// Exponential back-off: 30s, 1m, 2m, 4m … capped at 1h.
  static Duration backoff(int attempts) {
    final ms = _baseDelay.inMilliseconds * pow(2, max(0, attempts - 1));
    return Duration(milliseconds: min(ms.toInt(), _maxDelay.inMilliseconds));
  }

  Future<SyncReport> syncNow() {
    final running = _inFlight;
    if (running != null) {
      return running.then((_) => const SyncReport(skipped: true));
    }
    final future = _inFlight = _run();
    return future.whenComplete(() => _inFlight = null);
  }

  Future<SyncReport> _run() async {
    await _dao.resetInterrupted();
    final due = await _dao.dueForSync(_now());
    var uploaded = 0;
    var failed = 0;

    for (final item in due) {
      await _dao.upsert(item.copyWith(syncStatus: SyncStatus.syncing));
      try {
        final remoteId = await _api.upload(item);
        await _dao.upsert(
          item.copyWith(
            syncStatus: SyncStatus.synced,
            remoteId: remoteId,
            attempts: item.attempts + 1,
            nextRetryAt: () => null,
            lastError: () => null,
            updatedAt: _now(),
          ),
        );
        uploaded++;
      } on SyncException catch (e) {
        final attempts = item.attempts + 1;
        await _dao.upsert(
          item.copyWith(
            syncStatus: SyncStatus.failed,
            attempts: attempts,
            nextRetryAt: () =>
                e.retryable ? _now().add(backoff(attempts)) : null,
            lastError: () => e.message,
          ),
        );
        failed++;
      }
    }
    return SyncReport(uploaded: uploaded, failed: failed);
  }

  /// Manual retry from the UI (also clears a non-retryable failure).
  Future<void> retry(Inspection item) => _dao.upsert(
    item.copyWith(
      syncStatus: SyncStatus.pending,
      nextRetryAt: () => null,
      lastError: () => null,
    ),
  );
}
