// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:hive/hive.dart' as _i979;
import 'package:injectable/injectable.dart' as _i526;

import '../../app/router/app_router.dart' as _i180;
import '../../app/router/route_guards.dart' as _i469;
import '../../features/profile/data/datasources/profile_remote_data_source.dart'
    as _i847;
import '../../features/profile/data/datasources/profile_remote_data_source_impl.dart'
    as _i1036;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/domain/usecases/change_password_usecase.dart'
    as _i550;
import '../../features/profile/domain/usecases/deactivate_account_usecase.dart'
    as _i761;
import '../../features/profile/domain/usecases/get_profile_usecase.dart'
    as _i965;
import '../../features/profile/domain/usecases/logout_usecase.dart' as _i17;
import '../../features/profile/domain/usecases/update_demographics_usecase.dart'
    as _i829;
import '../../features/profile/presentation/bloc/profile_bloc.dart' as _i469;
import '../../features/vitals_sync/data/datasources/vitals_local_data_source.dart'
    as _i75;
import '../../features/vitals_sync/data/datasources/vitals_local_data_source_impl.dart'
    as _i269;
import '../../features/vitals_sync/data/datasources/vitals_remote_data_source.dart'
    as _i630;
import '../../features/vitals_sync/data/datasources/vitals_remote_data_source_impl.dart'
    as _i267;
import '../../features/vitals_sync/data/repositories/vitals_repository_impl.dart'
    as _i1029;
import '../../features/vitals_sync/domain/repositories/vitals_repository.dart'
    as _i84;
import '../../features/vitals_sync/domain/usecases/get_pending_vitals_usecase.dart'
    as _i356;
import '../../features/vitals_sync/domain/usecases/get_unified_vitals_history_usecase.dart'
    as _i677;
import '../../features/vitals_sync/domain/usecases/save_home_vital_offline_usecase.dart'
    as _i1051;
import '../../features/vitals_sync/domain/usecases/sync_vitals_usecase.dart'
    as _i404;
import '../../features/vitals_sync/presentation/bloc/vitals_sync_bloc.dart'
    as _i838;
import '../../features/vitals_sync/vitals_module.dart' as _i285;
import '../network/api_client.dart' as _i557;
import '../network/network_info.dart' as _i932;
import '../notifications/local_alarm_scheduler.dart' as _i949;
import '../notifications/notification_service.dart' as _i229;
import '../storage/cookie_storage_service.dart' as _i916;
import '../storage/local_database_service.dart' as _i605;
import '../storage/secure_storage_service.dart' as _i666;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    final vitalsModule = _$VitalsModule();
    gh.lazySingleton<_i180.AppRouter>(() => _i180.AppRouter());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
        () => registerModule.secureStorage);
    gh.lazySingleton<_i229.NotificationService>(
        () => _i229.NotificationService());
    gh.lazySingleton<_i605.LocalDatabaseService>(
        () => _i605.LocalDatabaseService());
    gh.lazySingleton<_i979.Box<dynamic>>(() => vitalsModule.vitalsBox);
    gh.lazySingleton<_i916.CookieStorageService>(
        () => _i916.CookieStorageService(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i932.NetworkInfo>(() => _i932.NetworkInfoImpl());
    gh.lazySingleton<_i949.LocalAlarmScheduler>(
        () => _i949.LocalAlarmScheduler(gh<_i229.NotificationService>()));
    gh.lazySingletonAsync<_i557.ApiClient>(
        () => _i557.ApiClient.create(gh<_i916.CookieStorageService>()));
    gh.lazySingleton<_i75.VitalsLocalDataSource>(
        () => _i269.VitalsLocalDataSourceImpl(gh<_i979.Box<dynamic>>()));
    gh.lazySingleton<_i666.SecureStorageService>(
        () => _i666.SecureStorageService(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i469.RouteGuards>(
        () => _i469.RouteGuards(gh<_i666.SecureStorageService>()));
    gh.lazySingletonAsync<_i630.VitalsRemoteDataSource>(() async =>
        _i267.VitalsRemoteDataSourceImpl(await getAsync<_i557.ApiClient>()));
    gh.lazySingletonAsync<_i847.ProfileRemoteDataSource>(() async =>
        _i1036.ProfileRemoteDataSourceImpl(await getAsync<_i557.ApiClient>()));
    gh.lazySingletonAsync<_i894.ProfileRepository>(() async =>
        _i334.ProfileRepositoryImpl(
            await getAsync<_i847.ProfileRemoteDataSource>()));
    gh.lazySingletonAsync<_i84.VitalsRepository>(
        () async => _i1029.VitalsRepositoryImpl(
              local: gh<_i75.VitalsLocalDataSource>(),
              remote: await getAsync<_i630.VitalsRemoteDataSource>(),
            ));
    gh.factoryAsync<_i550.ChangePasswordUseCase>(() async =>
        _i550.ChangePasswordUseCase(await getAsync<_i894.ProfileRepository>()));
    gh.factoryAsync<_i761.DeactivateAccountUseCase>(() async =>
        _i761.DeactivateAccountUseCase(
            await getAsync<_i894.ProfileRepository>()));
    gh.factoryAsync<_i965.GetProfileUseCase>(() async =>
        _i965.GetProfileUseCase(await getAsync<_i894.ProfileRepository>()));
    gh.factoryAsync<_i17.LogoutUseCase>(() async =>
        _i17.LogoutUseCase(await getAsync<_i894.ProfileRepository>()));
    gh.factoryAsync<_i829.UpdateDemographicsUseCase>(() async =>
        _i829.UpdateDemographicsUseCase(
            await getAsync<_i894.ProfileRepository>()));
    gh.lazySingletonAsync<_i356.GetPendingVitalsUseCase>(() async =>
        _i356.GetPendingVitalsUseCase(await getAsync<_i84.VitalsRepository>()));
    gh.lazySingletonAsync<_i677.GetUnifiedVitalsHistoryUseCase>(() async =>
        _i677.GetUnifiedVitalsHistoryUseCase(
            await getAsync<_i84.VitalsRepository>()));
    gh.lazySingletonAsync<_i1051.SaveHomeVitalOfflineUseCase>(() async =>
        _i1051.SaveHomeVitalOfflineUseCase(
            await getAsync<_i84.VitalsRepository>()));
    gh.lazySingletonAsync<_i404.SyncVitalsUseCase>(() async =>
        _i404.SyncVitalsUseCase(await getAsync<_i84.VitalsRepository>()));
    gh.factoryAsync<_i469.ProfileBloc>(() async => _i469.ProfileBloc(
          getProfile: await getAsync<_i965.GetProfileUseCase>(),
          updateDemographics: await getAsync<_i829.UpdateDemographicsUseCase>(),
          changePassword: await getAsync<_i550.ChangePasswordUseCase>(),
          deactivateAccount: await getAsync<_i761.DeactivateAccountUseCase>(),
          logout: await getAsync<_i17.LogoutUseCase>(),
        ));
    gh.factoryAsync<_i838.VitalsSyncBloc>(() async => _i838.VitalsSyncBloc(
          saveVital: await getAsync<_i1051.SaveHomeVitalOfflineUseCase>(),
          syncVitals: await getAsync<_i404.SyncVitalsUseCase>(),
          getHistory: await getAsync<_i677.GetUnifiedVitalsHistoryUseCase>(),
          getPendingVitals: await getAsync<_i356.GetPendingVitalsUseCase>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}

class _$VitalsModule extends _i285.VitalsModule {}
