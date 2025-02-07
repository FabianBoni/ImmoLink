import 'dart:convert';
import 'package:http/http.dart' as http;
import 'database_interface.dart';
import 'database_exception.dart';

class WebDatabaseService implements IDatabaseService {
  final String apiBaseUrl;
  
  WebDatabaseService({required this.apiBaseUrl});

  @override
  Future<void> connect() async {
    try {
      print('Attempting to connect to: $apiBaseUrl/health');
      
      final response = await http.get(
        Uri.parse('$apiBaseUrl/health'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      );
      
      print('Health check response: ${response.statusCode}');
      print('Response body: ${response.body}');
    
      if (response.statusCode != 200) {
        throw DatabaseException('API connection failed with status: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('Network error: ${e.toString()}');
      throw DatabaseException('Connection failed: Network error - ${e.toString()}');
    } catch (e) {
      print('Unexpected error: ${e.toString()}');
      throw DatabaseException('Connection failed: ${e.toString()}');
    }
  }

  @override
  Future<void> disconnect() async => null;

  @override
  Future<dynamic> query(String collection, Map<String, dynamic> filter) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/$collection/query'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: json.encode(filter),
      );

      if (response.statusCode != 200) {
        throw DatabaseException('Query failed with status: ${response.statusCode}');
      }

      return json.decode(response.body);
    } catch (e) {
      throw DatabaseException('Query failed: ${e.toString()}');
    }
  }
}