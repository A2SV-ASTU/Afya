import '../../domain/entities/encounter_detail_entity.dart';
import '../../domain/entities/clinical_evaluation_entity.dart';
import 'diagnosis_model.dart';
import 'encounter_model.dart';
import 'lab_result_model.dart';

class EncounterVitalModel {
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

  const EncounterVitalModel({
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

  factory EncounterVitalModel.fromJson(Map<String, dynamic> json) {
    return EncounterVitalModel(
      id: json['id'] as String,
      source: _parseSource(json['source'] as String),
      systolicBp: (json['systolic_bp'] as num?)?.toInt(),
      diastolicBp: (json['diastolic_bp'] as num?)?.toInt(),
      pulse: (json['pulse'] as num?)?.toInt(),
      respiratoryRate: (json['respiratory_rate'] as num?)?.toInt(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      spo2: (json['spo2'] as num?)?.toDouble(),
      bloodSugar: (json['blood_sugar'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }

  static EncounterVitalSource _parseSource(String value) {
    switch (value) {
      case 'clinic':
        return EncounterVitalSource.clinic;
      case 'patient':
        return EncounterVitalSource.patient;
      default:
        throw FormatException('Unknown vital source: $value');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source.name,
      if (systolicBp != null) 'systolic_bp': systolicBp,
      if (diastolicBp != null) 'diastolic_bp': diastolicBp,
      if (pulse != null) 'pulse': pulse,
      if (respiratoryRate != null) 'respiratory_rate': respiratoryRate,
      if (temperature != null) 'temperature': temperature,
      if (spo2 != null) 'spo2': spo2,
      if (bloodSugar != null) 'blood_sugar': bloodSugar,
      if (weight != null) 'weight': weight,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  EncounterVitalEntity toEntity() {
    return EncounterVitalEntity(
      id: id,
      source: source,
      systolicBp: systolicBp,
      diastolicBp: diastolicBp,
      pulse: pulse,
      respiratoryRate: respiratoryRate,
      temperature: temperature,
      spo2: spo2,
      bloodSugar: bloodSugar,
      weight: weight,
      recordedAt: recordedAt,
    );
  }
}

class EncounterPrescriptionItemModel {
  final String id;
  final String medicationName;
  final String dose;
  final String route;
  final String frequency;
  final String duration;
  final EncounterPrescriptionStatus status;
  final String? instructions;
  final DateTime startedAt;

  const EncounterPrescriptionItemModel({
    required this.id,
    required this.medicationName,
    required this.dose,
    required this.route,
    required this.frequency,
    required this.duration,
    required this.status,
    this.instructions,
    required this.startedAt,
  });

  factory EncounterPrescriptionItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EncounterPrescriptionItemModel(
      id: json['id'] as String,
      medicationName: json['medication_name'] as String,
      dose: json['dose'] as String,
      route: json['route'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
      status: _parseStatus(json['status'] as String),
      instructions: json['instructions'] as String?,
      startedAt: DateTime.parse(json['started_at'] as String),
    );
  }

  static EncounterPrescriptionStatus _parseStatus(String value) {
    switch (value) {
      case 'active':
        return EncounterPrescriptionStatus.active;
      case 'deactivated':
        return EncounterPrescriptionStatus.deactivated;
      case 'completed':
        return EncounterPrescriptionStatus.completed;
      default:
        throw FormatException(
          'Unknown prescription status: $value',
        );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medication_name': medicationName,
      'dose': dose,
      'route': route,
      'frequency': frequency,
      'duration': duration,
      'status': status.name,
      if (instructions != null) 'instructions': instructions,
      'started_at': startedAt.toIso8601String(),
    };
  }

  EncounterPrescriptionItemEntity toEntity() {
    return EncounterPrescriptionItemEntity(
      id: id,
      medicationName: medicationName,
      dose: dose,
      route: route,
      frequency: frequency,
      duration: duration,
      status: status,
      instructions: instructions,
      startedAt: startedAt,
    );
  }
}

class EncounterPrescriptionModel {
  final String id;
  final String? notes;
  final DateTime prescribedAt;
  final List<EncounterPrescriptionItemModel> items;

  const EncounterPrescriptionModel({
    required this.id,
    this.notes,
    required this.prescribedAt,
    required this.items,
  });

  factory EncounterPrescriptionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EncounterPrescriptionModel(
      id: json['id'] as String,
      notes: json['notes'] as String?,
      prescribedAt: DateTime.parse(json['prescribed_at'] as String),
      items: (json['items'] as List<dynamic>)
          .map(
            (item) => EncounterPrescriptionItemModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (notes != null) 'notes': notes,
      'prescribed_at': prescribedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  EncounterPrescriptionEntity toEntity() {
    return EncounterPrescriptionEntity(
      id: id,
      notes: notes,
      prescribedAt: prescribedAt,
      items: items.map((item) => item.toEntity()).toList(),
    );
  }
}

class EncounterDetailModel {
  final EncounterModel encounter;
  final List<EncounterVitalModel> vitals;
  final List<LabResultModel> labs;
  final List<DiagnosisModel> diagnoses;
  final List<EncounterPrescriptionModel> prescriptions;

  const EncounterDetailModel({
    required this.encounter,
    required this.vitals,
    required this.labs,
    required this.diagnoses,
    required this.prescriptions,
  });

  factory EncounterDetailModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EncounterDetailModel(
      encounter: EncounterModel.fromJson(
        json['encounter'] as Map<String, dynamic>,
      ),
      vitals: (json['vitals'] as List<dynamic>)
          .map(
            (item) => EncounterVitalModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      labs: (json['labs'] as List<dynamic>)
          .map(
            (item) => LabResultModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      diagnoses: (json['diagnoses'] as List<dynamic>)
          .map(
            (item) => DiagnosisModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      prescriptions: (json['prescriptions'] as List<dynamic>)
          .map(
            (item) => EncounterPrescriptionModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'encounter': encounter.toJson(),
      'vitals': vitals.map((item) => item.toJson()).toList(),
      'labs': labs.map((item) => item.toJson()).toList(),
      'diagnoses': diagnoses.map((item) => item.toJson()).toList(),
      'prescriptions': prescriptions.map((item) => item.toJson()).toList(),
    };
  }

  EncounterDetailEntity toEntity({
    ClinicalEvaluationEntity? clinicalEvaluation,
  }) {
    return EncounterDetailEntity(
      encounter: encounter.toEntity(),
      clinicalEvaluation: clinicalEvaluation,
      vitals: vitals.map((item) => item.toEntity()).toList(),
      labs: labs.map((item) => item.toEntity()).toList(),
      diagnoses: diagnoses.map((item) => item.toEntity()).toList(),
      prescriptions: prescriptions.map((item) => item.toEntity()).toList(),
    );
  }
}
