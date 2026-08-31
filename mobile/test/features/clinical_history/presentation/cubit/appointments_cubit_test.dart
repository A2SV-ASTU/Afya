import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/appointment_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/usecases/get_appointments_usecase.dart';
import 'package:afyamind_mobile/features/clinical_history/presentation/cubit/appointments_cubit.dart';
import 'package:afyamind_mobile/features/clinical_history/presentation/cubit/appointments_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAppointmentsUseCase extends Mock
    implements GetAppointmentsUseCase {}

void main() {
  late AppointmentsCubit cubit;
  late MockGetAppointmentsUseCase mockGetAppointmentsUseCase;

  setUp(() {
    mockGetAppointmentsUseCase = MockGetAppointmentsUseCase();
    cubit = AppointmentsCubit(
      getAppointmentsUseCase: mockGetAppointmentsUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  final tAppointment = AppointmentEntity(
    id: 'apt-1',
    clinicId: 'clinic-1',
    doctorId: 'doc-1',
    patientId: 'p-123',
    scheduledAt: DateTime(2026, 2, 1),
    status: AppointmentStatus.scheduled,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final tAppointments = [tAppointment];

  test('initial state should be AppointmentsInitialState', () {
    expect(cubit.state, equals(const AppointmentsInitialState()));
  });

  blocTest<AppointmentsCubit, AppointmentsState>(
    'should emit [AppointmentsLoadingState, AppointmentsLoadedState] when fetchAppointments succeeds',
    build: () {
      when(() => mockGetAppointmentsUseCase(patientId: 'p-123', status: null))
          .thenAnswer((_) async => Right(tAppointments));
      return cubit;
    },
    act: (c) => c.fetchAppointments(patientId: 'p-123'),
    expect: () => [
      const AppointmentsLoadingState(),
      AppointmentsLoadedState(appointments: tAppointments),
    ],
  );

  blocTest<AppointmentsCubit, AppointmentsState>(
    'should emit [AppointmentsLoadingState, AppointmentsErrorState] when fetchAppointments fails',
    build: () {
      when(() => mockGetAppointmentsUseCase(patientId: 'p-123', status: null))
          .thenAnswer(
              (_) async => const Left(ServerFailure('Failed to fetch')));
      return cubit;
    },
    act: (c) => c.fetchAppointments(patientId: 'p-123'),
    expect: () => [
      const AppointmentsLoadingState(),
      const AppointmentsErrorState(message: 'Failed to fetch'),
    ],
  );
}
