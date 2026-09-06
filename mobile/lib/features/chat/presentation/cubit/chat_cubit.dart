import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

@injectable
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repository;

  ChatCubit({required this.repository}) : super(const ChatInitial());

  Future<void> loadHistory() async {
    final messages = await repository.getChatHistory();
    emit(ChatLoaded(messages: messages));
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final currentState = state;
    List<ChatMessage> currentMessages = [];
    if (currentState is ChatLoaded) {
      currentMessages = List.from(currentState.messages);
    }

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...currentMessages, userMessage];
    emit(ChatLoaded(messages: updatedMessages, isTyping: true));

    try {
      final aiResponse = await repository.sendMessage(trimmed, currentMessages);
      final finalMessages = [...updatedMessages, aiResponse];
      emit(ChatLoaded(messages: finalMessages, isTyping: false));
    } catch (e) {
      emit(ChatLoaded(
        messages: updatedMessages,
        isTyping: false,
        errorMessage: "Failed to receive AI response.",
      ));
    }
  }

  Future<void> clearHistory() async {
    await repository.clearHistory();
    emit(const ChatLoaded(messages: []));
  }
}
