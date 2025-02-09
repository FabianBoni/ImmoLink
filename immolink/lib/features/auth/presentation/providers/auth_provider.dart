import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/features/auth/domain/models/user.dart';
import 'package:immolink/features/auth/domain/services/auth_service.dart';
import 'package:immolink/features/auth/presentation/providers/register_provider.dart';
import 'package:immolink/features/auth/presentation/providers/user_role_provider.dart';
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

final currentUserProvider = StateProvider<User?>((ref) => null);

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(userRoleProvider.notifier),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final UserRoleNotifier _userRoleNotifier;

  AuthNotifier(this._authService, this._userRoleNotifier) 
      : super(AuthState.initial());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final userData = await _authService.loginUser(
        email: email,
        password: password,
      );
      
      await _userRoleNotifier.setUserRole(userData['role']);
      
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthDate,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.registerUser(
        email: email,
        password: password,
        fullName: fullName,
        birthDate: birthDate,
        role: role,
      );
      
      // After registration, perform login
      await login(email, password);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      state = AuthState.initial();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> checkAuthState() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: userId != null,
        userId: userId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }
}