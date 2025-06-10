import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/features/auth/domain/models/user.dart';
import 'package:immolink/features/property/domain/services/property_service.dart';
import '../../domain/models/property.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/user_service_provider.dart';

// Service provider
final propertyServiceProvider = Provider<PropertyService>((ref) {
  return PropertyService();
});

// Properties stream provider
final propertiesProvider = StreamProvider<List<Property>>((ref) {
  final propertyService = ref.watch(propertyServiceProvider);
  return propertyService.getAllProperties();
});

// Landlord-specific properties provider
final landlordPropertiesProvider = StreamProvider<List<Property>>((ref) {
  print('Provider initialized');
  final currentUser = ref.watch(currentUserProvider);
  print('Current user in provider: ${currentUser?.id}');

  // Early return empty list if no user
  if (currentUser == null) {
    return Stream.value([]);
  }

  final propertyService = ref.watch(propertyServiceProvider);
  print('Calling PropertyService.getLandlordProperties with ID: ${currentUser.id}');
  return propertyService.getLandlordProperties(currentUser.id);
});

// Tenant-specific properties provider  
final tenantPropertiesProvider = FutureProvider<List<Property>>((ref) async {
  try {
    final propertyService = ref.watch(propertyServiceProvider);
    // For tenant dashboard, show all available properties
    final properties = await propertyService.getAllPropertiesFuture();
    print('Tenant properties loaded: ${properties.length}');
    return properties;
  } catch (e) {
    print('Error in tenantPropertiesProvider: $e');
    // Return empty list instead of throwing error
    return <Property>[];
  }
});

final tenantInvitationProvider =
    StateNotifierProvider<TenantInvitationNotifier, AsyncValue<void>>((ref) {
  return TenantInvitationNotifier(ref.watch(propertyServiceProvider));
});

class TenantInvitationNotifier extends StateNotifier<AsyncValue<void>> {
  final PropertyService _propertyService;

  TenantInvitationNotifier(this._propertyService)
      : super(const AsyncValue.data(null));

  Future<void> inviteTenant(String propertyId, String tenantId) async {
    state = const AsyncValue.loading();

    try {
      await _propertyService.inviteTenant(propertyId, tenantId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final availableTenantsProvider = StreamProvider<List<User>>((ref) {
  final userService = ref.watch(userServiceProvider);
  return userService.getAvailableTenants();
});

final propertyProvider =
    StreamProvider.family<Property, String>((ref, propertyId) {
  final propertyService = ref.watch(propertyServiceProvider);
  return propertyService.getPropertyById(propertyId);
});

