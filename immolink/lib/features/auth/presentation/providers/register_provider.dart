import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/features/auth/domain/services/auth_service.dart';

class RegisterState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  RegisterState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  RegisterState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class RegisterNotifier extends StateNotifier<RegisterState> {
  final AuthService _authService;

  RegisterNotifier(this._authService) : super(RegisterState());

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
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
      
      state = state.copyWith(
        isLoading: false, 
        isSuccess: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isSuccess: false,
      );
    }
  }
}

// Update the provider to include the AuthService dependency
final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) => RegisterNotifier(ref.read(authServiceProvider)),
);
