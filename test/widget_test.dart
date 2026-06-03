import 'dart:async';

import 'package:architecture/architecture.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter_template/app/app.dart';
import 'package:flutter_starter_template/app/di/injection.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/services/bookmarks_sync_controller.dart';
import 'package:flutter_starter_template/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_starter_template/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:flutter_starter_template/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter_starter_template/shared/domain/bookmark_stats.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage/storage.dart';
import 'package:theme/theme.dart';

import 'test_utils.dart';

void main() {
  late StreamController<BookmarksSyncStatus> syncStatusController;
  late MockBookmarksSyncController sync;
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

    syncStatusController = StreamController<BookmarksSyncStatus>.broadcast();
    sync = MockBookmarksSyncController();
    when(
      () => sync.statusStream,
    ).thenAnswer((_) => syncStatusController.stream);
    when(() => sync.statusNow).thenReturn(BookmarksSyncStatus.idle);
    when(() => sync.start()).thenAnswer((_) async {});
    when(() => sync.stop()).thenAnswer((_) async {});
    when(() => sync.sync()).thenAnswer((_) async {});

    final bookmarkStats = MockBookmarkStatsReader();
    when(
      bookmarkStats.call,
    ).thenAnswer((_) async => const Ok(BookmarkStats()));

    authBloc = AuthBloc(
      signIn: signIn,
      register: MockRegister(),
      signOut: signOut,
      restoreSession: restoreSession,
      analytics: analytics,
    );
    themeBloc = ThemeBloc(await SharedPreferences.getInstance(), analytics);

    getIt.registerFactory<HomeBloc>(() {
      final bloc = HomeBloc(bookmarkStats);
      homeBloc = bloc;
      return bloc;
    });

    final notificationsBloc = MockNotificationsBloc();
    when(() => notificationsBloc.state).thenReturn(const NotificationsState());
    getIt.registerFactory<NotificationsBloc>(() => notificationsBloc);
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

  testWidgets('signs in and lands on home screen', (tester) async {
    await tester.pumpWidget(
      App(
        authBloc: authBloc,
        themeBloc: themeBloc,
        bookmarksSync: sync,
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
}
