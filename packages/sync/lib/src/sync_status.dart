/// The user-facing sync state, surfaced by the scheduler to drive UI such as an
/// app-bar indicator.
enum SyncStatus {
  /// No sync running and the last one succeeded.
  idle,

  /// A sync is in progress.
  syncing,

  /// The last sync failed or left rows unsynced; a retry is scheduled.
  error,
}

/// The result of one sync run, returned by a scheduler body. Drives both the
/// surfaced [SyncStatus] and the scheduler's backoff.
enum SyncOutcome {
  /// Everything pushed and pulled cleanly.
  ok,

  /// The run completed but some rows stayed pending (e.g. a transient per-row
  /// failure); worth retrying with backoff.
  hadFailures,

  /// The run aborted (e.g. the pull threw); retry with backoff.
  error,
}
