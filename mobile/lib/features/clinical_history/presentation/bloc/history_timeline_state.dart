import 'package:equatable/equatable.dart';

import '../../domain/entities/encounter_entity.dart';

abstract class HistoryTimelineState extends Equatable {
  const HistoryTimelineState();

  @override
  List<Object?> get props => [];
}

class HistoryTimelineInitialState extends HistoryTimelineState {
  const HistoryTimelineInitialState();
}

class HistoryTimelineLoadingState extends HistoryTimelineState {
  const HistoryTimelineLoadingState();
}

class HistoryTimelineLoadedState extends HistoryTimelineState {
  final List<EncounterEntity> encounters;
  final bool isRefreshing;

  const HistoryTimelineLoadedState({
    required this.encounters,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [encounters, isRefreshing];
}

class HistoryTimelineErrorState extends HistoryTimelineState {
  final String message;
  final String? code;

  const HistoryTimelineErrorState({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}
