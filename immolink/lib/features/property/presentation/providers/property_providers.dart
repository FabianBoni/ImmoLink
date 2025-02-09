import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/features/property/domain/services/property_service.dart';
import '../../domain/models/property.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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
  final propertyService = ref.watch(propertyServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  
  // Get landlord-specific properties if user is authenticated
  if (currentUser != null) {
    return propertyService.getLandlordProperties(currentUser.id.toString());
  }
  
  return Stream.value([]); // Empty list if no user
});

final propertyProvider = StreamProvider.family<Property, String>((ref, propertyId) {
  final propertyService = ref.watch(propertyServiceProvider);
  return propertyService.getPropertyById(propertyId);
});