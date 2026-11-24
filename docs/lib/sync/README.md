# `lib/sync/`

**Purpose:** Offline sync: the engine that drains the local outbox to the server, connectivity monitoring, and Android background scheduling.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`background_sync.dart`](#background_syncdart) | WorkManager entry point and registration for the 15-minute background sync on Android. |
| [`connectivity_monitor.dart`](#connectivity_monitordart) | Reports whether the device has a network connection and emits changes, behind an interface so tests can fake it. |
| [`sync_engine.dart`](#sync_enginedart) | Drains the local outbox to the server, with back-off, crash recovery and a single-flight lock. |

## `background_sync.dart`

**Purpose:** WorkManager entry point and registration for the 15-minute background sync on Android.

Source: [`lib/sync/background_sync.dart`](../../../lib/sync/background_sync.dart)

- **Uses:** `lib/data/local/app_database.dart`, `lib/data/local/inspection_dao.dart`, `lib/data/remote/inspection_api.dart`, `lib/sync/sync_engine.dart`
- **Used by:** `lib/main.dart`

### variable `const kBackgroundSyncTask = 'fieldsync.periodicSync'`

> WorkManager entry point and registration for the 15-minute background sync
> on Android.

### function `void callbackDispatcher()`

> Runs in a separate background isolate started by WorkManager (Android).

### function `Future<void> registerBackgroundSync()`

> Schedules a sync every 15 minutes (the Android minimum), only when the
> device has network, so field data reaches the server even if the app is
> never reopened.

## `connectivity_monitor.dart`

**Purpose:** Reports whether the device has a network connection and emits changes, behind an interface so tests can fake it.

Source: [`lib/sync/connectivity_monitor.dart`](../../../lib/sync/connectivity_monitor.dart)

- **Uses:** —
- **Used by:** `lib/main.dart`, `lib/viewmodels/inspection_list_view_model.dart`

### `abstract interface class ConnectivityMonitor`

| Member | Kind | What it does |
|---|---|---|
| `Future<bool> isOnline()` | method | One-off check of whether the device currently has any network; the list view model calls it once in `init()`. |
| `Stream<bool> get onStatusChange` | getter | Emits true/false whenever network availability changes; the list view model listens to it to update the banner and auto-sync on reconnect. |

### `class PlatformConnectivityMonitor implements ConnectivityMonitor`

| Member | Kind | What it does |
|---|---|---|
| `PlatformConnectivityMonitor([Connectivity? connectivity]) : _connectivity = connectivity ?? Connectivity()` | constructor | _(auto)_ Creates an instance. |
| `final Connectivity _connectivity` | field | _(auto)_ Injected dependency / private state. |
| `static bool _hasNetwork(List<ConnectivityResult> r)` | method | True if any reported connection type is not `none`. Note this means a network interface is up, not that the server is reachable. |
| `Future<bool> isOnline()` | method | Asks `connectivity_plus` for the current connection types and reduces them with `_hasNetwork`. |
| `Stream<bool> get onStatusChange` | getter | Maps `onConnectivityChanged` through `_hasNetwork` and drops repeats with `distinct()`, so listeners only hear real online/offline flips. |

## `sync_engine.dart`

**Purpose:** Drains the local outbox to the server, with back-off, crash recovery and a single-flight lock.

Source: [`lib/sync/sync_engine.dart`](../../../lib/sync/sync_engine.dart)

- **Uses:** `lib/data/local/inspection_dao.dart`, `lib/data/remote/inspection_api.dart`, `lib/models/inspection.dart`
- **Used by:** `lib/main.dart`, `lib/sync/background_sync.dart`, `lib/viewmodels/inspection_list_view_model.dart`

### `class SyncReport`

> Drains the local outbox to the server, with back-off, crash recovery and a
> single-flight lock.

| Member | Kind | What it does |
|---|---|---|
| `const SyncReport({this.uploaded = 0, this.failed = 0, this.skipped = false})` | constructor | _(auto)_ Creates an instance. |
| `final int uploaded` | field | Number of records uploaded successfully in this run; the list view model shows it in the snackbar. |
| `final int failed` | field | Number of records whose upload failed in this run; the background worker returns `false` to WorkManager when this is above 0. |
| `final bool skipped` | field | True when another sync was already running. |

### `class SyncEngine`

> Drains the local outbox to the server. Safe to call from the UI,
> a connectivity change and the background worker; overlapping calls are
> collapsed into one run.

| Member | Kind | What it does |
|---|---|---|
| `SyncEngine(this._dao, this._api, {DateTime Function()? clock}) : _now = clock ?? DateTime.now` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final InspectionDao _dao` | field | _(auto)_ Injected dependency / private state. |
| `final InspectionApi _api` | field | _(auto)_ Injected dependency / private state. |
| `final DateTime Function() _now` | field | Clock used for due-time checks, back-off scheduling and `updatedAt`; injectable for tests, defaults to `DateTime.now`. |
| `Future<SyncReport>? _inFlight` | field | The currently running sync, or null when idle; `syncNow` uses it to collapse overlapping calls into one run. |
| `static const _baseDelay = Duration(seconds: 30)` | field | _(auto)_ Constant; the value is in the signature. |
| `static const _maxDelay = Duration(hours: 1)` | field | _(auto)_ Constant; the value is in the signature. |
| `static Duration backoff(int attempts)` | method | Exponential back-off: 30s, 1m, 2m, 4m … capped at 1h. |
| `Future<SyncReport> syncNow()` | method | Starts a sync run, or, if one is already running, waits for it and returns a `SyncReport(skipped: true)`. Clears `_inFlight` when the run completes, even on error. |
| `Future<SyncReport> _run()` | method | Resets rows stuck in `syncing`, then uploads each due record oldest-first: marks it `syncing`, then `synced` with the remote id on success, or `failed` with the error and a back-off `nextRetryAt` (none if non-retryable) on `SyncException`. Returns the counts; other exception types are not caught and abort the run. |
| `Future<void> retry(Inspection item)` | method | Manual retry from the UI (also clears a non-retryable failure). |

