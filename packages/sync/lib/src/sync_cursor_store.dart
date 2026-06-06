/// Persists the per-resource delta cursor — the highest server revision a pull
/// has already applied. The next pull asks the server only for newer rows.
///
/// Keyed by a resource string (e.g. `'bookmarks'`) so one store can serve
/// several synced resources.
abstract interface class SyncCursorStore {
  /// The last applied revision for [resource], or 0 if none (a full first pull).
  Future<int> read(String resource);

  /// Records [rev] as the last applied revision for [resource].
  Future<void> write(String resource, int rev);
}
