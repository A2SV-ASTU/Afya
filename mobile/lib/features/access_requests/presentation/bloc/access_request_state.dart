import 'package:equatable/equatable.dart';

import '../../domain/entities/access_request_entity.dart';
import '../../domain/entities/clinic_grant_entity.dart';

abstract class AccessRequestState extends Equatable {
  const AccessRequestState();

  @override
  List<Object?> get props => [];
}

class AccessRequestInitial extends AccessRequestState {
  const AccessRequestInitial();
}

class AccessRequestLoading extends AccessRequestState {
  const AccessRequestLoading();
}

class AccessRequestActive extends AccessRequestState {
  final AccessRequestEntity request;
  final String formattedTime;
  final int secondsRemaining;

  const AccessRequestActive({
    required this.request,
    required this.formattedTime,
    required this.secondsRemaining,
  });

  @override
  List<Object?> get props => [request, formattedTime, secondsRemaining];
}

class AccessRequestSubmitting extends AccessRequestState {
  final String requestId;
  final bool isApproving;

  const AccessRequestSubmitting({
    required this.requestId,
    required this.isApproving,
  });

  @override
  List<Object?> get props => [requestId, isApproving];
}

class AccessRequestExpired extends AccessRequestState {
  const AccessRequestExpired();
}

class AccessRequestSuccess extends AccessRequestState {
  final String message;

  const AccessRequestSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AccessRequestError extends AccessRequestState {
  final String message;

  const AccessRequestError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// Active Grants states
// ---------------------------------------------------------------------------

class ActiveGrantsLoading extends AccessRequestState {
  const ActiveGrantsLoading();
}

class ActiveGrantsLoaded extends AccessRequestState {
  final List<ClinicGrantEntity> grants;

  const ActiveGrantsLoaded({required this.grants});

  @override
  List<Object?> get props => [grants];
}

class RevokingGrant extends AccessRequestState {
  final List<ClinicGrantEntity> grants;

  const RevokingGrant({required this.grants});

  @override
  List<Object?> get props => [grants];
}

class ActiveGrantsFailure extends AccessRequestState {
  final String message;

  const ActiveGrantsFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
