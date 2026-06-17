/// Home feature: the dashboard presentation layer.
///
/// The host app wires `FeatureHomePackageModule` via
/// `externalPackageModulesBefore` and mounts the exported `HomeScreen` in its
/// router. The bloc is exported so the app's shared test mocks can reference
/// it; data-less, this feature reads bookmark and collection summaries through
/// `shared_contracts`.
library;

export 'src/di.module.dart' show FeatureHomePackageModule;
export 'src/presentation/bloc/home_bloc.dart';
export 'src/presentation/bloc/home_state.dart';
export 'src/presentation/screens/home_screen.dart';
