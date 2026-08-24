import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:mobile/features/chat/data/models/chat_message_model.dart';
import 'package:mobile/features/chat/data/models/chat_thread_model.dart';
import 'package:mobile/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';
import 'package:mobile/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRemoteDataSource extends Mock
    implements ChatRemoteDataSource {}

void main() {
  late MockChatRemoteDataSource mockRemoteDataSource;
  late ChatRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockChatRemoteDataSource();
    repository =
        ChatRepositoryImpl(mockRemoteDataSource);
  });

  // ── Fixture data ──────────────────────────────────────────────────────

  final DateTime now = DateTime.utc(2026, 8, 24, 12, 0, 0);

  final ChatThreadModel tThread = ChatThreadModel(
    id: 'thread-1',
    userId: 'user-1',
    status: ChatStatus.active,
    createdAt: now,
    updatedAt: now,
  );

  final ChatMessageModel tMessage = ChatMessageModel(
    id: 'msg-1',
    chatId: 'thread-1',
    sender: MessageSender.app,
    content: 'Try deep breathing.',
    suggestedExerciseId: 'ex-1',
    createdAt: now,
  );

  // ── createChat ────────────────────────────────────────────────────────

  group('createChat', () {
    test('should return Right(ChatThreadEntity) on success', () async {
      when(() => mockRemoteDataSource.createChat())
          .thenAnswer((_) async => tThread);

      final result = await repository.createChat();

      expect(result, isA<Right<Failure, ChatThreadEntity>>());
      result.fold(
        (_) => fail('Expected Right'),
        (thread) {
          expect(thread.id, 'thread-1');
          expect(thread.status, ChatStatus.active);
        },
      );
      verify(() => mockRemoteDataSource.createChat()).called(1);
    });

    test('should return Left(ServerFailure) on ServerException', () async {
      when(() => mockRemoteDataSource.createChat()).thenThrow(
        const ServerException(
          message: 'Server error',
          code: 'ERR_500',
          statusCode: 500,
        ),
      );

      final result = await repository.createChat();

      expect(result, isA<Left<Failure, ChatThreadEntity>>());
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Server error');
          expect((failure as ServerFailure).statusCode, 500);
        },
        (_) => fail('Expected Left'),
      );
    });

    test('should return Left(NetworkFailure) on NetworkException',
        () async {
      when(() => mockRemoteDataSource.createChat())
          .thenThrow(const NetworkException());

      final result = await repository.createChat();

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test(
        'should return Left(UnauthorizedFailure) on UnauthorizedException',
        () async {
      when(() => mockRemoteDataSource.createChat())
          .thenThrow(const UnauthorizedException());

      final result = await repository.createChat();

      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  // ── getChats ──────────────────────────────────────────────────────────

  group('getChats', () {
    test('should return Right(List<ChatThreadEntity>) on success',
        () async {
      when(() => mockRemoteDataSource.getChats())
          .thenAnswer((_) async => <ChatThreadModel>[tThread]);

      final result = await repository.getChats();

      expect(result, isA<Right<Failure, List<ChatThreadEntity>>>());
      result.fold(
        (_) => fail('Expected Right'),
        (threads) {
          expect(threads.length, 1);
          expect(threads.first.id, 'thread-1');
        },
      );
    });

    test('should return Left(ServerFailure) on ServerException', () async {
      when(() => mockRemoteDataSource.getChats()).thenThrow(
        const ServerException(message: 'Fetch failed'),
      );

      final result = await repository.getChats();

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('should return Left(NetworkFailure) on NetworkException',
        () async {
      when(() => mockRemoteDataSource.getChats())
          .thenThrow(const NetworkException());

      final result = await repository.getChats();

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test(
        'should return Left(UnauthorizedFailure) on UnauthorizedException',
        () async {
      when(() => mockRemoteDataSource.getChats())
          .thenThrow(const UnauthorizedException());

      final result = await repository.getChats();

      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  // ── getChatMessages ───────────────────────────────────────────────────

  group('getChatMessages', () {
    const String chatId = 'thread-1';

    test('should return Right(List<ChatMessageEntity>) on success',
        () async {
      when(() => mockRemoteDataSource.getChatMessages(chatId))
          .thenAnswer((_) async => <ChatMessageModel>[tMessage]);

      final result = await repository.getChatMessages(chatId);

      expect(result, isA<Right<Failure, List<ChatMessageEntity>>>());
      result.fold(
        (_) => fail('Expected Right'),
        (messages) {
          expect(messages.length, 1);
          expect(messages.first.suggestedExerciseId, 'ex-1');
        },
      );
      verify(() => mockRemoteDataSource.getChatMessages(chatId)).called(1);
    });

    test('should return Left(ServerFailure) on ServerException', () async {
      when(() => mockRemoteDataSource.getChatMessages(chatId)).thenThrow(
        const ServerException(message: 'Not found', statusCode: 404),
      );

      final result = await repository.getChatMessages(chatId);

      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).statusCode, 404);
        },
        (_) => fail('Expected Left'),
      );
    });

    test('should return Left(NetworkFailure) on NetworkException',
        () async {
      when(() => mockRemoteDataSource.getChatMessages(chatId))
          .thenThrow(const NetworkException());

      final result = await repository.getChatMessages(chatId);

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test(
        'should return Left(UnauthorizedFailure) on UnauthorizedException',
        () async {
      when(() => mockRemoteDataSource.getChatMessages(chatId))
          .thenThrow(const UnauthorizedException());

      final result = await repository.getChatMessages(chatId);

      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  // ── sendMessage ───────────────────────────────────────────────────────

  group('sendMessage', () {
    const String chatId = 'thread-1';
    const String message = 'I feel stressed';

    test(
        'should return Right(ChatMessageEntity) with suggestedExerciseId on success',
        () async {
      when(() => mockRemoteDataSource.sendMessage(
            chatId: chatId,
            message: message,
          )).thenAnswer((_) async => tMessage);

      final result = await repository.sendMessage(
        chatId: chatId,
        message: message,
      );

      expect(result, isA<Right<Failure, ChatMessageEntity>>());
      result.fold(
        (_) => fail('Expected Right'),
        (msg) {
          expect(msg.sender, MessageSender.app);
          expect(msg.suggestedExerciseId, 'ex-1');
          expect(msg.content, 'Try deep breathing.');
        },
      );
      verify(() => mockRemoteDataSource.sendMessage(
            chatId: chatId,
            message: message,
          )).called(1);
    });

    test('should return Left(ServerFailure) on ServerException', () async {
      when(() => mockRemoteDataSource.sendMessage(
            chatId: chatId,
            message: message,
          )).thenThrow(
        const ServerException(
          message: 'Rate limited',
          code: 'RATE_LIMIT',
          statusCode: 429,
        ),
      );

      final result = await repository.sendMessage(
        chatId: chatId,
        message: message,
      );

      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.code, 'RATE_LIMIT');
        },
        (_) => fail('Expected Left'),
      );
    });

    test('should return Left(NetworkFailure) on NetworkException',
        () async {
      when(() => mockRemoteDataSource.sendMessage(
            chatId: chatId,
            message: message,
          )).thenThrow(const NetworkException());

      final result = await repository.sendMessage(
        chatId: chatId,
        message: message,
      );

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test(
        'should return Left(UnauthorizedFailure) on UnauthorizedException',
        () async {
      when(() => mockRemoteDataSource.sendMessage(
            chatId: chatId,
            message: message,
          )).thenThrow(const UnauthorizedException());

      final result = await repository.sendMessage(
        chatId: chatId,
        message: message,
      );

      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
