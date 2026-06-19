import 'dart:developer' as developer;

import 'package:app_platform/app_platform.dart';
import 'package:config/config.dart';
import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

import 'app/app.dart';
import 'app/bootstrap_error_app.dart';
import 'app/di/injection.dart';
import 'app/firebase.dart';
import 'core/platform/firebase/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await configureDependencies();

    // Drop any Keychain data that survived a previous install (iOS keeps it
    // across uninstalls) before session restore reads secure storage.
    await getIt<KeychainResetOnReinstall>().run();

    // Local notifications are not a Firebase service — always initialise.
    await getIt<NotificationsService>().init();

    if (kFirebaseEnabled) {
      await getIt<FirebaseService>().init();
      await getIt<RemoteConfigService>().init();
      await getIt<FirebaseMessagingService>().init();
    }

    // Crash reporting goes through the CrashReporter port. The no-op binding
    // does nothing; the Firebase adapter requires Firebase initialised above,
    // so this must follow the platform block.
    await getIt<CrashReporter>().install();

    runApp(const App());
  } on Object catch (error, stackTrace) {
    await _reportBootstrapFailure(error, stackTrace);
    runApp(BootstrapErrorApp(error: error));
  }
}

/// Records a fatal bootstrap failure. Always logs via `dart:developer`; also
/// reports through the [CrashReporter] port when one is registered — the no-op
/// reporter (Firebase disabled) simply does nothing.
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

  if (!getIt.isRegistered<CrashReporter>()) return;
  try {
    await getIt<CrashReporter>().recordError(
      error,
      stackTrace,
      reason: 'App bootstrap failed',
      fatal: true,
    );
  } on Object catch (_) {
    // Best-effort; the developer.log above already fired.
  }
}
