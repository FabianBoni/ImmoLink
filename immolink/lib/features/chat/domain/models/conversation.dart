class Conversation {
  final String id;
  final String propertyId;
  final String landlordId;
  final String tenantId;
  final String propertyAddress;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? landlordName;
  final String? tenantName;
  final String? relatedInvitationId;

  Conversation({
    required this.id,
    required this.propertyId,
    required this.landlordId,
    required this.tenantId,
    required this.propertyAddress,
    required this.lastMessage,
    required this.lastMessageTime,
    this.landlordName,
    this.tenantName,
    this.relatedInvitationId,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      propertyId: map['propertyId'] ?? '',
      landlordId: map['landlordId'] ?? '',
      tenantId: map['tenantId'] ?? '',
      propertyAddress: map['propertyAddress'] ?? 'Unknown Property',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null 
          ? DateTime.parse(map['lastMessageTime'])
          : DateTime.now(),
      landlordName: map['landlordName'],
      tenantName: map['tenantName'],
      relatedInvitationId: map['relatedInvitationId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyId': propertyId,
      'landlordId': landlordId,
      'tenantId': tenantId,
      'propertyAddress': propertyAddress,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'landlordName': landlordName,
      'tenantName': tenantName,
      'relatedInvitationId': relatedInvitationId,
    };
  }

  @override
  String toString() {
    return 'Conversation(id: $id, propertyAddress: $propertyAddress, lastMessage: $lastMessage)';
  }
}
