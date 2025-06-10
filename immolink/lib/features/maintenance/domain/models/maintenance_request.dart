class MaintenanceRequest {
  final String id;
  final String propertyId;
  final String tenantId;
  final String description;
  final String status; // 'pending', 'in_progress', 'completed', 'cancelled'
  final DateTime dateCreated;
  final DateTime? dateResolved;
  final String? assignedTo; // ID of maintenance person or landlord
  final List<String>? imageUrls;
  final String? priority; // 'low', 'medium', 'high', 'emergency'
  final String? category; // 'plumbing', 'electrical', 'structural', etc.

  MaintenanceRequest({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.description,
    required this.status,
    required this.dateCreated,
    this.dateResolved,
    this.assignedTo,
    this.imageUrls,
    this.priority = 'medium',
    this.category,
  });

  factory MaintenanceRequest.fromMap(Map<String, dynamic> map) {
    return MaintenanceRequest(
      id: map['_id'].toString(),
      propertyId: map['propertyId'],
      tenantId: map['tenantId'],
      description: map['description'],
      status: map['status'],
      dateCreated: DateTime.parse(map['dateCreated']),
      dateResolved: map['dateResolved'] != null
          ? DateTime.parse(map['dateResolved'])
          : null,
      assignedTo: map['assignedTo'],
      imageUrls: map['imageUrls'] != null
          ? List<String>.from(map['imageUrls'])
          : null,
      priority: map['priority'],
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'tenantId': tenantId,
      'description': description,
      'status': status,
      'dateCreated': dateCreated.toIso8601String(),
      'dateResolved': dateResolved?.toIso8601String(),
      'assignedTo': assignedTo,
      'imageUrls': imageUrls,
      'priority': priority,
      'category': category,
    };
  }

  MaintenanceRequest copyWith({
    String? id,
    String? propertyId,
    String? tenantId,
    String? description,
    String? status,
    DateTime? dateCreated,
    DateTime? dateResolved,
    String? assignedTo,
    List<String>? imageUrls,
    String? priority,
    String? category,
  }) {
    return MaintenanceRequest(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      tenantId: tenantId ?? this.tenantId,
      description: description ?? this.description,
      status: status ?? this.status,
      dateCreated: dateCreated ?? this.dateCreated,
      dateResolved: dateResolved ?? this.dateResolved,
      assignedTo: assignedTo ?? this.assignedTo,
      imageUrls: imageUrls ?? this.imageUrls,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }
}

