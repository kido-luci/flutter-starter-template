import 'package:architecture/architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter_template/app/di/injection.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/delete_account_cubit.dart';
import 'package:flutter_starter_template/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/test_utils.dart';
import 'support/harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppHarness harness;
  ProfileBloc? capturedProfileBloc;
  DeleteAccountCubit? capturedDeleteAccountCubit;

  setUp(() async {
    harness = AppHarness();
    await harness.setUp();

    // — ProfileBloc —
    // PackageInfo is pre-stubbed in AppHarness.setUp so the onLoaded handler
    // doesn't hit a real platform channel.
    getIt.registerFactory<ProfileBloc>(() {
      final bloc = ProfileBloc(harness.analytics);
      capturedProfileBloc = bloc;
      harness.trackDispose(() async {
        if (!bloc.isClosed) await bloc.close();
      });
      return bloc;
    });

    // — DeleteAccountCubit —
    final deleteAccount = MockDeleteAccount();
    when(
      deleteAccount.call,
    ).thenAnswer((_) async => const Ok<void>(null));

    getIt.registerFactory<DeleteAccountCubit>(() {
      final cubit = DeleteAccountCubit(deleteAccount, harness.analytics);
      capturedDeleteAccountCubit = cubit;
      harness.trackDispose(() async {
        if (!cubit.isClosed) await cubit.close();
      });
      return cubit;
    });
  });

  tearDown(() async {
    capturedProfileBloc = null;
    capturedDeleteAccountCubit = null;
    await harness.tearDown();
  });

  testWidgets(
    'profile: screen shows Appearance and Account sections',
    (tester) async {
      await harness.signInToHome(tester);

      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      await harness.pumpUntil(tester, find.text('Profile'));

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Profile'),
        ),
        findsOneWidget,
      );

      expect(find.text('Appearance'), findsWidgets);
      expect(find.text('Account'), findsWidgets);
      expect(capturedProfileBloc, isNotNull);
      expect(capturedDeleteAccountCubit, isNotNull);
    },
  );

  testWidgets(
    'profile: sign out triggers sync stop and returns to login',
    (tester) async {
      await harness.signInToHome(tester);

      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();

      // The "Sign out" button is the last item in the profile screen's
      // `ListView` and sits below the initial viewport — slivers only build
      // elements within (or near) the visible viewport, so it doesn't exist
      // in the tree until scrolled into view.
      await tester.scrollUntilVisible(find.text('Sign out'), 200);
      await tester.pumpAndSettle();

      // Even fully scrolled, the button sits directly under the shell's
      // floating bottom-nav pill (an overlay docked to the bottom of the
      // screen), so a coordinate-based `tester.tap` lands on the pill instead
      // — not a finder problem, but a real visual overlap at this viewport
      // size. Invoke the button's `onPressed` directly to drive the same
      // `_confirmSignOut` flow a tap would, bypassing hit-testing.
      // `find.ancestor` can't traverse from the label up to
      // `FilledButton.tonalIcon` here (its `_FilledButtonWithIconChild` wraps
      // the label in a `Flexible`), but it's the only `FilledButton` on this
      // screen (the rest of the profile actions use other `AppButton`
      // variants), so `byType` alone is unambiguous.
      final signOutButton = tester.widget<FilledButton>(
        find.byType(FilledButton),
      );
      signOutButton.onPressed!();
      await tester.pumpAndSettle();

      // Confirm sign out in the dialog.
      await tester.tap(find.widgetWithText(TextButton, 'Sign out'));
      await harness.settle(tester);
      await tester.pumpAndSettle();

      // Router should redirect to the login screen.
      await harness.pumpUntil(tester, find.text('Welcome Back'));
      expect(find.text('Welcome Back'), findsOneWidget);

      // Sync controllers stopped when session ended.
      verify(
        () => harness.bookmarksSync.stop(),
      ).called(greaterThanOrEqualTo(1));
      verify(
        () => harness.collectionsSync.stop(),
      ).called(greaterThanOrEqualTo(1));
      verify(
        () => harness.notificationsSync.stop(),
      ).called(greaterThanOrEqualTo(1));
    },
  );
}
