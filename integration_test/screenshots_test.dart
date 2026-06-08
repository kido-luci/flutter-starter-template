// Screenshot-capture run for the README, against the real local backend
// (`simple_backend_server`, http://localhost:8080 by default) with a
// pre-seeded demo user (`demo` / `demo1234`, 8 bookmarks, 2 collections).
//
// Unlike `e2e_test.dart`, this suite asserts almost nothing about business
// behaviour — it signs in and walks to eight representative screens, capturing
// each. By default the driver writes the bare app surface
// (`test_driver/integration_test.dart` persists the PNGs). When run with
// `--dart-define=WINDOW_CAPTURE=true` it instead emits a `WINDOW_SHOT:<name>`
// sentinel + dwell per screen, so an external host script can grab the whole
// Simulator *window* (device bezel included). The host script we use for the
// committed PNGs is a local, uncommitted helper (it needs macOS Screen
// Recording + `screencapture`); the default surface mode needs no such tool.
//
// The demo user's bookmarks/collections live only on the server (seeded via the
// API, not created through the app), so list screens wait for the offline-first
// background *pull* to land them locally. A pull only progresses under
// `tester.runAsync` (real wall-clock time, outside the fake-async guard), so
// the waits poll bloc state via [_pumpUntilTrue]. Home loads once and doesn't
// auto-refresh, so it's captured late with an explicit `HomeLoadRequested`.
//
// Run with:
// ```sh
// fvm flutter drive \
//   --driver=test_driver/integration_test.dart \
//   --target=integration_test/screenshots_test.dart \
//   --dart-define=API_BASE_URL=http://localhost:8080 \
//   -d <device-id>
// ```

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_template/app/router.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmarks_list/bookmarks_list_bloc.dart';
import 'package:flutter_starter_template/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:theme/theme.dart';

import 'support/e2e_app.dart';

