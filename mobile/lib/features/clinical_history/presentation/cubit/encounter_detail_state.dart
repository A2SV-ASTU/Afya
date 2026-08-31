import 'package:equatable/equatable.dart';

import '../../domain/entities/encounter_detail_entity.dart';

abstract class EncounterDetailState extends Equatable {
  const EncounterDetailState();

  @override
  List<Object?> get props => [];
}

class EncounterDetailInitialState extends EncounterDetailState {
  const EncounterDetailInitialState();
}

class EncounterDetailLoadingState extends EncounterDetailState {
  const EncounterDetailLoadingState();
}

class EncounterDetailLoadedState extends EncounterDetailState {
  final EncounterDetailEntity detail;

  const EncounterDetailLoadedState({required this.detail});

  @override
  List<Object?> get props => [detail];
}

class EncounterDetailErrorState extends EncounterDetailState {
  final String message;
  final String? code;

  const EncounterDetailErrorState({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}
