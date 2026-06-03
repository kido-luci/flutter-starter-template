import 'package:analytics/analytics.dart';
import 'package:app_platform/app_platform.dart';
import 'package:config/config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';
import 'package:storage/storage.dart';
import 'package:theme/theme.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

/// Async because core database modules use `@preResolve` to open native
/// resources before any consumer is constructed. Must be awaited from `main`.
///
/// `analytics` is registered before `app_platform` and `theme`
/// because both depend on `AnalyticsService` (the former via
/// `FirebaseMessagingService`, the latter via `ThemeBloc`). `storage` is
/// listed before `theme` because `ThemeBloc` reads the `SharedPreferences`
/// that `storage` provides.
@InjectableInit(
  externalPackageModulesBefore: [
    ExternalModule(CoreAnalyticsPackageModule),
    ExternalModule(CoreConfigPackageModule),
    ExternalModule(CoreNetworkPackageModule),
    ExternalModule(CorePlatformPackageModule),
    ExternalModule(CoreStoragePackageModule),
    ExternalModule(CoreThemePackageModule),
  ],
)
Future<void> configureDependencies() async {
  await getIt.init();
}
