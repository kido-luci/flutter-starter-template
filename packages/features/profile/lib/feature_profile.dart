/// Profile feature: the account and settings presentation layer.
///
/// The host app wires `FeatureProfilePackageModule` via
/// `externalPackageModulesBefore` and mounts the exported `ProfileScreen` in
/// its router. Profile surfaces auth's delete-account flow as a single-consumer
/// capability and owns its own reaction to it (snackbars, session clearing).
library;

export 'src/di.module.dart' show FeatureProfilePackageModule;
export 'src/presentation/bloc/profile_bloc.dart';
export 'src/presentation/bloc/profile_state.dart';
export 'src/presentation/screens/profile_screen.dart';
