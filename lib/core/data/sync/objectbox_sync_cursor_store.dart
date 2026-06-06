import 'package:injectable/injectable.dart';
import 'package:sync/sync.dart';

import '../../../objectbox.g.dart' hide SyncState;
import 'sync_cursor_entity.dart';

/// ObjectBox-backed [SyncCursorStore]. Kept in the same store as the synced
/// entities so a cursor advance is durable alongside the rows it accounts for.
@LazySingleton(as: SyncCursorStore)
class ObjectBoxSyncCursorStore implements SyncCursorStore {
  ObjectBoxSyncCursorStore(Store store) : _box = store.box<SyncCursorEntity>();

  final Box<SyncCursorEntity> _box;

  @override
  Future<int> read(String resource) async {
    final query = _box
        .query(SyncCursorEntity_.resource.equals(resource))
        .build();
    try {
      return query.findFirst()?.rev ?? 0;
    } finally {
      query.close();
    }
  }

  @override
  Future<void> write(String resource, int rev) async {
    final query = _box
        .query(SyncCursorEntity_.resource.equals(resource))
        .build();
    final SyncCursorEntity? existing;
    try {
      existing = query.findFirst();
    } finally {
      query.close();
    }
    _box.put(
      existing == null
          ? SyncCursorEntity(resource: resource, rev: rev)
          : (existing..rev = rev),
    );
  }
}
