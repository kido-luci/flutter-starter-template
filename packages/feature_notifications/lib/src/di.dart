import 'package:injectable/injectable.dart';

/// Code-generation anchor for the feature_notifications micro-package.
///
/// Running `build_runner` here generates `di.module.dart` containing
/// `FeatureNotificationsPackageModule`, which the host app wires via
/// `externalPackageModulesBefore`.
@InjectableInit.microPackage()
void initNotificationsFeature() {}
