import 'dart:async';

import 'package:architecture/architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter_template/app/app.dart';
import 'package:flutter_starter_template/app/di/injection.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/services/bookmarks_sync_controller.dart';
import 'package:flutter_starter_template/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_starter_template/shared/domain/bookmark_stats.dart';
import 'package:flutter_starter_template/shared/domain/collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:storage/storage.dart';
import 'package:theme/theme.dart';

// Reuse the unit/widget test fakes so the integration test exercises the real
// assembled App without a backend, Firebase, or native storage.
import '../test/test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late StreamController<BookmarksSyncStatus> syncStatusController;
  late MockBookmarksSyncController sync;
  late MockCollectionsSyncController collectionsSync;
  late MockNotificationsSyncController notificationsSync;
  late MockAnalyticsService analytics;
  late AuthBloc authBloc;
  late ThemeBloc themeBloc;
  HomeBloc? homeBloc;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    analytics = MockAnalyticsService();
    stubAnalyticsService(analytics);

    final signIn = MockSignIn();
    when(
      () => signIn((username: 'alice', password: 'hunter2')),
    ).thenAnswer((_) async => const Ok(testUser));

    final restoreSession = MockRestoreSession();
    when(
      restoreSession.call,
    ).thenAnswer((_) async => const Err(testFailure));

    final signOut = MockSignOut();
    when(signOut.call).thenAnswer((_) async => const Ok(null));

    syncStatusController = StreamController<BookmarksSyncStatus>.broadcast();
    sync = MockBookmarksSyncController();
    when(
      () => sync.statusStream,
    ).thenAnswer((_) => syncStatusController.stream);
    when(() => sync.statusNow).thenReturn(BookmarksSyncStatus.idle);
    when(() => sync.start()).thenAnswer((_) async {});
    when(() => sync.stop()).thenAnswer((_) async {});
    when(() => sync.sync()).thenAnswer((_) async {});

    collectionsSync = MockCollectionsSyncController();
    when(() => collectionsSync.start()).thenAnswer((_) async {});
    when(() => collectionsSync.stop()).thenAnswer((_) async {});
    when(() => collectionsSync.sync()).thenAnswer((_) async {});

    notificationsSync = MockNotificationsSyncController();
    when(
      () => notificationsSync.onSynced,
    ).thenAnswer((_) => const Stream.empty());
    when(() => notificationsSync.start()).thenAnswer((_) async {});
    when(() => notificationsSync.stop()).thenAnswer((_) async {});
    when(() => notificationsSync.sync()).thenAnswer((_) async {});

    final bookmarkStats = MockBookmarkStatsReader();
    when(
      bookmarkStats.call,
    ).thenAnswer((_) async => const Ok(BookmarkStats()));

    final collectionsReader = MockCollectionsReader();
    when(
      collectionsReader.call,
    ).thenAnswer((_) async => const Ok<List<CollectionSummary>>([]));

    authBloc = AuthBloc(
      signIn: signIn,
      register: MockRegister(),
      signOut: signOut,
      restoreSession: restoreSession,
      analytics: analytics,
    );
    themeBloc = ThemeBloc(await SharedPreferences.getInstance(), analytics);

    getIt.registerFactory<HomeBloc>(() {
      final bloc = HomeBloc(bookmarkStats, collectionsReader);
      homeBloc = bloc;
      return bloc;
    });
  });

  tearDown(() async {
    await getIt.reset();
    final bloc = homeBloc;
    if (bloc != null && !bloc.isClosed) {
      await bloc.close();
    }
    await themeBloc.close();
    await authBloc.close();
    await syncStatusController.close();
  });

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();
  }

  testWidgets('end-to-end: unauthenticated user signs in and reaches home', (
    tester,
  ) async {
    await tester.pumpWidget(
      App(
        authBloc: authBloc,
        themeBloc: themeBloc,
        bookmarksSync: sync,
        collectionsSync: collectionsSync,
        notificationsSync: notificationsSync,
        navigatorObservers: const [],
        videoPlayerService: MockVideoPlayerService(),
      ),
    );

    // Splash gates routing on session restoration; wait for the login screen.
    await tester.pump();
    await settle(tester);
    await tester.pump(const Duration(seconds: 3));
    await settle(tester);
    for (var i = 0; i < 40 && find.text('Sign in').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Sign in'), findsWidgets);

    // Fill credentials and submit.
    await tester.enterText(find.byType(TextFormField).at(0), 'alice');
    await tester.enterText(find.byType(TextFormField).at(1), 'hunter2');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await settle(tester);
    await tester.pumpAndSettle();
    for (var i = 0; i < 20 && find.text('Home').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Landed on the authenticated home screen.
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Home')),
      findsOneWidget,
    );
    expect(authBloc.state, isA<AuthAuthenticated>());
    expect((authBloc.state as AuthAuthenticated).user.username, 'alice');

    // Both sync controllers started for the now-authenticated session.
    verify(() => sync.start()).called(greaterThanOrEqualTo(1));
    verify(() => collectionsSync.start()).called(greaterThanOrEqualTo(1));
    verify(() => notificationsSync.start()).called(greaterThanOrEqualTo(1));
  });
}
