# FieldSync: offline-first field reporting app (Flutter)

A data-collection app for field teams who inspect and maintain rural water pumps, in places
with poor or no mobile coverage. Every report is **saved to SQLite on the device first**.
An outbox-based **sync engine** uploads the reports to the web backend when a connection is
available: from the UI, on a connectivity change, or from a **WorkManager background job**
even if the app is closed.

## Features

- Three report types: **Installation**, **Community assessment** and **Maintenance**
- Fully usable offline. Reports never depend on the network to be saved.
- Live online/offline banner and a sync status (Pending, Syncing, Synced, Failed) for each report
- **Auto-sync on reconnect** (`connectivity_plus`) and a **15-minute periodic background sync** (`workmanager`, Android)
- **Exponential back-off** for retryable errors (30s, 1m, 2m, 4m, up to a 1h cap)
- **Non-retryable** server rejections (4xx) wait for a manual **Retry** instead of looping
- **Idempotency key** (the client-generated UUID) on every upload, so a retry after a lost response cannot create a duplicate
- Crash-safe: rows left in `syncing` by a crash are reset to `pending` on the next run
- Overlapping sync triggers are collapsed into one run, so nothing is uploaded twice
- Schema **migrations** (v1 to v2) so existing installs keep their unsynced data
- Conditional validation: notes are required when a pump is not working

## Architecture (MVVM with Provider)

```
lib/
├── models/                 # Inspection + enums, row/JSON mapping
├── data/
│   ├── local/              # AppDatabase (open + migrations), InspectionDao (queries)
│   └── remote/             # InspectionApi interface + HTTP implementation
├── sync/
│   ├── sync_engine.dart    # outbox drain, back-off, single-flight lock
│   ├── connectivity_monitor.dart
│   └── background_sync.dart  # WorkManager entry point (separate isolate)
├── viewmodels/             # ChangeNotifier view models: list and form
└── ui/                     # pages + widgets, which only talk to view models
```

```
 Save ──► SQLite (pending) ──► SyncEngine ──► POST /inspections
                 ▲               │   ▲
                 │  synced/failed │   ├── connectivity regained
                 └───────────────┘   ├── "Sync now" button
                                     └── WorkManager every 15 min
```

## Tests

```bash
flutter test
```

They run against a real SQLite engine, in memory, through `sqflite_common_ffi`.

- **DAO**: row round-trip; which records are due for sync (pending vs. back-off vs. rejected); crash recovery
- **SyncEngine**: success path, retryable vs. non-retryable failures, manual retry, concurrent `syncNow()` calls, back-off curve
- **Form view model**: validation rules and record creation

## Backend

The app defaults to `https://jsonplaceholder.typicode.com/posts`, which accepts POSTs, so the
sync flow can be demoed without a server. Pass your own `baseUrl` to `HttpInspectionApi` to
use a real backend.

## Platform notes

- **Android**: background sync is handled by WorkManager, with a network-connected constraint.
- **iOS**: the reconnect and foreground sync work as-is. Periodic background sync needs a
  `BGTaskScheduler` identifier in `Info.plist` and must be registered in `AppDelegate`
  (see the `workmanager` iOS setup guide).

## Run

```bash
flutter pub get
flutter run
```

**Tech:** Flutter · Dart 3 · Provider (MVVM) · sqflite · connectivity_plus · workmanager · http · uuid · sqflite_common_ffi (tests)
