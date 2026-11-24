# `lib/models/`

**Purpose:** Plain immutable domain models with their SQLite row and API JSON conversions.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`inspection.dart`](#inspectiondart) | The inspection record that field teams save, with its enums, sync state and row and JSON mapping. |

## `inspection.dart`

**Purpose:** The inspection record that field teams save, with its enums, sync state and row and JSON mapping.

Source: [`lib/models/inspection.dart`](../../../lib/models/inspection.dart)

- **Uses:** —
- **Used by:** `lib/data/local/inspection_dao.dart`, `lib/data/remote/inspection_api.dart`, `lib/sync/sync_engine.dart`, `lib/ui/pages/inspection_form_page.dart`, `lib/ui/pages/inspection_list_page.dart`, `lib/ui/widgets/sync_status_chip.dart`, `lib/viewmodels/inspection_form_view_model.dart`, `lib/viewmodels/inspection_list_view_model.dart`

### `enum InspectionType`

> The inspection record that field teams save, with its enums, sync state and
> row and JSON mapping.

| Member | Kind | What it does |
|---|---|---|
| `installation('Installation')` | value | _(auto)_ Enum value. |
| `assessment('Community assessment')` | value | _(auto)_ Enum value. |
| `maintenance('Maintenance')` | value | _(auto)_ Enum value. |
| `const InspectionType(this.label)` | constructor | _(auto)_ Creates an instance. |
| `final String label` | field | Display text for the type, shown in the form's segmented button and the list tile subtitle. |

### `enum PumpCondition`

| Member | Kind | What it does |
|---|---|---|
| `working('Working')` | value | _(auto)_ Enum value. |
| `needsRepair('Needs repair')` | value | _(auto)_ Enum value. |
| `broken('Broken')` | value | _(auto)_ Enum value. |
| `const PumpCondition(this.label)` | constructor | _(auto)_ Creates an instance. |
| `final String label` | field | Display text for the condition, shown in the form dropdown and the list tile subtitle. |

### `enum SyncStatus`

> Where a record is in the outbox. Everything starts as [pending] and is
> only ever written locally first; the sync engine moves it on.

| Member | Kind | What it does |
|---|---|---|
| `pending` | value | _(auto)_ Enum value. |
| `syncing` | value | _(auto)_ Enum value. |
| `synced` | value | _(auto)_ Enum value. |
| `failed` | value | _(auto)_ Enum value. |

### `class Inspection`

| Member | Kind | What it does |
|---|---|---|
| `const Inspection({ required this.id, required this.siteName, required this.inspectorName, required this.type, required this.condition, required this.flowRateLpm, required this.h…` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final String id` | field | Client-generated UUID v4, so the record exists and is addressable before the server sees it; also sent as the upload `Idempotency-Key` and `clientId`. |
| `final String siteName` | field | Site or village name entered in the form (trimmed); shown as the list tile title. |
| `final String inspectorName` | field | Name of the person who filed the report (trimmed); sent to the server as `inspector`. |
| `final InspectionType type` | field | Kind of visit (installation, assessment or maintenance); stored and sent by its enum `name`. |
| `final PumpCondition condition` | field | Pump state found on site; anything other than `working` makes notes mandatory in the form. |
| `final double flowRateLpm` | field | Measured flow rate in litres per minute; the form only accepts 0 to 500. |
| `final int householdsServed` | field | Number of households the pump serves; the form rejects negative or non-integer input. |
| `final String notes` | field | Free-text notes or problem description; required (10+ chars) when the pump is not working, otherwise may be empty. |
| `final DateTime createdAt` | field | When the report was created on the device; drives list order (newest first) and sync order (oldest first). |
| `final DateTime updatedAt` | field | Last local change time; set at creation and bumped by `SyncEngine` when an upload succeeds. |
| `final SyncStatus syncStatus` | field | Where the record is in the outbox; defaults to `pending` and is moved on only by `SyncEngine` (or reset by a manual retry). |
| `final int attempts` | field | How many upload attempts have been made (success or failure); feeds `SyncEngine.backoff` to compute the next retry delay. |
| `final DateTime? nextRetryAt` | field | Earliest time a failed record may be retried automatically; null for non-failed records and for non-retryable (4xx) failures that need a manual retry. |
| `final String? lastError` | field | Message from the most recent failed upload, shown under the list tile; cleared on success or manual retry. |
| `final int? remoteId` | field | Server-side id returned by a successful upload; null until synced. |
| `Inspection copyWith({ SyncStatus? syncStatus, int? attempts, DateTime? Function()? nextRetryAt, String? Function()? lastError, int? remoteId, DateTime? updatedAt, })` | method | Returns a copy with only sync-related fields changed (form data is fixed). Nullable `nextRetryAt` and `lastError` are passed as functions so callers can explicitly set them to null with `() => null`. |
| `Map<String, Object?> toRow()` | method | Converts the record to a SQLite row map: snake_case columns, enums by `name`, dates as epoch milliseconds; used by `InspectionDao.upsert`. |
| `factory Inspection.fromRow(Map<String, Object?> row)` | constructor | _(auto)_ Creates an instance. |
| `Map<String, Object?> toApiJson()` | method | Payload sent to the web application. |

