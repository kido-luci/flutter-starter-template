import 'package:architecture/architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter_template/app/di/injection.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmark_detail/bookmark_detail_bloc.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmark_form/bookmark_form_bloc.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmarks_list/bookmarks_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/test_utils.dart';
import 'support/harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeBookmarkInput());
  });

  late AppHarness harness;
  // Captured so tests can assert the blocs were created.
  BookmarksListBloc? capturedListBloc;
  BookmarkDetailBloc? capturedDetailBloc;
  BookmarkFormBloc? capturedFormBloc;
  late MockGetBookmark getBookmark;
  late MockDeleteBookmark deleteBookmark;

  setUp(() async {
    harness = AppHarness();
    await harness.setUp();

    // — use-case mocks —
    final listBookmarks = MockListBookmarks();
    when(
      listBookmarks.call,
    ).thenAnswer((_) async => Ok([testBookmark, testBookmark2]));

    final listLocalBookmarks = MockListLocalBookmarks();
    when(
      listLocalBookmarks.call,
    ).thenAnswer((_) async => Ok([testBookmark, testBookmark2]));

    deleteBookmark = MockDeleteBookmark();
    when(
      () => deleteBookmark(any()),
    ).thenAnswer((_) async => const Ok<void>(null));

    final share = MockShareService();
    stubShareService(share);

    getBookmark = MockGetBookmark();
    when(
      () => getBookmark(testBookmark.id),
    ).thenAnswer((_) async => Ok(testBookmark));

    final activityNotifier = MockActivityNotifier();
    when(
      () => activityNotifier.onActivityOccurred,
    ).thenAnswer((_) => const Stream.empty());

    // — getIt registrations —
    getIt.registerFactory<BookmarksListBloc>(() {
      final bloc = BookmarksListBloc(
        listBookmarks,
        listLocalBookmarks,
        deleteBookmark,
        harness.bookmarksSync,
        harness.analytics,
        share,
      );
      capturedListBloc = bloc;
      harness.trackDispose(() async {
        if (!bloc.isClosed) await bloc.close();
      });
      return bloc;
    });

    getIt.registerFactory<BookmarkDetailBloc>(() {
      final bloc = BookmarkDetailBloc(
        getBookmark,
        deleteBookmark,
        harness.analytics,
        share,
      );
      capturedDetailBloc = bloc;
      harness.trackDispose(() async {
        if (!bloc.isClosed) await bloc.close();
      });
      return bloc;
    });

    getIt.registerFactory<BookmarkFormBloc>(() {
      final bloc = BookmarkFormBloc(
        MockGetBookmark(),
        MockCreateBookmark(),
        MockUpdateBookmark(),
        harness.analytics,
        MockImagePickerService(),
        MockPermissionService(),
        activityNotifier,
      );
      capturedFormBloc = bloc;
      harness.trackDispose(() async {
        if (!bloc.isClosed) await bloc.close();
      });
      return bloc;
    });
  });

  tearDown(() async {
    capturedListBloc = null;
    capturedDetailBloc = null;
    capturedFormBloc = null;
    await harness.tearDown();
  });

  testWidgets(
    'bookmarks: list renders fixture bookmarks',
    (tester) async {
      await harness.signInToHome(tester);

      await tester.tap(find.byTooltip('Bookmarks'));
      await tester.pumpAndSettle();
      await harness.pumpUntil(tester, find.text('Bookmarks'));

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Bookmarks'),
        ),
        findsOneWidget,
      );

      await harness.pumpUntil(tester, find.text('Flutter'));
      expect(find.text('Flutter'), findsWidgets);
      expect(find.text('Dart'), findsWidgets);
      expect(capturedListBloc, isNotNull);
    },
  );

  testWidgets(
    'bookmarks: FAB opens create form',
    (tester) async {
      await harness.signInToHome(tester);

      await tester.tap(find.byTooltip('Bookmarks'));
      await tester.pumpAndSettle();
      await harness.pumpUntil(tester, find.text('Bookmarks'));

      await tester.tap(
        find.byTooltip('Add bookmark'),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      await harness.pumpUntil(tester, find.byType(TextFormField));

      expect(find.byType(TextFormField), findsWidgets);
      expect(capturedFormBloc, isNotNull);
    },
  );

  testWidgets(
    'bookmarks: tapping a bookmark opens the detail screen',
    (tester) async {
      await harness.signInToHome(tester);

      await tester.tap(find.byTooltip('Bookmarks'));
      await tester.pumpAndSettle();
      await harness.pumpUntil(tester, find.text('Flutter'));

      await tester.tap(find.text('Flutter').first);
      await tester.pumpAndSettle();
      await harness.pumpUntil(tester, find.text('Flutter'));

      expect(find.text('Flutter'), findsWidgets);
      expect(capturedDetailBloc, isNotNull);

      // GetBookmark was called to load the bookmark.
      verify(
        () => getBookmark(testBookmark.id),
      ).called(greaterThanOrEqualTo(1));
    },
  );

  testWidgets(
    'bookmarks: sync controllers start on sign-in',
    (tester) async {
      await harness.signInToHome(tester);
      verify(
        () => harness.bookmarksSync.start(),
      ).called(greaterThanOrEqualTo(1));
      verify(
        () => harness.collectionsSync.start(),
      ).called(greaterThanOrEqualTo(1));
      verify(
        () => harness.notificationsSync.start(),
      ).called(greaterThanOrEqualTo(1));
    },
  );
}
