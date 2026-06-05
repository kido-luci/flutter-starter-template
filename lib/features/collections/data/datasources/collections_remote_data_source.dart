import 'package:network/network.dart';

import '../models/collection_dto.dart';
import '../models/collection_request.dart';

part 'collections_remote_data_source.g.dart';

@RestApi()
abstract class CollectionsRemoteDataSource {
  factory CollectionsRemoteDataSource(Dio dio, {String baseUrl}) =
      _CollectionsRemoteDataSource;

  @GET('/api/collections')
  Future<List<CollectionDto>> list();

  @POST('/api/collections')
  Future<CollectionDto> create(@Body() CollectionRequest body);

  @PUT('/api/collections/{id}')
  Future<CollectionDto> update(
    @Path('id') String id,
    @Body() CollectionRequest body,
  );

  @DELETE('/api/collections/{id}')
  Future<void> delete(@Path('id') String id);
}
