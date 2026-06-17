import 'package:injectable/injectable.dart';

/// Code-generation anchor for this micro-package's injectable registrations.
///
/// Running `build_runner` generates `di.module.dart` next to this file,
/// containing `NetworkPackageModule`, which the host app wires into its own
/// `@InjectableInit` via `externalPackageModulesBefore`.
@InjectableInit.microPackage()
void initNetworkPackage() {}
