import 'package:injectable/injectable.dart' hide Order;

import '../../../../objectbox.g.dart';
import 'activity_entity.dart';
import 'notification_entity.dart';

/// ObjectBox-backed cache for the notifications feed. All operations are
/// synchronous on the ObjectBox side; wrapped in `Future` to keep the
/// repository contract async-friendly.
///
/// Identity is the string `uuid` (the server id); the integer ObjectBox PK is
/// internal and only used for [removeNotification] / [removeActivity].
abstract interface class NotificationsLocalDataSource {
  /// Cached notifications, newest-first.
  Future<List<NotificationEntity>> notifications();

  /// Cached activity entries, newest-first.
  Future<List<ActivityEntity>> activities();

  /// Notifications whose local read-mark hasn't been pushed yet.
  Future<List<NotificationEntity>> pendingReads();

  Future<NotificationEntity?> getNotification(String uuid);

  Future<void> putNotification(NotificationEntity entity);

  Future<void> putActivity(ActivityEntity entity);

  /// Flags [uuid] as read locally and queues its read-mark for push. No-op if
  /// the row is unknown or already read.
  Future<void> markReadPending(String uuid);

  /// Hard-removes a notification by internal PK. Used by the pull reconciler.
  Future<void> removeNotification(int pk);

  /// Hard-removes an activity entry by internal PK. Used by the pull
  /// reconciler.
  Future<void> removeActivity(int pk);
}

@LazySingleton(as: NotificationsLocalDataSource)
class ObjectBoxNotificationsDataSource implements NotificationsLocalDataSource {
  ObjectBoxNotificationsDataSource(Store store)
    : _notifications = store.box<NotificationEntity>(),
      _activities = store.box<ActivityEntity>();

  final Box<NotificationEntity> _notifications;
  final Box<ActivityEntity> _activities;

  @override
  Future<List<NotificationEntity>> notifications() async {
    final query = _notifications
        .query()
        .order(NotificationEntity_.createdAt, flags: Order.descending)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<List<ActivityEntity>> activities() async {
    final query = _activities
        .query()
        .order(ActivityEntity_.createdAt, flags: Order.descending)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<List<NotificationEntity>> pendingReads() async {
    final query = _notifications
        .query(NotificationEntity_.pendingRead.equals(true))
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<NotificationEntity?> getNotification(String uuid) async {
    final query = _notifications
        .query(NotificationEntity_.uuid.equals(uuid))
        .build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

  @override
  Future<void> putNotification(NotificationEntity entity) async {
    _notifications.put(entity);
  }

  @override
  Future<void> putActivity(ActivityEntity entity) async {
    _activities.put(entity);
  }

  @override
  Future<void> markReadPending(String uuid) async {
    final row = await getNotification(uuid);
    if (row == null || row.isRead) return;
    row
      ..isRead = true
      ..pendingRead = true;
    _notifications.put(row);
  }

  @override
  Future<void> removeNotification(int pk) async {
    _notifications.remove(pk);
  }

  @override
  Future<void> removeActivity(int pk) async {
    _activities.remove(pk);
  }
}
