/// A reusable offline-first sync engine: a connectivity-driven scheduler plus a
/// generic CRUD sync (push queue + delta pull) that reconciles a local store
/// with a remote adapter over a server revision cursor, with conflict detection.
library;

export 'src/connectivity_source.dart';
export 'src/offline_crud_sync.dart';
export 'src/remote_record.dart';
export 'src/sync_cursor_store.dart';
export 'src/sync_local_store.dart';
export 'src/sync_remote_adapter.dart';
export 'src/sync_scheduler.dart';
export 'src/sync_state.dart';
export 'src/sync_status.dart';
export 'src/syncable.dart';
