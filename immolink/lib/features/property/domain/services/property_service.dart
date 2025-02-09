import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/config/db_config.dart';
import '../../../auth/domain/models/user.dart';
import '../models/property.dart';

class PropertyService {
  final String _apiUrl = DbConfig.apiUrl;

  Future<List<Property>> getPropertiesForLandlord(String landlordId) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/properties/landlord/$landlordId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Property.fromMap(json)).toList();
    }
    throw Exception('Failed to load properties');
  }

  Future<List<User>> getTenantsForProperty(String propertyId) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/properties/$propertyId/tenants'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromMap(json)).toList();
    }
    throw Exception('Failed to load tenants');
  }
}