import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_starter_template/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_starter_template/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_starter_template/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../test_utils.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

Widget wrapWithDependencies(AuthBloc bloc) {
  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const RegisterScreen(),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
      ],
    ),
  );
}

void main() {
  late MockAuthBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(
      const AuthRegisterRequested(username: '', password: ''),
    );
  });

  setUp(() {
    mockBloc = MockAuthBloc();
    when(() => mockBloc.state).thenReturn(const AuthState.initial());
    when(
      () => mockBloc.stream,
    ).thenAnswer((_) => Stream.value(const AuthState.initial()));
    when(() => mockBloc.add(any())).thenReturn(null);
  });

  group('RegisterScreen', () {
    testWidgets('renders register form fields', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Flutter Starter'), findsOneWidget);
      expect(find.text('Join Flutter Starter'), findsAtLeast(1));
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Must be at least 8 characters.'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pump(const Duration(seconds: 1));

      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Join Flutter Starter'),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Join Flutter Starter'),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Required'), findsAtLeast(1));
    });

    testWidgets('shows validation error for short password', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'jane@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'short');
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Join Flutter Starter'),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Join Flutter Starter'),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Password must be at least 8 characters.'),
        findsOneWidget,
      );
      verifyNever(() => mockBloc.add(any()));
    });

    testWidgets('shows validation error for malformed email', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Join Flutter Starter'),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Join Flutter Starter'),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      verifyNever(() => mockBloc.add(any()));
    });

    testWidgets('calls register with entered credentials', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'jane@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Join Flutter Starter'),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Join Flutter Starter'),
      );
      await tester.pump(const Duration(milliseconds: 100));

      verify(
        () => mockBloc.add(
          any(
            that: isA<AuthRegisterRequested>()
                .having(
                  (event) => event.username,
                  'username',
                  'jane@example.com',
                )
                .having(
                  (event) => event.password,
                  'password',
                  'password123',
                ),
          ),
        ),
      ).called(1);
    });

    testWidgets('does not submit again while already submitting', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(const AuthState.submitting());
      when(
        () => mockBloc.stream,
      ).thenAnswer((_) => Stream.value(const AuthState.submitting()));

      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'jane@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 100));

      verifyNever(() => mockBloc.add(any()));
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pump(const Duration(seconds: 1));

      expect(
        tester.widget<EditableText>(find.byType(EditableText).last).obscureText,
        isTrue,
      );

      await tester.ensureVisible(find.byTooltip('Show password'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();

      expect(find.byTooltip('Hide password'), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText).last).obscureText,
        isFalse,
      );
    });

    testWidgets('shows error message on auth failure', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(const AuthState.failure(testFailure));
      when(
        () => mockBloc.stream,
      ).thenAnswer((_) => Stream.value(const AuthState.failure(testFailure)));

      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Something went wrong.'), findsOneWidget);
    });
  });
}
