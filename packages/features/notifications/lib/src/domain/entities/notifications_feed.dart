import 'app_notification.dart';
import 'user_activity.dart';

/// The combined payload shown on the notifications page: the user's own recent
/// [activities] alongside [notifications] addressed to them.
class NotificationsFeed {
  const NotificationsFeed({
    required this.notifications,
    required this.activities,
  });

  final List<AppNotification> notifications;
  final List<UserActivity> activities;

  static const empty = NotificationsFeed(notifications: [], activities: []);
}
