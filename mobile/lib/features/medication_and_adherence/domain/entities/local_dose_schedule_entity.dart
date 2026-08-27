import 'package:equatable/equatable.dart';

enum DoseOutcome {
  pending,
  taken,
  missed,
  skipped;

  static DoseOutcome fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'pending':
        return DoseOutcome.pending;
      case 'taken':
        return DoseOutcome.taken;
      case 'missed':
        return DoseOutcome.missed;
      case 'skipped':
        return DoseOutcome.skipped;
      default:
        throw FormatException('Unknown DoseOutcome value: $value');
    }
  }

  String get value => name;
}

class LocalDoseScheduleEntity extends Equatable {
  final String id;
  final String prescriptionItemId;
  final String medicationName;
  final String dosage;
  final DateTime scheduledTime;
  final DoseOutcome outcome;
  final DateTime? loggedAt;
  final DateTime? snoozeUntil;
  final int snoozeCount;

  const LocalDoseScheduleEntity({
    required this.id,
    required this.prescriptionItemId,
    required this.medicationName,
    required this.dosage,
    required this.scheduledTime,
    this.outcome = DoseOutcome.pending,
    this.loggedAt,
    this.snoozeUntil,
    this.snoozeCount = 0,
  });

  LocalDoseScheduleEntity copyWith({
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
    return LocalDoseScheduleEntity(
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

  @override
  List<Object?> get props => [
        id,
        prescriptionItemId,
        medicationName,
        dosage,
        scheduledTime,
        outcome,
        loggedAt,
        snoozeUntil,
        snoozeCount,
      ];
}
