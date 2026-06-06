import 'package:network/network.dart';
import 'package:sync/sync.dart';

import '../datasources/bookmarks_remote_data_source.dart';
import '../local/bookmark_entity.dart';
import '../local/bookmarks_local_data_source.dart';
import '../models/bookmark_dto.dart';
import '../models/bookmark_request.dart';
import 'bookmark_media_upload_sync.dart';

/// Bridges the bookmarks REST API to the generic sync engine: maps DTOs to
/// [RemoteRecord]s, sends the base revision for conflict detection, and
/// translates Dio errors into the engine's push outcomes and retryable /
/// terminal exceptions.
class BookmarksSyncAdapter implements SyncRemoteAdapter<BookmarkEntity> {
  BookmarksSyncAdapter(
    BookmarksLocalDataSource local,
    this._remote, {
    BookmarkMediaUploadSync? mediaUploadSync,
  }) : _mediaUploadSync =
           mediaUploadSync ?? BookmarkMediaUploadSync(local, _remote);

  final BookmarksRemoteDataSource _remote;
  final BookmarkMediaUploadSync _mediaUploadSync;

  // 4xx codes worth retrying rather than giving up on: auth (token refresh may
  // recover), request timeout, and rate limiting.
  static const _retryable4xx = {401, 403, 408, 429};

  @override
  String get resource => 'bookmarks';

  @override
  Future<void> beforePush(BookmarkEntity row) =>
      _mediaUploadSync.checkpointUploads(row);

  @override
  Future<PushResult<BookmarkEntity>> create(BookmarkEntity row) async {
    try {
      final dto = await _remote.create(_requestFor(row, includeId: true));
      return PushApplied(_record(dto));
    } on DioException catch (e) {
      // 409: a previous attempt already created it server-side; treat as synced.
      if (e.response?.statusCode == 409) return const PushSuperseded();
      _classify(e);
    }
  }

  @override
  Future<PushResult<BookmarkEntity>> update(BookmarkEntity row) async {
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
  Future<PushResult<BookmarkEntity>> delete(BookmarkEntity row) async {
    try {
      await _remote.delete(row.uuid, _expectedRev(row));
      // The server returns no body; the engine hard-deletes locally on any
      // accepted/gone outcome, so a tombstone record built from the row
      // suffices.
      return PushApplied(
        RemoteRecord<BookmarkEntity>(
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
  Future<List<RemoteRecord<BookmarkEntity>>> listSince(int cursor) async {
    final dtos = await _remote.list(since: cursor);
    return [for (final dto in dtos) _record(dto)];
  }

  int? _expectedRev(BookmarkEntity row) => row.rev == 0 ? null : row.rev;

  BookmarkRequest _requestFor(BookmarkEntity row, {required bool includeId}) {
    return BookmarkRequest(
      id: includeId ? row.uuid : null,
      title: row.title,
      url: row.url,
      description: row.description,
      tags: row.tags,
      imageUrls: row.imageUrls,
      videoUrl: row.videoUrl,
    );
  }

  RemoteRecord<BookmarkEntity> _record(BookmarkDto dto) {
    return RemoteRecord<BookmarkEntity>(
      uuid: dto.id,
      rev: dto.rev,
      updatedAt: dto.updatedAt,
      deleted: dto.deletedAt != null,
      build: () => _entityFromDto(dto),
      apply: (row) => _applyDto(row, dto),
    );
  }

  BookmarkEntity _entityFromDto(BookmarkDto dto) => BookmarkEntity(
    uuid: dto.id,
    title: dto.title,
    url: dto.url,
    description: dto.description,
    tags: List.of(dto.tags),
    imageUrls: List.of(dto.imageUrls),
    videoUrl: dto.videoUrl,
    createdAt: dto.createdAt,
    updatedAt: dto.updatedAt,
    serverUpdatedAt: dto.updatedAt,
    rev: dto.rev,
    syncStateCode: SyncState.synced.code,
  );

  void _applyDto(BookmarkEntity row, BookmarkDto dto) {
    row
      ..title = dto.title
      ..url = dto.url
      ..description = dto.description
      ..tags = List.of(dto.tags)
      ..imageUrls = List.of(dto.imageUrls)
      ..videoUrl = dto.videoUrl
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
