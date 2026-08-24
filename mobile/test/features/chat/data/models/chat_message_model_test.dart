import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/chat/data/models/chat_message_model.dart';
import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';

void main() {
  group('ChatMessageModel', () {
    final DateTime createdAt = DateTime.utc(2026, 8, 24, 12, 0, 0);

    final Map<String, dynamic> userMessageJson = <String, dynamic>{
      'id': 'msg-1',
      'chat_id': 'chat-abc',
      'sender': 'user',
      'content': 'How can I manage my anxiety?',
      'suggested_exercise_id': null,
      'created_at': '2026-08-24T12:00:00.000Z',
    };

    final Map<String, dynamic> appMessageWithExerciseJson =
        <String, dynamic>{
      'id': 'msg-2',
      'chat_id': 'chat-abc',
      'sender': 'app',
      'content': 'Try this breathing exercise to calm down.',
      'suggested_exercise_id': 'exercise-breathing-101',
      'created_at': '2026-08-24T12:00:00.000Z',
    };

    final Map<String, dynamic> appMessageWithoutExerciseJson =
        <String, dynamic>{
      'id': 'msg-3',
      'chat_id': 'chat-abc',
      'sender': 'app',
      'content': 'I understand how you feel.',
      'suggested_exercise_id': null,
      'created_at': '2026-08-24T12:00:00.000Z',
    };

    group('fromJson', () {
      test('should parse a user message correctly', () {
        final model = ChatMessageModel.fromJson(userMessageJson);

        expect(model.id, 'msg-1');
        expect(model.chatId, 'chat-abc');
        expect(model.sender, MessageSender.user);
        expect(model.content, 'How can I manage my anxiety?');
        expect(model.suggestedExerciseId, isNull);
        expect(model.createdAt, createdAt);
      });

      test('should parse an app message with suggested_exercise_id', () {
        final model =
            ChatMessageModel.fromJson(appMessageWithExerciseJson);

        expect(model.id, 'msg-2');
        expect(model.sender, MessageSender.app);
        expect(model.suggestedExerciseId, 'exercise-breathing-101');
        expect(model.content,
            'Try this breathing exercise to calm down.');
      });

      test(
          'should parse an app message without suggested_exercise_id',
          () {
        final model =
            ChatMessageModel.fromJson(appMessageWithoutExerciseJson);

        expect(model.sender, MessageSender.app);
        expect(model.suggestedExerciseId, isNull);
      });

      test('should default to app sender for unknown sender values', () {
        final json = Map<String, dynamic>.from(userMessageJson)
          ..['sender'] = 'unknown_sender';

        final model = ChatMessageModel.fromJson(json);

        expect(model.sender, MessageSender.app);
      });

      test(
          'should handle missing suggested_exercise_id key gracefully',
          () {
        final json = Map<String, dynamic>.from(userMessageJson)
          ..remove('suggested_exercise_id');

        final model = ChatMessageModel.fromJson(json);

        expect(model.suggestedExerciseId, isNull);
      });
    });

    group('toJson', () {
      test('should serialize a user message to JSON', () {
        final model = ChatMessageModel(
          id: 'msg-1',
          chatId: 'chat-abc',
          sender: MessageSender.user,
          content: 'Hello',
          createdAt: createdAt,
        );

        final json = model.toJson();

        expect(json['id'], 'msg-1');
        expect(json['chat_id'], 'chat-abc');
        expect(json['sender'], 'user');
        expect(json['content'], 'Hello');
        expect(json['suggested_exercise_id'], isNull);
        expect(json['created_at'], createdAt.toIso8601String());
      });

      test('should serialize an app message with exercise id', () {
        final model = ChatMessageModel(
          id: 'msg-2',
          chatId: 'chat-abc',
          sender: MessageSender.app,
          content: 'Try breathing.',
          suggestedExerciseId: 'ex-1',
          createdAt: createdAt,
        );

        final json = model.toJson();

        expect(json['sender'], 'app');
        expect(json['suggested_exercise_id'], 'ex-1');
      });
    });

    group('roundtrip', () {
      test(
          'fromJson → toJson should preserve all fields for user message',
          () {
        final model = ChatMessageModel.fromJson(userMessageJson);
        final output = model.toJson();

        expect(output['id'], userMessageJson['id']);
        expect(output['chat_id'], userMessageJson['chat_id']);
        expect(output['sender'], userMessageJson['sender']);
        expect(output['content'], userMessageJson['content']);
        expect(output['suggested_exercise_id'],
            userMessageJson['suggested_exercise_id']);
      });

      test(
          'fromJson → toJson should preserve suggested_exercise_id for app message',
          () {
        final model =
            ChatMessageModel.fromJson(appMessageWithExerciseJson);
        final output = model.toJson();

        expect(output['suggested_exercise_id'],
            'exercise-breathing-101');
      });
    });

    test('should be a subtype of ChatMessageEntity', () {
      final model = ChatMessageModel.fromJson(userMessageJson);
      expect(model, isA<ChatMessageEntity>());
    });
  });
}
