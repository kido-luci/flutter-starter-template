import 'package:architecture/architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/test_utils.dart';
import 'support/harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppHarness harness;

  setUp(() async {
    harness = AppHarness();
    await harness.setUp();
  });

  tearDown(() => harness.tearDown());

  group('auth — login failure', () {
    testWidgets('shows error message and stays on login screen', (
      tester,
    ) async {
      // The harness stubs signIn only for alice/hunter2. Stub a second set of
      // credentials that returns a failure.
      when(
        () => harness.signIn((username: 'baduser', password: 'badpass')),
      ).thenAnswer((_) async => const Err(testFailure));

      await harness.pumpApp(tester);
      await tester.pump();
      await harness.settle(tester);
      // runAsync lets real Dart timers fire (the splash 2-second guard).
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(seconds: 3)),
      );
      await harness.settle(tester);
      await harness.pumpUntil(tester, find.text('Welcome Back'));
      expect(find.text('Welcome Back'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'baduser');
      await tester.enterText(find.byType(TextFormField).at(1), 'badpass');
      await tester.tap(find.text('Log In'));
      await harness.settle(tester);
      await tester.pumpAndSettle();

      // Still on the login screen.
      expect(find.text('Welcome Back'), findsOneWidget);
      // AuthBloc failure routes unknown failures to l10n.errorUnknown.
      expect(find.text('Something went wrong.'), findsOneWidget);
    });
  });

  group('auth — register navigation', () {
    testWidgets('Login → Register screen is reachable', (tester) async {
      await harness.pumpApp(tester);
      await tester.pump();
      await harness.settle(tester);
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(seconds: 3)),
      );
      await harness.settle(tester);
      await harness.pumpUntil(tester, find.text('Welcome Back'));

      // Tap "Create an account" to navigate to Register.
      await tester.tap(find.text('Create an account'));
      await tester.pumpAndSettle();
      // Register screen shows headline and submit button both labelled
      // "Join Flutter Starter"; the login screen shows "Welcome Back".
      await harness.pumpUntil(tester, find.text('Join Flutter Starter'));

      // Register screen is identified by its headline / submit button.
      expect(find.text('Join Flutter Starter'), findsWidgets);
    });
  });
}
