import 'dart:async';

import 'package:sync/sync.dart';

/// A minimal [Syncable] row carrying one domain field (`value`).
class FakeRow implements Syncable {
  FakeRow(
    this.uuid,
    this.value,
    this.syncState, {
    this.rev = 0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime(2026);

  @override
  final String uuid;
  String value;
  @override
  SyncState syncState;
  @override
  int rev;
  @override
  DateTime updatedAt;
}

/// The server's view of a row, scripted by tests.
class ServerRow {
  ServerRow({required this.rev, required this.value, this.deleted = false});
  int rev;
  String value;
  bool deleted;
}

/// In-memory [SyncLocalStore]. Stores the row instances as given.
class MemStore implements SyncLocalStore<FakeRow> {
  final Map<String, FakeRow> rows = {};

  @override
  Future<List<FakeRow>> listPending() async =>
      rows.values.where((r) => r.syncState.isPending).toList();

  @override
  Future<FakeRow?> getByUuid(String uuid) async => rows[uuid];

  @override
  Future<void> put(FakeRow row) async => rows[row.uuid] = row;

  @override
  Future<void> hardDelete(FakeRow row) async => rows.remove(row.uuid);
}

/// In-memory cursor store.
class MemCursors implements SyncCursorStore {
  final Map<String, int> _cursors = {};

  @override
  Future<int> read(String resource) async => _cursors[resource] ?? 0;

  @override
  Future<void> write(String resource, int rev) async =>
      _cursors[resource] = rev;
}

/// A scriptable [SyncRemoteAdapter] over an in-memory server map.
class FakeAdapter implements SyncRemoteAdapter<FakeRow> {
  /// The server state, keyed by uuid.
  final Map<String, ServerRow> server = {};

  // Behavior toggles, keyed by uuid.
  final Set<String> conflictOnUpdate = {};
  final Set<String> conflictOnDelete = {};
  final Set<String> terminalOnCreate = {};
  final Set<String> transientOnCreate = {};
  final Set<String> transientOnUpdate = {};

  /// Runs during a create, before it returns — used to simulate a concurrent
  /// local edit (the lost-update guard).
  Future<void> Function(FakeRow row)? onCreate;

  /// The cursor the last [listSince] was called with.
  int? lastSince;

  int _revCounter = 0;

  int _nextRev() {
    final maxServer = server.values.fold(0, (m, r) => r.rev > m ? r.rev : m);
    if (maxServer > _revCounter) _revCounter = maxServer;
    return ++_revCounter;
  }

  @override
  String get resource => 'fakes';

  @override
  Future<PushResult<FakeRow>> create(FakeRow row) async {
    if (transientOnCreate.contains(row.uuid)) {
      throw const SyncTransientException();
    }
    if (terminalOnCreate.contains(row.uuid)) {
      throw const SyncTerminalException();
    }
    if (server.containsKey(row.uuid)) return const PushSuperseded();
    await onCreate?.call(row);
    final rev = _nextRev();
    server[row.uuid] = ServerRow(rev: rev, value: row.value);
    return PushApplied(_record(row.uuid, rev, row.value, false));
  }

  @override
  Future<PushResult<FakeRow>> update(FakeRow row) async {
    if (transientOnUpdate.contains(row.uuid)) {
      throw const SyncTransientException();
    }
    if (conflictOnUpdate.contains(row.uuid)) return const PushConflict();
    final rev = _nextRev();
    server[row.uuid] = ServerRow(rev: rev, value: row.value);
    return PushApplied(_record(row.uuid, rev, row.value, false));
  }

  @override
  Future<PushResult<FakeRow>> delete(FakeRow row) async {
    if (conflictOnDelete.contains(row.uuid)) return const PushConflict();
    if (!server.containsKey(row.uuid)) return const PushGone();
    final rev = _nextRev();
    server[row.uuid]!
      ..rev = rev
      ..deleted = true;
    return PushApplied(_record(row.uuid, rev, row.value, true));
  }

  @override
  Future<void> beforePush(FakeRow row) async {}

  @override
  Future<List<RemoteRecord<FakeRow>>> listSince(int cursor) async {
    lastSince = cursor;
    return [
      for (final entry in server.entries)
        if (entry.value.rev > cursor)
          _record(
            entry.key,
            entry.value.rev,
            entry.value.value,
            entry.value.deleted,
          ),
    ];
  }

  RemoteRecord<FakeRow> _record(
    String uuid,
    int rev,
    String value,
    bool deleted,
  ) {
    return RemoteRecord<FakeRow>(
      uuid: uuid,
      rev: rev,
      updatedAt: DateTime(2026),
      deleted: deleted,
      build: () => FakeRow(uuid, value, SyncState.synced, rev: rev),
      apply: (row) => row.value = value,
    );
  }
}

/// A [ConnectivitySource] driven by a controller, for scheduler tests.
class FakeConnectivity implements ConnectivitySource {
  bool online = true;
  final _controller = StreamController<bool>.broadcast();

  void goOnline() {
    online = true;
    _controller.add(true);
  }

  void goOffline() {
    online = false;
    _controller.add(false);
  }

  Future<void> dispose() => _controller.close();

  @override
  Future<bool> isOnline() async => online;

  @override
  Stream<bool> get onOnlineChanged => _controller.stream;
}
