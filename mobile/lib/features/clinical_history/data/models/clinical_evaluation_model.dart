import '../../domain/entities/clinical_evaluation_entity.dart';

class ClinicalEvaluationModel {
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

  const ClinicalEvaluationModel({
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

  factory ClinicalEvaluationModel.fromJson(Map<String, dynamic> json) {
    return ClinicalEvaluationModel(
      id: json['id'] as String,
      encounterId: json['encounter_id'] as String,
      chiefComplaint: json['chief_complaint'] as String,
      historyOfPresentIllness: json['history_of_present_illness'] as String,
      pastAdmissions: json['past_admissions'] as String?,
      familyHistory: json['family_history'] as String?,
      allergiesNotes: json['allergies_notes'] as String?,
      generalAppearance: json['general_appearance'] as String?,
      systemExamination: json['system_examination'] != null
          ? Map<String, dynamic>.from(
              json['system_examination'] as Map,
            )
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'encounter_id': encounterId,
      'chief_complaint': chiefComplaint,
      'history_of_present_illness': historyOfPresentIllness,
      if (pastAdmissions != null) 'past_admissions': pastAdmissions,
      if (familyHistory != null) 'family_history': familyHistory,
      if (allergiesNotes != null) 'allergies_notes': allergiesNotes,
      if (generalAppearance != null) 'general_appearance': generalAppearance,
      if (systemExamination != null) 'system_examination': systemExamination,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ClinicalEvaluationEntity toEntity() {
    return ClinicalEvaluationEntity(
      id: id,
      encounterId: encounterId,
      chiefComplaint: chiefComplaint,
      historyOfPresentIllness: historyOfPresentIllness,
      pastAdmissions: pastAdmissions,
      familyHistory: familyHistory,
      allergiesNotes: allergiesNotes,
      generalAppearance: generalAppearance,
      systemExamination: systemExamination,
      createdAt: createdAt,
    );
  }
}
