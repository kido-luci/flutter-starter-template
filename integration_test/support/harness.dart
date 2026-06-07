/// Shared integration-test harness.
///
/// Each integration test creates an `AppHarness`, calls `setUp()` in its own
/// `setUp` callback, drives the UI with `pumpApp`/`signInToHome`, then calls
/// `tearDown()` to clean up. Feature tests register additional blocs in
/// `getIt` after `setUp()` and before pumping, then call `trackDispose` so
/// those blocs are closed at the end of the test.
library;

import 'dart:async';

import 'package:architecture/architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter_template/app/app.dart';
import 'package:flutter_starter_template/app/di/injection.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/services/bookmarks_sync_controller.dart';
import 'package:flutter_starter_template/features/collections/domain/services/collections_sync_controller.dart';
import 'package:flutter_starter_template/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_starter_template/features/notifications/domain/entities/notifications_feed.dart';
import 'package:flutter_starter_template/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:flutter_starter_template/shared/domain/bookmark_stats.dart';
import 'package:flutter_starter_template/shared/domain/collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:storage/storage.dart';
import 'package:theme/theme.dart';

import '../../test/test_utils.dart';

/// Boots the real assembled `App` for integration tests without a backend,
/// Firebase, or native storage.
///
/// Usage:
/// ```dart
/// late AppHarness harness;
/// setUp(() async {
///   harness = AppHarness();
///   await harness.setUp();
///   // Register feature-specific blocs here …
/// });
/// tearDown(harness.tearDown);
/// ```
class AppHarness {
  // Core auth / sync mocks — always needed.
  late StreamController<BookmarksSyncStatus> _bookmarksSyncStatusCtrl;
  late MockBookmarksSyncController bookmarksSync;
  late MockCollectionsSyncController collectionsSync;
  late MockNotificationsSyncController notificationsSync;
  late MockAnalyticsService analytics;
  late MockSignIn signIn;
  late MockRegister register;
  late MockSignOut signOut;
  late MockRestoreSession restoreSession;
  late AuthBloc authBloc;
  late ThemeBloc themeBloc;

  // Exposed so the collections test can re-stub the home screen's "Featured
  // Collections" reader to a non-empty list (its "View all" action is the
  // route into `/collections` — only rendered when the list isn't empty).
  late MockCollectionsReader collectionsReader;

  // Exposed so notification tests can re-stub before pumping the app.
  late MockGetNotificationsFeed getFeed;
  late MockGetNotificationsFeedLocal getFeedLocal;
  late MockMarkNotificationRead markRead;

  final List<Future<void> Function()> _disposeCallbacks = [];

