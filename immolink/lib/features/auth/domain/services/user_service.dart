import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:immolink/core/config/db_config.dart';
import '../models/user.dart';

class UserService {
  final String _apiUrl = DbConfig.apiUrl;

  Stream<List<User>> getAvailableTenants() async* {
    print('Fetching available tenants');
    final response = await http.get(
      Uri.parse('$_apiUrl/users/available-tenants'),
      headers: {'Content-Type': 'application/json'},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final tenants = data.map((json) => User.fromMap(json)).toList();
      print('Found ${tenants.length} available tenants');
      yield tenants;
    }
  }
}
