import 'package:feature_auth/src/presentation/bloc/delete_account_cubit.dart';
import 'package:feature_auth/src/presentation/bloc/delete_account_state.dart';
import 'package:feature_profile/src/presentation/bloc/profile_bloc.dart';
import 'package:feature_profile/src/presentation/bloc/profile_state.dart';
import 'package:feature_profile/src/presentation/widgets/profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:theme/theme.dart';

import '../../support.dart';

class MockThemeBloc extends Mock implements ThemeBloc {}

class MockProfileBloc extends Mock implements ProfileBloc {}

class MockDeleteAccountCubit extends Mock implements DeleteAccountCubit {}

void main() {
  late FakeSession session;
  late MockThemeBloc themeBloc;
  late MockProfileBloc profileBloc;
  late MockDeleteAccountCubit deleteAccountCubit;

  setUp(() {
    session = FakeSession(currentUser: testUser);
    themeBloc = MockThemeBloc();
    profileBloc = MockProfileBloc();
    deleteAccountCubit = MockDeleteAccountCubit();

    const themeState = ThemeState(
      mode: ThemeMode.system,
      scheme: ThemeState.defaultScheme,
    );
    when(() => themeBloc.state).thenReturn(themeState);
    when(() => themeBloc.stream).thenAnswer((_) => const Stream.empty());

    const profileState = ProfileState();
    when(() => profileBloc.state).thenReturn(profileState);
    when(() => profileBloc.stream).thenAnswer((_) => const Stream.empty());

    when(
      () => deleteAccountCubit.state,
    ).thenReturn(const DeleteAccountState.initial());
    when(
      () => deleteAccountCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => deleteAccountCubit.submit()).thenAnswer((_) async {});
  });

  Future<void> pumpProfile(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SessionScope(
          session: session,
          child: MultiBlocProvider(
            providers: [
              BlocProvider<ThemeBloc>.value(value: themeBloc),
              BlocProvider<ProfileBloc>.value(value: profileBloc),
              BlocProvider<DeleteAccountCubit>.value(value: deleteAccountCubit),
            ],
            child: const ProfileBody(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Delete stays disabled until the username is typed', (
    tester,
  ) async {
    await pumpProfile(tester);

    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    // Dialog is shown with a disabled Delete button.
    expect(find.text('Delete account?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    verifyNever(() => deleteAccountCubit.submit());

    // Wrong text keeps it disabled.
    await tester.enterText(find.byType(TextField), 'bob');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    verifyNever(() => deleteAccountCubit.submit());
  });

  testWidgets('typing the username enables Delete and invokes submit', (
    tester,
  ) async {
    await pumpProfile(tester);

    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), testUser.username);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    verify(() => deleteAccountCubit.submit()).called(1);
  });
}
