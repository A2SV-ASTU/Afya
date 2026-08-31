import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/usecases/get_encounters_timeline_usecase.dart';
import 'package:afyamind_mobile/features/clinical_history/presentation/bloc/history_timeline_bloc.dart';
import 'package:afyamind_mobile/features/clinical_history/presentation/bloc/history_timeline_event.dart';
import 'package:afyamind_mobile/features/clinical_history/presentation/bloc/history_timeline_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetEncountersTimelineUseCase extends Mock
    implements GetEncountersTimelineUseCase {}

void main() {
  late HistoryTimelineBloc bloc;
  late MockGetEncountersTimelineUseCase mockGetEncountersTimelineUseCase;

  setUp(() {
    mockGetEncountersTimelineUseCase = MockGetEncountersTimelineUseCase();
    bloc = HistoryTimelineBloc(
      getEncountersTimelineUseCase: mockGetEncountersTimelineUseCase,
    );
  });

  tearDown(() {
    bloc.close();
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
    endedAt: DateTime(2026, 1, 10, 11, 0),
  );

  final List<EncounterEntity> tEncountersList = [tEncounter];

  test('initial state should be HistoryTimelineInitialState', () {
    expect(bloc.state, equals(const HistoryTimelineInitialState()));
  });

  blocTest<HistoryTimelineBloc, HistoryTimelineState>(
    'should emit [HistoryTimelineLoadingState, HistoryTimelineLoadedState] when FetchEncountersTimelineEvent succeeds',
    build: () {
      when(() => mockGetEncountersTimelineUseCase(
            patientId: 'p-123',
            page: 1,
            limit: 20,
          )).thenAnswer((_) async => Right(tEncountersList));
      return bloc;
    },
    act: (b) => b.add(const FetchEncountersTimelineEvent(patientId: 'p-123')),
    expect: () => [
      const HistoryTimelineLoadingState(),
      HistoryTimelineLoadedState(encounters: tEncountersList),
    ],
    verify: (_) {
      verify(() => mockGetEncountersTimelineUseCase(
            patientId: 'p-123',
            page: 1,
            limit: 20,
          )).called(1);
    },
  );

  blocTest<HistoryTimelineBloc, HistoryTimelineState>(
    'should emit [HistoryTimelineLoadingState, HistoryTimelineErrorState] when FetchEncountersTimelineEvent fails',
    build: () {
      when(() => mockGetEncountersTimelineUseCase(
            patientId: 'p-123',
            page: 1,
            limit: 20,
          )).thenAnswer((_) async => const Left(ServerFailure('Server Error')));
      return bloc;
    },
    act: (b) => b.add(const FetchEncountersTimelineEvent(patientId: 'p-123')),
    expect: () => [
      const HistoryTimelineLoadingState(),
      const HistoryTimelineErrorState(message: 'Server Error'),
    ],
  );
}
