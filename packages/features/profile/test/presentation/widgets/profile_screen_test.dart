// Widget tests for the profile screen body. delete_account_flow_test covers the
// destructive delete flow; these cover the rest of the screen: the session
// identity header, the appearance theme-mode control wiring, and the sign-out
// confirmation. The harness mirrors delete_account_flow_test (mocked blocs +
// FakeSession) with a tall surface so every settings card is hit-testable.

// fst:auth:start
// AppButton is only reached by the sign-out tests below.
import 'package:app_ui/app_ui.dart';
// Deliberate cross-feature capability import: profile surfaces auth's
// delete-account flow (see the capability exception in CLAUDE.md).
import 'package:feature_auth/feature_auth.dart';
// fst:auth:end
import 'package:feature_profile/src/presentation/bloc/profile_bloc.dart';
import 'package:feature_profile/src/presentation/bloc/profile_state.dart';
import 'package:feature_profile/src/presentation/widgets/profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
// fst:auth:start
import 'package:shared_ui/shared_ui.dart';
// fst:auth:end
import 'package:theme/theme.dart';

import '../../support.dart';

class MockThemeBloc extends Mock implements ThemeBloc {}

class MockProfileBloc extends Mock implements ProfileBloc {}

// fst:auth:start
class MockDeleteAccountCubit extends Mock implements DeleteAccountCubit {}
// fst:auth:end

void main() {
  // fst:auth:start
  late FakeSession session;
  // fst:auth:end
  late MockThemeBloc themeBloc;
  late MockProfileBloc profileBloc;
  // fst:auth:start
  late MockDeleteAccountCubit deleteAccountCubit;
  // fst:auth:end

  setUpAll(() {
    registerFallbackValue(const ThemeModeChanged(ThemeMode.system));
  });

  setUp(() {
    // fst:auth:start
    session = FakeSession(currentUser: testUser);
    // fst:auth:end
    themeBloc = MockThemeBloc();
    profileBloc = MockProfileBloc();
    // fst:auth:start
    deleteAccountCubit = MockDeleteAccountCubit();
    // fst:auth:end

    const themeState = ThemeState(
      mode: ThemeMode.system,
      scheme: ThemeState.defaultScheme,
    );
    when(() => themeBloc.state).thenReturn(themeState);
    when(() => themeBloc.stream).thenAnswer((_) => const Stream.empty());

    const profileState = ProfileState();
    when(() => profileBloc.state).thenReturn(profileState);
    when(() => profileBloc.stream).thenAnswer((_) => const Stream.empty());

    // fst:auth:start
    when(
      () => deleteAccountCubit.state,
    ).thenReturn(const DeleteAccountState.initial());
    when(
      () => deleteAccountCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    // fst:auth:end
  });

  Future<void> pumpProfile(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Mirrors how `App` composes the tree: providers first, then the auth-only
    // SessionScope wrapped around them.
    Widget home = MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>.value(value: themeBloc),
        BlocProvider<ProfileBloc>.value(value: profileBloc),
        // fst:auth:start
        BlocProvider<DeleteAccountCubit>.value(value: deleteAccountCubit),
        // fst:auth:end
      ],
      child: const ProfileBody(),
    );
    // fst:auth:start
    home = SessionScope(session: session, child: home);
    // fst:auth:end

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );
    await tester.pumpAndSettle();
  }

  // fst:auth:start
  testWidgets('header shows the signed-in user identity', (tester) async {
    await pumpProfile(tester);

    expect(find.text(testUser.username), findsOneWidget); // 'alice'
    expect(find.text(testUser.id), findsOneWidget); // 'user-1'
  });
  // fst:auth:end

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

  // fst:auth:start
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
  // fst:auth:end
}
