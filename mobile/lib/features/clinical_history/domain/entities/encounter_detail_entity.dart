import 'package:equatable/equatable.dart';

import 'clinical_evaluation_entity.dart';
import 'diagnosis_entity.dart';
import 'encounter_entity.dart';
import 'lab_result_entity.dart';

enum EncounterVitalSource {
  clinic,
  patient,
}

class EncounterVitalEntity extends Equatable {
  final String id;
  final EncounterVitalSource source;
  final int? systolicBp;
  final int? diastolicBp;
  final int? pulse;
  final int? respiratoryRate;
  final double? temperature;
  final double? spo2;
  final double? bloodSugar;
  final double? weight;
  final DateTime recordedAt;

  const EncounterVitalEntity({
    required this.id,
    required this.source,
    this.systolicBp,
    this.diastolicBp,
    this.pulse,
    this.respiratoryRate,
    this.temperature,
    this.spo2,
    this.bloodSugar,
    this.weight,
    required this.recordedAt,
  });

  @override
  List<Object?> get props => [
        id,
        source,
        systolicBp,
        diastolicBp,
        pulse,
        respiratoryRate,
        temperature,
        spo2,
        bloodSugar,
        weight,
        recordedAt,
      ];
}

enum EncounterPrescriptionStatus {
  active,
  deactivated,
  completed,
}

class EncounterPrescriptionItemEntity extends Equatable {
  final String id;
  final String? prescriptionId;
  final String medicationName;
  final String dose;
  final String route;
  final String frequency;
  final String duration;
  final EncounterPrescriptionStatus status;
  final String? instructions;
  final DateTime startedAt;
  final bool isTrackingActive;

  const EncounterPrescriptionItemEntity({
    required this.id,
    this.prescriptionId,
    required this.medicationName,
    required this.dose,
    required this.route,
    required this.frequency,
    required this.duration,
    required this.status,
    this.instructions,
    required this.startedAt,
    this.isTrackingActive = false,
  });

  EncounterPrescriptionItemEntity copyWith({
    String? id,
    String? prescriptionId,
    String? medicationName,
    String? dose,
    String? route,
    String? frequency,
    String? duration,
    EncounterPrescriptionStatus? status,
    String? instructions,
    DateTime? startedAt,
    bool? isTrackingActive,
  }) {
    return EncounterPrescriptionItemEntity(
      id: id ?? this.id,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      medicationName: medicationName ?? this.medicationName,
      dose: dose ?? this.dose,
      route: route ?? this.route,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      instructions: instructions ?? this.instructions,
      startedAt: startedAt ?? this.startedAt,
      isTrackingActive: isTrackingActive ?? this.isTrackingActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        prescriptionId,
        medicationName,
        dose,
        route,
        frequency,
        duration,
        status,
        instructions,
        startedAt,
        isTrackingActive,
      ];
}

class EncounterPrescriptionEntity extends Equatable {
  final String id;
  final String? notes;
  final DateTime prescribedAt;
  final List<EncounterPrescriptionItemEntity> items;

  const EncounterPrescriptionEntity({
    required this.id,
    this.notes,
    required this.prescribedAt,
    required this.items,
  });

  @override
  List<Object?> get props => [
        id,
        notes,
        prescribedAt,
        items,
      ];
}

class EncounterDetailEntity extends Equatable {
  final EncounterEntity encounter;
  final ClinicalEvaluationEntity? clinicalEvaluation;
  final List<EncounterVitalEntity> vitals;
  final List<LabResultEntity> labs;
  final List<DiagnosisEntity> diagnoses;
  final List<EncounterPrescriptionEntity> prescriptions;

  const EncounterDetailEntity({
    required this.encounter,
    this.clinicalEvaluation,
    required this.vitals,
    required this.labs,
    required this.diagnoses,
    required this.prescriptions,
  });

  @override
  List<Object?> get props => [
        encounter,
        clinicalEvaluation,
        vitals,
        labs,
        diagnoses,
        prescriptions,
      ];
}
