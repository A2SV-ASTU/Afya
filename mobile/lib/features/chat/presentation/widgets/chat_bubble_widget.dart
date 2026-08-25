import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/chat/domain/entities/chat_message_entity.dart';
import 'package:mobile/features/chat/presentation/widgets/suggested_exercise_card.dart';

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessageEntity message;

  const ChatBubbleWidget({
    super.key,
    required this.message,
  });

  String _formatTime(DateTime time) {
    final int hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.sender == MessageSender.user;
    final String timeFormatted = _formatTime(message.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary : AppColors.chatBubbleApp,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16.0),
                topRight: const Radius.circular(16.0),
                bottomLeft: isUser ? const Radius.circular(16.0) : const Radius.circular(4.0),
                bottomRight: isUser ? const Radius.circular(4.0) : const Radius.circular(16.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isUser ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  timeFormatted,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: isUser ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (message.suggestedExerciseId != null && !isUser) ...[
            const SizedBox(height: 4.0),
            SuggestedExerciseCard(exerciseId: message.suggestedExerciseId!),
          ],
        ],
      ),
    );
  }
}
