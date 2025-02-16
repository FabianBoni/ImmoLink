import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/features/auth/presentation/pages/login_page.dart';
import 'package:immolink/features/auth/presentation/pages/register_page.dart';
import 'package:immolink/features/auth/presentation/providers/auth_provider.dart';
import 'package:immolink/features/chat/presentation/pages/chat_page.dart';
import 'package:immolink/features/chat/presentation/pages/conversations_list_page.dart';
import 'package:immolink/features/home/presentation/pages/home_page.dart';
import 'package:immolink/features/property/presentation/pages/add_property_page.dart';
import 'package:immolink/features/property/presentation/pages/property_details_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/home' : '/login',
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
        builder: (context, state) => HomePage(),
      ),
      GoRoute(
        path: '/property/add',
        builder: (context, state) => AddPropertyPage(),
      ),
      GoRoute(
        path: '/property/:id',
        builder: (context, state) => PropertyDetailsPage(
          propertyId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/chat/:conversationId',
        builder: (context, state) => ChatPage(
          conversationId: state.pathParameters['conversationId']!,
          otherUserName: state.uri.queryParameters['otherUser'] ?? 'User',
        ),
      ),
      GoRoute(
        path: '/conversations',
        builder: (context, state) => const ConversationsListPage(),
      ),
      GoRoute(
        path: '/property/:id',
        builder: (context, state) => PropertyDetailsPage(
          propertyId: state.pathParameters['id']!,
        ),
      ),
    ],
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';

      if (!authState.isAuthenticated && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      if (authState.isAuthenticated && isLoggingIn) {
        return '/home';
      }

      return null;
    },
  );
});
