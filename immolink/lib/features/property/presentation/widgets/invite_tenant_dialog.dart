import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/property_providers.dart';
import '../../../auth/domain/models/user.dart';

class InviteTenantDialog extends ConsumerStatefulWidget {
  final String propertyId;

  const InviteTenantDialog({required this.propertyId, super.key});

  @override
  ConsumerState<InviteTenantDialog> createState() => _InviteTenantDialogState();
}

class _InviteTenantDialogState extends ConsumerState<InviteTenantDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final tenantsAsync = ref.watch(availableTenantsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Select Tenant',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: tenantsAsync.when(
// In the _buildTenantList method where we filter tenants
                data: (tenants) => _buildTenantList(
                  tenants
                      .where((tenant) => tenant.fullName
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search tenants...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildTenantList(List<User> tenants) {
    return ListView.builder(
      itemCount: tenants.length,
      itemBuilder: (context, index) {
        final tenant = tenants[index];
        print('Building tenant item: ${tenant.id}'); // Debug print

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(tenant.fullName[0].toUpperCase()),
            ),
            title: Text(tenant.fullName),
            subtitle: Text(tenant.email),
            onTap: () => _inviteTenant(tenant),
          ),
        );
      },
    );
  }

  void _inviteTenant(User tenant) {
    print('Inviting tenant with ID: ${tenant.id}');
    ref
        .read(tenantInvitationProvider.notifier)
        .inviteTenant(widget.propertyId, tenant.id);
    Navigator.pop(context);
  }
}

