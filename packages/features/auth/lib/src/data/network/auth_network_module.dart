import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import '../datasources/auth_remote_data_source.dart';

@module
abstract class AuthNetworkModule {
  @lazySingleton
  AuthRemoteDataSource provideAuthRemoteDataSource(Dio dio) =>
      AuthRemoteDataSource(dio);
}
