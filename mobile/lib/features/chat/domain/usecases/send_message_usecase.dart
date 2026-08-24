import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';
import 'package:mobile/features/chat/domain/repositories/chat_repository.dart';

/// Parameters required to send a chat message.
class SendMessageParams {
  final String chatId;
  final String message;

  const SendMessageParams({
    required this.chatId,
    required this.message,
  });
}

/// Sends a message to the guided chat and returns the app's response.
///
/// The returned [ChatMessageEntity] will always have
/// [ChatMessageEntity.sender] == [MessageSender.app] and may include a
/// [ChatMessageEntity.suggestedExerciseId].
class SendMessageUseCase
    extends UseCase<ChatMessageEntity, SendMessageParams> {
  final ChatRepository _repository;

  SendMessageUseCase({required ChatRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, ChatMessageEntity>> call(
    SendMessageParams params,
  ) {
    return _repository.sendMessage(
      chatId: params.chatId,
      message: params.message,
    );
  }
}
