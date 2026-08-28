import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_encounters_timeline_usecase.dart';
import 'history_timeline_event.dart';
import 'history_timeline_state.dart';

@injectable
class HistoryTimelineBloc
    extends Bloc<HistoryTimelineEvent, HistoryTimelineState> {
  final GetEncountersTimelineUseCase getEncountersTimelineUseCase;

  HistoryTimelineBloc({
    required this.getEncountersTimelineUseCase,
  }) : super(const HistoryTimelineInitialState()) {
    on<FetchEncountersTimelineEvent>(_onFetchTimeline);
    on<RefreshEncountersTimelineEvent>(_onRefreshTimeline);
  }

  Future<void> _onFetchTimeline(
    FetchEncountersTimelineEvent event,
    Emitter<HistoryTimelineState> emit,
  ) async {
    emit(const HistoryTimelineLoadingState());

    final result = await getEncountersTimelineUseCase(
      patientId: event.patientId,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(
        HistoryTimelineErrorState(
          message: failure.message,
          code: failure.code,
        ),
      ),
      (encounters) => emit(
        HistoryTimelineLoadedState(encounters: encounters),
      ),
    );
  }

  Future<void> _onRefreshTimeline(
    RefreshEncountersTimelineEvent event,
    Emitter<HistoryTimelineState> emit,
  ) async {
    final currentState = state;
    if (currentState is HistoryTimelineLoadedState) {
      emit(HistoryTimelineLoadedState(
        encounters: currentState.encounters,
        isRefreshing: true,
      ));
    } else {
      emit(const HistoryTimelineLoadingState());
    }

    final result = await getEncountersTimelineUseCase(
      patientId: event.patientId,
    );

    result.fold(
      (failure) => emit(
        HistoryTimelineErrorState(
          message: failure.message,
          code: failure.code,
        ),
      ),
      (encounters) => emit(
        HistoryTimelineLoadedState(encounters: encounters),
      ),
    );
  }
}
