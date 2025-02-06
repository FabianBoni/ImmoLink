import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    try {
      // Implement login logic
      state = AuthState.authenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.error,
  });

  factory AuthState.initial() {
    return AuthState(isAuthenticated: false, isLoading: false);
  }

  factory AuthState.loading() {
    return AuthState(isAuthenticated: false, isLoading: true);
  }

  factory AuthState.authenticated() {
    return AuthState(isAuthenticated: true, isLoading: false);
  }

  factory AuthState.error(String error) {
    return AuthState(
      isAuthenticated: false,
      isLoading: false,
      error: error,
    );
  }
}