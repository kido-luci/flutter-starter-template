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

    // Override the default (empty) feed stubs so notifications are visible.
    when(
      harness.getFeed.call,
    ).thenAnswer((_) async => Ok(testNotificationFeed));
    when(
      harness.getFeedLocal.call,
    ).thenAnswer((_) async => Ok(testNotificationFeed));
  });

  tearDown(() => harness.tearDown());

  testWidgets(
    'notifications: tab shows notifications and activity sections',
    (tester) async {
      await harness.signInToHome(tester);

      // Tap the Notifications nav destination.
      await tester.tap(find.byTooltip('Notifications'));
      await tester.pumpAndSettle();
      await harness.pumpUntil(tester, find.text('Notifications'));

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Notifications'),
        ),
        findsOneWidget,
      );

      // Tab bar labels are present.
      expect(find.text('Notifications'), findsWidgets);
      expect(find.text('Your activity'), findsWidgets);
    },
  );

  testWidgets(
    'notifications: unread notification is shown in the feed',
    (tester) async {
      await harness.signInToHome(tester);

      await tester.tap(find.byTooltip('Notifications'));
      await tester.pumpAndSettle();

      await harness.pumpUntil(tester, find.text('New bookmark added'));
      expect(find.text('New bookmark added'), findsWidgets);
    },
  );

  testWidgets(
    'notifications: mark-read use-case called when tapping a notification',
    (tester) async {
      await harness.signInToHome(tester);

      await tester.tap(find.byTooltip('Notifications'));
      await tester.pumpAndSettle();
      await harness.pumpUntil(tester, find.text('New bookmark added'));
      verifyNever(() => harness.markRead(any()));

      // Tap the unread notification to mark it read.
      await tester.tap(find.text('New bookmark added').first);
      await harness.settle(tester);
      await tester.pumpAndSettle();

      // MarkNotificationRead was called exactly once, with the unread
      // notification's id, as a direct result of the tap above.
      verify(() => harness.markRead(testUnreadNotification.id)).called(1);
    },
  );
}
