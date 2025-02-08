import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/features/auth/presentation/pages/login_page.dart';
import 'package:immolink/features/auth/presentation/pages/register_page.dart';
import 'package:immolink/features/auth/presentation/providers/auth_provider.dart';
import 'package:immolink/features/chat/presentation/pages/chat_page.dart';
import 'package:immolink/features/chat/presentation/pages/conversations_list_page.dart';
import 'package:immolink/features/home/presentation/pages/home_page.dart';

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
        builder: (context, state) => const HomePage(),
        redirect: (context, state) {
          if (!authState.isAuthenticated) {
            return '/login';
          }
          return null;
        },
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
    ],
  );
});
