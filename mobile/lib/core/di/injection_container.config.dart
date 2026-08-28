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
import '../../features/clinical_history/data/datasources/clinical_history_local_data_source.dart'
    as _i196;
import '../../features/clinical_history/data/datasources/clinical_history_remote_data_source.dart'
    as _i113;
import '../../features/clinical_history/data/repositories/clinical_history_repository_impl.dart'
    as _i144;
import '../../features/clinical_history/domain/repositories/clinical_history_repository.dart'
    as _i829;
import '../../features/clinical_history/domain/usecases/get_appointments_usecase.dart'
    as _i702;
import '../../features/clinical_history/domain/usecases/get_encounter_detail_usecase.dart'
    as _i661;
import '../../features/clinical_history/domain/usecases/get_encounters_timeline_usecase.dart'
    as _i401;
import '../../features/clinical_history/presentation/bloc/history_timeline_bloc.dart'
    as _i460;
import '../../features/clinical_history/presentation/cubit/appointments_cubit.dart'
    as _i584;
import '../../features/clinical_history/presentation/cubit/encounter_detail_cubit.dart'
    as _i76;
import '../../features/medication_and_adherence/data/datasources/medication_local_data_source.dart'
    as _i894;
import '../../features/medication_and_adherence/data/datasources/medication_remote_data_source.dart'
    as _i1022;
import '../../features/medication_and_adherence/data/repositories/medication_repository_impl.dart'
    as _i106;
import '../../features/medication_and_adherence/domain/repositories/medication_repository.dart'
    as _i735;
import '../../features/medication_and_adherence/domain/usecases/complete_prescription_usecase.dart'
    as _i724;
import '../../features/medication_and_adherence/domain/usecases/get_local_dose_records_usecase.dart'
    as _i240;
import '../../features/medication_and_adherence/domain/usecases/get_prescriptions_usecase.dart'
    as _i453;
import '../../features/medication_and_adherence/domain/usecases/record_dose_adherence_usecase.dart'
    as _i851;
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
    gh.factory<_i460.HistoryTimelineBloc>(() => _i460.HistoryTimelineBloc(
        getEncountersTimelineUseCase:
            gh<_i401.GetEncountersTimelineUseCase>()));
    gh.factory<_i584.AppointmentsCubit>(() => _i584.AppointmentsCubit(
        getAppointmentsUseCase: gh<_i702.GetAppointmentsUseCase>()));
    gh.lazySingleton<_i196.ClinicalHistoryLocalDataSource>(
        () => _i196.ClinicalHistoryLocalDataSourceImpl());
    gh.lazySingleton<_i894.MedicationLocalDataSource>(
        () => _i894.MedicationLocalDataSourceImpl());
    gh.lazySingleton<_i916.CookieStorageService>(
        () => _i916.CookieStorageService(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i932.NetworkInfo>(() => _i932.NetworkInfoImpl());
    gh.lazySingleton<_i949.LocalAlarmScheduler>(
        () => _i949.LocalAlarmScheduler(gh<_i229.NotificationService>()));
    gh.lazySingletonAsync<_i557.ApiClient>(
        () => _i557.ApiClient.create(gh<_i916.CookieStorageService>()));
    gh.factory<_i76.EncounterDetailCubit>(() => _i76.EncounterDetailCubit(
        getEncounterDetailUseCase: gh<_i661.GetEncounterDetailUseCase>()));
    gh.lazySingleton<_i666.SecureStorageService>(
        () => _i666.SecureStorageService(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i469.RouteGuards>(
        () => _i469.RouteGuards(gh<_i666.SecureStorageService>()));
    gh.lazySingletonAsync<_i113.ClinicalHistoryRemoteDataSource>(() async =>
        _i113.ClinicalHistoryRemoteDataSourceImpl(
            await getAsync<_i557.ApiClient>()));
    gh.lazySingletonAsync<_i1022.MedicationRemoteDataSource>(() async =>
        _i1022.MedicationRemoteDataSourceImpl(
            await getAsync<_i557.ApiClient>()));
    gh.lazySingletonAsync<_i735.MedicationRepository>(() async =>
        _i106.MedicationRepositoryImpl(
          remoteDataSource: await getAsync<_i1022.MedicationRemoteDataSource>(),
          localDataSource: gh<_i894.MedicationLocalDataSource>(),
        ));
    gh.lazySingletonAsync<_i829.ClinicalHistoryRepository>(
        () async => _i144.ClinicalHistoryRepositoryImpl(
              remoteDataSource:
                  await getAsync<_i113.ClinicalHistoryRemoteDataSource>(),
              localDataSource: gh<_i196.ClinicalHistoryLocalDataSource>(),
            ));
    gh.lazySingletonAsync<_i724.CompletePrescriptionUseCase>(() async =>
        _i724.CompletePrescriptionUseCase(
            await getAsync<_i735.MedicationRepository>()));
    gh.lazySingletonAsync<_i240.GetLocalDoseRecordsUseCase>(() async =>
        _i240.GetLocalDoseRecordsUseCase(
            await getAsync<_i735.MedicationRepository>()));
    gh.lazySingletonAsync<_i453.GetPrescriptionsUseCase>(() async =>
        _i453.GetPrescriptionsUseCase(
            await getAsync<_i735.MedicationRepository>()));
    gh.lazySingletonAsync<_i851.RecordDoseAdherenceUseCase>(() async =>
        _i851.RecordDoseAdherenceUseCase(
            await getAsync<_i735.MedicationRepository>()));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
