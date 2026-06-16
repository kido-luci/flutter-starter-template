import 'package:network/network.dart';

import '../models/collection_dto.dart';
import '../models/collection_request.dart';

part 'collections_remote_data_source.g.dart';

@RestApi()
abstract class CollectionsRemoteDataSource {
  factory CollectionsRemoteDataSource(Dio dio, {String baseUrl}) =
      _CollectionsRemoteDataSource;

  /// Lists collections. With [since], returns the delta (changed rows including
  /// tombstones) whose server revision is greater than it; without it, the full
  /// live list.
  @GET('/api/collections')
  Future<List<CollectionDto>> list({@Query('since') int? since});

  @POST('/api/collections')
  Future<CollectionDto> create(@Body() CollectionRequest body);

  @PUT('/api/collections/{id}')
  Future<CollectionDto> update(
    @Path('id') String id,
    @Body() CollectionRequest body,
    @Header('X-Expected-Rev') int? expectedRev,
  );

  @DELETE('/api/collections/{id}')
  Future<void> delete(
    @Path('id') String id,
    @Header('X-Expected-Rev') int? expectedRev,
  );
}
