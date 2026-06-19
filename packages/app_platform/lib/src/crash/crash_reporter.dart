import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Routes uncaught errors to a crash-reporting backend and records errors on
/// demand.
///
/// [install] must run once the backend is ready (for Firebase, after
/// `Firebase.initializeApp()`).
abstract class CrashReporter {
  /// Installs the global Flutter-framework and platform-dispatcher error
  /// handlers.
  Future<void> install();

  /// Records an [error] (with its [stack]); [fatal] marks it as a crash.
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  });
}

/// A [CrashReporter] that records nothing.
///
/// The default binding when crash reporting is disabled (e.g. a project
/// scaffolded with `fst create --no-firebase`). To enable it, point the
/// `// fst:crash-impl` binding in `crash_module.dart` at a real adapter.
class NoOpCrashReporter implements CrashReporter {
  const NoOpCrashReporter();

  @override
  Future<void> install() async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  }) async {}
}

/// A [CrashReporter] backed by Firebase Crashlytics.
class FirebaseCrashReporter implements CrashReporter {
  @override
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

  @override
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  }) {
    return FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }
}
