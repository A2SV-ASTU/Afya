import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';
import 'package:mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:mobile/features/chat/domain/usecases/get_chat_messages_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockRepository;
  late GetChatMessagesUseCase useCase;

  setUp(() {
    mockRepository = MockChatRepository();
    useCase = GetChatMessagesUseCase(mockRepository);
  });

  final DateTime now = DateTime.utc(2026, 8, 24, 12, 0, 0);

  final List<ChatMessageEntity> tMessages = <ChatMessageEntity>[
    ChatMessageEntity(
      id: 'msg-1',
      chatId: 'chat-1',
      sender: MessageSender.user,
      content: 'Hello',
      createdAt: now,
    ),
    ChatMessageEntity(
      id: 'msg-2',
      chatId: 'chat-1',
      sender: MessageSender.app,
      content: 'Hi! How are you?',
      suggestedExerciseId: 'ex-1',
      createdAt: now,
    ),
  ];

  group('GetChatMessagesUseCase', () {
    const String chatId = 'chat-1';

    test('should return Right(List<ChatMessageEntity>) on success',
        () async {
      when(() => mockRepository.getChatMessages(chatId))
          .thenAnswer((_) async => Right(tMessages));

      final result = await useCase(chatId);

      result.fold(
        (_) => fail('Expected Right'),
        (messages) {
          expect(messages.length, 2);
          expect(messages[0].sender, MessageSender.user);
          expect(messages[1].sender, MessageSender.app);
          expect(messages[1].suggestedExerciseId, 'ex-1');
        },
      );
      verify(() => mockRepository.getChatMessages(chatId)).called(1);
    });

    test('should return Right(empty list) when no messages exist',
        () async {
      when(() => mockRepository.getChatMessages(chatId)).thenAnswer(
        (_) async => const Right(<ChatMessageEntity>[]),
      );

      final result = await useCase(chatId);

      result.fold(
        (_) => fail('Expected Right'),
        (messages) => expect(messages, isEmpty),
      );
    });

    test('should return Left(Failure) when repository fails', () async {
      when(() => mockRepository.getChatMessages(chatId)).thenAnswer(
        (_) async =>
            const Left(ServerFailure(message: 'Chat not found')),
      );

      final result = await useCase(chatId);

      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Chat not found');
        },
        (_) => fail('Expected Left'),
      );
    });

    test(
        'should return Left(NetworkFailure) when network is unavailable',
        () async {
      when(() => mockRepository.getChatMessages(chatId)).thenAnswer(
        (_) async => const Left(NetworkFailure()),
      );

      final result = await useCase(chatId);

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('should delegate the exact chatId to the repository', () async {
      const String specificId = 'specific-chat-id-xyz';
      when(() => mockRepository.getChatMessages(specificId)).thenAnswer(
        (_) async => const Right(<ChatMessageEntity>[]),
      );

      await useCase(specificId);

      verify(() => mockRepository.getChatMessages(specificId)).called(1);
    });
  });
}
