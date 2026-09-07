import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/clinic_grant_entity.dart';
import '../../domain/usecases/get_active_grants_usecase.dart';
import '../../domain/usecases/revoke_clinic_grant_usecase.dart';

// --- Events ---
abstract class ClinicGrantsEvent extends Equatable {
  const ClinicGrantsEvent();
  @override
  List<Object?> get props => [];
}

class FetchActiveGrantsEvent extends ClinicGrantsEvent {}

class RevokeClinicGrantEvent extends ClinicGrantsEvent {
  final String clinicId;
  const RevokeClinicGrantEvent(this.clinicId);
  @override
  List<Object?> get props => [clinicId];
}

class GrantExpiredEvent extends ClinicGrantsEvent {
  final String clinicId;
  const GrantExpiredEvent(this.clinicId);
  @override
  List<Object?> get props => [clinicId];
}

class _TickGrantsEvent extends ClinicGrantsEvent {}

class RecalculateTimersEvent extends ClinicGrantsEvent {}

// --- States ---
abstract class ClinicGrantsState extends Equatable {
  const ClinicGrantsState();
  @override
  List<Object?> get props => [];
}

class ClinicGrantsInitial extends ClinicGrantsState {}

class ClinicGrantsLoading extends ClinicGrantsState {}

class ClinicGrantsLoaded extends ClinicGrantsState {
  final List<ClinicGrantEntity> grants;
  final Map<String, int> remainingSecondsMap; // clinicId -> seconds
  final String? autoExpiredClinicId; // For snackbar trigger

  const ClinicGrantsLoaded({
    required this.grants,
    required this.remainingSecondsMap,
    this.autoExpiredClinicId,
  });

  @override
  List<Object?> get props => [grants, remainingSecondsMap, autoExpiredClinicId];

  ClinicGrantsLoaded copyWith({
    List<ClinicGrantEntity>? grants,
    Map<String, int>? remainingSecondsMap,
    String? autoExpiredClinicId,
    bool clearExpiredId = false,
  }) {
    return ClinicGrantsLoaded(
      grants: grants ?? this.grants,
      remainingSecondsMap: remainingSecondsMap ?? this.remainingSecondsMap,
      autoExpiredClinicId: clearExpiredId ? null : (autoExpiredClinicId ?? this.autoExpiredClinicId),
    );
  }
}

class ClinicGrantsError extends ClinicGrantsState {
  final String message;
  const ClinicGrantsError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
@injectable
class ClinicGrantsBloc extends Bloc<ClinicGrantsEvent, ClinicGrantsState> {
  final GetActiveGrantsUseCase _getActiveGrantsUseCase;
  final RevokeClinicGrantUseCase _revokeClinicGrantUseCase;
  Timer? _ticker;

  ClinicGrantsBloc({
    required GetActiveGrantsUseCase getActiveGrantsUseCase,
    required RevokeClinicGrantUseCase revokeClinicGrantUseCase,
  })  : _getActiveGrantsUseCase = getActiveGrantsUseCase,
        _revokeClinicGrantUseCase = revokeClinicGrantUseCase,
        super(ClinicGrantsInitial()) {
    on<FetchActiveGrantsEvent>(_onFetchActiveGrants);
    on<RevokeClinicGrantEvent>(_onRevokeGrant);
    on<GrantExpiredEvent>(_onGrantExpired);
    on<_TickGrantsEvent>(_onTick);
    on<RecalculateTimersEvent>(_onRecalculate);
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }

  Map<String, int> _calculateRemaining(List<ClinicGrantEntity> grants) {
    final now = DateTime.now();
    final map = <String, int>{};
    for (var g in grants) {
      final expiryTime = g.grantedAt.add(const Duration(minutes: 5));
      final seconds = expiryTime.difference(now).inSeconds;
      map[g.clinicId] = seconds > 0 ? seconds : 0;
    }
    return map;
  }

  Future<void> _onFetchActiveGrants(
    FetchActiveGrantsEvent event,
    Emitter<ClinicGrantsState> emit,
  ) async {
    emit(ClinicGrantsLoading());
    final result = await _getActiveGrantsUseCase();
    result.fold(
      (failure) => emit(ClinicGrantsError(failure.message)),
      (grants) {
        final map = _calculateRemaining(grants);
        emit(ClinicGrantsLoaded(grants: grants, remainingSecondsMap: map));

        _ticker?.cancel();
        if (grants.isNotEmpty) {
          _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
            add(_TickGrantsEvent());
          });
        }
      },
    );
  }

  void _onTick(_TickGrantsEvent event, Emitter<ClinicGrantsState> emit) {
    if (state is ClinicGrantsLoaded) {
      final currentState = state as ClinicGrantsLoaded;
      final newMap = Map<String, int>.from(currentState.remainingSecondsMap);
      bool hasChanges = false;

      for (final clinicId in newMap.keys.toList()) {
        final currentSecs = newMap[clinicId]!;
        if (currentSecs > 0) {
          newMap[clinicId] = currentSecs - 1;
          hasChanges = true;

          if (newMap[clinicId]! <= 0) {
            add(GrantExpiredEvent(clinicId));
          }
        }
      }

      if (hasChanges) {
        emit(currentState.copyWith(remainingSecondsMap: newMap, clearExpiredId: true));
      }
    }
  }

  void _onRecalculate(RecalculateTimersEvent event, Emitter<ClinicGrantsState> emit) {
    if (state is ClinicGrantsLoaded) {
      final currentState = state as ClinicGrantsLoaded;
      final newMap = _calculateRemaining(currentState.grants);

      for (final clinicId in newMap.keys) {
        if (newMap[clinicId]! <= 0) {
          add(GrantExpiredEvent(clinicId));
        }
      }

      emit(currentState.copyWith(remainingSecondsMap: newMap, clearExpiredId: true));
    }
  }

  Future<void> _onRevokeGrant(
    RevokeClinicGrantEvent event,
    Emitter<ClinicGrantsState> emit,
  ) async {
    // Keep current state but maybe show loading indicator internally,
    // or just trigger re-fetch on success.
    final result = await _revokeClinicGrantUseCase(event.clinicId);
    await result.fold(
      (failure) async {
        emit(ClinicGrantsError(failure.message));
      },
      (_) async {
        add(FetchActiveGrantsEvent());
      },
    );
  }

  Future<void> _onGrantExpired(
    GrantExpiredEvent event,
    Emitter<ClinicGrantsState> emit,
  ) async {
    if (state is ClinicGrantsLoaded) {
      final currentState = state as ClinicGrantsLoaded;
      // Mark as auto-expired for snackbar
      emit(currentState.copyWith(autoExpiredClinicId: event.clinicId));

      // Fire revoke
      add(RevokeClinicGrantEvent(event.clinicId));
    }
  }
}
