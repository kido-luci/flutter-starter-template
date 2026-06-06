import 'package:flutter_starter_template/features/bookmarks/data/datasources/bookmarks_remote_data_source.dart';
import 'package:flutter_starter_template/features/bookmarks/data/local/bookmark_entity.dart';
import 'package:flutter_starter_template/features/bookmarks/data/local/bookmarks_local_data_source.dart';
import 'package:flutter_starter_template/features/bookmarks/data/models/bookmark_dto.dart';
import 'package:flutter_starter_template/features/bookmarks/data/models/bookmark_request.dart';
import 'package:flutter_starter_template/features/bookmarks/data/sync/bookmark_media_upload_sync.dart';
import 'package:flutter_starter_template/features/bookmarks/data/sync/bookmarks_sync_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:sync/sync.dart';
import 'package:test_utils/test_utils.dart';

class MockBookmarksLocalDataSource extends Mock
    implements BookmarksLocalDataSource {}

class MockBookmarksRemoteDataSource extends Mock
    implements BookmarksRemoteDataSource {}

class MockMediaUploadSync extends Mock implements BookmarkMediaUploadSync {}

class FakeBookmarkRequest extends Fake implements BookmarkRequest {}

DioException _dioError(int status) => DioException(
  requestOptions: RequestOptions(path: '/'),
  response: Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: status,
  ),
);

BookmarkEntity _entity({int rev = 0, int syncStateCode = 0}) => BookmarkEntity(
  uuid: 'b-1',
  title: 'T',
  url: 'https://x',
  description: 'd',
  tags: const ['dev'],
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  rev: rev,
  syncStateCode: syncStateCode,
);

BookmarkDto _dto({int rev = 1, DateTime? deletedAt}) => BookmarkDto(
  id: 'b-1',
  title: 'Server',
  url: 'https://x',
  description: 'd',
  tags: const ['dev'],
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  rev: rev,
  deletedAt: deletedAt,
);

void main() {
  late MockBookmarksLocalDataSource local;
  late MockBookmarksRemoteDataSource remote;
  late MockMediaUploadSync media;
  late BookmarksSyncAdapter adapter;

  setUpAll(() => registerFallbackValue(FakeBookmarkRequest()));

  setUp(() {
    local = MockBookmarksLocalDataSource();
    remote = MockBookmarksRemoteDataSource();
    media = MockMediaUploadSync();
    adapter = BookmarksSyncAdapter(local, remote, mediaUploadSync: media);
  });

  group('create', () {
    test(
      'maps a successful create to PushApplied with the server record',
      () async {
        when(() => remote.create(any())).thenAnswer((_) async => _dto(rev: 5));

        final result = await adapter.create(_entity());

        expect(result, isA<PushApplied<BookmarkEntity>>());
        final record = (result as PushApplied<BookmarkEntity>).record;
        expect(record.rev, 5);
        // The record applies server-authoritative fields onto a row.
        final row = _entity();
        record.apply(row);
        expect(row.title, 'Server');
      },
    );

    test('treats a 409 as already-created (PushSuperseded)', () async {
      when(() => remote.create(any())).thenThrow(_dioError(409));

      expect(
        await adapter.create(_entity()),
        isA<PushSuperseded<BookmarkEntity>>(),
      );
    });

    test('a 400 is a terminal failure', () async {
      when(() => remote.create(any())).thenThrow(_dioError(400));

      expect(
        () => adapter.create(_entity()),
        throwsA(isA<SyncTerminalException>()),
      );
    });

    test('a 500 is a transient failure', () async {
      when(() => remote.create(any())).thenThrow(_dioError(500));

      expect(
        () => adapter.create(_entity()),
        throwsA(isA<SyncTransientException>()),
      );
    });

    test('a 401 is transient (auth refresh may recover)', () async {
      when(() => remote.create(any())).thenThrow(_dioError(401));

      expect(
        () => adapter.create(_entity()),
        throwsA(isA<SyncTransientException>()),
      );
    });
  });

  group('update', () {
    test('sends the base rev and maps 409 to PushConflict', () async {
      when(() => remote.update(any(), any(), any())).thenThrow(_dioError(409));

      final result = await adapter.update(_entity(rev: 7));

      expect(result, isA<PushConflict<BookmarkEntity>>());
      verify(() => remote.update('b-1', any(), 7)).called(1);
    });

    test('maps 404 to PushGone', () async {
      when(() => remote.update(any(), any(), any())).thenThrow(_dioError(404));

      expect(
        await adapter.update(_entity(rev: 2)),
        isA<PushGone<BookmarkEntity>>(),
      );
    });
  });

  group('delete', () {
    test('a successful delete is accepted', () async {
      when(() => remote.delete(any(), any())).thenAnswer((_) async {});

      expect(
        await adapter.delete(_entity(rev: 3)),
        isA<PushApplied<BookmarkEntity>>(),
      );
      verify(() => remote.delete('b-1', 3)).called(1);
    });

    test('a 404 delete is PushGone', () async {
      when(() => remote.delete(any(), any())).thenThrow(_dioError(404));

      expect(
        await adapter.delete(_entity(rev: 3)),
        isA<PushGone<BookmarkEntity>>(),
      );
    });
  });

  group('listSince', () {
    test('passes the cursor and maps tombstones to deleted records', () async {
      when(() => remote.list(since: any(named: 'since'))).thenAnswer(
        (_) async => [_dto(rev: 4, deletedAt: DateTime(2026, 2))],
      );

      final records = await adapter.listSince(2);

      verify(() => remote.list(since: 2)).called(1);
      expect(records.single.deleted, isTrue);
      expect(records.single.rev, 4);
    });
  });
}
