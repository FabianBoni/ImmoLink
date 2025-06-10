import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/services/chat_service.dart';

// Provider for chat service
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

// StateNotifier for managing chat messages
class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final ChatService _chatService;
  final String _conversationId;

  ChatMessagesNotifier(this._chatService, this._conversationId) 
      : super(const AsyncValue.loading()) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {    try {
      final messages = await _chatService.getMessages(_conversationId);
      state = AsyncValue.data(messages.reversed.toList()); // Reverse to show newest at bottom
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    try {
      await _chatService.sendMessage(
        conversationId: _conversationId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
      );
        // Refresh messages after sending
      await _loadMessages();
    } catch (error, _) {
      // Handle error but don't change the state to error
      // as we still want to show existing messages
      print('Error sending message: $error');
      rethrow;
    }
  }

  void refresh() {
    _loadMessages();
  }
}

// Provider factory for chat messages
final conversationMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, AsyncValue<List<ChatMessage>>, String>((ref, conversationId) {
  final chatService = ref.watch(chatServiceProvider);
  return ChatMessagesNotifier(chatService, conversationId);
});

// Provider for sending messages
class MessageSenderNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  MessageSenderNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _ref.read(conversationMessagesProvider(conversationId).notifier)
          .sendMessage(
            senderId: senderId,
            receiverId: receiverId,
            content: content,
          );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final messageSenderProvider = StateNotifierProvider<MessageSenderNotifier, AsyncValue<void>>((ref) {
  return MessageSenderNotifier(ref);
});
