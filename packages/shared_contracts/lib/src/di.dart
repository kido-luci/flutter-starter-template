import 'package:injectable/injectable.dart';

/// Code-generation anchor for the shared_contracts micro-package.
///
/// Running `build_runner` here generates `di.module.dart` containing
/// `SharedContractsPackageModule`, which the host app wires via
/// `externalPackageModulesBefore`.
@InjectableInit.microPackage()
void initSharedContracts() {}
