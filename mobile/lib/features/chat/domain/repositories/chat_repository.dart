import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getChatHistory();
  Future<ChatMessage> sendMessage(String text, List<ChatMessage> history);
  Future<void> clearHistory();
}
