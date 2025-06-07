import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immolink/features/auth/presentation/providers/auth_provider.dart';
import 'package:immolink/features/payment/domain/models/payment.dart';
import 'package:immolink/features/payment/presentation/providers/payment_providers.dart';
import 'package:immolink/features/property/presentation/providers/property_providers.dart';

class MakePaymentPage extends ConsumerStatefulWidget {
  final String? propertyId;

  const MakePaymentPage({super.key, this.propertyId});

  @override
  ConsumerState<MakePaymentPage> createState() => _MakePaymentPageState();
}

class _MakePaymentPageState extends ConsumerState<MakePaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedPropertyId;
  String? _selectedPaymentMethod;
  String? _selectedPaymentType;

  final List<String> _paymentMethods = [
    'Credit Card',
    'Bank Transfer',
    'PayPal',
    'Other'
  ];

  final List<String> _paymentTypes = [
    'Rent',
    'Deposit',
    'Fee',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _selectedPropertyId = widget.propertyId;
    _selectedPaymentMethod = _paymentMethods.first;
    _selectedPaymentType = _paymentTypes.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userProperties = ref.watch(tenantPropertiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Payment'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: userProperties.when(
            data: (properties) {
              // If no properties are available
              if (properties.isEmpty) {
                return const Center(
                  child: Text(
                    'You have no properties to make payments for.',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }

              // If propertyId was not provided or is invalid, use the first property
              if (_selectedPropertyId == null || 
                  !properties.any((p) => p.id == _selectedPropertyId)) {
                _selectedPropertyId = properties.first.id;
              }

              // Find the selected property
              final selectedProperty = properties.firstWhere(
                (p) => p.id == _selectedPropertyId,
                orElse: () => properties.first,
              );

              // Set the default amount to the outstanding payment amount
              if (_amountController.text.isEmpty) {
                _amountController.text = selectedProperty.outstandingPayments.toString();
              }

              return Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Property',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedPropertyId,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: properties.map((property) {
                                return DropdownMenuItem<String>(
                                  value: property.id,
                                  child: Text(property.address.street),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPropertyId = value;
                                  // Update amount based on the selected property
                                  final property = properties.firstWhere(
                                    (p) => p.id == value,
                                    orElse: () => properties.first,
                                  );
                                  _amountController.text = property.outstandingPayments.toString();
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.home, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${selectedProperty.address.street}, ${selectedProperty.address.city}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.attach_money, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'Outstanding: CHF ${selectedProperty.outstandingPayments}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _amountController,
                              decoration: InputDecoration(
                                labelText: 'Amount (CHF)',
                                prefixIcon: const Icon(Icons.attach_money),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an amount';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                if (double.parse(value) <= 0) {
                                  return 'Amount must be greater than zero';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedPaymentType,
                              decoration: InputDecoration(
                                labelText: 'Payment Type',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: _paymentTypes.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentType = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedPaymentMethod,
                              decoration: InputDecoration(
                                labelText: 'Payment Method',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: _paymentMethods.map((method) {
                                return DropdownMenuItem<String>(
                                  value: method,
                                  child: Text(method),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notesController,
                              decoration: InputDecoration(
                                labelText: 'Notes (Optional)',
                                hintText: 'Add any additional information',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _submitPayment(currentUser!.id);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Make Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Secure payment processing by ImmoLink',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading properties: $error'),
            ),
          ),
        ),
      ),
    );
  }

  void _submitPayment(String tenantId) async {
    if (_selectedPropertyId == null) return;

    final payment = Payment(
      id: '', // Will be assigned by the database
      propertyId: _selectedPropertyId!,
      tenantId: tenantId,
      amount: double.parse(_amountController.text),
      date: DateTime.now(),
      status: 'pending',
      type: _selectedPaymentType?.toLowerCase() ?? 'rent',
      paymentMethod: _selectedPaymentMethod?.toLowerCase(),
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    try {
      ref.read(paymentNotifierProvider.notifier).createPayment(payment);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
