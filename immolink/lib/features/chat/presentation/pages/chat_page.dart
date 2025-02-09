import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/features/auth/presentation/providers/auth_provider.dart';
import 'package:immolink/features/chat/domain/models/chat_message.dart';
import 'package:immolink/features/chat/presentation/providers/chat_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          widget.otherUserName,
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 1,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          image: DecorationImage(
            image: const AssetImage('assets/images/chat_bg.png'),
            opacity: 0.1,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: messagesStream.when(
                data: (messages) => ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _handleAttachment,
            color: Theme.of(context).primaryColor,
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _handleImagePicker,
            color: Theme.of(context).primaryColor,
          ),
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
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: _handleVoiceMemo,
            color: Theme.of(context).primaryColor,
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  void _handleAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null) {
      // Handle file upload
    }
  }

  void _handleImagePicker() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Handle image upload
    }
  }

  void _handleVoiceMemo() {
    // Implement voice memo recording
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
