import 'package:feature_collections/src/domain/entities/collection.dart';
import 'package:feature_collections/src/domain/repositories/collections_repository.dart';
import 'package:feature_collections/src/domain/services/collections_sync_controller.dart';
import 'package:feature_collections/src/domain/usecases/create_collection.dart';
import 'package:feature_collections/src/domain/usecases/delete_collection.dart';
import 'package:feature_collections/src/domain/usecases/get_collection.dart';
import 'package:feature_collections/src/domain/usecases/list_collections.dart';
import 'package:feature_collections/src/domain/usecases/list_local_collections.dart';
import 'package:feature_collections/src/domain/usecases/update_collection.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:test_utils/test_utils.dart';

export 'package:test_utils/test_utils.dart';

class MockCollectionsRepository extends Mock implements CollectionsRepository {}

class MockListCollections extends Mock implements ListCollectionsUseCase {}

class MockListLocalCollections extends Mock
    implements ListLocalCollectionsUseCase {}

class MockGetCollection extends Mock implements GetCollectionUseCase {}

class MockCreateCollection extends Mock implements CreateCollectionUseCase {}

class MockUpdateCollection extends Mock implements UpdateCollectionUseCase {}

class MockDeleteCollection extends Mock implements DeleteCollectionUseCase {}

class MockCollectionsSyncController extends Mock
    implements CollectionsSyncController {}

class FakeCollectionInput extends Fake implements CollectionInput {}

class FakeUpdateCollectionParams extends Fake
    implements UpdateCollectionParams {}

final testCollection = Collection(
  id: 'col-1',
  name: 'Dev Tools',
  icon: 'e8d4',
  color: 0xFF6366F1,
  bookmarkIds: const [],
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
);

Collection buildCollection({
  String id = 'c-1',
  String name = 'Design',
  String icon = 'f5fd',
  int color = 0xFF6366F1,
  List<String> bookmarkIds = const ['b-1'],
}) => Collection(
  id: id,
  name: name,
  icon: icon,
  color: color,
  bookmarkIds: bookmarkIds,
  createdAt: DateTime(2025),
  updatedAt: DateTime(2025),
);

BookmarkSummary buildSummary({String id = 'b-1', String title = 'Flutter'}) =>
    BookmarkSummary(
      id: id,
      title: title,
      url: 'https://flutter.dev',
      description: '',
      tags: const [],
    );
