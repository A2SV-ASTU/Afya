import 'package:equatable/equatable.dart';

import '../../domain/entities/access_request_entity.dart';
import '../../domain/entities/clinic_grant_entity.dart';

/// Base initial state.
class AccessRequestInitial extends AccessRequestState {
  const AccessRequestInitial();
}

/// Loading while fetching active requests.
class AccessRequestLoading extends AccessRequestState {
  const AccessRequestLoading();
}

/// Active request with countdown timer value.
class AccessRequestActive extends AccessRequestState {
  final AccessRequestEntity request;
  final int secondsRemaining;

  const AccessRequestActive({
    required this.request,
    required this.secondsRemaining,
  });

  @override
  List<Object?> get props => [request, secondsRemaining];
}

/// Triggered when secondsRemaining <= 0 or HTTP 410 error occurs.
class AccessRequestExpired extends AccessRequestState {
  const AccessRequestExpired();
}

/// While executing approve/deny actions.
class AccessRequestActionInFlight extends AccessRequestState {
  const AccessRequestActionInFlight();
}

/// Success state holding outcome message.
class AccessRequestSuccess extends AccessRequestState {
  final String message;

  const AccessRequestSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Failure state holding error message.
class AccessRequestFailure extends AccessRequestState {
  final String message;

  const AccessRequestFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// Active Grants states
// ---------------------------------------------------------------------------

/// Loading while fetching active grants.
class ActiveGrantsLoading extends AccessRequestState {
  const ActiveGrantsLoading();
}

/// Loaded state holding the list of active clinic grants.
class ActiveGrantsLoaded extends AccessRequestState {
  final List<ClinicGrantEntity> grants;

  const ActiveGrantsLoaded({required this.grants});

  @override
  List<Object?> get props => [grants];
}

/// While executing a grant revocation action.
class RevokingGrant extends AccessRequestState {
  final List<ClinicGrantEntity> grants;

  const RevokingGrant({required this.grants});

  @override
  List<Object?> get props => [grants];
}

/// Failure state for active grants operations.
class ActiveGrantsFailure extends AccessRequestState {
  final String message;

  const ActiveGrantsFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Base state class for the access request cubit.
abstract class AccessRequestState extends Equatable {
  const AccessRequestState();

  @override
  List<Object?> get props => [];
}
