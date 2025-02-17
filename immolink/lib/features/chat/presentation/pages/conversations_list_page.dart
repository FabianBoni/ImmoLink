import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/conversations_provider.dart';
import '../../domain/models/conversation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ConversationsListPage extends ConsumerWidget {
  const ConversationsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: conversationsAsync.when(
        data: (conversations) => ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            final isLandlord = currentUser?.role == 'landlord';
            final otherUserId = isLandlord 
                ? conversation.tenantId 
                : conversation.landlordId;
            
            return _buildConversationTile(
              context,
              conversation,
              otherUserId,
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context, 
    Conversation conversation,
    String otherUserId,
  ) {
    return ListTile(
      leading: CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text('Property: ${conversation.propertyAddress}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(conversation.lastMessage),
          Text(
            conversation.lastMessageTime.toString(),
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      onTap: () => context.push(
        '/chat/${conversation.id}?otherUserId=$otherUserId',
      ),
    );
  }
}