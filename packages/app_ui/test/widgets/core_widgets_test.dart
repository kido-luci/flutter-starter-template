import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget materialApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('AppLoading', () {
    // `AppLoading` wraps its content in a fade-in entrance animation and
    // hosts a perpetually-animating `CircularProgressIndicator`, so settle
    // only the entrance (via a single pump past its duration) rather than
    // `pumpAndSettle`, which would never terminate.
    testWidgets('renders a CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(materialApp(const AppLoading()));
      await tester.pump(AppDurations.fast);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('shows label when provided', (tester) async {
      await tester.pumpWidget(
        materialApp(const AppLoading(label: 'Loading...')),
      );
      await tester.pump(AppDurations.fast);

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('uses custom size', (tester) async {
      await tester.pumpWidget(materialApp(const AppLoading(size: 48)));
      await tester.pump(AppDurations.fast);

      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(spinner.strokeWidth, 3);
    });
  });

  group('AppEmptyView', () {
    testWidgets('renders message and default icon', (tester) async {
      await tester.pumpWidget(
        materialApp(const AppEmptyView(message: 'Nothing here')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nothing here'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is FaIcon &&
              w.icon?.codePoint == FontAwesomeIcons.inbox.codePoint,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders title when provided', (tester) async {
      await tester.pumpWidget(
        materialApp(const AppEmptyView(message: 'Empty', title: 'No Data')),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Data'), findsOneWidget);
      expect(find.text('Empty'), findsOneWidget);
    });

    testWidgets('renders custom icon', (tester) async {
      await tester.pumpWidget(
        materialApp(
          const AppEmptyView(
            message: 'Empty',
            icon: FontAwesomeIcons.magnifyingGlassMinus,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is FaIcon &&
              w.icon?.codePoint ==
                  FontAwesomeIcons.magnifyingGlassMinus.codePoint,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders action widget when provided', (tester) async {
      await tester.pumpWidget(
        materialApp(
          AppEmptyView(
            message: 'Empty',
            action: ElevatedButton(onPressed: () {}, child: const Text('Add')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add'), findsOneWidget);
    });
  });

  group('AppErrorView', () {
    testWidgets('renders message and default icon', (tester) async {
      await tester.pumpWidget(materialApp(const AppErrorView(message: 'Oops')));
      await tester.pumpAndSettle();

      expect(find.text('Oops'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is FaIcon &&
              w.icon?.codePoint == FontAwesomeIcons.circleExclamation.codePoint,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders title when provided', (tester) async {
      await tester.pumpWidget(
        materialApp(const AppErrorView(message: 'Oops', title: 'Error')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Oops'), findsOneWidget);
    });

    testWidgets('renders retry button when onRetry is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        materialApp(AppErrorView(message: 'Oops', onRetry: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is FaIcon &&
              w.icon?.codePoint == FontAwesomeIcons.rotateRight.codePoint,
        ),
        findsOneWidget,
      );
    });

    testWidgets('retry callback fires on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        materialApp(
          AppErrorView(message: 'Oops', onRetry: () => tapped = true),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      expect(tapped, isTrue);
    });

    testWidgets('uses custom retry label', (tester) async {
      await tester.pumpWidget(
        materialApp(
          AppErrorView(
            message: 'Oops',
            onRetry: () {},
            retryLabel: 'Try Again',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Try Again'), findsOneWidget);
    });
  });

  group('AppScaffold', () {
    testWidgets('renders body inside SafeArea with padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppScaffold(body: Text('Content'))),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('renders AppBar when title is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(title: 'Test Screen', body: Text('Content')),
        ),
      );

      expect(find.text('Test Screen'), findsOneWidget);
    });

    testWidgets('renders custom appBar when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppScaffold(
            appBar: AppBar(title: const Text('Custom')),
            body: const Text('Content'),
          ),
        ),
      );

      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('shows loading overlay when isLoading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(body: Text('Content'), isLoading: true),
        ),
      );
      // `AppScaffold`'s loading overlay hosts an `AppLoading` (perpetually
      // animating spinner), so pump past the entrance/switcher animations
      // rather than `pumpAndSettle`, which would never terminate.
      await tester.pump(AppDurations.medium);
      await tester.pump(AppDurations.fast);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders floating action button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppScaffold(
            body: const Text('Content'),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const FaIcon(FontAwesomeIcons.plus),
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('AppSlidable', () {
    testWidgets('renders child and end action', (tester) async {
      await tester.pumpWidget(
        materialApp(
          const AppSlidable(
            endActions: [AppSlidableAction.delete(onPressed: null)],
            child: ListTile(title: Text('Bookmark')),
          ),
        ),
      );

      expect(find.text('Bookmark'), findsOneWidget);
      expect(find.byType(Slidable), findsOneWidget);

      await tester.drag(find.text('Bookmark'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.byType(CustomSlidableAction), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is FaIcon &&
              w.icon?.codePoint == FontAwesomeIcons.trashCan.codePoint,
        ),
        findsOneWidget,
      );
    });

    testWidgets('fires action callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        materialApp(
          AppSlidable(
            endActions: [
              AppSlidableAction.delete(onPressed: (_) => tapped = true),
            ],
            child: const ListTile(title: Text('Bookmark')),
          ),
        ),
      );

      await tester.drag(find.text('Bookmark'), const Offset(-300, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CustomSlidableAction));

      expect(tapped, isTrue);
    });
  });

  group('AppTextField', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        materialApp(const AppTextField(label: 'Username')),
      );

      expect(find.text('Username'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('renders hint text', (tester) async {
      await tester.pumpWidget(
        materialApp(const AppTextField(hint: 'Enter name')),
      );

      expect(find.text('Enter name'), findsOneWidget);
    });

    testWidgets('renders prefix icon', (tester) async {
      await tester.pumpWidget(
        materialApp(
          const AppTextField(
            label: 'Email',
            prefixIcon: FontAwesomeIcons.circle,
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is FaIcon &&
              w.icon?.codePoint == FontAwesomeIcons.circle.codePoint,
        ),
        findsOneWidget,
      );
    });

    testWidgets('accepts text input', (tester) async {
      await tester.pumpWidget(materialApp(const AppTextField()));

      await tester.enterText(find.byType(TextFormField), 'hello');
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('displays error text', (tester) async {
      await tester.pumpWidget(
        materialApp(const AppTextField(errorText: 'Required field')),
      );

      expect(find.text('Required field'), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      var changedValue = '';
      await tester.pumpWidget(
        materialApp(AppTextField(onChanged: (v) => changedValue = v)),
      );

      await tester.enterText(find.byType(TextFormField), 'test');
      expect(changedValue, 'test');
    });

    testWidgets('is disabled when enabled is false', (tester) async {
      await tester.pumpWidget(materialApp(const AppTextField(enabled: false)));

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.enabled, isFalse);
    });
  });

  group('AppButton', () {
    group('primary variant', () {
      testWidgets('renders label', (tester) async {
        await tester.pumpWidget(
          materialApp(AppButton(label: 'Save', onPressed: () {})),
        );

        expect(find.text('Save'), findsOneWidget);
        expect(find.byType(FilledButton), findsOneWidget);
      });

      testWidgets('fires onPressed callback', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          materialApp(AppButton(label: 'Save', onPressed: () => tapped = true)),
        );

        await tester.tap(find.text('Save'));
        expect(tapped, isTrue);
      });

      testWidgets('shows CircularProgressIndicator when loading', (
        tester,
      ) async {
        await tester.pumpWidget(
          materialApp(
            const AppButton(label: 'Save', onPressed: null, isLoading: true),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('renders icon button when icon provided', (tester) async {
        await tester.pumpWidget(
          materialApp(
            AppButton(
              label: 'Save',
              onPressed: () {},
              icon: FontAwesomeIcons.circle,
            ),
          ),
        );

        expect(
          find.byWidgetPredicate(
            (w) =>
                w is FaIcon &&
                w.icon?.codePoint == FontAwesomeIcons.circle.codePoint,
          ),
          findsOneWidget,
        );
        expect(find.text('Save'), findsOneWidget);
      });

      testWidgets('does nothing when onPressed is null', (tester) async {
        await tester.pumpWidget(
          materialApp(const AppButton(label: 'Save', onPressed: null)),
        );

        // Button should render but be disabled
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNull);
      });
    });

    group('tonal variant', () {
      testWidgets('renders FilledButton.tonal', (tester) async {
        await tester.pumpWidget(
          materialApp(
            AppButton(
              label: 'Cancel',
              onPressed: () {},
              variant: AppButtonVariant.tonal,
            ),
          ),
        );

        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('renders FilledButton.tonalIcon when icon provided', (
        tester,
      ) async {
        await tester.pumpWidget(
          materialApp(
            AppButton(
              label: 'Close',
              onPressed: () {},
              variant: AppButtonVariant.tonal,
              icon: FontAwesomeIcons.xmark,
            ),
          ),
        );

        expect(
          find.byWidgetPredicate(
            (w) =>
                w is FaIcon &&
                w.icon?.codePoint == FontAwesomeIcons.xmark.codePoint,
          ),
          findsOneWidget,
        );
      });
    });

    group('outlined variant', () {
      testWidgets('renders OutlinedButton', (tester) async {
        await tester.pumpWidget(
          materialApp(
            AppButton(
              label: 'Back',
              onPressed: () {},
              variant: AppButtonVariant.outlined,
            ),
          ),
        );

        expect(find.byType(OutlinedButton), findsOneWidget);
      });
    });

    group('text variant', () {
      testWidgets('renders TextButton', (tester) async {
        await tester.pumpWidget(
          materialApp(
            AppButton(
              label: 'Skip',
              onPressed: () {},
              variant: AppButtonVariant.text,
            ),
          ),
        );

        expect(find.byType(TextButton), findsOneWidget);
      });
    });

    group('size', () {
      testWidgets('small size', (tester) async {
        await tester.pumpWidget(
          materialApp(
            AppButton(
              label: 'Small',
              onPressed: () {},
              size: AppButtonSize.small,
            ),
          ),
        );

        expect(find.text('Small'), findsOneWidget);
      });

      testWidgets('large size', (tester) async {
        await tester.pumpWidget(
          materialApp(
            AppButton(
              label: 'Large',
              onPressed: () {},
              size: AppButtonSize.large,
            ),
          ),
        );

        expect(find.text('Large'), findsOneWidget);
      });
    });

    testWidgets('expand fills width', (tester) async {
      await tester.pumpWidget(
        materialApp(AppButton(label: 'Full', onPressed: () {}, expand: true)),
      );

      final button = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(button.width, double.infinity);
    });
  });
}
