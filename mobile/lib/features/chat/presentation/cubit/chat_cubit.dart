import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

@injectable
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repository;
  String? _lastMessage;

  ChatCubit({required this.repository}) : super(const ChatInitial());

  Future<void> loadHistory() async {
    try {
      final messages = await repository.getChatHistory();
      emit(ChatLoaded(messages: messages));
    } catch (_) {
      emit(const ChatLoaded(messages: []));
    }
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _lastMessage = trimmed;

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
        errorMessage: _errorMessage(e),
      ));
    }
  }

  Future<void> retryLastMessage() async {
    final message = _lastMessage;
    if (message == null ||
        state is ChatLoaded && (state as ChatLoaded).isTyping) {
      return;
    }
    if (state is ChatLoaded) {
      final current = (state as ChatLoaded).messages;
      if (current.isNotEmpty &&
          current.last.isUser &&
          current.last.content == message) {
        emit(ChatLoaded(messages: current.sublist(0, current.length - 1)));
      }
    }
    await sendMessage(message);
  }

  Future<void> clearHistory() async {
    try {
      await repository.clearHistory();
      _lastMessage = null;
      emit(const ChatLoaded(messages: []));
    } catch (e) {
      final current = state;
      emit(ChatLoaded(
        messages: current is ChatLoaded ? current.messages : const [],
        errorMessage: _errorMessage(e),
      ));
    }
  }

  String _errorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty
        ? 'Unable to reach Afya AI. Please try again.'
        : message;
  }
}
