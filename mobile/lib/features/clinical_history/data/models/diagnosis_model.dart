import '../../domain/entities/diagnosis_entity.dart';

class DiagnosisModel {
  final String id;
  final String diagnosisText;
  final String? icdCode;
  final DiagnosisType diagnosisType;
  final String? notes;
  final DateTime diagnosedAt;

  const DiagnosisModel({
    required this.id,
    required this.diagnosisText,
    this.icdCode,
    required this.diagnosisType,
    this.notes,
    required this.diagnosedAt,
  });

  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisModel(
      id: json['id'] as String,
      diagnosisText: json['diagnosis_text'] as String,
      icdCode: json['icd_code'] as String?,
      diagnosisType: _parseDiagnosisType(json['diagnosis_type'] as String),
      notes: json['notes'] as String?,
      diagnosedAt: DateTime.parse(json['diagnosed_at'] as String),
    );
  }

  static DiagnosisType _parseDiagnosisType(String value) {
    switch (value) {
      case 'provisional':
        return DiagnosisType.provisional;
      case 'final':
        return DiagnosisType.finalDiagnosis;
      default:
        throw FormatException('Unknown diagnosis type: $value');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diagnosis_text': diagnosisText,
      if (icdCode != null) 'icd_code': icdCode,
      'diagnosis_type':
          diagnosisType == DiagnosisType.provisional ? 'provisional' : 'final',
      if (notes != null) 'notes': notes,
      'diagnosed_at': diagnosedAt.toIso8601String(),
    };
  }

  DiagnosisEntity toEntity() {
    return DiagnosisEntity(
      id: id,
      diagnosisText: diagnosisText,
      icdCode: icdCode,
      diagnosisType: diagnosisType,
      notes: notes,
      diagnosedAt: diagnosedAt,
    );
  }
}
