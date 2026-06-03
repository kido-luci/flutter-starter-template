import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  const destinations = [
    AppDestination(icon: FontAwesomeIcons.house, label: 'Home'),
    AppDestination(icon: FontAwesomeIcons.circle, label: 'Settings'),
  ];

  Future<void> pumpAt(
    WidgetTester tester,
    double width, {
    ValueChanged<int>? onDestinationSelected,
  }) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: AppAdaptiveScaffold(
          destinations: destinations,
          selectedIndex: 0,
          onDestinationSelected: onDestinationSelected ?? (_) {},
          body: const Center(child: Text('body')),
        ),
      ),
    );
  }

  group('AppAdaptiveScaffold', () {
    testWidgets('compact width uses a floating bottom bar, not a rail', (
      tester,
    ) async {
      int? selected;
      await pumpAt(tester, 500, onDestinationSelected: (i) => selected = i);

      expect(find.byType(NavigationRail), findsNothing);
      // Compact navigation keeps labels in tooltips/semantics only.
      expect(find.text('Home'), findsNothing);
      expect(find.byTooltip('Home'), findsOneWidget);

      // Tapping another destination reports its index.
      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is FaIcon &&
              w.icon?.codePoint == FontAwesomeIcons.circle.codePoint,
        ),
      );
      expect(selected, 1);
    });

    testWidgets('medium width uses a collapsed NavigationRail', (tester) async {
      await pumpAt(tester, 700);

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isFalse);
    });

    testWidgets('expanded width uses an extended NavigationRail', (
      tester,
    ) async {
      await pumpAt(tester, 1000);

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isTrue);
    });
  });
}
