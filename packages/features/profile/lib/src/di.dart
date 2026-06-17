import 'package:injectable/injectable.dart';

/// Code-generation anchor for the feature_profile micro-package.
///
/// Running `build_runner` here generates `di.module.dart` containing
/// `FeatureProfilePackageModule`, which the host app wires via
/// `externalPackageModulesBefore`.
@InjectableInit.microPackage()
void initProfileFeature() {}
