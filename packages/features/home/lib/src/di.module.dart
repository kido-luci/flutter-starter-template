// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:feature_home/src/presentation/bloc/home_bloc.dart' as _i854;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_contracts/shared_contracts.dart' as _i856;

class FeatureHomePackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.factory<_i854.HomeBloc>(() => _i854.HomeBloc(
          gh<_i856.BookmarkStatsReader>(),
          gh<_i856.CollectionsReader>(),
        ));
  }
}
