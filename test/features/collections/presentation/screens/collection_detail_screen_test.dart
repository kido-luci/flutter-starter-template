import 'package:architecture/architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter_template/app/di/injection.dart';
import 'package:flutter_starter_template/features/collections/presentation/bloc/collection_detail/collection_detail_cubit.dart';
import 'package:flutter_starter_template/features/collections/presentation/screens/collection_detail_screen.dart';
import 'package:flutter_starter_template/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

import '../../collections_test_helpers.dart';

void main() {
  late MockGetCollection get;
  late MockUpdateCollection update;
  late MockDeleteCollection delete;
  late MockBookmarkSummariesReader summaries;

  setUp(() {
    get = MockGetCollection();
    update = MockUpdateCollection();
    delete = MockDeleteCollection();
    summaries = MockBookmarkSummariesReader();
    getIt.registerFactory<CollectionDetailCubit>(
      () => CollectionDetailCubit(get, update, delete, summaries),
    );
  });

  tearDown(getIt.reset);

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CollectionDetailScreen(id: 'c-1'),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders the collection name and member bookmarks', (
    tester,
  ) async {
    when(() => get('c-1')).thenAnswer(
      (_) async => Ok(buildCollection(name: 'Design', bookmarkIds: ['b-1'])),
    );
    when(() => summaries()).thenAnswer(
      (_) async => Ok([buildSummary(id: 'b-1', title: 'Flutter docs')]),
    );

    await pump(tester);
    await tester.pump();

    expect(find.text('Design'), findsOneWidget);
    expect(find.text('Flutter docs'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no members', (
    tester,
  ) async {
    when(
      () => get('c-1'),
    ).thenAnswer((_) async => Ok(buildCollection(bookmarkIds: [])));
    when(() => summaries()).thenAnswer((_) async => const Ok([]));

    await pump(tester);
    await tester.pump();

    expect(
      find.text('No bookmarks in this collection yet.'),
      findsOneWidget,
    );
  });
}
