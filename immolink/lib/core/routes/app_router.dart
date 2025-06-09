import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/features/auth/presentation/pages/login_page.dart';
import 'package:immolink/features/auth/presentation/pages/register_page.dart';
import 'package:immolink/features/auth/presentation/providers/auth_provider.dart';
import 'package:immolink/features/chat/presentation/pages/chat_page.dart';
import 'package:immolink/features/chat/presentation/pages/conversations_list_page.dart';
import 'package:immolink/features/chat/presentation/pages/address_book_page.dart';
import 'package:immolink/features/home/presentation/pages/home_page.dart';
import 'package:immolink/features/maintenance/presentation/pages/maintenance_management_page.dart';
import 'package:immolink/features/maintenance/presentation/pages/maintenance_request_page.dart';
import 'package:immolink/features/payment/presentation/pages/make_payment_page.dart';
import 'package:immolink/features/payment/presentation/pages/payment_history_page.dart';
import 'package:immolink/features/property/presentation/pages/add_property_page.dart';
import 'package:immolink/features/property/presentation/pages/property_details_page.dart';
import 'package:immolink/features/property/presentation/pages/property_list_page.dart';
import 'package:immolink/features/reports/presentation/pages/reports_page.dart';
import 'package:immolink/features/settings/presentation/pages/settings_page.dart';
import 'package:immolink/features/settings/presentation/pages/change_password_page.dart';
import 'package:immolink/features/profile/presentation/pages/edit_profile_page.dart';

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
      ),      GoRoute(
        path: '/add-property',
        builder: (context, state) => AddPropertyPage(),
      ),
      GoRoute(
        path: '/properties',
        builder: (context, state) => const PropertyListPage(),
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
      ),      GoRoute(
        path: '/conversations',
        builder: (context, state) => const ConversationsListPage(),
      ),
      GoRoute(
        path: '/address-book',
        builder: (context, state) => const AddressBookPage(),
      ),
      // Maintenance routes
      GoRoute(
        path: '/maintenance/request',
        builder: (context, state) => MaintenanceRequestPage(
          propertyId: state.uri.queryParameters['propertyId'],
        ),
      ),
      GoRoute(
        path: '/maintenance/manage',
        builder: (context, state) => const MaintenanceManagementPage(),
      ),
      // Payment routes
      GoRoute(
        path: '/payments/history',
        builder: (context, state) => const PaymentHistoryPage(),
      ),
      GoRoute(
        path: '/payments/make',
        builder: (context, state) => MakePaymentPage(
          propertyId: state.uri.queryParameters['propertyId'],
        ),
      ),      // Settings route
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      // Change Password route
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      // Edit Profile route
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      // Reports route
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsPage(),
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

