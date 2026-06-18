import 'package:go_router/go_router.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

/// Canonical navigation paths owned by the auth feature.
///
/// The feature navigates by pushing these via `go_router`'s `context.go`, so it
/// doesn't depend on the app shell.
abstract final class AuthRoutes {
  /// The login screen.
  static const login = '/login';

  /// The registration screen.
  static const register = '/register';

  /// The change-password screen (nested under the profile tab, mounted by the
  /// app shell because it lives inside the profile branch).
  static const changePassword = '/profile/change-password';
}

/// The auth feature's unauthenticated routes, mounted by the host app.
///
/// `changePassword` is not listed here: it is nested under the app shell's
/// profile tab, so the shell mounts it directly.
List<RouteBase> get authRoutes => [
  GoRoute(
    path: AuthRoutes.login,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: AuthRoutes.register,
    builder: (context, state) => const RegisterScreen(),
  ),
];
