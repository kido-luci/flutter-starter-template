import 'package:architecture/architecture.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import 'analytics_service.dart';

@lazySingleton
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._analytics);

  final AnalyticsService _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _track(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _track(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _track(previousRoute);
  }

  void _track(Route<dynamic>? route) {
    if (route is! PageRoute) return;
    final screenName = route.settings.name;
    if (screenName == null || screenName.isEmpty) return;
    _analytics.logScreenView(screenName: screenName).fire();
  }
}
