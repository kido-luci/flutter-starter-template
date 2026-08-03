// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:database/database.dart' as _i252;
import 'package:feature_collections/src/data/datasources/collections_remote_data_source.dart'
    as _i596;
import 'package:feature_collections/src/data/datasources/collections_remote_module.dart'
    as _i990;
import 'package:feature_collections/src/data/local/collections_local_data_source.dart'
    as _i214;
import 'package:feature_collections/src/data/repositories/collections_repository_impl.dart'
    as _i614;
import 'package:feature_collections/src/data/sync/collections_sync_service.dart'
    as _i342;
import 'package:feature_collections/src/domain/repositories/collections_repository.dart'
    as _i709;
import 'package:feature_collections/src/domain/services/collections_summary_service.dart'
    as _i228;
import 'package:feature_collections/src/domain/services/collections_sync_controller.dart'
    as _i321;
import 'package:feature_collections/src/domain/usecases/create_collection.dart'
    as _i227;
import 'package:feature_collections/src/domain/usecases/delete_collection.dart'
    as _i67;
import 'package:feature_collections/src/domain/usecases/get_collection.dart'
    as _i562;
import 'package:feature_collections/src/domain/usecases/list_collections.dart'
    as _i300;
import 'package:feature_collections/src/domain/usecases/list_local_collections.dart'
    as _i878;
import 'package:feature_collections/src/domain/usecases/update_collection.dart'
    as _i200;
import 'package:feature_collections/src/presentation/bloc/add_to_collection/add_to_collection_cubit.dart'
    as _i846;
import 'package:feature_collections/src/presentation/bloc/collection_detail/collection_detail_cubit.dart'
    as _i916;
import 'package:feature_collections/src/presentation/bloc/collection_form/collection_form_cubit.dart'
    as _i511;
import 'package:feature_collections/src/presentation/bloc/collections_list/collections_list_bloc.dart'
    as _i352;
import 'package:injectable/injectable.dart' as _i526;
import 'package:network/network.dart' as _i372;
import 'package:rev_sync/rev_sync.dart' as _i520;
import 'package:shared_contracts/shared_contracts.dart' as _i856;
import 'package:uuid/uuid.dart' as _i706;

class FeatureCollectionsPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final collectionsRemoteModule = _$CollectionsRemoteModule();
    gh.lazySingleton<_i214.CollectionsLocalDataSource>(
      () => _i214.ObjectBoxCollectionsDataSource(gh<_i252.Store>()),
    );
    gh.lazySingleton<_i596.CollectionsRemoteDataSource>(
      () => collectionsRemoteModule.provideCollectionsRemoteDataSource(
        gh<_i372.Dio>(),
      ),
    );
    gh.lazySingleton<_i321.CollectionsSyncController>(
      () => _i342.CollectionsSyncService(
        gh<_i214.CollectionsLocalDataSource>(),
        gh<_i596.CollectionsRemoteDataSource>(),
        gh<_i520.ConnectivitySource>(),
        gh<_i520.SyncCursorStore>(),
      ),
    );
    gh.lazySingleton<_i709.CollectionsRepository>(
      () => _i614.CollectionsRepositoryImpl(
        gh<_i214.CollectionsLocalDataSource>(),
        gh<_i321.CollectionsSyncController>(),
        gh<_i706.Uuid>(),
      ),
    );
    gh.factory<_i227.CreateCollectionUseCase>(
      () => _i227.CreateCollectionUseCase(gh<_i709.CollectionsRepository>()),
    );
    gh.factory<_i67.DeleteCollectionUseCase>(
      () => _i67.DeleteCollectionUseCase(gh<_i709.CollectionsRepository>()),
    );
    gh.factory<_i562.GetCollectionUseCase>(
      () => _i562.GetCollectionUseCase(gh<_i709.CollectionsRepository>()),
    );
    gh.factory<_i300.ListCollectionsUseCase>(
      () => _i300.ListCollectionsUseCase(gh<_i709.CollectionsRepository>()),
    );
    gh.factory<_i878.ListLocalCollectionsUseCase>(
      () =>
          _i878.ListLocalCollectionsUseCase(gh<_i709.CollectionsRepository>()),
    );
    gh.factory<_i200.UpdateCollectionUseCase>(
      () => _i200.UpdateCollectionUseCase(gh<_i709.CollectionsRepository>()),
    );
    gh.factory<_i511.CollectionFormCubit>(
      () => _i511.CollectionFormCubit(
        gh<_i227.CreateCollectionUseCase>(),
        gh<_i200.UpdateCollectionUseCase>(),
        gh<_i562.GetCollectionUseCase>(),
      ),
    );
    gh.factory<_i846.AddToCollectionCubit>(
      () => _i846.AddToCollectionCubit(
        gh<_i300.ListCollectionsUseCase>(),
        gh<_i200.UpdateCollectionUseCase>(),
      ),
    );
    gh.lazySingleton<_i856.CollectionsReader>(
      () => _i228.CollectionsSummaryService(gh<_i300.ListCollectionsUseCase>()),
    );
    gh.factory<_i352.CollectionsListBloc>(
      () => _i352.CollectionsListBloc(
        gh<_i300.ListCollectionsUseCase>(),
        gh<_i878.ListLocalCollectionsUseCase>(),
        gh<_i67.DeleteCollectionUseCase>(),
        gh<_i321.CollectionsSyncController>(),
      ),
    );
    gh.factory<_i916.CollectionDetailCubit>(
      () => _i916.CollectionDetailCubit(
        gh<_i562.GetCollectionUseCase>(),
        gh<_i200.UpdateCollectionUseCase>(),
        gh<_i67.DeleteCollectionUseCase>(),
        gh<_i856.BookmarkSummariesReader>(),
      ),
    );
  }
}

class _$CollectionsRemoteModule extends _i990.CollectionsRemoteModule {}
