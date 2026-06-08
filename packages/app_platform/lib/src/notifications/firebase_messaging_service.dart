import 'dart:async';
import 'dart:io' show Platform;

import 'package:analytics/analytics.dart';
import 'package:architecture/architecture.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'notifications_service.dart';

typedef OnNotificationTap = void Function(Map<String, dynamic>? data);

@lazySingleton
class FirebaseMessagingService {
  FirebaseMessagingService(
    this._localNotifications,
    this._messaging,
    this._analytics,
  );

  final NotificationsService _localNotifications;
  final FirebaseMessaging _messaging;
  final AnalyticsService _analytics;

  final _tokenStream = StreamController<String?>.broadcast();

  OnNotificationTap? onNotificationTap;

  Stream<String?> get onTokenRefresh => _tokenStream.stream;

  Future<void> init() async {
    // Don't request permission on web — handled by browser APIs.
    if (kIsWeb) return;

    final notificationsAllowed = await _localNotifications.requestPermissions();
    if (!notificationsAllowed) return;

    if (Platform.isIOS || Platform.isMacOS) {
      // APNs token registration — required for iOS push delivery.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Fetching the initial token can block for several seconds on Apple
    // platforms while waiting for the APNs token. Don't hold up app startup for
    // it — the token is delivered through `_tokenStream` once it's ready.
    _saveInitialToken().fire();

    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    // Handle messages while app is in the foreground.
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Handle when user taps a notification that brings the app from background.
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpened);

    // Handle when user taps a notification that launched the app from terminated state.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data);
    }
  }

  Future<String?> getToken() => _messaging.getToken();

  Future<void> _saveInitialToken() async {
    // On Apple platforms, `getToken()` throws `apns-token-not-set` until the
    // device has received its APNs token from Apple, which happens
    // asynchronously after registration. Wait for it before requesting the FCM
    // token.
    if (Platform.isIOS || Platform.isMacOS) {
      final apnsReady = await _waitForApnsToken();
      if (!apnsReady) return;
    }

    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _tokenStream.add(token);
      }
    } on Exception catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Failed to get initial FCM token',
        fatal: false,
      );
    }
  }

  /// Polls for the APNs token until it is available or [timeout] elapses.
  ///
  /// Returns `true` once the token is set, or `false` if it never arrives
  /// (e.g. on a simulator without push capability, or when offline).
  Future<bool> _waitForApnsToken({
    Duration timeout = const Duration(seconds: 10),
    Duration interval = const Duration(milliseconds: 500),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) return true;
      await Future<void>.delayed(interval);
    }
    return false;
  }

  void _onTokenRefresh(String token) {
    _tokenStream.add(token);
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title ?? '',
      body: notification.body ?? '',
      payload: _serializeData(message.data),
    );
  }

  void _onNotificationOpened(RemoteMessage message) {
    _handleNotificationTap(message.data);
  }

  void _handleNotificationTap(Map<String, dynamic>? data) {
    _analytics
        .trackNotificationOpened(payloadKeyCount: data?.length ?? 0)
        .fire();
    final callback = onNotificationTap;
    if (callback != null) {
      callback(data);
    }
  }

  String? _serializeData(Map<String, dynamic> data) {
    if (data.isEmpty) return null;
    return data.entries.map((e) => '${e.key}=${e.value}').join('&');
  }
}
