import 'package:go_router/go_router.dart';
import 'package:immolink/features/auth/presentation/pages/login_page.dart';
import 'package:immolink/features/auth/presentation/pages/register_page.dart';
import 'package:immolink/features/home/presentation/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    // Get stored session
    final prefs = await SharedPreferences.getInstance();
    final hasSession = prefs.containsKey('userId');

    // Public routes that don't need auth
    final isPublicRoute = state.uri.toString() == '/login' || 
                         state.uri.toString() == '/register';

    // Redirect logic
    if (!hasSession && !isPublicRoute) {
      return '/login';
    }
    
    if (hasSession && isPublicRoute) {
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
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);