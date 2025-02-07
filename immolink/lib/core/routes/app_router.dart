import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/features/auth/presentation/pages/login_page.dart';
import 'package:immolink/features/home/presentation/pages/home_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

final router = GoRouter(
  refreshListenable: _RouterNotifier(),
  redirect: (BuildContext context, GoRouterState state) {
    final container = ProviderContainer();
    final authState = container.read(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final isLoginRoute = state.uri.toString() == '/login';

    if (!isAuthenticated && !isLoginRoute) {
      return '/login';
    }

    if (isAuthenticated && isLoginRoute) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);

// Custom Listenable for router refreshes
class _RouterNotifier extends ChangeNotifier {
  late final ProviderSubscription<AuthState> _subscription;

  _RouterNotifier() {
    final container = ProviderContainer();
    _subscription = container.listen(
      authProvider,
      (_, __) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}