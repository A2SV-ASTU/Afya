import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/access_request_entity.dart';
import '../../domain/entities/clinic_grant_entity.dart';
import '../../domain/usecases/approve_access_request_usecase.dart';
import '../../domain/usecases/deny_access_request_usecase.dart';
import '../../domain/usecases/get_active_grants_usecase.dart';
import '../../domain/usecases/get_pending_access_requests_usecase.dart';
import '../../domain/usecases/revoke_clinic_grant_usecase.dart';
import '../utils/countdown_timer_helper.dart';
import 'access_request_state.dart';

class AccessRequestCubit extends Cubit<AccessRequestState> {
  final GetPendingAccessRequestsUseCase _getPendingAccessRequestsUseCase;
  final ApproveAccessRequestUseCase _approveAccessRequestUseCase;
  final DenyAccessRequestUseCase _denyAccessRequestUseCase;
  final GetActiveGrantsUseCase _getActiveGrantsUseCase;
  final RevokeClinicGrantUseCase _revokeClinicGrantUseCase;

  Timer? _timer;
  AccessRequestEntity? _currentRequest;
  List<ClinicGrantEntity> _activeGrants = [];

  AccessRequestCubit({
    required GetPendingAccessRequestsUseCase getPendingAccessRequestsUseCase,
    required ApproveAccessRequestUseCase approveAccessRequestUseCase,
    required DenyAccessRequestUseCase denyAccessRequestUseCase,
    required GetActiveGrantsUseCase getActiveGrantsUseCase,
    required RevokeClinicGrantUseCase revokeClinicGrantUseCase,
  })  : _getPendingAccessRequestsUseCase = getPendingAccessRequestsUseCase,
        _approveAccessRequestUseCase = approveAccessRequestUseCase,
        _denyAccessRequestUseCase = denyAccessRequestUseCase,
        _getActiveGrantsUseCase = getActiveGrantsUseCase,
        _revokeClinicGrantUseCase = revokeClinicGrantUseCase,
        super(const AccessRequestInitial());

  /// Fetches active pending access requests and starts the countdown timer.
  Future<void> fetchActiveRequest() async {
    emit(const AccessRequestLoading());

    final result = await _getPendingAccessRequestsUseCase();

    result.fold(
      (failure) => emit(AccessRequestFailure(message: failure.message)),
      (requests) {
        if (requests.isEmpty) {
          emit(const AccessRequestFailure(message: 'No pending access requests'));
          return;
        }

        _currentRequest = requests.first;
        _startTimer(_currentRequest!);
      },
    );
  }

  /// Approves the given access request by [id].
  Future<void> approveRequest(String id) async {
    emit(const AccessRequestActionInFlight());

    try {
      final result = await _approveAccessRequestUseCase(id);

      result.fold(
        (failure) => emit(AccessRequestFailure(message: failure.message)),
        (_) {
          _cancelTimer();
          emit(const AccessRequestSuccess(
            message: 'Access request approved successfully',
          ));
        },
      );
    } on ExpiredException {
      _cancelTimer();
      emit(const AccessRequestExpired());
    }
  }

  /// Denies the given access request by [id].
  Future<void> denyRequest(String id) async {
    emit(const AccessRequestActionInFlight());

    try {
      final result = await _denyAccessRequestUseCase(id);

      result.fold(
        (failure) => emit(AccessRequestFailure(message: failure.message)),
        (_) {
          _cancelTimer();
          emit(const AccessRequestSuccess(
            message: 'Access request denied successfully',
          ));
        },
      );
    } on ExpiredException {
      _cancelTimer();
      emit(const AccessRequestExpired());
    }
  }

  /// Starts a 1-second periodic timer that ticks down the remaining time.
  void _startTimer(AccessRequestEntity request) {
    _cancelTimer();

    final secondsRemaining = CountdownTimerHelper.remainingSeconds(request.expiresAt);

    if (secondsRemaining <= 0) {
      emit(const AccessRequestExpired());
      return;
    }

    emit(AccessRequestActive(
      request: request,
      secondsRemaining: secondsRemaining,
    ));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick(request);
    });
  }

  /// Single tick of the countdown timer.
  void _tick(AccessRequestEntity request) {
    final secondsRemaining = CountdownTimerHelper.remainingSeconds(request.expiresAt);

    if (secondsRemaining <= 0) {
      _cancelTimer();
      emit(const AccessRequestExpired());
    } else {
      emit(AccessRequestActive(
        request: request,
        secondsRemaining: secondsRemaining,
      ));
    }
  }

  /// Cancels the active timer to prevent memory leaks.
  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // -----------------------------------------------------------------------
  // Active Grants
  // -----------------------------------------------------------------------

  /// Fetches the list of active clinic access grants.
  Future<void> fetchActiveGrants() async {
    emit(const ActiveGrantsLoading());

    final result = await _getActiveGrantsUseCase();

    result.fold(
      (failure) => emit(ActiveGrantsFailure(message: failure.message)),
      (grants) {
        _activeGrants = List.of(grants);
        emit(ActiveGrantsLoaded(grants: _activeGrants));
      },
    );
  }

  /// Revokes a clinic grant by [clinicId].
  Future<void> revokeGrant(String clinicId) async {
    emit(RevokingGrant(grants: _activeGrants));

    final result = await _revokeClinicGrantUseCase(clinicId);

    result.fold(
      (failure) => emit(ActiveGrantsFailure(message: failure.message)),
      (_) {
        _activeGrants =
            _activeGrants.where((g) => g.clinicId != clinicId).toList();
        emit(ActiveGrantsLoaded(grants: _activeGrants));
      },
    );
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
