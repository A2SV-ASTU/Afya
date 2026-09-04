import 'package:equatable/equatable.dart';

import '../../domain/entities/vital_sign_entity.dart';

sealed class VitalsSyncState extends Equatable {
  const VitalsSyncState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class VitalsInitial extends VitalsSyncState {}

/// Loading
class VitalsLoading extends VitalsSyncState {}

/// Vital saved offline successfully
class VitalSavedOffline extends VitalsSyncState {
  final String message;

  const VitalSavedOffline({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

/// Syncing data
class VitalsSyncing extends VitalsSyncState {}

/// Sync completed
class VitalsSynced extends VitalsSyncState {
  final int uploaded;

  const VitalsSynced({
    required this.uploaded,
  });

  @override
  List<Object?> get props => [uploaded];
}

/// Pending records available
class VitalsPendingLoaded extends VitalsSyncState {
  final List<VitalSignEntity> vitals;

  const VitalsPendingLoaded(this.vitals);

  @override
  List<Object?> get props => [vitals];
}

/// History loaded
class VitalsHistoryLoaded extends VitalsSyncState {
  final List<VitalSignEntity> history;

  const VitalsHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

/// Error
class VitalsError extends VitalsSyncState {
  final String message;

  const VitalsError(this.message);

  @override
  List<Object?> get props => [message];
}