import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/features/auth/presentation/providers/auth_provider.dart';
import 'package:immolink/features/chat/domain/models/chat_message.dart';
import 'package:immolink/features/chat/presentation/providers/chat_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String conversationId;
  final String otherUserName;

  const ChatPage({
    required this.conversationId,
    required this.otherUserName,
    super.key,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final messagesStream = ref.watch(
      chatMessagesProvider(widget.conversationId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesStream.when(
              data: (messages) => ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) => _buildMessageBubble(
                  messages[index],
                ),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isCurrentUser = message.senderId == ref.read(authProvider).userId;
    
    return Align(
      alignment: isCurrentUser 
          ? Alignment.centerRight 
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isCurrentUser 
              ? Theme.of(context).primaryColor 
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isCurrentUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().toString(),
      senderId: ref.read(authProvider).userId!,
      receiverId: widget.otherUserName,
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    ref.read(chatServiceProvider).sendMessage(
          message,
          widget.conversationId,
        );

    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
