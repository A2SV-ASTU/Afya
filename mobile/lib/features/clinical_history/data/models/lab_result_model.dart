import '../../domain/entities/lab_result_entity.dart';

class LabResultModel {
  final String id;
  final String testName;
  final LabResultCategory category;
  final String summaryNotes;
  final Map<String, dynamic> measurements;
  final LabResultFlag? flag;
  final DateTime createdAt;

  const LabResultModel({
    required this.id,
    required this.testName,
    required this.category,
    required this.summaryNotes,
    required this.measurements,
    this.flag,
    required this.createdAt,
  });

  factory LabResultModel.fromJson(Map<String, dynamic> json) {
    return LabResultModel(
      id: json['id'] as String,
      testName: json['test_name'] as String,
      category: _parseCategory(json['category'] as String),
      summaryNotes: json['summary_notes'] as String,
      measurements: Map<String, dynamic>.from(
        json['measurements'] as Map,
      ),
      flag: json['flag'] != null ? _parseFlag(json['flag'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static LabResultCategory _parseCategory(String value) {
    switch (value) {
      case 'laboratory':
        return LabResultCategory.laboratory;
      case 'imaging':
        return LabResultCategory.imaging;
      case 'pathology':
        return LabResultCategory.pathology;
      case 'other':
        return LabResultCategory.other;
      default:
        throw FormatException('Unknown lab category: $value');
    }
  }

  static LabResultFlag _parseFlag(String value) {
    switch (value) {
      case 'normal':
        return LabResultFlag.normal;
      case 'abnormal':
        return LabResultFlag.abnormal;
      case 'critical':
        return LabResultFlag.critical;
      default:
        throw FormatException('Unknown lab flag: $value');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'test_name': testName,
      'category': category.name,
      'summary_notes': summaryNotes,
      'measurements': measurements,
      if (flag != null) 'flag': flag!.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  LabResultEntity toEntity() {
    return LabResultEntity(
      id: id,
      testName: testName,
      category: category,
      summaryNotes: summaryNotes,
      measurements: measurements,
      flag: flag,
      createdAt: createdAt,
    );
  }
}
