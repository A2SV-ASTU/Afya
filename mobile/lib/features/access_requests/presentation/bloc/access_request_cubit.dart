import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/access_request_entity.dart';
import '../../domain/entities/clinic_grant_entity.dart';
import '../../domain/usecases/approve_access_request_usecase.dart';
import '../../domain/usecases/deny_access_request_usecase.dart';
import '../../domain/usecases/get_active_grants_usecase.dart';
import '../../domain/usecases/get_pending_access_requests_usecase.dart';
import '../../domain/usecases/revoke_clinic_grant_usecase.dart';
import '../../../../core/utils/countdown_timer_helper.dart';
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

  Future<void> fetchPendingRequest() async {
    emit(const AccessRequestLoading());

    final result = await _getPendingAccessRequestsUseCase();

    result.fold(
      (failure) => emit(AccessRequestError(message: failure.message)),
      (requests) {
        if (requests.isEmpty) {
          emit(const AccessRequestInitial());
          return;
        }

        _currentRequest = requests.first;

        if (CountdownTimerHelper.isExpired(_currentRequest!.expiresAt)) {
          emit(const AccessRequestExpired());
        } else {
          _startTimer(_currentRequest!);
        }
      },
    );
  }

  Future<void> approveRequest(String id) async {
    _cancelTimer();
    emit(AccessRequestSubmitting(requestId: id, isApproving: true));

    final result = await _approveAccessRequestUseCase(id);

    result.fold(
      (failure) => emit(AccessRequestError(message: failure.message)),
      (_) => emit(const AccessRequestSuccess(message: 'Access granted')),
    );
  }

  Future<void> denyRequest(String id) async {
    _cancelTimer();
    emit(AccessRequestSubmitting(requestId: id, isApproving: false));

    final result = await _denyAccessRequestUseCase(id);

    result.fold(
      (failure) => emit(AccessRequestError(message: failure.message)),
      (_) => emit(const AccessRequestSuccess(message: 'Request denied')),
    );
  }

  void _startTimer(AccessRequestEntity request) {
    _cancelTimer();

    final initialSeconds = CountdownTimerHelper.remainingSeconds(request.expiresAt);
    if (initialSeconds <= 0) {
      _handleExpiration(request.id);
      return;
    }

    emit(AccessRequestActive(
      request: request,
      formattedTime: CountdownTimerHelper.formatSeconds(initialSeconds),
      secondsRemaining: initialSeconds,
    ));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick(request);
    });
  }

  void _tick(AccessRequestEntity request) {
    final secondsRemaining = CountdownTimerHelper.remainingSeconds(request.expiresAt);

    if (secondsRemaining <= 0) {
      _handleExpiration(request.id);
    } else {
      emit(AccessRequestActive(
        request: request,
        formattedTime: CountdownTimerHelper.formatSeconds(secondsRemaining),
        secondsRemaining: secondsRemaining,
      ));
    }
  }

  void _handleExpiration(String requestId) {
    _cancelTimer();
    emit(const AccessRequestExpired());
    denyRequest(requestId);
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // -----------------------------------------------------------------------
  // Active Grants Logic
  // -----------------------------------------------------------------------

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
