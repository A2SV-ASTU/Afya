import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';
import 'package:mobile/features/chat/domain/entities/chat_thread_entity.dart';

/// Base class for all chat-related BLoC states.
///
/// Each state captures a snapshot of the chat UI at a point in time.
sealed class ChatState {
  const ChatState();
}

/// Initial state before any chat data has been requested.
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// The chat thread or message history is being fetched from the repository.
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// The active chat thread and its messages have been loaded successfully.
///
/// [thread]   — the active [ChatThreadEntity].
/// [messages] — ordered list of messages to display (oldest first).
class ChatLoaded extends ChatState {
  final ChatThreadEntity thread;
  final List<ChatMessageEntity> messages;

  const ChatLoaded({
    required this.thread,
    required this.messages,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatLoaded &&
          runtimeType == other.runtimeType &&
          thread == other.thread &&
          _listEquals(messages, other.messages);

  @override
  int get hashCode => thread.hashCode ^ Object.hashAll(messages);

  static bool _listEquals(
    List<ChatMessageEntity> a,
    List<ChatMessageEntity> b,
  ) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// A user message has been optimistically added and the remote response is
/// being awaited.
///
/// Carries the current [thread] and the full [messages] list (including the
/// optimistic entry) so the UI can keep rendering without flicker.
class MessageSending extends ChatState {
  final ChatThreadEntity thread;
  final List<ChatMessageEntity> messages;

  const MessageSending({
    required this.thread,
    required this.messages,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageSending &&
          runtimeType == other.runtimeType &&
          thread == other.thread &&
          _listEquals(messages, other.messages);

  @override
  int get hashCode => thread.hashCode ^ Object.hashAll(messages);

  static bool _listEquals(
    List<ChatMessageEntity> a,
    List<ChatMessageEntity> b,
  ) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// An error occurred during any chat operation.
///
/// [message] — human-readable description of the failure.
class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
