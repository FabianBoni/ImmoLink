import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/property.dart';
import 'package:immolink/core/config/db_config.dart';
import '../../../chat/domain/services/chat_service.dart';

class PropertyService {
  final String _apiUrl = DbConfig.apiUrl;

  Future<void> addProperty(Property property) async {
    final prefs = await SharedPreferences.getInstance();

    // Debug session state
    print('Session variables:');
    print('userId: ${prefs.getString('userId')}');
    print('authToken: ${prefs.getString('authToken')}');
    print('userRole: ${prefs.getString('userRole')}');
    print('email: ${prefs.getString('email')}');

    final userId = prefs.getString('userId') ??
        (throw Exception('User not authenticated'));

    final propertyData = {
      ...property.toMap(),
      'landlordId': userId,
    };

    print('Property data to send: ${json.encode(propertyData)}');

    // Continue with property creation...
    final response = await http.post(
      Uri.parse('$_apiUrl/properties'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(propertyData),
    );

    if (response.statusCode != 201) {
      print('Server response: ${response.body}');
      throw Exception('Failed to add property: ${response.statusCode}');
    }
  }
  Future<void> inviteTenant(String propertyId, String tenantId) async {
    final prefs = await SharedPreferences.getInstance();
    final landlordId = prefs.getString('userId');

    if (landlordId == null) {
      throw Exception('User not authenticated');
    }

    // Use the chat service to send invitation and create conversation
    final chatService = ChatService();
    
    try {
      await chatService.inviteTenant(
        propertyId: propertyId,
        landlordId: landlordId,
        tenantId: tenantId,
        message: 'Hello! I would like to invite you to rent my property. Please let me know if you are interested.',
      );
      
      print('Invitation sent successfully to tenant $tenantId for property $propertyId');
    } catch (e) {
      print('Error sending invitation: $e');
      throw Exception('Failed to send invitation: $e');
    }
  }

  Stream<List<Property>> getLandlordProperties(String landlordId) async* {
    final idString =
        landlordId.toString().replaceAll('ObjectId("', '').replaceAll('")', '');

    final response = await http.get(
      Uri.parse('$_apiUrl/properties/landlord/$idString'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> properties = responseData['properties'];
      print('Found ${properties.length} properties');
      yield properties.map((json) => Property.fromMap(json)).toList();
    }
  }

  Stream<List<Property>> getTenantProperties(String tenantId) async* {
    final idString =
        tenantId.toString().replaceAll('ObjectId("', '').replaceAll('")', '');

    final response = await http.get(
      Uri.parse('$_apiUrl/properties/tenant/$idString'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> properties = responseData['properties'];
      print('Found ${properties.length} properties for tenant');
      yield properties.map((json) => Property.fromMap(json)).toList();
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

  Stream<Property> getPropertyById(String propertyId) async* {
    print('Fetching property with ID: $propertyId');

    final response = await http.get(
      Uri.parse('$_apiUrl/properties/$propertyId'),
      headers: {'Content-Type': 'application/json'},
    );

    print('API Response status: ${response.statusCode}');
    print('API Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      yield Property.fromMap(data);
    } else {
      throw Exception(
          'Failed to load property details: ${response.statusCode}');
    }
  }

  // Future-based method for tenant dashboard
  Future<List<Property>> getAllPropertiesFuture() async {
    final response = await http.get(
      Uri.parse('$_apiUrl/properties'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Property.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load properties');
    }
  }

  Future<void> updateProperty(Property property) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ??
        (throw Exception('User not authenticated'));

    final propertyData = {
      ...property.toMap(),
      'landlordId': userId,
    };

    print('Updating property: ${property.id}');
    print('Property data to send: ${json.encode(propertyData)}');

    final response = await http.put(
      Uri.parse('$_apiUrl/properties/${property.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(propertyData),
    );

    if (response.statusCode != 200) {
      print('Server response: ${response.body}');
      throw Exception('Failed to update property: ${response.statusCode}');
    }
  }
}

