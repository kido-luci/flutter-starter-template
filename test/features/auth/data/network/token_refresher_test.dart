import 'dart:async';

import 'package:feature_auth/src/data/datasources/auth_local_data_source.dart';
import 'package:feature_auth/src/data/network/token_refresher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:test_utils/test_utils.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockAuthLocalDataSource local;
  late MockDio dio;
  late TokenRefresher refresher;

  Response<Map<String, dynamic>> okResponse(Map<String, dynamic>? body) =>
      Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/api/auth/refresh'),
        statusCode: 200,
        data: body,
      );

  DioException dioError({int? status, DioExceptionType? type}) => DioException(
    requestOptions: RequestOptions(path: '/api/auth/refresh'),
    type: type ?? DioExceptionType.badResponse,
    response: status == null
        ? null
        : Response<dynamic>(
            requestOptions: RequestOptions(path: '/api/auth/refresh'),
            statusCode: status,
          ),
  );

  setUp(() {
    local = MockAuthLocalDataSource();
    dio = MockDio();
    refresher = TokenRefresher(local, dio);
    when(() => local.clearSession()).thenAnswer((_) async {});
    when(
      () => local.updateTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});
  });

  void stubPost(Object Function() answer) {
    when(
      () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).thenAnswer((_) {
      final result = answer();
      if (result is DioException) throw result;
      return Future.value(result as Response<Map<String, dynamic>>);
    });
  }

  test(
    'returns invalidSession and does not POST when no refresh token',
    () async {
      when(() => local.refreshToken).thenReturn(null);

      expect(await refresher.refresh(), RefreshOutcome.invalidSession);
      verifyNever(
        () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      );
    },
  );

  test('refreshes and persists new tokens on success', () async {
    when(() => local.refreshToken).thenReturn('old');
    stubPost(
      () => okResponse({
        'user': {'id': 'u1', 'username': 'alice'},
        'access_token': 'new-access',
        'refresh_token': 'new-refresh',
        'expires_in': 3600,
      }),
    );

    expect(await refresher.refresh(), RefreshOutcome.refreshed);
    verify(
      () => local.updateTokens(
        accessToken: 'new-access',
        refreshToken: 'new-refresh',
      ),
    ).called(1);
    verifyNever(() => local.clearSession());
  });

  test('keeps session (networkError) on connection error', () async {
    when(() => local.refreshToken).thenReturn('old');
    stubPost(() => dioError(type: DioExceptionType.connectionError));

    expect(await refresher.refresh(), RefreshOutcome.networkError);
    verifyNever(() => local.clearSession());
  });

  test('keeps session (networkError) on a 5xx server error', () async {
    when(() => local.refreshToken).thenReturn('old');
    stubPost(() => dioError(status: 503));

    expect(await refresher.refresh(), RefreshOutcome.networkError);
    verifyNever(() => local.clearSession());
  });

  test('clears session (invalidSession) on 401', () async {
    when(() => local.refreshToken).thenReturn('old');
    stubPost(() => dioError(status: 401));

    expect(await refresher.refresh(), RefreshOutcome.invalidSession);
    verify(() => local.clearSession()).called(1);
  });

  test('clears session (invalidSession) on a null body', () async {
    when(() => local.refreshToken).thenReturn('old');
    stubPost(() => okResponse(null));

    expect(await refresher.refresh(), RefreshOutcome.invalidSession);
    verify(() => local.clearSession()).called(1);
  });

  test('single-flight: concurrent callers share one POST', () async {
    when(() => local.refreshToken).thenReturn('old');
    final completer = Completer<Response<Map<String, dynamic>>>();
    when(
      () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).thenAnswer((_) => completer.future);

    final f1 = refresher.refresh();
    final f2 = refresher.refresh();
    expect(f1, same(f2));

    completer.complete(
      okResponse({
        'user': {'id': 'u1', 'username': 'alice'},
        'access_token': 'a',
        'refresh_token': 'r',
        'expires_in': 1,
      }),
    );
    await f1;

    verify(
      () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).called(1);
  });
}
