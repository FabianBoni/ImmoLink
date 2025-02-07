import 'package:mongo_dart/mongo_dart.dart';
import '../../../../core/services/database_service.dart';
import '../models/user_model.dart';

class UserRepository {
  static const String collectionName = 'users';
  final _db = DatabaseService.instance;

  Future<void> createUser(UserModel user) async {
    await _db.query(collectionName, user.toMap());
  }

  Future<UserModel?> getUser(ObjectId id) async {
    final map = await _db.query(collectionName, where.id(id).map);
    return map != null ? UserModel.fromMap(map) : null;
  }
}
