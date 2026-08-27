import 'package:equatable/equatable.dart';

enum PrescriptionItemStatus {
  active,
  completed,
  deactivated;

  static PrescriptionItemStatus fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'active':
        return PrescriptionItemStatus.active;
      case 'completed':
        return PrescriptionItemStatus.completed;
      case 'deactivated':
        return PrescriptionItemStatus.deactivated;
      default:
        throw FormatException('Unknown PrescriptionItemStatus value: $value');
    }
  }

  String get value => name;
}

class PrescriptionItemEntity extends Equatable {
  final String id;
  final String encounterId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final int? durationDays;
  final String? instructions;
  final PrescriptionItemStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PrescriptionItemEntity({
    required this.id,
    required this.encounterId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    this.durationDays,
    this.instructions,
    this.status = PrescriptionItemStatus.active,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        encounterId,
        medicationName,
        dosage,
        frequency,
        durationDays,
        instructions,
        status,
        startDate,
        endDate,
        createdAt,
        updatedAt,
      ];
}
