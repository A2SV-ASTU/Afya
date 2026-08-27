import 'package:flutter_test/flutter_test.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/clinical_evaluation_model.dart';

void main() {
  group('ClinicalEvaluationModel', () {
    test('parses clinical evaluation JSON correctly', () {
      final json = {
        'id': 'eval-1',
        'encounter_id': 'enc-1',
        'chief_complaint': 'Headache',
        'history_of_present_illness': 'Headache for two days',
        'past_admissions': 'None',
        'family_history': 'Hypertension',
        'allergies_notes': 'Penicillin',
        'general_appearance': 'Stable',
        'system_examination': {
          'cardiovascular': 'Normal',
          'respiratory': 'Clear',
        },
        'created_at': '2026-08-27T09:10:00Z',
      };

      final model = ClinicalEvaluationModel.fromJson(json);

      expect(model.id, 'eval-1');
      expect(model.encounterId, 'enc-1');
      expect(model.chiefComplaint, 'Headache');
      expect(
        model.historyOfPresentIllness,
        'Headache for two days',
      );
      expect(model.pastAdmissions, 'None');
      expect(model.familyHistory, 'Hypertension');
      expect(model.allergiesNotes, 'Penicillin');
      expect(model.generalAppearance, 'Stable');
      expect(
        model.systemExamination?['cardiovascular'],
        'Normal',
      );
      expect(
        model.systemExamination?['respiratory'],
        'Clear',
      );
      expect(
        model.createdAt,
        DateTime.parse('2026-08-27T09:10:00Z'),
      );
    });

    test('parses nullable clinical evaluation fields', () {
      final json = {
        'id': 'eval-2',
        'encounter_id': 'enc-2',
        'chief_complaint': 'Routine check-up',
        'history_of_present_illness': 'No acute complaints',
        'past_admissions': null,
        'family_history': null,
        'allergies_notes': null,
        'general_appearance': null,
        'system_examination': null,
        'created_at': '2026-08-27T10:00:00Z',
      };

      final model = ClinicalEvaluationModel.fromJson(json);

      expect(model.pastAdmissions, isNull);
      expect(model.familyHistory, isNull);
      expect(model.allergiesNotes, isNull);
      expect(model.generalAppearance, isNull);
      expect(model.systemExamination, isNull);
    });

    test('toEntity maps fields correctly', () {
      final model = ClinicalEvaluationModel.fromJson({
        'id': 'eval-1',
        'encounter_id': 'enc-1',
        'chief_complaint': 'Headache',
        'history_of_present_illness': 'Headache for two days',
        'past_admissions': null,
        'family_history': null,
        'allergies_notes': 'Penicillin',
        'general_appearance': 'Stable',
        'system_examination': {
          'cardiovascular': 'Normal',
        },
        'created_at': '2026-08-27T09:10:00Z',
      });

      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.encounterId, model.encounterId);
      expect(entity.chiefComplaint, model.chiefComplaint);
      expect(
        entity.historyOfPresentIllness,
        model.historyOfPresentIllness,
      );
      expect(entity.allergiesNotes, model.allergiesNotes);
      expect(
        entity.systemExamination?['cardiovascular'],
        'Normal',
      );
      expect(entity.createdAt, model.createdAt);
    });
  });
}
