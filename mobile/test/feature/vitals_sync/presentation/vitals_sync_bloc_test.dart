import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

// Domain
import 'package:afyamind_mobile/features/vitals_sync/domain/entities/vital_sign_entity.dart';
import 'package:afyamind_mobile/features/vitals_sync/domain/entities/vitals_sync_batch_result_entity.dart';
import 'package:afyamind_mobile/features/vitals_sync/domain/usecases/get_pending_vitals_usecase.dart';
import 'package:afyamind_mobile/features/vitals_sync/domain/usecases/get_unified_vitals_history_usecase.dart';
import 'package:afyamind_mobile/features/vitals_sync/domain/usecases/save_home_vital_offline_usecase.dart';
import 'package:afyamind_mobile/features/vitals_sync/domain/usecases/sync_vitals_usecase.dart';

// Presentation
import 'package:afyamind_mobile/features/vitals_sync/presentation/bloc/vitals_sync_bloc.dart';
import 'package:afyamind_mobile/features/vitals_sync/presentation/bloc/vitals_sync_event.dart';
import 'package:afyamind_mobile/features/vitals_sync/presentation/bloc/vitals_sync_state.dart';

final testRecordedAt = DateTime(2026, 8, 29, 10, 0);

class MockSaveVital extends Mock
    implements SaveHomeVitalOfflineUseCase {}

class MockSyncVitals extends Mock
    implements SyncVitalsUseCase {}

class MockHistory extends Mock
    implements GetUnifiedVitalsHistoryUseCase {}

class MockGetPendingVitals extends Mock
    implements GetPendingVitalsUseCase {}

void main() {
  late VitalsSyncBloc bloc;
  late MockSaveVital saveVital;
  late MockSyncVitals syncVitals;
  late MockHistory history;
  late MockGetPendingVitals getPendingVitals;

  setUpAll(() {
    registerFallbackValue(
      VitalSignEntity(
        clientId: 'fallback',
        pulse: 0,
        source: 'fallback',
        recordedAt: DateTime(2000),
      ),
    );
  });

  setUp(() {
    saveVital = MockSaveVital();
    syncVitals = MockSyncVitals();
    history = MockHistory();
    getPendingVitals = MockGetPendingVitals();

    bloc = VitalsSyncBloc(
      saveVital: saveVital,
      syncVitals: syncVitals,
      getHistory: history,
      getPendingVitals: getPendingVitals,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  blocTest<VitalsSyncBloc, VitalsSyncState>(
    'emits success when vital is saved offline',
    build: () {
      when(
        () => saveVital(any()),
      ).thenAnswer(
        (_) async {},
      );

      return bloc;
    },
    act: (bloc) {
      bloc.add(
        SaveVitalEvent(
          VitalSignEntity(
            clientId: '1',
            pulse: 80,
            source: 'patient',
            recordedAt: testRecordedAt,
          ),
        ),
      );
    },
    expect: () => [
      const VitalSavedOffline(
        message: 'Vital saved offline',
      ),
    ],
  );

  blocTest<VitalsSyncBloc, VitalsSyncState>(
    'emits synced when upload succeeds',
    build: () {
      when(
        () => syncVitals(),
      ).thenAnswer(
        (_) async => const VitalsSyncBatchResultEntity(
          uploaded: 3,
          failed: 0,
          failedIds: [],
        ),
      );

      return bloc;
    },
    act: (bloc) {
      bloc.add(
        SyncVitalsEvent(),
      );
    },
    expect: () => [
      VitalsSyncing(),
      const VitalsSynced(
  uploaded: 3,
),
    ],
  );
}