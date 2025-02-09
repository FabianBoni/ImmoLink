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
      appBar: AppBar(title: const Text('Add New Property')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAddressInput(),
            _buildRentInput(),
            _buildPropertyDetails(),
            _buildAmenitiesSelector(),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyDetails() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _sizeController,
            decoration: const InputDecoration(
              labelText: 'Size (m²)',
              suffixText: 'm²',
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _roomsController,
            decoration: const InputDecoration(
              labelText: 'Number of Rooms',
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Street Address',
            prefixIcon: Icon(Icons.location_on),
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
                decoration: const InputDecoration(labelText: 'City'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(labelText: 'Postal Code'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRentInput() {
    return TextFormField(
      controller: _rentController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Monthly Rent',
        prefixIcon: Icon(Icons.attach_money),
        suffixText: 'CHF',
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Rent amount is required';
        if (double.tryParse(value!) == null)
          return 'Please enter a valid amount';
        return null;
      },
    );
  }

  Widget _buildAmenitiesSelector() {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Amenities',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
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
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text('Add Property'),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final currentUser = ref.read(currentUserProvider);
      final landlordId =
          currentUser?.id.toString() ?? ''; // Explicit string conversion

      final property = Property(
        id: const Uuid().v4(),
        landlordId: landlordId, // Now properly typed as String
        tenantIds: [],
        address: Address(
          street: _addressController.text,
          city: _cityController.text,
          postalCode: _postalCodeController.text,
          country: 'Switzerland', // Default for now
        ),
        rentAmount: double.parse(_rentController.text),
        details: PropertyDetails(
          size: double.parse(_sizeController.text),
          rooms: int.parse(_roomsController.text),
          amenities: selectedAmenities,
        ),
        status: 'available', // New properties start as available
      );

      ref.read(propertyServiceProvider).addProperty(property);
      context.pop(); // Return to previous screen after submission
    }
  }
}
