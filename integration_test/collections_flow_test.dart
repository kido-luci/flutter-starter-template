import 'package:architecture/architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter_template/app/di/injection.dart';
import 'package:flutter_starter_template/features/collections/presentation/bloc/collection_detail/collection_detail_cubit.dart';
import 'package:flutter_starter_template/features/collections/presentation/bloc/collection_form/collection_form_cubit.dart';
import 'package:flutter_starter_template/features/collections/presentation/bloc/collections_list/collections_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/test_utils.dart';
import 'support/harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeCollectionInput());
    registerFallbackValue(FakeUpdateCollectionParams());
  });

  late AppHarness harness;
  CollectionsListBloc? capturedListBloc;
  CollectionDetailCubit? capturedDetailCubit;
  CollectionFormCubit? capturedFormCubit;

  setUp(() async {
    harness = AppHarness();
    await harness.setUp();

    // The home screen's "Featured Collections" section only renders a
    // "View all" action (routing to `/collections`) when its reader returns
    // a non-empty list; otherwise it shows "Create collection" instead.
    when(harness.collectionsReader.call).thenAnswer(
      (_) async => const Ok([testCollectionSummary]),
    );

    // — use-case mocks —
    final listCollections = MockListCollections();
    when(
      listCollections.call,
    ).thenAnswer((_) async => Ok([testCollection]));

    final listLocalCollections = MockListLocalCollections();
    when(
      listLocalCollections.call,
    ).thenAnswer((_) async => Ok([testCollection]));

    final deleteCollection = MockDeleteCollection();
    when(
      () => deleteCollection(any()),
    ).thenAnswer((_) async => const Ok<void>(null));

    final getCollection = MockGetCollection();
    when(
      () => getCollection(testCollection.id),
    ).thenAnswer((_) async => Ok(testCollection));

    final updateCollection = MockUpdateCollection();
    when(
      () => updateCollection(any()),
    ).thenAnswer((_) async => Ok(testCollection));

    final createCollection = MockCreateCollection();
    when(
      () => createCollection(any()),
    ).thenAnswer((_) async => Ok(testCollection));

    final bookmarkSummaries = MockBookmarkSummariesReader();
    when(bookmarkSummaries.call).thenAnswer((_) async => const Ok([]));

    // — getIt registrations —
    getIt.registerFactory<CollectionsListBloc>(() {
      final bloc = CollectionsListBloc(
        listCollections,
        listLocalCollections,
        deleteCollection,
        harness.collectionsSync,
      );
      capturedListBloc = bloc;
      harness.trackDispose(() async {
        if (!bloc.isClosed) await bloc.close();
      });
      return bloc;
    });

    getIt.registerFactory<CollectionDetailCubit>(() {
      final cubit = CollectionDetailCubit(
        getCollection,
        updateCollection,
        deleteCollection,
        bookmarkSummaries,
      );
      capturedDetailCubit = cubit;
      harness.trackDispose(() async {
        if (!cubit.isClosed) await cubit.close();
      });
      return cubit;
    });

    getIt.registerFactory<CollectionFormCubit>(() {
      final cubit = CollectionFormCubit(
        createCollection,
        updateCollection,
        getCollection,
      );
      capturedFormCubit = cubit;
      harness.trackDispose(() async {
        if (!cubit.isClosed) await cubit.close();
      });
      return cubit;
    });
  });

  tearDown(() async {
    capturedListBloc = null;
    capturedDetailCubit = null;
    capturedFormCubit = null;
    await harness.tearDown();
  });

  testWidgets(
    'collections: list renders fixture collection',
    (tester) async {
      await harness.signInToHome(tester);

      // Navigate to Collections via the home screen "Featured Collections"
      // section's "View all" action (only rendered when the reader returns a
      // non-empty list — see harness.collectionsReader stub above).
      await tester.tap(find.text('View all').first);
      await tester.pumpAndSettle();
      await harness.pumpUntil(tester, find.text('Collections'));

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Collections'),
        ),
        findsOneWidget,
      );

      await harness.pumpUntil(tester, find.text('Dev Tools'));
      expect(find.text('Dev Tools'), findsWidgets);
      expect(capturedListBloc, isNotNull);
    },
  );

  testWidgets(
    'collections: FAB opens create form',
    (tester) async {
      await harness.signInToHome(tester);

      await tester.tap(find.text('View all').first);
      await tester.pumpAndSettle();
      await harness.pumpUntil(tester, find.text('Collections'));

      await tester.tap(
        find.byTooltip('New collection'),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      await harness.pumpUntil(tester, find.text('Name'));

      expect(find.text('Name'), findsWidgets);
      expect(capturedFormCubit, isNotNull);
    },
  );

  testWidgets(
    'collections: tapping a collection opens the detail screen',
    (tester) async {
      await harness.signInToHome(tester);

      await tester.tap(find.text('View all').first);
      await tester.pumpAndSettle();
      await harness.pumpUntil(tester, find.text('Dev Tools'));

      await tester.tap(find.text('Dev Tools').first);
      await tester.pumpAndSettle();
      await harness.pumpUntil(tester, find.text('Dev Tools'));

      expect(find.text('Dev Tools'), findsWidgets);
      expect(capturedDetailCubit, isNotNull);
    },
  );
}
