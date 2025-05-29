import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:immolink/features/maintenance/domain/models/maintenance_request.dart';
import 'package:immolink/core/config/db_config.dart';

class MaintenanceService {
  final String _apiUrl = DbConfig.apiUrl;

  Future<List<MaintenanceRequest>> getMaintenanceRequestsByTenant(String tenantId) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/maintenance/tenant/$tenantId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => MaintenanceRequest.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load maintenance requests');
    }
  }

  Future<List<MaintenanceRequest>> getMaintenanceRequestsByProperty(String propertyId) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/maintenance/property/$propertyId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => MaintenanceRequest.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load maintenance requests');
    }
  }

  Future<List<MaintenanceRequest>> getMaintenanceRequestsByLandlord(String landlordId) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/maintenance/landlord/$landlordId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => MaintenanceRequest.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load maintenance requests');
    }
  }

  Future<MaintenanceRequest> getMaintenanceRequestById(String id) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/maintenance/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MaintenanceRequest.fromMap(data);
    } else {
      throw Exception('Failed to load maintenance request');
    }
  }

  Future<MaintenanceRequest> createMaintenanceRequest(MaintenanceRequest request) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/maintenance'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toMap()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return MaintenanceRequest.fromMap(data);
    } else {
      throw Exception('Failed to create maintenance request');
    }
  }

  Future<MaintenanceRequest> updateMaintenanceRequest(MaintenanceRequest request) async {
    final response = await http.put(
      Uri.parse('$_apiUrl/maintenance/${request.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toMap()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MaintenanceRequest.fromMap(data);
    } else {
      throw Exception('Failed to update maintenance request');
    }
  }

  Future<void> deleteMaintenanceRequest(String id) async {
    final response = await http.delete(
      Uri.parse('$_apiUrl/maintenance/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete maintenance request');
    }
  }
}
