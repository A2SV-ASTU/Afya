import 'package:equatable/equatable.dart';

import '../../domain/entities/appointment_entity.dart';

abstract class AppointmentsState extends Equatable {
  const AppointmentsState();

  @override
  List<Object?> get props => [];
}

class AppointmentsInitialState extends AppointmentsState {
  const AppointmentsInitialState();
}

class AppointmentsLoadingState extends AppointmentsState {
  const AppointmentsLoadingState();
}

class AppointmentsLoadedState extends AppointmentsState {
  final List<AppointmentEntity> appointments;
  final String? filterStatus;

  const AppointmentsLoadedState({
    required this.appointments,
    this.filterStatus,
  });

  List<AppointmentEntity> get upcomingAppointments => appointments
      .where((a) => a.status == AppointmentStatus.scheduled)
      .toList();

  List<AppointmentEntity> get pastAppointments => appointments
      .where((a) => a.status != AppointmentStatus.scheduled)
      .toList();

  @override
  List<Object?> get props => [appointments, filterStatus];
}

class AppointmentsErrorState extends AppointmentsState {
  final String message;
  final String? code;

  const AppointmentsErrorState({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}
