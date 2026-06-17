import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Routes uncaught Flutter framework and platform errors to Firebase
/// Crashlytics.
///
/// [install] must be called after `Firebase.initializeApp()` — Crashlytics
/// needs the Firebase app initialized before it can record anything.
@singleton
class CrashReportingService {
  /// Enables collection in release builds (off in debug, to keep dev crashes
  /// out of production Crashlytics) and installs the global Flutter and
  /// platform-dispatcher error handlers.
  Future<void> install() async {
    // Keep dev/debug crashes out of production Crashlytics. Release builds
    // collect; debug builds only log locally.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );

    FlutterError.onError = (errorDetails) {
      // Still surface the red-screen / console dump in debug so developers see
      // the error; recordFlutterFatalError is a no-op when collection is off.
      FlutterError.presentError(errorDetails);
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
}
