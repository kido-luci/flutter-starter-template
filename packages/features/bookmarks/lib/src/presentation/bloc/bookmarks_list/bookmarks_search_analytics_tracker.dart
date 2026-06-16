import 'dart:async';
import 'package:analytics/analytics.dart';
import 'package:architecture/architecture.dart';

class BookmarksSearchAnalyticsTracker {
  BookmarksSearchAnalyticsTracker(this._analytics);

  static const debounce = Duration(milliseconds: 350);

  final AnalyticsService _analytics;
  Timer? _timer;

  void schedule({required String query, required int resultCount}) {
    final normalized = query.trim();
    _timer?.cancel();
    if (normalized.isEmpty) return;
    _timer = Timer(debounce, () {
      _analytics
          .trackBookmarkSearch(
            queryLength: normalized.length,
            resultCount: resultCount,
          )
          .fire();
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}
