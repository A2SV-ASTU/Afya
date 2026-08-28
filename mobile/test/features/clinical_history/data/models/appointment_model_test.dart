import 'package:flutter_test/flutter_test.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/appointment_model.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/appointment_entity.dart';

void main() {
  group('AppointmentModel', () {
    test('parses scheduled appointment', () {
      final json = {
        'id': 'appt-1',
        'clinic_id': 'clinic-1',
        'doctor_id': 'doctor-1',
        'patient_id': 'patient-1',
        'scheduled_at': '2026-09-17T10:00:00Z',
        'status': 'scheduled',
        'notes': 'Follow-up',
        'created_at': '2026-08-27T09:40:00Z',
        'updated_at': '2026-08-27T09:40:00Z',
      };

      final model = AppointmentModel.fromJson(json);

      expect(model.id, 'appt-1');
      expect(model.clinicId, 'clinic-1');
      expect(model.doctorId, 'doctor-1');
      expect(model.patientId, 'patient-1');
      expect(
        model.status,
        AppointmentStatus.scheduled,
      );
      expect(model.notes, 'Follow-up');
    });

    test('parses attended appointment', () {
      final json = {
        'id': 'appt-2',
        'clinic_id': 'clinic-1',
        'doctor_id': 'doctor-1',
        'patient_id': 'patient-1',
        'scheduled_at': '2026-08-20T10:00:00Z',
        'status': 'attended',
        'notes': null,
        'created_at': '2026-08-01T09:40:00Z',
        'updated_at': '2026-08-20T11:00:00Z',
      };

      final model = AppointmentModel.fromJson(json);

      expect(
        model.status,
        AppointmentStatus.attended,
      );
    });

    test('parses cancelled appointment', () {
      final json = {
        'id': 'appt-3',
        'clinic_id': 'clinic-1',
        'doctor_id': 'doctor-1',
        'patient_id': 'patient-1',
        'scheduled_at': '2026-08-20T10:00:00Z',
        'status': 'cancelled',
        'notes': 'Patient unavailable',
        'created_at': '2026-08-01T09:40:00Z',
        'updated_at': '2026-08-19T11:00:00Z',
      };

      final model = AppointmentModel.fromJson(json);

      expect(
        model.status,
        AppointmentStatus.cancelled,
      );
    });

    test('throws FormatException for unknown appointment status', () {
      final json = {
        'id': 'appt-4',
        'clinic_id': 'clinic-1',
        'doctor_id': 'doctor-1',
        'patient_id': 'patient-1',
        'scheduled_at': '2026-08-20T10:00:00Z',
        'status': 'missed',
        'notes': null,
        'created_at': '2026-08-01T09:40:00Z',
        'updated_at': '2026-08-20T11:00:00Z',
      };

      expect(
        () => AppointmentModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('toEntity maps all fields correctly', () {
      final model = AppointmentModel.fromJson({
        'id': 'appt-1',
        'clinic_id': 'clinic-1',
        'doctor_id': 'doctor-1',
        'patient_id': 'patient-1',
        'scheduled_at': '2026-09-17T10:00:00Z',
        'status': 'scheduled',
        'notes': 'Follow-up',
        'created_at': '2026-08-27T09:40:00Z',
        'updated_at': '2026-08-27T09:40:00Z',
      });

      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.clinicId, model.clinicId);
      expect(entity.doctorId, model.doctorId);
      expect(entity.patientId, model.patientId);
      expect(entity.scheduledAt, model.scheduledAt);
      expect(entity.status, model.status);
      expect(entity.notes, model.notes);
      expect(entity.createdAt, model.createdAt);
      expect(entity.updatedAt, model.updatedAt);
    });
  });
}
