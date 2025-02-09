class PropertyDetails {
  final double size;
  final int rooms;
  final List<String> amenities;

  PropertyDetails({
    required this.size,
    required this.rooms,
    required this.amenities,
  });

  Map<String, dynamic> toMap() {
    return {
      'size': size,
      'rooms': rooms,
      'amenities': amenities,
    };
  }

  factory PropertyDetails.fromMap(Map<String, dynamic> map) {
    return PropertyDetails(
      size: map['size'],
      rooms: map['rooms'],
      amenities: List<String>.from(map['amenities']),
    );
  }
}
