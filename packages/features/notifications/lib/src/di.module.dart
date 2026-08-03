// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:database/database.dart' as _i252;
import 'package:feature_notifications/src/data/datasources/notifications_remote_data_source.dart'
    as _i929;
import 'package:feature_notifications/src/data/datasources/notifications_remote_module.dart'
    as _i189;
import 'package:feature_notifications/src/data/local/notifications_local_data_source.dart'
    as _i1001;
import 'package:feature_notifications/src/data/repositories/notifications_repository_impl.dart'
    as _i899;
import 'package:feature_notifications/src/data/sync/notifications_sync_service.dart'
    as _i33;
import 'package:feature_notifications/src/domain/repositories/notifications_repository.dart'
    as _i705;
import 'package:feature_notifications/src/domain/services/notifications_sync_controller.dart'
    as _i309;
import 'package:feature_notifications/src/domain/usecases/get_notifications_feed.dart'
    as _i618;
import 'package:feature_notifications/src/domain/usecases/get_notifications_feed_local.dart'
    as _i590;
import 'package:feature_notifications/src/domain/usecases/mark_notification_read.dart'
    as _i122;
import 'package:feature_notifications/src/presentation/bloc/notifications_bloc.dart'
    as _i503;
import 'package:injectable/injectable.dart' as _i526;
import 'package:network/network.dart' as _i372;
import 'package:rev_sync/rev_sync.dart' as _i520;
import 'package:shared_contracts/shared_contracts.dart' as _i856;

class FeatureNotificationsPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final notificationsRemoteModule = _$NotificationsRemoteModule();
    gh.lazySingleton<_i1001.NotificationsLocalDataSource>(
      () => _i1001.ObjectBoxNotificationsDataSource(gh<_i252.Store>()),
    );
    gh.lazySingleton<_i929.NotificationsRemoteDataSource>(
      () => notificationsRemoteModule.provideNotificationsRemoteDataSource(
        gh<_i372.Dio>(),
      ),
    );
    gh.lazySingleton<_i309.NotificationsSyncController>(
      () => _i33.NotificationsSyncService(
        gh<_i1001.NotificationsLocalDataSource>(),
        gh<_i929.NotificationsRemoteDataSource>(),
        gh<_i520.ConnectivitySource>(),
      ),
    );
    gh.lazySingleton<_i705.NotificationsRepository>(
      () => _i899.NotificationsRepositoryImpl(
        gh<_i1001.NotificationsLocalDataSource>(),
        gh<_i309.NotificationsSyncController>(),
      ),
    );
    gh.factory<_i618.GetNotificationsFeedUseCase>(
      () => _i618.GetNotificationsFeedUseCase(
        gh<_i705.NotificationsRepository>(),
      ),
    );
    gh.factory<_i590.GetNotificationsFeedLocalUseCase>(
      () => _i590.GetNotificationsFeedLocalUseCase(
        gh<_i705.NotificationsRepository>(),
      ),
    );
    gh.factory<_i122.MarkNotificationReadUseCase>(
      () => _i122.MarkNotificationReadUseCase(
        gh<_i705.NotificationsRepository>(),
      ),
    );
    gh.lazySingleton<_i503.NotificationsBloc>(
      () => _i503.NotificationsBloc(
        gh<_i618.GetNotificationsFeedUseCase>(),
        gh<_i590.GetNotificationsFeedLocalUseCase>(),
        gh<_i122.MarkNotificationReadUseCase>(),
        gh<_i856.ActivityNotifier>(),
        gh<_i309.NotificationsSyncController>(),
      ),
    );
  }
}

class _$NotificationsRemoteModule extends _i189.NotificationsRemoteModule {}
