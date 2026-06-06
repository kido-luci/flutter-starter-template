import 'package:injectable/injectable.dart' hide Order;
import 'package:sync/sync.dart';

import '../../../../objectbox.g.dart' hide SyncState;
import 'collection_entity.dart';

/// ObjectBox-backed CRUD + sync helpers. All operations are synchronous on
/// the ObjectBox side; wrapped in `Future` to keep the repository contract
/// async-friendly.
///
/// Identity at this layer is the string [CollectionEntity.uuid]. The integer
/// `id` is an internal ObjectBox PK that callers never see. Implements
/// [SyncLocalStore] so the generic sync engine can drive it.
abstract interface class CollectionsLocalDataSource
    implements SyncLocalStore<CollectionEntity> {
  /// All non-tombstoned collections, newest-first.
  Future<List<CollectionEntity>> listVisible();

  /// Includes tombstoned (pendingDelete) rows.
  Future<List<CollectionEntity>> listAll();

  /// Inserts a new row in [SyncState.pendingCreate].
  Future<CollectionEntity> putNew(CollectionEntity entity);
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
    // Only the active push-queue states — conflicted/failed rows await user
    // action and must not be re-pushed.
    final query = _box
        .query(
          CollectionEntity_.syncStateCode.oneOf([
            SyncState.pendingCreate.code,
            SyncState.pendingUpdate.code,
            SyncState.pendingDelete.code,
          ]),
        )
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
  Future<void> hardDelete(CollectionEntity entity) async {
    _box.remove(entity.id);
  }
}
