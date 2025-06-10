import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/contact_service.dart';
import '../../domain/models/contact_user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Contact service provider
final contactServiceProvider = Provider<ContactService>((ref) {
  return ContactService();
});

// Provider for user's contacts (tenants for landlords, landlords for tenants)
final userContactsProvider = FutureProvider<List<ContactUser>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return [];

  final contactService = ref.watch(contactServiceProvider);
  return contactService.getContactsForUser(
    userId: currentUser.id,
    userRole: currentUser.role,
  );
});

// Provider for all users (admin view or search)
final allUsersProvider = FutureProvider<List<ContactUser>>((ref) async {
  final contactService = ref.watch(contactServiceProvider);
  return contactService.getAllUsers();
});

// Provider for all tenants (landlord's tenant management view)
final allTenantsProvider = FutureProvider<List<ContactUser>>((ref) async {
  final contactService = ref.watch(contactServiceProvider);
  return contactService.getAllTenants();
});
