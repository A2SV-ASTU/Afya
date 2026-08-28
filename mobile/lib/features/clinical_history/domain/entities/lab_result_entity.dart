import 'package:equatable/equatable.dart';

enum LabResultCategory {
  laboratory,
  imaging,
  pathology,
  other,
}

enum LabResultFlag {
  normal,
  abnormal,
  critical,
}

class LabResultEntity extends Equatable {
  final String id;
  final String testName;
  final LabResultCategory category;
  final String summaryNotes;
  final Map<String, dynamic> measurements;
  final LabResultFlag? flag;
  final DateTime createdAt;

  const LabResultEntity({
    required this.id,
    required this.testName,
    required this.category,
    required this.summaryNotes,
    required this.measurements,
    this.flag,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        testName,
        category,
        summaryNotes,
        measurements,
        flag,
        createdAt,
      ];
}
