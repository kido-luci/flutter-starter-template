import 'package:flutter_starter_template/features/collections/data/datasources/collections_remote_data_source.dart';
import 'package:flutter_starter_template/features/collections/data/local/collection_entity.dart';
import 'package:flutter_starter_template/features/collections/data/local/collections_local_data_source.dart';
import 'package:flutter_starter_template/features/collections/data/models/collection_dto.dart';
import 'package:flutter_starter_template/features/collections/data/models/collection_request.dart';
import 'package:flutter_starter_template/features/collections/data/sync/collections_push_queue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

class MockCollectionsRemoteDataSource extends Mock
    implements CollectionsRemoteDataSource {}

class MockCollectionsLocalDataSource extends Mock
    implements CollectionsLocalDataSource {}

class FakeCollectionEntity extends Fake implements CollectionEntity {}

class FakeCollectionRequest extends Fake implements CollectionRequest {}

void main() {
  late MockCollectionsRemoteDataSource remote;
  late MockCollectionsLocalDataSource local;
  late CollectionsPushQueue queue;

  setUpAll(() {
    registerFallbackValue(FakeCollectionEntity());
    registerFallbackValue(FakeCollectionRequest());
  });

  final t0 = DateTime.utc(2025);

  CollectionEntity row({required int syncStateCode, int id = 1}) =>
      CollectionEntity(
        id: id,
        uuid: 'c-1',
        name: 'Design',
        icon: 'f5fd',
        color: 0xFF6366F1,
        bookmarkIds: const ['b-1'],
        createdAt: t0,
        updatedAt: t0,
        syncStateCode: syncStateCode,
      );

  CollectionDto dto() => CollectionDto(
    id: 'c-1',
    name: 'Design',
    icon: 'f5fd',
    color: 0xFF6366F1,
    bookmarkIds: const ['b-1'],
    createdAt: t0,
    updatedAt: t0,
  );

  setUp(() {
    remote = MockCollectionsRemoteDataSource();
    local = MockCollectionsLocalDataSource();
    when(() => local.put(any())).thenAnswer((_) async {});
    when(() => local.hardDelete(any())).thenAnswer((_) async {});
    queue = CollectionsPushQueue(local, remote);
  });

  test('pushes a pendingCreate row and marks it synced', () async {
    final entity = row(syncStateCode: SyncState.pendingCreate.code);
    when(() => local.listPending()).thenAnswer((_) async => [entity]);
    when(() => remote.create(any())).thenAnswer((_) async => dto());

    final hadFailure = await queue.push();

    expect(hadFailure, isFalse);
    expect(entity.syncState, SyncState.synced);
    verify(() => remote.create(any())).called(1);
  });

  test('pushes a pendingDelete row then hard-deletes locally', () async {
    final entity = row(syncStateCode: SyncState.pendingDelete.code, id: 7);
    when(() => local.listPending()).thenAnswer((_) async => [entity]);
    when(() => remote.delete('c-1')).thenAnswer((_) async {});

    final hadFailure = await queue.push();

    expect(hadFailure, isFalse);
    verify(() => local.hardDelete(7)).called(1);
  });

  test('reports failure when a row throws', () async {
    final entity = row(syncStateCode: SyncState.pendingUpdate.code);
    when(() => local.listPending()).thenAnswer((_) async => [entity]);
    when(() => remote.update(any(), any())).thenThrow(Exception('network'));

    final hadFailure = await queue.push();

    expect(hadFailure, isTrue);
    expect(entity.syncState, SyncState.pendingUpdate);
  });
}
