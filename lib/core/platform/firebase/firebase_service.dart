// FirebaseService is accessed via GetIt in main.dart, but the analyzer flags it as unreachable because of the entry point below.
// ignore_for_file: unreachable_from_main

import 'package:app_platform/app_platform.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:injectable/injectable.dart';

import '../../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

@singleton
class FirebaseService {
  /// Initializes the Firebase app with the platform-specific generated options
  /// and registers the background message handler.
  ///
  /// Crash reporting (the global error-capture handlers) is installed
  /// separately via `CrashReportingService.install()` once this completes.
  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
}
