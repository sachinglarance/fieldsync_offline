# `lib/viewmodels/`

**Purpose:** ChangeNotifier view models holding screen state and logic, kept free of widgets so they can be unit-tested.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`inspection_form_view_model.dart`](#inspection_form_view_modeldart) | Holds form state and validation rules so they can be unit-tested without building widgets. |
| [`inspection_list_view_model.dart`](#inspection_list_view_modeldart) | State and actions for the inspection list: loads records, tracks connectivity, and saves, syncs, retries and deletes. |

## `inspection_form_view_model.dart`

**Purpose:** Holds form state and validation rules so they can be unit-tested without building widgets.

Source: [`lib/viewmodels/inspection_form_view_model.dart`](../../../lib/viewmodels/inspection_form_view_model.dart)

- **Uses:** `lib/models/inspection.dart`
- **Used by:** `lib/ui/pages/inspection_form_page.dart`

### `class InspectionFormViewModel extends ChangeNotifier`

> Holds form state and validation rules so they can be unit-tested
> without building widgets.

| Member | Kind | What it does |
|---|---|---|
| `InspectionFormViewModel({DateTime Function()? clock, Uuid? uuid}) : _now = clock ?? DateTime.now, _uuid = uuid ?? const Uuid()` | constructor | _(auto)_ Creates an instance. |
| `final DateTime Function() _now` | field | Clock used to stamp `createdAt`/`updatedAt` in `build`; injectable for tests, defaults to `DateTime.now`. |
| `final Uuid _uuid` | field | _(auto)_ Injected dependency / private state. |
| `InspectionType type = InspectionType.maintenance` | field | Currently selected inspection type; defaults to maintenance and is changed through `setType`. |
| `PumpCondition condition = PumpCondition.working` | field | Currently selected pump condition; defaults to working and is changed through `setCondition`, which also affects `notesRequired`. |
| `void setType(InspectionType value)` | method | Sets `type` and notifies listeners; called by the form's segmented button. |
| `void setCondition(PumpCondition value)` | method | Sets `condition` and notifies listeners so the notes label and validation switch between optional and required. |
| `bool get notesRequired` | getter | Notes are mandatory when a pump isn't working, so the repair team knows what to bring. |
| `String? validateRequired(String? v, String field)` | method | Form validator that returns "`<field>` is required" for null or blank input, otherwise null; used for site and inspector fields. |
| `String? validateFlowRate(String? v)` | method | Returns an error unless the trimmed input parses as a number between 0 and 500 L/min inclusive. |
| `String? validateHouseholds(String? v)` | method | Returns an error unless the trimmed input parses as a whole number that is not negative. |
| `String? validateNotes(String? v)` | method | When `notesRequired`, returns an error if the trimmed notes are shorter than 10 characters; otherwise always passes. |
| `Inspection build({ required String siteName, required String inspectorName, required String flowRate, required String households, required String notes, })` | method | Creates a new pending `Inspection` with a fresh UUID v4, trimmed text, the selected type and condition, and `createdAt`/`updatedAt` set to now. Parses numbers with `double.parse`/`int.parse`, so it must only be called after validation passes. |

## `inspection_list_view_model.dart`

**Purpose:** State and actions for the inspection list: loads records, tracks connectivity, and saves, syncs, retries and deletes.

Source: [`lib/viewmodels/inspection_list_view_model.dart`](../../../lib/viewmodels/inspection_list_view_model.dart)

- **Uses:** `lib/data/local/inspection_dao.dart`, `lib/models/inspection.dart`, `lib/sync/connectivity_monitor.dart`, `lib/sync/sync_engine.dart`
- **Used by:** `lib/main.dart`, `lib/ui/pages/inspection_list_page.dart`

### `class InspectionListViewModel extends ChangeNotifier`

| Member | Kind | What it does |
|---|---|---|
| `InspectionListViewModel({ required this._dao, required this._engine, required this._connectivity, })` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final InspectionDao _dao` | field | _(auto)_ Injected dependency / private state. |
| `final SyncEngine _engine` | field | _(auto)_ Injected dependency / private state. |
| `final ConnectivityMonitor _connectivity` | field | _(auto)_ Injected dependency / private state. |
| `StreamSubscription<bool>? _sub` | field | Subscription to connectivity changes opened in `init()` and cancelled in `dispose()`. |
| `List<Inspection> items = const []` | field | All stored inspections, newest first, as last loaded by `_reload`; the list page renders it. |
| `bool isOnline = false` | field | Latest known network state; drives the connectivity banner, enables the sync button and gates automatic syncs. |
| `bool isSyncing = false` | field | True while `sync()` is running; shows the spinner and blocks overlapping syncs from this view model. |
| `String? message` | field | One-shot result text (e.g. "2 synced, 1 failed (will retry)") that the list page shows in a snackbar and then clears. |
| `int get unsyncedCount` | getter | Number of loaded items not yet `synced`; shown in the app-bar badge and the connectivity banner. |
| `Future<void> init()` | method | Reads the initial connectivity, subscribes to changes (auto-syncing when the device comes back online), loads the list, and syncs immediately if online; called once from `main.dart` when the provider is created. |
| `Future<void> _reload()` | method | Reloads `items` from the DAO and notifies listeners; called after every save, sync, retry and delete. |
| `Future<void> save(Inspection inspection)` | method | Saves locally first (works fully offline), then syncs if possible. |
| `Future<void> sync()` | method | Runs one sync and reports the result as a snackbar message. Unexpected errors are shown too, and never leave the sync button stuck disabled. |
| `Future<void> retry(Inspection item)` | method | Resets a failed record to pending through `SyncEngine.retry`, reloads, and syncs right away if online; wired to the tile's Retry button. |
| `Future<void> delete(Inspection item)` | method | Removes the record from the local database and reloads; the list page only allows swiping away records that are already synced. |
| `void clearMessage()` | method | Sets `message` to null without notifying listeners; the list page calls it after showing the snackbar so it is not shown again on the next rebuild. |
| `void dispose()` | method | _(auto)_ Releases controllers / listeners when the widget is removed. |

