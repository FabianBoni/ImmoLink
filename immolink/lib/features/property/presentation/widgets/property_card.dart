import 'package:flutter/material.dart';
import 'package:immolink/features/property/domain/models/property.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;

  const PropertyCard({
    required this.property,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(Icons.home, color: Theme.of(context).primaryColor),
        title: Text(property.address.street),
        subtitle: Text('${property.address.city}, ${property.address.postalCode}'),
        trailing: Text(
          '€${property.rentAmount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
