import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';
import 'package:sync/sync.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/collection.dart';
import '../../domain/repositories/collections_repository.dart';
import '../../domain/services/collections_sync_controller.dart';
import '../local/collection_entity.dart';
import '../local/collections_local_data_source.dart';

/// Offline-first: reads always serve from the local ObjectBox store, writes
/// commit locally first (and mark sync state), then kick a fire-and-forget
/// sync. The UI gets immediate confirmation regardless of network state.
@LazySingleton(as: CollectionsRepository)
class CollectionsRepositoryImpl implements CollectionsRepository {
  CollectionsRepositoryImpl(this._local, this._sync, this._uuid);

  final CollectionsLocalDataSource _local;
  final CollectionsSyncController _sync;
  final Uuid _uuid;

  @override
  Future<Result<List<Collection>>> list() async {
    final result = await listLocal();
    // Trigger a refresh in the background; reads return immediately.
    _sync.sync().uw();
    return result;
  }

  @override
  Future<Result<List<Collection>>> listLocal() async {
    final rows = await _local.listVisible();
    return Ok(rows.map((e) => e.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<Collection>> get(String id) async {
    final row = await _local.getByUuid(id);
    if (row == null || row.syncState == SyncState.pendingDelete) {
      return const Err(NotFoundFailure('Collection not found.'));
    }
    return Ok(row.toDomain());
  }

  @override
  Future<Result<Collection>> create(CollectionInput input) async {
    final normalized = _normalize(input);
    final now = DateTime.now().toUtc();
    final entity = CollectionEntity(
      uuid: _uuid.v4(),
      name: normalized.name,
      icon: normalized.icon,
      color: normalized.color,
      bookmarkIds: List.of(normalized.bookmarkIds),
      createdAt: now,
      updatedAt: now,
      syncStateCode: SyncState.pendingCreate.code,
    );
    await _local.putNew(entity);
    _sync.sync().uw();
    return Ok(entity.toDomain());
  }

  @override
  Future<Result<Collection>> update(String id, CollectionInput input) async {
    final existing = await _local.getByUuid(id);
    if (existing == null || existing.syncState == SyncState.pendingDelete) {
      return const Err(NotFoundFailure('Collection not found.'));
    }
    final normalized = _normalize(input);
    existing.applyInput(normalized, now: DateTime.now().toUtc());
    // pendingCreate stays pendingCreate (still needs the initial POST). Every
    // other state — synced, an existing pendingUpdate, or a conflicted/failed
    // row the user is re-editing — becomes a pendingUpdate to (re)push.
    if (existing.syncState != SyncState.pendingCreate) {
      existing.syncState = SyncState.pendingUpdate;
    }
    await _local.put(existing);
    _sync.sync().uw();
    return Ok(existing.toDomain());
  }

  @override
  Future<Result<void>> delete(String id) async {
    final existing = await _local.getByUuid(id);
    if (existing == null || existing.syncState == SyncState.pendingDelete) {
      return const Err(NotFoundFailure('Collection not found.'));
    }
    // A pendingCreate that's never been synced can be dropped outright —
    // the server has never seen it, so there's nothing to tell it.
    if (existing.syncState == SyncState.pendingCreate) {
      await _local.hardDelete(existing);
      return const Ok(null);
    }
    existing.syncState = SyncState.pendingDelete;
    existing.updatedAt = DateTime.now().toUtc();
    await _local.put(existing);
    _sync.sync().uw();
    return const Ok(null);
  }

  /// Trim the name + dedupe bookmark ids so storage matches what the server
  /// would compute.
  CollectionInput _normalize(CollectionInput input) {
    final seen = <String>{};
    final bookmarkIds = <String>[];
    for (final raw in input.bookmarkIds) {
      final id = raw.trim();
      if (id.isEmpty || !seen.add(id)) continue;
      bookmarkIds.add(id);
    }
    return CollectionInput(
      name: input.name.trim(),
      icon: input.icon,
      color: input.color,
      bookmarkIds: bookmarkIds,
    );
  }
}
