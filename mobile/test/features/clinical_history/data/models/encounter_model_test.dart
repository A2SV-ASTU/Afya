import 'package:flutter_test/flutter_test.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/encounter_model.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_entity.dart';

void main() {
  group('EncounterModel', () {
    test('parses a closed encounter from JSON', () {
      final json = {
        'id': 'enc-1',
        'patient_id': 'patient-1',
        'clinic_id': 'clinic-1',
        'opened_by_doctor_id': 'doctor-1',
        'status': 'closed',
        'started_at': '2026-08-27T09:00:00Z',
        'ended_at': '2026-08-27T09:45:00Z',
      };

      final model = EncounterModel.fromJson(json);

      expect(model.id, 'enc-1');
      expect(model.patientId, 'patient-1');
      expect(model.clinicId, 'clinic-1');
      expect(model.openedByDoctorId, 'doctor-1');
      expect(model.status, EncounterStatus.closed);
      expect(
        model.startedAt,
        DateTime.parse('2026-08-27T09:00:00Z'),
      );
      expect(
        model.endedAt,
        DateTime.parse('2026-08-27T09:45:00Z'),
      );
    });

    test('parses an open encounter with null endedAt', () {
      final json = {
        'id': 'enc-2',
        'patient_id': 'patient-1',
        'clinic_id': 'clinic-1',
        'opened_by_doctor_id': 'doctor-1',
        'status': 'open',
        'started_at': '2026-08-27T10:00:00Z',
        'ended_at': null,
      };

      final model = EncounterModel.fromJson(json);

      expect(model.id, 'enc-2');
      expect(model.status, EncounterStatus.open);
      expect(
        model.startedAt,
        DateTime.parse('2026-08-27T10:00:00Z'),
      );
      expect(model.endedAt, isNull);
    });

    test('parses optional clinic and doctor names when present', () {
      final json = {
        'id': 'enc-3',
        'patient_id': 'patient-1',
        'clinic_id': 'clinic-1',
        'opened_by_doctor_id': 'doctor-1',
        'clinic_name': 'St. Gabriel General Clinic',
        'doctor_name': 'Dr. Selam',
        'status': 'closed',
        'started_at': '2026-08-27T09:00:00Z',
        'ended_at': '2026-08-27T09:45:00Z',
      };

      final model = EncounterModel.fromJson(json);

      expect(model.clinicName, 'St. Gabriel General Clinic');
      expect(model.doctorName, 'Dr. Selam');
    });

    test('allows optional clinic and doctor names to be absent', () {
      final json = {
        'id': 'enc-4',
        'patient_id': 'patient-1',
        'clinic_id': 'clinic-1',
        'opened_by_doctor_id': 'doctor-1',
        'status': 'open',
        'started_at': '2026-08-27T10:00:00Z',
        'ended_at': null,
      };

      final model = EncounterModel.fromJson(json);

      expect(model.clinicName, isNull);
      expect(model.doctorName, isNull);
    });

    test('maps opened status to EncounterStatus.open', () {
      final json = {
        'id': 'enc-5',
        'patient_id': 'patient-1',
        'clinic_id': 'clinic-1',
        'opened_by_doctor_id': 'doctor-1',
        'status': 'opened',
        'started_at': '2026-08-27T10:00:00Z',
        'ended_at': null,
      };

      final model = EncounterModel.fromJson(json);

      expect(model.status, EncounterStatus.open);
    });

    test('throws FormatException for unknown encounter status', () {
      final json = {
        'id': 'enc-6',
        'patient_id': 'patient-1',
        'clinic_id': 'clinic-1',
        'opened_by_doctor_id': 'doctor-1',
        'status': 'archived',
        'started_at': '2026-08-27T10:00:00Z',
        'ended_at': null,
      };

      expect(
        () => EncounterModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('toEntity maps all fields correctly', () {
      final startedAt = DateTime.parse('2026-08-27T09:00:00Z');
      final endedAt = DateTime.parse('2026-08-27T09:45:00Z');

      final model = EncounterModel(
        id: 'enc-1',
        patientId: 'patient-1',
        clinicId: 'clinic-1',
        openedByDoctorId: 'doctor-1',
        clinicName: 'St. Gabriel General Clinic',
        doctorName: 'Dr. Selam',
        status: EncounterStatus.closed,
        startedAt: startedAt,
        endedAt: endedAt,
      );

      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.patientId, model.patientId);
      expect(entity.clinicId, model.clinicId);
      expect(entity.openedByDoctorId, model.openedByDoctorId);
      expect(entity.clinicName, model.clinicName);
      expect(entity.doctorName, model.doctorName);
      expect(entity.status, model.status);
      expect(entity.startedAt, model.startedAt);
      expect(entity.endedAt, model.endedAt);
    });

    test('toJson serializes correctly for round-trip parsing', () {
      final model = EncounterModel(
        id: 'enc-1',
        patientId: 'patient-1',
        clinicId: 'clinic-1',
        openedByDoctorId: 'doctor-1',
        clinicName: 'St. Gabriel General Clinic',
        doctorName: 'Dr. Selam',
        status: EncounterStatus.open,
        startedAt: DateTime.parse('2026-08-27T09:00:00Z'),
      );

      final json = model.toJson();
      final roundTripModel = EncounterModel.fromJson(json);

      expect(roundTripModel.id, model.id);
      expect(roundTripModel.patientId, model.patientId);
      expect(roundTripModel.status, model.status);
      expect(roundTripModel.clinicName, model.clinicName);
      expect(roundTripModel.startedAt, model.startedAt);
    });
  });
}
