# Features

This directory contains the distinct feature modules of the application, structured using a feature-first approach combined with Clean Architecture.

Each folder in this directory represents an independent, cohesive feature of the app (e.g., `auth`, `home`, `profile`, `bookmarks`, `splash`).

## Clean Architecture Structure

Inside each feature directory, you will typically find the following three layers:

### 1. `domain/`
The innermost layer containing the core business logic of the feature. It should be independent of any external packages, frameworks, or UI code.
- **Entities:** Immutable domain models representing core business objects (typically utilizing `freezed`).
- **Repositories (Interfaces):** Abstract contracts/interfaces defining how data is accessed.
- **Use Cases / Services:** Classes containing the business rules that orchestrate repositories.

### 2. `data/`
The outermost layer responsible for data retrieval and persistence. This layer implements the repository interfaces defined in the domain layer.
- **Repositories (Implementations):** Concrete classes that implement domain interfaces.
- **Data Sources:** Classes that handle communication with external APIs, local databases, Firebase, or shared preferences.
- **DTOs (Data Transfer Objects):** Models specifically used for parsing external data formats (like JSON).

### 3. `presentation/`
The UI layer responsible for displaying information to the user and capturing user input.
- **State Management:** BLoCs that manage the state of the UI and interact with domain services.
- **Screens / Pages:** Full-screen widgets representing a complete view.
- **Widgets:** Smaller, reusable UI components specific to this feature.

## Best Practices

- **Feature Independence:** Features should be as isolated as possible. As a default, a feature must **not** import another feature's `presentation` layer — shared *state* is read through a contract in `lib/shared/` instead. The one deliberate exception is a *capability* (a self-contained presentation object one feature surfaces inside another); while only a single consumer exists, importing it directly is allowed.
- **Shared Code:** Pick the destination by what kind of thing it is:
  - *Business* vocabulary used by 2+ features (e.g. the session, shared entities) → `lib/shared/`, on the **rule of three** (promote only when ≥2 features depend on it today).
  - *Cross-cutting, non-visual* infrastructure → `lib/core/` (app-coupled) or a workspace package (reusable).
  - *Generic visual* building blocks → the `app_ui` package.
- **Immutability:** Use immutable models and `Freezed` unions for state management and domain entities.
- **Dependency Injection:** Dependencies are injected using `get_it` + `injectable` (composition root in `lib/core/di/`).

## 📶 Offline‑First Sync

Writes commit to the local **ObjectBox** store first and the UI updates
immediately — the network is reconciled in the background, so the app stays
fully usable offline. The sync machinery is a single reusable engine in the
**`sync` package** (`packages/sync`); `bookmarks` and `collections` drive it
through a thin per‑feature adapter, and `notifications` is a read‑state variant
that reuses only the scheduler.

### 🧩 One shared engine

`package:sync` is pure Dart (no Flutter/Dio/ObjectBox), so it is unit‑tested in
isolation. A feature plugs in by implementing three small contracts:

- **`SyncLocalStore<T>`** — the local store (the ObjectBox data source).
- **`SyncRemoteAdapter<T>`** — maps DTOs ↔ rows, sends requests, and translates
  HTTP errors into the engine's outcomes. The one bookmarks‑specific piece
  (`BookmarksSyncAdapter`) also checkpoints media uploads before a push.
- **`Syncable`** — the row exposes `uuid`, `updatedAt`, `rev`, and `syncState`.

The composition root for a feature is ~5 lines:
`SyncScheduler(OfflineCrudSync(localStore, adapter, cursorStore).run)`.

### ✍️ Local‑first writes

The repository persists to ObjectBox, stamps a sync state, then fires a
fire‑and‑forget `sync()`. The caller never waits on the server. Each row carries
its lifecycle as an int code so ObjectBox needs no converter:

```text
synced(0) · pendingCreate(1) · pendingUpdate(2) · pendingDelete(3) · conflicted(4) · failed(5)
```

`listPending()` feeds the push queue with only the three active states —
`conflicted`/`failed` rows hold until the user acts.

### 🔄 The scheduler

`SyncScheduler` owns the cross‑cutting machinery every resource shares:
connectivity (via a `ConnectivitySource`), an **offline→online** re‑sync,
single‑flight (concurrent `sync()` callers share one run), a start/stop
generation guard, and **exponential backoff** — a run that fails or leaves rows
pending is retried on a timer, not just on the next user action.

### ⬆️ Push (with conflict detection)

`OfflineCrudSync` drains the pending rows, each isolated so one bad row can't
block the queue. The client‑generated `uuid` is the stable identity across both
sides; every update/delete echoes the row's **server revision (`rev`)** so the
server can reject a stale write:

| State | Action | Edge cases |
|-------|--------|------------|
| `pendingCreate` | `beforePush` (media), `POST` | **409** → already created → `synced` |
| `pendingUpdate` | `PUT` with base `rev` | **409** → server moved → `conflicted`; **404** → `conflicted` |
| `pendingDelete` | `DELETE` with base `rev`, then hard‑delete | **404** → already gone → success; **409** → `conflicted` |

Two correctness guards: a **lost‑update guard** re‑reads the row after a push and
leaves it queued if it was edited mid‑flight (so a concurrent edit is never
clobbered by the ack), and errors are **classified** — non‑retryable `4xx` mark
the row `failed` and surface it, while `5xx`/network/timeout stay pending for
backoff retry.

### ⬇️ Pull (delta + tombstones)

Pull is **incremental**: it sends the highest `rev` it has seen
(`GET …?since=<rev>`) and the server returns only newer rows — including
**tombstones** for deletes. There is no full‑table scan and deletions are never
inferred from absence. Reconciliation by `uuid`:

- Server row absent locally → insert as `synced`.
- Tombstone over a `synced` row → hard‑delete; over a pending edit → `conflicted`.
- Server `rev` newer than a `synced` row → overwrite local fields.
- Local row is **pending** → kept; if the server moved past its base `rev`, it's
  flagged `conflicted` for the user to resolve.

Conflicts are **detected and surfaced**, not silently merged — and any local
change you haven't pushed is never clobbered by a pull.
