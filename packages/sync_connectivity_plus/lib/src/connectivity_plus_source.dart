import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:sync/sync.dart';

/// Adapts `connectivity_plus` to the engine's [ConnectivitySource], collapsing
/// the platform's list of links into a single online/offline signal.
///
/// Note this reports link presence, not reachability — a Wi-Fi connection
/// behind a captive portal still reads as online. The scheduler tolerates that
/// (a sync that fails simply retries with backoff).
@LazySingleton(as: ConnectivitySource)
class ConnectivityPlusSource implements ConnectivitySource {
  ConnectivityPlusSource(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> isOnline() async =>
      _hasNetwork(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onOnlineChanged =>
      _connectivity.onConnectivityChanged.map(_hasNetwork);

  static bool _hasNetwork(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}
