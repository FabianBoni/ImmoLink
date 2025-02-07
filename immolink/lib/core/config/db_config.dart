import 'package:flutter_dotenv/flutter_dotenv.dart';

class DbConfig {
  static String get connectionUri => dotenv.env['MONGODB_URI'] ?? '';
  static String get dbName => dotenv.env['MONGODB_DB_NAME'] ?? '';
  static String get apiUrl => dotenv.env['API_URL'] ?? '';
}