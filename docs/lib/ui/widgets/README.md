# `lib/ui/widgets/`

**Purpose:** Small presentational widgets used by the pages; they render values passed in by the parent.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/ui/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`connectivity_banner.dart`](#connectivity_bannerdart) | Full-width banner showing whether the device is online or offline and how many records are waiting to sync. |
| [`sync_status_chip.dart`](#sync_status_chipdart) | Small icon-and-label chip showing a record's sync status in a matching colour. |

## `connectivity_banner.dart`

**Purpose:** Full-width banner showing whether the device is online or offline and how many records are waiting to sync.

Source: [`lib/ui/widgets/connectivity_banner.dart`](../../../../lib/ui/widgets/connectivity_banner.dart)

- **Uses:** —
- **Used by:** `lib/ui/pages/inspection_list_page.dart`

### `class ConnectivityBanner extends StatelessWidget`

| Member | Kind | What it does |
|---|---|---|
| `const ConnectivityBanner({ super.key, required this.isOnline, required this.unsynced, })` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final bool isOnline` | field | _(auto)_ Value passed in by the parent widget. |
| `final int unsynced` | field | _(auto)_ Value passed in by the parent widget. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

## `sync_status_chip.dart`

**Purpose:** Small icon-and-label chip showing a record's sync status in a matching colour.

Source: [`lib/ui/widgets/sync_status_chip.dart`](../../../../lib/ui/widgets/sync_status_chip.dart)

- **Uses:** `lib/models/inspection.dart`
- **Used by:** `lib/ui/pages/inspection_list_page.dart`

### `class SyncStatusChip extends StatelessWidget`

| Member | Kind | What it does |
|---|---|---|
| `const SyncStatusChip({super.key, required this.status})` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final SyncStatus status` | field | _(auto)_ Value passed in by the parent widget. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

