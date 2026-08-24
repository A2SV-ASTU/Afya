import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/chat/data/models/chat_thread_model.dart';
import 'package:mobile/features/chat/domain/entities/chat_thread_entity.dart';

void main() {
  group('ChatThreadModel', () {
    final DateTime createdAt = DateTime.utc(2026, 8, 24, 12, 0, 0);
    final DateTime updatedAt = DateTime.utc(2026, 8, 24, 13, 0, 0);

    final Map<String, dynamic> validJson = <String, dynamic>{
      'id': 'thread-abc',
      'user_id': 'user-123',
      'status': 'active',
      'created_at': '2026-08-24T12:00:00.000Z',
      'updated_at': '2026-08-24T13:00:00.000Z',
    };

    group('fromJson', () {
      test('should return a valid model from JSON with active status', () {
        final model = ChatThreadModel.fromJson(validJson);

        expect(model.id, 'thread-abc');
        expect(model.userId, 'user-123');
        expect(model.status, ChatStatus.active);
        expect(model.createdAt, createdAt);
        expect(model.updatedAt, updatedAt);
      });

      test('should parse closed status correctly', () {
        final json = Map<String, dynamic>.from(validJson)
          ..['status'] = 'closed';

        final model = ChatThreadModel.fromJson(json);

        expect(model.status, ChatStatus.closed);
      });

      test('should default to closed for unknown status values', () {
        final json = Map<String, dynamic>.from(validJson)
          ..['status'] = 'unknown_status';

        final model = ChatThreadModel.fromJson(json);

        expect(model.status, ChatStatus.closed);
      });
    });

    group('toJson', () {
      test('should produce correct JSON from an active thread model', () {
        final model = ChatThreadModel(
          id: 'thread-abc',
          userId: 'user-123',
          status: ChatStatus.active,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = model.toJson();

        expect(json['id'], 'thread-abc');
        expect(json['user_id'], 'user-123');
        expect(json['status'], 'active');
        expect(json['created_at'], createdAt.toIso8601String());
        expect(json['updated_at'], updatedAt.toIso8601String());
      });

      test('should produce "closed" for closed status', () {
        final model = ChatThreadModel(
          id: 'thread-xyz',
          userId: 'user-456',
          status: ChatStatus.closed,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = model.toJson();

        expect(json['status'], 'closed');
      });
    });

    group('roundtrip', () {
      test('fromJson → toJson should produce equivalent JSON', () {
        final model = ChatThreadModel.fromJson(validJson);
        final outputJson = model.toJson();

        expect(outputJson['id'], validJson['id']);
        expect(outputJson['user_id'], validJson['user_id']);
        expect(outputJson['status'], validJson['status']);
      });
    });

    test('should be a subtype of ChatThreadEntity', () {
      final model = ChatThreadModel.fromJson(validJson);
      expect(model, isA<ChatThreadEntity>());
    });
  });
}
