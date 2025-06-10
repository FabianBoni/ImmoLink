import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immolink/features/property/presentation/widgets/invite_tenant_dialog.dart';
import '../../domain/models/property.dart';
import '../providers/property_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PropertyDetailsPage extends ConsumerWidget {
  final String propertyId;

  const PropertyDetailsPage({required this.propertyId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyProvider(propertyId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: propertyAsync.when(
        data: (property) => CustomScrollView(
          slivers: [
            _buildAppBar(property, ref),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, property),
                  _buildStats(context, property),
                  _buildDescription(context, property),
                  _buildAmenities(context, property),
                  _buildLocation(context, property),
                  _buildFinancialDetails(context, property, ref),
                  const SizedBox(height: 100), // Bottom padding for FAB
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),      floatingActionButton: propertyAsync.when(
        data: (property) => _buildContactButton(context, property, ref),
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildInviteTenantButton(BuildContext context, Property property) {
    return ElevatedButton.icon(
      onPressed: () => _showInviteTenantDialog(context, property),
      icon: const Icon(Icons.person_add),
      label: const Text('Invite Tenant'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showInviteTenantDialog(BuildContext context, Property property) {
    showDialog(
      context: context,
      builder: (context) => InviteTenantDialog(propertyId: property.id),
    );
  }

  Widget _buildHeader(BuildContext context, Property property) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${property.address.street}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: property.status == 'available'
                      ? Colors.green
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  property.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${property.address.city}, ${property.address.postalCode}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, Property property) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            context,
            Icons.straighten,
            '${property.details.size}',
            'm²',
          ),
          _buildStatCard(
            context,
            Icons.meeting_room,
            '${property.details.rooms}',
            'Rooms',
          ),
          _buildStatCard(
            context,
            Icons.attach_money,
            '${property.rentAmount}',
            'CHF/month',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context, Property property) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Modern property located in a prime location with excellent amenities and convenient access to public transportation.',
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities(BuildContext context, Property property) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amenities',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: property.details.amenities.map((amenity) {
              return Chip(
                avatar: Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 18,
                ),
                label: Text(amenity),
                backgroundColor:
                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation(BuildContext context, Property property) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: const Center(
              child: Icon(
                Icons.map,
                size: 48,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFinancialDetails(BuildContext context, Property property, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Only show invite tenant button for landlords
          if (currentUser?.role == 'landlord')
            _buildInviteTenantButton(context, property),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildFinancialRow(
                      'Monthly Rent', '${property.rentAmount} CHF'),
                  const Divider(),
                  _buildFinancialRow(
                    'Outstanding Payments',
                    '${property.outstandingPayments} CHF',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildContactButton(BuildContext context, Property property, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    // Hide contact button for landlords
    if (currentUser?.role == 'landlord') {
      return const SizedBox.shrink();
    }
    
    return FloatingActionButton.extended(
      onPressed: () {
        // Implement contact functionality
      },
      icon: const Icon(Icons.message),
      label: const Text('Contact Landlord'),
    );
  }
  Widget _buildAppBar(Property property, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      actions: [
        // Only show edit button if user is the landlord
        if (currentUser?.role == 'landlord')
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/add-property', extra: property);
              },
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://picsum.photos/800/500?random=${property.id}',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

