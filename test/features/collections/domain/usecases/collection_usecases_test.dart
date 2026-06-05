import 'package:architecture/architecture.dart';
import 'package:flutter_starter_template/features/collections/domain/entities/collection.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/delete_collection.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/get_collection.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/list_collections.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/list_local_collections.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/update_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

import '../../collections_test_helpers.dart';

void main() {
  late MockCollectionsRepository repository;

  setUpAll(() => registerFallbackValue(FakeCollectionInput()));

  setUp(() {
    repository = MockCollectionsRepository();
  });

  test('ListCollections delegates to repository.list', () async {
    when(
      () => repository.list(),
    ).thenAnswer((_) async => Ok([buildCollection()]));

    final result = await ListCollections(repository)();

    expect((result as Ok<List<Collection>>).value, hasLength(1));
    verify(() => repository.list()).called(1);
  });

  test('ListLocalCollections delegates to repository.listLocal', () async {
    when(() => repository.listLocal()).thenAnswer((_) async => const Ok([]));

    await ListLocalCollections(repository)();

    verify(() => repository.listLocal()).called(1);
  });

  test('GetCollection delegates to repository.get', () async {
    when(
      () => repository.get('c-1'),
    ).thenAnswer((_) async => Ok(buildCollection()));

    final result = await GetCollection(repository)('c-1');

    expect((result as Ok<Collection>).value.id, 'c-1');
  });

  test('UpdateCollection validates before delegating', () async {
    final result = await UpdateCollection(repository)(
      const UpdateCollectionParams(
        id: 'c-1',
        input: CollectionInput(name: '  ', icon: 'f5fd', color: 0xFF6366F1),
      ),
    );

    expect((result as Err<Collection>).failure, isA<ValidationFailure>());
    verifyNever(() => repository.update(any(), any()));
  });

  test('DeleteCollection delegates to repository.delete', () async {
    when(
      () => repository.delete('c-1'),
    ).thenAnswer((_) async => const Ok(null));

    await DeleteCollection(repository)('c-1');

    verify(() => repository.delete('c-1')).called(1);
  });
}
