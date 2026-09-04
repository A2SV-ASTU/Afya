import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_pending_vitals_usecase.dart';
import '../../domain/usecases/get_unified_vitals_history_usecase.dart';
import '../../domain/usecases/save_home_vital_offline_usecase.dart';
import '../../domain/usecases/sync_vitals_usecase.dart';

import 'vitals_sync_event.dart';
import 'vitals_sync_state.dart';

@injectable
class VitalsSyncBloc extends Bloc<VitalsSyncEvent, VitalsSyncState> {
  final SaveHomeVitalOfflineUseCase saveVital;
  final SyncVitalsUseCase syncVitals;
  final GetUnifiedVitalsHistoryUseCase getHistory;
  final GetPendingVitalsUseCase getPendingVitals;

  VitalsSyncBloc({
    required this.saveVital,
    required this.syncVitals,
    required this.getHistory,
    required this.getPendingVitals,
  }) : super(VitalsInitial()) {
    // ==========================================
    // SAVE VITAL OFFLINE
    // ==========================================
    on<SaveVitalEvent>((event, emit) async {
      try {
        await saveVital(event.vital);

        emit(
  VitalSavedOffline(
    message: 'Vital saved offline',
    vital: event.vital,
  ),
);
      } catch (e) {
        emit(VitalsError(e.toString()));
      }
    });

    // ==========================================
    // LOAD PENDING OFFLINE VITALS
    // ==========================================
    on<LoadPendingVitalsEvent>((event, emit) async {
      try {
        emit(VitalsLoading());

        final pending = await getPendingVitals();

        emit(VitalsPendingLoaded(pending));
      } catch (e) {
        emit(VitalsError(e.toString()));
      }
    });

    // ==========================================
    // SYNC PENDING VITALS
    // ==========================================
    on<SyncVitalsEvent>((event, emit) async {
      try {
        emit(VitalsSyncing());

        final result = await syncVitals();

        emit(
          VitalsSynced(
            uploaded: result.uploaded,
          ),
        );
      } catch (e) {
        emit(VitalsError(e.toString()));
      }
    });

    // ==========================================
    // NETWORK RESTORED
    // ==========================================
    on<NetworkRestoredEvent>((event, emit) {
      add(SyncVitalsEvent());
    });

    // ==========================================
    // LOAD HISTORY
    // ==========================================
    on<LoadVitalsHistoryEvent>((event, emit) async {
      try {
        emit(VitalsLoading());

        final history = await getHistory();

        emit(VitalsHistoryLoaded(history));
      } catch (e) {
        emit(VitalsError(e.toString()));
      }
    });
  }
}