  /// Initialise all mocks and register the always-needed [HomeBloc] and
  /// [NotificationsBloc] factories in [getIt].
  Future<void> setUp() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});

    // Stub PackageInfo so ProfileBloc.onLoaded doesn't hit a real channel.
    PackageInfo.setMockInitialValues(
      appName: 'FlutterStarterTemplate',
      packageName: 'com.example.flutterstarter',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );

    // — analytics —
    analytics = MockAnalyticsService();
    stubAnalyticsService(analytics);

    // — auth use-cases —
    signIn = MockSignIn();
    when(
      () => signIn((username: 'alice', password: 'hunter2')),
    ).thenAnswer((_) async => const Ok(testUser));

    restoreSession = MockRestoreSession();
    when(
      restoreSession.call,
    ).thenAnswer((_) async => const Err(testFailure));

    signOut = MockSignOut();
    when(signOut.call).thenAnswer((_) async => const Ok(null));

    register = MockRegister();

    // — bookmarks sync —
    _bookmarksSyncStatusCtrl =
        StreamController<BookmarksSyncStatus>.broadcast();
    bookmarksSync = MockBookmarksSyncController();
    when(
      () => bookmarksSync.statusStream,
    ).thenAnswer((_) => _bookmarksSyncStatusCtrl.stream);
    when(() => bookmarksSync.statusNow).thenReturn(BookmarksSyncStatus.idle);
    when(() => bookmarksSync.start()).thenAnswer((_) async {});
    when(() => bookmarksSync.stop()).thenAnswer((_) async {});
    when(() => bookmarksSync.sync()).thenAnswer((_) async {});

    // — collections sync —
    collectionsSync = MockCollectionsSyncController();
    when(
      () => collectionsSync.statusStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => collectionsSync.statusNow,
    ).thenReturn(CollectionsSyncStatus.idle);
    when(() => collectionsSync.start()).thenAnswer((_) async {});
    when(() => collectionsSync.stop()).thenAnswer((_) async {});
    when(() => collectionsSync.sync()).thenAnswer((_) async {});

    // — notifications sync —
    notificationsSync = MockNotificationsSyncController();
    when(
      () => notificationsSync.onSynced,
    ).thenAnswer((_) => const Stream.empty());
    when(() => notificationsSync.start()).thenAnswer((_) async {});
    when(() => notificationsSync.stop()).thenAnswer((_) async {});
    when(() => notificationsSync.sync()).thenAnswer((_) async {});

    // — blocs that drive the app shell —
    authBloc = AuthBloc(
      signIn: signIn,
      register: register,
      signOut: signOut,
      restoreSession: restoreSession,
      analytics: analytics,
    );
    themeBloc = ThemeBloc(await SharedPreferences.getInstance(), analytics);

    // — HomeBloc (home screen) —
    final bookmarkStats = MockBookmarkStatsReader();
    when(
      bookmarkStats.call,
    ).thenAnswer((_) async => const Ok(BookmarkStats()));
    collectionsReader = MockCollectionsReader();
    when(collectionsReader.call).thenAnswer(
      (_) async => const Ok<List<CollectionSummary>>([]),
    );
    getIt.registerFactory<HomeBloc>(() {
      final bloc = HomeBloc(bookmarkStats, collectionsReader);
      trackDispose(() async {
        if (!bloc.isClosed) await bloc.close();
      });
      return bloc;
    });

    // — NotificationsBloc (AppShell + NotificationsScreen) —
    // Exposed as fields so tests can re-stub before pumping the app.
    getFeed = MockGetNotificationsFeed();
    when(
      getFeed.call,
    ).thenAnswer((_) async => const Ok(NotificationsFeed.empty));

    getFeedLocal = MockGetNotificationsFeedLocal();
    when(
      getFeedLocal.call,
    ).thenAnswer((_) async => const Ok(NotificationsFeed.empty));

    markRead = MockMarkNotificationRead();
    when(
      () => markRead(any()),
    ).thenAnswer((_) async => const Ok<void>(null));

    final activityNotifier = MockActivityNotifier();
    when(
      () => activityNotifier.onActivityOccurred,
    ).thenAnswer((_) => const Stream.empty());

    getIt.registerLazySingleton<NotificationsBloc>(() {
      final bloc = NotificationsBloc(
        getFeed,
        getFeedLocal,
        markRead,
        activityNotifier,
        notificationsSync,
      );
      trackDispose(() async {
        if (!bloc.isClosed) await bloc.close();
      });
      return bloc;
    });
  }

  /// Register a dispose [callback] to be invoked during [tearDown].
  void trackDispose(Future<void> Function() callback) {
    _disposeCallbacks.add(callback);
  }

  /// Pumps the real [App] widget tree with all overrides wired.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      App(
        authBloc: authBloc,
        themeBloc: themeBloc,
        bookmarksSync: bookmarksSync,
        collectionsSync: collectionsSync,
        notificationsSync: notificationsSync,
        navigatorObservers: const [],
        videoPlayerService: MockVideoPlayerService(),
      ),
    );
  }

  /// Pumps a microtask + frame so async events flush without blocking.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();
  }

  /// Pumps [interval] frames until [finder] is non-empty or [maxTries] is hit.
  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    int maxTries = 40,
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    for (var i = 0; i < maxTries && finder.evaluate().isEmpty; i++) {
      await tester.pump(interval);
    }
  }

  /// Pumps the app, waits through splash, signs in as `alice`, and asserts
  /// the home screen is reached.
  Future<void> signInToHome(WidgetTester tester) async {
    await pumpApp(tester);
    await tester.pump();
    await settle(tester);
    // runAsync steps outside TestAsyncUtils.guard so real Dart timers fire,
    // including the splash screen's 2-second minimum-display guard.
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(seconds: 3)),
    );
    await settle(tester);

    await pumpUntil(tester, find.text('Welcome Back'));
    expect(find.text('Welcome Back'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'alice');
    await tester.enterText(find.byType(TextFormField).at(1), 'hunter2');
    await tester.tap(find.text('Log In'));
    await settle(tester);
    await tester.pumpAndSettle();
    await pumpUntil(tester, find.text('Home'));

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Home')),
      findsOneWidget,
    );
  }

  /// Closes all registered blocs and resets [getIt].
  Future<void> tearDown() async {
    for (final dispose in _disposeCallbacks) {
      await dispose();
    }
    _disposeCallbacks.clear();
    await themeBloc.close();
    await authBloc.close();
    await _bookmarksSyncStatusCtrl.close();
    await getIt.reset();
  }
}
