import 'package:analytics/analytics.dart';
import 'package:app_platform/app_platform.dart';
import 'package:config/config.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_bookmarks/feature_bookmarks.dart';
import 'package:feature_collections/feature_collections.dart';
import 'package:feature_home/feature_home.dart';
import 'package:feature_notifications/feature_notifications.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:storage/storage.dart';
import 'package:sync_connectivity_plus/sync_connectivity_plus.dart';
import 'package:theme/theme.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

/// Async because core database modules use `@preResolve` to open native
/// resources before any consumer is constructed. Must be awaited from `main`.
///
/// Order: `shared_contracts` registers `ActivityNotifier` (consumed by
/// `feature_notifications`'s BLoC), so it must be listed before
/// `feature_notifications`. `feature_auth` provides the authenticated `Dio`
/// that the other feature packages resolve from the shared `GetIt`, so it is
/// listed before them too.
@InjectableInit(
  externalPackageModulesBefore: [
    ExternalModule(AnalyticsPackageModule),
    ExternalModule(ConfigPackageModule),
    ExternalModule(NetworkPackageModule),
    ExternalModule(AppPlatformPackageModule),
    ExternalModule(StoragePackageModule),
    ExternalModule(ThemePackageModule),
    ExternalModule(SyncConnectivityPlusPackageModule),
    ExternalModule(SharedContractsPackageModule),
    ExternalModule(FeatureAuthPackageModule),
    ExternalModule(FeatureNotificationsPackageModule),
    ExternalModule(FeatureCollectionsPackageModule),
    ExternalModule(FeatureBookmarksPackageModule),
    ExternalModule(FeatureHomePackageModule),
    ExternalModule(FeatureProfilePackageModule),
    // fst:feature-modules — `fst add-feature` inserts new feature modules above
  ],
)
Future<void> configureDependencies() async {
  await getIt.init();
}
