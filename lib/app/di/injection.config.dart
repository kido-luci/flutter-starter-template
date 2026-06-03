// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:analytics/analytics.dart' as _i548;
import 'package:app_platform/app_platform.dart' as _i199;
import 'package:config/config.dart' as _i259;
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:flutter_starter_template/core/data/database/object_box.dart'
    as _i706;
import 'package:flutter_starter_template/core/platform/firebase/firebase_service.dart'
    as _i473;
import 'package:flutter_starter_template/features/auth/data/datasources/auth_local_data_source.dart'
    as _i297;
import 'package:flutter_starter_template/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i87;
import 'package:flutter_starter_template/features/auth/data/network/auth_network_module.dart'
    as _i740;
import 'package:flutter_starter_template/features/auth/data/network/token_refresher.dart'
    as _i533;
import 'package:flutter_starter_template/features/auth/data/repositories/auth_repository_impl.dart'
    as _i1028;
import 'package:flutter_starter_template/features/auth/domain/repositories/auth_repository.dart'
    as _i987;
import 'package:flutter_starter_template/features/auth/domain/usecases/change_password.dart'
    as _i780;
import 'package:flutter_starter_template/features/auth/domain/usecases/delete_account.dart'
    as _i625;
import 'package:flutter_starter_template/features/auth/domain/usecases/register.dart'
    as _i699;
import 'package:flutter_starter_template/features/auth/domain/usecases/restore_session.dart'
    as _i271;
import 'package:flutter_starter_template/features/auth/domain/usecases/sign_in.dart'
    as _i1001;
import 'package:flutter_starter_template/features/auth/domain/usecases/sign_out.dart'
    as _i926;
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_bloc.dart'
    as _i269;
import 'package:flutter_starter_template/features/auth/presentation/bloc/change_password_cubit.dart'
    as _i11;
import 'package:flutter_starter_template/features/auth/presentation/bloc/delete_account_cubit.dart'
    as _i329;
import 'package:flutter_starter_template/features/bookmarks/data/bookmarks_data_module.dart'
    as _i179;
import 'package:flutter_starter_template/features/bookmarks/data/datasources/bookmarks_remote_data_source.dart'
    as _i729;
import 'package:flutter_starter_template/features/bookmarks/data/datasources/bookmarks_remote_module.dart'
    as _i235;
import 'package:flutter_starter_template/features/bookmarks/data/local/bookmarks_local_data_source.dart'
    as _i724;
import 'package:flutter_starter_template/features/bookmarks/data/repositories/bookmarks_repository_impl.dart'
    as _i73;
import 'package:flutter_starter_template/features/bookmarks/data/sync/bookmarks_sync_service.dart'
    as _i539;
import 'package:flutter_starter_template/features/bookmarks/domain/repositories/bookmarks_repository.dart'
    as _i630;
import 'package:flutter_starter_template/features/bookmarks/domain/services/bookmark_stats_service.dart'
    as _i405;
import 'package:flutter_starter_template/features/bookmarks/domain/services/bookmarks_sync_controller.dart'
    as _i627;
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/create_bookmark.dart'
    as _i632;
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/delete_bookmark.dart'
    as _i244;
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/get_bookmark.dart'
    as _i690;
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/list_bookmarks.dart'
    as _i568;
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/list_local_bookmarks.dart'
    as _i428;
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/update_bookmark.dart'
    as _i412;
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmark_detail/bookmark_detail_bloc.dart'
    as _i373;
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmark_form/bookmark_form_bloc.dart'
    as _i540;
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmarks_list/bookmarks_list_bloc.dart'
    as _i566;
import 'package:flutter_starter_template/features/home/presentation/bloc/home_bloc.dart'
    as _i423;
import 'package:flutter_starter_template/features/notifications/data/datasources/notifications_remote_data_source.dart'
    as _i937;
import 'package:flutter_starter_template/features/notifications/data/datasources/notifications_remote_module.dart'
    as _i951;
import 'package:flutter_starter_template/features/notifications/data/repositories/notifications_repository_impl.dart'
    as _i879;
import 'package:flutter_starter_template/features/notifications/domain/repositories/notifications_repository.dart'
    as _i578;
import 'package:flutter_starter_template/features/notifications/domain/usecases/get_notifications_feed.dart'
    as _i41;
import 'package:flutter_starter_template/features/notifications/domain/usecases/mark_notification_read.dart'
    as _i854;
import 'package:flutter_starter_template/features/notifications/presentation/bloc/notifications_bloc.dart'
    as _i642;
import 'package:flutter_starter_template/features/profile/presentation/bloc/profile_bloc.dart'
    as _i1013;
import 'package:flutter_starter_template/objectbox.g.dart' as _i831;
import 'package:flutter_starter_template/shared/domain/activity_notifier.dart'
    as _i855;
