import '../../domain/entities/local_dose_record_entity.dart';

class LocalDoseRecordModel {
  final String id;
  final String prescriptionItemId;
  final String medicationName;
  final String dose;
  final DateTime scheduledTime;
  final DateTime? snoozedUntil;
  final DoseStatus status;
  final DateTime? recordedAt;
  final int snoozeCount;
  final String? skipReason;

  const LocalDoseRecordModel({
    required this.id,
    required this.prescriptionItemId,
    required this.medicationName,
    required this.dose,
    required this.scheduledTime,
    this.snoozedUntil,
    this.status = DoseStatus.pending,
    this.recordedAt,
    this.snoozeCount = 0,
    this.skipReason,
  });

  factory LocalDoseRecordModel.fromJson(Map<String, dynamic> json) {
    return LocalDoseRecordModel(
      id: json['id'] as String,
      prescriptionItemId: json['prescription_item_id'] as String,
      medicationName: json['medication_name'] as String,
      dose: json['dose'] as String,
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      snoozedUntil: json['snoozed_until'] != null
          ? DateTime.parse(json['snoozed_until'] as String)
          : null,
      status: _parseStatus(json['status'] as String),
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'] as String)
          : null,
      snoozeCount: (json['snooze_count'] as num?)?.toInt() ?? 0,
      skipReason: json['skip_reason'] as String?,
    );
  }

  LocalDoseRecordModel copyWith({
    String? id,
    String? prescriptionItemId,
    String? medicationName,
    String? dose,
    DateTime? scheduledTime,
    DateTime? snoozedUntil,
    bool clearSnoozedUntil = false,
    DoseStatus? status,
    DateTime? recordedAt,
    int? snoozeCount,
    String? skipReason,
    bool clearSkipReason = false,
  }) {
    return LocalDoseRecordModel(
      id: id ?? this.id,
      prescriptionItemId: prescriptionItemId ?? this.prescriptionItemId,
      medicationName: medicationName ?? this.medicationName,
      dose: dose ?? this.dose,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      snoozedUntil:
          clearSnoozedUntil ? null : (snoozedUntil ?? this.snoozedUntil),
      status: status ?? this.status,
      recordedAt: recordedAt ?? this.recordedAt,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      skipReason: clearSkipReason ? null : (skipReason ?? this.skipReason),
    );
  }

  static DoseStatus _parseStatus(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return DoseStatus.pending;
      case 'taken':
        return DoseStatus.taken;
      case 'missed':
        return DoseStatus.missed;
      case 'skipped':
        return DoseStatus.skipped;
      default:
        throw FormatException('Unknown dose status: $value');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescription_item_id': prescriptionItemId,
      'medication_name': medicationName,
      'dose': dose,
      'scheduled_time': scheduledTime.toIso8601String(),
      if (snoozedUntil != null)
        'snoozed_until': snoozedUntil!.toIso8601String(),
      'status': status.name,
      if (recordedAt != null) 'recorded_at': recordedAt!.toIso8601String(),
      'snooze_count': snoozeCount,
      if (skipReason != null) 'skip_reason': skipReason,
    };
  }

  LocalDoseRecordEntity toEntity() {
    return LocalDoseRecordEntity(
      id: id,
      prescriptionItemId: prescriptionItemId,
      medicationName: medicationName,
      dose: dose,
      scheduledTime: scheduledTime,
      snoozedUntil: snoozedUntil,
      status: status,
      recordedAt: recordedAt,
      snoozeCount: snoozeCount,
      skipReason: skipReason,
    );
  }

  factory LocalDoseRecordModel.fromEntity(LocalDoseRecordEntity entity) {
    return LocalDoseRecordModel(
      id: entity.id,
      prescriptionItemId: entity.prescriptionItemId,
      medicationName: entity.medicationName,
      dose: entity.dose,
      scheduledTime: entity.scheduledTime,
      snoozedUntil: entity.snoozedUntil,
      status: entity.status,
      recordedAt: entity.recordedAt,
      snoozeCount: entity.snoozeCount,
      skipReason: entity.skipReason,
    );
  }
}
