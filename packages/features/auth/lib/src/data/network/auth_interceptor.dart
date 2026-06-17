import 'package:network/network.dart';

import '../datasources/auth_local_data_source.dart';
import 'token_refresher.dart';

/// Attaches the persisted access token to outgoing requests and, on 401,
/// transparently refreshes the token once and retries the original request.
///
/// Requests already carrying `_retried` in their extras skip the retry path
/// so a doomed refresh can never cause an infinite loop.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._local, this._refresher, this._dio);

  final AuthLocalDataSource _local;
  final TokenRefresher _refresher;
  final Dio _dio;

  static const _retriedKey = '__auth_retried__';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _local.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final request = err.requestOptions;
    final alreadyRetried = request.extra[_retriedKey] == true;

    if (response?.statusCode != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    final outcome = await _refresher.refresh();
    if (outcome != RefreshOutcome.refreshed) {
      handler.next(err);
      return;
    }

    try {
      final retried = await _dio.fetch<dynamic>(
        request
          ..extra[_retriedKey] = true
          ..headers['Authorization'] = 'Bearer ${_local.accessToken}',
      );
      handler.resolve(retried);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
