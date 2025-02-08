import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/features/chat/domain/models/conversation.dart';
import 'package:immolink/features/chat/presentation/providers/chat_provider.dart';

final conversationsProvider = StreamProvider<List<Conversation>>((ref) async* {
  final chatService = ref.read(chatServiceProvider);
  
  while (true) {
    try {
      final conversations = await chatService.getConversations();
      yield conversations;
    } catch (e) {
      yield [];
    }
    await Future.delayed(const Duration(seconds: 2));
  }
});
