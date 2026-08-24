import 'package:mobile/features/chat/domain/entities/chat_thread_entity.dart';

/// Data model for [ChatThreadEntity] with JSON serialization support.
class ChatThreadModel extends ChatThreadEntity {
  const ChatThreadModel({
    required super.id,
    required super.userId,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Deserializes a chat thread from the API JSON response.
  ///
  /// Expected shape:
  /// ```json
  /// {
  ///   "id": "uuid",
  ///   "user_id": "uuid",
  ///   "status": "active" | "closed",
  ///   "created_at": "2026-08-24T12:00:00Z",
  ///   "updated_at": "2026-08-24T12:00:00Z"
  /// }
  /// ```
  factory ChatThreadModel.fromJson(Map<String, dynamic> json) {
    return ChatThreadModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'status': status == ChatStatus.active ? 'active' : 'closed',
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static ChatStatus _parseStatus(String raw) {
    switch (raw) {
      case 'active':
        return ChatStatus.active;
      case 'closed':
        return ChatStatus.closed;
      default:
        return ChatStatus.closed;
    }
  }
}
