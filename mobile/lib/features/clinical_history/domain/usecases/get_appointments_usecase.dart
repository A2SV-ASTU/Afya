import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/appointment_entity.dart';
import '../repositories/clinical_history_repository.dart';

@lazySingleton
class GetAppointmentsUseCase {
  final ClinicalHistoryRepository repository;

  const GetAppointmentsUseCase(this.repository);

  Future<Either<Failure, List<AppointmentEntity>>> call({
    required String patientId,
    String? status,
  }) {
    return repository.getAppointments(
      patientId: patientId,
      status: status,
    );
  }
}
