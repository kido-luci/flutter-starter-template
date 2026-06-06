import 'package:architecture/architecture.dart';
import 'package:flutter_starter_template/features/bookmarks/data/local/bookmark_entity.dart';
import 'package:flutter_starter_template/features/bookmarks/data/local/bookmarks_local_data_source.dart';
import 'package:flutter_starter_template/features/bookmarks/data/repositories/bookmarks_repository_impl.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/entities/bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/services/bookmarks_sync_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync/sync.dart';
import 'package:test_utils/test_utils.dart';
import 'package:uuid/uuid.dart';

class MockBookmarksLocalDataSource extends Mock
    implements BookmarksLocalDataSource {}

class MockBookmarksSyncController extends Mock
    implements BookmarksSyncController {}

class MockUuid extends Mock implements Uuid {}

class FakeBookmarkEntity extends Fake implements BookmarkEntity {}

void main() {
  late MockBookmarksLocalDataSource mockLocal;
  late MockBookmarksSyncController mockSync;
  late MockUuid mockUuid;
  late BookmarksRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeBookmarkEntity());
  });

  final now = DateTime(2025, 6, 1, 12, 0, 0, 0, 0);

  BookmarkEntity createEntity({
    int id = 1,
    String uuid = 'b-1',
    String title = 'Flutter',
    String url = 'https://flutter.dev',
    String description = 'Flutter website',
    List<String> tags = const ['dev'],
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? serverUpdatedAt,
    int syncStateCode = 0, // synced
  }) {
    return BookmarkEntity(
      id: id,
      uuid: uuid,
      title: title,
      url: url,
      description: description,
      tags: tags,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      serverUpdatedAt: serverUpdatedAt,
      syncStateCode: syncStateCode,
    );
  }

  setUp(() {
    mockLocal = MockBookmarksLocalDataSource();
    mockSync = MockBookmarksSyncController();
    mockUuid = MockUuid();
    when(() => mockSync.sync()).thenAnswer((_) async {});
    repository = BookmarksRepositoryImpl(mockLocal, mockSync, mockUuid);
  });

  group('list', () {
    test('returns empty list when no bookmarks', () async {
      when(() => mockLocal.listVisible()).thenAnswer((_) async => []);

      final result = await repository.list();

      final ok = result as Ok<List<Bookmark>>;
      expect(ok.value, isEmpty);
      verify(() => mockSync.sync()).called(1);
    });

    test('returns bookmarks mapped from entities', () async {
      final entity = createEntity();
      when(() => mockLocal.listVisible()).thenAnswer((_) async => [entity]);

      final result = await repository.list();

      final ok = result as Ok<List<Bookmark>>;
      expect(ok.value.length, 1);
      expect(ok.value[0].id, 'b-1');
      expect(ok.value[0].title, 'Flutter');
    });
  });

  group('get', () {
    test('returns bookmark when found', () async {
      final entity = createEntity();
      when(() => mockLocal.getByUuid('b-1')).thenAnswer((_) async => entity);

      final result = await repository.get('b-1');

      final ok = result as Ok<Bookmark>;
      expect(ok.value.id, 'b-1');
    });

    test('returns NotFoundFailure when not found', () async {
      when(() => mockLocal.getByUuid('b-1')).thenAnswer((_) async => null);

      final result = await repository.get('b-1');

      expect(result, isA<Err<Bookmark>>());
      final err = result as Err<Bookmark>;
      expect(err.failure, isA<NotFoundFailure>());
    });

    test('returns NotFoundFailure when pendingDelete', () async {
      final entity = createEntity(syncStateCode: SyncState.pendingDelete.code);
      when(() => mockLocal.getByUuid('b-1')).thenAnswer((_) async => entity);

      final result = await repository.get('b-1');

      expect(result, isA<Err<Bookmark>>());
      final err = result as Err<Bookmark>;
      expect(err.failure, isA<NotFoundFailure>());
    });
  });

  group('create', () {
    const input = BookmarkInput(
      title: 'Flutter',
      url: 'https://flutter.dev',
      description: 'Flutter website',
      tags: ['dev'],
    );

    test('creates entity with trimmed and normalized input', () async {
      when(() => mockUuid.v4()).thenReturn('new-uuid');
      when(() => mockLocal.putNew(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments[0] as BookmarkEntity,
      );

      final result = await repository.create(
        const BookmarkInput(
          title: '  Flutter  ',
          url: 'https://flutter.dev  ',
          description: '  Flutter website  ',
          tags: ['  dev  ', ' dev ', '  dart  '],
        ),
      );

      final ok = result as Ok<Bookmark>;
      expect(ok.value.id, 'new-uuid');
      expect(ok.value.title, 'Flutter');
      expect(ok.value.url, 'https://flutter.dev');
      expect(ok.value.description, 'Flutter website');
      expect(ok.value.tags, ['dev', 'dart']);
      expect(ok.value.isPendingSync, isTrue);

      verify(() => mockSync.sync()).called(1);
    });

    test('puts entity with pendingCreate sync state', () async {
      when(() => mockUuid.v4()).thenReturn('new-uuid');
      when(() => mockLocal.putNew(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments[0] as BookmarkEntity,
      );

      await repository.create(input);

      final captured =
          verify(() => mockLocal.putNew(captureAny())).captured.single
              as BookmarkEntity;
      expect(captured.uuid, 'new-uuid');
      expect(captured.syncState, SyncState.pendingCreate);
      expect(captured.syncStateCode, SyncState.pendingCreate.code);
    });
  });

  group('update', () {
    const input = BookmarkInput(
      title: 'Updated',
      url: 'https://new.dev',
      description: 'Updated desc',
      tags: ['updated'],
    );

    test('returns NotFoundFailure when bookmark not found', () async {
      when(() => mockLocal.getByUuid('b-1')).thenAnswer((_) async => null);

      final result = await repository.update('b-1', input);

      expect(result, isA<Err<Bookmark>>());
      final err = result as Err<Bookmark>;
      expect(err.failure, isA<NotFoundFailure>());
    });

    test('returns NotFoundFailure when existing is pendingDelete', () async {
      final entity = createEntity(syncStateCode: SyncState.pendingDelete.code);
      when(() => mockLocal.getByUuid('b-1')).thenAnswer((_) async => entity);

      final result = await repository.update('b-1', input);

      expect(result, isA<Err<Bookmark>>());
    });

    test('transitions synced to pendingUpdate', () async {
      final entity = createEntity(syncStateCode: SyncState.synced.code);
      when(() => mockLocal.getByUuid('b-1')).thenAnswer((_) async => entity);
      when(() => mockLocal.put(any())).thenAnswer((_) async {});

      final result = await repository.update('b-1', input);

      final ok = result as Ok<Bookmark>;
      expect(ok.value.title, 'Updated');
      expect(entity.syncState, SyncState.pendingUpdate);
      verify(() => mockSync.sync()).called(1);
    });

    test('keeps pendingCreate when updating pendingCreate', () async {
      final entity = createEntity(syncStateCode: SyncState.pendingCreate.code);
      when(() => mockLocal.getByUuid('b-1')).thenAnswer((_) async => entity);
      when(() => mockLocal.put(any())).thenAnswer((_) async {});

      final result = await repository.update('b-1', input);

      final ok = result as Ok<Bookmark>;
      expect(ok.value.title, 'Updated');
      expect(entity.syncState, SyncState.pendingCreate);
      verify(() => mockSync.sync()).called(1);
    });
  });

  group('delete', () {
    test('returns NotFoundFailure when bookmark not found', () async {
      when(() => mockLocal.getByUuid('b-1')).thenAnswer((_) async => null);

      final result = await repository.delete('b-1');

      expect(result, isA<Err<void>>());
      final err = result as Err<void>;
      expect(err.failure, isA<NotFoundFailure>());
    });

    test('returns NotFoundFailure when already pendingDelete', () async {
      final entity = createEntity(syncStateCode: SyncState.pendingDelete.code);
      when(() => mockLocal.getByUuid('b-1')).thenAnswer((_) async => entity);

      final result = await repository.delete('b-1');

      expect(result, isA<Err<void>>());
    });

    test('hard deletes pendingCreate without sync', () async {
      final entity = createEntity(
        id: 42,
        syncStateCode: SyncState.pendingCreate.code,
      );
      when(() => mockLocal.getByUuid('b-1')).thenAnswer((_) async => entity);
      when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

      final result = await repository.delete('b-1');

      expect(result, isA<Ok<void>>());
      verify(() => mockLocal.hardDelete(entity)).called(1);
      verifyNever(() => mockSync.sync());
    });

    test('marks synced as pendingDelete and triggers sync', () async {
      final entity = createEntity(syncStateCode: SyncState.synced.code);
      when(() => mockLocal.getByUuid('b-1')).thenAnswer((_) async => entity);
      when(() => mockLocal.put(any())).thenAnswer((_) async {});

      final result = await repository.delete('b-1');

      expect(result, isA<Ok<void>>());
      expect(entity.syncState, SyncState.pendingDelete);
      verify(() => mockLocal.put(entity)).called(1);
      verify(() => mockSync.sync()).called(1);
    });
  });
}
