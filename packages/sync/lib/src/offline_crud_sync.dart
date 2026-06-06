import 'remote_record.dart';
import 'sync_cursor_store.dart';
import 'sync_local_store.dart';
import 'sync_remote_adapter.dart';
import 'sync_state.dart';
import 'sync_status.dart';
import 'syncable.dart';

/// The generic body of an offline-first CRUD sync: a push queue followed by a
/// delta pull, reconciling a [SyncLocalStore] with a [SyncRemoteAdapter] using
/// the server's revision (`rev`) as both the delta cursor and the
/// optimistic-concurrency token.
///
/// Run it through a scheduler (which owns connectivity, single-flight and
/// backoff); [run] is the body the scheduler invokes.
class OfflineCrudSync<T extends Syncable> {
  OfflineCrudSync(this._store, this._remote, this._cursors);

  final SyncLocalStore<T> _store;
  final SyncRemoteAdapter<T> _remote;
  final SyncCursorStore _cursors;

  /// Pushes pending local writes, then pulls server changes. Never throws:
  /// failures map to [SyncOutcome.hadFailures] (some rows stayed pending) or
  /// [SyncOutcome.error] (the pull aborted), both of which the scheduler retries.
  Future<SyncOutcome> run() async {
    final pushHadFailures = await _push();
    try {
      await _pull();
    } on Object {
      return SyncOutcome.error;
    }
    return pushHadFailures ? SyncOutcome.hadFailures : SyncOutcome.ok;
  }

  /// Drains the push queue. Each row is isolated so one bad row can't block the
  /// rest. Returns true if any row stayed pending (a retryable failure).
  Future<bool> _push() async {
    final pending = await _store.listPending();
    var hadFailure = false;
    for (final row in pending) {
      try {
        await _pushRow(row);
      } on SyncTerminalException {
        await _mark(row, SyncState.failed);
      } on SyncTransientException {
        hadFailure = true;
      } on Object {
        // An unexpected error is treated as transient so the row is retried
        // rather than silently dropped.
        hadFailure = true;
      }
    }
    return hadFailure;
  }

  Future<void> _pushRow(T row) async {
    switch (row.syncState) {
      case SyncState.pendingCreate:
        // Snapshot the edit time before any network work so the lost-update
        // guard can detect a concurrent edit, regardless of whether the store
        // hands back the same instance or a fresh one.
        final base = row.updatedAt;
        await _remote.beforePush(row);
        await _applyPush(row, base, await _remote.create(row));
      case SyncState.pendingUpdate:
        final base = row.updatedAt;
        await _remote.beforePush(row);
        await _applyPush(row, base, await _remote.update(row));
      case SyncState.pendingDelete:
        await _applyDeletePush(row, await _remote.delete(row));
      case SyncState.synced:
      case SyncState.conflicted:
      case SyncState.failed:
        break;
    }
  }

  Future<void> _applyPush(T row, DateTime base, PushResult<T> result) async {
    switch (result) {
      case PushApplied<T>(:final record):
        final fresh = await _store.getByUuid(row.uuid);
        if (fresh == null) return;
        // Lost-update guard: the row was edited while the request was in
        // flight. The server accepted the prior state at record.rev, but a
        // newer local edit exists — record the new rev and re-queue it as an
        // update (a create has now happened server-side) so the newer edit is
        // pushed next cycle instead of being clobbered or re-created.
        if (fresh.updatedAt != base) {
          fresh.rev = record.rev;
          if (fresh.syncState == SyncState.pendingCreate) {
            fresh.syncState = SyncState.pendingUpdate;
          }
          await _store.put(fresh);
          return;
        }
        record.apply(fresh);
        fresh
          ..rev = record.rev
          ..syncState = SyncState.synced;
        await _store.put(fresh);
      case PushSuperseded<T>():
        // Create lost its response but the row exists server-side: treat as
        // synced; the pull refreshes its authoritative fields.
        await _mark(row, SyncState.synced);
      case PushConflict<T>():
        await _mark(row, SyncState.conflicted);
      case PushGone<T>():
        // We tried to update a row the server deleted elsewhere; surface it.
        await _mark(row, SyncState.conflicted);
    }
  }

  Future<void> _applyDeletePush(T row, PushResult<T> result) async {
    switch (result) {
      case PushApplied<T>():
      case PushSuperseded<T>():
      case PushGone<T>():
        // Accepted, or the server no longer had it: either way it's gone.
        await _store.hardDelete(row);
      case PushConflict<T>():
        await _mark(row, SyncState.conflicted);
    }
  }

  /// Pulls every server change since the stored cursor and reconciles by uuid,
  /// then advances the cursor. Delta-based: only changed rows are touched, and
  /// deletions arrive as explicit tombstones (never inferred from absence).
  Future<void> _pull() async {
    final cursor = await _cursors.read(_remote.resource);
    final records = await _remote.listSince(cursor);
    var maxRev = cursor;
    for (final record in records) {
      if (record.rev > maxRev) maxRev = record.rev;
      await _reconcile(record);
    }
    if (maxRev != cursor) await _cursors.write(_remote.resource, maxRev);
  }

  Future<void> _reconcile(RemoteRecord<T> record) async {
    final local = await _store.getByUuid(record.uuid);

    if (record.deleted) {
      if (local == null) return;
      if (local.syncState.isPending) {
        // We have an unpushed local edit for a row the server deleted: conflict.
        await _mark(local, SyncState.conflicted);
      } else {
        await _store.hardDelete(local);
      }
      return;
    }

    if (local == null) {
      await _store.put(record.build());
      return;
    }

    // A pendingCreate appearing on the server is just our own create landing
    // (the uuid is client-minted and unique to us) — typically a create whose
    // response was lost. It is NOT a conflict: leave it queued so the push
    // retry finalizes it (the retried POST gets a 409 → superseded → synced).
    if (local.syncState == SyncState.pendingCreate) return;

    // An unsynced local edit wins until pushed — unless the server has moved
    // past the revision it was based on, which is a conflict.
    if (local.syncState.isPending) {
      if (record.rev > local.rev) await _mark(local, SyncState.conflicted);
      return;
    }

    // Synced row: last-write-wins by server revision.
    if (record.rev > local.rev) {
      record.apply(local);
      local
        ..rev = record.rev
        ..syncState = SyncState.synced;
      await _store.put(local);
    }
  }

  Future<void> _mark(T row, SyncState state) async {
    row.syncState = state;
    await _store.put(row);
  }
}
