import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/features/auth/domain/models/user.dart';
import 'package:immolink/features/auth/domain/services/auth_service.dart';
import 'package:immolink/features/auth/presentation/providers/user_role_provider.dart';
import 'package:immolink/features/property/domain/models/property.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? userId;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.error,
    this.userId,
  });

  factory AuthState.initial() {
    return AuthState(isAuthenticated: false, isLoading: false);
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    String? userId,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userId: userId ?? this.userId,
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final currentUserProvider = StateProvider<User?>((ref) {
  print('Initializing currentUserProvider');
  return null;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref ref;

  AuthNotifier(this._authService, this.ref) : super(AuthState.initial()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    print('Restoring auth session');
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      ref.read(currentUserProvider.notifier).state = User(
          id: ObjectId.fromHexString(userId),
          email: prefs.getString('email') ?? '',
          role: prefs.getString('role') ?? '',
          fullName: prefs.getString('fullName') ?? '',
          birthDate: DateTime.now(),
          isAdmin: false,
          isValidated: true,
          address: Address(street: '', city: '', postalCode: '', country: ''));

      state = state.copyWith(isAuthenticated: true, userId: userId);
    }
  }

  Future<void> login(String email, String password) async {
    print('Starting login process for email: $email');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userData =
          await _authService.loginUser(email: email, password: password);
      print('Received user data: $userData');

      // Convert string ID to ObjectId
      final userId = ObjectId.fromHexString(userData['userId']);

      // Store data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString('userId', userData['userId']),
        prefs.setString('authToken', userData['token']),
        prefs.setString('email', userData['email']),
        prefs.setString('userRole', userData['role']),
        prefs.setString('fullName', userData['fullName'])
      ]);

      // Update userRoleProvider with proper ID type
      ref.read(userRoleProvider.notifier).setUserRole(userData['role']);
      print('User role set to: ${userData['role']}');

      // Update currentUserProvider with converted ObjectId
      ref.read(currentUserProvider.notifier).state = User(
          id: userId, // Now using ObjectId instead of String
          email: userData['email'],
          role: userData['role'],
          fullName: userData['fullName'],
          birthDate: DateTime.now(),
          isAdmin: false,
          isValidated: true,
          address: Address(street: '', city: '', postalCode: '', country: ''));
      print('User provider updated');

      state = state.copyWith(
          isLoading: false, isAuthenticated: true, userId: userData['userId']);
      print('Auth state updated');
    } catch (e) {
      print('Login error: $e');
      state = state.copyWith(
          isLoading: false, error: e.toString(), isAuthenticated: false);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      ref.read(currentUserProvider.notifier).state = null;
      state = AuthState.initial();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  print('Initializing AuthNotifier with service');
  return AuthNotifier(authService, ref);
});
