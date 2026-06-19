import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

import 'analytics_service.dart';

@module
abstract class AnalyticsModule {
  /// Binds the app's [AnalyticsService].
  ///
  /// `fst create --no-firebase` rewrites the expression at the
  /// `// fst:analytics-impl` marker to `const NoOpAnalyticsService()`. To use a
  /// non-Firebase backend, replace it with your own [AnalyticsService].
  @lazySingleton
  AnalyticsService provideAnalyticsService() =>
      FirebaseAnalyticsService(FirebaseAnalytics.instance); // fst:analytics-impl
}
