import 'dart:math';

import 'package:dio/dio.dart';

/// Retries transient request failures with exponential backoff and jitter.
///
/// Only failures that are plausibly recoverable are retried: connection and
/// timeout errors, plus a small set of "try again later" status codes
/// ([_retryableStatusCodes]). Client errors like 400/401/404 are passed
/// straight through — they will not succeed on a second attempt. The 401 →
/// token-refresh path is owned by the auth interceptor, which runs first and
/// resolves the request before this interceptor ever sees it.
///
/// A per-request attempt counter is stored in [RequestOptions.extra] so that
/// re-dispatching through the same [Dio] (which re-enters this interceptor)
/// can never loop beyond [maxRetries].
class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 300),
    this.maxDelay = const Duration(seconds: 5),
  });

  final Dio _dio;

  /// Maximum number of retries after the initial attempt.
  final int maxRetries;

  /// Delay before the first retry; doubled (with jitter) on each subsequent
  /// attempt, capped at [maxDelay].
  final Duration baseDelay;

  /// Upper bound for any single backoff delay.
  final Duration maxDelay;

  static const _attemptKey = '__retry_attempt__';

  static const _retryableStatusCodes = <int>{408, 425, 429, 500, 502, 503, 504};

  /// Methods safe to replay after an *ambiguous* transport failure (a timeout
  /// or dropped connection, where the server may or may not have processed the
  /// request). POST/PATCH are excluded: replaying one can duplicate a create,
  /// upload, or other side effect.
  static const _idempotentMethods = <String>{
    'GET',
    'HEAD',
    'OPTIONS',
    'PUT',
    'DELETE',
  };

  final _random = Random();

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 0;

    if (attempt >= maxRetries || !_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    await Future<void>.delayed(_delayFor(err, attempt));
    options.extra[_attemptKey] = attempt + 1;

    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        // Ambiguous: the request may already have reached the server. Only
        // replay idempotent methods so a non-idempotent POST can't double-fire.
        return _isIdempotent(err.requestOptions.method);
      case DioExceptionType.badResponse:
        // A retryable status (429/503/…) means the server explicitly did *not*
        // process the request, so it's safe to retry regardless of method.
        final status = err.response?.statusCode;
        return status != null && _retryableStatusCodes.contains(status);
      case DioExceptionType.transformTimeout:
        // The response already arrived and the server has processed the
        // request — only the local decode of the body ran past its budget.
        // Replaying would re-run the same deterministic work on the same
        // payload, and for a non-idempotent method it would double-fire.
        return false;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }

  bool _isIdempotent(String method) =>
      _idempotentMethods.contains(method.toUpperCase());

  /// Honors a `Retry-After` header (seconds) when present; otherwise uses
  /// exponential backoff with full jitter, capped at [maxDelay].
  Duration _delayFor(DioException err, int attempt) {
    final retryAfter = _retryAfter(err);
    if (retryAfter != null) {
      return retryAfter > maxDelay ? maxDelay : retryAfter;
    }

    final exponential = baseDelay * pow(2, attempt).toInt();
    final capped = exponential > maxDelay ? maxDelay : exponential;
    final jitterMs = _random.nextInt(baseDelay.inMilliseconds + 1);
    return capped + Duration(milliseconds: jitterMs);
  }

  Duration? _retryAfter(DioException err) {
    final header = err.response?.headers.value('retry-after');
    if (header == null) return null;
    final seconds = int.tryParse(header.trim());
    return seconds == null ? null : Duration(seconds: seconds);
  }
}
