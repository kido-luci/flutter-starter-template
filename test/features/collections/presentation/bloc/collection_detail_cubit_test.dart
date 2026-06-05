import 'package:architecture/architecture.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/update_collection.dart';
import 'package:flutter_starter_template/features/collections/presentation/bloc/collection_detail/collection_detail_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

import '../../collections_test_helpers.dart';

void main() {
  late MockGetCollection get;
  late MockUpdateCollection update;
  late MockDeleteCollection delete;
  late MockBookmarkSummariesReader summaries;
  late CollectionDetailCubit cubit;

  setUpAll(() {
    registerFallbackValue(FakeUpdateCollectionParams());
  });

  setUp(() {
    get = MockGetCollection();
    update = MockUpdateCollection();
    delete = MockDeleteCollection();
    summaries = MockBookmarkSummariesReader();
    cubit = CollectionDetailCubit(get, update, delete, summaries);
  });

  tearDown(() => cubit.close());

  test('load resolves members from bookmark summaries', () async {
    when(() => get('c-1')).thenAnswer(
      (_) async => Ok(buildCollection(bookmarkIds: ['b-1', 'b-2'])),
    );
    when(() => summaries()).thenAnswer(
      (_) async => Ok([
        buildSummary(id: 'b-1', title: 'One'),
        buildSummary(id: 'b-3', title: 'Three'),
      ]),
    );

    await cubit.load('c-1');

    expect(cubit.state.collection, isNotNull);
    // Only b-1 resolves; b-2 has no summary and is dropped.
    expect(cubit.state.members.map((m) => m.id), ['b-1']);
    expect(cubit.state.candidates.map((c) => c.id), ['b-3']);
  });

  test('load surfaces failure when the collection is missing', () async {
    when(
      () => get('c-1'),
    ).thenAnswer((_) async => const Err(NotFoundFailure('nope')));

    await cubit.load('c-1');

    expect(cubit.state.failure, isA<NotFoundFailure>());
    expect(cubit.state.collection, isNull);
  });

  test('addBookmarks unions ids and persists', () async {
    when(() => get('c-1')).thenAnswer(
      (_) async => Ok(buildCollection(bookmarkIds: ['b-1'])),
    );
    when(() => summaries()).thenAnswer(
      (_) async => Ok([buildSummary(id: 'b-1'), buildSummary(id: 'b-2')]),
    );
    when(() => update(any())).thenAnswer(
      (_) async => Ok(buildCollection(bookmarkIds: ['b-1', 'b-2'])),
    );

    await cubit.load('c-1');
    await cubit.addBookmarks({'b-2'});

    final params =
        verify(() => update(captureAny())).captured.single
            as UpdateCollectionParams;
    expect(params.input.bookmarkIds, ['b-1', 'b-2']);
    expect(cubit.state.members.map((m) => m.id), ['b-1', 'b-2']);
  });

  test('removeBookmark drops the id and persists', () async {
    when(() => get('c-1')).thenAnswer(
      (_) async => Ok(buildCollection(bookmarkIds: ['b-1', 'b-2'])),
    );
    when(() => summaries()).thenAnswer(
      (_) async => Ok([buildSummary(id: 'b-1'), buildSummary(id: 'b-2')]),
    );
    when(() => update(any())).thenAnswer(
      (_) async => Ok(buildCollection(bookmarkIds: ['b-1'])),
    );

    await cubit.load('c-1');
    await cubit.removeBookmark('b-2');

    final params =
        verify(() => update(captureAny())).captured.single
            as UpdateCollectionParams;
    expect(params.input.bookmarkIds, ['b-1']);
  });

  test('delete flips deleted on success', () async {
    when(() => get('c-1')).thenAnswer((_) async => Ok(buildCollection()));
    when(() => summaries()).thenAnswer((_) async => const Ok([]));
    when(() => delete('c-1')).thenAnswer((_) async => const Ok(null));

    await cubit.load('c-1');
    await cubit.delete();

    expect(cubit.state.deleted, isTrue);
  });
}
