import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

/// Registers generic third-party services shared across feature packages.
///
/// These are app-wide primitives (not owned by any one feature), so the host
/// app provides them. Feature packages resolve them from the shared `GetIt`
/// graph at runtime.
@module
abstract class AppServicesModule {
  @lazySingleton
  Uuid provideUuid() => const Uuid();
}
