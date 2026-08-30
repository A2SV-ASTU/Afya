import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/notifications/local_alarm_scheduler.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/datasources/medication_local_data_source.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/models/local_dose_record_model.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/cancel_prescription_reminders_usecase.dart';

class MockMedicationLocalDataSource extends Mock
    implements MedicationLocalDataSource {}

class MockLocalAlarmScheduler extends Mock implements LocalAlarmScheduler {}

void main() {
  late MockMedicationLocalDataSource mockLocalDataSource;
  late MockLocalAlarmScheduler mockAlarmScheduler;
  late CancelPrescriptionRemindersUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      LocalDoseRecordModel(
        id: 'fallback_id',
        prescriptionItemId: 'fallback_rx',
        medicationName: 'Fallback',
        dose: '100mg',
        scheduledTime: DateTime(2026, 1, 1),
        status: DoseStatus.pending,
      ),
    );
  });

  setUp(() {
    mockLocalDataSource = MockMedicationLocalDataSource();
    mockAlarmScheduler = MockLocalAlarmScheduler();
    useCase = CancelPrescriptionRemindersUseCase(
      mockLocalDataSource,
      mockAlarmScheduler,
    );
  });

  const targetRxId = 'rx_target_123';
  const otherRxId = 'rx_other_456';
  final st = DateTime(2026, 8, 28, 8, 0);

  LocalDoseRecordModel createModel({
    required String id,
    required String rxId,
    DoseStatus status = DoseStatus.pending,
  }) {
    return LocalDoseRecordModel(
      id: id,
      prescriptionItemId: rxId,
      medicationName: 'Amoxicillin',
      dose: '500mg',
      scheduledTime: st,
      status: status,
    );
  }

  group('CancelPrescriptionRemindersUseCase', () {
    test('cancels all matching pending reminders for the given prescription ID',
        () async {
      final dose1 = createModel(id: 'rx_target_123_1', rxId: targetRxId);
      final dose2 = createModel(id: 'rx_target_123_2', rxId: targetRxId);
      final doseTaken = createModel(
        id: 'rx_target_123_3',
        rxId: targetRxId,
        status: DoseStatus.taken,
      );

      when(() => mockLocalDataSource.getDoseRecords(
            prescriptionItemId: any(named: 'prescriptionItemId'),
            forDate: any(named: 'forDate'),
          )).thenAnswer((_) async => [dose1, dose2, doseTaken]);
      when(() => mockAlarmScheduler.cancelReminder(any()))
          .thenAnswer((_) async {});

      final result = await useCase(prescriptionItemId: targetRxId);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (count) {
        expect(count, 2);
      });

      final reminderId1 = dose1.id.hashCode & 0x7FFFFFFF;
      final reminderId2 = dose2.id.hashCode & 0x7FFFFFFF;

      verify(() => mockAlarmScheduler.cancelReminder(reminderId1)).called(1);
      verify(() => mockAlarmScheduler.cancelReminder(reminderId2)).called(1);
      // History remains intact (no deletions or saves)
      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
    });

    test('does not affect other prescriptions or non-pending doses', () async {
      final otherDose = createModel(id: 'rx_other_1', rxId: otherRxId);

      when(() => mockLocalDataSource.getDoseRecords(
            prescriptionItemId: any(named: 'prescriptionItemId'),
            forDate: any(named: 'forDate'),
          )).thenAnswer((invocation) async {
        final rxId = invocation.namedArguments[#prescriptionItemId] as String?;
        if (rxId == targetRxId) {
          return [];
        } else if (rxId == otherRxId) {
          return [otherDose];
        }
        return [];
      });

      final result = await useCase(prescriptionItemId: targetRxId);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (count) {
        expect(count, 0);
      });

      final otherReminderId = otherDose.id.hashCode & 0x7FFFFFFF;
      verifyNever(() => mockAlarmScheduler.cancelReminder(otherReminderId));
    });

    test('handles zero matching dose records safely', () async {
      when(() => mockLocalDataSource.getDoseRecords(
            prescriptionItemId: any(named: 'prescriptionItemId'),
            forDate: any(named: 'forDate'),
          )).thenAnswer((_) async => []);

      final result = await useCase(prescriptionItemId: 'rx_none');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (count) {
        expect(count, 0);
      });

      verifyNever(() => mockAlarmScheduler.cancelReminder(any()));
    });

    test('repeated cancellation is safe and idempotent', () async {
      final dose1 = createModel(id: 'rx_target_123_1', rxId: targetRxId);

      when(() => mockLocalDataSource.getDoseRecords(
            prescriptionItemId: any(named: 'prescriptionItemId'),
            forDate: any(named: 'forDate'),
          )).thenAnswer((_) async => [dose1]);
      when(() => mockAlarmScheduler.cancelReminder(any()))
          .thenAnswer((_) async {});

      final result1 = await useCase(prescriptionItemId: targetRxId);
      final result2 = await useCase(prescriptionItemId: targetRxId);

      expect(result1.isRight(), isTrue);
      expect(result2.isRight(), isTrue);

      final reminderId1 = dose1.id.hashCode & 0x7FFFFFFF;
      verify(() => mockAlarmScheduler.cancelReminder(reminderId1)).called(2);
    });
  });
}
