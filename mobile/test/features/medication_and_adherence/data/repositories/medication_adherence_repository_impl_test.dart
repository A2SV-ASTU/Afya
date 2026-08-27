import 'package:afyamind_mobile/core/errors/exceptions.dart';
import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/core/network/network_info.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/datasources/adherence_local_data_source.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/datasources/prescription_remote_data_source.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/models/local_dose_schedule_model.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/models/prescription_item_model.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/repositories/medication_adherence_repository_impl.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_schedule_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/prescription_item_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockPrescriptionRemoteDataSource extends Mock
    implements PrescriptionRemoteDataSource {}

class MockAdherenceLocalDataSource extends Mock
    implements AdherenceLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockPrescriptionRemoteDataSource mockRemoteDataSource;
  late MockAdherenceLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late MedicationAdherenceRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockPrescriptionRemoteDataSource();
    mockLocalDataSource = MockAdherenceLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();

    repository = MedicationAdherenceRepositoryImpl(
      mockRemoteDataSource,
      mockLocalDataSource,
      mockNetworkInfo,
    );
  });

  final tPrescriptionModel = PrescriptionItemModel(
    id: 'rx-101',
    encounterId: 'enc-202',
    medicationName: 'Amoxicillin',
    dosage: '500mg',
    frequency: 'twice daily',
    durationDays: 1,
    status: PrescriptionItemStatus.active,
    startDate: DateTime.parse('2026-08-28T08:00:00.000Z'),
  );

  group('syncPrescriptionsForEncounter', () {
    const tEncounterId = 'enc-202';

    test('should fetch from remote and persist locally when online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() =>
              mockRemoteDataSource.getPrescriptionsForEncounter(tEncounterId))
          .thenAnswer((_) async => [tPrescriptionModel]);
      when(() =>
              mockLocalDataSource.savePrescriptionItems([tPrescriptionModel]))
          .thenAnswer((_) async {});

      final result =
          await repository.syncPrescriptionsForEncounter(tEncounterId);

      expect(result.isRight(), true);
      verify(() =>
              mockRemoteDataSource.getPrescriptionsForEncounter(tEncounterId))
          .called(1);
      verify(() =>
              mockLocalDataSource.savePrescriptionItems([tPrescriptionModel]))
          .called(1);
    });

    test('should return cached data when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocalDataSource.getPrescriptionItems(
              encounterId: tEncounterId))
          .thenAnswer((_) async => [tPrescriptionModel]);

      final result =
          await repository.syncPrescriptionsForEncounter(tEncounterId);

      expect(result.isRight(), true);
      verifyNever(
          () => mockRemoteDataSource.getPrescriptionsForEncounter(any()));
    });

    test('should return NetworkFailure when offline and cache is empty',
        () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocalDataSource.getPrescriptionItems(
          encounterId: tEncounterId)).thenAnswer((_) async => []);

      final result =
          await repository.syncPrescriptionsForEncounter(tEncounterId);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should map ServerException to ServerFailure', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() =>
              mockRemoteDataSource.getPrescriptionsForEncounter(tEncounterId))
          .thenThrow(const ServerException('Server error', code: 'server_err'));

      final result =
          await repository.syncPrescriptionsForEncounter(tEncounterId);

      expect(result,
          const Left(ServerFailure('Server error', code: 'server_err')));
    });
  });

  group('updateDoseOutcome and completion trigger', () {
    final tDose1 = LocalDoseScheduleModel(
      id: 'dose-1',
      prescriptionItemId: 'rx-101',
      medicationName: 'Amoxicillin',
      dosage: '500mg',
      scheduledTime: DateTime.parse('2026-08-28T08:00:00.000Z'),
      outcome: DoseOutcome.pending,
    );

    final tDose2 = LocalDoseScheduleModel(
      id: 'dose-2',
      prescriptionItemId: 'rx-101',
      medicationName: 'Amoxicillin',
      dosage: '500mg',
      scheduledTime: DateTime.parse('2026-08-28T20:00:00.000Z'),
      outcome: DoseOutcome.pending,
    );

    test(
        'should update dose locally and NOT trigger completion if remaining doses are still pending',
        () async {
      when(() => mockLocalDataSource.updateDoseOutcome(
              'dose-1', DoseOutcome.taken, loggedAt: any(named: 'loggedAt')))
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.getDoseScheduleById('dose-1'))
          .thenAnswer((_) async => tDose1.copyWith(outcome: DoseOutcome.taken));
      when(() => mockLocalDataSource.getPrescriptionItemById('rx-101'))
          .thenAnswer((_) async => tPrescriptionModel);
      when(() => mockLocalDataSource
              .getDoseSchedules(prescriptionItemId: 'rx-101'))
          .thenAnswer((_) async => [
                tDose1.copyWith(outcome: DoseOutcome.taken),
                tDose2, // Still pending
              ]);

      final result = await repository.updateDoseOutcome(
        doseId: 'dose-1',
        outcome: DoseOutcome.taken,
      );

      expect(result, const Right(null));
      verify(() => mockLocalDataSource.updateDoseOutcome(
              'dose-1', DoseOutcome.taken, loggedAt: any(named: 'loggedAt')))
          .called(1);
      verifyNever(() => mockRemoteDataSource.completePrescription(any()));
    });

    test(
        'should trigger completion when all local doses for the prescription resolve',
        () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockLocalDataSource.updateDoseOutcome(
              'dose-2', DoseOutcome.taken, loggedAt: any(named: 'loggedAt')))
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.getDoseScheduleById('dose-2'))
          .thenAnswer((_) async => tDose2.copyWith(outcome: DoseOutcome.taken));
      when(() => mockLocalDataSource.getPrescriptionItemById('rx-101'))
          .thenAnswer((_) async => tPrescriptionModel);
      when(() => mockLocalDataSource
              .getDoseSchedules(prescriptionItemId: 'rx-101'))
          .thenAnswer((_) async => [
                tDose1.copyWith(outcome: DoseOutcome.taken),
                tDose2.copyWith(outcome: DoseOutcome.taken),
              ]);
      when(() => mockRemoteDataSource.completePrescription('rx-101'))
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.updatePrescriptionStatus(
          'rx-101', PrescriptionItemStatus.completed)).thenAnswer((_) async {});

      final result = await repository.updateDoseOutcome(
        doseId: 'dose-2',
        outcome: DoseOutcome.taken,
      );

      expect(result, const Right(null));
      verify(() => mockRemoteDataSource.completePrescription('rx-101'))
          .called(1);
      verify(() => mockLocalDataSource.updatePrescriptionStatus(
          'rx-101', PrescriptionItemStatus.completed)).called(1);
    });

    test('should NOT trigger remote completion if prescription is deactivated',
        () async {
      final deactivatedRx = tPrescriptionModel.copyWith(
          status: PrescriptionItemStatus.deactivated);

      when(() => mockLocalDataSource.getPrescriptionItemById('rx-101'))
          .thenAnswer((_) async => deactivatedRx);

      final result = await repository.completePrescription('rx-101');

      expect(result, const Right(null));
      verifyNever(() => mockRemoteDataSource.completePrescription(any()));
    });
  });
}
