import 'package:database/database.dart';
import 'package:feature_notifications/feature_notifications.dart';

/// Maps the persistence [NotificationEntity] to the domain [AppNotification].
///
/// Lives in the feature data layer (not on the entity) so the dependency
/// direction stays `feature → database` and the entity stays domain-free.
extension NotificationEntityMapper on NotificationEntity {
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
