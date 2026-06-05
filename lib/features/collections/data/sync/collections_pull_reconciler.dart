import '../datasources/collections_remote_data_source.dart';
import '../local/collection_entity.dart';
import '../local/collections_local_data_source.dart';

/// Reconciles the local collection store with the server's latest list.
class CollectionsPullReconciler {
  CollectionsPullReconciler(this._local, this._remote);

  final CollectionsLocalDataSource _local;
  final CollectionsRemoteDataSource _remote;

  Future<void> pull() async {
    final serverList = await _remote.list();
    final serverByUuid = {for (final dto in serverList) dto.id: dto};
    final localByUuid = <String, CollectionEntity>{
      for (final row in await _local.listAll()) row.uuid: row,
    };

    for (final dto in serverList) {
      final local = localByUuid[dto.id];
      if (local == null) {
        await _local.put(
          CollectionEntity(
            uuid: dto.id,
            name: dto.name,
            icon: dto.icon,
            color: dto.color,
            bookmarkIds: List.of(dto.bookmarkIds),
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
            serverUpdatedAt: dto.updatedAt,
            syncStateCode: SyncState.synced.code,
          ),
        );
        continue;
      }

      if (local.syncState.isPending) continue;
      if (dto.updatedAt.isAfter(local.updatedAt)) {
        local
          ..name = dto.name
          ..icon = dto.icon
          ..color = dto.color
          ..bookmarkIds = List.of(dto.bookmarkIds)
          ..updatedAt = dto.updatedAt
          ..serverUpdatedAt = dto.updatedAt;
        await _local.put(local);
      }
    }

    for (final local in localByUuid.values) {
      if (local.syncState != SyncState.synced) continue;
      if (serverByUuid.containsKey(local.uuid)) continue;
      await _local.hardDelete(local.id);
    }
  }
}
