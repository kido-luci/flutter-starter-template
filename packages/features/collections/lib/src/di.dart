import 'package:injectable/injectable.dart';

/// Code-generation anchor for the feature_collections micro-package.
///
/// Running `build_runner` here generates `di.module.dart` containing
/// `FeatureCollectionsPackageModule`, which the host app wires via
/// `externalPackageModulesBefore`.
@InjectableInit.microPackage()
void initCollectionsFeature() {}
