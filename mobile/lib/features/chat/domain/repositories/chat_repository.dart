import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';
import 'package:mobile/features/chat/domain/entities/chat_thread_entity.dart';

/// Contract for the chat repository.
///
/// All operations return [Either] to separate the success path from
/// domain-level [Failure]s without throwing exceptions.
abstract class ChatRepository {
  /// Creates a new chat thread.
  ///
  /// The backend automatically closes the previously active thread (if any)
  /// when a new one is created.
  Future<Either<Failure, ChatThreadEntity>> createChat();

  /// Returns all chat threads for the current user, ordered by most recent.
  Future<Either<Failure, List<ChatThreadEntity>>> getChats();

  /// Returns the paginated message history for the given [chatId].
  Future<Either<Failure, List<ChatMessageEntity>>> getChatMessages(
    String chatId,
  );

  /// Sends a user [message] in the given chat thread and returns the
  /// complete app response message (which may contain a
  /// [ChatMessageEntity.suggestedExerciseId]).
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String chatId,
    required String message,
  });
}
