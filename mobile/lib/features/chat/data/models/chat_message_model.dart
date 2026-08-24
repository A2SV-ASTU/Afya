import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';

/// Data model for [ChatMessageEntity] with JSON serialization support.
class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.chatId,
    required super.sender,
    required super.content,
    super.suggestedExerciseId,
    required super.createdAt,
  });

  /// Deserializes a chat message from the API JSON response.
  ///
  /// Expected shape:
  /// ```json
  /// {
  ///   "id": "uuid",
  ///   "chat_id": "uuid",
  ///   "sender": "user" | "app",
  ///   "content": "Hello, how are you?",
  ///   "suggested_exercise_id": "uuid" | null,
  ///   "created_at": "2026-08-24T12:00:00Z"
  /// }
  /// ```
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      sender: _parseSender(json['sender'] as String),
      content: json['content'] as String,
      suggestedExerciseId: json['suggested_exercise_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'chat_id': chatId,
      'sender': sender == MessageSender.user ? 'user' : 'app',
      'content': content,
      'suggested_exercise_id': suggestedExerciseId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static MessageSender _parseSender(String raw) {
    switch (raw) {
      case 'user':
        return MessageSender.user;
      case 'app':
        return MessageSender.app;
      default:
        return MessageSender.app;
    }
  }
}
