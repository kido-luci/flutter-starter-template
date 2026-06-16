import 'package:injectable/injectable.dart';

/// Code-generation anchor for the feature_bookmarks micro-package.
///
/// Running `build_runner` here generates `di.module.dart` containing
/// `FeatureBookmarksPackageModule`, which the host app wires via
/// `externalPackageModulesBefore`.
@InjectableInit.microPackage()
void initBookmarksFeature() {}
