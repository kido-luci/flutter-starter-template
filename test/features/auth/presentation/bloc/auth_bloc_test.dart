import 'package:architecture/architecture.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:feature_auth/src/presentation/bloc/auth_bloc.dart';
import 'package:feature_auth/src/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_utils.dart';

void main() {
  late MockSignIn mockSignIn;
  late MockRegister mockRegister;
  late MockSignOut mockSignOut;
  late MockRestoreSession mockRestoreSession;
  late MockAnalyticsService mockAnalytics;
  late AuthBloc bloc;

  setUp(() {
    mockSignIn = MockSignIn();
    mockRegister = MockRegister();
    mockSignOut = MockSignOut();
    mockRestoreSession = MockRestoreSession();
    mockAnalytics = MockAnalyticsService();
    stubAnalyticsService(mockAnalytics);
    bloc = AuthBloc(
      signIn: mockSignIn,
      register: mockRegister,
      signOut: mockSignOut,
      restoreSession: mockRestoreSession,
      analytics: mockAnalytics,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(bloc.state, const AuthState.initial());
    });

    group('restoreSession', () {
      blocTest<AuthBloc, AuthState>(
        'emits authenticated when session is restored',
        build: () {
          when(
            () => mockRestoreSession(),
          ).thenAnswer((_) async => const Ok(testUser));
          return bloc;
        },
        act: (bloc) => bloc.add(const AuthSessionRestoreRequested()),
        expect: () => [
          const AuthState.restoring(),
          const AuthState.authenticated(testUser),
        ],
        verify: (_) {
          verify(() => mockAnalytics.setCurrentUser(testUser.id)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits initial when no persisted session',
        build: () {
          when(
            () => mockRestoreSession(),
          ).thenAnswer((_) async => const Err(NoSessionFailure()));
          return bloc;
        },
        act: (bloc) => bloc.add(const AuthSessionRestoreRequested()),
        expect: () => [
          const AuthState.restoring(),
          const AuthState.initial(),
        ],
        verify: (_) {
          verify(() => mockAnalytics.setCurrentUser(null)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits failure when restore returns a real error',
        build: () {
          when(
            () => mockRestoreSession(),
          ).thenAnswer((_) async => const Err(testFailure));
          return bloc;
        },
        act: (bloc) => bloc.add(const AuthSessionRestoreRequested()),
        expect: () => [
          const AuthState.restoring(),
          const AuthState.failure(testFailure),
        ],
        verify: (_) {
          verify(() => mockAnalytics.setCurrentUser(null)).called(1);
        },
      );
    });

    blocTest<AuthBloc, AuthState>(
      'clears session without invoking sign out use case',
      build: () => bloc,
      seed: () => const AuthState.authenticated(testUser),
      act: (bloc) => bloc.add(const AuthSessionCleared()),
      expect: () => [const AuthState.initial()],
      verify: (_) {
        verifyNever(() => mockSignOut());
      },
    );

    group('signIn', () {
      blocTest<AuthBloc, AuthState>(
        'emits submitting then authenticated on success',
        build: () {
          when(
            () => mockSignIn((username: 'alice', password: 'pass')),
          ).thenAnswer((_) async => const Ok(testUser));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const AuthSignInRequested(username: 'alice', password: 'pass'),
        ),
        expect: () => [
          const AuthState.submitting(),
          const AuthState.authenticated(testUser),
        ],
        verify: (_) {
          verify(() => mockAnalytics.setCurrentUser(testUser.id)).called(1);
          verify(() => mockAnalytics.logLogin(method: 'password')).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits submitting then failure on error',
        build: () {
          when(
            () => mockSignIn((username: 'bob', password: 'bad')),
          ).thenAnswer((_) async => const Err(testFailure));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const AuthSignInRequested(username: 'bob', password: 'bad'),
        ),
        expect: () => [
          const AuthState.submitting(),
          const AuthState.failure(testFailure),
        ],
        verify: (_) {
          verify(
            () => mockAnalytics.logEvent(
              'login_failed',
              parameters: any(named: 'parameters'),
            ),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'drops duplicate sign-in while one is in flight',
        build: () {
          when(
            () => mockSignIn((username: 'alice', password: 'pass')),
          ).thenAnswer(
            (_) => Future.delayed(
              const Duration(milliseconds: 50),
              () => const Ok(testUser),
            ),
          );
          return bloc;
        },
        act: (bloc) {
          bloc
            ..add(
              const AuthSignInRequested(username: 'alice', password: 'pass'),
            )
            ..add(
              const AuthSignInRequested(username: 'alice', password: 'pass'),
            );
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const AuthState.submitting(),
          const AuthState.authenticated(testUser),
        ],
        verify: (_) {
          verify(
            () => mockSignIn((username: 'alice', password: 'pass')),
          ).called(1);
        },
      );
    });

    group('signOut', () {
      blocTest<AuthBloc, AuthState>(
        'transitions through signingOut to initial on success',
        build: () {
          when(() => mockSignOut()).thenAnswer((_) async => const Ok(null));
          return bloc;
        },
        seed: () => const AuthState.authenticated(testUser),
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          const AuthState.signingOut(testUser),
          const AuthState.initial(),
        ],
        verify: (_) {
          verify(() => mockAnalytics.logEvent('sign_out')).called(1);
          verify(() => mockAnalytics.setCurrentUser(null)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'still lands on initial when sign-out returns Err',
        build: () {
          when(
            () => mockSignOut(),
          ).thenAnswer((_) async => const Err(testFailure));
          return bloc;
        },
        seed: () => const AuthState.authenticated(testUser),
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          const AuthState.signingOut(testUser),
          const AuthState.initial(),
        ],
      );
    });
  });
}
