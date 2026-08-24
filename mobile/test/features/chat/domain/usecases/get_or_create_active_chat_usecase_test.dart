import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:mobile/features/chat/domain/usecases/get_or_create_active_chat_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockRepository;
  late GetOrCreateActiveChatUseCase useCase;

  setUp(() {
    mockRepository = MockChatRepository();
    useCase =
        GetOrCreateActiveChatUseCase(mockRepository);
  });

  final DateTime now = DateTime.utc(2026, 8, 24, 12, 0, 0);

  final ChatThreadEntity activeThread = ChatThreadEntity(
    id: 'active-thread',
    userId: 'user-1',
    status: ChatStatus.active,
    createdAt: now,
    updatedAt: now,
  );

  final ChatThreadEntity closedThread = ChatThreadEntity(
    id: 'closed-thread',
    userId: 'user-1',
    status: ChatStatus.closed,
    createdAt: now,
    updatedAt: now,
  );

  final ChatThreadEntity newThread = ChatThreadEntity(
    id: 'new-thread',
    userId: 'user-1',
    status: ChatStatus.active,
    createdAt: now,
    updatedAt: now,
  );

  group('GetOrCreateActiveChatUseCase', () {
    test(
        'should return existing active thread without calling createChat',
        () async {
      when(() => mockRepository.getChats()).thenAnswer(
        (_) async => Right(<ChatThreadEntity>[closedThread, activeThread]),
      );

      final result = await useCase(const NoParams());

      result.fold(
        (_) => fail('Expected Right'),
        (thread) => expect(thread.id, 'active-thread'),
      );
      verify(() => mockRepository.getChats()).called(1);
      verifyNever(() => mockRepository.createChat());
    });

    test(
        'should call createChat when no active thread exists in the list',
        () async {
      when(() => mockRepository.getChats()).thenAnswer(
        (_) async => Right(<ChatThreadEntity>[closedThread]),
      );
      when(() => mockRepository.createChat()).thenAnswer(
        (_) async => Right(newThread),
      );

      final result = await useCase(const NoParams());

      result.fold(
        (_) => fail('Expected Right'),
        (thread) => expect(thread.id, 'new-thread'),
      );
      verify(() => mockRepository.getChats()).called(1);
      verify(() => mockRepository.createChat()).called(1);
    });

    test('should call createChat when thread list is empty', () async {
      when(() => mockRepository.getChats()).thenAnswer(
        (_) async => const Right(<ChatThreadEntity>[]),
      );
      when(() => mockRepository.createChat()).thenAnswer(
        (_) async => Right(newThread),
      );

      final result = await useCase(const NoParams());

      result.fold(
        (_) => fail('Expected Right'),
        (thread) => expect(thread.id, 'new-thread'),
      );
      verify(() => mockRepository.createChat()).called(1);
    });

    test('should return Left(Failure) when getChats fails', () async {
      when(() => mockRepository.getChats()).thenAnswer(
        (_) async => const Left(
          ServerFailure(message: 'Server down'),
        ),
      );

      final result = await useCase(const NoParams());

      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Server down');
        },
        (_) => fail('Expected Left'),
      );
      verifyNever(() => mockRepository.createChat());
    });

    test(
        'should return Left(Failure) when createChat fails after empty list',
        () async {
      when(() => mockRepository.getChats()).thenAnswer(
        (_) async => const Right(<ChatThreadEntity>[]),
      );
      when(() => mockRepository.createChat()).thenAnswer(
        (_) async => const Left(NetworkFailure()),
      );

      final result = await useCase(const NoParams());

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('should pick the first active thread when multiple exist',
        () async {
      final ChatThreadEntity active2 = ChatThreadEntity(
        id: 'active-thread-2',
        userId: 'user-1',
        status: ChatStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      when(() => mockRepository.getChats()).thenAnswer(
        (_) async => Right(
          <ChatThreadEntity>[activeThread, active2],
        ),
      );

      final result = await useCase(const NoParams());

      result.fold(
        (_) => fail('Expected Right'),
        (thread) => expect(thread.id, 'active-thread'),
      );
      verifyNever(() => mockRepository.createChat());
    });
  });
}
