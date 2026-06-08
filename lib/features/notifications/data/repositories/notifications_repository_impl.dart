import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/notifications_feed.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/services/notifications_sync_controller.dart';
import '../local/notifications_local_data_source.dart';

/// Offline-first: reads serve from the local ObjectBox cache, the read-mark
/// commits locally first (and queues a push), then a fire-and-forget sync
/// reconciles with the API. The UI renders regardless of network state.
@LazySingleton(as: NotificationsRepository)
class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._local, this._sync);

  final NotificationsLocalDataSource _local;
  final NotificationsSyncController _sync;

  @override
  Future<Result<NotificationsFeed>> getFeed() async {
    final feed = await _readLocal();
    // Refresh in the background; the read returns the cache immediately.
    _sync.sync().fire();
    return Ok(feed);
  }

  @override
  Future<Result<NotificationsFeed>> getFeedLocal() async {
    return Ok(await _readLocal());
  }

  @override
  Future<Result<void>> markRead(String id) async {
    await _local.markReadPending(id);
    _sync.sync().fire();
    return const Ok(null);
  }

  Future<NotificationsFeed> _readLocal() async {
    final notifications = await _local.notifications();
    final activities = await _local.activities();
    return NotificationsFeed(
      notifications: notifications
          .map((e) => e.toDomain())
          .toList(growable: false),
      activities: activities.map((e) => e.toDomain()).toList(growable: false),
    );
  }
}
