import 'package:flutter_starter_template/features/collections/domain/entities/collection.dart';
import 'package:flutter_starter_template/features/collections/domain/repositories/collections_repository.dart';
import 'package:flutter_starter_template/features/collections/domain/services/collections_sync_controller.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/create_collection.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/delete_collection.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/get_collection.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/list_collections.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/list_local_collections.dart';
import 'package:flutter_starter_template/features/collections/domain/usecases/update_collection.dart';
import 'package:flutter_starter_template/shared/domain/bookmark_stats.dart';
import 'package:flutter_starter_template/shared/domain/bookmark_summaries.dart';
import 'package:test_utils/test_utils.dart';

class MockCollectionsRepository extends Mock implements CollectionsRepository {}

class MockListCollections extends Mock implements ListCollections {}

class MockListLocalCollections extends Mock implements ListLocalCollections {}

class MockGetCollection extends Mock implements GetCollection {}

class MockCreateCollection extends Mock implements CreateCollection {}

class MockUpdateCollection extends Mock implements UpdateCollection {}

class MockDeleteCollection extends Mock implements DeleteCollection {}

class MockCollectionsSyncController extends Mock
    implements CollectionsSyncController {}

class MockBookmarkSummariesReader extends Mock
    implements BookmarkSummariesReader {}

class FakeCollectionInput extends Fake implements CollectionInput {}

class FakeUpdateCollectionParams extends Fake
    implements UpdateCollectionParams {}

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
