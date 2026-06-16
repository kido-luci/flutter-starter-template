import 'package:sync/sync.dart';

export 'package:sync/sync.dart' show SyncStatus;

/// The collections sync status, aliased to the shared engine status so existing
/// callers keep using `CollectionsSyncStatus.idle/syncing/error`.
typedef CollectionsSyncStatus = SyncStatus;

/// Controls the collections offline-first sync lifecycle. The app starts it on
/// sign-in and stops it on sign-out; the repository triggers [sync] after each
/// local mutation.
abstract interface class CollectionsSyncController {
  /// Surfaced status for the UI.
  Stream<SyncStatus> get statusStream;

  /// The latest [statusStream] value.
  SyncStatus get statusNow;

  /// Begin reacting to connectivity and run an initial sync. Idempotent.
  Future<void> start();

  /// Stop syncing and reset. Called on sign-out.
  Future<void> stop();

  /// Trigger a sync now. Concurrent callers share one in-flight run.
  Future<void> sync();
}
