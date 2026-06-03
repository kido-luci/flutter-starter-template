import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_starter_template/features/auth/presentation/screens/login_screen.dart';
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
            child: const LoginScreen(),
          ),
        ),
      ],
    ),
  );
}

void main() {
  late MockAuthBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(
      const AuthSignInRequested(username: '', password: ''),
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

  group('LoginScreen', () {
    testWidgets('renders login form fields', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Flutter Starter'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Create an account'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Required'), findsAtLeast(1));
    });

    testWidgets('calls signIn with entered credentials', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(find.byType(TextFormField).at(0), 'alice');
      await tester.enterText(find.byType(TextFormField).at(1), 'hunter2');
      await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
      await tester.pump(const Duration(milliseconds: 100));

      verify(
        () => mockBloc.add(
          any(
            that: isA<AuthSignInRequested>()
                .having((event) => event.username, 'username', 'alice')
                .having((event) => event.password, 'password', 'hunter2'),
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

      await tester.enterText(find.byType(TextFormField).at(0), 'alice');
      await tester.enterText(find.byType(TextFormField).at(1), 'hunter2');
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

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();

      expect(find.byTooltip('Hide password'), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText).last).obscureText,
        isFalse,
      );
    });

    testWidgets('shows unavailable message for forgot password action', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Forgot?'));
      await tester.pump();

      expect(
        find.text("Password recovery isn't configured yet."),
        findsOneWidget,
      );
      verifyNever(() => mockBloc.add(any()));
    });

    testWidgets('shows unavailable messages for social actions', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pump(const Duration(seconds: 1));

      await tester.ensureVisible(find.text('Google'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Google'));
      await tester.pump();

      expect(
        find.text("Social sign-in isn't configured yet."),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 4));
      await tester.ensureVisible(find.text('Apple'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple'));
      await tester.pump();

      expect(
        find.text("Social sign-in isn't configured yet."),
        findsOneWidget,
      );
      verifyNever(() => mockBloc.add(any()));
    });

    testWidgets('shows CircularProgressIndicator while submitting', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(const AuthState.submitting());
      when(
        () => mockBloc.stream,
      ).thenAnswer((_) => Stream.value(const AuthState.submitting()));

      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
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
