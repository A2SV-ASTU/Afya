import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';
import 'package:mobile/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:mobile/features/chat/domain/usecases/get_chat_messages_usecase.dart';
import 'package:mobile/features/chat/domain/usecases/get_or_create_active_chat_usecase.dart';
import 'package:mobile/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:mobile/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:mobile/features/chat/presentation/bloc/chat_event.dart';
import 'package:mobile/features/chat/presentation/bloc/chat_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetOrCreateActiveChatUseCase extends Mock
    implements GetOrCreateActiveChatUseCase {}

class MockGetChatMessagesUseCase extends Mock
    implements GetChatMessagesUseCase {}

class MockSendMessageUseCase extends Mock implements SendMessageUseCase {}

void main() {
  late MockGetOrCreateActiveChatUseCase mockGetOrCreateActiveChatUseCase;
  late MockGetChatMessagesUseCase mockGetChatMessagesUseCase;
  late MockSendMessageUseCase mockSendMessageUseCase;
  late ChatBloc bloc;

  setUpAll(() {
    // Register fallback for SendMessageParams so mocktail can match any instance.
    registerFallbackValue(
      const SendMessageParams(chatId: '', message: ''),
    );
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockGetOrCreateActiveChatUseCase =
        MockGetOrCreateActiveChatUseCase();
    mockGetChatMessagesUseCase = MockGetChatMessagesUseCase();
    mockSendMessageUseCase = MockSendMessageUseCase();
    bloc = ChatBloc(
      getOrCreateActiveChatUseCase: mockGetOrCreateActiveChatUseCase,
      getChatMessagesUseCase: mockGetChatMessagesUseCase,
      sendMessageUseCase: mockSendMessageUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  // ── Fixtures ────────────────────────────────────────────────────────

  final DateTime now = DateTime.utc(2026, 8, 24, 12, 0, 0);

  final ChatThreadEntity tThread = ChatThreadEntity(
    id: 'thread-1',
    userId: 'user-1',
    status: ChatStatus.active,
    createdAt: now,
    updatedAt: now,
  );

  final List<ChatMessageEntity> tMessages = <ChatMessageEntity>[
    ChatMessageEntity(
      id: 'msg-1',
      chatId: 'thread-1',
      sender: MessageSender.user,
      content: 'Hello',
      createdAt: now,
    ),
    ChatMessageEntity(
      id: 'msg-2',
      chatId: 'thread-1',
      sender: MessageSender.app,
      content: 'Hi! How can I help you today?',
      createdAt: now,
    ),
  ];

  final ChatMessageEntity tAppResponse = ChatMessageEntity(
    id: 'msg-reply-1',
    chatId: 'thread-1',
    sender: MessageSender.app,
    content: 'I recommend trying the 4-7-8 breathing technique.',
    suggestedExerciseId: 'ex-breathing-478',
    createdAt: now,
  );

  // Helper to fully load the chat bloc into a ChatLoaded state.
  Future<void> seedChatLoaded() async {
    when(() => mockGetOrCreateActiveChatUseCase(any()))
        .thenAnswer((_) async => Right(tThread));
    when(() => mockGetChatMessagesUseCase(any()))
        .thenAnswer((_) async => Right(tMessages));

    final List<ChatState> states = <ChatState>[];
    final StreamSubscription<ChatState> sub =
        bloc.stream.listen(states.add);

    bloc.add(const LoadChatEvent());
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    // Verify we landed in ChatLoaded.
    expect(states.last, isA<ChatLoaded>());
  }

  // ── Initial State ───────────────────────────────────────────────────

  group('initial state', () {
    test('should start with ChatInitial', () {
      expect(bloc.state, isA<ChatInitial>());
    });
  });

  // ── Canned Responses ────────────────────────────────────────────────

  group('cannedResponses', () {
    test('should contain exactly 5 predefined options', () {
      expect(cannedResponses.length, 5);
    });

    test('should include common mental health responses', () {
      expect(cannedResponses, contains('I\'m feeling anxious'));
      expect(cannedResponses, contains('I\'m feeling sad'));
      expect(cannedResponses, contains('I need motivation'));
      expect(cannedResponses, contains('I can\'t sleep'));
      expect(cannedResponses, contains('I\'m feeling stressed'));
    });
  });

  // ── LoadChatEvent ───────────────────────────────────────────────────

  group('LoadChatEvent', () {
    test(
        'should emit [ChatLoading, ChatLoaded] when both use cases succeed',
        () async {
      when(() => mockGetOrCreateActiveChatUseCase(any()))
          .thenAnswer((_) async => Right(tThread));
      when(() => mockGetChatMessagesUseCase(any()))
          .thenAnswer((_) async => Right(tMessages));

      final List<ChatState> actual = <ChatState>[];
      final StreamSubscription<ChatState> sub =
          bloc.stream.listen(actual.add);

      bloc.add(const LoadChatEvent());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(actual.length, 2);
      expect(actual[0], isA<ChatLoading>());
      expect(actual[1], isA<ChatLoaded>());
      final ChatLoaded loaded = actual[1] as ChatLoaded;
      expect(loaded.thread.id, 'thread-1');
      expect(loaded.messages.length, 2);
    });

    test(
        'should emit [ChatLoading, ChatError] when getOrCreateActiveChatUseCase fails',
        () async {
      when(() => mockGetOrCreateActiveChatUseCase(any()))
          .thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Server down')),
      );

      final List<ChatState> actual = <ChatState>[];
      final StreamSubscription<ChatState> sub =
          bloc.stream.listen(actual.add);

      bloc.add(const LoadChatEvent());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(actual.length, 2);
      expect(actual[0], isA<ChatLoading>());
      expect(actual[1], isA<ChatError>());
      final ChatError error = actual[1] as ChatError;
      expect(error.message, 'Server down');
    });

    test(
        'should emit [ChatLoading, ChatError] when getChatMessagesUseCase fails',
        () async {
      when(() => mockGetOrCreateActiveChatUseCase(any()))
          .thenAnswer((_) async => Right(tThread));
      when(() => mockGetChatMessagesUseCase(any()))
          .thenAnswer((_) async => const Left(NetworkFailure()));

      final List<ChatState> actual = <ChatState>[];
      final StreamSubscription<ChatState> sub =
          bloc.stream.listen(actual.add);

      bloc.add(const LoadChatEvent());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(actual.length, 2);
      expect(actual[0], isA<ChatLoading>());
      expect(actual[1], isA<ChatError>());
      final ChatError error = actual[1] as ChatError;
      expect(error.message, 'Please check your internet connection.');
    });

    test(
        'should emit ChatLoaded with empty messages when no messages exist',
        () async {
      when(() => mockGetOrCreateActiveChatUseCase(any()))
          .thenAnswer((_) async => Right(tThread));
      when(() => mockGetChatMessagesUseCase(any()))
          .thenAnswer((_) async => const Right(<ChatMessageEntity>[]));

      final List<ChatState> actual = <ChatState>[];
      final StreamSubscription<ChatState> sub =
          bloc.stream.listen(actual.add);

      bloc.add(const LoadChatEvent());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(actual.length, 2);
      expect(actual.last, isA<ChatLoaded>());
      final ChatLoaded loaded = actual.last as ChatLoaded;
      expect(loaded.messages, isEmpty);
    });
  });

  // ── SendMessageEvent ────────────────────────────────────────────────

  group('SendMessageEvent', () {
    test(
        'should emit [MessageSending, ChatLoaded] with optimistic then server response on success',
        () async {
      await seedChatLoaded();

      when(() => mockSendMessageUseCase(any()))
          .thenAnswer((_) async => Right(tAppResponse));

      final List<ChatState> statesAfterSend = <ChatState>[];
      final StreamSubscription<ChatState> sub =
          bloc.stream.listen(statesAfterSend.add);

      bloc.add(const SendMessageEvent(
        message: 'I feel anxious',
        chatId: 'thread-1',
      ));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      // First emitted state should be MessageSending with the optimistic message.
      expect(statesAfterSend[0], isA<MessageSending>());
      final MessageSending sending =
          statesAfterSend[0] as MessageSending;
      expect(sending.messages.length, tMessages.length + 1);
      expect(sending.messages.last.sender, MessageSender.user);
      expect(sending.messages.last.content, 'I feel anxious');

      // Second emitted state should be ChatLoaded with both messages.
      expect(statesAfterSend[1], isA<ChatLoaded>());
      final ChatLoaded loaded = statesAfterSend[1] as ChatLoaded;
      expect(loaded.messages.length, tMessages.length + 2);
      expect(loaded.messages.last.sender, MessageSender.app);
      expect(
        loaded.messages.last.content,
        'I recommend trying the 4-7-8 breathing technique.',
      );
    });

    test(
        'should revert optimistic message and emit ChatError when sendMessage fails',
        () async {
      await seedChatLoaded();

      when(() => mockSendMessageUseCase(any())).thenAnswer(
        (_) async =>
            const Left(ServerFailure(message: 'Rate limited')),
      );

      final List<ChatState> statesAfterSend = <ChatState>[];
      final StreamSubscription<ChatState> sub =
          bloc.stream.listen(statesAfterSend.add);

      bloc.add(const SendMessageEvent(
        message: 'I feel anxious',
        chatId: 'thread-1',
      ));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      // First emitted state should be MessageSending with the optimistic message.
      expect(statesAfterSend[0], isA<MessageSending>());

      // Second emitted state should be ChatLoaded with the optimistic message reverted.
      expect(statesAfterSend[1], isA<ChatLoaded>());
      final ChatLoaded reverted =
          statesAfterSend[1] as ChatLoaded;
      expect(reverted.messages.length, tMessages.length);

      // Third emitted state should be ChatError.
      expect(statesAfterSend[2], isA<ChatError>());
      final ChatError error = statesAfterSend[2] as ChatError;
      expect(error.message, 'Rate limited');
    });

    test(
        'should not emit when state is ChatInitial (not loaded yet)',
        () async {
      final List<ChatState> statesAfterSend = <ChatState>[];
      final StreamSubscription<ChatState> sub =
          bloc.stream.listen(statesAfterSend.add);

      bloc.add(const SendMessageEvent(
        message: 'Hello',
        chatId: 'thread-1',
      ));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(statesAfterSend, isEmpty);
    });

    test(
        'should not emit when state is ChatError (error without loaded thread)',
        () async {
      when(() => mockGetOrCreateActiveChatUseCase(any()))
          .thenAnswer(
        (_) async =>
            const Left(ServerFailure(message: 'Server down')),
      );

      // Load then fail.
      final List<ChatState> loadStates = <ChatState>[];
      final StreamSubscription<ChatState> loadSub =
          bloc.stream.listen(loadStates.add);

      bloc.add(const LoadChatEvent());
      await Future<void>.delayed(Duration.zero);
      await loadSub.cancel();

      expect(bloc.state, isA<ChatError>());

      final List<ChatState> statesAfterSend = <ChatState>[];
      final StreamSubscription<ChatState> sub =
          bloc.stream.listen(statesAfterSend.add);

      bloc.add(const SendMessageEvent(
        message: 'Hello',
        chatId: 'thread-1',
      ));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(statesAfterSend, isEmpty);
    });

    test('should handle NetworkFailure during sendMessage', () async {
      await seedChatLoaded();

      when(() => mockSendMessageUseCase(any()))
          .thenAnswer((_) async => const Left(NetworkFailure()));

      final List<ChatState> statesAfterSend = <ChatState>[];
      final StreamSubscription<ChatState> sub =
          bloc.stream.listen(statesAfterSend.add);

      bloc.add(const SendMessageEvent(
        message: 'Hello',
        chatId: 'thread-1',
      ));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      // Should emit MessageSending, then ChatLoaded (reverted), then ChatError.
      expect(statesAfterSend.length, 3);
      expect(statesAfterSend[0], isA<MessageSending>());
      expect(statesAfterSend[1], isA<ChatLoaded>());
      expect(statesAfterSend[2], isA<ChatError>());
      final ChatError error = statesAfterSend[2] as ChatError;
      expect(error.message, 'Please check your internet connection.');
    });
  });

  // ── ChatEvent equality ──────────────────────────────────────────────

  group('ChatEvent equality', () {
    test('SendMessageEvent with same message and chatId should be equal',
        () {
      const SendMessageEvent a = SendMessageEvent(
        message: 'Hello',
        chatId: 'chat-1',
      );
      const SendMessageEvent b = SendMessageEvent(
        message: 'Hello',
        chatId: 'chat-1',
      );
      expect(a, equals(b));
    });

    test('SendMessageEvent with different message should not be equal',
        () {
      const SendMessageEvent a = SendMessageEvent(
        message: 'Hello',
        chatId: 'chat-1',
      );
      const SendMessageEvent b = SendMessageEvent(
        message: 'Goodbye',
        chatId: 'chat-1',
      );
      expect(a, isNot(equals(b)));
    });

    test('SendMessageEvent with different chatId should not be equal',
        () {
      const SendMessageEvent a = SendMessageEvent(
        message: 'Hello',
        chatId: 'chat-1',
      );
      const SendMessageEvent b = SendMessageEvent(
        message: 'Hello',
        chatId: 'chat-2',
      );
      expect(a, isNot(equals(b)));
    });

    test('LoadChatEvent instances should be equal', () {
      const LoadChatEvent a = LoadChatEvent();
      const LoadChatEvent b = LoadChatEvent();
      expect(a, equals(b));
    });
  });

  // ── ChatState equality ──────────────────────────────────────────────

  group('ChatState equality', () {
    test('ChatInitial instances should be equal', () {
      const ChatInitial a = ChatInitial();
      const ChatInitial b = ChatInitial();
      expect(a, equals(b));
    });

    test('ChatLoading instances should be equal', () {
      const ChatLoading a = ChatLoading();
      const ChatLoading b = ChatLoading();
      expect(a, equals(b));
    });

    test('ChatLoaded with same data should be equal', () {
      final ChatLoaded a =
          ChatLoaded(thread: tThread, messages: tMessages);
      final ChatLoaded b =
          ChatLoaded(thread: tThread, messages: tMessages);
      expect(a, equals(b));
    });

    test('ChatLoaded with different messages should not be equal', () {
      final ChatLoaded a =
          ChatLoaded(thread: tThread, messages: tMessages);
      final ChatLoaded b = ChatLoaded(
        thread: tThread,
        messages: <ChatMessageEntity>[],
      );
      expect(a, isNot(equals(b)));
    });

    test('MessageSending with same data should be equal', () {
      final MessageSending a =
          MessageSending(thread: tThread, messages: tMessages);
      final MessageSending b =
          MessageSending(thread: tThread, messages: tMessages);
      expect(a, equals(b));
    });

    test('ChatError with same message should be equal', () {
      const ChatError a = ChatError(message: 'error');
      const ChatError b = ChatError(message: 'error');
      expect(a, equals(b));
    });

    test('ChatError with different message should not be equal', () {
      const ChatError a = ChatError(message: 'error-1');
      const ChatError b = ChatError(message: 'error-2');
      expect(a, isNot(equals(b)));
    });
  });
}
