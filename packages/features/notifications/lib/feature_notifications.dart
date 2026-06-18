/// Notifications feature: data, domain, and presentation layers.
///
/// The host app wires `FeatureNotificationsPackageModule` via
/// `externalPackageModulesBefore`, mounts the exported screen in its router,
/// and drives background sync through `NotificationsSyncController`. The domain
/// entities surfaced by `NotificationsState` are exported; repositories and use
/// cases are internal, resolved through dependency injection. Data and the
/// remaining presentation internals stay private.
library;

export 'src/di.module.dart' show FeatureNotificationsPackageModule;
export 'src/domain/entities/app_notification.dart';
export 'src/domain/entities/notifications_feed.dart';
export 'src/domain/entities/user_activity.dart';
export 'src/domain/services/notifications_sync_controller.dart';
export 'src/presentation/bloc/notifications_bloc.dart';
export 'src/presentation/bloc/notifications_state.dart';
export 'src/presentation/notifications_routes.dart';
export 'src/presentation/screens/notifications_screen.dart';
