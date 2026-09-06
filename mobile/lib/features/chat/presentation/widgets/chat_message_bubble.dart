import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../domain/entities/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final textColor = isUser
        ? Colors.white
        : message.isError
            ? const Color(0xFFBA1A1A)
            : const Color(0xFF1E2825);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // Small AI Avatar Icon
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFA2C7BB),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.eco_rounded,
                  size: 18,
                  color: Color(0xFF0C554B),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF0C554B) // Dark teal for user bubble
                    : message.isError
                        ? const Color(0xFFFFDAD6)
                        : Colors.white, // Clean white for AI bubble
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: MarkdownBody(
                data: message.content,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: textColor,
                  ),
                  strong: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  h1: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: isUser ? Colors.white : const Color(0xFF0C554B),
                  ),
                  h2: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: isUser ? Colors.white : const Color(0xFF0C554B),
                  ),
                  h3: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: isUser ? Colors.white : const Color(0xFF0C554B),
                  ),
                  h4: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: textColor,
                  ),
                  listBullet: TextStyle(
                    fontSize: 15,
                    color: textColor,
                  ),
                  em: TextStyle(
                    fontSize: 14.5,
                    fontStyle: FontStyle.italic,
                    color: textColor,
                  ),
                  blockquotePadding: const EdgeInsets.all(8),
                  blockquoteDecoration: BoxDecoration(
                    color: isUser
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFEBF5F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  blockSpacing: 8.0,
                  listIndent: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
