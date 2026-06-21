import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:storage/storage.dart';
import 'package:test_utils/test_utils.dart';

class _MockTokenStore extends Mock implements AuthTokenStore {}

class _MockRefresher extends Mock implements TokenRefresher {}

class _MockDio extends Mock implements Dio {}

class _MockRequestHandler extends Mock implements RequestInterceptorHandler {}

class _MockErrorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(
      DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.unknown,
      ),
    );
    registerFallbackValue(
      Response<dynamic>(
        requestOptions: RequestOptions(path: '/'),
        statusCode: 200,
      ),
    );
  });

  late _MockTokenStore tokens;
  late _MockRefresher refresher;
  late _MockDio dio;
  late AuthInterceptor interceptor;

  setUp(() {
    tokens = _MockTokenStore();
    refresher = _MockRefresher();
    dio = _MockDio();
    interceptor = AuthInterceptor(tokens, refresher, dio);
  });

  RequestOptions opts({Map<String, dynamic>? extra}) => RequestOptions(
    path: '/test',
    extra: extra ?? {},
  );

  DioException err401(RequestOptions o) => DioException(
    requestOptions: o,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(requestOptions: o, statusCode: 401),
  );

  group('onRequest', () {
    test('attaches Bearer header when access token exists', () {
      when(() => tokens.accessToken).thenReturn('tok123');
      final handler = _MockRequestHandler();
      final o = opts();
      when(() => handler.next(any())).thenReturn(null);

      interceptor.onRequest(o, handler);

      expect(o.headers['Authorization'], 'Bearer tok123');
      verify(() => handler.next(o)).called(1);
    });

    test('omits Authorization header when access token is null', () {
      when(() => tokens.accessToken).thenReturn(null);
      final handler = _MockRequestHandler();
      final o = opts();
      when(() => handler.next(any())).thenReturn(null);

      interceptor.onRequest(o, handler);

      expect(o.headers.containsKey('Authorization'), isFalse);
      verify(() => handler.next(o)).called(1);
    });
  });

  group('onError', () {
    test(
      'on 401: refreshes and retries with __auth_retried__ + new bearer',
      () async {
        when(() => tokens.accessToken).thenReturn('new-token');
        when(
          () => refresher.refresh(),
        ).thenAnswer((_) async => RefreshOutcome.refreshed);
        final o = opts();
        final err = err401(o);
        final handler = _MockErrorHandler();
        final retryResponse = Response<dynamic>(
          requestOptions: o,
          statusCode: 200,
        );
        when(
          () => dio.fetch<dynamic>(any()),
        ).thenAnswer((_) async => retryResponse);
        when(() => handler.resolve(any())).thenReturn(null);
        when(() => handler.next(any())).thenReturn(null);

        await interceptor.onError(err, handler);

        final captured = verify(
          () => dio.fetch<dynamic>(captureAny()),
        ).captured;
        final retriedOpts = captured.first as RequestOptions;
        expect(retriedOpts.extra['__auth_retried__'], isTrue);
        expect(retriedOpts.headers['Authorization'], 'Bearer new-token');
        verify(() => handler.resolve(retryResponse)).called(1);
        verifyNever(() => handler.next(any()));
      },
    );

    test('does not retry when __auth_retried__ flag is already set', () async {
      final o = opts(extra: {'__auth_retried__': true});
      final err = err401(o);
      final handler = _MockErrorHandler();
      when(() => handler.next(any())).thenReturn(null);

      await interceptor.onError(err, handler);

      verifyNever(() => refresher.refresh());
      verifyNever(() => dio.fetch<dynamic>(any()));
      verify(() => handler.next(err)).called(1);
    });

    test('does not retry when refresh returns networkError', () async {
      when(
        () => refresher.refresh(),
      ).thenAnswer((_) async => RefreshOutcome.networkError);
      final o = opts();
      final err = err401(o);
      final handler = _MockErrorHandler();
      when(() => handler.next(any())).thenReturn(null);

      await interceptor.onError(err, handler);

      verifyNever(() => dio.fetch<dynamic>(any()));
      verify(() => handler.next(err)).called(1);
    });

    test('does not retry when refresh returns invalidSession', () async {
      when(
        () => refresher.refresh(),
      ).thenAnswer((_) async => RefreshOutcome.invalidSession);
      final o = opts();
      final err = err401(o);
      final handler = _MockErrorHandler();
      when(() => handler.next(any())).thenReturn(null);

      await interceptor.onError(err, handler);

      verifyNever(() => dio.fetch<dynamic>(any()));
      verify(() => handler.next(err)).called(1);
    });

    test('passes through non-401 errors without refreshing', () async {
      final o = opts();
      final err = DioException(
        requestOptions: o,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(requestOptions: o, statusCode: 500),
      );
      final handler = _MockErrorHandler();
      when(() => handler.next(any())).thenReturn(null);

      await interceptor.onError(err, handler);

      verifyNever(() => refresher.refresh());
      verifyNever(() => dio.fetch<dynamic>(any()));
      verify(() => handler.next(err)).called(1);
    });
  });
}
