import 'package:flutter_test/flutter_test.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/encounter_detail_model.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/diagnosis_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_detail_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/lab_result_entity.dart';

void main() {
  group('EncounterDetailModel', () {
    test('parses aggregated encounter payload correctly', () {
      final json = {
        'encounter': {
          'id': 'enc-1',
          'patient_id': 'patient-1',
          'clinic_id': 'clinic-1',
          'opened_by_doctor_id': 'doctor-1',
          'status': 'closed',
          'started_at': '2026-08-27T09:00:00Z',
          'ended_at': '2026-08-27T10:00:00Z',
          'created_at': '2026-08-27T09:00:00Z',
        },
        'vitals': [
          {
            'id': 'vital-1',
            'source': 'clinic',
            'systolic_bp': 120,
            'diastolic_bp': 80,
            'pulse': 72,
            'respiratory_rate': 16,
            'temperature': 36.7,
            'spo2': 98,
            'blood_sugar': 95,
            'weight': 71,
            'recorded_at': '2026-08-27T09:15:00Z',
          }
        ],
        'labs': [
          {
            'id': 'lab-1',
            'test_name': 'Blood Sugar',
            'category': 'laboratory',
            'summary_notes': 'Normal',
            'measurements': {
              'glucose': 95,
            },
            'flag': 'normal',
            'created_at': '2026-08-27T09:30:00Z',
          }
        ],
        'diagnoses': [
          {
            'id': 'diag-1',
            'diagnosis_text': 'Type 2 diabetes',
            'icd_code': 'E11',
            'diagnosis_type': 'final',
            'notes': null,
            'diagnosed_at': '2026-08-27T09:40:00Z',
          }
        ],
        'prescriptions': [
          {
            'id': 'pres-1',
            'notes': 'Take with food',
            'prescribed_at': '2026-08-27T09:45:00Z',
            'items': [
              {
                'id': 'item-1',
                'medication_name': 'Metformin',
                'dose': '500mg',
                'route': 'oral',
                'frequency': 'BD',
                'duration': '30 days',
                'status': 'active',
                'instructions': 'Take after meals',
                'started_at': '2026-08-27T09:45:00Z',
              }
            ],
          }
        ],
      };

      final model = EncounterDetailModel.fromJson(json);

      expect(model.encounter.id, 'enc-1');

      expect(model.vitals, hasLength(1));
      expect(
        model.vitals.first.source,
        EncounterVitalSource.clinic,
      );
      expect(model.vitals.first.systolicBp, 120);

      expect(model.labs, hasLength(1));
      expect(model.labs.first.flag, LabResultFlag.normal);

      expect(model.diagnoses, hasLength(1));
      expect(
        model.diagnoses.first.diagnosisType,
        DiagnosisType.finalDiagnosis,
      );

      expect(model.prescriptions, hasLength(1));
      expect(model.prescriptions.first.items, hasLength(1));
      expect(
        model.prescriptions.first.items.first.medicationName,
        'Metformin',
      );
      expect(
        model.prescriptions.first.items.first.status,
        EncounterPrescriptionStatus.active,
      );
    });

    test('supports empty aggregated sections', () {
      final json = {
        'encounter': {
          'id': 'enc-2',
          'patient_id': 'patient-1',
          'clinic_id': 'clinic-1',
          'opened_by_doctor_id': 'doctor-1',
          'status': 'open',
          'started_at': '2026-08-27T11:00:00Z',
          'ended_at': null,
          'created_at': '2026-08-27T11:00:00Z',
        },
        'vitals': <Map<String, dynamic>>[],
        'labs': <Map<String, dynamic>>[],
        'diagnoses': <Map<String, dynamic>>[],
        'prescriptions': <Map<String, dynamic>>[],
      };

      final model = EncounterDetailModel.fromJson(json);

      expect(model.vitals, isEmpty);
      expect(model.labs, isEmpty);
      expect(model.diagnoses, isEmpty);
      expect(model.prescriptions, isEmpty);
    });

    test('toEntity maps nested models correctly', () {
      final model = EncounterDetailModel.fromJson({
        'encounter': {
          'id': 'enc-1',
          'patient_id': 'patient-1',
          'clinic_id': 'clinic-1',
          'opened_by_doctor_id': 'doctor-1',
          'status': 'closed',
          'started_at': '2026-08-27T09:00:00Z',
          'ended_at': '2026-08-27T10:00:00Z',
          'created_at': '2026-08-27T09:00:00Z',
        },
        'vitals': [
          {
            'id': 'vital-1',
            'source': 'clinic',
            'systolic_bp': 120,
            'diastolic_bp': 80,
            'pulse': 72,
            'respiratory_rate': 16,
            'temperature': 36.7,
            'spo2': 98,
            'blood_sugar': 95,
            'weight': 71,
            'recorded_at': '2026-08-27T09:15:00Z',
          }
        ],
        'labs': <Map<String, dynamic>>[],
        'diagnoses': <Map<String, dynamic>>[],
        'prescriptions': <Map<String, dynamic>>[],
      });

      final entity = model.toEntity();

      expect(entity.encounter.id, 'enc-1');
      expect(entity.vitals, hasLength(1));
      expect(entity.vitals.first.systolicBp, 120);
      expect(entity.clinicalEvaluation, isNull);
    });

    test('toJson serializes correctly for round-trip parsing', () {
      final json = {
        'encounter': {
          'id': 'enc-1',
          'patient_id': 'patient-1',
          'clinic_id': 'clinic-1',
          'opened_by_doctor_id': 'doctor-1',
          'status': 'closed',
          'started_at': '2026-08-27T09:00:00Z',
          'ended_at': '2026-08-27T10:00:00Z',
          'created_at': '2026-08-27T09:00:00Z',
        },
        'vitals': [
          {
            'id': 'vital-1',
            'source': 'clinic',
            'systolic_bp': 120,
            'diastolic_bp': 80,
            'pulse': 72,
            'respiratory_rate': 16,
            'temperature': 36.7,
            'spo2': 98.0,
            'blood_sugar': 95.0,
            'weight': 71.0,
            'recorded_at': '2026-08-27T09:15:00Z',
          }
        ],
        'labs': <Map<String, dynamic>>[],
        'diagnoses': <Map<String, dynamic>>[],
        'prescriptions': <Map<String, dynamic>>[],
      };

      final model = EncounterDetailModel.fromJson(json);
      final serialized = model.toJson();
      final roundTripModel = EncounterDetailModel.fromJson(serialized);

      expect(roundTripModel.encounter.id, model.encounter.id);
      expect(roundTripModel.vitals.first.systolicBp, 120);
    });
  });
}
