import '../../domain/entities/local_dose_schedule_entity.dart';

class LocalDoseScheduleModel extends LocalDoseScheduleEntity {
  const LocalDoseScheduleModel({
    required super.id,
    required super.prescriptionItemId,
    required super.medicationName,
    required super.dosage,
    required super.scheduledTime,
    super.outcome = DoseOutcome.pending,
    super.loggedAt,
    super.snoozeUntil,
    super.snoozeCount = 0,
  });

  factory LocalDoseScheduleModel.fromJson(Map<String, dynamic> json) {
    final rawOutcome = json['outcome'] as String?;
    if (rawOutcome == null) {
      throw const FormatException(
          'Missing required field "outcome" in local dose schedule');
    }
    final parsedOutcome = DoseOutcome.fromString(rawOutcome);

    return LocalDoseScheduleModel(
      id: json['id'] as String,
      prescriptionItemId: (json['prescription_item_id'] ??
          json['prescriptionItemId']) as String,
      medicationName:
          (json['medication_name'] ?? json['medicationName']) as String,
      dosage: json['dosage'] as String,
      scheduledTime: DateTime.parse(
          (json['scheduled_time'] ?? json['scheduledTime']) as String),
      outcome: parsedOutcome,
      loggedAt: json['logged_at'] != null
          ? DateTime.parse(json['logged_at'] as String)
          : (json['loggedAt'] != null
              ? DateTime.parse(json['loggedAt'] as String)
              : null),
      snoozeUntil: json['snooze_until'] != null
          ? DateTime.parse(json['snooze_until'] as String)
          : (json['snoozeUntil'] != null
              ? DateTime.parse(json['snoozeUntil'] as String)
              : null),
      snoozeCount: (json['snooze_count'] ?? json['snoozeCount'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescription_item_id': prescriptionItemId,
      'medication_name': medicationName,
      'dosage': dosage,
      'scheduled_time': scheduledTime.toIso8601String(),
      'outcome': outcome.value,
      'logged_at': loggedAt?.toIso8601String(),
      'snooze_until': snoozeUntil?.toIso8601String(),
      'snooze_count': snoozeCount,
    };
  }

  factory LocalDoseScheduleModel.fromEntity(LocalDoseScheduleEntity entity) {
    return LocalDoseScheduleModel(
      id: entity.id,
      prescriptionItemId: entity.prescriptionItemId,
      medicationName: entity.medicationName,
      dosage: entity.dosage,
      scheduledTime: entity.scheduledTime,
      outcome: entity.outcome,
      loggedAt: entity.loggedAt,
      snoozeUntil: entity.snoozeUntil,
      snoozeCount: entity.snoozeCount,
    );
  }

  LocalDoseScheduleEntity toEntity() => this;

  @override
  LocalDoseScheduleModel copyWith({
    String? id,
    String? prescriptionItemId,
    String? medicationName,
    String? dosage,
    DateTime? scheduledTime,
    DoseOutcome? outcome,
    DateTime? loggedAt,
    DateTime? snoozeUntil,
    int? snoozeCount,
  }) {
    return LocalDoseScheduleModel(
      id: id ?? this.id,
      prescriptionItemId: prescriptionItemId ?? this.prescriptionItemId,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      outcome: outcome ?? this.outcome,
      loggedAt: loggedAt ?? this.loggedAt,
      snoozeUntil: snoozeUntil ?? this.snoozeUntil,
      snoozeCount: snoozeCount ?? this.snoozeCount,
    );
  }
}
