import 'package:flutter_dotenv/flutter_dotenv.dart';

class DbConfig {
  static String get connectionUri => dotenv.env['MONGODB_URI'] ?? 'mongodb://localhost:27017';
  static String get dbName => dotenv.env['MONGODB_DB_NAME'] ?? 'immolink';
  static String get apiUrl => dotenv.env['API_URL'] ?? 'http://localhost:3000/api';
  
  static void printConfig() {
    print('DbConfig loaded:');
    print('  connectionUri: $connectionUri');
    print('  dbName: $dbName');
    print('  apiUrl: $apiUrl');
    print('  env loaded: ${dotenv.env.isNotEmpty}');
  }
}
