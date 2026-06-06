import 'package:injectable/injectable.dart';
import 'package:sync/sync.dart';

import '../../domain/services/collections_sync_controller.dart';
import '../datasources/collections_remote_data_source.dart';
import '../local/collection_entity.dart';
import '../local/collections_local_data_source.dart';
import 'collections_sync_adapter.dart';

/// Wires the collections feature onto the generic sync engine: a
/// [SyncScheduler] (connectivity, single-flight, backoff, status) driving an
/// [OfflineCrudSync] body built from the local store, the REST adapter, and the
/// shared delta cursor. All sync mechanics live in `package:sync`; this is just
/// composition.
@LazySingleton(as: CollectionsSyncController)
class CollectionsSyncService implements CollectionsSyncController {
  CollectionsSyncService(
    CollectionsLocalDataSource local,
    CollectionsRemoteDataSource remote,
    ConnectivitySource connectivity,
    SyncCursorStore cursors,
  ) : _scheduler = SyncScheduler(
        OfflineCrudSync<CollectionEntity>(
          local,
          CollectionsSyncAdapter(remote),
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
