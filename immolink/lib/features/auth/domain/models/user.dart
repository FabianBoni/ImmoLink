import 'package:immolink/features/property/domain/models/property.dart';
import 'package:mongo_dart/mongo_dart.dart';

class User {
  final ObjectId id;
  final String email;
  final String fullName;
  final DateTime birthDate;
  final String role;
  final bool isAdmin;
  final bool isValidated;
  final Address address;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.birthDate,
    required this.role,
    required this.isAdmin,
    required this.isValidated,
    required this.address,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] as ObjectId,  // MongoDB uses _id
      email: map['email'],
      fullName: map['fullName'],
      birthDate: DateTime.parse(map['birthDate']),
      role: map['role'],
      isAdmin: map['isAdmin'],
      isValidated: map['isValidated'],
      address: Address.fromMap(map['address']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,  // MongoDB format
      'email': email,
      'fullName': fullName,
      'birthDate': birthDate.toIso8601String(),
      'role': role,
      'isAdmin': isAdmin,
      'isValidated': isValidated,
      'address': address.toMap(),
    };
  }
}