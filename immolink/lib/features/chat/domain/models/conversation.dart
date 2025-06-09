class Conversation {
  final String id;
  final String propertyId;
  final String landlordId;
  final String tenantId;
  final String propertyAddress;
  final String lastMessage;
  final DateTime lastMessageTime;

  Conversation({
    required this.id,
    required this.propertyId,
    required this.landlordId,
    required this.tenantId,
    required this.propertyAddress,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['_id'],
      propertyId: map['propertyId'],
      landlordId: map['landlordId'],
      tenantId: map['tenantId'],
      propertyAddress: map['propertyAddress'],
      lastMessage: map['lastMessage'],
      lastMessageTime: DateTime.parse(map['lastMessageTime']),
    );
  }
}
