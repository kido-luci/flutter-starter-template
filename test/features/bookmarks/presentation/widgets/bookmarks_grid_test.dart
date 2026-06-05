import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_template/app/di/injection.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmarks_list/bookmarks_list_bloc.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmarks_list/bookmarks_list_state.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/widgets/bookmarks_list_widgets.dart';
import 'package:flutter_starter_template/features/collections/presentation/bloc/collections_list/collections_list_bloc.dart';
import 'package:flutter_starter_template/features/collections/presentation/bloc/collections_list/collections_list_state.dart';
import 'package:flutter_starter_template/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_utils.dart';

class MockBookmarksListBloc extends Mock implements BookmarksListBloc {}

class MockCollectionsListBloc
    extends MockBloc<CollectionsListEvent, CollectionsListState>
    implements CollectionsListBloc {}

void main() {
  late MockBookmarksListBloc listBloc;

  setUp(() {
    listBloc = MockBookmarksListBloc();
    final state = BookmarksListState(items: [testBookmark, testBookmark2]);
    when(() => listBloc.state).thenReturn(state);
    when(() => listBloc.stream).thenAnswer((_) => Stream.value(state));

    // The Collections tab embeds the collections feature's list view, which
    // resolves its bloc from getIt. Register an empty one.
    final collectionsBloc = MockCollectionsListBloc();
    when(() => collectionsBloc.state).thenReturn(const CollectionsListState());
    getIt.registerFactory<CollectionsListBloc>(() => collectionsBloc);
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

  group('BookmarksListView grid', () {
    testWidgets('renders a card per bookmark', (tester) async {
      await pumpList(tester, 500);

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
    });

    testWidgets('wide layout keeps the cards visible without a detail pane', (
      tester,
    ) async {
      await pumpList(tester, 1100);

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
      expect(
        find.text('Select a bookmark to view its details'),
        findsNothing,
      );
    });

    testWidgets('shows the filter tabs', (tester) async {
      await pumpList(tester, 500);

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);
      expect(find.text('Collections'), findsOneWidget);
    });

    testWidgets('Collections tab shows the collections list', (tester) async {
      await pumpList(tester, 500);

      await tester.tap(find.text('Collections'));
      await tester.pump(const Duration(milliseconds: 300));

      // With no collections, the embedded collections view shows its empty
      // state instead of the bookmarks grid.
      expect(find.text('No collections yet'), findsOneWidget);
      expect(find.text('Flutter'), findsNothing);
    });

    testWidgets('Recent tab filters out older bookmarks', (tester) async {
      await pumpList(tester, 500);

      await tester.tap(find.text('Recent'));
      await tester.pump(const Duration(milliseconds: 300));

      // Both fixtures are dated well over a week ago, so none are "recent".
      expect(find.text('Nothing recent'), findsOneWidget);
      expect(find.text('Flutter'), findsNothing);
    });
  });
}
