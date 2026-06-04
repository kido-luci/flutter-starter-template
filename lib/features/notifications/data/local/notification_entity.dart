import 'package:objectbox/objectbox.dart';

import '../../domain/entities/app_notification.dart';

/// ObjectBox row caching a single notification. Mutable by necessity —
/// ObjectBox writes back into instances during property loading.
///
/// Identity at this layer is the string [uuid] (the server id). The integer
/// [id] is an internal ObjectBox PK that callers never see.
@Entity()
class NotificationEntity {
  NotificationEntity({
    this.id = 0,
    required this.uuid,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.pendingRead = false,
  });

  /// ObjectBox primary key. Internal — never exposed to the domain layer.
  @Id()
  int id;

  /// Server id, stable across syncs.
  @Unique()
  String uuid;

  String title;
  String body;

  /// Raw server category (e.g. `social`); mapped to [NotificationType] in
  /// [toDomain]. Stored raw so an unknown future type round-trips intact.
  String type;

  bool isRead;

  /// Stored and read back as UTC.
  @Property(type: PropertyType.dateNanoUtc)
  DateTime createdAt;

  /// `true` when the read-mark was set locally but hasn't been pushed to the
  /// server yet. Keeps the pull reconciler from overwriting an unsynced read.
  bool pendingRead;

  AppNotification toDomain() => AppNotification(
    id: uuid,
    title: title,
    body: body,
    type: notificationTypeFromRaw(type),
    isRead: isRead,
    createdAt: createdAt,
  );
}

/// Maps a raw server notification type to its [NotificationType], defaulting
/// to [NotificationType.system] for unrecognized values.
NotificationType notificationTypeFromRaw(String raw) => switch (raw) {
  'social' => NotificationType.social,
  'reminder' => NotificationType.reminder,
  'promotion' => NotificationType.promotion,
  _ => NotificationType.system,
};
