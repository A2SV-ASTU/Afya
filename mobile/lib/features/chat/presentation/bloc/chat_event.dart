/// Base class for all chat-related BLoC events.
///
/// Events are dispatched by the UI layer and handled by [ChatBloc] to
/// trigger state transitions.
sealed class ChatEvent {
  const ChatEvent();
}

/// Triggers the initialisation of the guided chat.
///
/// The BLoC will call [GetOrCreateActiveChatUseCase] to ensure an active
/// thread exists, then fetch its message history with
/// [GetChatMessagesUseCase].
class LoadChatEvent extends ChatEvent {
  const LoadChatEvent();
}

/// Sends a user message to the active chat thread.
///
/// The BLoC performs optimistic message dispatching: the user's message is
/// appended to the displayed list immediately, then the remote response is
/// awaited. On success the response is appended; on failure the optimistic
/// message is removed and a [ChatError] state is emitted.
///
/// [message] — the plain-text content the user wants to send.
/// [chatId]  — the ID of the active chat thread.
class SendMessageEvent extends ChatEvent {
  final String message;
  final String chatId;

  const SendMessageEvent({
    required this.message,
    required this.chatId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendMessageEvent &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          chatId == other.chatId;

  @override
  int get hashCode => message.hashCode ^ chatId.hashCode;
}
