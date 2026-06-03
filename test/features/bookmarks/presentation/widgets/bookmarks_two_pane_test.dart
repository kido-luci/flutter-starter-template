import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_template/app/di/injection.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmark_detail/bookmark_detail_bloc.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmark_detail/bookmark_detail_state.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmarks_list/bookmarks_list_bloc.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmarks_list/bookmarks_list_state.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/widgets/bookmarks_list_widgets.dart';
import 'package:flutter_starter_template/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../test_utils.dart';

class MockBookmarksListBloc extends Mock implements BookmarksListBloc {}

class MockBookmarkDetailBloc extends Mock implements BookmarkDetailBloc {}

void main() {
  late MockBookmarksListBloc listBloc;

  setUpAll(() {
    registerFallbackValue(const BookmarkDetailLoadRequested(''));
  });

  setUp(() {
    listBloc = MockBookmarksListBloc();
    final state = BookmarksListState(items: [testBookmark, testBookmark2]);
    when(() => listBloc.state).thenReturn(state);
    when(() => listBloc.stream).thenAnswer((_) => Stream.value(state));

    // BookmarkDetailPane resolves its bloc from the service locator.
    getIt.registerFactory<BookmarkDetailBloc>(() {
      final detail = MockBookmarkDetailBloc();
      when(() => detail.state).thenReturn(const BookmarkDetailState.loading());
      when(
        () => detail.stream,
      ).thenAnswer((_) => Stream.value(const BookmarkDetailState.loading()));
      when(() => detail.add(any())).thenReturn(null);
      when(detail.close).thenAnswer((_) async {});
      return detail;
    });
  });

  tearDown(getIt.reset);

  Future<void> pumpList(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<BookmarksListBloc>.value(
          value: listBloc,
          child: const BookmarksListView(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  group('BookmarksListView two-pane', () {
    testWidgets('wide layout shows the placeholder until a row is tapped', (
      tester,
    ) async {
      await pumpList(tester, 1100);

      expect(
        find.text('Select a bookmark to view its details'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('tapping a row opens the detail in the side pane', (
      tester,
    ) async {
      await pumpList(tester, 1100);

      await tester.tap(find.text('Flutter'));
      await tester.pump(const Duration(milliseconds: 300));

      // Placeholder is replaced by the (loading) detail pane.
      expect(find.text('Select a bookmark to view its details'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('narrow layout keeps the list single-pane', (tester) async {
      await pumpList(tester, 500);

      // No detail placeholder in compact mode; the list is shown alone.
      expect(find.text('Select a bookmark to view its details'), findsNothing);
      expect(find.text('Flutter'), findsOneWidget);
    });
  });
}
