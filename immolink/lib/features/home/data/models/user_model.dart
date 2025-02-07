import 'package:mongo_dart/mongo_dart.dart';

class UserModel {
  final ObjectId id;
  final String email;
  final String fullName;
  final DateTime birthDate;
  final String role;
  final bool isAdmin;
  final bool isValidated;
  final Map<String, dynamic> address;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.birthDate,
    required this.role,
    required this.isAdmin,
    required this.isValidated,
    required this.address,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id'],
      email: map['email'],
      fullName: map['fullName'],
      birthDate: map['birthDate'],
      role: map['role'],
      isAdmin: map['isAdmin'],
      isValidated: map['isValidated'],
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'email': email,
      'fullName': fullName,
      'birthDate': birthDate,
      'role': role,
      'isAdmin': isAdmin,
      'isValidated': isValidated,
      'address': address,
    };
  }
}