// When true (`--dart-define=WINDOW_CAPTURE=true`), this run is being driven by
// an external host script that grabs the Simulator *window* (device bezel
// included). In that mode we must NOT write surface PNGs via
// the driver (`takeScreenshot`) — its asynchronous write races with, and
// clobbers, the host capture at the same path — nor convert the Flutter surface
// to an image (that freezes the live surface the window grab needs). We only
// emit the sentinel + dwell. Otherwise (the default) we capture the bare app
// surface through the driver as usual.
const _windowCapture = bool.fromEnvironment('WINDOW_CAPTURE');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(E2eApp.bootstrap);

  testWidgets('captures README screenshots as the seeded demo user', (
    tester,
  ) async {
    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      if (_windowCapture) {
        // Signal the external host capture script to grab the Simulator window
        // for this screen, then dwell so it can react before navigation moves on.
        debugPrint('WINDOW_SHOT:$name');
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(seconds: 6)),
        );
      } else {
        await binding.takeScreenshot(name);
      }
    }

    final homeTitle = _appBarTitle('Home');

    // ---- Sign in -----------------------------------------------------------
    await E2eApp.waitForLoginScreen(tester);

    // iOS needs the surface converted to an image before a driver
    // `takeScreenshot`; skip it in window-capture mode (it would freeze the
    // live surface the external window grab relies on).
    if (!kIsWeb && !_windowCapture) {
      await binding.convertFlutterSurfaceToImage();
    }
    await tester.pumpAndSettle();
    await shot('sign_in');

    // ---- Register (sample input, not submitted) ----------------------------
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(tester, find.text('Join Flutter Starter'));
    expect(find.text('Join Flutter Starter'), findsWidgets);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'jane@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'MyPassw0rd');
    await tester.pumpAndSettle();
    await shot('register');
    // Back to login without registering (the demo account already exists).
    const LoginRoute().go(
      tester.element(find.text('Join Flutter Starter').first),
    );
    await E2eApp.settle(tester);
    await tester.pumpAndSettle();

    // ---- Sign in as the seeded demo user -----------------------------------
    await E2eApp.pumpUntil(tester, find.text('Welcome Back'));
    await tester.enterText(find.byType(TextFormField).at(0), 'demo');
    await tester.enterText(find.byType(TextFormField).at(1), 'demo1234');
    await tester.tap(find.text('Log In'));
    await E2eApp.settle(tester);
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(tester, homeTitle);
    expect(homeTitle, findsOneWidget);

    // ---- Bookmarks ----------------------------------------------------------
    // Opening the list fires a background sync; the seeded rows appear only
    // once that pull lands them in the local store, so poll the bloc.
    await tester.tap(find.byTooltip('Bookmarks'));
    await tester.pumpAndSettle();
    final bookmarksTitle = _appBarTitle('Bookmarks');
    await E2eApp.pumpUntil(tester, bookmarksTitle);
    expect(bookmarksTitle, findsOneWidget);
    final bmBloc = tester.element(bookmarksTitle).read<BookmarksListBloc>();
    await _pumpUntilTrue(tester, () => bmBloc.state.items.isNotEmpty);
    expect(bmBloc.state.items, isNotEmpty);
    await shot('bookmarks');

    // ---- Create bookmark (sample input, not submitted) ---------------------
    await tester.tap(find.byTooltip('Add bookmark'), warnIfMissed: false);
    await tester.pumpAndSettle();
    // The form uses a custom header (not a standard AppBar), so match the
    // title as plain text rather than an AppBar descendant.
    final newBookmarkTitle = find.text('New bookmark');
    await E2eApp.pumpUntil(tester, newBookmarkTitle);
    expect(newBookmarkTitle, findsWidgets);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'https://www.anthropic.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Anthropic');
    await tester.pumpAndSettle();
    await shot('create_bookmark');
    GoRouter.of(tester.element(newBookmarkTitle.first)).pop();
    await E2eApp.settle(tester);
    await tester.pumpAndSettle();

    // ---- Bookmark detail -----------------------------------------------------
    // Open the first row by id (its card may be scrolled off-screen, so don't
    // rely on finding its title text in the lazy list).
    final first = bmBloc.state.items.first;
    unawaited(
      BookmarkDetailRoute(first.id).push<void>(tester.element(bookmarksTitle)),
    );
    await E2eApp.settle(tester);
    await tester.pumpAndSettle();
    final detailTitle = _appBarTitle('Bookmark Details');
    await E2eApp.pumpUntil(tester, detailTitle);
    expect(detailTitle, findsOneWidget);
    await shot('bookmark_detail');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // ---- Notifications ------------------------------------------------------
    // The seeded API creates each generated an activity + notification, so the
    // feed is populated once notifications sync pulls it in.
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    final notificationsTitle = _appBarTitle('Notifications');
    await E2eApp.pumpUntil(tester, notificationsTitle);
    expect(notificationsTitle, findsOneWidget);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 3)),
    );
    await tester.pumpAndSettle();
    await shot('notifications');

    // ---- Home (populated) ----------------------------------------------------
    // Bookmarks + collections have synced by now. Home loads once and doesn't
    // auto-refresh, so re-issue a load and wait for its dashboard to fill.
    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(tester, homeTitle);
    expect(homeTitle, findsOneWidget);
    final homeBloc = tester.element(homeTitle).read<HomeBloc>();
    homeBloc.add(const HomeLoadRequested());
    await _pumpUntilTrue(tester, () => homeBloc.state.totalBookmarks > 0);
    await shot('home');

    // ---- Profile (light mode) -----------------------------------------------
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    final profileTitle = _appBarTitle('Profile');
    await E2eApp.pumpUntil(tester, profileTitle);
    expect(profileTitle, findsOneWidget);
    tester
        .element(find.byType(MaterialApp))
        .read<ThemeBloc>()
        .add(const ThemeModeChanged(ThemeMode.light));
    await tester.pumpAndSettle();
    await shot('profile');

    debugPrint('WINDOW_SHOT_DONE');
  });
}

Finder _appBarTitle(String title) => find.descendant(
  of: find.byType(AppBar),
  matching: find.text(title),
);

/// Pumps until [ready] returns true or [maxTries] is hit, giving real
/// wall-clock time on each iteration via `runAsync` so background network
/// pulls (Dio → repository → ObjectBox) can actually make progress — plain
/// `tester.pump` advances only the fake clock and never lets real I/O run.
Future<void> _pumpUntilTrue(
  WidgetTester tester,
  bool Function() ready, {
  int maxTries = 80,
  Duration interval = const Duration(milliseconds: 250),
}) async {
  for (var i = 0; i < maxTries && !ready(); i++) {
    await tester.runAsync(() => Future<void>.delayed(interval));
    await tester.pump();
  }
}
