import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

/// Provides the `connectivity_plus` [Connectivity] client that
/// `ConnectivityPlusSource` adapts. Owned here so the plugin stays an
/// implementation detail of this adapter package.
@module
abstract class ConnectivityPlusModule {
  @lazySingleton
  Connectivity provideConnectivity() => Connectivity();
}
