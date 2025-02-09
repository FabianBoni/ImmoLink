import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/features/property/presentation/providers/property_providers.dart';
import '../../domain/models/property.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final landlordPropertiesProvider = StreamProvider<List<Property>>((ref) {
  final propertyService = ref.watch(propertyServiceProvider);
  final user = ref.watch(currentUserProvider); // User object directly
  
  if (user == null) return Stream.value([]);
  return propertyService.getLandlordProperties(user.id.toString());
});