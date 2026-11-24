# `lib/data/local/`

**Purpose:** Local SQLite storage: the database connection and schema migrations, plus the DAO for inspection records.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/data/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`app_database.dart`](#app_databasedart) | Owns the SQLite connection and schema migrations. |
| [`inspection_dao.dart`](#inspection_daodart) | SQLite reads and writes for inspection records, including the outbox queries the sync engine uses. |

## `app_database.dart`

**Purpose:** Owns the SQLite connection and schema migrations.

Source: [`lib/data/local/app_database.dart`](../../../../lib/data/local/app_database.dart)

- **Uses:** —
- **Used by:** `lib/data/local/inspection_dao.dart`, `lib/main.dart`, `lib/sync/background_sync.dart`

### `class AppDatabase`

> Owns the SQLite connection and schema migrations.

| Member | Kind | What it does |
|---|---|---|
| `AppDatabase._(this.db)` | constructor | _(auto)_ Creates an instance. |
| `final Database db` | field | The open sqflite connection; `InspectionDao` reads it in its constructor and `callbackDispatcher` closes it via `close()` after a background run. |
| `static const _version = 2` | field | _(auto)_ Constant; the value is in the signature. |
| `static Future<AppDatabase> open({ DatabaseFactory? factory, String? path, })` | method | [factory] and [path] are injectable so tests can use an in-memory FFI DB. |
| `static Future<void> _createV1(Database db)` | method | Creates the original `inspections` table (UUID text primary key, timestamps as epoch ms, `attempts` defaulting to 0) plus an index on `sync_status`; only run from `onCreate` on a fresh install, followed by `_migrateToV2`. |
| `static Future<void> _migrateToV2(Database db)` | method | v2 added retry back-off columns. Kept as a real migration so existing installs upgrade without losing unsynced field data. |
| `Future<void> close()` | method | Closes the SQLite connection; used by the background isolate in a `finally` block so each WorkManager run releases the database. |

## `inspection_dao.dart`

**Purpose:** SQLite reads and writes for inspection records, including the outbox queries the sync engine uses.

Source: [`lib/data/local/inspection_dao.dart`](../../../../lib/data/local/inspection_dao.dart)

- **Uses:** `lib/data/local/app_database.dart`, `lib/models/inspection.dart`
- **Used by:** `lib/main.dart`, `lib/sync/background_sync.dart`, `lib/sync/sync_engine.dart`, `lib/viewmodels/inspection_list_view_model.dart`

### `class InspectionDao`

| Member | Kind | What it does |
|---|---|---|
| `InspectionDao(AppDatabase database) : _db = database.db` | constructor | _(auto)_ Creates an instance. |
| `final Database _db` | field | _(auto)_ Injected dependency / private state. |
| `Future<void> upsert(Inspection inspection)` | method | Inserts the record's `toRow()` map with `ConflictAlgorithm.replace`, so the same call both creates new records and overwrites status changes; used by `SyncEngine` and `InspectionListViewModel.save`. |
| `Future<List<Inspection>> all()` | method | Returns every stored inspection, newest first (`created_at DESC`); the list view model uses it to refresh the on-screen list. |
| `Future<List<Inspection>> dueForSync(DateTime now)` | method | Records that should be uploaded now: pending ones, plus retryable failed ones whose back-off window has passed. Failed rows with no retry time were rejected by the server and wait for a manual retry. |
| `Future<int> countUnsynced()` | method | Counts rows whose `sync_status` is anything other than `synced` (pending, syncing or failed); returns 0 when the query yields nothing. |
| `Future<void> resetInterrupted()` | method | A crash mid-upload can leave rows stuck in `syncing`; reset them. |
| `Future<void> delete(String id)` | method | Deletes the row with this id; called from the list view model when the user swipes away an already-synced record. |

