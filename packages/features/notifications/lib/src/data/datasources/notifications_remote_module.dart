import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import 'notifications_remote_data_source.dart';

@module
abstract class NotificationsRemoteModule {
  @lazySingleton
  NotificationsRemoteDataSource provideNotificationsRemoteDataSource(Dio dio) =>
      NotificationsRemoteDataSource(dio);
}
