import 'package:flutter_starter_template/features/collections/data/datasources/collections_remote_data_source.dart';
import 'package:flutter_starter_template/features/collections/data/local/collection_entity.dart';
import 'package:flutter_starter_template/features/collections/data/local/collections_local_data_source.dart';
import 'package:flutter_starter_template/features/collections/data/models/collection_dto.dart';
import 'package:flutter_starter_template/features/collections/data/sync/collections_pull_reconciler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

class MockCollectionsRemoteDataSource extends Mock
    implements CollectionsRemoteDataSource {}

class MockCollectionsLocalDataSource extends Mock
    implements CollectionsLocalDataSource {}

class FakeCollectionEntity extends Fake implements CollectionEntity {}

void main() {
  late MockCollectionsRemoteDataSource remote;
  late MockCollectionsLocalDataSource local;
  late CollectionsPullReconciler reconciler;

  setUpAll(() => registerFallbackValue(FakeCollectionEntity()));

  final t0 = DateTime.utc(2025, 1, 1);
  final t1 = DateTime.utc(2025, 2, 1);

  CollectionDto dto(String id, {DateTime? updatedAt, String name = 'Server'}) =>
      CollectionDto(
        id: id,
        name: name,
        icon: 'f5fd',
        color: 0xFF6366F1,
        bookmarkIds: const ['b-1'],
        createdAt: t0,
        updatedAt: updatedAt ?? t0,
      );

  CollectionEntity entity({
    required String uuid,
    required DateTime updatedAt,
    int syncStateCode = 0,
    String name = 'Local',
  }) => CollectionEntity(
    id: uuid.hashCode,
    uuid: uuid,
    name: name,
    icon: 'f5fd',
    color: 0xFF6366F1,
    bookmarkIds: const ['b-1'],
    createdAt: t0,
    updatedAt: updatedAt,
    syncStateCode: syncStateCode,
  );

  setUp(() {
    remote = MockCollectionsRemoteDataSource();
    local = MockCollectionsLocalDataSource();
    when(() => local.put(any())).thenAnswer((_) async {});
    when(() => local.hardDelete(any())).thenAnswer((_) async {});
    reconciler = CollectionsPullReconciler(local, remote);
  });

  test('inserts server-only collections as synced', () async {
    when(() => remote.list()).thenAnswer((_) async => [dto('c-1')]);
    when(() => local.listAll()).thenAnswer((_) async => []);

    await reconciler.pull();

    final captured =
        verify(() => local.put(captureAny())).captured.single
            as CollectionEntity;
    expect(captured.uuid, 'c-1');
    expect(captured.syncState, SyncState.synced);
  });

  test(
    'updates local synced row when server is newer (last-write-wins)',
    () async {
      final local0 = entity(uuid: 'c-1', updatedAt: t0);
      when(() => remote.list()).thenAnswer(
        (_) async => [dto('c-1', updatedAt: t1, name: 'Newer')],
      );
      when(() => local.listAll()).thenAnswer((_) async => [local0]);

      await reconciler.pull();

      expect(local0.name, 'Newer');
      verify(() => local.put(local0)).called(1);
    },
  );

  test('skips locally pending rows during reconcile', () async {
    final pending = entity(
      uuid: 'c-1',
      updatedAt: t0,
      syncStateCode: SyncState.pendingUpdate.code,
    );
    when(() => remote.list()).thenAnswer(
      (_) async => [dto('c-1', updatedAt: t1)],
    );
    when(() => local.listAll()).thenAnswer((_) async => [pending]);

    await reconciler.pull();

    verifyNever(() => local.put(any()));
  });

  test('removes local synced rows the server no longer has', () async {
    final orphan = entity(uuid: 'c-9', updatedAt: t0);
    when(() => remote.list()).thenAnswer((_) async => []);
    when(() => local.listAll()).thenAnswer((_) async => [orphan]);

    await reconciler.pull();

    verify(() => local.hardDelete(orphan.id)).called(1);
  });
}
