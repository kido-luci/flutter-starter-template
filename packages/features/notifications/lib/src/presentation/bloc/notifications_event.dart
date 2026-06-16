part of 'notifications_bloc.dart';

sealed class NotificationsEvent {
  const NotificationsEvent();
}

/// Loads (or refreshes) the notifications and activity feed.
final class NotificationsLoadRequested extends NotificationsEvent {
  const NotificationsLoadRequested();
}

/// Marks a single notification as read.
final class NotificationMarkReadRequested extends NotificationsEvent {
  const NotificationMarkReadRequested(this.id);

  final String id;
}

/// Re-reads the local cache after a background sync, without showing a loading
/// indicator or triggering another sync.
final class _NotificationsReloadSilently extends NotificationsEvent {
  const _NotificationsReloadSilently();
}
