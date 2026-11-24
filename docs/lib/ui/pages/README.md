# `lib/ui/pages/`

**Purpose:** Routed screens; they watch view models through Provider and render their state.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/ui/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`inspection_form_page.dart`](#inspection_form_pagedart) | New-report form screen; validates input through `InspectionFormViewModel` and returns the new `Inspection` to the caller when saved. |
| [`inspection_list_page.dart`](#inspection_list_pagedart) | Home screen listing all inspections with sync status, a sync button, the connectivity banner, retry and swipe-to-delete, and a button to file a new report. |

## `inspection_form_page.dart`

**Purpose:** New-report form screen; validates input through `InspectionFormViewModel` and returns the new `Inspection` to the caller when saved.

Source: [`lib/ui/pages/inspection_form_page.dart`](../../../../lib/ui/pages/inspection_form_page.dart)

- **Uses:** `lib/models/inspection.dart`, `lib/viewmodels/inspection_form_view_model.dart`
- **Used by:** `lib/ui/pages/inspection_list_page.dart`

### `class InspectionFormPage extends StatelessWidget`

| Member | Kind | What it does |
|---|---|---|
| `const InspectionFormPage({super.key})` | constructor | _(auto)_ Creates an instance. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

### `class _InspectionForm extends StatefulWidget`

| Member | Kind | What it does |
|---|---|---|
| `const _InspectionForm()` | constructor | _(auto)_ Creates an instance. |
| `State<_InspectionForm> createState()` | method | _(auto)_ Creates the mutable `State` for this widget. |

### `class _InspectionFormState extends State<_InspectionForm>`

| Member | Kind | What it does |
|---|---|---|
| `final _formKey = GlobalKey<FormState>()` | field | Key for the `Form`, used by `_submit` to run all field validators before saving. |
| `final _site = TextEditingController()` | field | Holds the site / village name field text. |
| `final _inspector = TextEditingController()` | field | Holds the inspector name field text. |
| `final _flow = TextEditingController()` | field | Holds the flow rate (L/min) field text, parsed by the view model on save. |
| `final _households = TextEditingController()` | field | Holds the households served field text, parsed by the view model on save. |
| `final _notes = TextEditingController()` | field | Holds the notes / problem description field text. |
| `void dispose()` | method | _(auto)_ Releases controllers / listeners when the widget is removed. |
| `void _submit(InspectionFormViewModel vm)` | method | Validates the form and, if valid, builds the `Inspection` through the view model and pops the page with it as the route result; the list page then saves it. Does nothing if any field is invalid. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

## `inspection_list_page.dart`

**Purpose:** Home screen listing all inspections with sync status, a sync button, the connectivity banner, retry and swipe-to-delete, and a button to file a new report.

Source: [`lib/ui/pages/inspection_list_page.dart`](../../../../lib/ui/pages/inspection_list_page.dart)

- **Uses:** `lib/models/inspection.dart`, `lib/ui/pages/inspection_form_page.dart`, `lib/ui/widgets/connectivity_banner.dart`, `lib/ui/widgets/sync_status_chip.dart`, `lib/viewmodels/inspection_list_view_model.dart`
- **Used by:** `lib/main.dart`

### `class InspectionListPage extends StatelessWidget`

| Member | Kind | What it does |
|---|---|---|
| `const InspectionListPage({super.key})` | constructor | _(auto)_ Creates an instance. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

### `class _InspectionTile extends StatelessWidget`

| Member | Kind | What it does |
|---|---|---|
| `const _InspectionTile({required this.item})` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final Inspection item` | field | _(auto)_ Value passed in by the parent widget. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |
| `static IconData _iconFor(InspectionType t)` | method | Picks the leading avatar icon for each inspection type (build circle, groups, or water drop). |

### `class _EmptyState extends StatelessWidget`

| Member | Kind | What it does |
|---|---|---|
| `const _EmptyState()` | constructor | _(auto)_ Creates an instance. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

