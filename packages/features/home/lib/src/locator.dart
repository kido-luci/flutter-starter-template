import 'package:get_it/get_it.dart';

/// The app-wide service locator (the shared `GetIt` singleton).
///
/// The feature's screen resolves its bloc from here, the same instance the
/// host app configures in `configureDependencies()`.
final GetIt getIt = GetIt.instance;
