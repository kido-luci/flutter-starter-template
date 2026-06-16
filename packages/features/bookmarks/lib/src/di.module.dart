// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:analytics/analytics.dart' as _i548;
import 'package:app_platform/app_platform.dart' as _i199;
import 'package:database/database.dart' as _i252;
import 'package:feature_bookmarks/src/data/datasources/bookmarks_remote_data_source.dart'
    as _i436;
import 'package:feature_bookmarks/src/data/datasources/bookmarks_remote_module.dart'
    as _i781;
import 'package:feature_bookmarks/src/data/local/bookmarks_local_data_source.dart'
    as _i524;
import 'package:feature_bookmarks/src/data/repositories/bookmarks_repository_impl.dart'
    as _i967;
import 'package:feature_bookmarks/src/data/sync/bookmarks_sync_service.dart'
    as _i353;
import 'package:feature_bookmarks/src/domain/repositories/bookmarks_repository.dart'
    as _i263;
import 'package:feature_bookmarks/src/domain/services/bookmark_stats_service.dart'
    as _i808;
import 'package:feature_bookmarks/src/domain/services/bookmark_summaries_service.dart'
    as _i976;
import 'package:feature_bookmarks/src/domain/services/bookmarks_sync_controller.dart'
    as _i699;
import 'package:feature_bookmarks/src/domain/usecases/create_bookmark.dart'
    as _i806;
import 'package:feature_bookmarks/src/domain/usecases/delete_bookmark.dart'
    as _i135;
import 'package:feature_bookmarks/src/domain/usecases/get_bookmark.dart'
    as _i118;
import 'package:feature_bookmarks/src/domain/usecases/list_bookmarks.dart'
    as _i416;
import 'package:feature_bookmarks/src/domain/usecases/list_local_bookmarks.dart'
    as _i1010;
import 'package:feature_bookmarks/src/domain/usecases/update_bookmark.dart'
    as _i310;
import 'package:feature_bookmarks/src/presentation/bloc/bookmark_detail/bookmark_detail_bloc.dart'
    as _i1005;
import 'package:feature_bookmarks/src/presentation/bloc/bookmark_form/bookmark_form_bloc.dart'
    as _i278;
import 'package:feature_bookmarks/src/presentation/bloc/bookmarks_list/bookmarks_list_bloc.dart'
    as _i330;
import 'package:injectable/injectable.dart' as _i526;
import 'package:network/network.dart' as _i372;
import 'package:shared_contracts/shared_contracts.dart' as _i856;
import 'package:sync/sync.dart' as _i846;
import 'package:uuid/uuid.dart' as _i706;

class FeatureBookmarksPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final bookmarksRemoteModule = _$BookmarksRemoteModule();
    gh.lazySingleton<_i436.BookmarksRemoteDataSource>(
      () => bookmarksRemoteModule.provideBookmarksRemoteDataSource(
        gh<_i372.Dio>(),
      ),
    );
    gh.lazySingleton<_i524.BookmarksLocalDataSource>(
      () => _i524.ObjectBoxBookmarksDataSource(gh<_i252.Store>()),
    );
    gh.lazySingleton<_i699.BookmarksSyncController>(
      () => _i353.BookmarksSyncService(
        gh<_i524.BookmarksLocalDataSource>(),
        gh<_i436.BookmarksRemoteDataSource>(),
        gh<_i846.ConnectivitySource>(),
        gh<_i846.SyncCursorStore>(),
      ),
    );
    gh.lazySingleton<_i263.BookmarksRepository>(
      () => _i967.BookmarksRepositoryImpl(
        gh<_i524.BookmarksLocalDataSource>(),
        gh<_i699.BookmarksSyncController>(),
        gh<_i706.Uuid>(),
      ),
    );
    gh.factory<_i806.CreateBookmarkUseCase>(
      () => _i806.CreateBookmarkUseCase(gh<_i263.BookmarksRepository>()),
    );
    gh.factory<_i135.DeleteBookmarkUseCase>(
      () => _i135.DeleteBookmarkUseCase(gh<_i263.BookmarksRepository>()),
    );
    gh.factory<_i118.GetBookmarkUseCase>(
      () => _i118.GetBookmarkUseCase(gh<_i263.BookmarksRepository>()),
    );
    gh.factory<_i416.ListBookmarksUseCase>(
      () => _i416.ListBookmarksUseCase(gh<_i263.BookmarksRepository>()),
    );
    gh.factory<_i1010.ListLocalBookmarksUseCase>(
      () => _i1010.ListLocalBookmarksUseCase(gh<_i263.BookmarksRepository>()),
    );
    gh.factory<_i310.UpdateBookmarkUseCase>(
      () => _i310.UpdateBookmarkUseCase(gh<_i263.BookmarksRepository>()),
    );
    gh.factory<_i1005.BookmarkDetailBloc>(
      () => _i1005.BookmarkDetailBloc(
        gh<_i118.GetBookmarkUseCase>(),
        gh<_i135.DeleteBookmarkUseCase>(),
        gh<_i548.AnalyticsService>(),
        gh<_i199.ShareService>(),
      ),
    );
    gh.factory<_i330.BookmarksListBloc>(
      () => _i330.BookmarksListBloc(
        gh<_i416.ListBookmarksUseCase>(),
        gh<_i1010.ListLocalBookmarksUseCase>(),
        gh<_i135.DeleteBookmarkUseCase>(),
        gh<_i699.BookmarksSyncController>(),
        gh<_i548.AnalyticsService>(),
        gh<_i199.ShareService>(),
      ),
    );
    gh.lazySingleton<_i856.BookmarkStatsReader>(
      () => _i808.BookmarkStatsService(gh<_i416.ListBookmarksUseCase>()),
    );
    gh.lazySingleton<_i856.BookmarkSummariesReader>(
      () => _i976.BookmarkSummariesService(gh<_i416.ListBookmarksUseCase>()),
    );
    gh.factory<_i278.BookmarkFormBloc>(
      () => _i278.BookmarkFormBloc(
        gh<_i118.GetBookmarkUseCase>(),
        gh<_i806.CreateBookmarkUseCase>(),
        gh<_i310.UpdateBookmarkUseCase>(),
        gh<_i548.AnalyticsService>(),
        gh<_i199.ImagePickerService>(),
        gh<_i199.PermissionService>(),
        gh<_i856.ActivityNotifier>(),
      ),
    );
  }
}

class _$BookmarksRemoteModule extends _i781.BookmarksRemoteModule {}
