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
import 'package:injectable/injectable.dart' as _i526;

import '../../app/router/app_router.dart' as _i180;
import '../../app/router/route_guards.dart' as _i469;
import '../../features/medication_and_adherence/data/datasources/adherence_local_data_source.dart'
    as _i386;
import '../../features/medication_and_adherence/data/datasources/prescription_remote_data_source.dart'
    as _i335;
import '../../features/medication_and_adherence/data/repositories/medication_adherence_repository_impl.dart'
    as _i375;
import '../../features/medication_and_adherence/domain/repositories/medication_adherence_repository.dart'
    as _i163;
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
    gh.lazySingleton<_i180.AppRouter>(() => _i180.AppRouter());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
        () => registerModule.secureStorage);
    gh.lazySingleton<_i229.NotificationService>(
        () => _i229.NotificationService());
    gh.lazySingleton<_i605.LocalDatabaseService>(
        () => _i605.LocalDatabaseService());
    gh.lazySingleton<_i386.AdherenceLocalDataSource>(() =>
        _i386.AdherenceLocalDataSourceImpl(gh<_i605.LocalDatabaseService>()));
    gh.lazySingleton<_i916.CookieStorageService>(
        () => _i916.CookieStorageService(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i932.NetworkInfo>(() => _i932.NetworkInfoImpl());
    gh.lazySingleton<_i949.LocalAlarmScheduler>(
        () => _i949.LocalAlarmScheduler(gh<_i229.NotificationService>()));
    gh.lazySingletonAsync<_i557.ApiClient>(
        () => _i557.ApiClient.create(gh<_i916.CookieStorageService>()));
    gh.lazySingleton<_i666.SecureStorageService>(
        () => _i666.SecureStorageService(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i469.RouteGuards>(
        () => _i469.RouteGuards(gh<_i666.SecureStorageService>()));
    gh.lazySingletonAsync<_i335.PrescriptionRemoteDataSource>(() async =>
        _i335.PrescriptionRemoteDataSourceImpl(
            await getAsync<_i557.ApiClient>()));
    gh.lazySingletonAsync<_i163.MedicationAdherenceRepository>(
        () async => _i375.MedicationAdherenceRepositoryImpl(
              await getAsync<_i335.PrescriptionRemoteDataSource>(),
              gh<_i386.AdherenceLocalDataSource>(),
              gh<_i932.NetworkInfo>(),
            ));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
