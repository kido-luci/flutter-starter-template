import 'package:database/database.dart';
import 'package:injectable/injectable.dart';
import 'package:rev_sync/rev_sync.dart';

import '../../domain/services/bookmarks_sync_controller.dart';
import '../datasources/bookmarks_remote_data_source.dart';
import '../local/bookmarks_local_data_source.dart';
import 'bookmarks_sync_adapter.dart';

/// Wires the bookmarks feature onto the generic sync engine: a
/// [SyncScheduler] (connectivity, single-flight, backoff, status) driving an
/// [OfflineCrudSync] body built from the local store, the REST adapter, and the
/// shared delta cursor. All sync mechanics live in `package:sync`; this is just
/// composition.
@LazySingleton(as: BookmarksSyncController)
class BookmarksSyncService implements BookmarksSyncController {
  BookmarksSyncService(
    BookmarksLocalDataSource local,
    BookmarksRemoteDataSource remote,
    ConnectivitySource connectivity,
    SyncCursorStore cursors,
  ) : _scheduler = SyncScheduler(
        OfflineCrudSync<BookmarkEntity>(
          local,
          BookmarksSyncAdapter(local, remote),
          cursors,
        ).run,
        connectivity,
      );

  final SyncScheduler _scheduler;

  @override
  Stream<SyncStatus> get statusStream => _scheduler.statusStream;

  @override
  SyncStatus get statusNow => _scheduler.statusNow;

  @override
  Future<void> start() => _scheduler.start();

  @override
  Future<void> stop() => _scheduler.stop();

  @override
  Future<void> sync() => _scheduler.sync();
}
