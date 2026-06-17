/// Authentication feature: data, domain, and presentation layers.
///
/// The host app wires `FeatureAuthPackageModule` via
/// `externalPackageModulesBefore`, adopts `AuthSession` as its `Session`
/// implementation, drives routing off `AuthBloc`/`AuthState`, and mounts the
/// exported screens in its router. The shared contracts this feature speaks
/// (`AuthUser`, `Session`) live in `shared_contracts`/`shared_ui`; auth's own
/// domain (repositories, use cases) stays private.
library;

export 'src/di.module.dart' show FeatureAuthPackageModule;
export 'src/presentation/auth_routes.dart';
export 'src/presentation/auth_session.dart';
export 'src/presentation/bloc/auth_bloc.dart';
export 'src/presentation/bloc/auth_state.dart';
export 'src/presentation/bloc/delete_account_cubit.dart';
export 'src/presentation/bloc/delete_account_state.dart';
export 'src/presentation/screens/change_password_screen.dart';
export 'src/presentation/screens/login_screen.dart';
export 'src/presentation/screens/register_screen.dart';
