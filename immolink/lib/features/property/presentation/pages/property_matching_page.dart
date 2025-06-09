import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/features/auth/presentation/providers/user_role_provider.dart';
import 'package:immolink/features/property/presentation/providers/property_providers.dart';
import '../widgets/property_card.dart';
import '../widgets/property_details_sheet.dart';
import '../../domain/models/property.dart';

class PropertyMatchingPage extends ConsumerWidget {
  const PropertyMatchingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userRoleProvider);
    final properties = ref.watch(propertiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(userRole == 'landlord' ? 'My Tenants' : 'My Landlords'),
      ),
      body: properties.when(
        data: (props) => ListView.builder(
          itemCount: props.length,
          itemBuilder: (context, index) {
            final property = props[index];
            return PropertyCard(
              key: ValueKey(property.id),
              property: property,
              onTap: () => _showPropertyDetails(context, property),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showPropertyDetails(BuildContext context, Property property) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return PropertyDetailsSheet(
          key: ValueKey(property.id),
          property: property,
        );
      },
    );
  }
}
