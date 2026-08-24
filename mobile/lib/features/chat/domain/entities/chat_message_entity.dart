/// The sender of a chat message.
enum MessageSender { user, app }

/// Domain entity representing a single message within a chat thread.
///
/// When the [sender] is [MessageSender.app], the response may include a
/// [suggestedExerciseId] that links to a recommended exercise the user can
/// complete.
class ChatMessageEntity {
  final String id;
  final String chatId;
  final MessageSender sender;
  final String content;
  final String? suggestedExerciseId;
  final DateTime createdAt;

  const ChatMessageEntity({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    this.suggestedExerciseId,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ChatMessageEntity(id: $id, sender: $sender, content: ${content.length > 40 ? '${content.substring(0, 40)}...' : content})';
}
