import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

abstract class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object>? parameters});

  Future<void> logLogin({required String method});

  Future<void> logSignUp({required String signUpMethod});

  Future<void> logScreenView({required String screenName});

  Future<void> setCurrentUser(String? userId);

  Future<void> setUserProperty({required String name, required String? value});
}

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) {
    return _guard(
      () => _analytics.logEvent(name: name, parameters: parameters),
    );
  }

  @override
  Future<void> logLogin({required String method}) {
    return _guard(() => _analytics.logLogin(loginMethod: method));
  }

  @override
  Future<void> logSignUp({required String signUpMethod}) {
    return _guard(() => _analytics.logSignUp(signUpMethod: signUpMethod));
  }

  @override
  Future<void> logScreenView({required String screenName}) {
    return _guard(() => _analytics.logScreenView(screenName: screenName));
  }

  @override
  Future<void> setCurrentUser(String? userId) {
    return _guard(() => _analytics.setUserId(id: userId));
  }

  @override
  Future<void> setUserProperty({required String name, required String? value}) {
    return _guard(() => _analytics.setUserProperty(name: name, value: value));
  }

  Future<void> _guard(Future<void> Function() operation) async {
    try {
      await operation();
    } on Object catch (error) {
      if (kDebugMode) {
        debugPrint('Analytics error: $error');
      }
    }
  }
}

/// An [AnalyticsService] that records nothing.
///
/// The default binding when analytics tracking is disabled (e.g. a project
/// scaffolded with `fst create --no-firebase`). To enable analytics, point the
/// `// fst:analytics-impl` binding in `analytics_module.dart` at a real adapter.
class NoOpAnalyticsService implements AnalyticsService {
  const NoOpAnalyticsService();

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  @override
  Future<void> logLogin({required String method}) async {}

  @override
  Future<void> logSignUp({required String signUpMethod}) async {}

  @override
  Future<void> logScreenView({required String screenName}) async {}

  @override
  Future<void> setCurrentUser(String? userId) async {}

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {}
}
