import 'package:mongo_dart/mongo_dart.dart';
import '../config/db_config.dart';
import 'package:logging/logging.dart';

class DatabaseService {
  static Db? _db;
  static final _log = Logger('DatabaseService');
  
  static Future<void> connect() async {
    try {
      _db = await Db.create(DbConfig.connectionUri);
      await _db!.open();
      _log.info('Connected to MongoDB!');
    } catch (e) {
      _log.severe('Error connecting to MongoDB: $e');
      rethrow; // Allow caller to handle the error
    }
  }

  static Db? get database => _db;
  
  static Future<void> disconnect() async {
    await _db?.close();
    _log.info('Disconnected from MongoDB');
  }
}