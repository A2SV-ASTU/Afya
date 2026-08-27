import 'package:afyamind_mobile/core/constants/app_keys.dart';
import 'package:afyamind_mobile/core/errors/exceptions.dart';
import 'package:afyamind_mobile/core/storage/local_database_service.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/datasources/adherence_local_data_source.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/models/local_dose_schedule_model.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/models/prescription_item_model.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_schedule_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/prescription_item_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalDatabaseService extends Mock implements LocalDatabaseService {}

class MockBox extends Mock implements Box {}

void main() {
  late MockLocalDatabaseService mockDbService;
  late MockBox mockMedicationBox;
  late MockBox mockAdherenceBox;
  late AdherenceLocalDataSourceImpl localDataSource;

  setUp(() {
    mockDbService = MockLocalDatabaseService();
    mockMedicationBox = MockBox();
    mockAdherenceBox = MockBox();

    when(() => mockDbService.getBox(AppKeys.medicationScheduleBox))
        .thenReturn(mockMedicationBox);
    when(() => mockDbService.getBox(AppKeys.adherenceHistoryBox))
        .thenReturn(mockAdherenceBox);

    localDataSource = AdherenceLocalDataSourceImpl(mockDbService);
  });

  group('Prescription local operations', () {
    const tItem = PrescriptionItemModel(
      id: 'rx-1',
      encounterId: 'enc-1',
      medicationName: 'Amoxicillin',
      dosage: '500mg',
      frequency: 'twice daily',
      status: PrescriptionItemStatus.active,
    );

    test('savePrescriptionItems should store items in medication box',
        () async {
      when(() => mockMedicationBox.putAll(any())).thenAnswer((_) async {});

      await localDataSource.savePrescriptionItems([tItem]);

      verify(() => mockMedicationBox.putAll({
            'rx-1': tItem.toJson(),
          })).called(1);
    });

    test('getPrescriptionItems should retrieve and filter cached items',
        () async {
      when(() => mockMedicationBox.values).thenReturn([
        tItem.toJson(),
        {
          'id': 'rx-2',
          'encounter_id': 'enc-2',
          'medication_name': 'Paracetamol',
          'dosage': '1g',
          'frequency': 'once',
          'status': 'completed',
        }
      ]);

      final allItems = await localDataSource.getPrescriptionItems();
      final filteredItems =
          await localDataSource.getPrescriptionItems(encounterId: 'enc-1');

      expect(allItems.length, 2);
      expect(filteredItems.length, 1);
      expect(filteredItems.first.id, 'rx-1');
    });

    test('updatePrescriptionStatus should modify item status and save to box',
        () async {
      when(() => mockMedicationBox.get('rx-1')).thenReturn(tItem.toJson());
      when(() => mockMedicationBox.put('rx-1', any())).thenAnswer((_) async {});

      await localDataSource.updatePrescriptionStatus(
          'rx-1', PrescriptionItemStatus.completed);

      verify(() => mockMedicationBox.put(
          'rx-1', any(that: isA<Map<String, dynamic>>()))).called(1);
    });

    test('should throw CacheException if box operation fails', () async {
      when(() => mockMedicationBox.putAll(any()))
          .thenThrow(Exception('Hive disk failure'));

      expect(
        () => localDataSource.savePrescriptionItems([tItem]),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('Dose local operations', () {
    final tDose = LocalDoseScheduleModel(
      id: 'dose-1',
      prescriptionItemId: 'rx-1',
      medicationName: 'Amoxicillin',
      dosage: '500mg',
      scheduledTime: DateTime.parse('2026-08-28T08:00:00.000Z'),
      outcome: DoseOutcome.pending,
    );

    test('saveDoseSchedules should store dose models in adherence box',
        () async {
      when(() => mockAdherenceBox.putAll(any())).thenAnswer((_) async {});

      await localDataSource.saveDoseSchedules([tDose]);

      verify(() => mockAdherenceBox.putAll({
            'dose-1': tDose.toJson(),
          })).called(1);
    });

    test('getDoseSchedules should return chronologically sorted list',
        () async {
      final doseEarly = tDose;
      final doseLate = tDose.copyWith(
        id: 'dose-2',
        scheduledTime: DateTime.parse('2026-08-28T20:00:00.000Z'),
      );

      when(() => mockAdherenceBox.values).thenReturn([
        doseLate.toJson(),
        doseEarly.toJson(),
      ]);

      final result = await localDataSource.getDoseSchedules();

      expect(result.length, 2);
      expect(result.first.id, 'dose-1');
      expect(result.last.id, 'dose-2');
    });

    test('updateDoseOutcome should persist updated outcome in box', () async {
      when(() => mockAdherenceBox.get('dose-1')).thenReturn(tDose.toJson());
      when(() => mockAdherenceBox.put('dose-1', any()))
          .thenAnswer((_) async {});

      await localDataSource.updateDoseOutcome('dose-1', DoseOutcome.taken);

      verify(() => mockAdherenceBox.put(
          'dose-1', any(that: isA<Map<String, dynamic>>()))).called(1);
    });

    test(
        'updateDoseSnooze should update snooze time and increment snooze count',
        () async {
      when(() => mockAdherenceBox.get('dose-1')).thenReturn(tDose.toJson());
      when(() => mockAdherenceBox.put('dose-1', any()))
          .thenAnswer((_) async {});

      final snoozeTime = DateTime.parse('2026-08-28T08:30:00.000Z');
      await localDataSource.updateDoseSnooze('dose-1', snoozeTime);

      verify(() => mockAdherenceBox.put('dose-1', any())).called(1);
    });
  });
}
