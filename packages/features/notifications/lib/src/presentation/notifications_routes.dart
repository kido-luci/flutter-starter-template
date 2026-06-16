/// Canonical navigation paths owned by the notifications feature.
///
/// The app router wires these same paths to the feature's screens; the feature
/// navigates by pushing them via `go_router`'s `context.push`, so it doesn't
/// depend on the app shell's typed-route classes.
abstract final class NotificationsRoutes {
  /// The notifications feed (a shell tab).
  static const feed = '/notifications';
}
