import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/access_request_entity.dart';
import '../../domain/usecases/approve_access_request_usecase.dart';
import '../../domain/usecases/deny_access_request_usecase.dart';
import '../../domain/usecases/get_pending_access_requests_usecase.dart';

// --- Events ---
abstract class PendingAccessRequestsEvent extends Equatable {
  const PendingAccessRequestsEvent();

  @override
  List<Object?> get props => [];
}

class FetchPendingAccessRequestsEvent extends PendingAccessRequestsEvent {}

class ApproveAccessRequestEvent extends PendingAccessRequestsEvent {
  final String requestId;

  const ApproveAccessRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class DenyAccessRequestEvent extends PendingAccessRequestsEvent {
  final String requestId;

  const DenyAccessRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class AccessRequestExpiredEvent extends PendingAccessRequestsEvent {
  final String requestId;
  final String clinicName;

  const AccessRequestExpiredEvent(this.requestId, this.clinicName);

  @override
  List<Object?> get props => [requestId, clinicName];
}

class _TickExpirationsEvent extends PendingAccessRequestsEvent {}

// --- States ---
abstract class PendingAccessRequestsState extends Equatable {
  const PendingAccessRequestsState();

  @override
  List<Object?> get props => [];
}

class PendingAccessRequestsInitial extends PendingAccessRequestsState {
  const PendingAccessRequestsInitial();
}

class PendingAccessRequestsLoading extends PendingAccessRequestsState {
  const PendingAccessRequestsLoading();
}

class PendingAccessRequestsLoaded extends PendingAccessRequestsState {
  final List<AccessRequestEntity> requests;
  final String? autoExpiredClinicName; // For snackbar trigger

  const PendingAccessRequestsLoaded(this.requests, {this.autoExpiredClinicName});

  @override
  List<Object?> get props => [requests, autoExpiredClinicName];
}

class PendingAccessRequestsEmpty extends PendingAccessRequestsState {
  final String? autoExpiredClinicName;

  const PendingAccessRequestsEmpty({this.autoExpiredClinicName});

  @override
  List<Object?> get props => [autoExpiredClinicName];
}

class PendingAccessRequestsError extends PendingAccessRequestsState {
  final String message;

  const PendingAccessRequestsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AccessRequestActionSuccess extends PendingAccessRequestsState {
  final String message;
  final List<AccessRequestEntity> requests;

  const AccessRequestActionSuccess(this.message, this.requests);

  @override
  List<Object?> get props => [message, requests];
}

// --- BLoC ---
@injectable
class PendingAccessRequestsBloc
    extends Bloc<PendingAccessRequestsEvent, PendingAccessRequestsState> {
  final GetPendingAccessRequestsUseCase _getPendingUseCase;
  final ApproveAccessRequestUseCase _approveUseCase;
  final DenyAccessRequestUseCase _denyUseCase;

  Timer? _ticker;

  PendingAccessRequestsBloc({
    required GetPendingAccessRequestsUseCase getPendingUseCase,
    required ApproveAccessRequestUseCase approveUseCase,
    required DenyAccessRequestUseCase denyUseCase,
  })  : _getPendingUseCase = getPendingUseCase,
        _approveUseCase = approveUseCase,
        _denyUseCase = denyUseCase,
        super(const PendingAccessRequestsInitial()) {
    on<FetchPendingAccessRequestsEvent>(_onFetchPending);
    on<ApproveAccessRequestEvent>(_onApprove);
    on<DenyAccessRequestEvent>(_onDeny);
    on<AccessRequestExpiredEvent>(_onRequestExpired);
    on<_TickExpirationsEvent>(_onTickExpirations);
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }

  Future<void> _onFetchPending(
    FetchPendingAccessRequestsEvent event,
    Emitter<PendingAccessRequestsState> emit,
  ) async {
    emit(const PendingAccessRequestsLoading());

    final result = await _getPendingUseCase();

    result.fold(
      (failure) => emit(PendingAccessRequestsError(failure.message)),
      (requests) {
        final now = DateTime.now();
        final validRequests = requests.where((r) => r.expiresAt.isAfter(now)).toList();

        _ticker?.cancel();
        if (validRequests.isNotEmpty) {
          _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
            add(_TickExpirationsEvent());
          });
          emit(PendingAccessRequestsLoaded(validRequests));
        } else {
          emit(const PendingAccessRequestsEmpty());
        }
      },
    );
  }

  void _onTickExpirations(
    _TickExpirationsEvent event,
    Emitter<PendingAccessRequestsState> emit,
  ) {
    if (state is PendingAccessRequestsLoaded) {
      final currentRequests = (state as PendingAccessRequestsLoaded).requests;
      final now = DateTime.now();

      for (var req in currentRequests) {
        if (!req.expiresAt.isAfter(now)) {
          add(AccessRequestExpiredEvent(req.id, req.clinicName));
        }
      }
    }
  }

  void _onRequestExpired(
    AccessRequestExpiredEvent event,
    Emitter<PendingAccessRequestsState> emit,
  ) {
    if (state is PendingAccessRequestsLoaded) {
      final currentRequests = (state as PendingAccessRequestsLoaded).requests;
      final updatedRequests = currentRequests
          .where((req) => req.id != event.requestId)
          .toList();

      if (updatedRequests.isEmpty) {
        _ticker?.cancel();
        emit(PendingAccessRequestsEmpty(autoExpiredClinicName: event.clinicName));
      } else {
        emit(PendingAccessRequestsLoaded(
          updatedRequests,
          autoExpiredClinicName: event.clinicName,
        ));
      }
    }
  }

  Future<void> _onApprove(
    ApproveAccessRequestEvent event,
    Emitter<PendingAccessRequestsState> emit,
  ) async {
    emit(const PendingAccessRequestsLoading());

    final result = await _approveUseCase(event.requestId);

    await result.fold(
      (failure) async {
        emit(PendingAccessRequestsError(failure.message));
      },
      (_) async {
        // Refresh the list after successful approval
        final fetchResult = await _getPendingUseCase();
        fetchResult.fold(
          (failure) => emit(PendingAccessRequestsError(failure.message)),
          (requests) => emit(
            AccessRequestActionSuccess('Access request approved', requests),
          ),
        );
      },
    );
  }

  Future<void> _onDeny(
    DenyAccessRequestEvent event,
    Emitter<PendingAccessRequestsState> emit,
  ) async {
    emit(const PendingAccessRequestsLoading());

    final result = await _denyUseCase(event.requestId);

    await result.fold(
      (failure) async {
        emit(PendingAccessRequestsError(failure.message));
      },
      (_) async {
        // Refresh the list after successful denial
        final fetchResult = await _getPendingUseCase();
        fetchResult.fold(
          (failure) => emit(PendingAccessRequestsError(failure.message)),
          (requests) => emit(
            AccessRequestActionSuccess('Access request denied', requests),
          ),
        );
      },
    );
  }
}
