import 'package:mongo_dart/mongo_dart.dart';
import '../../../../core/services/database_service.dart';
import '../models/user_model.dart';

class UserRepository {
  static const String collectionName = 'users';

  Future<void> createUser(UserModel user) async {
    await DatabaseService.database!
        .collection(collectionName)
        .insert(user.toMap());
  }

  Future<UserModel?> getUser(ObjectId id) async {
    final map = await DatabaseService.database!
        .collection(collectionName)
        .findOne(where.id(id));
    return map != null ? UserModel.fromMap(map) : null;
  }
}
