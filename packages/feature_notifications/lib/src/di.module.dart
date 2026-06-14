// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:feature_notifications/src/domain/repositories/notifications_repository.dart'
    as _i705;
import 'package:feature_notifications/src/domain/usecases/get_notifications_feed.dart'
    as _i618;
import 'package:feature_notifications/src/domain/usecases/get_notifications_feed_local.dart'
    as _i590;
import 'package:feature_notifications/src/domain/usecases/mark_notification_read.dart'
    as _i122;
import 'package:injectable/injectable.dart' as _i526;

class FeatureNotificationsPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.factory<_i618.GetNotificationsFeedUseCase>(() =>
        _i618.GetNotificationsFeedUseCase(gh<_i705.NotificationsRepository>()));
    gh.factory<_i590.GetNotificationsFeedLocalUseCase>(() =>
        _i590.GetNotificationsFeedLocalUseCase(
            gh<_i705.NotificationsRepository>()));
    gh.factory<_i122.MarkNotificationReadUseCase>(() =>
        _i122.MarkNotificationReadUseCase(gh<_i705.NotificationsRepository>()));
  }
}
