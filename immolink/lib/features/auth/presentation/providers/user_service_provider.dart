import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});