import 'dart:async';
import 'dart:developer' show log;

import 'package:injectable/injectable.dart';
import 'package:network/network.dart';
import 'package:sync/sync.dart';

import '../../domain/services/notifications_sync_controller.dart';
import '../datasources/notifications_remote_data_source.dart';
import '../local/activity_entity.dart';
import '../local/notification_entity.dart';
import '../local/notifications_local_data_source.dart';
import '../models/notification_dto.dart';
import '../models/user_activity_dto.dart';

/// Reconciles the local notification/activity cache with the remote API.
///
/// Notifications are read-mostly, so unlike bookmarks/collections this is not a
/// full CRUD sync: there is no revision cursor, just a read-state push followed
/// by a full refresh. It therefore keeps its own body but runs it on the shared
/// [SyncScheduler], which provides connectivity-driven triggers, single-flight,
/// the start/stop generation guard, and backoff — the machinery this feature
/// used to hand-roll.
///
/// Strategy:
/// 1. **Push**: flush every pending read-mark to the server, clearing the flag
///    on success. A failure leaves it queued for the next trigger.
/// 2. **Pull**: GET both lists and reconcile by uuid — insert server-only rows,
///    refresh existing ones (preserving any unpushed read-mark), and drop local
///    rows the server no longer has.
@LazySingleton(as: NotificationsSyncController)
class NotificationsSyncService implements NotificationsSyncController {
  NotificationsSyncService(
    this._local,
    this._remote,
    ConnectivitySource connectivity,
  ) {
    _scheduler = SyncScheduler(_run, connectivity);
  }

  final NotificationsLocalDataSource _local;
  final NotificationsRemoteDataSource _remote;
  late final SyncScheduler _scheduler;

  final _synced = StreamController<void>.broadcast();

  @override
  Stream<void> get onSynced => _synced.stream;

  @override
  Future<void> start() => _scheduler.start();

  @override
  Future<void> stop() => _scheduler.stop();

  @override
  Future<void> sync() => _scheduler.sync();

  Future<SyncOutcome> _run() async {
    try {
      await _pushReads();
      await _pull();
      if (!_synced.isClosed) _synced.add(null);
      return SyncOutcome.ok;
    } on DioException {
      // Offline/auth error — expected; pending reads stay queued. Reported as
      // an error so the scheduler retries it with backoff.
      return SyncOutcome.error;
    } on Object catch (error, stackTrace) {
      // Unexpected (e.g. a reconciliation/ObjectBox bug). Surface it so it
      // isn't lost, but keep sync fire-and-forget for callers.
      log(
        'Notifications sync failed',
        name: 'NotificationsSyncService',
        error: error,
        stackTrace: stackTrace,
      );
      return SyncOutcome.error;
    }
  }

  Future<void> _pushReads() async {
    final pending = await _local.pendingReads();
    for (final row in pending) {
      try {
        await _remote.markRead(row.uuid);
        row.pendingRead = false;
        await _local.putNotification(row);
      } on DioException catch (e) {
        // 404: the server no longer has this notification, so stop retrying.
        // Other errors leave the row queued.
        if (e.response?.statusCode == 404) {
          row.pendingRead = false;
          await _local.putNotification(row);
        }
      }
    }
  }

  Future<void> _pull() async {
    final (notificationDtos, activityDtos) = await (
      _remote.listNotifications(),
      _remote.listActivity(),
    ).wait;
    await _reconcileNotifications(notificationDtos);
    await _reconcileActivities(activityDtos);
  }

  Future<void> _reconcileNotifications(List<NotificationDto> dtos) async {
    final serverIds = {for (final dto in dtos) dto.id};
    final localByUuid = {
      for (final row in await _local.notifications()) row.uuid: row,
    };

    for (final dto in dtos) {
      final local = localByUuid[dto.id];
      if (local == null) {
        await _local.putNotification(
          NotificationEntity(
            uuid: dto.id,
            title: dto.title,
            body: dto.body,
            type: dto.type,
            isRead: dto.isRead,
            createdAt: dto.createdAt,
          ),
        );
        continue;
      }
      local
        ..title = dto.title
        ..body = dto.body
        ..type = dto.type
        ..createdAt = dto.createdAt;
      // Read state is monotonic: preserve an unpushed local read, and never
      // let a stale server `false` flip a read we've already observed back to
      // unread (a markRead may have cleared pendingRead earlier this cycle).
      if (!local.pendingRead) local.isRead = local.isRead || dto.isRead;
      await _local.putNotification(local);
    }

    for (final row in localByUuid.values) {
      if (serverIds.contains(row.uuid)) continue;
      // Keep a row whose read-mark is still queued; it's cleared once pushed.
      if (row.pendingRead) continue;
      await _local.removeNotification(row.id);
    }
  }

  Future<void> _reconcileActivities(List<UserActivityDto> dtos) async {
    final serverIds = {for (final dto in dtos) dto.id};
    final localByUuid = {
      for (final row in await _local.activities()) row.uuid: row,
    };

    for (final dto in dtos) {
      final local = localByUuid[dto.id];
      if (local == null) {
        await _local.putActivity(
          ActivityEntity(
            uuid: dto.id,
            description: dto.description,
            type: dto.type,
            createdAt: dto.createdAt,
          ),
        );
        continue;
      }
      local
        ..description = dto.description
        ..type = dto.type
        ..createdAt = dto.createdAt;
      await _local.putActivity(local);
    }

    for (final row in localByUuid.values) {
      if (serverIds.contains(row.uuid)) continue;
      await _local.removeActivity(row.id);
    }
  }
}
