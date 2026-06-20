// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:injectable/injectable.dart' as _i526;
import 'package:rev_sync/rev_sync.dart' as _i846;
import 'package:sync_connectivity_plus/src/connectivity_plus_module.dart'
    as _i462;
import 'package:sync_connectivity_plus/src/connectivity_plus_source.dart'
    as _i916;

class SyncConnectivityPlusPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final connectivityPlusModule = _$ConnectivityPlusModule();
    gh.lazySingleton<_i895.Connectivity>(
      () => connectivityPlusModule.provideConnectivity(),
    );
    gh.lazySingleton<_i846.ConnectivitySource>(
      () => _i916.ConnectivityPlusSource(gh<_i895.Connectivity>()),
    );
  }
}

class _$ConnectivityPlusModule extends _i462.ConnectivityPlusModule {}
