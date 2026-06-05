import 'package:network/network.dart';

import '../datasources/collections_remote_data_source.dart';
import '../local/collection_entity.dart';
import '../local/collections_local_data_source.dart';
import '../models/collection_dto.dart';
import '../models/collection_request.dart';

/// Pushes pending local collection mutations to the remote API.
class CollectionsPushQueue {
  CollectionsPushQueue(this._local, this._remote);

  final CollectionsLocalDataSource _local;
  final CollectionsRemoteDataSource _remote;

  /// Drains every pending row. Each row is isolated so a single permanently
  /// rejected row cannot block the rest of the queue. Returns true if any row
  /// failed and stayed pending.
  Future<bool> push() async {
    final pending = await _local.listPending();
    var hadFailure = false;
    for (final row in pending) {
      try {
        await _pushRow(row);
      } on Object {
        hadFailure = true;
      }
    }
    return hadFailure;
  }

  Future<void> _pushRow(CollectionEntity row) async {
    switch (row.syncState) {
      case SyncState.pendingCreate:
        try {
          final dto = await _remote.create(
            CollectionRequest(
              id: row.uuid,
              name: row.name,
              icon: row.icon,
              color: row.color,
              bookmarkIds: row.bookmarkIds,
            ),
          );
          _markSynced(row, dto);
          await _local.put(row);
        } on DioException catch (e) {
          // 409: a previous attempt already created this row server-side, but
          // its response was lost. Pull reconciliation refreshes its fields.
          if (e.response?.statusCode != 409) rethrow;
          row.syncState = SyncState.synced;
          await _local.put(row);
        }
      case SyncState.pendingUpdate:
        final dto = await _remote.update(
          row.uuid,
          CollectionRequest(
            name: row.name,
            icon: row.icon,
            color: row.color,
            bookmarkIds: row.bookmarkIds,
          ),
        );
        _markSynced(row, dto);
        await _local.put(row);
      case SyncState.pendingDelete:
        try {
          await _remote.delete(row.uuid);
        } on DioException catch (e) {
          // 404 is fine: server already lost it. Anything else leaves the row
          // pending for the next sync.
          if (e.response?.statusCode != 404) rethrow;
        }
        await _local.hardDelete(row.id);
      case SyncState.synced:
        break;
    }
  }

  void _markSynced(CollectionEntity row, CollectionDto dto) {
    row
      ..syncState = SyncState.synced
      ..serverUpdatedAt = dto.updatedAt
      ..bookmarkIds = List.of(dto.bookmarkIds);
  }
}
