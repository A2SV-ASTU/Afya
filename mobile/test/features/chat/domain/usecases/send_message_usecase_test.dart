import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';
import 'package:mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:mobile/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockRepository;
  late SendMessageUseCase useCase;

  setUp(() {
    mockRepository = MockChatRepository();
    useCase = SendMessageUseCase(repository: mockRepository);
  });

  final DateTime now = DateTime.utc(2026, 8, 24, 12, 0, 0);

  final ChatMessageEntity appResponseWithExercise = ChatMessageEntity(
    id: 'msg-reply-1',
    chatId: 'chat-1',
    sender: MessageSender.app,
    content: 'I recommend trying the 4-7-8 breathing technique.',
    suggestedExerciseId: 'ex-breathing-478',
    createdAt: now,
  );

  final ChatMessageEntity appResponseWithoutExercise = ChatMessageEntity(
    id: 'msg-reply-2',
    chatId: 'chat-1',
    sender: MessageSender.app,
    content: 'Tell me more about how you are feeling.',
    createdAt: now,
  );

  const SendMessageParams tParams = SendMessageParams(
    chatId: 'chat-1',
    message: 'I feel anxious',
  );

  group('SendMessageUseCase', () {
    test(
        'should return Right(ChatMessageEntity) with suggestedExerciseId on success',
        () async {
      when(() => mockRepository.sendMessage(
            chatId: tParams.chatId,
            message: tParams.message,
          )).thenAnswer((_) async => Right(appResponseWithExercise));

      final result = await useCase(tParams);

      result.fold(
        (_) => fail('Expected Right'),
        (msg) {
          expect(msg.sender, MessageSender.app);
          expect(msg.suggestedExerciseId, 'ex-breathing-478');
          expect(msg.content,
              'I recommend trying the 4-7-8 breathing technique.');
        },
      );
      verify(() => mockRepository.sendMessage(
            chatId: tParams.chatId,
            message: tParams.message,
          )).called(1);
    });

    test(
        'should return Right(ChatMessageEntity) without suggestedExerciseId',
        () async {
      when(() => mockRepository.sendMessage(
            chatId: tParams.chatId,
            message: tParams.message,
          )).thenAnswer(
        (_) async => Right(appResponseWithoutExercise),
      );

      final result = await useCase(tParams);

      result.fold(
        (_) => fail('Expected Right'),
        (msg) {
          expect(msg.sender, MessageSender.app);
          expect(msg.suggestedExerciseId, isNull);
        },
      );
    });

    test('should return Left(ServerFailure) when repository fails',
        () async {
      when(() => mockRepository.sendMessage(
            chatId: tParams.chatId,
            message: tParams.message,
          )).thenAnswer(
        (_) async => const Left(
          ServerFailure(
            message: 'Rate limited',
            code: 'RATE_LIMIT',
            statusCode: 429,
          ),
        ),
      );

      final result = await useCase(tParams);

      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.code, 'RATE_LIMIT');
        },
        (_) => fail('Expected Left'),
      );
    });

    test('should return Left(NetworkFailure) on network error', () async {
      when(() => mockRepository.sendMessage(
            chatId: tParams.chatId,
            message: tParams.message,
          )).thenAnswer(
        (_) async => const Left(NetworkFailure()),
      );

      final result = await useCase(tParams);

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test(
        'should return Left(UnauthorizedFailure) on auth error',
        () async {
      when(() => mockRepository.sendMessage(
            chatId: tParams.chatId,
            message: tParams.message,
          )).thenAnswer(
        (_) async => const Left(UnauthorizedFailure()),
      );

      final result = await useCase(tParams);

      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('should pass correct chatId and message to repository',
        () async {
      const SendMessageParams customParams = SendMessageParams(
        chatId: 'custom-chat-id',
        message: 'Custom message content',
      );

      when(() => mockRepository.sendMessage(
            chatId: customParams.chatId,
            message: customParams.message,
          )).thenAnswer(
        (_) async => Right(appResponseWithoutExercise),
      );

      await useCase(customParams);

      verify(() => mockRepository.sendMessage(
            chatId: 'custom-chat-id',
            message: 'Custom message content',
          )).called(1);
    });
  });

  group('SendMessageParams', () {
    test('should hold chatId and message', () {
      const params = SendMessageParams(
        chatId: 'c-1',
        message: 'hello',
      );

      expect(params.chatId, 'c-1');
      expect(params.message, 'hello');
    });
  });
}
