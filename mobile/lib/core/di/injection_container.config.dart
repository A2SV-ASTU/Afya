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
import '../../features/auth/data/datasources/auth_local_data_source.dart'
    as _i852;
import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_auth_session_usecase.dart'
    as _i508;
import '../../features/auth/domain/usecases/login_patient_usecase.dart' as _i51;
import '../../features/auth/domain/usecases/login_with_pin_usecase.dart'
    as _i519;
import '../../features/auth/domain/usecases/logout_patient_usecase.dart'
    as _i244;
import '../../features/auth/domain/usecases/refresh_token_usecase.dart'
    as _i157;
import '../../features/auth/domain/usecases/register_patient_usecase.dart'
    as _i617;
import '../../features/auth/domain/usecases/set_pin_usecase.dart' as _i313;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
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
import '../../features/medication_and_adherence/domain/services/medication_reconciliation_service.dart'
    as _i570;
import '../../features/medication_and_adherence/domain/usecases/cancel_prescription_reminders_usecase.dart'
    as _i854;
import '../../features/medication_and_adherence/domain/usecases/complete_prescription_usecase.dart'
    as _i724;
import '../../features/medication_and_adherence/domain/usecases/generate_dose_schedule_usecase.dart'
    as _i492;
import '../../features/medication_and_adherence/domain/usecases/get_local_dose_records_usecase.dart'
    as _i240;
import '../../features/medication_and_adherence/domain/usecases/get_prescriptions_usecase.dart'
    as _i453;
import '../../features/medication_and_adherence/domain/usecases/handle_snooze_usecase.dart'
    as _i46;
import '../../features/medication_and_adherence/domain/usecases/process_missed_doses_usecase.dart'
    as _i779;
