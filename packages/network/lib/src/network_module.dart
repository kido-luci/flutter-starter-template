import 'dart:developer' as developer;

import 'package:config/config.dart';
import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:injectable/injectable.dart';
import 'package:storage/storage.dart';

import 'auth_interceptor.dart';
import 'performance_interceptor.dart';
import 'retry_interceptor.dart';
import 'token_refresher.dart';

BaseOptions apiBaseOptions(
  String baseUrl, {
  Duration timeout = const Duration(seconds: 10),
}) => BaseOptions(
  baseUrl: baseUrl,
  connectTimeout: timeout,
  receiveTimeout: timeout,
  contentType: 'application/json',
);

/// Verbose request/response logging for development builds only. Routes Dio's
/// output through `dart:developer` (not `print`) so it integrates with
/// DevTools and stays off the release console. Gate the call site on
/// [EnvConfig.isDev].
Interceptor devLogInterceptor() => LogInterceptor(
  requestBody: true,
  responseBody: true,
  logPrint: (object) => developer.log(object.toString(), name: 'dio'),
);

@module
abstract class NetworkModule {
  /// Plain Dio with no auth/refresh wiring. Used by callers that must bypass
  /// application-level interceptors.
  @lazySingleton
  @Named('plain')
  Dio providePlainDio(EnvConfig env) =>
      Dio(apiBaseOptions(env.apiBaseUrl, timeout: env.apiTimeout));

  /// Authenticated Dio used by the app: attaches the Bearer token and, on 401,
  /// transparently refreshes once and retries the request.
  ///
  /// Interceptor order matters. [PerformanceInterceptor] runs first (outside
  /// dev) so it times the full request including retries; [AuthInterceptor]
  /// owns the 401 → refresh path; [RetryInterceptor] handles transient failures
  /// with backoff. In dev a [devLogInterceptor] is appended last so it observes
  /// the final, token-bearing requests.
  @lazySingleton
  Dio provideDio(
    AuthTokenStore tokens,
    TokenRefresher refresher,
    EnvConfig env,
    FirebasePerformance performance,
  ) {
    final dio = Dio(apiBaseOptions(env.apiBaseUrl, timeout: env.apiTimeout));
    if (!env.isDev) {
      dio.interceptors.add(PerformanceInterceptor(performance));
    }
    dio.interceptors.add(AuthInterceptor(tokens, refresher, dio));
    dio.interceptors.add(RetryInterceptor(dio));
    if (env.isDev) {
      dio.interceptors.add(devLogInterceptor());
    }
    return dio;
  }
}
