import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

/// Programmable adapter: each entry in [responses] is consumed in order on
/// successive requests. A `DioException` entry simulates a transport failure;
/// a `ResponseBody` entry simulates a server response.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.responses);

  final List<Object> responses;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final next = responses[calls];
    calls++;
    if (next is DioException) {
      // Re-point the error at the real request options so it carries the
      // actual HTTP method — this is what real Dio does, and what the
      // interceptor's method-based retry decision depends on.
      throw DioException(
        requestOptions: options,
        type: next.type,
        response: next.response,
        error: next.error,
      );
    }
    return next as ResponseBody;
  }

  @override
  void close({bool force = false}) {}
}

DioException _connectionError() => DioException.connectionError(
  requestOptions: RequestOptions(path: '/'),
  reason: 'boom',
);

void main() {
  // Tiny delays so the exponential backoff doesn't slow the suite.
  Dio buildDio(_ScriptedAdapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    // The interceptor re-dispatches through this same Dio.
    dio.interceptors.add(
      RetryInterceptor(
        dio,
        baseDelay: const Duration(milliseconds: 1),
        maxDelay: const Duration(milliseconds: 5),
      ),
    );
    return dio;
  }

  ResponseBody ok() => ResponseBody.fromString(
    '{}',
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  group('RetryInterceptor', () {
    test(
      'retries a transient failure and resolves on eventual success',
      () async {
        final adapter = _ScriptedAdapter([_connectionError(), ok()]);
        final dio = buildDio(adapter);

        final response = await dio.get<dynamic>('/');

        expect(response.statusCode, 200);
        expect(adapter.calls, 2);
      },
    );

    test('gives up after maxRetries and rethrows', () async {
      final adapter = _ScriptedAdapter([
        _connectionError(),
        _connectionError(),
        _connectionError(),
        _connectionError(),
      ]);
      final dio = buildDio(adapter);

      await expectLater(dio.get<dynamic>('/'), throwsA(isA<DioException>()));
      // initial attempt + 3 retries.
      expect(adapter.calls, 4);
    });

    test('retries retryable status codes (503)', () async {
      final adapter = _ScriptedAdapter([
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 503,
          ),
        ),
        ok(),
      ]);
      final dio = buildDio(adapter);

      final response = await dio.get<dynamic>('/');

      expect(response.statusCode, 200);
      expect(adapter.calls, 2);
    });

    test('does not retry non-retryable client errors (404)', () async {
      final adapter = _ScriptedAdapter([
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 404,
          ),
        ),
        ok(),
      ]);
      final dio = buildDio(adapter);

      await expectLater(dio.get<dynamic>('/'), throwsA(isA<DioException>()));
      expect(adapter.calls, 1);
    });

    test('does not retry a transform timeout', () async {
      // The response arrived and the server has already processed the request
      // — only the local decode overran its budget. Replaying would repeat the
      // same deterministic work, so even a GET is left alone.
      final adapter = _ScriptedAdapter([
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.transformTimeout,
        ),
        ok(),
      ]);
      final dio = buildDio(adapter);

      await expectLater(dio.get<dynamic>('/'), throwsA(isA<DioException>()));
      expect(adapter.calls, 1);
    });

    test('does NOT retry a POST on an ambiguous transport failure', () async {
      // A timed-out POST may already have been processed; replaying it could
      // duplicate the side effect, so it must not be retried.
      final adapter = _ScriptedAdapter([_connectionError(), ok()]);
      final dio = buildDio(adapter);

      await expectLater(dio.post<dynamic>('/'), throwsA(isA<DioException>()));
      expect(adapter.calls, 1);
    });

    test('retries an idempotent PUT on a transport failure', () async {
      final adapter = _ScriptedAdapter([_connectionError(), ok()]);
      final dio = buildDio(adapter);

      final response = await dio.put<dynamic>('/');

      expect(response.statusCode, 200);
      expect(adapter.calls, 2);
    });

    test('still retries a POST on a retryable status code (503)', () async {
      // 503 means the server explicitly did not process the request, so even a
      // POST is safe to retry.
      final adapter = _ScriptedAdapter([
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 503,
          ),
        ),
        ok(),
      ]);
      final dio = buildDio(adapter);

      final response = await dio.post<dynamic>('/');

      expect(response.statusCode, 200);
      expect(adapter.calls, 2);
    });
  });
}
