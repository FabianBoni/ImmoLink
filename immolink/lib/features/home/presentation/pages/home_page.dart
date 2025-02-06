import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildWelcomeSection(),
            _buildQuickAccessSection(),
            _buildPropertySection(),
            _buildRecentActivitySection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 52),
          SizedBox(
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    color: Color(0x00000000),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFD8CCC4),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Color(0xFF614E40)),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 43,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFBCC1CA)),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(width: 16),
                Icon(Icons.search, color: Color(0xFFBCC1CA)),
                SizedBox(width: 12),
                Text(
                  'Search your activities...',
                  style: TextStyle(
                    color: Color(0xFFBCC1CA),
                    fontSize: 16,
                    fontFamily: 'Open Sans',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabButton('Notifications', true),
              _buildTabButton('Recent Activity', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected) {
    return SizedBox(
      width: 115,
      height: 52,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF614E40)
                  : const Color(0xFF565E6C),
              fontSize: 14,
              fontFamily: 'Open Sans',
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          if (isSelected)
            Container(
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: ShapeDecoration(
                color: const Color(0xFF614E40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Container(
      height: 111,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildQuickAccessButton('Pay Rent', Icons.payment),
              const SizedBox(width: 5),
              _buildQuickAccessButton('Report Issue', Icons.report_problem),
              const SizedBox(width: 5),
              _buildQuickAccessButton('Message Landlord', Icons.message),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(String text, IconData icon) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(
        color: const Color(0xFF614E40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Open Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertySection() {
    // Implementation for property section
    return Container(); // Add property section implementation
  }

  Widget _buildRecentActivitySection() {
    // Implementation for recent activity section
    return Container(); // Add recent activity section implementation
  }

  Widget _buildBottomNavigationBar() {
    return SizedBox(
      width: 370,
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem('Home', Icons.home, true),
          _buildNavItem('Messages', Icons.message, false),
          _buildNavItem('Maintenance', Icons.build, false),
          _buildNavItem('Payments', Icons.payment, false),
          _buildNavItem('Profile', Icons.person, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, bool isSelected) {
    return Container(
      width: 74,
      height: 52,
      decoration: ShapeDecoration(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color:
                isSelected ? const Color(0xFF614E40) : const Color(0xFF565E6C),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF614E40)
                  : const Color(0xFF565E6C),
              fontSize: 10,
              fontFamily: 'Open Sans',
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              height: 1.60,
            ),
          ),
        ],
      ),
    );
  }
}
