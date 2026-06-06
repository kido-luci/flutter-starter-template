# sync

A reusable, **pure-Dart** offline-first sync engine. It has no Flutter, Dio, or
ObjectBox dependency — transport and storage specifics stay in per-feature
adapters — so the reconciliation logic is unit-tested in isolation.

Used by the `bookmarks` and `collections` features (full CRUD sync) and, for its
scheduler only, by `notifications` (a read-state variant).

## Pieces

- **`SyncScheduler`** — the cross-cutting machinery every synced resource shares:
  connectivity-driven triggers (via `ConnectivitySource`), an offline→online
  re-sync, single-flight (concurrent `sync()` calls share one run), a start/stop
  generation guard, exponential-backoff retry, and a `SyncStatus` stream. It runs
  any `Future<SyncOutcome> Function()` body.
- **`OfflineCrudSync<T>`** — the generic CRUD body: a push queue followed by a
  delta pull, keyed on the server **revision (`rev`)** as both the delta cursor
  and the optimistic-concurrency token. Push classifies outcomes
  (applied / superseded / conflict / gone) and retryable-vs-terminal failures,
  and guards against lost updates. Pull is delta-based and applies tombstones
  explicitly (deletes are never inferred from absence).
- **Contracts** a feature implements: `Syncable` (the row), `SyncLocalStore<T>`
  (the local DB), `SyncRemoteAdapter<T>` (DTO mapping + HTTP-error translation),
  and `SyncCursorStore` (persisted delta cursor).

## Plugging in a feature

```dart
// 1. The entity implements Syncable (uuid, updatedAt, rev, syncState).
// 2. The local data source implements SyncLocalStore<T>.
// 3. A per-feature adapter implements SyncRemoteAdapter<T>:
//    - maps DTOs <-> rows and entity -> request,
//    - sends the base rev for conflict detection,
//    - turns DioExceptions into PushResult / Sync{Transient,Terminal}Exception,
//    - optionally does work in beforePush (e.g. upload media).
// 4. The sync controller is just composition:
final scheduler = SyncScheduler(
  OfflineCrudSync<T>(localStore, adapter, cursorStore).run,
  connectivity,
);
```

See `lib/features/bookmarks/data/sync/` for a complete worked example, and the
[Offline-First Sync](../../README.md#-offlinefirst-sync) section of the root
README for the end-to-end picture.

## Tests

`fvm flutter test` (inside this package) covers the scheduler (single-flight,
offline→online, backoff, generation guard) and `OfflineCrudSync` (push outcomes,
the lost-update guard, delta/tombstone/conflict reconciliation) with in-memory
fakes — no network or database needed.
