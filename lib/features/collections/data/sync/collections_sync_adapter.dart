import 'package:network/network.dart';
import 'package:sync/sync.dart';

import '../datasources/collections_remote_data_source.dart';
import '../local/collection_entity.dart';
import '../models/collection_dto.dart';
import '../models/collection_request.dart';

/// Bridges the collections REST API to the generic sync engine: maps DTOs to
/// [RemoteRecord]s, sends the base revision for conflict detection, and
/// translates Dio errors into the engine's push outcomes and retryable /
/// terminal exceptions.
class CollectionsSyncAdapter implements SyncRemoteAdapter<CollectionEntity> {
  CollectionsSyncAdapter(this._remote);

  final CollectionsRemoteDataSource _remote;

  // 4xx codes worth retrying rather than giving up on: auth (token refresh may
  // recover), request timeout, and rate limiting.
  static const _retryable4xx = {401, 403, 408, 429};

  @override
  String get resource => 'collections';

  @override
  Future<void> beforePush(CollectionEntity row) async {}

  @override
  Future<PushResult<CollectionEntity>> create(CollectionEntity row) async {
    try {
      final dto = await _remote.create(_requestFor(row, includeId: true));
      return PushApplied(_record(dto));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) return const PushSuperseded();
      _classify(e);
    }
  }

  @override
  Future<PushResult<CollectionEntity>> update(CollectionEntity row) async {
    try {
      final dto = await _remote.update(
        row.uuid,
        _requestFor(row, includeId: false),
        _expectedRev(row),
      );
      return PushApplied(_record(dto));
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 409:
          return const PushConflict();
        case 404:
          return const PushGone();
        default:
          _classify(e);
      }
    }
  }

  @override
  Future<PushResult<CollectionEntity>> delete(CollectionEntity row) async {
    try {
      await _remote.delete(row.uuid, _expectedRev(row));
      return PushApplied(
        RemoteRecord<CollectionEntity>(
          uuid: row.uuid,
          rev: row.rev,
          updatedAt: row.updatedAt,
          deleted: true,
          build: () => row,
          apply: (_) {},
        ),
      );
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 404:
          return const PushGone();
        case 409:
          return const PushConflict();
        default:
          _classify(e);
      }
    }
  }

  @override
  Future<List<RemoteRecord<CollectionEntity>>> listSince(int cursor) async {
    final dtos = await _remote.list(since: cursor);
    return [for (final dto in dtos) _record(dto)];
  }

  int? _expectedRev(CollectionEntity row) => row.rev == 0 ? null : row.rev;

  CollectionRequest _requestFor(
    CollectionEntity row, {
    required bool includeId,
  }) {
    return CollectionRequest(
      id: includeId ? row.uuid : null,
      name: row.name,
      icon: row.icon,
      color: row.color,
      bookmarkIds: row.bookmarkIds,
    );
  }

  RemoteRecord<CollectionEntity> _record(CollectionDto dto) {
    return RemoteRecord<CollectionEntity>(
      uuid: dto.id,
      rev: dto.rev,
      updatedAt: dto.updatedAt,
      deleted: dto.deletedAt != null,
      build: () => _entityFromDto(dto),
      apply: (row) => _applyDto(row, dto),
    );
  }

  CollectionEntity _entityFromDto(CollectionDto dto) => CollectionEntity(
    uuid: dto.id,
    name: dto.name,
    icon: dto.icon,
    color: dto.color,
    bookmarkIds: List.of(dto.bookmarkIds),
    createdAt: dto.createdAt,
    updatedAt: dto.updatedAt,
    serverUpdatedAt: dto.updatedAt,
    rev: dto.rev,
    syncStateCode: SyncState.synced.code,
  );

  void _applyDto(CollectionEntity row, CollectionDto dto) {
    row
      ..name = dto.name
      ..icon = dto.icon
      ..color = dto.color
      ..bookmarkIds = List.of(dto.bookmarkIds)
      ..updatedAt = dto.updatedAt
      ..serverUpdatedAt = dto.updatedAt;
  }

  /// Maps a transport error to the engine's retry policy: most 4xx are terminal
  /// (the request won't succeed on retry); auth/timeout/rate-limit and 5xx /
  /// network errors are transient.
  Never _classify(DioException error) {
    final code = error.response?.statusCode;
    if (code != null &&
        code >= 400 &&
        code < 500 &&
        !_retryable4xx.contains(code)) {
      throw SyncTerminalException('HTTP $code: ${error.message}');
    }
    throw SyncTransientException(error.message);
  }
}
