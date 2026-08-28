import 'package:flutter_test/flutter_test.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/medical_history_summary_model.dart';

void main() {
  group('MedicalHistorySummaryModel', () {
    test('parses condensed medical history JSON', () {
      final json = {
        'encounter_id': 'enc-1',
        'date': '2026-08-27T09:00:00Z',
        'chief_complaint': 'Routine check-up',
        'diagnosis': 'Type 2 diabetes',
        'prescription': [
          {
            'medication_name': 'Metformin',
            'dose': '500mg',
            'route': 'oral',
            'frequency': 'BD',
            'duration': '30 days',
          }
        ],
        'vitals': {
          'systolic_bp': 120,
          'diastolic_bp': 80,
          'pulse': 72,
          'respiratory_rate': 16,
          'temperature': 36.7,
          'spo2': 98,
          'blood_sugar': 95.5,
          'weight': 71,
        },
      };

      final model = MedicalHistorySummaryModel.fromJson(json);

      expect(model.encounterId, 'enc-1');
      expect(
        model.date,
        DateTime.parse('2026-08-27T09:00:00Z'),
      );
      expect(model.chiefComplaint, 'Routine check-up');
      expect(model.diagnosis, 'Type 2 diabetes');

      expect(model.prescription, hasLength(1));
      expect(
        model.prescription.first.medicationName,
        'Metformin',
      );
      expect(
        model.prescription.first.dose,
        '500mg',
      );
      expect(
        model.prescription.first.route,
        'oral',
      );
      expect(
        model.prescription.first.frequency,
        'BD',
      );
      expect(
        model.prescription.first.duration,
        '30 days',
      );

      expect(model.vitals.systolicBp, 120);
      expect(model.vitals.diastolicBp, 80);
      expect(model.vitals.pulse, 72);
      expect(model.vitals.respiratoryRate, 16);
      expect(model.vitals.temperature, 36.7);
      expect(model.vitals.spo2, 98.0);
      expect(model.vitals.bloodSugar, 95.5);
      expect(model.vitals.weight, 71.0);
    });

    test('supports nullable diagnosis and vital values', () {
      final json = {
        'encounter_id': 'enc-2',
        'date': '2026-08-27T11:00:00Z',
        'chief_complaint': 'General consultation',
        'diagnosis': null,
        'prescription': <Map<String, dynamic>>[],
        'vitals': {
          'systolic_bp': null,
          'diastolic_bp': null,
          'pulse': null,
          'respiratory_rate': null,
          'temperature': null,
          'spo2': null,
          'blood_sugar': null,
          'weight': null,
        },
      };

      final model = MedicalHistorySummaryModel.fromJson(json);

      expect(model.diagnosis, isNull);
      expect(model.prescription, isEmpty);
      expect(model.vitals.systolicBp, isNull);
      expect(model.vitals.diastolicBp, isNull);
      expect(model.vitals.pulse, isNull);
      expect(model.vitals.respiratoryRate, isNull);
      expect(model.vitals.temperature, isNull);
      expect(model.vitals.spo2, isNull);
      expect(model.vitals.bloodSugar, isNull);
      expect(model.vitals.weight, isNull);
    });

    test('supports multiple prescription items', () {
      final json = {
        'encounter_id': 'enc-3',
        'date': '2026-08-27T12:00:00Z',
        'chief_complaint': 'Follow-up',
        'diagnosis': 'Hypertension',
        'prescription': [
          {
            'medication_name': 'Drug A',
            'dose': '10mg',
            'route': 'oral',
            'frequency': 'OD',
            'duration': '7 days',
          },
          {
            'medication_name': 'Drug B',
            'dose': '20mg',
            'route': 'oral',
            'frequency': 'BD',
            'duration': '14 days',
          }
        ],
        'vitals': {
          'systolic_bp': 130,
          'diastolic_bp': 85,
          'pulse': 75,
          'respiratory_rate': 16,
          'temperature': 36.5,
          'spo2': 99,
          'blood_sugar': null,
          'weight': 70,
        },
      };

      final model = MedicalHistorySummaryModel.fromJson(json);

      expect(model.prescription, hasLength(2));
      expect(
        model.prescription.first.medicationName,
        'Drug A',
      );
      expect(
        model.prescription.last.medicationName,
        'Drug B',
      );
    });

    test('toEntity converts nested prescription and vitals models', () {
      final json = {
        'encounter_id': 'enc-1',
        'date': '2026-08-27T09:00:00Z',
        'chief_complaint': 'Routine check-up',
        'diagnosis': 'Diabetes',
        'prescription': [
          {
            'medication_name': 'Metformin',
            'dose': '500mg',
            'route': 'oral',
            'frequency': 'BD',
            'duration': '30 days',
          }
        ],
        'vitals': {
          'systolic_bp': 120,
          'diastolic_bp': 80,
          'pulse': 72,
          'respiratory_rate': 16,
          'temperature': 36.7,
          'spo2': 98,
          'blood_sugar': 95,
          'weight': 71,
        },
      };

      final entity = MedicalHistorySummaryModel.fromJson(json).toEntity();

      expect(entity.encounterId, 'enc-1');
      expect(entity.chiefComplaint, 'Routine check-up');
      expect(entity.diagnosis, 'Diabetes');
      expect(entity.prescription, hasLength(1));
      expect(
        entity.prescription.first.medicationName,
        'Metformin',
      );
      expect(entity.vitals.systolicBp, 120);
      expect(entity.vitals.bloodSugar, 95.0);
      expect(entity.vitals.weight, 71.0);
    });
  });
}
