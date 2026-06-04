import 'dart:async';

import 'package:architecture/architecture.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import '../../domain/services/notifications_sync_controller.dart';
import '../datasources/notifications_remote_data_source.dart';
import '../local/activity_entity.dart';
import '../local/notification_entity.dart';
import '../local/notifications_local_data_source.dart';
import '../models/notification_dto.dart';
import '../models/user_activity_dto.dart';

/// Reconciles the local notification/activity cache with the remote API.
///
/// Triggers:
/// - [sync] is called explicitly on app start (post-auth) and after every
///   local read-mark.
/// - Connectivity transitions from offline → online.
///
/// Strategy (notifications are read-mostly, so there is no create/update/delete
/// queue):
/// 1. **Push**: flush every [NotificationEntity.pendingRead] row to the server,
///    clearing the flag on success. A failure leaves it queued for the next
///    trigger.
/// 2. **Pull**: GET both lists and reconcile by uuid — insert server-only rows,
///    refresh existing ones (preserving any unpushed read-mark), and drop local
///    rows the server no longer has.
///
/// Concurrent calls collapse into one in-flight sync (single-flight).
@LazySingleton(as: NotificationsSyncController)
class NotificationsSyncService implements NotificationsSyncController {
  NotificationsSyncService(this._local, this._remote, this._connectivity);

  final NotificationsLocalDataSource _local;
  final NotificationsRemoteDataSource _remote;
  final Connectivity _connectivity;

  final _synced = StreamController<void>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Future<void>? _inflight;
  bool _wasOnline = true;

  @override
  Stream<void> get onSynced => _synced.stream;

  @override
  Future<void> start() async {
    if (_connectivitySub != null) return;
    _connectivitySub = _connectivity.onConnectivityChanged.listen(
      _onConnectivity,
    );
    final initial = await _connectivity.checkConnectivity();
    _wasOnline = _hasNetwork(initial);
    sync().uw();
  }

  @override
  Future<void> stop() async {
    await _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  void _onConnectivity(List<ConnectivityResult> result) {
    final online = _hasNetwork(result);
    if (online && !_wasOnline) sync().uw();
    _wasOnline = online;
  }

  bool _hasNetwork(List<ConnectivityResult> result) =>
      result.any((r) => r != ConnectivityResult.none);

  @override
  Future<void> sync() {
    return _inflight ??= _run()..whenComplete(() => _inflight = null);
  }

  Future<void> _run() async {
    try {
      await _pushReads();
      await _pull();
      _synced.add(null);
    } on DioException {
      // Offline/auth error — pending reads stay queued for the next trigger.
    } on Object {
      // Swallow; sync is fire-and-forget from callers.
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
      // Preserve an unpushed local read; otherwise trust the server.
      if (!local.pendingRead) local.isRead = dto.isRead;
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
