import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/chat/domain/entities/chat_thread_entity.dart';

void main() {
  group('ChatThreadEntity', () {
    final DateTime now = DateTime(2026, 8, 24, 12, 0, 0);

    ChatThreadEntity createThread({
      String id = 'thread-1',
      String userId = 'user-1',
      ChatStatus status = ChatStatus.active,
      DateTime? createdAt,
      DateTime? updatedAt,
    }) {
      return ChatThreadEntity(
        id: id,
        userId: userId,
        status: status,
        createdAt: createdAt ?? now,
        updatedAt: updatedAt ?? now,
      );
    }

    test('should create an entity with all required fields', () {
      final thread = createThread();

      expect(thread.id, 'thread-1');
      expect(thread.userId, 'user-1');
      expect(thread.status, ChatStatus.active);
      expect(thread.createdAt, now);
      expect(thread.updatedAt, now);
    });

    test('should support active status', () {
      final thread = createThread(status: ChatStatus.active);
      expect(thread.status, ChatStatus.active);
    });

    test('should support closed status', () {
      final thread = createThread(status: ChatStatus.closed);
      expect(thread.status, ChatStatus.closed);
    });

    group('equality', () {
      test('two threads with the same id should be equal', () {
        final thread1 = createThread(id: 'same-id', userId: 'user-A');
        final thread2 = createThread(id: 'same-id', userId: 'user-B');

        expect(thread1, equals(thread2));
      });

      test('two threads with different ids should not be equal', () {
        final thread1 = createThread(id: 'id-1');
        final thread2 = createThread(id: 'id-2');

        expect(thread1, isNot(equals(thread2)));
      });

      test('identical instance should be equal', () {
        final thread = createThread();
        expect(thread, equals(thread));
      });
    });

    group('hashCode', () {
      test('same id should produce the same hashCode', () {
        final thread1 = createThread(id: 'hash-id');
        final thread2 = createThread(id: 'hash-id');

        expect(thread1.hashCode, equals(thread2.hashCode));
      });
    });

    group('toString', () {
      test('should include id and status', () {
        final thread = createThread(id: 'abc', status: ChatStatus.active);
        final str = thread.toString();

        expect(str, contains('abc'));
        expect(str, contains('active'));
      });
    });
  });

  group('ChatStatus', () {
    test('should have exactly two values', () {
      expect(ChatStatus.values.length, 2);
    });

    test('should contain active and closed', () {
      expect(ChatStatus.values, contains(ChatStatus.active));
      expect(ChatStatus.values, contains(ChatStatus.closed));
    });
  });
}
