import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import 'collections_remote_data_source.dart';

@module
abstract class CollectionsRemoteModule {
  @lazySingleton
  CollectionsRemoteDataSource provideCollectionsRemoteDataSource(Dio dio) =>
      CollectionsRemoteDataSource(dio);
}
