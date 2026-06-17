import 'package:config/config.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import 'auth_interceptor.dart';
import 'token_refresher.dart';

@module
abstract class AuthNetworkModule {
  /// Authenticated Dio used by the app: attaches the Bearer token and, on 401,
  /// transparently refreshes once and retries the request.
  ///
  /// Interceptor order matters. [PerformanceInterceptor] runs first (outside
  /// dev) so it times the full request, including any retries; [AuthInterceptor]
  /// owns the 401 → refresh path; [RetryInterceptor] then handles transient
  /// failures (timeouts, 5xx) with backoff. In dev builds a [devLogInterceptor]
  /// is appended last so it observes the final, token-bearing requests.
  @lazySingleton
  Dio provideDio(
    AuthLocalDataSource session,
    TokenRefresher refresher,
    EnvConfig env,
    FirebasePerformance performance,
  ) {
    final dio = Dio(apiBaseOptions(env.apiBaseUrl, timeout: env.apiTimeout));
    if (!env.isDev) {
      dio.interceptors.add(PerformanceInterceptor(performance));
    }
    dio.interceptors.add(AuthInterceptor(session, refresher, dio));
    dio.interceptors.add(RetryInterceptor(dio));
    if (env.isDev) {
      dio.interceptors.add(devLogInterceptor());
    }
    return dio;
  }

  @lazySingleton
  AuthRemoteDataSource provideAuthRemoteDataSource(Dio dio) =>
      AuthRemoteDataSource(dio);
}
