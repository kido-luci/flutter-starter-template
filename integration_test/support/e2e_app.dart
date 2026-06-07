/// Real-backend end-to-end bootstrap.
///
/// Unlike the old `AppHarness` (mocked every boundary), this mirrors
/// `lib/main.dart`'s production bootstrap — real DI, real Firebase, and a
/// `const App()` with no constructor overrides — so the assembled app talks to
/// the real local backend (`simple_backend_server`, default
/// `http://localhost:8080`) through its real Dio client and repositories.
library;

import 'package:app_platform/app_platform.dart';
import 'package:config/config.dart';
import 'package:flutter_starter_template/app/app.dart';
import 'package:flutter_starter_template/app/di/injection.dart';
import 'package:flutter_starter_template/core/platform/firebase/firebase_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage/storage.dart';

/// Boots the real assembled [App] against the real local backend.
///
/// Usage:
/// ```dart
/// setUpAll(() async {
///   await E2eApp.bootstrap();
/// });
/// testWidgets('full journey', (tester) async {
///   await E2eApp.pumpApp(tester);
///   ...
/// });
/// ```
abstract final class E2eApp {
  static bool _bootstrapped = false;

  /// Runs the production dependency/service bootstrap exactly once for the
  /// whole suite — mirrors `main()` in `lib/main.dart`.
  static Future<void> bootstrap() async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    await configureDependencies();
    await getIt<KeychainResetOnReinstall>().run();
    await getIt<FirebaseService>().init();
    await getIt<RemoteConfigService>().init();
    await getIt<NotificationsService>().init();

    // Deliberately NOT `getIt<FirebaseMessagingService>().init()`: it calls
    // `NotificationsService.requestPermissions()`, which raises iOS's native
    // "Would Like to Send You Notifications" alert — a system-level dialog
    // outside the Flutter widget tree that `WidgetTester` cannot see or
    // dismiss (and `simctl privacy` has no "notifications" service to
    // pre-grant it). Skipping it is the only automatable option; everything
    // else in `main()`'s bootstrap still runs for real.
  }

  /// Pumps the real [App] widget with no overrides — every dependency
  /// resolves through `getIt` to its real, DI-assembled implementation.
  static Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const App());
  }

  /// Pumps a microtask + frame so async events flush without blocking.
  static Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();
  }

  /// Pumps [interval] frames until [finder] is non-empty or [maxTries] is hit.
  ///
  /// Real network calls are slower and more variable than mocks, so this
  /// defaults to a longer budget than the old harness's mock-tuned one.
  static Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    int maxTries = 100,
    Duration interval = const Duration(milliseconds: 200),
  }) async {
    for (var i = 0; i < maxTries && finder.evaluate().isEmpty; i++) {
      await tester.pump(interval);
    }
  }

  /// Pumps the app and waits through the splash screen to the login screen.
  ///
  /// `runAsync` steps outside `TestAsyncUtils.guard` so real Dart timers fire,
  /// including the splash screen's 2-second minimum-display guard — a fresh
  /// install has no session to restore, so the splash always routes to login.
  static Future<void> waitForLoginScreen(WidgetTester tester) async {
    await pumpApp(tester);
    await tester.pump();
    await settle(tester);
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(seconds: 3)),
    );
    await settle(tester);

    await pumpUntil(tester, find.text('Welcome Back'));
    expect(find.text('Welcome Back'), findsOneWidget);
  }
}
