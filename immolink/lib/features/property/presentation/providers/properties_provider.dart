import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/features/auth/presentation/providers/auth_provider.dart';
import 'package:immolink/features/property/domain/models/property.dart';
import 'package:immolink/features/property/presentation/providers/property_service_provider.dart';

final propertiesProvider = StreamProvider<List<Property>>((ref) async* {
  final propertyService = ref.read(propertyServiceProvider);
  final userId = ref.read(authProvider).userId;
  
  while (true) {
    try {
      final properties = await propertyService.getPropertiesForLandlord(userId!);
      yield properties;
    } catch (e) {
      yield [];
    }
    await Future.delayed(const Duration(seconds: 2));
  }
});
