/// Canonical navigation paths owned by the auth feature.
///
/// The app router wires these same paths to the feature's screens; the feature
/// navigates by pushing them via `go_router`'s `context.go`, so it doesn't
/// depend on the app shell's typed-route classes.
abstract final class AuthRoutes {
  /// The login screen.
  static const login = '/login';

  /// The registration screen.
  static const register = '/register';

  /// The change-password screen (nested under the profile tab).
  static const changePassword = '/profile/change-password';
}
