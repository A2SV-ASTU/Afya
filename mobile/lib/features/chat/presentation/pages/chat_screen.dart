import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:mobile/features/chat/presentation/bloc/chat_event.dart';
import 'package:mobile/features/chat/presentation/bloc/chat_state.dart';
import 'package:mobile/features/chat/presentation/widgets/chat_bubble_widget.dart';
import 'package:mobile/features/chat/presentation/widgets/chat_fallback_view.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const LoadChatEvent());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final state = context.read<ChatBloc>().state;
      String chatId = '';
      if (state is ChatLoaded) {
        chatId = state.thread.id;
      } else if (state is MessageSending) {
        chatId = state.thread.id;
      }

      if (chatId.isNotEmpty) {
        context.read<ChatBloc>().add(
              SendMessageEvent(
                chatId: chatId,
                message: text,
              ),
            );
        _messageController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        title: const Row(
          children: [
            SizedBox(width: 16),
            Icon(
              Icons.energy_savings_leaf,
              color: AppColors.primary,
              size: 28,
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chat',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  "We're here with you.",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: InkWell(
                onTap: () {
                  context.go('/crisis');
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.crisisBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        CupertinoIcons.phone,
                        color: AppColors.crisis,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Crisis',
                        style: TextStyle(
                          color: AppColors.crisis,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatLoaded || state is MessageSending) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
          }
        },
        builder: (context, state) {
          if (state is ChatInitial || state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is ChatError) {
            return const ChatFallbackView();
          }

          final messages = state is ChatLoaded
              ? state.messages
              : (state as MessageSending).messages;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ChatBubbleWidget(message: message);
                  },
                ),
              ),
              _buildInputBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: AppColors.textDisabled),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
