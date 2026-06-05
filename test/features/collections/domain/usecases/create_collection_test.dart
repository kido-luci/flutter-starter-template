import 'package:architecture/architecture.dart';
import 'package:flutter_starter_template/features/collections/domain/entities/collection.dart';
import 'package:flutter_starter_template/features/collections/domain/repositories/collections_repository.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/create_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

class MockCollectionsRepository extends Mock implements CollectionsRepository {}

class FakeCollectionInput extends Fake implements CollectionInput {}

void main() {
  late MockCollectionsRepository repository;
  late CreateCollection useCase;

  setUpAll(() => registerFallbackValue(FakeCollectionInput()));

  setUp(() {
    repository = MockCollectionsRepository();
    useCase = CreateCollection(repository);
  });

  test('rejects a blank name without touching the repository', () async {
    final result = await useCase(
      const CollectionInput(name: '   ', icon: 'f5fd', color: 0xFF6366F1),
    );

    expect(result, isA<Err<Collection>>());
    expect((result as Err<Collection>).failure, isA<ValidationFailure>());
    verifyNever(() => repository.create(any()));
  });

  test('delegates to the repository for a valid input', () async {
    final collection = Collection(
      id: 'c-1',
      name: 'Design',
      icon: 'f5fd',
      color: 0xFF6366F1,
      bookmarkIds: const [],
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    );
    when(
      () => repository.create(any()),
    ).thenAnswer((_) async => Ok(collection));

    final result = await useCase(
      const CollectionInput(name: 'Design', icon: 'f5fd', color: 0xFF6366F1),
    );

    expect((result as Ok<Collection>).value.name, 'Design');
    verify(() => repository.create(any())).called(1);
  });
}
