import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_appointments_usecase.dart';
import 'appointments_state.dart';

@injectable
class AppointmentsCubit extends Cubit<AppointmentsState> {
  final GetAppointmentsUseCase getAppointmentsUseCase;

  AppointmentsCubit({
    required this.getAppointmentsUseCase,
  }) : super(const AppointmentsInitialState());

  Future<void> fetchAppointments({
    required String patientId,
    String? status,
  }) async {
    emit(const AppointmentsLoadingState());

    final result = await getAppointmentsUseCase(
      patientId: patientId,
      status: status,
    );

    result.fold(
      (failure) => emit(
        AppointmentsErrorState(
          message: failure.message,
          code: failure.code,
        ),
      ),
      (appointments) => emit(
        AppointmentsLoadedState(
          appointments: appointments,
          filterStatus: status,
        ),
      ),
    );
  }
}
