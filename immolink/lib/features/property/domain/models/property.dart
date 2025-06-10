class Property {
  final String id;
  final String landlordId;
  final List<String> tenantIds;
  final Address address;
  final String status;
  final double rentAmount;
  final PropertyDetails details;
  final List<String> imageUrls;
  final double outstandingPayments; // Added field

  Property({
    required this.id,
    required this.landlordId,
    required this.tenantIds,
    required this.address,
    required this.status,
    required this.rentAmount,
    required this.details,
    this.imageUrls = const [],
    this.outstandingPayments = 0.0, // Default to zero
  });

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['_id'].toString(), // Convert MongoDB _id to string
      landlordId: map['landlordId'],
      address: Address.fromMap(map['address']),
      status: map['status'],
      rentAmount: map['rentAmount'].toDouble(),
      details: PropertyDetails.fromMap(map['details']),
      imageUrls: List<String>.from(map['imageUrls']),
      tenantIds: List<String>.from(map['tenantIds']),
      outstandingPayments: map['outstandingPayments'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'landlordId': landlordId,
      'tenantIds': tenantIds,
      'address': address.toMap(),
      'status': status,
      'rentAmount': rentAmount,
      'details': details.toMap(),
      'imageUrls': imageUrls,
      'outstandingPayments': outstandingPayments,
    };
  }
}

class Address {
  final String street;
  final String city;
  final String postalCode;
  final String country;

  Address({
    required this.street,
    required this.city,
    required this.postalCode,
    required this.country,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      street: map['street'],
      city: map['city'],
      postalCode: map['postalCode'],
      country: map['country'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'country': country,
    };
  }
}

class PropertyDetails {
  final double size;
  final int rooms;
  final List<String> amenities;

  PropertyDetails({
    required this.size,
    required this.rooms,
    required this.amenities,
  });

  factory PropertyDetails.fromMap(Map<String, dynamic> map) {
    return PropertyDetails(
      size: map['size'].toDouble(),
      rooms: map['rooms'],
      amenities: List<String>.from(map['amenities']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'size': size,
      'rooms': rooms,
      'amenities': amenities,
    };
  }
}

