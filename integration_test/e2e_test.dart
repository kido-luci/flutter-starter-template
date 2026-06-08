// End-to-end journey against the real local backend (`simple_backend_server`,
// http://localhost:8080 by default). Run via `tool/run_e2e.sh`, which starts
// the backend with a fresh database and launches this suite on a connected
// iOS Simulator with `--dart-define=API_BASE_URL=...`.
//
// A single `testWidgets` walks one user through every feature in the order
// they'd naturally encounter them — register, browse home, create a bookmark,
// create a collection, check notifications, sign out — so the run proves the
// assembled app, real Dio client, repositories, and backend all wire together,
// not just that each screen renders against a stub.
//
// The user is freshly registered with a timestamp-unique email/username each
// run, so the journey is order-independent and needs no seeded data or
// cleanup: re-running against the same `data.db` always starts from "no
// bookmarks/collections yet" for that user.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_template/app/router.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmark_form/bookmark_form_bloc.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmarks_list/bookmarks_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/e2e_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(E2eApp.bootstrap);

  testWidgets('real-backend journey: register through every feature', (
    tester,
  ) async {
    final runId = DateTime.now().millisecondsSinceEpoch;
    final email = 'e2e+$runId@example.com';
    const password = 'TestPass123';
    const changedPassword = 'ChangedPass123';
    final bookmarkTitle = 'E2E Bookmark $runId';
    final editedBookmarkTitle = 'E2E Bookmark Updated $runId';
    final collectionName = 'E2E Collection $runId';
    final editedCollectionName = 'E2E Collection Updated $runId';

    // ---- Form validation before auth ---------------------------------------
    await E2eApp.waitForLoginScreen(tester);

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsWidgets);

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(tester, find.text('Join Flutter Starter'));
    expect(find.text('Join Flutter Starter'), findsWidgets);

    await tester.tap(find.text('Join Flutter Starter').last);
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsWidgets);

    // ---- Register a fresh user --------------------------------------------
    await _register(tester, email: email, password: password);

    await _expectHome(tester);
    final authBloc = tester.element(find.byType(MaterialApp)).read<AuthBloc>();
    expect(authBloc.state, isA<AuthAuthenticated>());
    expect((authBloc.state as AuthAuthenticated).user.username, email);

    // ---- Bookmarks: create one through the real backend --------------------
    await tester.tap(find.byTooltip('Bookmarks'));
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(
      tester,
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Bookmarks'),
      ),
    );

    await tester.tap(find.byTooltip('Add bookmark'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(tester, find.byType(TextFormField));

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'https://flutter.dev',
    );
    await tester.enterText(find.byType(TextFormField).at(1), bookmarkTitle);
    await tester.tap(find.text('Create'));
    await E2eApp.settle(tester);
    await tester.pumpAndSettle();

    // Form pops back to the list once the real `CreateBookmark` use case
    // round-trips through the backend and persists the row.
    await E2eApp.pumpUntil(tester, find.text(bookmarkTitle));
    expect(find.text(bookmarkTitle), findsWidgets);

    await _openBookmarkDetail(tester, bookmarkTitle);
    expect(find.text(bookmarkTitle), findsWidgets);

    await tester.tap(_popupMenuButton().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(tester, find.text('Edit bookmark'));

    await tester.enterText(
      find.byType(TextFormField).at(1),
      editedBookmarkTitle,
    );
    tester.element(find.text('Edit bookmark')).read<BookmarkFormBloc>()
      ..add(BookmarkFormTitleChanged(editedBookmarkTitle))
      ..add(const BookmarkFormSubmitted());
    await E2eApp.settle(tester);
    await tester.pumpAndSettle();

    await E2eApp.pumpUntil(
      tester,
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Bookmark Details'),
      ),
    );
    await E2eApp.pumpUntil(tester, find.text(editedBookmarkTitle));
    expect(find.text(editedBookmarkTitle), findsWidgets);
    expect(find.text(bookmarkTitle), findsNothing);

    await _goToBookmarksList(tester, find.text(editedBookmarkTitle).first);
    await E2eApp.pumpUntil(tester, find.text(editedBookmarkTitle));
    expect(find.text(editedBookmarkTitle), findsWidgets);

    // ---- Collections: create one through the real backend ------------------
    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(
      tester,
      find.descendant(of: find.byType(AppBar), matching: find.text('Home')),
    );

    // A brand-new account has no collections yet, so the home screen's
    // "Featured Collections" section shows "Create collection", which routes
    // *directly* to the `/collections/new` form (not the list screen — that's
    // only what "View all" opens once the account has collections).
    await E2eApp.pumpUntil(tester, find.text('Create collection'));
    await tester.tap(find.text('Create collection').first);
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(tester, find.text('Name'));

    await tester.enterText(find.byType(TextFormField).first, collectionName);
    await tester.tap(find.text('Save'));
    await E2eApp.settle(tester);
    await tester.pumpAndSettle();

    // Saving pops back to Home, but `HomeBloc` only loads collections once at
    // creation and never refreshes — so Home's "Featured Collections" section
    // stays stale (still showing "no collections yet"). Push the collections
    // list route directly to verify the new collection actually round-tripped
    // through the real backend, rather than asserting against stale UI state.
    await _openCollectionsListFromHome(tester);

    await E2eApp.pumpUntil(tester, find.text(collectionName));
    expect(find.text(collectionName), findsWidgets);

    await tester.tap(find.text(collectionName).first);
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(tester, find.text(collectionName));
    expect(find.text(collectionName), findsWidgets);

    await tester.tap(find.text('Add bookmarks'));
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(tester, find.text(editedBookmarkTitle));
    await tester.tap(find.text(editedBookmarkTitle).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add 1'));
    await E2eApp.settle(tester);
    await tester.pumpAndSettle();

    await E2eApp.pumpUntil(tester, find.text(editedBookmarkTitle));
    expect(find.text(editedBookmarkTitle), findsWidgets);

    await tester.tap(find.byTooltip('Remove from collection'));
    await E2eApp.settle(tester);
    await tester.pumpAndSettle();
    expect(find.text(editedBookmarkTitle), findsNothing);

    await tester.tap(find.byTooltip('Edit collection'));
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(tester, find.text('Edit collection'));
    await tester.enterText(
      find.byType(TextFormField).first,
      editedCollectionName,
    );
    await tester.tap(find.text('Save'));
    await E2eApp.settle(tester);
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await _expectHome(tester);
    await _openCollectionsListFromHome(tester);
    await E2eApp.pumpUntil(tester, find.text(editedCollectionName));
    expect(find.text(editedCollectionName), findsWidgets);
    expect(find.text(collectionName), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    // ---- Notifications: real feed for a brand-new user is empty ------------
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(
      tester,
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Notifications'),
      ),
    );
    expect(find.text('Your activity'), findsWidgets);

    // ---- Profile: sign out, returning to login -----------------------------
    await _signOut(tester);

    // ---- Existing user login preserves backend data ------------------------
    await _login(tester, email: email, password: password);
    await _goHome(tester);

    await tester.tap(find.byTooltip('Bookmarks'));
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(tester, find.text(editedBookmarkTitle));
    expect(find.text(editedBookmarkTitle), findsWidgets);

    await _goHome(tester);
    await _openCollectionsListFromHome(tester);
    await E2eApp.pumpUntil(tester, find.text(editedCollectionName));
    expect(find.text(editedCollectionName), findsWidgets);

    await tester.tap(find.text(editedCollectionName).first);
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(tester, find.text(editedCollectionName));
    await tester.tap(find.byTooltip('Delete collection'));
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(tester, find.text('Delete collection'));
    await tester.tap(find.text('Delete collection').last);
    await E2eApp.settle(tester);
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    await _expectHome(tester);
    await _openCollectionsListFromHome(tester);
    await E2eApp.settle(tester);
    expect(find.text(editedCollectionName), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Bookmarks'));
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(tester, find.text(editedBookmarkTitle));
    await _openBookmarkDetail(tester, editedBookmarkTitle);
    await E2eApp.pumpUntil(tester, find.text(editedBookmarkTitle));

    await tester.tap(_popupMenuButton().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await E2eApp.pumpUntil(tester, find.text('Delete bookmark?'));
    await tester.tap(find.text('Delete').last);
    await E2eApp.settle(tester);
    await tester.pumpAndSettle();
    expect(find.text(editedBookmarkTitle), findsNothing);

    // ---- Change password: old password fails, new password works -----------
    await _changePassword(
      tester,
      currentPassword: password,
      newPassword: changedPassword,
    );
    await _signOut(tester);
    await _expectLoginFailure(tester, email: email, password: password);
    await _login(tester, email: email, password: changedPassword);
    await _goHome(tester);
    await _signOut(tester);
  });
}

Future<void> _expectHome(WidgetTester tester) async {
  final homeTitle = find.descendant(
    of: find.byType(AppBar),
    matching: find.text('Home'),
  );
  await E2eApp.pumpUntil(tester, homeTitle);
  expect(homeTitle, findsOneWidget);
}

Future<void> _goHome(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Home'));
  await tester.pumpAndSettle();
  await _expectHome(tester);
}

Future<void> _openCollectionsListFromHome(WidgetTester tester) async {
  final homeAppBarTitle = find.descendant(
    of: find.byType(AppBar),
    matching: find.text('Home'),
  );
  await E2eApp.pumpUntil(tester, homeAppBarTitle);
  // `GoRouter.of` resolves an `InheritedWidget` scoped *below* the `Router`
  // that `MaterialApp.router` builds — `MaterialApp`'s own element sits
  // above it, so it can't see the router. Use an element from inside the
  // routed screen instead (the Home AppBar title we just located).
  //
  // `push` also returns a Future that only completes once the route is
  // popped — don't await it here, or the test would deadlock waiting for a
  // pop that hasn't happened yet.
  unawaited(
    const CollectionsListRoute().push<void>(tester.element(homeAppBarTitle)),
  );
  await E2eApp.settle(tester);
  await tester.pumpAndSettle();
}

Future<void> _openBookmarkDetail(WidgetTester tester, String title) async {
  final titleFinder = find.text(title).first;
  final context = tester.element(titleFinder);
  final bloc = context.read<BookmarksListBloc>();
  final bookmark = bloc.state.items.firstWhere((item) => item.title == title);

  unawaited(BookmarkDetailRoute(bookmark.id).push<void>(context));
  await E2eApp.settle(tester);
  await tester.pumpAndSettle();
  final detailTitle = find.descendant(
    of: find.byType(AppBar),
    matching: find.text('Bookmark Details'),
  );
  await E2eApp.pumpUntil(tester, detailTitle);
  expect(detailTitle, findsOneWidget);
  await E2eApp.pumpUntil(tester, _popupMenuButton());
  expect(_popupMenuButton(), findsWidgets);
}

Future<void> _goToBookmarksList(
  WidgetTester tester,
  Finder contextFinder,
) async {
  const BookmarksListRoute().go(tester.element(contextFinder));
  await E2eApp.settle(tester);
  await tester.pumpAndSettle();
  final bookmarksTitle = find.descendant(
    of: find.byType(AppBar),
    matching: find.text('Bookmarks'),
  );
  await E2eApp.pumpUntil(tester, bookmarksTitle);
  expect(bookmarksTitle, findsOneWidget);
}

Finder _popupMenuButton() {
  return find.byWidgetPredicate((widget) => widget is PopupMenuButton);
}

Future<void> _login(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await E2eApp.pumpUntil(tester, find.text('Welcome Back'));
  await tester.enterText(find.byType(TextFormField).at(0), email);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.text('Log In'));
  await E2eApp.settle(tester);
  await tester.pumpAndSettle();
}

