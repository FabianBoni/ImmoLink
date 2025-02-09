import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/features/property/presentation/providers/property_providers.dart';
import '../../domain/models/property.dart';

class PropertyDetailsPage extends ConsumerWidget {
  final String propertyId;

  const PropertyDetailsPage({
    required this.propertyId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyProvider(propertyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
      ),
      body: propertyAsync.when(
        data: (property) => _buildPropertyDetails(context, property),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildPropertyDetails(BuildContext context, Property property) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(property.imageUrls),
          
          const SizedBox(height: 16),
          
          Text(
            property.address.toString(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '${property.rentAmount} CHF/month',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          
          const SizedBox(height: 16),
          
          _buildDetailsSection(property.details),
          
          const SizedBox(height: 16),
          
          _buildContactButton(context, property.landlordId),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<String> imageUrls) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: imageUrls.isEmpty ? 1 : imageUrls.length,
        itemBuilder: (context, index) {
          return imageUrls.isEmpty
              ? const Center(child: Icon(Icons.home, size: 100))
              : Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                );
        },
      ),
    );
  }

  Widget _buildDetailsSection(PropertyDetails details) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Size: ${details.size} m²'),
            Text('Rooms: ${details.rooms}'),
            const SizedBox(height: 8),
            const Text('Amenities:'),
            Wrap(
              spacing: 8,
              children: details.amenities
                  .map((amenity) => Chip(label: Text(amenity)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(BuildContext context, String landlordId) {
    return ElevatedButton(
      onPressed: () => _contactLandlord(context, landlordId),
      child: const Text('Contact Landlord'),
    );
  }

  void _contactLandlord(BuildContext context, String landlordId) {
    // TODO: Implement contact functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact feature coming soon')),
    );
  }
}