import '../../features/medication_and_adherence/domain/usecases/record_dose_adherence_usecase.dart'
    as _i851;
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
import '../notifications/medication_notification_handler.dart' as _i275;
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
    gh.factory<_i460.HistoryTimelineBloc>(() => _i460.HistoryTimelineBloc(
        getEncountersTimelineUseCase:
            gh<_i401.GetEncountersTimelineUseCase>()));
    gh.factory<_i584.AppointmentsCubit>(() => _i584.AppointmentsCubit(
        getAppointmentsUseCase: gh<_i702.GetAppointmentsUseCase>()));
    gh.lazySingleton<_i196.ClinicalHistoryLocalDataSource>(
        () => _i196.ClinicalHistoryLocalDataSourceImpl());
    gh.lazySingleton<_i894.MedicationLocalDataSource>(
        () => _i894.MedicationLocalDataSourceImpl());
    gh.lazySingleton<_i852.AuthLocalDataSource>(
        () => _i852.AuthLocalDataSourceImpl(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i916.CookieStorageService>(
        () => _i916.CookieStorageService(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i932.NetworkInfo>(() => _i932.NetworkInfoImpl());
    gh.lazySingleton<_i949.LocalAlarmScheduler>(
        () => _i949.LocalAlarmScheduler(gh<_i229.NotificationService>()));
    gh.lazySingleton<_i557.ApiClient>(
        () => _i557.ApiClient(gh<_i916.CookieStorageService>()));
    gh.factory<_i76.EncounterDetailCubit>(() => _i76.EncounterDetailCubit(
        getEncounterDetailUseCase: gh<_i661.GetEncounterDetailUseCase>()));
    gh.lazySingleton<_i75.VitalsLocalDataSource>(
        () => _i269.VitalsLocalDataSourceImpl(gh<_i979.Box<dynamic>>()));
    gh.lazySingleton<_i666.SecureStorageService>(
        () => _i666.SecureStorageService(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i469.RouteGuards>(
        () => _i469.RouteGuards(gh<_i666.SecureStorageService>()));
    gh.lazySingleton<_i847.ProfileRemoteDataSource>(
        () => _i1036.ProfileRemoteDataSourceImpl(gh<_i557.ApiClient>()));
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
        () => _i107.AuthRemoteDataSourceImpl(gh<_i557.ApiClient>()));
    gh.lazySingleton<_i894.ProfileRepository>(
        () => _i334.ProfileRepositoryImpl(gh<_i847.ProfileRemoteDataSource>()));
    gh.lazySingleton<_i779.ProcessMissedDosesUseCase>(
        () => _i779.ProcessMissedDosesUseCase(
              gh<_i894.MedicationLocalDataSource>(),
              gh<_i949.LocalAlarmScheduler>(),
              missedThreshold: gh<Duration>(),
            ));
    gh.lazySingleton<_i854.CancelPrescriptionRemindersUseCase>(
        () => _i854.CancelPrescriptionRemindersUseCase(
              gh<_i894.MedicationLocalDataSource>(),
              gh<_i949.LocalAlarmScheduler>(),
            ));
    gh.lazySingleton<_i492.GenerateDoseScheduleUseCase>(
        () => _i492.GenerateDoseScheduleUseCase(
              gh<_i894.MedicationLocalDataSource>(),
              gh<_i949.LocalAlarmScheduler>(),
            ));
    gh.lazySingleton<_i46.HandleSnoozeUseCase>(() => _i46.HandleSnoozeUseCase(
          gh<_i894.MedicationLocalDataSource>(),
          gh<_i949.LocalAlarmScheduler>(),
        ));
    gh.factory<_i550.ChangePasswordUseCase>(
        () => _i550.ChangePasswordUseCase(gh<_i894.ProfileRepository>()));
    gh.factory<_i761.DeactivateAccountUseCase>(
        () => _i761.DeactivateAccountUseCase(gh<_i894.ProfileRepository>()));
    gh.factory<_i965.GetProfileUseCase>(
        () => _i965.GetProfileUseCase(gh<_i894.ProfileRepository>()));
    gh.factory<_i17.LogoutUseCase>(
        () => _i17.LogoutUseCase(gh<_i894.ProfileRepository>()));
    gh.factory<_i829.UpdateDemographicsUseCase>(
        () => _i829.UpdateDemographicsUseCase(gh<_i894.ProfileRepository>()));
    gh.lazySingleton<_i630.VitalsRemoteDataSource>(
        () => _i267.VitalsRemoteDataSourceImpl(
              gh<_i557.ApiClient>(),
              gh<_i666.SecureStorageService>(),
            ));
    gh.lazySingleton<_i787.AuthRepository>(() => _i153.AuthRepositoryImpl(
          remoteDataSource: gh<_i107.AuthRemoteDataSource>(),
          localDataSource: gh<_i852.AuthLocalDataSource>(),
        ));
    gh.lazySingleton<_i113.ClinicalHistoryRemoteDataSource>(
        () => _i113.ClinicalHistoryRemoteDataSourceImpl(gh<_i557.ApiClient>()));
    gh.lazySingleton<_i1022.MedicationRemoteDataSource>(
        () => _i1022.MedicationRemoteDataSourceImpl(gh<_i557.ApiClient>()));
    gh.lazySingleton<_i570.MedicationReconciliationService>(
        () => _i570.MedicationReconciliationService(
              gh<_i779.ProcessMissedDosesUseCase>(),
              gh<_i492.GenerateDoseScheduleUseCase>(),
              gh<_i894.MedicationLocalDataSource>(),
            ));
    gh.lazySingleton<_i508.GetAuthSessionUseCase>(
        () => _i508.GetAuthSessionUseCase(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i51.LoginPatientUseCase>(
        () => _i51.LoginPatientUseCase(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i519.LoginWithPinUseCase>(
        () => _i519.LoginWithPinUseCase(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i244.LogoutPatientUseCase>(
        () => _i244.LogoutPatientUseCase(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i157.RefreshTokenUseCase>(
        () => _i157.RefreshTokenUseCase(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i617.RegisterPatientUseCase>(
        () => _i617.RegisterPatientUseCase(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i313.SetPinUseCase>(
        () => _i313.SetPinUseCase(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i275.MedicationNotificationHandler>(
        () => _i275.MedicationNotificationHandler(
              gh<_i894.MedicationLocalDataSource>(),
              gh<_i949.LocalAlarmScheduler>(),
              gh<_i46.HandleSnoozeUseCase>(),
            ));
    gh.lazySingleton<_i797.AuthBloc>(() => _i797.AuthBloc(
          getAuthSessionUseCase: gh<_i508.GetAuthSessionUseCase>(),
          loginPatientUseCase: gh<_i51.LoginPatientUseCase>(),
          registerPatientUseCase: gh<_i617.RegisterPatientUseCase>(),
          logoutPatientUseCase: gh<_i244.LogoutPatientUseCase>(),
          loginWithPinUseCase: gh<_i519.LoginWithPinUseCase>(),
          setPinUseCase: gh<_i313.SetPinUseCase>(),
        ));
    gh.lazySingleton<_i735.MedicationRepository>(
        () => _i106.MedicationRepositoryImpl(
              remoteDataSource: gh<_i1022.MedicationRemoteDataSource>(),
              localDataSource: gh<_i894.MedicationLocalDataSource>(),
            ));
    gh.lazySingleton<_i84.VitalsRepository>(() => _i1029.VitalsRepositoryImpl(
          local: gh<_i75.VitalsLocalDataSource>(),
          remote: gh<_i630.VitalsRemoteDataSource>(),
        ));
    gh.factory<_i469.ProfileBloc>(() => _i469.ProfileBloc(
          getProfile: gh<_i965.GetProfileUseCase>(),
          updateDemographics: gh<_i829.UpdateDemographicsUseCase>(),
          changePassword: gh<_i550.ChangePasswordUseCase>(),
          deactivateAccount: gh<_i761.DeactivateAccountUseCase>(),
          logout: gh<_i17.LogoutUseCase>(),
        ));
    gh.lazySingleton<_i829.ClinicalHistoryRepository>(
        () => _i144.ClinicalHistoryRepositoryImpl(
              remoteDataSource: gh<_i113.ClinicalHistoryRemoteDataSource>(),
              localDataSource: gh<_i196.ClinicalHistoryLocalDataSource>(),
            ));
    gh.lazySingleton<_i453.GetPrescriptionsUseCase>(
        () => _i453.GetPrescriptionsUseCase(
              gh<_i735.MedicationRepository>(),
              gh<_i492.GenerateDoseScheduleUseCase>(),
            ));
    gh.lazySingleton<_i240.GetLocalDoseRecordsUseCase>(() =>
        _i240.GetLocalDoseRecordsUseCase(gh<_i735.MedicationRepository>()));
    gh.lazySingleton<_i851.RecordDoseAdherenceUseCase>(() =>
        _i851.RecordDoseAdherenceUseCase(gh<_i735.MedicationRepository>()));
    gh.lazySingleton<_i724.CompletePrescriptionUseCase>(
        () => _i724.CompletePrescriptionUseCase(
              gh<_i735.MedicationRepository>(),
              gh<_i854.CancelPrescriptionRemindersUseCase>(),
            ));
    gh.lazySingleton<_i356.GetPendingVitalsUseCase>(
        () => _i356.GetPendingVitalsUseCase(gh<_i84.VitalsRepository>()));
    gh.lazySingleton<_i677.GetUnifiedVitalsHistoryUseCase>(() =>
        _i677.GetUnifiedVitalsHistoryUseCase(gh<_i84.VitalsRepository>()));
    gh.lazySingleton<_i1051.SaveHomeVitalOfflineUseCase>(
        () => _i1051.SaveHomeVitalOfflineUseCase(gh<_i84.VitalsRepository>()));
    gh.lazySingleton<_i404.SyncVitalsUseCase>(
        () => _i404.SyncVitalsUseCase(gh<_i84.VitalsRepository>()));
    gh.factory<_i838.VitalsSyncBloc>(() => _i838.VitalsSyncBloc(
          saveVital: gh<_i1051.SaveHomeVitalOfflineUseCase>(),
          syncVitals: gh<_i404.SyncVitalsUseCase>(),
          getHistory: gh<_i677.GetUnifiedVitalsHistoryUseCase>(),
          getPendingVitals: gh<_i356.GetPendingVitalsUseCase>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}

class _$VitalsModule extends _i285.VitalsModule {}
