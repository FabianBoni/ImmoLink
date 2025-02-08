import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LandlordDashboard extends ConsumerStatefulWidget {
  const LandlordDashboard({super.key});

  @override
  ConsumerState<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends ConsumerState<LandlordDashboard> {
  int _selectedIndex = 0;

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Home'),
          _buildNavItem(1, Icons.apartment_rounded, 'Properties'),
          _buildNavItem(2, Icons.message_rounded, 'Messages'),
          _buildNavItem(3, Icons.person_rounded, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 30),
                _buildSearchBar(),
                const SizedBox(height: 30),
                _buildPropertyOverview(),
                const SizedBox(height: 30),
                _buildQuickAccess(),
                const SizedBox(height: 30),
                _buildRecentMessages(),
                const SizedBox(height: 30),
                _buildMaintenanceRequests(),
                const SizedBox(height: 30),
                _buildFinancialOverview(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildGlassBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back',
              style: TextStyle(
                color: Colors.black.withAlpha(80),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Property Manager',
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(Icons.person_outline, color: Color(0xFF4A90E2)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search properties...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Color(0xFF4A90E2)),
        ),
      ),
    );
  }

  Widget _buildPropertyOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Property Overview',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) => _buildPropertyCard(
            title: 'Property ${index + 1}',
            occupancy: '${85 + index * 5}%',
            rentCollected: '\$${15000 + index * 5000}',
            image: 'https://picsum.photos/200/100?random=$index',
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCard({
    required String title,
    required String occupancy,
    required String rentCollected,
    required String image,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Occupancy: $occupancy',
                  style: TextStyle(
                    color: const Color(0xFF2D3142).withAlpha(70),
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Rent Collected: $rentCollected',
                  style: TextStyle(
                    color: const Color(0xFF2D3142).withAlpha(70),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              image,
              width: 120,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildQuickAccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildQuickAccessButton(
              'Add Property',
              Icons.add_home_rounded,
              () {},
            ),
            const SizedBox(width: 16),
            _buildQuickAccessButton(
              'Send Notice',
              Icons.notification_important_rounded,
              () {},
            ),
            const SizedBox(width: 16),
            _buildQuickAccessButton(
              'Reports',
              Icons.bar_chart_rounded,
              () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          'Message Tenants',
          Icons.message,
          () => context.push('/conversations'),
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: const Color(0xFF4A90E2), size: 28),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF2D3142),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentMessages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildMessageItem(
                'John Doe',
                'Maintenance request for Unit 301',
                '2h ago',
              ),
              const Divider(height: 1),
              _buildMessageItem(
                'Jane Smith',
                'Rent payment confirmation',
                '5h ago',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(String sender, String message, String time) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF4A90E2).withAlpha(10),
            child: Text(
              sender[0],
              style: const TextStyle(
                color: Color(0xFF4A90E2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sender,
                  style: const TextStyle(
                    color: Color(0xFF2D3142),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    color: const Color(0xFF2D3142).withAlpha(70),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Maintenance Requests',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildMaintenanceItem(
                'Plumbing Issue',
                'Unit 301',
                'High Priority',
                Colors.red,
              ),
              const Divider(height: 1),
              _buildMaintenanceItem(
                'AC Repair',
                'Unit 205',
                'Medium Priority',
                Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceItem(
    String issue,
    String location,
    String priority,
    Color priorityColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: priorityColor.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.warning_rounded,
              color: priorityColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue,
                  style: const TextStyle(
                    color: Color(0xFF2D3142),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    color: const Color(0xFF2D3142).withAlpha(70),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: priorityColor.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              priority,
              style: TextStyle(
                color: priorityColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Overview',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildFinancialCard(
                'Total Revenue',
                '\$45,000',
                Icons.trending_up_rounded,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFinancialCard(
                'Outstanding',
                '\$3,500',
                Icons.warning_rounded,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
