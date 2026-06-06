import 'package:architecture/architecture.dart';
import 'package:flutter_starter_template/features/collections/data/local/collection_entity.dart';
import 'package:flutter_starter_template/features/collections/data/local/collections_local_data_source.dart';
import 'package:flutter_starter_template/features/collections/data/repositories/collections_repository_impl.dart';
import 'package:flutter_starter_template/features/collections/domain/entities/collection.dart';
import 'package:flutter_starter_template/features/collections/domain/services/collections_sync_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync/sync.dart';
import 'package:test_utils/test_utils.dart';
import 'package:uuid/uuid.dart';

class MockCollectionsLocalDataSource extends Mock
    implements CollectionsLocalDataSource {}

class MockCollectionsSyncController extends Mock
    implements CollectionsSyncController {}

class MockUuid extends Mock implements Uuid {}

class FakeCollectionEntity extends Fake implements CollectionEntity {}

void main() {
  late MockCollectionsLocalDataSource mockLocal;
  late MockCollectionsSyncController mockSync;
  late MockUuid mockUuid;
  late CollectionsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeCollectionEntity());
  });

  final now = DateTime(2025, 6, 1, 12, 0, 0, 0, 0);

  CollectionEntity createEntity({
    int id = 1,
    String uuid = 'c-1',
    String name = 'Design',
    String icon = 'f5fd',
    int color = 0xFF6366F1,
    List<String> bookmarkIds = const ['b-1'],
    DateTime? createdAt,
    DateTime? updatedAt,
    int syncStateCode = 0, // synced
  }) {
    return CollectionEntity(
      id: id,
      uuid: uuid,
      name: name,
      icon: icon,
      color: color,
      bookmarkIds: List.of(bookmarkIds),
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      syncStateCode: syncStateCode,
    );
  }

  setUp(() {
    mockLocal = MockCollectionsLocalDataSource();
    mockSync = MockCollectionsSyncController();
    mockUuid = MockUuid();
    when(() => mockSync.sync()).thenAnswer((_) async {});
    repository = CollectionsRepositoryImpl(mockLocal, mockSync, mockUuid);
  });

  group('list', () {
    test(
      'returns collections mapped from entities and triggers sync',
      () async {
        when(
          () => mockLocal.listVisible(),
        ).thenAnswer((_) async => [createEntity()]);

        final result = await repository.list();

        final ok = result as Ok<List<Collection>>;
        expect(ok.value.single.id, 'c-1');
        expect(ok.value.single.itemCount, 1);
        verify(() => mockSync.sync()).called(1);
      },
    );
  });

  group('create', () {
    test('normalizes name + dedupes ids and marks pendingCreate', () async {
      when(() => mockUuid.v4()).thenReturn('new-uuid');
      when(() => mockLocal.putNew(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments[0] as CollectionEntity,
      );

      final result = await repository.create(
        const CollectionInput(
          name: '  Reading  ',
          icon: 'f02d',
          color: 0xFF0EA5E9,
          bookmarkIds: ['  b-1  ', 'b-1', '  b-2  '],
        ),
      );

      final ok = result as Ok<Collection>;
      expect(ok.value.id, 'new-uuid');
      expect(ok.value.name, 'Reading');
      expect(ok.value.bookmarkIds, ['b-1', 'b-2']);
      expect(ok.value.isPendingSync, isTrue);

      final captured =
          verify(() => mockLocal.putNew(captureAny())).captured.single
              as CollectionEntity;
      expect(captured.syncState, SyncState.pendingCreate);
      verify(() => mockSync.sync()).called(1);
    });
  });

  group('update', () {
    const input = CollectionInput(
      name: 'Updated',
      icon: 'f02d',
      color: 0xFF10B981,
      bookmarkIds: ['b-9'],
    );

    test('transitions synced to pendingUpdate', () async {
      final entity = createEntity();
      when(() => mockLocal.getByUuid('c-1')).thenAnswer((_) async => entity);
      when(() => mockLocal.put(any())).thenAnswer((_) async {});

      final result = await repository.update('c-1', input);

      final ok = result as Ok<Collection>;
      expect(ok.value.name, 'Updated');
      expect(ok.value.bookmarkIds, ['b-9']);
      expect(entity.syncState, SyncState.pendingUpdate);
      verify(() => mockSync.sync()).called(1);
    });

    test('keeps pendingCreate when updating pendingCreate', () async {
      final entity = createEntity(syncStateCode: SyncState.pendingCreate.code);
      when(() => mockLocal.getByUuid('c-1')).thenAnswer((_) async => entity);
      when(() => mockLocal.put(any())).thenAnswer((_) async {});

      await repository.update('c-1', input);

      expect(entity.syncState, SyncState.pendingCreate);
    });

    test('returns NotFoundFailure when missing', () async {
      when(() => mockLocal.getByUuid('c-1')).thenAnswer((_) async => null);

      final result = await repository.update('c-1', input);

      expect(result, isA<Err<Collection>>());
    });
  });

  group('delete', () {
    test('hard deletes pendingCreate without sync', () async {
      final entity = createEntity(
        id: 42,
        syncStateCode: SyncState.pendingCreate.code,
      );
      when(() => mockLocal.getByUuid('c-1')).thenAnswer((_) async => entity);
      when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

      final result = await repository.delete('c-1');

      expect(result, isA<Ok<void>>());
      verify(() => mockLocal.hardDelete(entity)).called(1);
      verifyNever(() => mockSync.sync());
    });

    test('marks synced as pendingDelete and triggers sync', () async {
      final entity = createEntity();
      when(() => mockLocal.getByUuid('c-1')).thenAnswer((_) async => entity);
      when(() => mockLocal.put(any())).thenAnswer((_) async {});

      final result = await repository.delete('c-1');

      expect(result, isA<Ok<void>>());
      expect(entity.syncState, SyncState.pendingDelete);
      verify(() => mockSync.sync()).called(1);
    });
  });
}