import 'package:flutter_starter_template/shared/domain/bookmark_stats.dart'
    as _i189;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:network/network.dart' as _i372;
import 'package:storage/storage.dart' as _i431;
import 'package:theme/theme.dart' as _i873;
import 'package:uuid/uuid.dart' as _i706;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    await _i548.CoreAnalyticsPackageModule().init(gh);
    await _i259.CoreConfigPackageModule().init(gh);
    await _i372.CoreNetworkPackageModule().init(gh);
    await _i199.CorePlatformPackageModule().init(gh);
    await _i431.CoreStoragePackageModule().init(gh);
    await _i873.CoreThemePackageModule().init(gh);
    final objectBoxModule = _$ObjectBoxModule();
    final secureStorageModule = _$SecureStorageModule();
    final bookmarksDataModule = _$BookmarksDataModule();
    final authNetworkModule = _$AuthNetworkModule();
    final bookmarksRemoteModule = _$BookmarksRemoteModule();
    final notificationsRemoteModule = _$NotificationsRemoteModule();
    await gh.singletonAsync<_i706.ObjectBox>(
      () => objectBoxModule.provideObjectBox(),
      preResolve: true,
    );
    gh.singleton<_i473.FirebaseService>(() => _i473.FirebaseService());
    gh.lazySingleton<_i431.FlutterSecureStorage>(
      () => secureStorageModule.provideSecureStorage(),
    );
    gh.lazySingleton<_i895.Connectivity>(
      () => bookmarksDataModule.provideConnectivity(),
    );
    gh.lazySingleton<_i706.Uuid>(() => bookmarksDataModule.provideUuid());
    gh.lazySingleton<_i855.ActivityNotifier>(() => _i855.ActivityNotifier());
    gh.singleton<_i831.Store>(
      () => objectBoxModule.provideStore(gh<_i706.ObjectBox>()),
    );
    gh.factory<_i1013.ProfileBloc>(
      () => _i1013.ProfileBloc(gh<_i548.AnalyticsService>()),
    );
    gh.lazySingleton<_i297.AuthLocalDataSource>(
      () => _i297.SecureStorageAuthDataSource(gh<_i431.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i724.BookmarksLocalDataSource>(
      () => _i724.ObjectBoxBookmarksDataSource(gh<_i831.Store>()),
    );
    gh.lazySingleton<_i533.TokenRefresher>(
      () => _i533.TokenRefresher(
        gh<_i297.AuthLocalDataSource>(),
        gh<_i372.Dio>(instanceName: 'plain'),
      ),
    );
    gh.lazySingleton<_i372.Dio>(
      () => authNetworkModule.provideDio(
        gh<_i297.AuthLocalDataSource>(),
        gh<_i533.TokenRefresher>(),
        gh<_i259.EnvConfig>(),
        gh<_i372.FirebasePerformance>(),
      ),
    );
    gh.lazySingleton<_i87.AuthRemoteDataSource>(
      () => authNetworkModule.provideAuthRemoteDataSource(gh<_i372.Dio>()),
    );
    gh.lazySingleton<_i729.BookmarksRemoteDataSource>(
      () => bookmarksRemoteModule.provideBookmarksRemoteDataSource(
        gh<_i372.Dio>(),
      ),
    );
    gh.lazySingleton<_i937.NotificationsRemoteDataSource>(
      () => notificationsRemoteModule.provideNotificationsRemoteDataSource(
        gh<_i372.Dio>(),
      ),
    );
    gh.lazySingleton<_i578.NotificationsRepository>(
      () => _i879.NotificationsRepositoryImpl(
        gh<_i937.NotificationsRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i627.BookmarksSyncController>(
      () => _i539.BookmarksSyncService(
        gh<_i724.BookmarksLocalDataSource>(),
        gh<_i729.BookmarksRemoteDataSource>(),
        gh<_i895.Connectivity>(),
      ),
    );
    gh.factory<_i41.GetNotificationsFeed>(
      () => _i41.GetNotificationsFeed(gh<_i578.NotificationsRepository>()),
    );
    gh.factory<_i854.MarkNotificationRead>(
      () => _i854.MarkNotificationRead(gh<_i578.NotificationsRepository>()),
    );
    gh.lazySingleton<_i987.AuthRepository>(
      () => _i1028.AuthRepositoryImpl(
        gh<_i87.AuthRemoteDataSource>(),
        gh<_i297.AuthLocalDataSource>(),
        gh<_i533.TokenRefresher>(),
      ),
    );
    gh.factory<_i780.ChangePassword>(
      () => _i780.ChangePassword(gh<_i987.AuthRepository>()),
    );
    gh.factory<_i625.DeleteAccount>(
      () => _i625.DeleteAccount(gh<_i987.AuthRepository>()),
    );
    gh.factory<_i699.Register>(
      () => _i699.Register(gh<_i987.AuthRepository>()),
    );
    gh.factory<_i271.RestoreSession>(
      () => _i271.RestoreSession(gh<_i987.AuthRepository>()),
    );
    gh.factory<_i1001.SignIn>(() => _i1001.SignIn(gh<_i987.AuthRepository>()));
    gh.factory<_i926.SignOut>(() => _i926.SignOut(gh<_i987.AuthRepository>()));
    gh.lazySingleton<_i630.BookmarksRepository>(
      () => _i73.BookmarksRepositoryImpl(
        gh<_i724.BookmarksLocalDataSource>(),
        gh<_i627.BookmarksSyncController>(),
        gh<_i706.Uuid>(),
      ),
    );
    gh.lazySingleton<_i642.NotificationsBloc>(
      () => _i642.NotificationsBloc(
        gh<_i41.GetNotificationsFeed>(),
        gh<_i854.MarkNotificationRead>(),
        gh<_i855.ActivityNotifier>(),
      ),
    );
    gh.factory<_i329.DeleteAccountCubit>(
      () => _i329.DeleteAccountCubit(
        gh<_i625.DeleteAccount>(),
        gh<_i548.AnalyticsService>(),
      ),
    );
    gh.factory<_i11.ChangePasswordCubit>(
      () => _i11.ChangePasswordCubit(gh<_i780.ChangePassword>()),
    );
    gh.lazySingleton<_i269.AuthBloc>(
      () => _i269.AuthBloc(
        signIn: gh<_i1001.SignIn>(),
        register: gh<_i699.Register>(),
        signOut: gh<_i926.SignOut>(),
        restoreSession: gh<_i271.RestoreSession>(),
        analytics: gh<_i548.AnalyticsService>(),
      ),
    );
    gh.factory<_i632.CreateBookmark>(
      () => _i632.CreateBookmark(gh<_i630.BookmarksRepository>()),
    );
    gh.factory<_i244.DeleteBookmark>(
      () => _i244.DeleteBookmark(gh<_i630.BookmarksRepository>()),
    );
    gh.factory<_i690.GetBookmark>(
      () => _i690.GetBookmark(gh<_i630.BookmarksRepository>()),
    );
    gh.factory<_i568.ListBookmarks>(
      () => _i568.ListBookmarks(gh<_i630.BookmarksRepository>()),
    );
    gh.factory<_i428.ListLocalBookmarks>(
      () => _i428.ListLocalBookmarks(gh<_i630.BookmarksRepository>()),
    );
    gh.factory<_i412.UpdateBookmark>(
      () => _i412.UpdateBookmark(gh<_i630.BookmarksRepository>()),
    );
    gh.factory<_i540.BookmarkFormBloc>(
      () => _i540.BookmarkFormBloc(
        gh<_i690.GetBookmark>(),
        gh<_i632.CreateBookmark>(),
        gh<_i412.UpdateBookmark>(),
        gh<_i548.AnalyticsService>(),
        gh<_i199.ImagePickerService>(),
        gh<_i199.PermissionService>(),
        gh<_i855.ActivityNotifier>(),
      ),
    );
    gh.factory<_i566.BookmarksListBloc>(
      () => _i566.BookmarksListBloc(
        gh<_i568.ListBookmarks>(),
        gh<_i428.ListLocalBookmarks>(),
        gh<_i244.DeleteBookmark>(),
        gh<_i627.BookmarksSyncController>(),
        gh<_i548.AnalyticsService>(),
        gh<_i199.ShareService>(),
      ),
    );
    gh.factory<_i373.BookmarkDetailBloc>(
      () => _i373.BookmarkDetailBloc(
        gh<_i690.GetBookmark>(),
        gh<_i244.DeleteBookmark>(),
        gh<_i548.AnalyticsService>(),
        gh<_i199.ShareService>(),
      ),
    );
    gh.lazySingleton<_i189.BookmarkStatsReader>(
      () => _i405.BookmarkStatsService(gh<_i568.ListBookmarks>()),
    );
    gh.factory<_i423.HomeBloc>(
      () => _i423.HomeBloc(gh<_i189.BookmarkStatsReader>()),
    );
    return this;
  }
}

class _$ObjectBoxModule extends _i706.ObjectBoxModule {}

class _$SecureStorageModule extends _i297.SecureStorageModule {}

class _$BookmarksDataModule extends _i179.BookmarksDataModule {}

class _$AuthNetworkModule extends _i740.AuthNetworkModule {}

class _$BookmarksRemoteModule extends _i235.BookmarksRemoteModule {}

class _$NotificationsRemoteModule extends _i951.NotificationsRemoteModule {}
