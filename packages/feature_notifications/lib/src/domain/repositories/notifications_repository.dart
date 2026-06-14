import 'package:architecture/architecture.dart';
import '../entities/notifications_feed.dart';

abstract interface class NotificationsRepository {
  /// Loads the cached feed and triggers a background refresh from the server.
  Future<Result<NotificationsFeed>> getFeed();

  /// Loads the cached feed only, without triggering a sync. Used to surface
  /// server-side changes after a background sync completes.
  Future<Result<NotificationsFeed>> getFeedLocal();

  /// Marks the notification with [id] as read locally and queues the change
  /// for the next sync.
  Future<Result<void>> markRead(String id);
}
