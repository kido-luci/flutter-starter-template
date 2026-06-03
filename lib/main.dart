import 'dart:developer' as developer;

import 'package:app_platform/app_platform.dart';
import 'package:config/config.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

import 'app/app.dart';
import 'app/bootstrap_error_app.dart';
import 'app/di/injection.dart';
import 'core/platform/firebase/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await configureDependencies();

    // Drop any Keychain data that survived a previous install (iOS keeps it
    // across uninstalls) before session restore reads secure storage.
    await getIt<KeychainResetOnReinstall>().run();

    await getIt<FirebaseService>().init();

    await getIt<RemoteConfigService>().init();

    await getIt<NotificationsService>().init();
    await getIt<FirebaseMessagingService>().init();
    runApp(const App());
  } on Object catch (error, stackTrace) {
    await _reportBootstrapFailure(error, stackTrace);
    runApp(BootstrapErrorApp(error: error));
  }
}

/// Records a fatal bootstrap failure. Always logs via `dart:developer`; also
/// reports to Crashlytics, but only if Firebase managed to initialize —
/// otherwise the report itself would throw and mask the original error.
Future<void> _reportBootstrapFailure(
  Object error,
  StackTrace stackTrace,
) async {
  developer.log(
    'App bootstrap failed',
    name: 'bootstrap',
    level: 1000,
    error: error,
    stackTrace: stackTrace,
  );

  if (Firebase.apps.isEmpty) return;
  try {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: 'App bootstrap failed',
      fatal: true,
    );
  } on Object catch (_) {
    // Crashlytics is best-effort here; the developer.log above still fired.
  }
}
