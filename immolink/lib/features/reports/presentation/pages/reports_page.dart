import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immolink/features/auth/presentation/providers/auth_provider.dart';
import 'package:immolink/features/payment/presentation/providers/payment_providers.dart';
import 'package:immolink/features/property/presentation/providers/property_providers.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/navigation_provider.dart';
import '../../../../core/widgets/common_bottom_nav.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isLandlord = currentUser?.role == 'landlord';

    // Set navigation index to Reports (3) when this page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationIndexProvider.notifier).state = 3;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            // Navigate back to dashboard instead of popping
            context.go('/home');
          },
        ),
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
      bottomNavigationBar: const CommonBottomNav(),
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
          child: isLandlord
              ? _buildLandlordReports(context, ref)
              : _buildTenantReports(context, ref),
        ),
      ),
    );
  }

  Widget _buildLandlordReports(BuildContext context, WidgetRef ref) {
    final properties = ref.watch(landlordPropertiesProvider);
    final payments = ref.watch(landlordPaymentsProvider);

    return ListView(
      children: [
        _buildReportPeriodSelector(context),
        const SizedBox(height: 24),
        _buildFinancialSummaryCard(context, properties, payments),
        const SizedBox(height: 24),
        _buildOccupancyRateCard(context, properties),
        const SizedBox(height: 24),
        _buildIncomeChart(context, payments),
        const SizedBox(height: 24),
        _buildPropertyPerformanceCard(context, properties, payments),
      ],
    );
  }

  Widget _buildTenantReports(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(tenantPaymentsProvider);

    return ListView(
      children: [
        _buildReportPeriodSelector(context),
        const SizedBox(height: 24),
        _buildPaymentSummaryCard(context, payments),
        const SizedBox(height: 24),
        _buildPaymentHistoryChart(context, payments),
      ],
    );
  }

  Widget _buildReportPeriodSelector(BuildContext context) {
    return Card(
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
              'Report Period',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: 'This Month',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                      DropdownMenuItem(value: 'Last Month', child: Text('Last Month')),
                      DropdownMenuItem(value: 'Last 3 Months', child: Text('Last 3 Months')),
                      DropdownMenuItem(value: 'Last 6 Months', child: Text('Last 6 Months')),
                      DropdownMenuItem(value: 'This Year', child: Text('This Year')),
                      DropdownMenuItem(value: 'Last Year', child: Text('Last Year')),
                      DropdownMenuItem(value: 'Custom', child: Text('Custom')),
                    ],
                    onChanged: (value) {
                      // TODO: Implement period selection
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryCard(
    BuildContext context,
    AsyncValue<List<dynamic>> properties,
    AsyncValue<List<dynamic>> payments,
  ) {
    return Card(
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
              'Financial Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            properties.when(
              data: (propertiesList) {
                return payments.when(
                  data: (paymentsList) {
                    // Calculate total income
                    final totalIncome = paymentsList.fold<double>(
                      0,
                      (sum, payment) => sum + (payment.status == 'completed' ? payment.amount : 0),
                    );

                    // Calculate outstanding payments
                    final outstandingPayments = propertiesList.fold<double>(
                      0,
                      (sum, property) => sum + property.outstandingPayments,
                    );

                    // Calculate occupancy rate
                    final totalProperties = propertiesList.length;
                    final rentedProperties = propertiesList.where((p) => p.status == 'rented').length;
                    final occupancyRate = totalProperties > 0
                        ? (rentedProperties / totalProperties * 100).toStringAsFixed(1)
                        : '0.0';

                    return Column(
                      children: [
                        _buildFinancialSummaryItem(
                          'Total Income',
                          'CHF ${totalIncome.toStringAsFixed(2)}',
                          Icons.attach_money,
                          Colors.green,
                        ),
                        const Divider(),
                        _buildFinancialSummaryItem(
                          'Outstanding Payments',
                          'CHF ${outstandingPayments.toStringAsFixed(2)}',
                          Icons.money_off,
                          Colors.red,
                        ),
                        const Divider(),
                        _buildFinancialSummaryItem(
                          'Occupancy Rate',
                          '$occupancyRate%',
                          Icons.home,
                          Colors.blue,
                        ),
                        const Divider(),
                        _buildFinancialSummaryItem(
                          'Total Properties',
                          totalProperties.toString(),
                          Icons.apartment,
                          Colors.purple,
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Error loading payments: $error'),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading properties: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyRateCard(
    BuildContext context,
    AsyncValue<List<dynamic>> properties,
  ) {
    return Card(
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
              'Occupancy Rate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            properties.when(
              data: (propertiesList) {
                // Calculate occupancy rate
                final totalProperties = propertiesList.length;
                final rentedProperties = propertiesList.where((p) => p.status == 'rented').length;
                final occupancyRate = totalProperties > 0
                    ? (rentedProperties / totalProperties * 100)
                    : 0.0;

                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: CircularProgressIndicator(
                                value: occupancyRate / 100,
                                strokeWidth: 15,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  occupancyRate > 80
                                      ? Colors.green
                                      : occupancyRate > 50
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${occupancyRate.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$rentedProperties of $totalProperties',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusIndicator('Available', Colors.blue, propertiesList.where((p) => p.status == 'available').length),
                        _buildStatusIndicator('Rented', Colors.green, rentedProperties),
                        _buildStatusIndicator('Maintenance', Colors.orange, propertiesList.where((p) => p.status == 'maintenance').length),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading properties: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, Color color, int count) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeChart(
    BuildContext context,
    AsyncValue<List<dynamic>> payments,
  ) {
    return Card(
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
              'Income Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            payments.when(
              data: (paymentsList) {
                // This is a placeholder for a chart
                // In a real implementation, you would use a charting library
                return SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart,
                        size: 80,
                        color: Colors.blue.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Income chart would be displayed here',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${paymentsList.length} payments recorded',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading payments: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyPerformanceCard(
    BuildContext context,
    AsyncValue<List<dynamic>> properties,
    AsyncValue<List<dynamic>> payments,
  ) {
    return Card(
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
              'Property Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            properties.when(
              data: (propertiesList) {
                if (propertiesList.isEmpty) {
                  return const Center(
                    child: Text(
                      'No properties found',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return payments.when(
                  data: (paymentsList) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: propertiesList.length > 5 ? 5 : propertiesList.length,
                      itemBuilder: (context, index) {
                        final property = propertiesList[index];
                        
                        // Calculate property income
                        final propertyIncome = paymentsList
                            .where((p) => p.propertyId == property.id && p.status == 'completed')
                            .fold<double>(0, (sum, p) => sum + p.amount);

                        return ListTile(
                          title: Text(
                            property.address.street,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${property.status.toUpperCase()} - CHF ${property.rentAmount}/month',
                          ),
                          trailing: Text(
                            'CHF ${propertyIncome.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: propertyIncome > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Error loading payments: $error'),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading properties: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard(
    BuildContext context,
    AsyncValue<List<dynamic>> payments,
  ) {
    return Card(
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
              'Payment Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            payments.when(
              data: (paymentsList) {
                // Calculate total payments
                final totalPayments = paymentsList.fold<double>(
                  0,
                  (sum, payment) => sum + payment.amount,
                );

                // Calculate completed payments
                final completedPayments = paymentsList
                    .where((p) => p.status == 'completed')
                    .fold<double>(0, (sum, p) => sum + p.amount);

                // Calculate pending payments
                final pendingPayments = paymentsList
                    .where((p) => p.status == 'pending')
                    .fold<double>(0, (sum, p) => sum + p.amount);

                return Column(
                  children: [
                    _buildFinancialSummaryItem(
                      'Total Payments',
                      'CHF ${totalPayments.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.blue,
                    ),
                    const Divider(),
                    _buildFinancialSummaryItem(
                      'Completed Payments',
                      'CHF ${completedPayments.toStringAsFixed(2)}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    const Divider(),
                    _buildFinancialSummaryItem(
                      'Pending Payments',
                      'CHF ${pendingPayments.toStringAsFixed(2)}',
                      Icons.hourglass_empty,
                      Colors.orange,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading payments: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistoryChart(
    BuildContext context,
    AsyncValue<List<dynamic>> payments,
  ) {
    return Card(
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
              'Payment History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            payments.when(
              data: (paymentsList) {
                if (paymentsList.isEmpty) {
                  return const Center(
                    child: Text(
                      'No payment history found',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                // Sort payments by date
                paymentsList.sort((a, b) => b.date.compareTo(a.date));

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: paymentsList.length > 5 ? 5 : paymentsList.length,
                  itemBuilder: (context, index) {
                    final payment = paymentsList[index];
                    
                    Color statusColor;
                    switch (payment.status) {
                      case 'completed':
                        statusColor = Colors.green;
                        break;
                      case 'pending':
                        statusColor = Colors.orange;
                        break;
                      case 'failed':
                        statusColor = Colors.red;
                        break;
                      default:
                        statusColor = Colors.grey;
                    }

                    return ListTile(
                      title: Text(
                        'CHF ${payment.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${payment.type.toUpperCase()} - ${DateFormat('MMM d, yyyy').format(payment.date)}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          payment.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading payments: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

