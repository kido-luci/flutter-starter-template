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
}
