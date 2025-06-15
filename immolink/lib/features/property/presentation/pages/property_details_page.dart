import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:immolink/features/property/presentation/widgets/invite_tenant_dialog.dart';
import '../../domain/models/property.dart';
import '../providers/property_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';

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
      label: Text(AppLocalizations.of(context)!.inviteTenant),
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
        children: [          _buildStatCard(
            context,
            Icons.straighten,
            '${property.details.size}',
            AppLocalizations.of(context)!.squareMeters,
          ),_buildStatCard(
            context,
            Icons.meeting_room,
            '${property.details.rooms}',
            AppLocalizations.of(context)!.rooms,
          ),          _buildStatCard(
            context,
            Icons.attach_money,
            '${property.rentAmount}',
            AppLocalizations.of(context)!.chfPerMonth,
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
        children: [          Text(
            AppLocalizations.of(context)!.description,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.propertyDescription,
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
        children: [          Text(
            AppLocalizations.of(context)!.amenities,
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
            AppLocalizations.of(context)!.location,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FutureBuilder<LatLng?>(
                future: _getLocationFromAddress(property.address),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      color: AppColors.surfaceCards,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    );
                  }
                    if (snapshot.hasError || !snapshot.hasData) {
                    return Container(
                      color: AppColors.surfaceCards,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.locationNotAvailable,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${property.address.street}\n${property.address.city}, ${property.address.postalCode}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.addressDisplayOnly,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    );
                  }                  final location = snapshot.data!;
                  
                  // Use different map implementation for web vs mobile
                  if (kIsWeb) {
                    // Web fallback: Show static map image
                    return _buildWebMapFallback(location, property);
                  } else {
                    // Mobile: Use Google Maps widget
                    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: location,
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('property'),
                          position: location,
                          infoWindow: InfoWindow(
                            title: property.address.street,
                            snippet: '${property.address.city}, ${property.address.postalCode}',
                          ),
                        ),
                      },
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      myLocationButtonEnabled: false,
                      onTap: (_) => _openMapsApp(location),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final location = await _getLocationFromAddress(property.address);
              if (location != null) {
                _openMapsApp(location);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions,
                    color: AppColors.primaryAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.getDirections,
                          style: TextStyle(
                            color: AppColors.primaryAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${property.address.street}, ${property.address.city}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.open_in_new,
                    color: AppColors.primaryAccent,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }  Future<LatLng?> _getLocationFromAddress(Address address) async {
    try {
      // First try the built-in geocoding service
      final location = await _tryBuiltInGeocoding(address);
      if (location != null) {
        return location;
      }

      // If built-in fails, try OpenStreetMap Nominatim API
      print('Built-in geocoding failed, trying Nominatim API...');
      return await _tryNominatimGeocoding(address);
    } catch (e) {
      print('All geocoding attempts failed: $e');
      return null;
    }
  }

  Future<LatLng?> _tryBuiltInGeocoding(Address address) async {
    try {
      final addressString = '${address.street}, ${address.city}, ${address.postalCode}, ${address.country}';
      print('Trying built-in geocoding: $addressString');
      
      final locations = await locationFromAddress(addressString);
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        print('Built-in geocoding success: ${location.latitude}, ${location.longitude}');
        return LatLng(location.latitude, location.longitude);
      }
    } catch (e) {
      print('Built-in geocoding failed: $e');
    }
    return null;
  }

  Future<LatLng?> _tryNominatimGeocoding(Address address) async {
    try {
      // Try different address formats with OpenStreetMap Nominatim
      final addressQueries = [
        '${address.street}, ${address.city}, ${address.postalCode}, Switzerland',
        '${address.city}, ${address.postalCode}, Switzerland', 
        '${address.city}, Switzerland',
        address.city,
      ];

      for (final query in addressQueries) {
        print('Trying Nominatim with: $query');
        
        final encodedQuery = Uri.encodeComponent(query);
        final url = 'https://nominatim.openstreetmap.org/search?format=json&q=$encodedQuery&limit=1&countrycodes=ch';
        
        try {
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'User-Agent': 'ImmoLink App/1.0 (property management)',
            },
          );

          if (response.statusCode == 200) {
            final List<dynamic> data = json.decode(response.body);
            
            if (data.isNotEmpty) {
              final result = data.first;
              final lat = double.tryParse(result['lat']);
              final lon = double.tryParse(result['lon']);
              
              if (lat != null && lon != null) {
                print('Nominatim success: $lat, $lon for query: $query');
                return LatLng(lat, lon);
              }
            }
          } else {
            print('Nominatim API returned status: ${response.statusCode}');
          }
        } catch (e) {
          print('Nominatim request failed for "$query": $e');
          continue; // Try next query
        }
        
        // Add a small delay between requests to be respectful to the free API
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      print('Nominatim geocoding completely failed: $e');
    }
    
    return null;
  }void _openMapsApp(LatLng location) async {
    try {
      // Try to open Google Maps app first, fallback to web version
      final googleMapsUrl = Uri.parse('google.navigation:q=${location.latitude},${location.longitude}');
      final webMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}');
      
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else if (await canLaunchUrl(webMapsUrl)) {
        await launchUrl(webMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: show error message
        print('Could not open maps app. Coordinates: ${location.latitude}, ${location.longitude}');
      }
    } catch (e) {
      print('Error opening maps app: $e');
    }
  }

  Widget _buildFinancialDetails(BuildContext context, Property property, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [          Text(
            AppLocalizations.of(context)!.financialDetails,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Only show invite tenant button for landlords
          if (currentUser?.role == 'landlord')
            _buildInviteTenantButton(context, property),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(                children: [
                  _buildFinancialRow(
                      AppLocalizations.of(context)!.monthlyRent, '${property.rentAmount} CHF'),
                  const Divider(),
                  _buildFinancialRow(
                    AppLocalizations.of(context)!.outstandingPayments,
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
  Widget _buildWebMapFallback(LatLng location, Property property) {
    // For web, show a static map image with click to open external maps
    final zoom = 15;
    
    return GestureDetector(
      onTap: () => _openMapsApp(location),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceCards,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerSeparator),
        ),
        child: Stack(
          children: [
            // Static map image using OpenStreetMap tiles
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://tile.openstreetmap.org/$zoom/${_lon2tile(location.longitude, zoom)}/${_lat2tile(location.latitude, zoom)}.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceCards,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Click to open map',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${property.address.street}\n${property.address.city}, ${property.address.postalCode}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Map pin overlay
            Positioned(
              top: 90,
              left: 190,
              child: Icon(
                Icons.location_pin,
                color: AppColors.error,
                size: 32,
              ),
            ),
            // Click overlay
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.open_in_new,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Open Map',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for tile calculation
  int _lon2tile(double lon, int zoom) {
    return ((lon + 180.0) / 360.0 * (1 << zoom)).floor();
  }

  int _lat2tile(double lat, int zoom) {
    return ((1.0 - log(tan(lat * pi / 180.0) + 1.0 / cos(lat * pi / 180.0)) / pi) / 2.0 * (1 << zoom)).floor();
  }
}

