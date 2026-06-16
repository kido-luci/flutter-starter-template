/// Notifications feature: data, domain, and presentation layers.
///
/// The host app wires `FeatureNotificationsPackageModule` via
/// `externalPackageModulesBefore`, mounts the exported screen in its router,
/// and drives background sync through `NotificationsSyncController`. The
/// domain layer (entities, use cases, contracts) is exported as the feature's
/// public API; data and presentation internals stay private.
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
export 'src/presentation/bloc/notifications_bloc.dart';
export 'src/presentation/bloc/notifications_state.dart';
export 'src/presentation/notifications_routes.dart';
export 'src/presentation/screens/notifications_screen.dart';
