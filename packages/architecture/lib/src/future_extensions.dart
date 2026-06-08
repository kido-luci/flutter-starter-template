import 'dart:async';

extension UnawaitedFutureExtension<T> on Future<T> {
  /// Marks this future as intentionally not awaited (fire-and-forget).
  ///
  /// Sugar for [unawaited]; use it on a future whose result is deliberately
  /// ignored, e.g. `analytics.logEvent().fire();`.
  void fire() => unawaited(this);
}
