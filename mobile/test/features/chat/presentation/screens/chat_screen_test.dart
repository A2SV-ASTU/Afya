import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';
import 'package:mobile/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:mobile/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:mobile/features/chat/presentation/bloc/chat_event.dart';
import 'package:mobile/features/chat/presentation/bloc/chat_state.dart';
import 'package:mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:mobile/features/chat/presentation/widgets/chat_bubble_widget.dart';
import 'package:mobile/features/chat/presentation/widgets/chat_fallback_view.dart';
import 'package:mocktail/mocktail.dart';

class MockChatBloc extends Mock implements ChatBloc {}
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockChatBloc mockChatBloc;
  late MockGoRouter mockGoRouter;
  late StreamController<ChatState> stateController;

  setUpAll(() {
    registerFallbackValue(const LoadChatEvent());
    registerFallbackValue(const ChatInitial());
  });

  setUp(() {
    mockChatBloc = MockChatBloc();
    mockGoRouter = MockGoRouter();
    stateController = StreamController<ChatState>.broadcast();

    when(() => mockChatBloc.state).thenReturn(const ChatInitial());
    when(() => mockChatBloc.stream).thenAnswer((_) => stateController.stream);
    when(() => mockChatBloc.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    stateController.close();
  });

  Widget buildWidget() {
    return MaterialApp(
      home: InheritedGoRouter(
        goRouter: mockGoRouter,
        child: BlocProvider<ChatBloc>.value(
          value: mockChatBloc,
          child: const ChatScreen(),
        ),
      ),
    );
  }

  testWidgets('ChatScreen shows loading indicator on initial state', (tester) async {
    when(() => mockChatBloc.state).thenReturn(const ChatInitial());

    await tester.pumpWidget(buildWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    verify(() => mockChatBloc.add(const LoadChatEvent())).called(1);
  });

  testWidgets('ChatScreen shows loading indicator on loading state', (tester) async {
    when(() => mockChatBloc.state).thenReturn(const ChatLoading());

    await tester.pumpWidget(buildWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ChatScreen shows ChatFallbackView on error state', (tester) async {
    when(() => mockChatBloc.state).thenReturn(const ChatError(message: 'Error'));

    await tester.pumpWidget(buildWidget());

    expect(find.byType(ChatFallbackView), findsOneWidget);
  });

  testWidgets('ChatScreen renders messages on loaded state', (tester) async {
    final thread = ChatThreadEntity(
      id: 'thread1',
      userId: 'user1',
      status: ChatStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final messages = [
      ChatMessageEntity(
        id: '1',
        chatId: 'thread1',
        sender: MessageSender.user,
        content: 'Hi',
        createdAt: DateTime.now(),
      ),
      ChatMessageEntity(
        id: '2',
        chatId: 'thread1',
        sender: MessageSender.app,
        content: 'Hello',
        createdAt: DateTime.now(),
      ),
    ];
    when(() => mockChatBloc.state).thenReturn(ChatLoaded(thread: thread, messages: messages));

    await tester.pumpWidget(buildWidget());

    expect(find.byType(ChatBubbleWidget), findsNWidgets(2));
    expect(find.text('Hi'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('ChatScreen sends message on submit', (tester) async {
    final thread = ChatThreadEntity(
      id: 'thread1',
      userId: 'user1',
      status: ChatStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    when(() => mockChatBloc.state).thenReturn(ChatLoaded(thread: thread, messages: const []));

    await tester.pumpWidget(buildWidget());

    await tester.enterText(find.byType(TextField), 'Test message');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    verify(() => mockChatBloc.add(const SendMessageEvent(chatId: 'thread1', message: 'Test message'))).called(1);
  });

  testWidgets('ChatScreen navigates to /crisis when Crisis button tapped', (tester) async {
    when(() => mockChatBloc.state).thenReturn(const ChatInitial());

    await tester.pumpWidget(buildWidget());

    await tester.tap(find.text('Crisis'));
    await tester.pumpAndSettle();

    verify(() => mockGoRouter.go('/crisis')).called(1);
  });
}
