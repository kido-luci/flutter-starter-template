// Widget tests for the profile screen body. delete_account_flow_test covers the
// destructive delete flow; these cover the rest of the screen: the session
// identity header, the appearance theme-mode control wiring, and the sign-out
// confirmation. The harness mirrors delete_account_flow_test (mocked blocs +
// FakeSession) with a tall surface so every settings card is hit-testable.

import 'package:app_ui/app_ui.dart';
// Deliberate cross-feature capability import: profile surfaces auth's
// delete-account flow (see the capability exception in CLAUDE.md).
import 'package:feature_auth/feature_auth.dart';
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

  setUpAll(() {
    registerFallbackValue(const ThemeModeChanged(ThemeMode.system));
  });

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
  });

  Future<void> pumpProfile(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

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

  testWidgets('header shows the signed-in user identity', (tester) async {
    await pumpProfile(tester);

    expect(find.text(testUser.username), findsOneWidget); // 'alice'
    expect(find.text(testUser.id), findsOneWidget); // 'user-1'
  });

  testWidgets('selecting a theme mode dispatches ThemeModeChanged', (
    tester,
  ) async {
    await pumpProfile(tester);

    final darkTile = find.byWidgetPredicate(
      (w) => w is RadioListTile<ThemeMode> && w.value == ThemeMode.dark,
    );
    expect(darkTile, findsOneWidget);
    await tester.ensureVisible(darkTile);
    await tester.tap(darkTile);
    await tester.pumpAndSettle();

    verify(
      () => themeBloc.add(
        any(
          that: isA<ThemeModeChanged>().having(
            (e) => e.mode,
            'mode',
            ThemeMode.dark,
          ),
        ),
      ),
    ).called(1);
  });

  testWidgets('confirming sign-out clears the session', (tester) async {
    await pumpProfile(tester);
    expect(session.currentUser, isNotNull);

    await tester.tap(find.byType(AppButton)); // the Sign Out button
    await tester.pumpAndSettle();

    // The confirmation dialog's confirm button is its only FilledButton.
    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(session.currentUser, isNull);
  });

  testWidgets('cancelling sign-out keeps the session', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.widgetWithText(TextButton, 'Cancel'),
      ),
    );
    await tester.pumpAndSettle();

    expect(session.currentUser, isNotNull);
  });
}
