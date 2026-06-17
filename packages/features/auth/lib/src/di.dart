import 'package:injectable/injectable.dart';

/// Code-generation anchor for the feature_auth micro-package.
///
/// Running `build_runner` here generates `di.module.dart` containing
/// `FeatureAuthPackageModule`, which the host app wires via
/// `externalPackageModulesBefore`. It registers the authenticated `Dio` that
/// the other feature packages resolve from the shared `GetIt`, so it must be
/// listed before them.
@InjectableInit.microPackage()
void initAuthFeature() {}
