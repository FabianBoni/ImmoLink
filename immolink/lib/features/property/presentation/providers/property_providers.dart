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
  print('Provider initialized');
  final currentUser = ref.watch(currentUserProvider);
  print('Current user in provider: ${currentUser?.id}');

  if (currentUser == null) throw Exception('User not authenticated');

  final propertyService = PropertyService();
  print('Calling PropertyService.getLandlordProperties');
  return propertyService.getLandlordProperties(currentUser.id.toString());
});

final propertyProvider =
    StreamProvider.family<Property, String>((ref, propertyId) {
  final propertyService = ref.watch(propertyServiceProvider);
  return propertyService.getPropertyById(propertyId);
});
