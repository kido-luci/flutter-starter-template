// Screenshot-capture run for the README, against the real local backend
// (`simple_backend_server`, http://localhost:8080 by default) with a
// pre-seeded demo user (`demo` / `demo1234`, 8 bookmarks, 2 collections).
//
// Unlike `e2e_test.dart`, this suite asserts almost nothing about business
// behaviour — it signs in and walks to six representative screens, capturing
// a PNG of each via `IntegrationTestWidgetsFlutterBinding.takeScreenshot`. The
// companion driver (`test_driver/integration_test.dart`) persists the bytes to
// `doc/screenshots/<name>.png`.
//
// The demo user's bookmarks and collections live only on the server (seeded
// via the API, not created through the app), so each list screen must wait for
// the app's offline-first background *pull* to land them in the local store
// before it shows anything. A pull only progresses under `tester.runAsync`
// (real wall-clock time, outside the fake-async guard) — plain `tester.pump`
// never advances it — so the waits poll bloc state via [_pumpUntilTrue].
// Home loads once and doesn't auto-refresh, so it's captured last, after the
// syncs, with an explicit `HomeLoadRequested` reload.
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
import 'package:integration_test/integration_test.dart';
import 'package:theme/theme.dart';

import 'support/e2e_app.dart';

// When true (`--dart-define=WINDOW_CAPTURE=true`), this run is being driven by
// `tool/capture_sim_window.sh`, which grabs the Simulator *window* (device
// bezel included) externally. In that mode we must NOT write surface PNGs via
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
        // Signal tool/capture_sim_window.sh to grab the Simulator window for
        // this screen, then dwell so it can react before navigation moves on.
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

    // ---- Bookmark detail -----------------------------------------------------
    // Open the first row by id (its card may be scrolled off-screen, so don't
    // rely on finding its title text in the lazy list).
    final first = bmBloc.state.items.first;
    final bookmarksContext = tester.element(bookmarksTitle);
    unawaited(BookmarkDetailRoute(first.id).push<void>(bookmarksContext));
    await E2eApp.settle(tester);
    await tester.pumpAndSettle();
    final detailTitle = _appBarTitle('Bookmark Details');
    await E2eApp.pumpUntil(tester, detailTitle);
    expect(detailTitle, findsOneWidget);
    await shot('bookmark_detail');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // ---- Collections ---------------------------------------------------------
    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(tester, homeTitle);
    expect(homeTitle, findsOneWidget);

    await _pushCollectionsList(tester, homeTitle);
    await _pumpUntilTrue(
      tester,
      () => find.text('AI Tools').evaluate().isNotEmpty,
    );
    expect(find.text('AI Tools'), findsWidgets);
    await shot('collections');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // ---- Home (populated) ----------------------------------------------------
    // Both resources are now synced. Home loads once and doesn't auto-refresh,
    // so re-issue a load and wait for its dashboard to reflect the synced data.
    await E2eApp.pumpUntil(tester, homeTitle);
    expect(homeTitle, findsOneWidget);
    final homeBloc = tester.element(homeTitle).read<HomeBloc>();
    homeBloc.add(const HomeLoadRequested());
    await _pumpUntilTrue(tester, () => homeBloc.state.totalBookmarks > 0);
    await shot('home');

    // ---- Profile (dark mode) --------------------------------------------------
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    final profileTitle = _appBarTitle('Profile');
    await E2eApp.pumpUntil(tester, profileTitle);
    expect(profileTitle, findsOneWidget);

    tester
        .element(find.byType(MaterialApp))
        .read<ThemeBloc>()
        .add(const ThemeModeChanged(ThemeMode.dark));
    await tester.pumpAndSettle();
    await shot('profile_dark');

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

Future<void> _pushCollectionsList(WidgetTester tester, Finder homeTitle) async {
  await E2eApp.pumpUntil(tester, homeTitle);
  // `GoRouter.of` resolves an `InheritedWidget` scoped *below* the `Router`
  // that `MaterialApp.router` builds — `MaterialApp`'s own element sits above
  // it, so it can't see the router. Use an element from inside the routed
  // screen instead (the Home AppBar title).
  //
  // `push` returns a Future that only completes once the route is popped —
  // don't await it here, or the test would deadlock.
  unawaited(
    const CollectionsListRoute().push<void>(tester.element(homeTitle)),
  );
  await E2eApp.settle(tester);
  await tester.pumpAndSettle();
}
