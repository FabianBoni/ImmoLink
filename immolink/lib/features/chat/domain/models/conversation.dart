class Conversation {
  final String id;
  final String otherUserName;
  final String? lastMessage;
  final DateTime lastMessageTime;

  Conversation({
    required this.id,
    required this.otherUserName,
    this.lastMessage,
    required this.lastMessageTime,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'],
      otherUserName: map['otherUserName'],
      lastMessage: map['lastMessage'],
      lastMessageTime: DateTime.parse(map['lastMessageTime']),
    );
  }
}