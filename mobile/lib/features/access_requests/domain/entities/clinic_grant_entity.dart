import 'package:equatable/equatable.dart';

class ClinicGrantEntity extends Equatable {
  final String grantId;
  final String clinicId;
  final String clinicName;
  final DateTime grantedAt;
  final String status;

  const ClinicGrantEntity({
    required this.grantId,
    required this.clinicId,
    required this.clinicName,
    required this.grantedAt,
    this.status = 'active',
  });

  @override
  List<Object?> get props => [grantId, clinicId, clinicName, grantedAt, status];
}
