import 'package:equatable/equatable.dart';

class ClinicalEvaluationEntity extends Equatable {
  final String id;
  final String encounterId;
  final String chiefComplaint;
  final String historyOfPresentIllness;
  final String? pastAdmissions;
  final String? familyHistory;
  final String? allergiesNotes;
  final String? generalAppearance;
  final Map<String, dynamic>? systemExamination;
  final DateTime createdAt;

  const ClinicalEvaluationEntity({
    required this.id,
    required this.encounterId,
    required this.chiefComplaint,
    required this.historyOfPresentIllness,
    this.pastAdmissions,
    this.familyHistory,
    this.allergiesNotes,
    this.generalAppearance,
    this.systemExamination,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        encounterId,
        chiefComplaint,
        historyOfPresentIllness,
        pastAdmissions,
        familyHistory,
        allergiesNotes,
        generalAppearance,
        systemExamination,
        createdAt,
      ];
}
