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
import '../../features/access_requests/data/datasources/access_request_remote_data_source.dart'
    as _i718;
import '../../features/access_requests/data/repositories/access_request_repository_impl.dart'
    as _i345;
import '../../features/access_requests/domain/repositories/access_request_repository.dart'
    as _i438;
import '../../features/access_requests/domain/usecases/approve_access_request_usecase.dart'
    as _i719;
import '../../features/access_requests/domain/usecases/deny_access_request_usecase.dart'
    as _i998;
import '../../features/access_requests/domain/usecases/get_active_grants_usecase.dart'
    as _i211;
import '../../features/access_requests/domain/usecases/get_pending_access_requests_usecase.dart'
    as _i508;
import '../../features/access_requests/domain/usecases/revoke_clinic_grant_usecase.dart'
    as _i1;
import '../../features/access_requests/presentation/bloc/grants_management_bloc.dart'
    as _i506;
import '../../features/access_requests/presentation/bloc/pending_access_requests_bloc.dart'
    as _i427;
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
    gh.lazySingleton<_i666.SecureStorageService>(
        () => _i666.SecureStorageService(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i469.RouteGuards>(
        () => _i469.RouteGuards(gh<_i666.SecureStorageService>()));
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
        () => _i107.AuthRemoteDataSourceImpl(gh<_i557.ApiClient>()));
    gh.lazySingleton<_i718.AccessRequestRemoteDataSource>(
        () => _i718.AccessRequestRemoteDataSourceImpl(gh<_i557.ApiClient>()));
    gh.lazySingleton<_i779.ProcessMissedDosesUseCase>(
        () => _i779.ProcessMissedDosesUseCase(
              gh<_i894.MedicationLocalDataSource>(),
              gh<_i949.LocalAlarmScheduler>(),
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
    gh.lazySingleton<_i438.AccessRequestRepository>(() =>
        _i345.AccessRequestRepositoryImpl(
            remoteDataSource: gh<_i718.AccessRequestRemoteDataSource>()));
    gh.lazySingleton<_i719.ApproveAccessRequestUseCase>(() =>
        _i719.ApproveAccessRequestUseCase(gh<_i438.AccessRequestRepository>()));
    gh.lazySingleton<_i998.DenyAccessRequestUseCase>(() =>
        _i998.DenyAccessRequestUseCase(gh<_i438.AccessRequestRepository>()));
    gh.lazySingleton<_i211.GetActiveGrantsUseCase>(() =>
        _i211.GetActiveGrantsUseCase(gh<_i438.AccessRequestRepository>()));
    gh.lazySingleton<_i508.GetPendingAccessRequestsUseCase>(() =>
        _i508.GetPendingAccessRequestsUseCase(
            gh<_i438.AccessRequestRepository>()));
    gh.lazySingleton<_i1.RevokeClinicGrantUseCase>(() =>
        _i1.RevokeClinicGrantUseCase(gh<_i438.AccessRequestRepository>()));
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
    gh.lazySingleton<_i829.ClinicalHistoryRepository>(
        () => _i144.ClinicalHistoryRepositoryImpl(
              remoteDataSource: gh<_i113.ClinicalHistoryRemoteDataSource>(),
              localDataSource: gh<_i196.ClinicalHistoryLocalDataSource>(),
            ));
    gh.factory<_i506.GrantsManagementBloc>(() => _i506.GrantsManagementBloc(
          getActiveGrantsUseCase: gh<_i211.GetActiveGrantsUseCase>(),
          revokeClinicGrantUseCase: gh<_i1.RevokeClinicGrantUseCase>(),
        ));
    gh.factory<_i427.PendingAccessRequestsBloc>(
        () => _i427.PendingAccessRequestsBloc(
              getPendingUseCase: gh<_i508.GetPendingAccessRequestsUseCase>(),
              approveUseCase: gh<_i719.ApproveAccessRequestUseCase>(),
              denyUseCase: gh<_i998.DenyAccessRequestUseCase>(),
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
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
