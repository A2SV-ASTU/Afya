import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:mobile/features/chat/data/models/chat_message_model.dart';
import 'package:mobile/features/chat/data/models/chat_thread_model.dart';
import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';
import 'package:mobile/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockClient;
  late ChatRemoteDataSourceImpl dataSource;

  setUp(() {
    mockClient = MockApiClient();
    dataSource = ChatRemoteDataSourceImpl(mockClient);
  });

  // ── Fixture data ──────────────────────────────────────────────────────

  final Map<String, dynamic> threadJson = <String, dynamic>{
    'id': 'thread-1',
    'user_id': 'user-1',
    'status': 'active',
    'created_at': '2026-08-24T12:00:00.000Z',
    'updated_at': '2026-08-24T12:00:00.000Z',
  };

  final Map<String, dynamic> messageJson = <String, dynamic>{
    'id': 'msg-1',
    'chat_id': 'thread-1',
    'sender': 'app',
    'content': 'How are you feeling today?',
    'suggested_exercise_id': 'ex-1',
    'created_at': '2026-08-24T12:00:00.000Z',
  };

  Response<T> fakeResponse<T>(T data) {
    return Response<T>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );
  }

  // ── createChat ────────────────────────────────────────────────────────

  group('createChat', () {
    test('should POST to /chats and return a ChatThreadModel', () async {
      when(() => mockClient.post<Map<String, dynamic>>(ApiEndpoints.chats))
          .thenAnswer(
        (_) async => fakeResponse<Map<String, dynamic>>(
          <String, dynamic>{'data': threadJson},
        ),
      );

      final result = await dataSource.createChat();

      expect(result, isA<ChatThreadModel>());
      expect(result.id, 'thread-1');
      expect(result.status, ChatStatus.active);
      verify(() => mockClient.post<Map<String, dynamic>>(ApiEndpoints.chats))
          .called(1);
    });

    test('should handle response without nested data key', () async {
      when(() => mockClient.post<Map<String, dynamic>>(ApiEndpoints.chats))
          .thenAnswer(
        (_) async => fakeResponse<Map<String, dynamic>>(threadJson),
      );

      final result = await dataSource.createChat();

      expect(result.id, 'thread-1');
    });

    test('should throw ServerException when response data is null',
        () async {
      when(() => mockClient.post<Map<String, dynamic>>(ApiEndpoints.chats))
          .thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => dataSource.createChat(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ── getChats ──────────────────────────────────────────────────────────

  group('getChats', () {
    test('should GET /chats and return a list of ChatThreadModels',
        () async {
      when(() => mockClient.get<Map<String, dynamic>>(ApiEndpoints.chats))
          .thenAnswer(
        (_) async => fakeResponse<Map<String, dynamic>>(
          <String, dynamic>{
            'data': <dynamic>[threadJson]
          },
        ),
      );

      final result = await dataSource.getChats();

      expect(result, isA<List<ChatThreadModel>>());
      expect(result.length, 1);
      expect(result.first.id, 'thread-1');
      verify(() => mockClient.get<Map<String, dynamic>>(ApiEndpoints.chats))
          .called(1);
    });

    test('should return empty list when data array is empty', () async {
      when(() => mockClient.get<Map<String, dynamic>>(ApiEndpoints.chats))
          .thenAnswer(
        (_) async => fakeResponse<Map<String, dynamic>>(
          <String, dynamic>{'data': <dynamic>[]},
        ),
      );

      final result = await dataSource.getChats();

      expect(result, isEmpty);
    });

    test('should return empty list when data key is missing', () async {
      when(() => mockClient.get<Map<String, dynamic>>(ApiEndpoints.chats))
          .thenAnswer(
        (_) async => fakeResponse<Map<String, dynamic>>(
          <String, dynamic>{'other': 'value'},
        ),
      );

      final result = await dataSource.getChats();

      expect(result, isEmpty);
    });
  });

  // ── getChatMessages ───────────────────────────────────────────────────

  group('getChatMessages', () {
    const String chatId = 'thread-1';
    const String path = '${ApiEndpoints.chats}/$chatId/messages';

    test('should GET /chats/:id/messages and return messages', () async {
      when(() => mockClient.get<Map<String, dynamic>>(path)).thenAnswer(
        (_) async => fakeResponse<Map<String, dynamic>>(
          <String, dynamic>{
            'data': <dynamic>[messageJson]
          },
        ),
      );

      final result = await dataSource.getChatMessages(chatId);

      expect(result, isA<List<ChatMessageModel>>());
      expect(result.length, 1);
      expect(result.first.id, 'msg-1');
      expect(result.first.sender, MessageSender.app);
      expect(result.first.suggestedExerciseId, 'ex-1');
      verify(() => mockClient.get<Map<String, dynamic>>(path)).called(1);
    });

    test('should return empty list when no messages exist', () async {
      when(() => mockClient.get<Map<String, dynamic>>(path)).thenAnswer(
        (_) async => fakeResponse<Map<String, dynamic>>(
          <String, dynamic>{'data': <dynamic>[]},
        ),
      );

      final result = await dataSource.getChatMessages(chatId);

      expect(result, isEmpty);
    });
  });

  // ── sendMessage ───────────────────────────────────────────────────────

  group('sendMessage', () {
    const String chatId = 'thread-1';
    const String userMessage = 'I feel anxious today';
    const String path = '${ApiEndpoints.chats}/$chatId/messages';

    test(
        'should POST message and return the app response with suggestedExerciseId',
        () async {
      when(() => mockClient.post<Map<String, dynamic>>(
            path,
            data: <String, dynamic>{'content': userMessage},
          )).thenAnswer(
        (_) async => fakeResponse<Map<String, dynamic>>(
          <String, dynamic>{'data': messageJson},
        ),
      );

      final result = await dataSource.sendMessage(
        chatId: chatId,
        message: userMessage,
      );

      expect(result, isA<ChatMessageModel>());
      expect(result.sender, MessageSender.app);
      expect(result.suggestedExerciseId, 'ex-1');
      expect(result.content, 'How are you feeling today?');
      verify(() => mockClient.post<Map<String, dynamic>>(
            path,
            data: <String, dynamic>{'content': userMessage},
          )).called(1);
    });

    test('should handle response without nested data key', () async {
      when(() => mockClient.post<Map<String, dynamic>>(
            path,
            data: <String, dynamic>{'content': userMessage},
          )).thenAnswer(
        (_) async => fakeResponse<Map<String, dynamic>>(messageJson),
      );

      final result = await dataSource.sendMessage(
        chatId: chatId,
        message: userMessage,
      );

      expect(result.id, 'msg-1');
    });

    test(
        'should correctly deserialize app response without suggestedExerciseId',
        () async {
      final Map<String, dynamic> noExerciseJson =
          Map<String, dynamic>.from(messageJson)
            ..['suggested_exercise_id'] = null;

      when(() => mockClient.post<Map<String, dynamic>>(
            path,
            data: <String, dynamic>{'content': userMessage},
          )).thenAnswer(
        (_) async => fakeResponse<Map<String, dynamic>>(
          <String, dynamic>{'data': noExerciseJson},
        ),
      );

      final result = await dataSource.sendMessage(
        chatId: chatId,
        message: userMessage,
      );

      expect(result.suggestedExerciseId, isNull);
    });
  });
}
