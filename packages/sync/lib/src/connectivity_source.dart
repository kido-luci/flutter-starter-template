/// A minimal connectivity signal the scheduler reacts to, abstracted so the
/// engine stays pure Dart (the app supplies a `connectivity_plus`-backed
/// implementation) and is trivially fakeable in tests.
abstract interface class ConnectivitySource {
  /// Whether the device currently has a network link.
  Future<bool> isOnline();

  /// Emits the new online state on every connectivity transition (true when a
  /// link appears, false when it drops).
  Stream<bool> get onOnlineChanged;
}
