import 'syncable.dart';

/// A server view of one row, returned by a delta pull or a push acknowledgement.
///
/// The engine is generic over `T`, so the adapter — which alone knows `T`'s
/// fields — supplies [build] (construct a fresh synced row from this record) and
/// [apply] (overwrite an existing row's server-derived fields). For a [deleted]
/// tombstone both may be unused.
class RemoteRecord<T extends Syncable> {
  RemoteRecord({
    required this.uuid,
    required this.rev,
    required this.updatedAt,
    required this.deleted,
    required this.build,
    required this.apply,
  });

  /// Stable identity, matched against the local row's [Syncable.uuid].
  final String uuid;

  /// The server revision of this record. Monotonic per owner.
  final int rev;

  /// The server's last-modified timestamp for this record.
  final DateTime updatedAt;

  /// Whether this record is a tombstone (the server soft-deleted the row).
  final bool deleted;

  /// Builds a brand-new local row from this record, in the synced state.
  final T Function() build;

  /// Writes this record's domain fields onto an existing row. Does not touch
  /// sync bookkeeping (rev / syncState); the engine owns that.
  final void Function(T row) apply;
}

/// The outcome of pushing one pending row to the server.
sealed class PushResult<T extends Syncable> {
  const PushResult();
}

/// The server accepted the write; [record] carries its authoritative values.
class PushApplied<T extends Syncable> extends PushResult<T> {
  const PushApplied(this.record);

  final RemoteRecord<T> record;
}

/// A create was rejected because the row already exists server-side (a retried
/// create whose first response was lost). It is effectively synced; the next
/// pull refreshes its fields.
class PushSuperseded<T extends Syncable> extends PushResult<T> {
  const PushSuperseded();
}

/// An update/delete was rejected because the server revision no longer matches
/// the one the edit was based on — a genuine conflict needing resolution.
class PushConflict<T extends Syncable> extends PushResult<T> {
  const PushConflict();
}

/// An update/delete targeted a row the server no longer has.
class PushGone<T extends Syncable> extends PushResult<T> {
  const PushGone();
}

/// A retryable failure (network down, timeout, server 5xx). The row keeps its
/// pending state and is retried on the next sync.
class SyncTransientException implements Exception {
  const SyncTransientException([this.message]);

  final String? message;

  @override
  String toString() => 'SyncTransientException(${message ?? ''})';
}

/// A non-retryable failure (e.g. validation 4xx). The row is marked failed and
/// surfaced rather than retried forever.
class SyncTerminalException implements Exception {
  const SyncTerminalException([this.message]);

  final String? message;

  @override
  String toString() => 'SyncTerminalException(${message ?? ''})';
}
