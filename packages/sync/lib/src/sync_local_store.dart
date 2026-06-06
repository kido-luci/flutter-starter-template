import 'syncable.dart';

/// The local persistence the sync engine drives, abstracted over the concrete
/// store (ObjectBox in the app). Implementations are expected to be backed by a
/// fast local database; all methods are async only to keep the contract
/// storage-agnostic.
abstract interface class SyncLocalStore<T extends Syncable> {
  /// Rows queued for a push — exactly those whose [Syncable.syncState] is
  /// pending (create/update/delete). Must NOT include `conflicted`/`failed`
  /// rows, which await user action. Ordered oldest-edit first.
  Future<List<T>> listPending();

  /// The row with [uuid], or null if absent. Returns tombstoned
  /// (`pendingDelete`) rows too — the engine needs them.
  Future<T?> getByUuid(String uuid);

  /// Inserts or updates [row] by its uuid.
  Future<void> put(T row);

  /// Permanently removes [row] (after a delete is confirmed, or when the server
  /// reports it gone).
  Future<void> hardDelete(T row);
}
