import 'package:flutter_starter_template/features/collections/data/datasources/collections_remote_data_source.dart';
import 'package:flutter_starter_template/features/collections/data/local/collection_entity.dart';
import 'package:flutter_starter_template/features/collections/data/models/collection_dto.dart';
import 'package:flutter_starter_template/features/collections/data/models/collection_request.dart';
import 'package:flutter_starter_template/features/collections/data/sync/collections_sync_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:sync/sync.dart';
import 'package:test_utils/test_utils.dart';

class MockCollectionsRemoteDataSource extends Mock
    implements CollectionsRemoteDataSource {}

class FakeCollectionRequest extends Fake implements CollectionRequest {}

DioException _dioError(int status) => DioException(
  requestOptions: RequestOptions(path: '/'),
  response: Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: status,
  ),
);

CollectionEntity _entity({int rev = 0}) => CollectionEntity(
  uuid: 'c-1',
  name: 'Design',
  icon: 'f5fd',
  color: 1,
  bookmarkIds: const ['b1'],
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  rev: rev,
);

CollectionDto _dto({int rev = 1, DateTime? deletedAt}) => CollectionDto(
  id: 'c-1',
  name: 'Server',
  icon: 'f5fd',
  color: 1,
  bookmarkIds: const ['b1'],
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  rev: rev,
  deletedAt: deletedAt,
);

void main() {
  late MockCollectionsRemoteDataSource remote;
  late CollectionsSyncAdapter adapter;

  setUpAll(() => registerFallbackValue(FakeCollectionRequest()));

  setUp(() {
    remote = MockCollectionsRemoteDataSource();
    adapter = CollectionsSyncAdapter(remote);
  });

  group('create', () {
    test(
      'maps a successful create to PushApplied with the server record',
      () async {
        when(() => remote.create(any())).thenAnswer((_) async => _dto(rev: 5));

        final result = await adapter.create(_entity());

        expect(result, isA<PushApplied<CollectionEntity>>());
        expect((result as PushApplied<CollectionEntity>).record.rev, 5);
      },
    );

    test('treats a 409 as already-created (PushSuperseded)', () async {
      when(() => remote.create(any())).thenThrow(_dioError(409));

      expect(
        await adapter.create(_entity()),
        isA<PushSuperseded<CollectionEntity>>(),
      );
    });

    test('a 400 is terminal and a 500 is transient', () async {
      when(() => remote.create(any())).thenThrow(_dioError(400));
      expect(
        () => adapter.create(_entity()),
        throwsA(isA<SyncTerminalException>()),
      );

      when(() => remote.create(any())).thenThrow(_dioError(500));
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

      expect(result, isA<PushConflict<CollectionEntity>>());
      verify(() => remote.update('c-1', any(), 7)).called(1);
    });

    test('maps 404 to PushGone', () async {
      when(() => remote.update(any(), any(), any())).thenThrow(_dioError(404));

      expect(
        await adapter.update(_entity(rev: 2)),
        isA<PushGone<CollectionEntity>>(),
      );
    });
  });

  group('delete / listSince', () {
    test('a successful delete sends the base rev', () async {
      when(() => remote.delete(any(), any())).thenAnswer((_) async {});

      expect(
        await adapter.delete(_entity(rev: 3)),
        isA<PushApplied<CollectionEntity>>(),
      );
      verify(() => remote.delete('c-1', 3)).called(1);
    });

    test('a 404 delete is PushGone', () async {
      when(() => remote.delete(any(), any())).thenThrow(_dioError(404));

      expect(
        await adapter.delete(_entity(rev: 3)),
        isA<PushGone<CollectionEntity>>(),
      );
    });

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
