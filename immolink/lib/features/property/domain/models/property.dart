class Property {
  final String id;
  final String landlordId;
  final List<String> tenantIds;
  final Address address;
  final String status;
  final double rentAmount;
  final PropertyDetails details;

  Property({
    required this.id,
    required this.landlordId,
    required this.tenantIds,
    required this.address,
    required this.status,
    required this.rentAmount,
    required this.details,
  });

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'],
      landlordId: map['landlordId'],
      tenantIds: List<String>.from(map['tenantIds']),
      address: Address.fromMap(map['address']),
      status: map['status'],
      rentAmount: map['rentAmount'].toDouble(),
      details: PropertyDetails.fromMap(map['details']),
    );
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
}