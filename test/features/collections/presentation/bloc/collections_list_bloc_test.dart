import 'dart:async';

import 'package:architecture/architecture.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_starter_template/features/collections/domain/services/collections_sync_controller.dart';
import 'package:flutter_starter_template/features/collections/presentation/bloc/collections_list/collections_list_bloc.dart';
import 'package:flutter_starter_template/features/collections/presentation/bloc/collections_list/collections_list_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

import '../../collections_test_helpers.dart';

void main() {
  late MockListCollections list;
  late MockListLocalCollections listLocal;
  late MockDeleteCollection delete;
  late MockCollectionsSyncController sync;
  late StreamController<CollectionsSyncStatus> statusController;

  setUp(() {
    list = MockListCollections();
    listLocal = MockListLocalCollections();
    delete = MockDeleteCollection();
    sync = MockCollectionsSyncController();
    statusController = StreamController<CollectionsSyncStatus>.broadcast();
    when(() => sync.statusStream).thenAnswer((_) => statusController.stream);
  });

  tearDown(() => statusController.close());

  CollectionsListBloc build() =>
      CollectionsListBloc(list, listLocal, delete, sync);

  blocTest<CollectionsListBloc, CollectionsListState>(
    'emits loaded items on load',
    setUp: () => when(() => list()).thenAnswer(
      (_) async => Ok([buildCollection()]),
    ),
    build: build,
    act: (bloc) => bloc.add(const CollectionsListLoadRequested()),
    expect: () => [
      const CollectionsListState(isLoading: true),
      isA<CollectionsListState>()
          .having((s) => s.isLoading, 'isLoading', false)
          .having((s) => s.items.length, 'items', 1),
    ],
  );

  blocTest<CollectionsListBloc, CollectionsListState>(
    'stores failure when load fails',
    setUp: () => when(
      () => list(),
    ).thenAnswer((_) async => const Err(UnknownFailure('boom'))),
    build: build,
    act: (bloc) => bloc.add(const CollectionsListLoadRequested()),
    expect: () => [
      const CollectionsListState(isLoading: true),
      isA<CollectionsListState>().having(
        (s) => s.failure,
        'failure',
        isA<UnknownFailure>(),
      ),
    ],
  );

  blocTest<CollectionsListBloc, CollectionsListState>(
    'delete reloads from local on success',
    setUp: () {
      when(() => delete('c-1')).thenAnswer((_) async => const Ok(null));
      when(() => listLocal()).thenAnswer((_) async => const Ok([]));
    },
    build: build,
    act: (bloc) => bloc.add(const CollectionsListDeleteRequested('c-1')),
    verify: (_) {
      verify(() => delete('c-1')).called(1);
      verify(() => listLocal()).called(1);
    },
  );
}
