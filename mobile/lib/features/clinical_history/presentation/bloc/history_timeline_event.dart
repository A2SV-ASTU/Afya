import 'package:equatable/equatable.dart';

abstract class HistoryTimelineEvent extends Equatable {
  const HistoryTimelineEvent();

  @override
  List<Object?> get props => [];
}

class FetchEncountersTimelineEvent extends HistoryTimelineEvent {
  final String patientId;
  final int page;
  final int limit;

  const FetchEncountersTimelineEvent({
    required this.patientId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [patientId, page, limit];
}

class RefreshEncountersTimelineEvent extends HistoryTimelineEvent {
  final String patientId;

  const RefreshEncountersTimelineEvent({required this.patientId});

  @override
  List<Object?> get props => [patientId];
}
