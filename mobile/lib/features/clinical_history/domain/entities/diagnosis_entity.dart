import 'package:equatable/equatable.dart';

enum DiagnosisType {
  provisional,
  finalDiagnosis,
}

class DiagnosisEntity extends Equatable {
  final String id;
  final String diagnosisText;
  final String? icdCode;
  final DiagnosisType diagnosisType;
  final String? notes;
  final DateTime diagnosedAt;

  const DiagnosisEntity({
    required this.id,
    required this.diagnosisText,
    this.icdCode,
    required this.diagnosisType,
    this.notes,
    required this.diagnosedAt,
  });

  @override
  List<Object?> get props => [
        id,
        diagnosisText,
        icdCode,
        diagnosisType,
        notes,
        diagnosedAt,
      ];
}
