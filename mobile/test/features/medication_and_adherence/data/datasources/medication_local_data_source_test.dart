import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/errors/exceptions.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/encounter_detail_model.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_detail_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/datasources/medication_local_data_source.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/models/local_dose_record_model.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';

class MockBox extends Mock implements Box {}

void main() {
  late MockBox mockScheduleBox;
  late MockBox mockAdherenceBox;
  late MedicationLocalDataSourceImpl localDataSource;

  setUp(() {
    mockScheduleBox = MockBox();
    mockAdherenceBox = MockBox();
    localDataSource = MedicationLocalDataSourceImpl.withBoxes(
      scheduleBox: mockScheduleBox,
      adherenceBox: mockAdherenceBox,
    );
  });

  final samplePrescriptionItem = EncounterPrescriptionItemModel(
    id: 'rx-1',
    medicationName: 'Amoxicillin',
    dose: '500mg',
    route: 'oral',
    frequency: 'TID',
    duration: '7 days',
    status: EncounterPrescriptionStatus.active,
    instructions: 'With meals',
    startedAt: DateTime.parse('2026-08-28T08:00:00Z'),
  );

  final sampleDoseRecord1 = LocalDoseRecordModel(
    id: 'dose-1',
    prescriptionItemId: 'rx-1',
    medicationName: 'Amoxicillin',
    dose: '500mg',
    scheduledTime: DateTime.parse('2026-08-28T08:00:00Z'),
    status: DoseStatus.pending,
  );

  final sampleDoseRecord2 = LocalDoseRecordModel(
    id: 'dose-2',
    prescriptionItemId: 'rx-2',
    medicationName: 'Metformin',
    dose: '850mg',
    scheduledTime: DateTime.parse('2026-08-29T12:00:00Z'),
    status: DoseStatus.taken,
    recordedAt: DateTime.parse('2026-08-29T12:05:00Z'),
  );

  group('Prescriptions Cache Operations', () {
    test('cachePrescriptions puts all items in schedule box', () async {
      when(() => mockScheduleBox.putAll(any())).thenAnswer((_) async {});

      await localDataSource.cachePrescriptions([samplePrescriptionItem]);

      verify(() => mockScheduleBox.putAll({
            'rx-1': samplePrescriptionItem.toJson(),
          })).called(1);
    });

    test('getCachedPrescriptions returns items when box has data', () async {
      when(() => mockScheduleBox.keys).thenReturn(['rx-1']);
      when(() => mockScheduleBox.get('rx-1'))
          .thenReturn(samplePrescriptionItem.toJson());

      final result = await localDataSource.getCachedPrescriptions();

      expect(result.length, 1);
      expect(result.first.id, 'rx-1');
      expect(result.first.medicationName, 'Amoxicillin');
    });

    test('getCachedPrescriptions throws CacheException when box is empty',
        () async {
      when(() => mockScheduleBox.keys).thenReturn([]);

      expect(
        () => localDataSource.getCachedPrescriptions(),
        throwsA(isA<CacheException>()),
      );
    });

    test('updatePrescriptionStatus updates item status in box', () async {
      when(() => mockScheduleBox.get('rx-1'))
          .thenReturn(samplePrescriptionItem.toJson());
      when(() => mockScheduleBox.put('rx-1', any())).thenAnswer((_) async {});

      await localDataSource.updatePrescriptionStatus(
        'rx-1',
        EncounterPrescriptionStatus.completed,
      );

      verify(() => mockScheduleBox.put(
            'rx-1',
            any(that: predicate<Map>((map) => map['status'] == 'completed')),
          )).called(1);
    });
  });

  group('Dose Records Adherence Operations', () {
    test('saveDoseRecord stores record in adherence box', () async {
      when(() => mockAdherenceBox.put(any(), any())).thenAnswer((_) async {});

      await localDataSource.saveDoseRecord(sampleDoseRecord1);

      verify(() => mockAdherenceBox.put('dose-1', sampleDoseRecord1.toJson()))
          .called(1);
    });

    test('getDoseRecordById returns record when found', () async {
      when(() => mockAdherenceBox.get('dose-1'))
          .thenReturn(sampleDoseRecord1.toJson());

      final result = await localDataSource.getDoseRecordById('dose-1');

      expect(result, isNotNull);
      expect(result!.id, 'dose-1');
      expect(result.medicationName, 'Amoxicillin');
    });

    test('getDoseRecords filters by forDate correctly', () async {
      when(() => mockAdherenceBox.keys).thenReturn(['dose-1', 'dose-2']);
      when(() => mockAdherenceBox.get('dose-1'))
          .thenReturn(sampleDoseRecord1.toJson());
      when(() => mockAdherenceBox.get('dose-2'))
          .thenReturn(sampleDoseRecord2.toJson());

      final result = await localDataSource.getDoseRecords(
        forDate: DateTime.parse('2026-08-28T00:00:00Z'),
      );

      expect(result.length, 1);
      expect(result.first.id, 'dose-1');
    });

    test('getDoseRecords filters by prescriptionItemId correctly', () async {
      when(() => mockAdherenceBox.keys).thenReturn(['dose-1', 'dose-2']);
      when(() => mockAdherenceBox.get('dose-1'))
          .thenReturn(sampleDoseRecord1.toJson());
      when(() => mockAdherenceBox.get('dose-2'))
          .thenReturn(sampleDoseRecord2.toJson());

      final result = await localDataSource.getDoseRecords(
        prescriptionItemId: 'rx-2',
      );

      expect(result.length, 1);
      expect(result.first.id, 'dose-2');
      expect(result.first.medicationName, 'Metformin');
    });

    test('deleteDoseRecord removes record from adherence box', () async {
      when(() => mockAdherenceBox.delete('dose-1')).thenAnswer((_) async {});

      await localDataSource.deleteDoseRecord('dose-1');

      verify(() => mockAdherenceBox.delete('dose-1')).called(1);
    });

    test('clearAdherenceHistory clears entire adherence box', () async {
      when(() => mockAdherenceBox.clear()).thenAnswer((_) async => 0);

      await localDataSource.clearAdherenceHistory();

      verify(() => mockAdherenceBox.clear()).called(1);
    });
  });
}
