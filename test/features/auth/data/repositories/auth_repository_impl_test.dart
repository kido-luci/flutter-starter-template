import 'package:architecture/architecture.dart';
import 'package:feature_auth/src/data/datasources/auth_local_data_source.dart';
import 'package:feature_auth/src/data/datasources/auth_remote_data_source.dart';
import 'package:feature_auth/src/data/models/auth_user_dto.dart';
import 'package:feature_auth/src/data/models/refresh_token_request.dart';
import 'package:feature_auth/src/data/models/sign_in_request.dart';
import 'package:feature_auth/src/data/models/sign_in_response.dart';
import 'package:feature_auth/src/data/network/token_refresher.dart';
import 'package:feature_auth/src/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:test_utils/test_utils.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockTokenRefresher extends Mock implements TokenRefresher {}

class FakeSignInRequest extends Fake implements SignInRequest {}

class FakeRefreshTokenRequest extends Fake implements RefreshTokenRequest {}

class FakeAuthUser extends Fake implements AuthUser {}

void main() {
  late MockAuthRemoteDataSource mockRemote;
  late MockAuthLocalDataSource mockLocal;
  late MockTokenRefresher mockRefresher;
  late AuthRepositoryImpl repository;

  const testUser = AuthUser(id: 'user-1', username: 'alice');
  const testSignInResponse = SignInResponse(
    user: AuthUserDto(id: 'user-1', username: 'alice'),
    accessToken: 'access',
    refreshToken: 'refresh',
    expiresIn: 3600,
  );

  setUpAll(() {
    registerFallbackValue(FakeSignInRequest());
    registerFallbackValue(FakeRefreshTokenRequest());
    registerFallbackValue(FakeAuthUser());
  });

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockLocal = MockAuthLocalDataSource();
    mockRefresher = MockTokenRefresher();
    repository = AuthRepositoryImpl(mockRemote, mockLocal, mockRefresher);
  });

  group('signIn', () {
    test('returns Ok with user and persists session on success', () async {
      when(
        () => mockRemote.signIn(any()),
      ).thenAnswer((_) async => testSignInResponse);
      when(
        () => mockLocal.setSession(
          user: any(named: 'user'),
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.signIn(
        username: 'alice',
        password: 'pass',
      );

      expect(result, isA<Ok<AuthUser>>());
      final ok = result as Ok<AuthUser>;
      expect(ok.value.id, 'user-1');
      expect(ok.value.username, 'alice');

      verify(
        () => mockLocal.setSession(
          user: any(named: 'user'),
          accessToken: 'access',
          refreshToken: 'refresh',
        ),
      ).called(1);
    });

    test('returns InvalidCredentialsFailure on 401 DioException', () async {
      when(() => mockRemote.signIn(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/auth/sign-in'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/auth/sign-in'),
            statusCode: 401,
            data: {'message': 'Bad credentials'},
          ),
        ),
      );

      final result = await repository.signIn(
        username: 'alice',
        password: 'bad',
      );

      expect(result, isA<Err<AuthUser>>());
      final err = result as Err<AuthUser>;
      expect(err.failure, isA<InvalidCredentialsFailure>());
      expect(err.failure.message, 'Bad credentials');
    });

    test('returns UnknownFailure on non-401 DioException', () async {
      when(() => mockRemote.signIn(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/auth/sign-in'),
          message: 'Network error',
        ),
      );

      final result = await repository.signIn(
        username: 'alice',
        password: 'pass',
      );

      expect(result, isA<Err<AuthUser>>());
      final err = result as Err<AuthUser>;
      expect(err.failure, isA<UnknownFailure>());
      expect(err.failure.message, 'Network error');
    });

    test('returns default message when DioException has no message', () async {
      when(() => mockRemote.signIn(any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/api/auth/sign-in')),
      );

      final result = await repository.signIn(
        username: 'alice',
        password: 'pass',
      );

      expect(result, isA<Err<AuthUser>>());
      final err = result as Err<AuthUser>;
      expect(err.failure, isA<UnknownFailure>());
      expect(err.failure.message, 'Network error');
    });
  });

  group('signOut', () {
    test(
      'clears local session and returns Ok when server call succeeds',
      () async {
        when(() => mockLocal.refreshToken).thenReturn('refresh');
        when(() => mockRemote.signOut(any())).thenAnswer((_) async {});
        when(() => mockLocal.clearSession()).thenAnswer((_) async {});

        final result = await repository.signOut();

        expect(result, isA<Ok<void>>());
        verify(() => mockLocal.clearSession()).called(1);
      },
    );

    test(
      'still clears local session when server call fails (best-effort)',
      () async {
        when(() => mockLocal.refreshToken).thenReturn('refresh');
        when(() => mockRemote.signOut(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/auth/sign-out'),
          ),
        );
        when(() => mockLocal.clearSession()).thenAnswer((_) async {});

        final result = await repository.signOut();

        expect(result, isA<Ok<void>>());
        verify(() => mockLocal.clearSession()).called(1);
      },
    );

    test('clears local session even when no refresh token', () async {
      when(() => mockLocal.refreshToken).thenReturn(null);
      when(() => mockLocal.clearSession()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, isA<Ok<void>>());
      verifyNever(() => mockRemote.signOut(any()));
      verify(() => mockLocal.clearSession()).called(1);
    });
  });

  group('deleteAccount', () {
    test('clears local session and returns Ok on success', () async {
      when(() => mockRemote.deleteAccount()).thenAnswer((_) async {});
      when(() => mockLocal.clearSession()).thenAnswer((_) async {});

      final result = await repository.deleteAccount();

      expect(result, isA<Ok<void>>());
      verify(() => mockLocal.clearSession()).called(1);
    });

    test('keeps session and returns Err when server call fails', () async {
      when(() => mockRemote.deleteAccount()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/auth/account'),
          message: 'Network error',
        ),
      );

      final result = await repository.deleteAccount();

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<UnknownFailure>());
      verifyNever(() => mockLocal.clearSession());
    });
  });

  group('restoreSession', () {
    setUp(() {
      when(() => mockLocal.load()).thenAnswer((_) async {});
    });

    test('returns NoSessionFailure when no user persisted', () async {
      when(() => mockLocal.currentUser).thenReturn(null);
      when(() => mockLocal.refreshToken).thenReturn('refresh');

      final result = await repository.restoreSession();

      expect(result, isA<Err<AuthUser>>());
      final err = result as Err<AuthUser>;
      expect(err.failure, isA<NoSessionFailure>());
    });

    test('returns NoSessionFailure when no refresh token', () async {
      when(() => mockLocal.currentUser).thenReturn(testUser);
      when(() => mockLocal.refreshToken).thenReturn(null);

      final result = await repository.restoreSession();

      expect(result, isA<Err<AuthUser>>());
      expect((result as Err<AuthUser>).failure, isA<NoSessionFailure>());
    });

    test(
      'returns NoSessionFailure on invalidSession (refresher owns clearing)',
      () async {
        when(() => mockLocal.currentUser).thenReturn(testUser);
        when(() => mockLocal.refreshToken).thenReturn('refresh');
        when(
          () => mockRefresher.refresh(),
        ).thenAnswer((_) async => RefreshOutcome.invalidSession);

        final result = await repository.restoreSession();

        expect(result, isA<Err<AuthUser>>());
        final err = result as Err<AuthUser>;
        expect(err.failure, isA<NoSessionFailure>());
        expect(err.failure.message, 'Session expired.');
        // The repository no longer double-clears: TokenRefresher already wiped
        // storage on a genuine token rejection.
        verifyNever(() => mockLocal.clearSession());
      },
    );

    test(
      'restores optimistically (Ok) when refresh hits a network error',
      () async {
        when(() => mockLocal.currentUser).thenReturn(testUser);
        when(() => mockLocal.refreshToken).thenReturn('refresh');
        when(
          () => mockRefresher.refresh(),
        ).thenAnswer((_) async => RefreshOutcome.networkError);

        final result = await repository.restoreSession();

        // Offline launch must keep the user signed in, not wipe the session.
        expect(result, isA<Ok<AuthUser>>());
        expect((result as Ok<AuthUser>).value.id, 'user-1');
        verifyNever(() => mockLocal.clearSession());
      },
    );

    test('returns Ok with user on successful session restore', () async {
      when(() => mockLocal.currentUser).thenReturn(testUser);
      when(() => mockLocal.refreshToken).thenReturn('refresh');
      when(
        () => mockRefresher.refresh(),
      ).thenAnswer((_) async => RefreshOutcome.refreshed);

      final result = await repository.restoreSession();

      expect(result, isA<Ok<AuthUser>>());
      final ok = result as Ok<AuthUser>;
      expect(ok.value.id, 'user-1');
      expect(ok.value.username, 'alice');
    });
  });

  group('currentUser', () {
    test('delegates to local data source', () {
      when(() => mockLocal.currentUser).thenReturn(testUser);
      expect(repository.currentUser, testUser);
    });

    test('returns null when local has no user', () {
      when(() => mockLocal.currentUser).thenReturn(null);
      expect(repository.currentUser, isNull);
    });
  });
}
