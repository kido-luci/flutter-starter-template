// Widget tests for the splash gate. `SplashScreen` restores the session and
// enforces a minimum display time, then hands control back to the host via
// `onRestored` exactly once. The host owns the routing decision, so these
// tests assert the gate's timing contract rather than any navigation.

import 'package:feature_splash/feature_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
// fst:auth:start
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
// fst:auth:end

void main() {
  // fst:auth:start
  late _RecordingSession session;

  setUp(() => session = _RecordingSession());
  // fst:auth:end

  // Kept session-free at the call site so the harness reads the same with and
  // without the auth pillar — only the SessionScope wrapper differs.
  Widget host(void Function(BuildContext context) onRestored) {
    Widget home = SplashScreen(onRestored: onRestored);
    // fst:auth:start
    home = SessionScope(session: session, child: home);
    // fst:auth:end
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }

  // fst:auth:start
  testWidgets('restores the session on the first frame', (tester) async {
    await tester.pumpWidget(host((_) {}));

    await tester.pump(); // fire the post-frame callback → bootstrap
    expect(session.restoreCalls, 1);

    // Drain the minimum-display timer so no timer is left pending.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });
  // fst:auth:end

  testWidgets('calls onRestored only after the minimum display time', (
    tester,
  ) async {
    var restoredCalls = 0;
    await tester.pumpWidget(host((_) => restoredCalls++));

    await tester.pump(); // start bootstrap
    await tester.pump(const Duration(milliseconds: 1900)); // just before 2s
    expect(restoredCalls, 0);

    await tester.pump(const Duration(milliseconds: 200)); // cross the 2s gate
    await tester.pump(); // flush the Future.wait continuation
    expect(restoredCalls, 1);
  });

  testWidgets('shows the splash content while bootstrapping', (tester) async {
    await tester.pumpWidget(host((_) {}));
    await tester.pump();

    expect(find.byType(SplashContent), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });
}
