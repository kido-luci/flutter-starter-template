/// Centralized ObjectBox persistence: entity rows, generated bindings, and the
/// `ObjectBox` store wrapper.
///
/// `SyncState` from the generated ObjectBox bindings is hidden so it doesn't
/// clash with the offline-first `SyncState` from `package:sync`, which is the
/// one the entities and feature code use.
library;

export 'objectbox.g.dart' hide SyncState;
export 'src/entities/activity_entity.dart';
export 'src/entities/bookmark_entity.dart';
export 'src/entities/collection_entity.dart';
export 'src/entities/notification_entity.dart';
export 'src/entities/sync_cursor_entity.dart';
export 'src/object_box.dart';
