/// Notifications feature domain layer: entities, repository contract,
/// use cases, and sync controller interface.
library;

export 'src/di.module.dart' show FeatureNotificationsPackageModule;
export 'src/domain/entities/app_notification.dart';
export 'src/domain/entities/notifications_feed.dart';
export 'src/domain/entities/user_activity.dart';
export 'src/domain/repositories/notifications_repository.dart';
export 'src/domain/services/notifications_sync_controller.dart';
export 'src/domain/usecases/get_notifications_feed.dart';
export 'src/domain/usecases/get_notifications_feed_local.dart';
export 'src/domain/usecases/mark_notification_read.dart';
