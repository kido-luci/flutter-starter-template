import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:storage/storage.dart';
import 'package:test_utils/test_utils.dart';

class _MockTokenStore extends Mock implements AuthTokenStore {}

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockTokenStore tokens;
  late _MockDio dio;
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
    tokens = _MockTokenStore();
    dio = _MockDio();
    refresher = TokenRefresher(tokens, dio);
    when(() => tokens.clearTokens()).thenAnswer((_) async {});
    when(
      () => tokens.updateTokens(
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

  test('returns invalidSession and does not POST when no refresh token',
      () async {
    when(() => tokens.refreshToken).thenReturn(null);

    expect(await refresher.refresh(), RefreshOutcome.invalidSession);
    verifyNever(
      () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    );
  });

  test('refreshes and persists new tokens on success', () async {
    when(() => tokens.refreshToken).thenReturn('old');
    stubPost(
      () => okResponse({
        'access_token': 'new-access',
        'refresh_token': 'new-refresh',
        'expires_in': 3600,
      }),
    );

    expect(await refresher.refresh(), RefreshOutcome.refreshed);
    verify(
      () => tokens.updateTokens(
        accessToken: 'new-access',
        refreshToken: 'new-refresh',
      ),
    ).called(1);
    verifyNever(() => tokens.clearTokens());
  });

  test('keeps session (networkError) on connection error', () async {
    when(() => tokens.refreshToken).thenReturn('old');
    stubPost(() => dioError(type: DioExceptionType.connectionError));

    expect(await refresher.refresh(), RefreshOutcome.networkError);
    verifyNever(() => tokens.clearTokens());
  });

  test('keeps session (networkError) on a 5xx server error', () async {
    when(() => tokens.refreshToken).thenReturn('old');
    stubPost(() => dioError(status: 503));

    expect(await refresher.refresh(), RefreshOutcome.networkError);
    verifyNever(() => tokens.clearTokens());
  });

  test('clears tokens (invalidSession) on 401', () async {
    when(() => tokens.refreshToken).thenReturn('old');
    stubPost(() => dioError(status: 401));

    expect(await refresher.refresh(), RefreshOutcome.invalidSession);
    verify(() => tokens.clearTokens()).called(1);
  });

  test('clears tokens (invalidSession) on a null body', () async {
    when(() => tokens.refreshToken).thenReturn('old');
    stubPost(() => okResponse(null));

    expect(await refresher.refresh(), RefreshOutcome.invalidSession);
    verify(() => tokens.clearTokens()).called(1);
  });

  test('clears tokens (invalidSession) on a malformed body, without throwing',
      () async {
    when(() => tokens.refreshToken).thenReturn('old');
    stubPost(() => okResponse({'unexpected': 'shape'}));

    expect(await refresher.refresh(), RefreshOutcome.invalidSession);
    verify(() => tokens.clearTokens()).called(1);
    verifyNever(
      () => tokens.updateTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    );
  });

  test('single-flight: concurrent callers share one POST', () async {
    when(() => tokens.refreshToken).thenReturn('old');
    final completer = Completer<Response<Map<String, dynamic>>>();
    when(
      () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).thenAnswer((_) => completer.future);

    final f1 = refresher.refresh();
    final f2 = refresher.refresh();
    expect(f1, same(f2));

    completer.complete(
      okResponse({'access_token': 'a', 'refresh_token': 'r', 'expires_in': 1}),
    );
    await f1;

    verify(
      () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).called(1);
  });
}
