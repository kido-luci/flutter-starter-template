import 'package:go_router/go_router.dart';

/// Lifecycle interface for an optional feature's background sync.
abstract interface class FeatureSyncController {
  Future<void> start();
  Future<void> stop();
}

/// Bundles the wiring points the app shell needs from each optional feature.
abstract class FeatureModule {
  const FeatureModule();

  /// The feature's sync controller, or null if it has no background sync.
  FeatureSyncController? get syncController => null;

  /// The feature's non-shell routes, mounted by the app router.
  ///
  /// Empty for features that only contribute a shell tab (e.g. notifications).
  Iterable<RouteBase> get routes => const [];
}
