# `lib/`

**Purpose:** Source root of FieldSync, an offline-first app for logging water-pump inspections that saves to SQLite and syncs to a server when online.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

## Folders

- [`data/`](data/README.md) — Data layer: the local SQLite store and the remote upload API used by the sync engine and view models.
- [`models/`](models/README.md) — Plain immutable domain models with their SQLite row and API JSON conversions.
- [`sync/`](sync/README.md) — Offline sync: the engine that drains the local outbox to the server, connectivity monitoring, and Android background scheduling.
- [`ui/`](ui/README.md) — Flutter UI: screens and the widgets they use, reading state from Provider view models.
- [`viewmodels/`](viewmodels/README.md) — ChangeNotifier view models holding screen state and logic, kept free of widgets so they can be unit-tested.

## Files

| File | Purpose |
|---|---|
| [`main.dart`](#maindart) | App entry point: opens the database, builds the DAO and sync engine, registers background sync, and provides them to the widget tree before running `FieldSyncApp`. |

## `main.dart`

**Purpose:** App entry point: opens the database, builds the DAO and sync engine, registers background sync, and provides them to the widget tree before running `FieldSyncApp`.

Source: [`lib/main.dart`](../../lib/main.dart)

- **Uses:** `lib/data/local/app_database.dart`, `lib/data/local/inspection_dao.dart`, `lib/data/remote/inspection_api.dart`, `lib/sync/background_sync.dart`, `lib/sync/connectivity_monitor.dart`, `lib/sync/sync_engine.dart`, `lib/ui/pages/inspection_list_page.dart`, `lib/viewmodels/inspection_list_view_model.dart`
- **Used by:** — (entry point, generated-code target, or unused)

### function `Future<void> main()`

### `class FieldSyncApp extends StatelessWidget`

| Member | Kind | What it does |
|---|---|---|
| `const FieldSyncApp({super.key})` | constructor | _(auto)_ Creates an instance. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

