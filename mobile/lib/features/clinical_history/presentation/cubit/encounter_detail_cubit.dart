import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_encounter_detail_usecase.dart';
import 'encounter_detail_state.dart';

@injectable
class EncounterDetailCubit extends Cubit<EncounterDetailState> {
  final GetEncounterDetailUseCase getEncounterDetailUseCase;

  EncounterDetailCubit({
    required this.getEncounterDetailUseCase,
  }) : super(const EncounterDetailInitialState());

  Future<void> fetchEncounterDetail(String encounterId) async {
    emit(const EncounterDetailLoadingState());

    final result = await getEncounterDetailUseCase(encounterId: encounterId);

    result.fold(
      (failure) => emit(
        EncounterDetailErrorState(
          message: failure.message,
          code: failure.code,
        ),
      ),
      (detail) => emit(
        EncounterDetailLoadedState(detail: detail),
      ),
    );
  }
}
