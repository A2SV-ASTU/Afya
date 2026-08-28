import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_detail_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/usecases/get_encounter_detail_usecase.dart';
import 'package:afyamind_mobile/features/clinical_history/presentation/cubit/encounter_detail_cubit.dart';
import 'package:afyamind_mobile/features/clinical_history/presentation/cubit/encounter_detail_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetEncounterDetailUseCase extends Mock
    implements GetEncounterDetailUseCase {}

void main() {
  late EncounterDetailCubit cubit;
  late MockGetEncounterDetailUseCase mockGetEncounterDetailUseCase;

  setUp(() {
    mockGetEncounterDetailUseCase = MockGetEncounterDetailUseCase();
    cubit = EncounterDetailCubit(
      getEncounterDetailUseCase: mockGetEncounterDetailUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  final tEncounter = EncounterEntity(
    id: 'enc-1',
    clinicId: 'clinic-1',
    clinicName: 'St. Mary Clinic',
    openedByDoctorId: 'doc-1',
    doctorName: 'Sarah Jenkins',
    patientId: 'p-123',
    status: EncounterStatus.closed,
    startedAt: DateTime(2026, 1, 10),
  );

  final tDetail = EncounterDetailEntity(
    encounter: tEncounter,
    vitals: const [],
    labs: const [],
    diagnoses: const [],
    prescriptions: const [],
  );

  test('initial state should be EncounterDetailInitialState', () {
    expect(cubit.state, equals(const EncounterDetailInitialState()));
  });

  blocTest<EncounterDetailCubit, EncounterDetailState>(
    'should emit [EncounterDetailLoadingState, EncounterDetailLoadedState] when fetchEncounterDetail succeeds',
    build: () {
      when(() => mockGetEncounterDetailUseCase(encounterId: 'enc-1'))
          .thenAnswer((_) async => Right(tDetail));
      return cubit;
    },
    act: (c) => c.fetchEncounterDetail('enc-1'),
    expect: () => [
      const EncounterDetailLoadingState(),
      EncounterDetailLoadedState(detail: tDetail),
    ],
  );

  blocTest<EncounterDetailCubit, EncounterDetailState>(
    'should emit [EncounterDetailLoadingState, EncounterDetailErrorState] when fetchEncounterDetail fails',
    build: () {
      when(() => mockGetEncounterDetailUseCase(encounterId: 'enc-1'))
          .thenAnswer(
              (_) async => const Left(ServerFailure('Encounter not found')));
      return cubit;
    },
    act: (c) => c.fetchEncounterDetail('enc-1'),
    expect: () => [
      const EncounterDetailLoadingState(),
      const EncounterDetailErrorState(message: 'Encounter not found'),
    ],
  );
}
