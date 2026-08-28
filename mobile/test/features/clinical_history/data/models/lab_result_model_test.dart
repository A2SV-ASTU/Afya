import 'package:flutter_test/flutter_test.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/lab_result_model.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/lab_result_entity.dart';

void main() {
  group('LabResultModel', () {
    test('parses normal laboratory result', () {
      final json = {
        'id': 'lab-1',
        'test_name': 'Blood Sugar',
        'category': 'laboratory',
        'summary_notes': 'Within normal range',
        'measurements': {
          'glucose': 95,
          'unit': 'mg/dL',
        },
        'flag': 'normal',
        'created_at': '2026-08-27T09:20:00Z',
      };

      final model = LabResultModel.fromJson(json);

      expect(model.id, 'lab-1');
      expect(model.testName, 'Blood Sugar');
      expect(
        model.category,
        LabResultCategory.laboratory,
      );
      expect(model.flag, LabResultFlag.normal);
      expect(model.measurements['glucose'], 95);
      expect(model.measurements['unit'], 'mg/dL');
    });

    test('parses abnormal flag', () {
      final json = {
        'id': 'lab-2',
        'test_name': 'CBC',
        'category': 'pathology',
        'summary_notes': 'Abnormal findings',
        'measurements': {
          'hemoglobin': 9.5,
        },
        'flag': 'abnormal',
        'created_at': '2026-08-27T09:25:00Z',
      };

      final model = LabResultModel.fromJson(json);

      expect(model.category, LabResultCategory.pathology);
      expect(model.flag, LabResultFlag.abnormal);
    });

    test('parses critical flag', () {
      final json = {
        'id': 'lab-3',
        'test_name': 'Blood Glucose',
        'category': 'laboratory',
        'summary_notes': 'Critical value',
        'measurements': {
          'glucose': 450,
        },
        'flag': 'critical',
        'created_at': '2026-08-27T09:30:00Z',
      };

      final model = LabResultModel.fromJson(json);

      expect(model.flag, LabResultFlag.critical);
    });

    test('allows null lab flag', () {
      final json = {
        'id': 'lab-4',
        'test_name': 'Chest X-Ray',
        'category': 'imaging',
        'summary_notes': 'Awaiting interpretation',
        'measurements': <String, dynamic>{},
        'flag': null,
        'created_at': '2026-08-27T09:35:00Z',
      };

      final model = LabResultModel.fromJson(json);

      expect(model.category, LabResultCategory.imaging);
      expect(model.flag, isNull);
    });

    test('parses other category', () {
      final json = {
        'id': 'lab-5',
        'test_name': 'Other test',
        'category': 'other',
        'summary_notes': 'Other category',
        'measurements': <String, dynamic>{},
        'flag': 'normal',
        'created_at': '2026-08-27T09:40:00Z',
      };

      final model = LabResultModel.fromJson(json);

      expect(model.category, LabResultCategory.other);
    });

    test('throws FormatException for unknown lab flag', () {
      final json = {
        'id': 'lab-6',
        'test_name': 'Unknown',
        'category': 'laboratory',
        'summary_notes': 'Unknown',
        'measurements': <String, dynamic>{},
        'flag': 'dangerous',
        'created_at': '2026-08-27T09:45:00Z',
      };

      expect(
        () => LabResultModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for unknown category', () {
      final json = {
        'id': 'lab-7',
        'test_name': 'Unknown',
        'category': 'genetics',
        'summary_notes': 'Unknown',
        'measurements': <String, dynamic>{},
        'flag': 'normal',
        'created_at': '2026-08-27T09:45:00Z',
      };

      expect(
        () => LabResultModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('toEntity maps all fields correctly', () {
      final model = LabResultModel.fromJson({
        'id': 'lab-1',
        'test_name': 'Blood Sugar',
        'category': 'laboratory',
        'summary_notes': 'Normal',
        'measurements': {
          'glucose': 95,
        },
        'flag': 'normal',
        'created_at': '2026-08-27T09:20:00Z',
      });

      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.testName, model.testName);
      expect(entity.category, model.category);
      expect(entity.summaryNotes, model.summaryNotes);
      expect(entity.measurements['glucose'], 95);
      expect(entity.flag, model.flag);
      expect(entity.createdAt, model.createdAt);
    });
  });
}
