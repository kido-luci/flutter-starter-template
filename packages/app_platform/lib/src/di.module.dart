// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:analytics/analytics.dart' as _i548;
import 'package:app_platform/src/crash/crash_module.dart' as _i1043;
import 'package:app_platform/src/crash/crash_reporter.dart' as _i608;
import 'package:app_platform/src/media/camera_service.dart' as _i883;
import 'package:app_platform/src/media/image_picker_service.dart' as _i315;
import 'package:app_platform/src/media/media_module.dart' as _i888;
import 'package:app_platform/src/media/video_player_service.dart' as _i430;
import 'package:app_platform/src/notifications/firebase_messaging_service.dart'
    as _i1010;
import 'package:app_platform/src/notifications/notifications_module.dart'
    as _i742;
import 'package:app_platform/src/notifications/notifications_service.dart'
    as _i479;
import 'package:app_platform/src/permissions/permission_service.dart' as _i735;
import 'package:app_platform/src/share/share_module.dart' as _i614;
import 'package:app_platform/src/share/share_service.dart' as _i527;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:image_picker/image_picker.dart' as _i183;
import 'package:injectable/injectable.dart' as _i526;
import 'package:share_plus/share_plus.dart' as _i998;

class AppPlatformPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final crashModule = _$CrashModule();
    final mediaModule = _$MediaModule();
    final notificationsModule = _$NotificationsModule();
    final shareModule = _$ShareModule();
    gh.lazySingleton<_i608.CrashReporter>(
      () => crashModule.provideCrashReporter(),
    );
    gh.lazySingleton<_i883.CameraService>(() => _i883.CameraService());
    gh.lazySingleton<_i183.ImagePicker>(() => mediaModule.imagePicker);
    gh.lazySingleton<_i430.VideoPlayerService>(
      () => _i430.VideoPlayerService(),
    );
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
      () => notificationsModule.providePlugin(),
    );
    gh.lazySingleton<_i892.FirebaseMessaging>(
      () => notificationsModule.provideFirebaseMessaging(),
    );
    gh.lazySingleton<_i735.PermissionService>(() => _i735.PermissionService());
    gh.lazySingleton<_i998.SharePlus>(() => shareModule.provideSharePlus());
    gh.lazySingleton<_i315.ImagePickerService>(
      () => _i315.ImagePickerService(gh<_i183.ImagePicker>()),
    );
    gh.lazySingleton<_i527.ShareService>(
      () => _i527.ShareService(gh<_i998.SharePlus>()),
    );
    gh.lazySingleton<_i479.NotificationsService>(
      () => _i479.NotificationsService(
        gh<_i163.FlutterLocalNotificationsPlugin>(),
        gh<_i735.PermissionService>(),
      ),
    );
    gh.lazySingleton<_i1010.FirebaseMessagingService>(
      () => _i1010.FirebaseMessagingService(
        gh<_i479.NotificationsService>(),
        gh<_i892.FirebaseMessaging>(),
        gh<_i548.AnalyticsService>(),
      ),
    );
  }
}

class _$CrashModule extends _i1043.CrashModule {}

class _$MediaModule extends _i888.MediaModule {}

class _$NotificationsModule extends _i742.NotificationsModule {}

class _$ShareModule extends _i614.ShareModule {}
