import 'package:architecture/architecture.dart';
// fst:auth:start
import 'package:checks/checks.dart';
import 'package:feature_auth/src/presentation/bloc/auth_bloc.dart';
import 'package:feature_auth/src/presentation/bloc/auth_state.dart';
// fst:auth:end
import 'package:feature_home/feature_home.dart';
// fst:feature:notifications:start
import 'package:feature_notifications/feature_notifications.dart';
// fst:feature:notifications:end
// fst:auth:start
import 'package:flutter/material.dart';
import 'package:flutter_starter_template/app/app.dart';
// fst:auth:end
import 'package:flutter_starter_template/app/di/injection.dart';
// fst:auth:start
import 'package:flutter_starter_template/app/feature_module.dart';
// fst:auth:end
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:storage/storage.dart';
import 'package:theme/theme.dart';

import 'test_utils.dart';

// fst:auth:start
final class _NoOpSyncModule extends FeatureModule {
  @override
  FeatureSyncController get syncController => _NoOpSync();
}

final class _NoOpSync implements FeatureSyncController {
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
}
// fst:auth:end

void main() {
  late MockAnalyticsService analytics;
  // fst:auth:start
  late AuthBloc authBloc;
  // fst:auth:end
  late ThemeBloc themeBloc;
  HomeBloc? homeBloc;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    analytics = MockAnalyticsService();
    stubAnalyticsService(analytics);

    // fst:auth:start
    final signIn = MockSignIn();
    when(() => signIn((username: 'alice', password: 'hunter2'))).thenAnswer((
      _,
    ) async {
      return const Ok(testUser);
    });

    final restoreSession = MockRestoreSession();
    when(
      restoreSession.call,
    ).thenAnswer((_) async => const Err(testFailure));

    final signOut = MockSignOut();
    when(signOut.call).thenAnswer((_) async => const Ok(null));
    // fst:auth:end

    final bookmarkStats = MockBookmarkStatsReader();
    when(
      bookmarkStats.call,
    ).thenAnswer((_) async => const Ok(BookmarkStats()));

    final collectionsReader = MockCollectionsReader();
    when(
      collectionsReader.call,
    ).thenAnswer((_) async => const Ok<List<CollectionSummary>>([]));

    // fst:auth:start
    authBloc = AuthBloc(
      signIn: signIn,
      register: MockRegister(),
      signOut: signOut,
      restoreSession: restoreSession,
      analytics: analytics,
    );
    // fst:auth:end
    themeBloc = ThemeBloc(await SharedPreferences.getInstance(), analytics);

    getIt.registerFactory<HomeBloc>(() {
      final bloc = HomeBloc(bookmarkStats, collectionsReader);
      homeBloc = bloc;
      return bloc;
    });

    // fst:feature:notifications:start
    final notificationsBloc = MockNotificationsBloc();
    when(() => notificationsBloc.state).thenReturn(const NotificationsState());
    getIt.registerFactory<NotificationsBloc>(() => notificationsBloc);
    // fst:feature:notifications:end
  });

  tearDown(() async {
    await getIt.reset();
    final bloc = homeBloc;
    if (bloc != null && !bloc.isClosed) {
      await bloc.close();
    }
    await themeBloc.close();
    // fst:auth:start
    await authBloc.close();
    // fst:auth:end
  });

  // fst:auth:start
  testWidgets('signs in and lands on home screen', (tester) async {
    await tester.pumpWidget(
      App(
        authBloc: authBloc,
        themeBloc: themeBloc,
        features: [_NoOpSyncModule(), _NoOpSyncModule(), _NoOpSyncModule()],
        navigatorObservers: const [],
        videoPlayerService: MockVideoPlayerService(),
      ),
    );
    await tester.pump();
    await tester.idle();
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump(const Duration(seconds: 3));
    await tester.idle();
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();
    for (var i = 0; i < 40 && find.text('Log In').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    check(find.text('Log In').evaluate()).isNotEmpty();

    await tester.enterText(find.byType(TextFormField).at(0), 'alice');
    await tester.enterText(find.byType(TextFormField).at(1), 'hunter2');

    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
    for (var i = 0; i < 20 && find.text('Home').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Home')),
      findsOneWidget,
    );
    expect(homeBloc, isNotNull);
    expect(authBloc.state, isA<AuthAuthenticated>());
    expect(
      (authBloc.state as AuthAuthenticated).user.username,
      'alice',
    );
  });
  // fst:auth:end
}
