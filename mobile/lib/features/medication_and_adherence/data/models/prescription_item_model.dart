import '../../domain/entities/prescription_item_entity.dart';

class PrescriptionItemModel extends PrescriptionItemEntity {
  const PrescriptionItemModel({
    required super.id,
    required super.encounterId,
    required super.medicationName,
    required super.dosage,
    required super.frequency,
    super.durationDays,
    super.instructions,
    super.status = PrescriptionItemStatus.active,
    super.startDate,
    super.endDate,
    super.createdAt,
    super.updatedAt,
  });

  factory PrescriptionItemModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String?;
    if (rawStatus == null) {
      throw const FormatException(
          'Missing required field "status" in prescription item');
    }
    final parsedStatus = PrescriptionItemStatus.fromString(rawStatus);

    return PrescriptionItemModel(
      id: json['id'] as String,
      encounterId: (json['encounter_id'] ?? json['encounterId']) as String,
      medicationName:
          (json['medication_name'] ?? json['medicationName']) as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      durationDays: (json['duration_days'] ?? json['durationDays']) as int?,
      instructions: json['instructions'] as String?,
      status: parsedStatus,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : (json['startDate'] != null
              ? DateTime.parse(json['startDate'] as String)
              : null),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : (json['endDate'] != null
              ? DateTime.parse(json['endDate'] as String)
              : null),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : (json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : (json['updatedAt'] != null
                  ? DateTime.parse(json['updatedAt'] as String)
                  : null)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'encounter_id': encounterId,
      'medication_name': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'duration_days': durationDays,
      'instructions': instructions,
      'status': status.value,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory PrescriptionItemModel.fromEntity(PrescriptionItemEntity entity) {
    return PrescriptionItemModel(
      id: entity.id,
      encounterId: entity.encounterId,
      medicationName: entity.medicationName,
      dosage: entity.dosage,
      frequency: entity.frequency,
      durationDays: entity.durationDays,
      instructions: entity.instructions,
      status: entity.status,
      startDate: entity.startDate,
      endDate: entity.endDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  PrescriptionItemEntity toEntity() => this;

  PrescriptionItemModel copyWith({
    String? id,
    String? encounterId,
    String? medicationName,
    String? dosage,
    String? frequency,
    int? durationDays,
    String? instructions,
    PrescriptionItemStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PrescriptionItemModel(
      id: id ?? this.id,
      encounterId: encounterId ?? this.encounterId,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      durationDays: durationDays ?? this.durationDays,
      instructions: instructions ?? this.instructions,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
