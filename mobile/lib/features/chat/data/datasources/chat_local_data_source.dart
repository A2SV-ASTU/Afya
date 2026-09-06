import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_keys.dart';
import '../models/chat_message_model.dart';

abstract class ChatLocalDataSource {
  Future<List<ChatMessageModel>> getChatHistory();
  Future<void> saveMessage(ChatMessageModel message);
  Future<void> clearHistory();
}

@LazySingleton(as: ChatLocalDataSource)
class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  Box get _box => Hive.box(AppKeys.chatHistoryBox);

  @override
  Future<List<ChatMessageModel>> getChatHistory() async {
    final rawList = _box.values.toList();
    final List<ChatMessageModel> messages = [];

    for (final item in rawList) {
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        messages.add(ChatMessageModel.fromJson(map));
      }
    }

    // Sort chronologically by timestamp
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  @override
  Future<void> saveMessage(ChatMessageModel message) async {
    await _box.put(message.id, message.toJson());
  }

  @override
  Future<void> clearHistory() async {
    await _box.clear();
  }
}
