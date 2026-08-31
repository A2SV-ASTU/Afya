import 'package:equatable/equatable.dart';

class AccessRequestEntity extends Equatable {
  final String id;
  final String clinicId;
  final String clinicName;
  final String doctorName;
  final String reason;
  final String status;
  final DateTime expiresAt;
  final DateTime createdAt;

  const AccessRequestEntity({
    required this.id,
    required this.clinicId,
    required this.clinicName,
    required this.doctorName,
    required this.reason,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        clinicId,
        clinicName,
        doctorName,
        reason,
        status,
        expiresAt,
        createdAt,
      ];
}
