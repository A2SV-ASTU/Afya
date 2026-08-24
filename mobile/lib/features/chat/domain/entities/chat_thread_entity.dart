/// Represents the lifecycle status of a chat thread.
enum ChatStatus { active, closed }

/// Domain entity representing a chat thread (conversation).
///
/// Each user has at most one [ChatStatus.active] thread at a time.
/// When a new thread is created, the previous active thread is closed by the
/// backend automatically.
class ChatThreadEntity {
  final String id;
  final String userId;
  final ChatStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatThreadEntity({
    required this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatThreadEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ChatThreadEntity(id: $id, status: $status)';
}
