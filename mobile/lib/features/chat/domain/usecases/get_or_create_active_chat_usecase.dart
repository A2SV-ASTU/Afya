import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:mobile/features/chat/domain/repositories/chat_repository.dart';

/// Retrieves all existing chat threads. If no active thread exists, creates one
/// and returns the updated list.
///
/// This ensures the user always has an active chat thread to interact with.
class GetOrCreateActiveChatUseCase
    extends UseCase<ChatThreadEntity, NoParams> {
  final ChatRepository _repository;

  GetOrCreateActiveChatUseCase({required ChatRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, ChatThreadEntity>> call(NoParams params) async {
    // 1. Fetch existing threads
    final Either<Failure, List<ChatThreadEntity>> chatsResult =
        await _repository.getChats();

    return chatsResult.fold(
      (Failure failure) => Left(failure),
      (List<ChatThreadEntity> threads) async {
        // 2. Look for an active thread
        final ChatThreadEntity? active = threads
            .where(
                (ChatThreadEntity t) => t.status == ChatStatus.active)
            .fold<ChatThreadEntity?>(
              null,
              (ChatThreadEntity? prev, ChatThreadEntity curr) => prev ?? curr,
            );

        if (active != null) {
          return Right(active);
        }

        // 3. No active thread → create one
        return _repository.createChat();
      },
    );
  }
}