Future<void> _signOut(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Profile'));
  await tester.pumpAndSettle();
  await E2eApp.pumpUntil(
    tester,
    find.descendant(of: find.byType(AppBar), matching: find.text('Profile')),
  );
  expect(find.text('Appearance'), findsWidgets);
  expect(find.text('Account'), findsWidgets);

  // The "Sign out" button sits below the initial viewport (lazy sliver
  // building) and under the floating bottom-nav pill once scrolled into
  // view, so a coordinate tap lands on the pill — invoke its callback
  // directly, bypassing hit-testing (see integration_test/README.md).
  await tester.scrollUntilVisible(find.text('Sign out'), 200);
  await tester.pumpAndSettle();
  final signOutButton = tester.widget<FilledButton>(find.byType(FilledButton));
  signOutButton.onPressed!();
  await tester.pumpAndSettle();

  await tester.tap(find.widgetWithText(FilledButton, 'Sign out').last);
  await E2eApp.settle(tester);
  await tester.pumpAndSettle();

  await E2eApp.pumpUntil(tester, find.text('Welcome Back'));
  expect(find.text('Welcome Back'), findsOneWidget);
}

Future<void> _changePassword(
  WidgetTester tester, {
  required String currentPassword,
  required String newPassword,
}) async {
  await tester.tap(find.byTooltip('Profile'));
  await tester.pumpAndSettle();
  await E2eApp.pumpUntil(tester, find.text('Change Password'));
  await tester.scrollUntilVisible(find.text('Change Password'), 200);
  await tester.tap(find.text('Change Password'));
  await tester.pumpAndSettle();
  await E2eApp.pumpUntil(tester, find.text('Update Password'));

  await tester.enterText(find.byType(TextFormField).at(0), currentPassword);
  await tester.enterText(find.byType(TextFormField).at(1), newPassword);
  await tester.enterText(find.byType(TextFormField).at(2), newPassword);
  await tester.tap(find.text('Update Password'));
  await E2eApp.settle(tester);
  await tester.pumpAndSettle();

  await E2eApp.pumpUntil(
    tester,
    find.descendant(of: find.byType(AppBar), matching: find.text('Profile')),
  );
  expect(find.text('Profile'), findsWidgets);
}

Future<void> _expectLoginFailure(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await E2eApp.pumpUntil(tester, find.text('Welcome Back'));
  await tester.enterText(find.byType(TextFormField).at(0), email);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.text('Log In'));
  await E2eApp.settle(tester);
  await tester.pumpAndSettle();

  expect(find.text('Welcome Back'), findsOneWidget);
  expect(find.text('Please enter a username and password.'), findsWidgets);
}

Future<void> _register(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.enterText(find.byType(TextFormField).at(0), email);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.text('Join Flutter Starter').last);
  await E2eApp.settle(tester);
  await tester.pumpAndSettle();
}
