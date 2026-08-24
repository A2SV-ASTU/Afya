import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';
import 'package:mobile/features/chat/domain/repositories/chat_repository.dart';

/// Retrieves all messages for a given chat thread.
class GetChatMessagesUseCase
    extends UseCase<List<ChatMessageEntity>, String> {
  final ChatRepository _repository;

  GetChatMessagesUseCase({required ChatRepository repository})
      : _repository = repository;

  /// [params] is the chat thread ID.
  @override
  Future<Either<Failure, List<ChatMessageEntity>>> call(String params) {
    return _repository.getChatMessages(params);
  }
}
