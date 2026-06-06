import 'package:injectable/injectable.dart' hide Order;
import 'package:sync/sync.dart';

import '../../../../objectbox.g.dart' hide SyncState;
import 'bookmark_entity.dart';

/// ObjectBox-backed CRUD + sync helpers. All operations are synchronous on
/// the ObjectBox side; wrapped in `Future` to keep the repository contract
/// async-friendly.
///
/// Identity at this layer is the string [BookmarkEntity.uuid]. The integer
/// `id` is an internal ObjectBox PK that callers never see. Implements
/// [SyncLocalStore] so the generic sync engine can drive it.
abstract interface class BookmarksLocalDataSource
    implements SyncLocalStore<BookmarkEntity> {
  /// All non-tombstoned bookmarks, newest-first.
  Future<List<BookmarkEntity>> listVisible();

  /// Includes tombstoned (pendingDelete) rows.
  Future<List<BookmarkEntity>> listAll();

  /// Inserts a new row in [SyncState.pendingCreate].
  Future<BookmarkEntity> putNew(BookmarkEntity entity);
}

@LazySingleton(as: BookmarksLocalDataSource)
class ObjectBoxBookmarksDataSource implements BookmarksLocalDataSource {
  ObjectBoxBookmarksDataSource(Store store)
    : _box = store.box<BookmarkEntity>();

  final Box<BookmarkEntity> _box;

  @override
  Future<List<BookmarkEntity>> listVisible() async {
    final query = _box
        .query(
          BookmarkEntity_.syncStateCode.notEquals(SyncState.pendingDelete.code),
        )
        .order(BookmarkEntity_.createdAt, flags: Order.descending)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<List<BookmarkEntity>> listAll() async {
    final query = _box
        .query()
        .order(BookmarkEntity_.createdAt, flags: Order.descending)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<BookmarkEntity?> getByUuid(String uuid) async {
    final query = _box.query(BookmarkEntity_.uuid.equals(uuid)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

  @override
  Future<List<BookmarkEntity>> listPending() async {
    // Only the active push-queue states — conflicted/failed rows await user
    // action and must not be re-pushed.
    final query = _box
        .query(
          BookmarkEntity_.syncStateCode.oneOf([
            SyncState.pendingCreate.code,
            SyncState.pendingUpdate.code,
            SyncState.pendingDelete.code,
          ]),
        )
        .order(BookmarkEntity_.updatedAt)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<BookmarkEntity> putNew(BookmarkEntity entity) async {
    _box.put(entity);
    return entity;
  }

  @override
  Future<void> put(BookmarkEntity entity) async {
    _box.put(entity);
  }

  @override
  Future<void> hardDelete(BookmarkEntity entity) async {
    _box.remove(entity.id);
  }
}
