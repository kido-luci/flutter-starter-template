// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:analytics/analytics.dart' as _i548;
import 'package:feature_auth/src/data/datasources/auth_local_data_source.dart'
    as _i887;
import 'package:feature_auth/src/data/datasources/auth_remote_data_source.dart'
    as _i371;
import 'package:feature_auth/src/data/network/auth_network_module.dart'
    as _i692;
import 'package:feature_auth/src/data/repositories/auth_repository_impl.dart'
    as _i953;
import 'package:feature_auth/src/domain/repositories/auth_repository.dart'
    as _i1063;
import 'package:feature_auth/src/domain/usecases/change_password.dart' as _i359;
import 'package:feature_auth/src/domain/usecases/delete_account.dart' as _i884;
import 'package:feature_auth/src/domain/usecases/register.dart' as _i821;
import 'package:feature_auth/src/domain/usecases/restore_session.dart' as _i63;
import 'package:feature_auth/src/domain/usecases/sign_in.dart' as _i147;
import 'package:feature_auth/src/domain/usecases/sign_out.dart' as _i1002;
import 'package:feature_auth/src/presentation/bloc/auth_bloc.dart' as _i1014;
import 'package:feature_auth/src/presentation/bloc/change_password_cubit.dart'
    as _i1062;
import 'package:feature_auth/src/presentation/bloc/delete_account_cubit.dart'
    as _i1061;
import 'package:injectable/injectable.dart' as _i526;
import 'package:network/network.dart' as _i372;
import 'package:storage/storage.dart' as _i431;

class FeatureAuthPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final authNetworkModule = _$AuthNetworkModule();
    gh.lazySingleton<_i887.AuthLocalDataSource>(
        () => _i887.SecureStorageAuthDataSource(
              gh<_i431.FlutterSecureStorage>(),
              gh<_i431.AuthTokenStore>(),
            ));
    gh.lazySingleton<_i371.AuthRemoteDataSource>(
        () => authNetworkModule.provideAuthRemoteDataSource(gh<_i372.Dio>()));
    gh.lazySingleton<_i1063.AuthRepository>(() => _i953.AuthRepositoryImpl(
          gh<_i371.AuthRemoteDataSource>(),
          gh<_i887.AuthLocalDataSource>(),
          gh<_i372.TokenRefresher>(),
        ));
    gh.factory<_i359.ChangePasswordUseCase>(
        () => _i359.ChangePasswordUseCase(gh<_i1063.AuthRepository>()));
    gh.factory<_i884.DeleteAccountUseCase>(
        () => _i884.DeleteAccountUseCase(gh<_i1063.AuthRepository>()));
    gh.factory<_i821.RegisterUseCase>(
        () => _i821.RegisterUseCase(gh<_i1063.AuthRepository>()));
    gh.factory<_i63.RestoreSessionUseCase>(
        () => _i63.RestoreSessionUseCase(gh<_i1063.AuthRepository>()));
    gh.factory<_i147.SignInUseCase>(
        () => _i147.SignInUseCase(gh<_i1063.AuthRepository>()));
    gh.factory<_i1002.SignOutUseCase>(
        () => _i1002.SignOutUseCase(gh<_i1063.AuthRepository>()));
    gh.factory<_i1061.DeleteAccountCubit>(() => _i1061.DeleteAccountCubit(
          gh<_i884.DeleteAccountUseCase>(),
          gh<_i548.AnalyticsService>(),
        ));
    gh.factory<_i1062.ChangePasswordCubit>(
        () => _i1062.ChangePasswordCubit(gh<_i359.ChangePasswordUseCase>()));
    gh.lazySingleton<_i1014.AuthBloc>(() => _i1014.AuthBloc(
          signIn: gh<_i147.SignInUseCase>(),
          register: gh<_i821.RegisterUseCase>(),
          signOut: gh<_i1002.SignOutUseCase>(),
          restoreSession: gh<_i63.RestoreSessionUseCase>(),
          analytics: gh<_i548.AnalyticsService>(),
        ));
  }
}

class _$AuthNetworkModule extends _i692.AuthNetworkModule {}
