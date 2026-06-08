import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter_template/app/di/injection.dart';
import 'package:flutter_starter_template/features/collections/presentation/bloc/collections_list/collections_list_bloc.dart';
import 'package:flutter_starter_template/features/collections/presentation/bloc/collections_list/collections_list_state.dart';
import 'package:flutter_starter_template/features/collections/presentation/widgets/collections_list_view.dart';
import 'package:flutter_starter_template/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

import '../../collections_test_helpers.dart';

class MockCollectionsListBloc
    extends MockBloc<CollectionsListEvent, CollectionsListState>
    implements CollectionsListBloc {}

void main() {
  late MockCollectionsListBloc bloc;

  setUp(() {
    bloc = MockCollectionsListBloc();
    getIt.registerFactory<CollectionsListBloc>(() => bloc);
  });

  tearDown(getIt.reset);

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: CollectionsListView()),
      ),
    );
    // Advance past the per-item stagger entrance motion so no flutter_animate
    // timers remain pending when the test ends.
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('renders a card per collection', (tester) async {
    when(() => bloc.state).thenReturn(
      CollectionsListState(
        items: [
          buildCollection(id: 'c-1', name: 'Design', bookmarkIds: ['b-1']),
          buildCollection(id: 'c-2', name: 'Reading', bookmarkIds: []),
        ],
      ),
    );

    await pump(tester);

    expect(find.text('Design'), findsOneWidget);
    expect(find.text('Reading'), findsOneWidget);
  });

  testWidgets('renders the empty state with a create action', (tester) async {
    when(() => bloc.state).thenReturn(const CollectionsListState());

    await pump(tester);

    expect(find.text('No collections yet'), findsOneWidget);
    expect(find.text('New collection'), findsOneWidget);
  });
}
