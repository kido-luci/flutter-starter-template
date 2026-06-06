/// The sync lifecycle of a single local row.
///
/// Stored as an int via [code] so an ObjectBox entity needs no converter.
/// The three `pending*` states form the push queue; [conflicted] and [failed]
/// are terminal states that require user attention and are never retried
/// automatically.
enum SyncState {
  /// In sync with the server.
  synced(0),

  /// Created locally, not yet POSTed.
  pendingCreate(1),

  /// Edited locally, not yet PUT.
  pendingUpdate(2),

  /// Deleted locally (tombstone), not yet DELETEd on the server.
  pendingDelete(3),

  /// The server moved underneath an unsynced local edit. Needs resolution.
  conflicted(4),

  /// The server rejected the push for a non-retryable reason (e.g. validation).
  failed(5);

  const SyncState(this.code);

  /// The stored integer form.
  final int code;

  /// Resolves a [SyncState] from its stored [code], defaulting to [synced] for
  /// unknown values (forward-compatible with older data).
  static SyncState fromCode(int code) {
    for (final state in SyncState.values) {
      if (state.code == code) return state;
    }
    return SyncState.synced;
  }

  /// Whether this row is queued for a push (one of the `pending*` states).
  ///
  /// [conflicted] and [failed] are deliberately excluded: they hold their
  /// state until the user acts, rather than being re-pushed every sync.
  bool get isPending =>
      this == pendingCreate || this == pendingUpdate || this == pendingDelete;

  /// Whether this row needs user attention before it can sync again.
  bool get needsAttention => this == conflicted || this == failed;
}
