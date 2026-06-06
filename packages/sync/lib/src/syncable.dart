import 'sync_state.dart';

/// A local row the sync engine can reconcile with the server.
///
/// Implemented by each feature's ObjectBox entity. Identity is the stable
/// string [uuid] (minted client-side at create time so a row has a meaningful
/// id before its first push). [rev] is the server's per-owner revision, used as
/// both the delta cursor and the optimistic-concurrency token; it is 0 until
/// the row is first acknowledged by the server.
abstract interface class Syncable {
  /// Stable, client-minted identity shared with the server.
  String get uuid;

  /// The row's sync lifecycle.
  SyncState get syncState;
  set syncState(SyncState value);

  /// Last local mutation time. Compared before/after a push to detect a
  /// concurrent edit (the lost-update guard).
  DateTime get updatedAt;

  /// The server revision this row was last reconciled to. Drives last-write-
  /// wins on pull (higher server rev wins) and conflict detection.
  int get rev;
  set rev(int value);
}
