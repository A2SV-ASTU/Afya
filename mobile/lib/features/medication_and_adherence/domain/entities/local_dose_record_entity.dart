import 'package:equatable/equatable.dart';

enum DoseStatus {
  pending,
  taken,
  missed,
  skipped,
}

class LocalDoseRecordEntity extends Equatable {
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

  const LocalDoseRecordEntity({
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

  LocalDoseRecordEntity copyWith({
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
    return LocalDoseRecordEntity(
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

  @override
  List<Object?> get props => [
        id,
        prescriptionItemId,
        medicationName,
        dose,
        scheduledTime,
        snoozedUntil,
        status,
        recordedAt,
        snoozeCount,
        skipReason,
      ];
}
