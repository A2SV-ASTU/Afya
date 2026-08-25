import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';
import 'package:mobile/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:mobile/features/chat/domain/usecases/get_chat_messages_usecase.dart';
import 'package:mobile/features/chat/domain/usecases/get_or_create_active_chat_usecase.dart';
import 'package:mobile/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:mobile/features/chat/presentation/bloc/chat_event.dart';
import 'package:mobile/features/chat/presentation/bloc/chat_state.dart';

/// Predefined quick-reply options for the guided chat.
///
/// These are displayed as tappable chips in the UI and allow the user to
/// respond without typing.
const List<String> cannedResponses = <String>[
  'I\'m feeling anxious',
  'I\'m feeling sad',
  'I need motivation',
  'I can\'t sleep',
  'I\'m feeling stressed',
];

/// Manages the guided chat session state.
///
/// Uses three domain use cases to:
/// - Initialise / resume an active chat thread ([GetOrCreateActiveChatUseCase])
/// - Load message history ([GetChatMessagesUseCase])
/// - Send messages with optimistic dispatching ([SendMessageUseCase])
///
/// All use-case results are handled via [fpdart] [Either], keeping error
/// handling purely functional and free of exceptions.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetOrCreateActiveChatUseCase _getOrCreateActiveChatUseCase;
  final GetChatMessagesUseCase _getChatMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;

  ChatBloc({
    required this._getOrCreateActiveChatUseCase,
    required this._getChatMessagesUseCase,
    required this._sendMessageUseCase,
  }) : super(const ChatInitial()) {
    on<LoadChatEvent>(_onLoadChat);
    on<SendMessageEvent>(_onSendMessage);
  }

  /// Handles [LoadChatEvent]: fetches or creates the active thread, then
  /// loads its messages.
  Future<void> _onLoadChat(
    LoadChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    final Either<Failure, ChatThreadEntity> threadResult =
        await _getOrCreateActiveChatUseCase(const NoParams());

    await threadResult.fold(
      (Failure failure) async {
        emit(ChatError(message: failure.message));
      },
      (ChatThreadEntity thread) async {
        final Either<Failure, List<ChatMessageEntity>> messagesResult =
            await _getChatMessagesUseCase(thread.id);

        messagesResult.fold(
          (Failure failure) {
            emit(ChatError(message: failure.message));
          },
          (List<ChatMessageEntity> messages) {
            emit(ChatLoaded(thread: thread, messages: messages));
          },
        );
      },
    );
  }

  /// Handles [SendMessageEvent]: performs optimistic message dispatching.
  ///
  /// 1. A synthetic user message is appended to the displayed list.
  /// 2. [MessageSending] is emitted so the UI can show a pending indicator.
  /// 3. [SendMessageUseCase] is called.
  /// 4. On success the server response replaces the optimistic entry.
  /// 5. On failure the optimistic entry is removed and [ChatError] is emitted.
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final ChatState currentState = state;
    if (currentState is! ChatLoaded && currentState is! MessageSending) {
      return;
    }

    final ChatThreadEntity thread =
        currentState is MessageSending
            ? currentState.thread
            : (currentState as ChatLoaded).thread;
    final List<ChatMessageEntity> currentMessages =
        currentState is MessageSending
            ? currentState.messages
            : (currentState as ChatLoaded).messages;

    // 1. Build an optimistic user message.
    final String optimisticId =
        'pending-${DateTime.now().microsecondsSinceEpoch}';
    final ChatMessageEntity optimisticMessage = ChatMessageEntity(
      id: optimisticId,
      chatId: event.chatId,
      sender: MessageSender.user,
      content: event.message,
      createdAt: DateTime.now(),
    );

    final List<ChatMessageEntity> updatedMessages =
        List<ChatMessageEntity>.of(currentMessages)
          ..add(optimisticMessage);

    // 2. Emit the sending state.
    emit(MessageSending(thread: thread, messages: updatedMessages));

    // 3. Call the use case.
    final Either<Failure, ChatMessageEntity> result =
        await _sendMessageUseCase(
      SendMessageParams(chatId: event.chatId, message: event.message),
    );

    // 4. Handle the result.
    await result.fold(
      (Failure failure) async {
        // Revert the optimistic message on failure.
        final List<ChatMessageEntity> revertedMessages =
            List<ChatMessageEntity>.of(updatedMessages)..removeLast();
        emit(ChatLoaded(thread: thread, messages: revertedMessages));
        emit(ChatError(message: failure.message));
      },
      (ChatMessageEntity appResponse) async {
        final List<ChatMessageEntity> finalMessages =
            List<ChatMessageEntity>.of(updatedMessages)
              ..add(appResponse);
        emit(ChatLoaded(thread: thread, messages: finalMessages));
      },
    );
  }
}
