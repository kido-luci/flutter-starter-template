import 'package:architecture/architecture.dart';
import 'package:feature_auth/src/domain/usecases/change_password.dart';
import 'package:feature_auth/src/domain/usecases/delete_account.dart';
import 'package:feature_auth/src/domain/usecases/register.dart';
import 'package:feature_auth/src/domain/usecases/restore_session.dart';
import 'package:feature_auth/src/domain/usecases/sign_in.dart';
import 'package:feature_auth/src/domain/usecases/sign_out.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';

import '../../support.dart';

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
  });

  group('SignInUseCase', () {
    test('rejects empty username without hitting repository', () async {
      final result = await SignInUseCase(repo)((username: '', password: 'pw'));

      expect(result, isA<Err<AuthUser>>());
      expect(
        (result as Err<AuthUser>).failure,
        isA<InvalidCredentialsFailure>(),
      );
      verifyZeroInteractions(repo);
    });

    test('rejects empty password without hitting repository', () async {
      final result = await SignInUseCase(repo)((
        username: 'alice',
        password: '',
      ));

      expect(result, isA<Err<AuthUser>>());
      verifyZeroInteractions(repo);
    });

    test('delegates to repository when both fields present', () async {
      when(
        () => repo.signIn(username: 'alice', password: 'pw'),
      ).thenAnswer((_) async => const Ok(testUser));

      final result = await SignInUseCase(repo)((
        username: 'alice',
        password: 'pw',
      ));

      expect(result, isA<Ok<AuthUser>>());
      verify(() => repo.signIn(username: 'alice', password: 'pw')).called(1);
    });
  });

  group('RegisterUseCase', () {
    test('rejects empty credentials without hitting repository', () async {
      final result = await RegisterUseCase(repo)((username: '', password: ''));

      expect(result, isA<Err<AuthUser>>());
      expect(
        (result as Err<AuthUser>).failure,
        isA<InvalidCredentialsFailure>(),
      );
      verifyZeroInteractions(repo);
    });
  });

  group('ChangePasswordUseCase', () {
    test('rejects empty currentPassword', () async {
      final result = await ChangePasswordUseCase(repo)(
        (currentPassword: '', newPassword: 'new'),
      );

      expect(result, isA<Err<void>>());
      expect(
        (result as Err<void>).failure,
        isA<InvalidCredentialsFailure>(),
      );
      verifyZeroInteractions(repo);
    });

    test('rejects empty newPassword', () async {
      final result = await ChangePasswordUseCase(repo)(
        (currentPassword: 'cur', newPassword: ''),
      );

      expect(result, isA<Err<void>>());
      verifyZeroInteractions(repo);
    });
  });

  group('session use cases', () {
    test('DeleteAccountUseCase delegates to repository', () async {
      when(() => repo.deleteAccount()).thenAnswer((_) async => const Ok(null));

      final result = await DeleteAccountUseCase(repo)();

      expect(result, isA<Ok<void>>());
      verify(() => repo.deleteAccount()).called(1);
    });

    test('RestoreSessionUseCase delegates to repository', () async {
      when(
        () => repo.restoreSession(),
      ).thenAnswer((_) async => const Ok(testUser));

      final result = await RestoreSessionUseCase(repo)();

      expect(result, isA<Ok<AuthUser>>());
      verify(() => repo.restoreSession()).called(1);
    });

    test('SignOutUseCase delegates to repository', () async {
      when(() => repo.signOut()).thenAnswer((_) async => const Ok(null));

      final result = await SignOutUseCase(repo)();

      expect(result, isA<Ok<void>>());
      verify(() => repo.signOut()).called(1);
    });

    test('SignOutUseCase maps thrown errors to UnknownFailure', () async {
      when(() => repo.signOut()).thenThrow(Exception('offline'));

      final result = await SignOutUseCase(repo)();

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<UnknownFailure>());
    });
  });
}
