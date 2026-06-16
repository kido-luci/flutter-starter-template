import 'package:network/network.dart';

import '../models/bookmark_dto.dart';
import '../models/bookmark_request.dart';

part 'bookmarks_remote_data_source.g.dart';

@RestApi()
abstract class BookmarksRemoteDataSource {
  factory BookmarksRemoteDataSource(Dio dio, {String baseUrl}) =
      _BookmarksRemoteDataSource;

  /// Lists bookmarks. With [since], returns the delta (changed rows including
  /// tombstones) whose server revision is greater than it; without it, the full
  /// live list.
  @GET('/api/bookmarks')
  Future<List<BookmarkDto>> list({@Query('since') int? since});

  @POST('/api/bookmarks')
  Future<BookmarkDto> create(@Body() BookmarkRequest body);

  @PUT('/api/bookmarks/{id}')
  Future<BookmarkDto> update(
    @Path('id') String id,
    @Body() BookmarkRequest body,
    @Header('X-Expected-Rev') int? expectedRev,
  );

  @DELETE('/api/bookmarks/{id}')
  Future<void> delete(
    @Path('id') String id,
    @Header('X-Expected-Rev') int? expectedRev,
  );

  @POST('/api/upload')
  @MultiPart()
  Future<Map<String, String>> upload(@Part(name: 'file') MultipartFile file);
}
