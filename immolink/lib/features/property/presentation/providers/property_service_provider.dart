import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/property_service.dart';

final propertyServiceProvider = Provider<PropertyService>((ref) {
  return PropertyService();
});