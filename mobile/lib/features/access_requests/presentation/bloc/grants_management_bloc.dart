import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/clinic_grant_entity.dart';
import '../../domain/usecases/get_active_grants_usecase.dart';
import '../../domain/usecases/revoke_clinic_grant_usecase.dart';

// --- Events ---
abstract class GrantsManagementEvent extends Equatable {
  const GrantsManagementEvent();

  @override
  List<Object?> get props => [];
}

class FetchActiveGrantsEvent extends GrantsManagementEvent {}

class RevokeGrantEvent extends GrantsManagementEvent {
  final String clinicId;

  const RevokeGrantEvent(this.clinicId);

  @override
  List<Object?> get props => [clinicId];
}

// --- States ---
abstract class GrantsManagementState extends Equatable {
  const GrantsManagementState();

  @override
  List<Object?> get props => [];
}

class GrantsManagementInitial extends GrantsManagementState {
  const GrantsManagementInitial();
}

class GrantsManagementLoading extends GrantsManagementState {
  const GrantsManagementLoading();
}

class GrantsManagementLoaded extends GrantsManagementState {
  final List<ClinicGrantEntity> grants;

  const GrantsManagementLoaded(this.grants);

  @override
  List<Object?> get props => [grants];
}

class GrantsManagementError extends GrantsManagementState {
  final String message;

  const GrantsManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
@injectable
class GrantsManagementBloc extends Bloc<GrantsManagementEvent, GrantsManagementState> {
  final GetActiveGrantsUseCase _getActiveGrantsUseCase;
  final RevokeClinicGrantUseCase _revokeClinicGrantUseCase;

  GrantsManagementBloc({
    required GetActiveGrantsUseCase getActiveGrantsUseCase,
    required RevokeClinicGrantUseCase revokeClinicGrantUseCase,
  })  : _getActiveGrantsUseCase = getActiveGrantsUseCase,
        _revokeClinicGrantUseCase = revokeClinicGrantUseCase,
        super(const GrantsManagementInitial()) {
    on<FetchActiveGrantsEvent>(_onFetchActiveGrants);
    on<RevokeGrantEvent>(_onRevokeGrant);
  }

  Future<void> _onFetchActiveGrants(
    FetchActiveGrantsEvent event,
    Emitter<GrantsManagementState> emit,
  ) async {
    emit(const GrantsManagementLoading());

    // Assuming getActiveGrantsUseCase takes NoParams() if it uses fpdart Either
    // If it doesn't take params, we'll try an empty call.
    // Based on standard clean architecture, it usually takes NoParams() or nothing.
    final result = await _getActiveGrantsUseCase();

    result.fold(
      (failure) => emit(GrantsManagementError(failure.message)),
      (grants) => emit(GrantsManagementLoaded(grants)),
    );
  }

  Future<void> _onRevokeGrant(
    RevokeGrantEvent event,
    Emitter<GrantsManagementState> emit,
  ) async {
    emit(const GrantsManagementLoading());

    final result = await _revokeClinicGrantUseCase(event.clinicId);

    await result.fold(
      (failure) async {
        emit(GrantsManagementError(failure.message));
      },
      (_) async {
        // Automatically refresh grants list after successful revocation
        final fetchResult = await _getActiveGrantsUseCase();
        fetchResult.fold(
          (failure) => emit(GrantsManagementError(failure.message)),
          (grants) => emit(GrantsManagementLoaded(grants)),
        );
      },
    );
  }
}
