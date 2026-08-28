import '../../domain/entities/medical_history_summary_entity.dart';

class MedicalHistoryPrescriptionItemModel {
  final String medicationName;
  final String dose;
  final String route;
  final String frequency;
  final String duration;

  const MedicalHistoryPrescriptionItemModel({
    required this.medicationName,
    required this.dose,
    required this.route,
    required this.frequency,
    required this.duration,
  });

  factory MedicalHistoryPrescriptionItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MedicalHistoryPrescriptionItemModel(
      medicationName: json['medication_name'] as String,
      dose: json['dose'] as String,
      route: json['route'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medication_name': medicationName,
      'dose': dose,
      'route': route,
      'frequency': frequency,
      'duration': duration,
    };
  }

  MedicalHistoryPrescriptionItemEntity toEntity() {
    return MedicalHistoryPrescriptionItemEntity(
      medicationName: medicationName,
      dose: dose,
      route: route,
      frequency: frequency,
      duration: duration,
    );
  }
}

class MedicalHistoryVitalsModel {
  final int? systolicBp;
  final int? diastolicBp;
  final int? pulse;
  final int? respiratoryRate;
  final double? temperature;
  final double? spo2;
  final double? bloodSugar;
  final double? weight;

  const MedicalHistoryVitalsModel({
    this.systolicBp,
    this.diastolicBp,
    this.pulse,
    this.respiratoryRate,
    this.temperature,
    this.spo2,
    this.bloodSugar,
    this.weight,
  });

  factory MedicalHistoryVitalsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MedicalHistoryVitalsModel(
      systolicBp: (json['systolic_bp'] as num?)?.toInt(),
      diastolicBp: (json['diastolic_bp'] as num?)?.toInt(),
      pulse: (json['pulse'] as num?)?.toInt(),
      respiratoryRate: (json['respiratory_rate'] as num?)?.toInt(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      spo2: (json['spo2'] as num?)?.toDouble(),
      bloodSugar: (json['blood_sugar'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (systolicBp != null) 'systolic_bp': systolicBp,
      if (diastolicBp != null) 'diastolic_bp': diastolicBp,
      if (pulse != null) 'pulse': pulse,
      if (respiratoryRate != null) 'respiratory_rate': respiratoryRate,
      if (temperature != null) 'temperature': temperature,
      if (spo2 != null) 'spo2': spo2,
      if (bloodSugar != null) 'blood_sugar': bloodSugar,
      if (weight != null) 'weight': weight,
    };
  }

  MedicalHistoryVitalsEntity toEntity() {
    return MedicalHistoryVitalsEntity(
      systolicBp: systolicBp,
      diastolicBp: diastolicBp,
      pulse: pulse,
      respiratoryRate: respiratoryRate,
      temperature: temperature,
      spo2: spo2,
      bloodSugar: bloodSugar,
      weight: weight,
    );
  }
}

class MedicalHistorySummaryModel {
  final String encounterId;
  final DateTime date;
  final String chiefComplaint;
  final String? diagnosis;
  final List<MedicalHistoryPrescriptionItemModel> prescription;
  final MedicalHistoryVitalsModel vitals;

  const MedicalHistorySummaryModel({
    required this.encounterId,
    required this.date,
    required this.chiefComplaint,
    this.diagnosis,
    required this.prescription,
    required this.vitals,
  });

  factory MedicalHistorySummaryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MedicalHistorySummaryModel(
      encounterId: json['encounter_id'] as String,
      date: DateTime.parse(json['date'] as String),
      chiefComplaint: json['chief_complaint'] as String,
      diagnosis: json['diagnosis'] as String?,
      prescription: (json['prescription'] as List<dynamic>)
          .map(
            (item) => MedicalHistoryPrescriptionItemModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      vitals: MedicalHistoryVitalsModel.fromJson(
        json['vitals'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'encounter_id': encounterId,
      'date': date.toIso8601String(),
      'chief_complaint': chiefComplaint,
      if (diagnosis != null) 'diagnosis': diagnosis,
      'prescription': prescription.map((item) => item.toJson()).toList(),
      'vitals': vitals.toJson(),
    };
  }

  MedicalHistorySummaryEntity toEntity() {
    return MedicalHistorySummaryEntity(
      encounterId: encounterId,
      date: date,
      chiefComplaint: chiefComplaint,
      diagnosis: diagnosis,
      prescription: prescription.map((item) => item.toEntity()).toList(),
      vitals: vitals.toEntity(),
    );
  }
}
