import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/notifications/local_alarm_scheduler.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/datasources/medication_local_data_source.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/models/local_dose_record_model.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/handle_snooze_usecase.dart';

class MockMedicationLocalDataSource extends Mock
    implements MedicationLocalDataSource {}

class MockLocalAlarmScheduler extends Mock implements LocalAlarmScheduler {}

void main() {
  late MockMedicationLocalDataSource mockLocalDataSource;
  late MockLocalAlarmScheduler mockAlarmScheduler;
  late HandleSnoozeUseCase useCase;

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
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockLocalDataSource = MockMedicationLocalDataSource();
    mockAlarmScheduler = MockLocalAlarmScheduler();
    useCase = HandleSnoozeUseCase(mockLocalDataSource, mockAlarmScheduler);
  });

  const testDoseId = 'rx_item_1_1787904000000';
  final testScheduledTime = DateTime(2026, 8, 28, 8, 0);

  LocalDoseRecordModel createDoseModel({
    String id = testDoseId,
    String prescriptionItemId = 'rx_item_1',
    String medicationName = 'Amoxicillin',
    String dose = '500mg',
    DateTime? scheduledTime,
    DateTime? snoozedUntil,
    DoseStatus status = DoseStatus.pending,
    int snoozeCount = 0,
  }) {
    return LocalDoseRecordModel(
      id: id,
      prescriptionItemId: prescriptionItemId,
      medicationName: medicationName,
      dose: dose,
      scheduledTime: scheduledTime ?? testScheduledTime,
      snoozedUntil: snoozedUntil,
      status: status,
      snoozeCount: snoozeCount,
    );
  }

  group('HandleSnoozeUseCase', () {
    test(
        'first snooze (count 0) increments count to 1, sets snoozedUntil to T+10, schedules reminder with includeSnooze=true',
        () async {
      final initialModel = createDoseModel(snoozeCount: 0);

      when(() => mockLocalDataSource.getDoseRecordById(testDoseId))
          .thenAnswer((_) async => initialModel);
      when(() => mockLocalDataSource.saveDoseRecord(any()))
          .thenAnswer((_) async {});
      when(() => mockAlarmScheduler.scheduleSnoozeReminder(
            reminderId: any(named: 'reminderId'),
            medicationName: any(named: 'medicationName'),
            snoozeTime: any(named: 'snoozeTime'),
            doseId: any(named: 'doseId'),
            prescriptionItemId: any(named: 'prescriptionItemId'),
            includeSnooze: any(named: 'includeSnooze'),
          )).thenAnswer((_) async {});

      final result = await useCase(doseId: testDoseId);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (updated) {
        expect(updated.snoozeCount, 1);
        expect(
          updated.snoozedUntil,
          testScheduledTime.add(const Duration(minutes: 10)),
        );
        expect(updated.status, DoseStatus.pending);
      });

      final capturedModel = verify(
        () => mockLocalDataSource.saveDoseRecord(captureAny()),
      ).captured.first as LocalDoseRecordModel;
      expect(capturedModel.snoozeCount, 1);
      expect(
        capturedModel.snoozedUntil,
        testScheduledTime.add(const Duration(minutes: 10)),
      );

      verify(() => mockAlarmScheduler.scheduleSnoozeReminder(
            reminderId: any(named: 'reminderId'),
            medicationName: 'Amoxicillin',
            snoozeTime: testScheduledTime.add(const Duration(minutes: 10)),
            doseId: testDoseId,
            prescriptionItemId: 'rx_item_1',
            includeSnooze: true,
          )).called(1);
    });

    test(
        'second snooze (count 1) increments count to 2, sets snoozedUntil to T+20, schedules reminder with includeSnooze=false',
        () async {
      final initialModel = createDoseModel(
        snoozeCount: 1,
        snoozedUntil: testScheduledTime.add(const Duration(minutes: 10)),
      );

      when(() => mockLocalDataSource.getDoseRecordById(testDoseId))
          .thenAnswer((_) async => initialModel);
      when(() => mockLocalDataSource.saveDoseRecord(any()))
          .thenAnswer((_) async {});
      when(() => mockAlarmScheduler.scheduleSnoozeReminder(
            reminderId: any(named: 'reminderId'),
            medicationName: any(named: 'medicationName'),
            snoozeTime: any(named: 'snoozeTime'),
            doseId: any(named: 'doseId'),
            prescriptionItemId: any(named: 'prescriptionItemId'),
            includeSnooze: any(named: 'includeSnooze'),
          )).thenAnswer((_) async {});

      final result = await useCase(doseId: testDoseId);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (updated) {
        expect(updated.snoozeCount, 2);
        expect(
          updated.snoozedUntil,
          testScheduledTime.add(const Duration(minutes: 20)),
        );
        expect(updated.status, DoseStatus.pending);
      });

      verify(() => mockAlarmScheduler.scheduleSnoozeReminder(
            reminderId: any(named: 'reminderId'),
            medicationName: 'Amoxicillin',
            snoozeTime: testScheduledTime.add(const Duration(minutes: 20)),
            doseId: testDoseId,
            prescriptionItemId: 'rx_item_1',
            includeSnooze: false,
          )).called(1);
    });

    test('third snooze rejected when snoozeCount is already >= 2', () async {
      final initialModel = createDoseModel(
        snoozeCount: 2,
        snoozedUntil: testScheduledTime.add(const Duration(minutes: 20)),
      );

      when(() => mockLocalDataSource.getDoseRecordById(testDoseId))
          .thenAnswer((_) async => initialModel);

      final result = await useCase(doseId: testDoseId);

      expect(result.isLeft(), isTrue);
      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
      verifyNever(() => mockAlarmScheduler.scheduleSnoozeReminder(
            reminderId: any(named: 'reminderId'),
            medicationName: any(named: 'medicationName'),
            snoozeTime: any(named: 'snoozeTime'),
          ));
    });

    test('taken dose cannot be snoozed', () async {
      final model = createDoseModel(status: DoseStatus.taken);
      when(() => mockLocalDataSource.getDoseRecordById(testDoseId))
          .thenAnswer((_) async => model);

      final result = await useCase(doseId: testDoseId);

      expect(result.isLeft(), isTrue);
      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
    });

    test('skipped dose cannot be snoozed', () async {
      final model = createDoseModel(status: DoseStatus.skipped);
      when(() => mockLocalDataSource.getDoseRecordById(testDoseId))
          .thenAnswer((_) async => model);

      final result = await useCase(doseId: testDoseId);

      expect(result.isLeft(), isTrue);
      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
    });

    test('missed dose cannot be snoozed', () async {
      final model = createDoseModel(status: DoseStatus.missed);
      when(() => mockLocalDataSource.getDoseRecordById(testDoseId))
          .thenAnswer((_) async => model);

      final result = await useCase(doseId: testDoseId);

      expect(result.isLeft(), isTrue);
      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
    });

    test('non-existent dose returns Failure deterministically', () async {
      when(() => mockLocalDataSource.getDoseRecordById(testDoseId))
          .thenAnswer((_) async => null);

      final result = await useCase(doseId: testDoseId);

      expect(result.isLeft(), isTrue);
      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
    });
  });
}
