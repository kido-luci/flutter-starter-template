import 'package:architecture/architecture.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/update_collection.dart';
import 'package:flutter_starter_template/features/collections/presentation/bloc/add_to_collection/add_to_collection_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

import '../../collections_test_helpers.dart';

void main() {
  late MockListCollections list;
  late MockUpdateCollection update;
  late AddToCollectionCubit cubit;

  setUpAll(() {
    registerFallbackValue(FakeUpdateCollectionParams());
  });

  setUp(() {
    list = MockListCollections();
    update = MockUpdateCollection();
    cubit = AddToCollectionCubit(list, update);
  });

  tearDown(() => cubit.close());

  test('load marks collections that already contain the bookmark', () async {
    when(() => list()).thenAnswer(
      (_) async => Ok([
        buildCollection(id: 'c-1', bookmarkIds: ['b-1']),
        buildCollection(id: 'c-2', bookmarkIds: ['x']),
      ]),
    );

    await cubit.load('b-1');

    expect(cubit.state.memberOf, {'c-1'});
  });

  test('toggle adds the bookmark to a collection it is not in', () async {
    when(() => list()).thenAnswer(
      (_) async => Ok([
        buildCollection(id: 'c-2', bookmarkIds: ['x']),
      ]),
    );
    when(() => update(any())).thenAnswer(
      (_) async => Ok(buildCollection(id: 'c-2', bookmarkIds: ['x', 'b-1'])),
    );

    await cubit.load('b-1');
    await cubit.toggle('c-2', 'b-1');

    final params =
        verify(() => update(captureAny())).captured.single
            as UpdateCollectionParams;
    expect(params.input.bookmarkIds, ['x', 'b-1']);
    expect(cubit.state.memberOf, {'c-2'});
  });

  test('toggle removes the bookmark from a collection it is in', () async {
    when(() => list()).thenAnswer(
      (_) async => Ok([
        buildCollection(id: 'c-1', bookmarkIds: ['b-1', 'y']),
      ]),
    );
    when(() => update(any())).thenAnswer(
      (_) async => Ok(buildCollection(id: 'c-1', bookmarkIds: ['y'])),
    );

    await cubit.load('b-1');
    await cubit.toggle('c-1', 'b-1');

    final params =
        verify(() => update(captureAny())).captured.single
            as UpdateCollectionParams;
    expect(params.input.bookmarkIds, ['y']);
    expect(cubit.state.memberOf, isEmpty);
  });
}
