import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';

void main() {
  group('ChatMessageEntity', () {
    final DateTime now = DateTime(2026, 8, 24, 12, 0, 0);

    ChatMessageEntity createMessage({
      String id = 'msg-1',
      String chatId = 'chat-1',
      MessageSender sender = MessageSender.user,
      String content = 'Hello',
      String? suggestedExerciseId,
      DateTime? createdAt,
    }) {
      return ChatMessageEntity(
        id: id,
        chatId: chatId,
        sender: sender,
        content: content,
        suggestedExerciseId: suggestedExerciseId,
        createdAt: createdAt ?? now,
      );
    }

    test('should create an entity with all required fields', () {
      final message = createMessage();

      expect(message.id, 'msg-1');
      expect(message.chatId, 'chat-1');
      expect(message.sender, MessageSender.user);
      expect(message.content, 'Hello');
      expect(message.suggestedExerciseId, isNull);
      expect(message.createdAt, now);
    });

    test('should create a message with suggestedExerciseId', () {
      final message =
          createMessage(suggestedExerciseId: 'exercise-42');

      expect(message.suggestedExerciseId, 'exercise-42');
    });

    test('should support user sender', () {
      final message = createMessage(sender: MessageSender.user);
      expect(message.sender, MessageSender.user);
    });

    test('should support app sender', () {
      final message = createMessage(sender: MessageSender.app);
      expect(message.sender, MessageSender.app);
    });

    test(
        'app message with suggestedExerciseId should deserialize correctly',
        () {
      final message = createMessage(
        sender: MessageSender.app,
        content: 'Try this breathing exercise.',
        suggestedExerciseId: 'ex-breathing-101',
      );

      expect(message.sender, MessageSender.app);
      expect(message.suggestedExerciseId, 'ex-breathing-101');
    });

    group('equality', () {
      test('two messages with the same id should be equal', () {
        final msg1 = createMessage(id: 'same-id', content: 'A');
        final msg2 = createMessage(id: 'same-id', content: 'B');

        expect(msg1, equals(msg2));
      });

      test('two messages with different ids should not be equal', () {
        final msg1 = createMessage(id: 'id-1');
        final msg2 = createMessage(id: 'id-2');

        expect(msg1, isNot(equals(msg2)));
      });
    });

    group('hashCode', () {
      test('same id should produce the same hashCode', () {
        final msg1 = createMessage(id: 'hash-id');
        final msg2 = createMessage(id: 'hash-id');

        expect(msg1.hashCode, equals(msg2.hashCode));
      });
    });

    group('toString', () {
      test('should include id and sender', () {
        final message = createMessage(id: 'abc', sender: MessageSender.app);
        final str = message.toString();

        expect(str, contains('abc'));
        expect(str, contains('app'));
      });

      test('should truncate long content in toString', () {
        final longContent = 'A' * 60;
        final message = createMessage(content: longContent);
        final str = message.toString();

        expect(str, contains('...'));
      });

      test('should not truncate short content in toString', () {
        final message = createMessage(content: 'Short');
        final str = message.toString();

        expect(str, contains('Short'));
        expect(str, isNot(contains('...')));
      });
    });
  });

  group('MessageSender', () {
    test('should have exactly two values', () {
      expect(MessageSender.values.length, 2);
    });

    test('should contain user and app', () {
      expect(MessageSender.values, contains(MessageSender.user));
      expect(MessageSender.values, contains(MessageSender.app));
    });
  });
}
