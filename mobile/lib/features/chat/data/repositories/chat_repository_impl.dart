import 'package:injectable/injectable.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/gemini_remote_data_source.dart';
import '../models/chat_message_model.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDataSource localDataSource;
  final GeminiRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<ChatMessage>> getChatHistory() async {
    final models = await localDataSource.getChatHistory();
    return models;
  }

  @override
  Future<ChatMessage> sendMessage(String text, List<ChatMessage> history) async {
    // 1. Save user message locally
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    await localDataSource.saveMessage(ChatMessageModel.fromEntity(userMessage));

    // 2. Prepare context for Gemini
    final historyPayload = history
        .map((m) => {
              'role': m.isUser ? 'user' : 'model',
              'text': m.content,
            })
        .toList();

    // 3. Generate response
    try {
      final responseText = await remoteDataSource.generateHealthResponse(text, historyPayload);
      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      await localDataSource.saveMessage(ChatMessageModel.fromEntity(aiMessage));
      return aiMessage;
    } catch (e) {
      final errorMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: "Sorry, I am having trouble processing your query right now. Please check your internet connection or API settings.",
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );
      await localDataSource.saveMessage(ChatMessageModel.fromEntity(errorMessage));
      return errorMessage;
    }
  }

  @override
  Future<void> clearHistory() async {
    await localDataSource.clearHistory();
  }
}
