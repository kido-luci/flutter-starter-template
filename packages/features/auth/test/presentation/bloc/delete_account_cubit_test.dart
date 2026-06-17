import 'package:architecture/architecture.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:feature_auth/src/presentation/bloc/delete_account_cubit.dart';
import 'package:feature_auth/src/presentation/bloc/delete_account_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support.dart';

void main() {
  late MockDeleteAccount mockDeleteAccount;
  late MockAnalyticsService mockAnalytics;

  setUp(() {
    mockDeleteAccount = MockDeleteAccount();
    mockAnalytics = MockAnalyticsService();
    stubAnalyticsService(mockAnalytics);
  });

  DeleteAccountCubit buildCubit() =>
      DeleteAccountCubit(mockDeleteAccount, mockAnalytics);

  group('DeleteAccountCubit', () {
    test('initial state is DeleteAccountInitial', () {
      expect(buildCubit().state, const DeleteAccountState.initial());
    });

    blocTest<DeleteAccountCubit, DeleteAccountState>(
      'emits submitting then success and tracks analytics on success',
      build: () {
        when(() => mockDeleteAccount()).thenAnswer((_) async => const Ok(null));
        return buildCubit();
      },
      act: (cubit) => cubit.submit(),
      expect: () => [
        const DeleteAccountState.submitting(),
        const DeleteAccountState.success(),
      ],
      verify: (_) {
        verify(() => mockAnalytics.logEvent('account_deleted')).called(1);
        verify(() => mockAnalytics.setCurrentUser(null)).called(1);
      },
    );

    blocTest<DeleteAccountCubit, DeleteAccountState>(
      'emits submitting then failure on error',
      build: () {
        when(
          () => mockDeleteAccount(),
        ).thenAnswer((_) async => const Err(testFailure));
        return buildCubit();
      },
      act: (cubit) => cubit.submit(),
      expect: () => [
        const DeleteAccountState.submitting(),
        const DeleteAccountState.failure(testFailure),
      ],
      verify: (_) {
        verifyNever(() => mockAnalytics.logEvent('account_deleted'));
      },
    );

    blocTest<DeleteAccountCubit, DeleteAccountState>(
      'ignores a second submit while one is in flight',
      build: () {
        when(() => mockDeleteAccount()).thenAnswer(
          (_) => Future.delayed(
            const Duration(milliseconds: 50),
            () => const Ok(null),
          ),
        );
        return buildCubit();
      },
      act: (cubit) {
        cubit
          ..submit()
          ..submit();
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        const DeleteAccountState.submitting(),
        const DeleteAccountState.success(),
      ],
      verify: (_) {
        verify(() => mockDeleteAccount()).called(1);
      },
    );
  });
}
