# `lib/data/remote/`

**Purpose:** Remote data source: uploads inspection records to the web application over HTTP.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/data/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`inspection_api.dart`](#inspection_apidart) | Uploads inspection records to the web backend and marks each failure as retryable or not. |

## `inspection_api.dart`

**Purpose:** Uploads inspection records to the web backend and marks each failure as retryable or not.

Source: [`lib/data/remote/inspection_api.dart`](../../../../lib/data/remote/inspection_api.dart)

- **Uses:** `lib/models/inspection.dart`
- **Used by:** `lib/main.dart`, `lib/sync/background_sync.dart`, `lib/sync/sync_engine.dart`

### `class SyncException implements Exception`

> Uploads inspection records to the web backend and marks each failure as
> retryable or not.

| Member | Kind | What it does |
|---|---|---|
| `const SyncException(this.message, {this.retryable = true})` | constructor | _(auto)_ Creates an instance. |
| `final String message` | field | Human-readable failure reason (network error or rejected status code); `SyncEngine` stores it in `lastError`, which the list tile shows under the record. |
| `final bool retryable` | field | 4xx validation errors won't succeed on retry; 5xx and network errors will. |
| `String toString()` | method | Returns just `message`, so the exception prints cleanly in logs and UI. |

### `abstract interface class InspectionApi`

| Member | Kind | What it does |
|---|---|---|
| `Future<int> upload(Inspection inspection)` | method | Uploads one record and returns the server-side id. |

### `class HttpInspectionApi implements InspectionApi`

> Talks to the web application. Defaults to JSONPlaceholder, which accepts
> POSTs and echoes an id, so the sync flow can be demoed end to end.

| Member | Kind | What it does |
|---|---|---|
| `HttpInspectionApi({ http.Client? client, this.baseUrl = 'https://jsonplaceholder.typicode.com', }) : _client = client ?? http.Client()` | constructor | _(auto)_ Creates an instance. |
| `final http.Client _client` | field | HTTP client used for uploads; injectable so tests can pass a mock client, defaulting to a new `http.Client()`. |
| `final String baseUrl` | field | Server root the record is POSTed to at `$baseUrl/posts`; defaults to JSONPlaceholder for demos. |
| `Future<int> upload(Inspection inspection)` | method | POSTs `toApiJson()` with an `Idempotency-Key` header set to the record's UUID and a 20-second timeout, returning the `id` from a 2xx response. Network errors throw a retryable `SyncException`; other statuses throw one that is retryable only for 5xx or 429. |

