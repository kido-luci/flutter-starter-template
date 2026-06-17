import 'package:injectable/injectable.dart';

/// Code-generation anchor for the feature_home micro-package.
///
/// Running `build_runner` here generates `di.module.dart` containing
/// `FeatureHomePackageModule`, which the host app wires via
/// `externalPackageModulesBefore`.
@InjectableInit.microPackage()
void initHomeFeature() {}
