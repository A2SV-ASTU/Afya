import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/features/clinical_history/data/models/encounter_detail_model.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_detail_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/datasources/medication_local_data_source.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/services/medication_reconciliation_service.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/generate_dose_schedule_usecase.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/process_missed_doses_usecase.dart';

class MockProcessMissedDosesUseCase extends Mock
    implements ProcessMissedDosesUseCase {}

class MockGenerateDoseScheduleUseCase extends Mock
    implements GenerateDoseScheduleUseCase {}

class MockMedicationLocalDataSource extends Mock
    implements MedicationLocalDataSource {}

void main() {
  late MockProcessMissedDosesUseCase mockProcessMissedDosesUseCase;
  late MockGenerateDoseScheduleUseCase mockGenerateDoseScheduleUseCase;
  late MockMedicationLocalDataSource mockLocalDataSource;
  late MedicationReconciliationService service;

  setUpAll(() {
    registerFallbackValue(
      EncounterPrescriptionItemEntity(
        id: 'fallback_rx',
        medicationName: 'Amox',
        dose: '500mg',
        route: 'oral',
        frequency: 'OD',
        duration: '3 days',
        status: EncounterPrescriptionStatus.active,
        instructions: '',
        startedAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    mockProcessMissedDosesUseCase = MockProcessMissedDosesUseCase();
    mockGenerateDoseScheduleUseCase = MockGenerateDoseScheduleUseCase();
    mockLocalDataSource = MockMedicationLocalDataSource();

    service = MedicationReconciliationService(
      mockProcessMissedDosesUseCase,
      mockGenerateDoseScheduleUseCase,
      mockLocalDataSource,
    );
  });

  final testNow = DateTime(2026, 8, 28, 9, 0);

  final activeRxModel = EncounterPrescriptionItemModel(
    id: 'rx_active_1',
    medicationName: 'Amoxicillin',
    dose: '500mg',
    route: 'oral',
    frequency: 'Once daily (OD)',
    duration: '3 days',
    status: EncounterPrescriptionStatus.active,
    instructions: 'Take with food',
    startedAt: DateTime(2026, 8, 28),
  );

  final completedRxModel = EncounterPrescriptionItemModel(
    id: 'rx_completed_2',
    medicationName: 'Metformin',
    dose: '500mg',
    route: 'oral',
    frequency: 'BID',
    duration: '7 days',
    status: EncounterPrescriptionStatus.completed,
    instructions: 'Take with food',
    startedAt: DateTime(2026, 8, 20),
  );

  group('MedicationReconciliationService - Startup Reconciliation', () {
    test(
        'processes missed doses first, then reconciles active prescriptions while ignoring completed ones',
        () async {
      when(() => mockProcessMissedDosesUseCase(now: testNow))
          .thenAnswer((_) async => const Right([]));

      when(() => mockLocalDataSource.getCachedPrescriptions())
          .thenAnswer((_) async => [activeRxModel, completedRxModel]);

      when(() => mockGenerateDoseScheduleUseCase(
            prescription: any(named: 'prescription'),
            now: testNow,
          )).thenAnswer((_) async => const Right([]));

      await service.reconcile(now: testNow);

      verify(() => mockProcessMissedDosesUseCase(now: testNow)).called(1);
      verify(() => mockLocalDataSource.getCachedPrescriptions()).called(1);

      // Only active prescription is reconciled
      verify(() => mockGenerateDoseScheduleUseCase(
            prescription: activeRxModel.toEntity(),
            now: testNow,
          )).called(1);

      verifyNever(() => mockGenerateDoseScheduleUseCase(
            prescription: completedRxModel.toEntity(),
            now: any(named: 'now'),
          ));
    });

    test('reconciliation error is caught gracefully without throwing',
        () async {
      when(() => mockProcessMissedDosesUseCase(now: any(named: 'now')))
          .thenThrow(Exception('Database locked'));

      // Should complete normally without uncaught exception
      await service.reconcile(now: testNow);

      verify(() => mockProcessMissedDosesUseCase(now: testNow)).called(1);
    });
  });
}
