import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immolink/features/auth/presentation/providers/auth_provider.dart';
import 'package:immolink/features/auth/presentation/providers/user_role_provider.dart';
import 'package:immolink/features/home/presentation/pages/landlord_dashboard.dart';
import 'package:immolink/features/home/presentation/pages/tenant_dashboard.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, current) {
      if (!current.isAuthenticated) {
        context.go('/login');
      }
    });

    // Get current user role
    final userRole = ref.watch(userRoleProvider);

    // Return appropriate dashboard based on role
    return userRole == 'landlord' 
        ? const LandlordDashboard()
        : const TenantDashboard();
  }
}