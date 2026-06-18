// Widget tests for the splash gate. `SplashScreen` restores the session and
// enforces a minimum display time, then hands control back to the host via
// `onRestored` exactly once. The host owns the routing decision, so these
// tests assert the gate's timing contract rather than any navigation.

import 'package:feature_splash/feature_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:test_utils/test_utils.dart';

/// A [FakeSession] that records how many times [restore] was called.
class _RecordingSession extends FakeSession {
  int restoreCalls = 0;

  @override
  Future<void> restore() async {
    restoreCalls++;
  }
}

void main() {
  Widget host(
    _RecordingSession session,
    void Function(BuildContext context) onRestored,
  ) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SessionScope(
        session: session,
        child: SplashScreen(onRestored: onRestored),
      ),
    );
  }

  testWidgets('restores the session on the first frame', (tester) async {
    final session = _RecordingSession();
    await tester.pumpWidget(host(session, (_) {}));

    await tester.pump(); // fire the post-frame callback → bootstrap
    expect(session.restoreCalls, 1);

    // Drain the minimum-display timer so no timer is left pending.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });

  testWidgets('calls onRestored only after the minimum display time', (
    tester,
  ) async {
    final session = _RecordingSession();
    var restoredCalls = 0;
    await tester.pumpWidget(host(session, (_) => restoredCalls++));

    await tester.pump(); // start bootstrap
    await tester.pump(const Duration(milliseconds: 1900)); // just before 2s
    expect(restoredCalls, 0);

    await tester.pump(const Duration(milliseconds: 200)); // cross the 2s gate
    await tester.pump(); // flush the Future.wait continuation
    expect(restoredCalls, 1);
  });

  testWidgets('shows the splash content while bootstrapping', (tester) async {
    final session = _RecordingSession();
    await tester.pumpWidget(host(session, (_) {}));
    await tester.pump();

    expect(find.byType(SplashContent), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });
}
