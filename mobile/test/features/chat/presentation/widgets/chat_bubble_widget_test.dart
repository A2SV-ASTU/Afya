import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';
import 'package:mobile/features/chat/presentation/widgets/chat_bubble_widget.dart';
import 'package:mobile/features/chat/presentation/widgets/suggested_exercise_card.dart';

void main() {
  testWidgets('ChatBubbleWidget renders user message without exercise card', (tester) async {
    final message = ChatMessageEntity(
      id: '1',
      chatId: 'thread1',
      sender: MessageSender.user,
      content: 'Hello, this is a user message.',
      createdAt: DateTime(2023, 1, 1, 10, 30),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ChatBubbleWidget(message: message),
      ),
    ));

    expect(find.text('Hello, this is a user message.'), findsOneWidget);
    expect(find.text('10:30 AM'), findsOneWidget);
    expect(find.byType(SuggestedExerciseCard), findsNothing);
  });

  testWidgets('ChatBubbleWidget renders app message with exercise card', (tester) async {
    final message = ChatMessageEntity(
      id: '2',
      chatId: 'thread1',
      sender: MessageSender.app,
      content: 'Hello, this is an app message.',
      suggestedExerciseId: 'sleep_1',
      createdAt: DateTime(2023, 1, 1, 14, 45),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ChatBubbleWidget(message: message),
      ),
    ));

    expect(find.text('Hello, this is an app message.'), findsOneWidget);
    expect(find.text('2:45 PM'), findsOneWidget);
    expect(find.byType(SuggestedExerciseCard), findsOneWidget);
  });
}
