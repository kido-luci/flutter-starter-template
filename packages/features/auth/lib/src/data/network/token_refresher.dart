import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import '../datasources/auth_local_data_source.dart';
import '../models/refresh_token_response.dart';

/// Outcome of a token-refresh attempt.
///
/// Lets callers tell a *transient* failure (offline / timeout / server hiccup —
/// keep the session and retry later) apart from a genuine auth rejection (the
/// refresh token is dead and the session must be cleared). Collapsing the two
/// is what previously signed users out on any cold-start network blip.
enum RefreshOutcome {
  /// New tokens were obtained and persisted.
  refreshed,

  /// The request never reached a verdict — offline, a timeout, or a server
  /// error. The stored session is left intact so it can be retried.
  networkError,

  /// The server rejected the refresh token (or returned an unusable body).
  /// The stored session has been cleared.
  invalidSession,
}

/// Single-flight refresh: concurrent callers share one in-flight POST so the
/// server doesn't see a stampede of refresh requests during a 401 storm.
@lazySingleton
class TokenRefresher {
  TokenRefresher(this._local, @Named('plain') this._dio);

  final AuthLocalDataSource _local;
  final Dio _dio;
  Future<RefreshOutcome>? _inflight;

  /// Attempt to exchange the persisted refresh token for a new access/refresh
  /// pair. Clears storage only on [RefreshOutcome.invalidSession]; on
  /// [RefreshOutcome.networkError] the session is deliberately preserved.
  Future<RefreshOutcome> refresh() {
    return _inflight ??= _run()..whenComplete(() => _inflight = null);
  }

  Future<RefreshOutcome> _run() async {
    final token = _local.refreshToken;
    if (token == null) return RefreshOutcome.invalidSession;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        data: {'refresh_token': token},
      );
      final body = response.data;
      if (body == null) {
        await _local.clearSession();
        return RefreshOutcome.invalidSession;
      }
      final parsed = RefreshTokenResponse.fromJson(body);
      await _local.updateTokens(
        accessToken: parsed.accessToken,
        refreshToken: parsed.refreshToken,
      );
      return RefreshOutcome.refreshed;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // Only an explicit token rejection means the session is truly dead.
      if (status == 401 || status == 403) {
        await _local.clearSession();
        return RefreshOutcome.invalidSession;
      }
      // Offline, timeout, 5xx, or any other ambiguous failure: the refresh
      // token may still be valid, so keep the session and let the next trigger
      // (or the next 401) retry instead of forcing a re-login.
      return RefreshOutcome.networkError;
    }
  }
}
