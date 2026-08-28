import 'package:flutter_test/flutter_test.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/diagnosis_model.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/diagnosis_entity.dart';

void main() {
  group('DiagnosisModel', () {
    test('parses provisional diagnosis', () {
      final json = {
        'id': 'diag-1',
        'diagnosis_text': 'Possible hypertension',
        'icd_code': 'I10',
        'diagnosis_type': 'provisional',
        'notes': 'Needs confirmation',
        'diagnosed_at': '2026-08-27T09:30:00Z',
      };

      final model = DiagnosisModel.fromJson(json);

      expect(model.id, 'diag-1');
      expect(
        model.diagnosisType,
        DiagnosisType.provisional,
      );
      expect(model.icdCode, 'I10');
    });

    test('maps final diagnosis correctly', () {
      final json = {
        'id': 'diag-2',
        'diagnosis_text': 'Hypertension',
        'icd_code': 'I10',
        'diagnosis_type': 'final',
        'notes': null,
        'diagnosed_at': '2026-08-27T09:35:00Z',
      };

      final model = DiagnosisModel.fromJson(json);

      expect(
        model.diagnosisType,
        DiagnosisType.finalDiagnosis,
      );
      expect(model.notes, isNull);
    });

    test('throws FormatException for unknown diagnosis type', () {
      final json = {
        'id': 'diag-3',
        'diagnosis_text': 'Unknown',
        'icd_code': null,
        'diagnosis_type': 'suspected',
        'notes': null,
        'diagnosed_at': '2026-08-27T09:35:00Z',
      };

      expect(
        () => DiagnosisModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('toEntity maps all fields correctly', () {
      final model = DiagnosisModel.fromJson({
        'id': 'diag-2',
        'diagnosis_text': 'Hypertension',
        'icd_code': 'I10',
        'diagnosis_type': 'final',
        'notes': 'Confirmed',
        'diagnosed_at': '2026-08-27T09:35:00Z',
      });

      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.diagnosisText, model.diagnosisText);
      expect(entity.icdCode, model.icdCode);
      expect(entity.diagnosisType, model.diagnosisType);
      expect(entity.notes, model.notes);
      expect(entity.diagnosedAt, model.diagnosedAt);
    });
  });
}
