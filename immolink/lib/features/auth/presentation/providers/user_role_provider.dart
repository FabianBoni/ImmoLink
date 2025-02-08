import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userRoleProvider = StateNotifierProvider<UserRoleNotifier, String>((ref) {
  return UserRoleNotifier();
});

class UserRoleNotifier extends StateNotifier<String> {
  UserRoleNotifier() : super('') {
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole') ?? '';
    state = role;
  }

  Future<void> setUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role);
    state = role;
  }
}