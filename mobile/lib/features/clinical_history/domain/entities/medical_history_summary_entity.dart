import 'package:equatable/equatable.dart';

class MedicalHistoryPrescriptionItemEntity extends Equatable {
  final String medicationName;
  final String dose;
  final String route;
  final String frequency;
  final String duration;

  const MedicalHistoryPrescriptionItemEntity({
    required this.medicationName,
    required this.dose,
    required this.route,
    required this.frequency,
    required this.duration,
  });

  @override
  List<Object?> get props => [
        medicationName,
        dose,
        route,
        frequency,
        duration,
      ];
}

class MedicalHistoryVitalsEntity extends Equatable {
  final int? systolicBp;
  final int? diastolicBp;
  final int? pulse;
  final int? respiratoryRate;
  final double? temperature;
  final double? spo2;
  final double? bloodSugar;
  final double? weight;

  const MedicalHistoryVitalsEntity({
    this.systolicBp,
    this.diastolicBp,
    this.pulse,
    this.respiratoryRate,
    this.temperature,
    this.spo2,
    this.bloodSugar,
    this.weight,
  });

  @override
  List<Object?> get props => [
        systolicBp,
        diastolicBp,
        pulse,
        respiratoryRate,
        temperature,
        spo2,
        bloodSugar,
        weight,
      ];
}

class MedicalHistorySummaryEntity extends Equatable {
  final String encounterId;
  final DateTime date;
  final String chiefComplaint;
  final String? diagnosis;
  final List<MedicalHistoryPrescriptionItemEntity> prescription;
  final MedicalHistoryVitalsEntity vitals;

  const MedicalHistorySummaryEntity({
    required this.encounterId,
    required this.date,
    required this.chiefComplaint,
    this.diagnosis,
    required this.prescription,
    required this.vitals,
  });

  @override
  List<Object?> get props => [
        encounterId,
        date,
        chiefComplaint,
        diagnosis,
        prescription,
        vitals,
      ];
}
