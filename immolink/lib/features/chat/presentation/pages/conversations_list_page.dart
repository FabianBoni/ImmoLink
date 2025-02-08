import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/conversations_provider.dart';
import '../../domain/models/conversation.dart';

class ConversationsListPage extends ConsumerWidget {
  const ConversationsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ref.watch(conversationsProvider).when(
            data: (conversations) => ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) => _buildConversationTile(
                context,
                conversations[index],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
    );
  }

  Widget _buildConversationTile(BuildContext context, Conversation conversation) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(conversation.otherUserName[0].toUpperCase()),
      ),
      title: Text(conversation.otherUserName),
      subtitle: Text(conversation.lastMessage ?? 'No messages yet'),
      onTap: () => context.push(
        '/chat/${conversation.id}?otherUser=${conversation.otherUserName}',
      ),
    );
  }
}
