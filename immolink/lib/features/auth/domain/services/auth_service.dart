import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:immolink/core/config/db_config.dart';

class AuthService {
  final String _apiUrl = DbConfig.apiUrl;

  Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthDate,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
          'fullName': fullName,
          'birthDate': birthDate.toIso8601String(),
          'role': role,
          'isAdmin': false,
          'isValidated': false,
          'address': {
            'street': '',
            'city': '',
            'postalCode': '',
            'country': ''
          }
        }),
      );

      if (response.statusCode >= 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Registration failed');
      }

      if (response.statusCode != 201) {
        throw Exception('Unexpected response from server');
      }

      final responseData = json.decode(response.body);
      if (!responseData.containsKey('userId')) {
        throw Exception('Invalid server response');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Network error: Unable to connect to server');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body)['message'] ?? 'Login failed';
      throw Exception(error);
    }

    return json.decode(response.body);
  }
}