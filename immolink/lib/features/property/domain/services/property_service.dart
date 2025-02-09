import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/property.dart';
import 'package:immolink/core/config/db_config.dart';

class PropertyService {
  final String _apiUrl = DbConfig.apiUrl;

  Future<void> addProperty(Property property) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/properties'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(property.toMap()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add property');
    }
  }

  Stream<List<Property>> getLandlordProperties(String landlordId) async* {
    final response = await http.get(
      Uri.parse('$_apiUrl/properties/landlord/$landlordId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      yield data.map((json) => Property.fromMap(json)).toList();
    }
  }

  Stream<List<Property>> getAllProperties() async* {
    final response = await http.get(
      Uri.parse('$_apiUrl/properties'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      yield data.map((json) => Property.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load properties');
    }
  }
}