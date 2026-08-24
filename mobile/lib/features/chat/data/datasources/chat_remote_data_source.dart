import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/features/chat/data/models/chat_message_model.dart';
import 'package:mobile/features/chat/data/models/chat_thread_model.dart';

/// Remote data source for chat operations.
///
/// Communicates with the AfyaMind API using the authenticated [ApiClient].
///
/// Endpoints:
/// - `POST   /chats`                → create a new chat thread
/// - `GET    /chats`                → list all chat threads
/// - `GET    /chats/:id/messages`   → get messages for a thread
/// - `POST   /chats/:id/messages`   → send a message and receive the response
abstract class ChatRemoteDataSource {
  /// POST /chats — Creates a new chat thread.
  Future<ChatThreadModel> createChat();

  /// GET /chats — Returns all chat threads for the current user.
  Future<List<ChatThreadModel>> getChats();

  /// GET /chats/:id/messages — Returns messages for [chatId].
  Future<List<ChatMessageModel>> getChatMessages(String chatId);

  /// POST /chats/:id/messages — Sends a [message] and returns the app response.
  Future<ChatMessageModel> sendMessage({
    required String chatId,
    required String message,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient _client;

  ChatRemoteDataSourceImpl({required ApiClient client}) : _client = client;

  @override
  Future<ChatThreadModel> createChat() async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.chats,
    );

    final Map<String, dynamic>? data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Empty response when creating chat.',
      );
    }

    // The response may nest the thread under a "data" key
    final Map<String, dynamic> threadJson =
        (data['data'] as Map<String, dynamic>?) ?? data;

    return ChatThreadModel.fromJson(threadJson);
  }

  @override
  Future<List<ChatThreadModel>> getChats() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.chats,
    );

    final Map<String, dynamic>? data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Empty response when fetching chats.',
      );
    }

    // Expect { "data": [ ...threads ] }
    final List<dynamic> threadsList =
        (data['data'] as List<dynamic>?) ?? <dynamic>[];

    return threadsList
        .map((dynamic json) =>
            ChatThreadModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ChatMessageModel>> getChatMessages(String chatId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '${ApiEndpoints.chats}/$chatId/messages',
    );

    final Map<String, dynamic>? data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Empty response when fetching chat messages.',
      );
    }

    // Expect { "data": [ ...messages ] }
    final List<dynamic> messagesList =
        (data['data'] as List<dynamic>?) ?? <dynamic>[];

    return messagesList
        .map((dynamic json) =>
            ChatMessageModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String chatId,
    required String message,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '${ApiEndpoints.chats}/$chatId/messages',
      data: <String, dynamic>{'content': message},
    );

    final Map<String, dynamic>? data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Empty response when sending message.',
      );
    }

    // The app response message is the reply from the guided chat engine.
    // It may be nested under "data".
    final Map<String, dynamic> messageJson =
        (data['data'] as Map<String, dynamic>?) ?? data;

    return ChatMessageModel.fromJson(messageJson);
  }
}
