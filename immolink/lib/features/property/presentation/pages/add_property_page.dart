import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immolink/features/auth/presentation/providers/auth_provider.dart';
import 'package:immolink/features/property/domain/models/property.dart';
import 'package:immolink/features/property/presentation/providers/property_providers.dart';
import 'package:uuid/uuid.dart';

class AddPropertyPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends ConsumerState<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _rentController = TextEditingController();
  final _sizeController = TextEditingController();
  final _roomsController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  List<String> selectedAmenities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Add New Property'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageUploadSection(),
              const SizedBox(height: 20),
              _buildLocationSection(),
              const SizedBox(height: 20),
              _buildPropertyDetailsSection(),
              const SizedBox(height: 20),
              _buildAmenitiesSection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Text(
                'Add Property Photos',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Street Address',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Address is required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: InputDecoration(
                      labelText: 'Postal Code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyDetailsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Property Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sizeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Size (m²)',
                      suffixText: 'm²',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _roomsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Number of Rooms',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monthly Rent (CHF)',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Rent amount is required';
                if (double.tryParse(value!) == null) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    final amenitiesList = [
      'Parking',
      'Elevator',
      'Balcony',
      'Garden',
      'Furnished',
      'Pet Friendly',
      'Storage',
      'Laundry'
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amenities',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: amenitiesList.map((amenity) {
                final isSelected = selectedAmenities.contains(amenity);
                return FilterChip(
                  label: Text(amenity),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedAmenities.add(amenity);
                      } else {
                        selectedAmenities.remove(amenity);
                      }
                    });
                  },
                  backgroundColor: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                  checkmarkColor: Theme.of(context).primaryColor,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Add Property',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final currentUser = ref.read(currentUserProvider);
      final landlordId = currentUser?.id.toString() ?? '';

      final property = Property(
        id: const Uuid().v4(),
        landlordId: landlordId,
        tenantIds: [],
        address: Address(
          street: _addressController.text,
          city: _cityController.text,
          postalCode: _postalCodeController.text,
          country: 'Switzerland',
        ),
        rentAmount: double.parse(_rentController.text),
        details: PropertyDetails(
          size: double.parse(_sizeController.text),
          rooms: int.parse(_roomsController.text),
          amenities: selectedAmenities,
        ),
        status: 'available',
      );

      ref.read(propertyServiceProvider).addProperty(property);
      context.pop();
    }
  }
}