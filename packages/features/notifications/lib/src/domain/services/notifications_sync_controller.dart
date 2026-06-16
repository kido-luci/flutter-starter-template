/// Reconciles the local notification/activity cache with the remote API.
///
/// Notifications are read-mostly, so this is lighter than a full bidirectional
/// sync: it flushes pending read-marks, then refreshes both cached lists.
abstract interface class NotificationsSyncController {
  /// Emits once after each completed sync cycle so the UI can re-read the
  /// refreshed cache without a manual pull-to-refresh.
  Stream<void> get onSynced;

  /// Begin reacting to connectivity changes and run an initial sync.
  /// Idempotent.
  Future<void> start();

  /// Stop listening to connectivity. Called on sign-out.
  Future<void> stop();

  /// Public trigger. Concurrent callers share the in-flight future.
  Future<void> sync();
}
