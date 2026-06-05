import 'package:injectable/injectable.dart' hide Order;

import '../../../../objectbox.g.dart' hide SyncState;
import 'collection_entity.dart';

/// ObjectBox-backed CRUD + sync helpers. All operations are synchronous on
/// the ObjectBox side; wrapped in `Future` to keep the repository contract
/// async-friendly.
///
/// Identity at this layer is the string [CollectionEntity.uuid]. The integer
/// `id` is an internal ObjectBox PK that callers never see.
abstract interface class CollectionsLocalDataSource {
  /// All non-tombstoned collections, newest-first.
  Future<List<CollectionEntity>> listVisible();

  /// Includes tombstoned (pendingDelete) rows. Used by the sync service.
  Future<List<CollectionEntity>> listAll();

  Future<CollectionEntity?> getByUuid(String uuid);

  /// Rows with any non-synced state, ordered by [CollectionEntity.updatedAt].
  Future<List<CollectionEntity>> listPending();

  /// Inserts a new row in [SyncState.pendingCreate].
  Future<CollectionEntity> putNew(CollectionEntity entity);

  /// Persists changes to an existing row. Caller owns sync state changes.
  Future<void> put(CollectionEntity entity);

  /// Hard-removes by internal PK. Used after a successful pendingDelete push.
  Future<void> hardDelete(int pk);
}

@LazySingleton(as: CollectionsLocalDataSource)
class ObjectBoxCollectionsDataSource implements CollectionsLocalDataSource {
  ObjectBoxCollectionsDataSource(Store store)
    : _box = store.box<CollectionEntity>();

  final Box<CollectionEntity> _box;

  @override
  Future<List<CollectionEntity>> listVisible() async {
    final query = _box
        .query(
          CollectionEntity_.syncStateCode.notEquals(
            SyncState.pendingDelete.code,
          ),
        )
        .order(CollectionEntity_.createdAt, flags: Order.descending)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<List<CollectionEntity>> listAll() async {
    final query = _box
        .query()
        .order(CollectionEntity_.createdAt, flags: Order.descending)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<CollectionEntity?> getByUuid(String uuid) async {
    final query = _box.query(CollectionEntity_.uuid.equals(uuid)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

  @override
  Future<List<CollectionEntity>> listPending() async {
    final query = _box
        .query(CollectionEntity_.syncStateCode.notEquals(SyncState.synced.code))
        .order(CollectionEntity_.updatedAt)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<CollectionEntity> putNew(CollectionEntity entity) async {
    _box.put(entity);
    return entity;
  }

  @override
  Future<void> put(CollectionEntity entity) async {
    _box.put(entity);
  }

  @override
  Future<void> hardDelete(int pk) async {
    _box.remove(pk);
  }
}
