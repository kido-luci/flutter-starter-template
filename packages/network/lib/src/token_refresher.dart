import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:storage/storage.dart';

/// Outcome of a token-refresh attempt.
///
/// Distinguishes a *transient* failure (offline / timeout / server hiccup —
/// keep the session, retry later) from a genuine auth rejection (the refresh
/// token is dead and the tokens must be cleared).
enum RefreshOutcome { refreshed, networkError, invalidSession }

/// Single-flight refresh: concurrent callers share one in-flight POST so the
/// server doesn't see a stampede during a 401 storm. Uses the unauthenticated
/// (`plain`) Dio so the refresh call itself can't recurse through the auth
/// interceptor.
@lazySingleton
class TokenRefresher {
  TokenRefresher(this._tokens, @Named('plain') this._dio);

  final AuthTokenStore _tokens;
  final Dio _dio;
  Future<RefreshOutcome>? _inflight;

  Future<RefreshOutcome> refresh() =>
      _inflight ??= _run()..whenComplete(() => _inflight = null);

  Future<RefreshOutcome> _run() async {
    final token = _tokens.refreshToken;
    if (token == null) return RefreshOutcome.invalidSession;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        data: {'refresh_token': token},
      );
      final body = response.data;
      final String access;
      final String refresh;
      try {
        if (body == null) throw const FormatException('empty refresh body');
        final a = body['access_token'];
        final r = body['refresh_token'];
        if (a is! String || r is! String) {
          throw const FormatException('missing tokens');
        }
        access = a;
        refresh = r;
      } on Object {
        await _tokens.clearTokens();
        return RefreshOutcome.invalidSession;
      }
      await _tokens.updateTokens(accessToken: access, refreshToken: refresh);
      return RefreshOutcome.refreshed;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        await _tokens.clearTokens();
        return RefreshOutcome.invalidSession;
      }
      return RefreshOutcome.networkError;
    } on Object {
      // Any non-Dio failure — e.g. a secure-storage write throwing while
      // persisting/clearing tokens — must not escape and break the caller's
      // error handling (AuthInterceptor.onError / restoreSession). Treat it as
      // transient so the session is kept and the next trigger retries.
      return RefreshOutcome.networkError;
    }
  }
}
