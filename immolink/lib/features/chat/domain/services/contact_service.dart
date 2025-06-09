import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:immolink/core/config/db_config.dart';
import '../models/contact_user.dart';

class ContactService {
  final String _apiUrl = DbConfig.apiUrl;

  /// Get contacts for the current user based on their role
  /// Landlords get their tenants, tenants get their landlords
  Future<List<ContactUser>> getContactsForUser({
    required String userId,
    required String userRole,
  }) async {
    try {
      String endpoint;
      if (userRole == 'landlord') {
        // Get tenants for this landlord
        endpoint = '$_apiUrl/contacts/landlord/$userId/tenants';
      } else {
        // Get landlords for this tenant
        endpoint = '$_apiUrl/contacts/tenant/$userId/landlords';
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ContactUser.fromMap(json)).toList();
      } else {
        print('Failed to load contacts: ${response.statusCode}');
        // Return mock data as fallback
        return _getMockContacts(userRole);
      }
    } catch (e) {
      print('Network error in getContactsForUser: $e');
      // Return mock data as fallback when offline
      return _getMockContacts(userRole);
    }
  }
  /// Get all users (for admin or general contact list)
  Future<List<ContactUser>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ContactUser.fromMap(json)).toList();
      } else {
        print('Failed to load users: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Network error in getAllUsers: $e');
      return [];
    }
  }

  /// Get all tenants from the database
  Future<List<ContactUser>> getAllTenants() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/users/tenants'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ContactUser.fromMap(json)).toList();
      } else {
        print('Failed to load tenants: ${response.statusCode}');
        // Return mock data as fallback
        return _getMockTenants();
      }
    } catch (e) {
      print('Network error in getAllTenants: $e');
      // Return mock data as fallback when offline
      return _getMockTenants();
    }
  }
  /// Fallback mock data when API is unavailable
  List<ContactUser> _getMockContacts(String userRole) {
    if (userRole == 'landlord') {
      // Return tenants for landlords
      return [
        ContactUser(
          id: '2',
          fullName: 'Emma Weber',
          email: 'emma.weber@email.com',
          role: 'tenant',
          phone: '+41 79 234 56 78',
          properties: ['Seestrasse 456, Geneva'],
        ),
        ContactUser(
          id: '3',
          fullName: 'Mike Johnson',
          email: 'mike.johnson@email.com',
          role: 'tenant',
          phone: '+41 79 345 67 89',
          properties: ['Hauptstrasse 789, Basel'],
        ),
        ContactUser(
          id: '4',
          fullName: 'Sarah Wilson',
          email: 'sarah.wilson@email.com',
          role: 'tenant',
          phone: '+41 79 456 78 90',
          properties: ['Kirchgasse 101, Bern'],
        ),
      ];
    } else {
      // Return landlords for tenants
      return [
        ContactUser(
          id: '101',
          fullName: 'Robert Mueller',
          email: 'robert.mueller@properties.com',
          role: 'landlord',
          phone: '+41 44 123 45 67',
          properties: ['Multiple Properties Manager'],
        ),
        ContactUser(
          id: '102',
          fullName: 'Anna Schneider',
          email: 'anna.schneider@realestate.com',
          role: 'landlord',
          phone: '+41 44 234 56 78',
          properties: ['Property Owner & Manager'],
        ),
      ];
    }
  }

  /// Mock tenant data for fallback
  List<ContactUser> _getMockTenants() {
    return [
      ContactUser(
        id: '2',
        fullName: 'Emma Weber',
        email: 'emma.weber@email.com',
        role: 'tenant',
        phone: '+41 79 234 56 78',
        properties: ['Seestrasse 456, Geneva'],
      ),
      ContactUser(
        id: '3',
        fullName: 'Mike Johnson',
        email: 'mike.johnson@email.com',
        role: 'tenant',
        phone: '+41 79 345 67 89',
        properties: ['Hauptstrasse 789, Basel'],
      ),
      ContactUser(
        id: '4',
        fullName: 'Sarah Wilson',
        email: 'sarah.wilson@email.com',
        role: 'tenant',
        phone: '+41 79 456 78 90',
        properties: ['Kirchgasse 101, Bern'],
      ),
      ContactUser(
        id: '5',
        fullName: 'David Brown',
        email: 'david.brown@email.com',
        role: 'tenant',
        phone: '+41 79 567 89 01',
        properties: ['Bahnhofstrasse 123, Zurich'],
      ),
      ContactUser(
        id: '6',
        fullName: 'Lisa Martinez',
        email: 'lisa.martinez@email.com',
        role: 'tenant',
        phone: '+41 79 678 90 12',
        properties: ['Steinengraben 45, Basel'],
      ),
      ContactUser(
        id: '7',
        fullName: 'Tom Anderson',
        email: 'tom.anderson@email.com',
        role: 'tenant',
        phone: '+41 79 789 01 23',
        properties: [],
      ),
    ];
  }
}
