import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:immolink/core/config/db_config.dart';
import 'package:immolink/features/chat/domain/models/chat_message.dart';
import 'package:immolink/features/chat/domain/models/conversation.dart';

class ChatService {
  final String _apiUrl = DbConfig.apiUrl;

  Future<List<Conversation>> getConversations() async {
    final response = await http.get(
      Uri.parse('$_apiUrl/chat/conversations'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Conversation.fromMap(json)).toList();
    }
    throw Exception('Failed to load conversations');
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/chat/$conversationId/messages'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChatMessage.fromMap(json)).toList();
    }
    throw Exception('Failed to load messages');
  }

  Future<void> sendMessage(ChatMessage message, String conversationId) async {
    await http.post(
      Uri.parse('$_apiUrl/chat/$conversationId/messages'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(message.toMap()),
    );
  }
}