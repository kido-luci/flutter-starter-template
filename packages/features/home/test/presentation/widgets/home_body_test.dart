// Widget tests for the home dashboard body. home_bloc_test covers the
// stats-to-state mapping; these assert that HomeBody renders that state for the
// branches that don't pull network thumbnails — the empty dashboard and the
// featured-collections row.
//
// Populated bookmark cards are intentionally not exercised here: each renders
// an AppLinkPreviewThumbnail whose link-preview fetch schedules a real 5s
// timeout timer, which would leak past the test and fail it. The bloc test
// already verifies the bookmark-stats mapping.

import 'package:app_ui/app_ui.dart';
import 'package:architecture/architecture.dart';
import 'package:feature_home/feature_home.dart';
import 'package:feature_home/src/presentation/widgets/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
import 'package:shared_contracts/shared_contracts.dart';

import '../../support.dart';

void main() {
  Future<HomeBloc> loadedBloc({
    BookmarkStats stats = const BookmarkStats(),
    List<CollectionSummary> collections = const [],
  }) async {
    final statsReader = MockBookmarkStatsReader();
    when(statsReader.call).thenAnswer((_) async => Ok(stats));
    final collectionsReader = MockCollectionsReader();
    when(collectionsReader.call).thenAnswer((_) async => Ok(collections));

    final bloc = HomeBloc(statsReader, collectionsReader)
      ..add(const HomeLoadRequested());
    // Wait for the load to settle. When collections are expected, also wait for
    // the (separate) collections emit that follows the stats emit.
    await bloc.stream.firstWhere(
      (s) => !s.isLoading && (collections.isEmpty || s.collections.isNotEmpty),
    );
    return bloc;
  }

  Future<void> pumpHome(WidgetTester tester, HomeBloc bloc) async {
    // A tall, wide surface so the whole scrolling dashboard lays out and is
    // hit-testable without scrolling.
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<HomeBloc>.value(
          value: bloc,
          child: const HomeBody(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the empty dashboard with no bookmark thumbnails', (
    tester,
  ) async {
    final bloc = await loadedBloc();
    await pumpHome(tester, bloc);

    expect(find.text('Home'), findsWidgets); // app bar title
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('No bookmarks yet. Tap + to add one.'), findsOneWidget);
    expect(find.byType(AppLinkPreviewThumbnail), findsNothing);

    await bloc.close();
  });

  testWidgets('renders featured collections from state', (tester) async {
    final bloc = await loadedBloc(
      collections: const [
        CollectionSummary(
          id: 'c1',
          name: 'Reading list',
          icon: 'book',
          color: 0xFF2196F3,
          itemCount: 4,
        ),
      ],
    );
    await pumpHome(tester, bloc);

    expect(find.text('Reading list'), findsOneWidget);
    // Collection cards are gradient tiles, not link-preview thumbnails.
    expect(find.byType(AppLinkPreviewThumbnail), findsNothing);

    await bloc.close();
  });
}
