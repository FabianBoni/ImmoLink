import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/category_tabs.dart';
import '../../../../core/widgets/app_button.dart';

class TenantDashboard extends ConsumerStatefulWidget {
  const TenantDashboard({super.key});

  @override
  ConsumerState<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends ConsumerState<TenantDashboard> {
  int _selectedIndex = 0;
  int _selectedCategoryIndex = 0;

  final List<CategoryTab> _categories = [
    const CategoryTab(label: 'All', icon: Icons.home),
    const CategoryTab(label: 'Apartments', icon: Icons.apartment),
    const CategoryTab(label: 'Houses', icon: Icons.house),
    const CategoryTab(label: 'Studios', icon: Icons.single_bed),
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppTopBar(
        location: 'Springfield, IL',
        showLocation: true,
        onLocationTap: () {
          // Handle location tap
        },
        onNotificationTap: () {
          // Handle notification tap
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sectionSeparation),
            _buildHeader(),
            const SizedBox(height: AppSpacing.sectionSeparation),
            _buildSearchBar(),
            const SizedBox(height: AppSpacing.itemSeparation),
            _buildCategoryTabs(),
            const SizedBox(height: AppSpacing.sectionSeparation),
            _buildPropertyCard(),
            const SizedBox(height: AppSpacing.sectionSeparation),
            _buildQuickActions(),
            const SizedBox(height: AppSpacing.sectionSeparation),
            _buildRecentActivity(),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Guest User',
                style: AppTypography.heading1,
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBackground,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.surfaceCards,
              child: const Icon(
                Icons.person_outline,
                color: AppColors.textSecondary,
                size: AppSizes.iconMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: AppSearchBar(
        hintText: 'Search properties, locations...',
        onTap: () {
          // Navigate to search page or show search functionality
        },
        readOnly: true,
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return CategoryTabs(
      tabs: _categories,
      selectedIndex: _selectedCategoryIndex,
      onTabSelected: (index) {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
    );
  }

  Widget _buildPropertyCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(AppBorderRadius.cardsButtons),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppBorderRadius.cardsButtons),
              ),
              child: Container(
                height: AppSizes.propertyCardImageHeight,
                width: double.infinity,
                color: AppColors.surfaceCards,
                child: const Icon(
                  Icons.home,
                  color: AppColors.textPlaceholder,
                  size: AppSizes.iconLarge,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sunset Apartments',
                    style: AppTypography.subhead,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: AppSizes.iconSmall,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '123 Main Street, Springfield',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPropertyStatus(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyStatus() {
    return Row(
      children: [
        _buildStatusItem('Rent Status', 'Paid', AppColors.success),
        const SizedBox(width: AppSpacing.lg),
        _buildStatusItem('Next Due', '12/12/2023', AppColors.warning),
      ],
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color == AppColors.success ? AppColors.successLight : AppColors.warningLight,
          borderRadius: BorderRadius.circular(AppBorderRadius.cardsButtons),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTypography.subhead.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTypography.heading2,
          ),
          const SizedBox(height: AppSpacing.itemSeparation),
          Row(
            children: [
              _buildActionButton('Pay Rent', Icons.payment, AppColors.success),
              const SizedBox(width: AppSpacing.md),
              _buildActionButton('Report Issue', Icons.warning_rounded, AppColors.warning),
              const SizedBox(width: AppSpacing.md),
              _buildActionButton('Message Landlord', Icons.message, AppColors.primaryAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Navigate based on the action button
          if (label == 'Pay Rent') {
            context.push('/payments/make');
          } else if (label == 'Report Issue') {
            context.push('/maintenance/request');
          } else if (label == 'Message Landlord') {
            context.push('/conversations');
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.circular(AppBorderRadius.cardsButtons),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: AppSizes.iconMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: AppTypography.heading2,
          ),
          const SizedBox(height: AppSpacing.itemSeparation),
          _buildActivityItem(
            'Rent Payment',
            'Payment processed successfully',
            Icons.payment,
            AppColors.success,
            '2h ago',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildActivityItem(
            'Maintenance Request',
            'Water leak reported in kitchen',
            Icons.build,
            AppColors.warning,
            '1d ago',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String description,
    IconData icon,
    Color color,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.cardsButtons),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color == AppColors.success ? AppColors.successLight : AppColors.warningLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: AppSizes.iconSmall),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.subhead,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPlaceholder,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        border: const Border(
          top: BorderSide(color: AppColors.dividerSeparator),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0, context),
          _buildNavItem(Icons.message, 'Messages', 1, context),
          _buildNavItem(Icons.build, 'Maintenance', 2, context),
          _buildNavItem(Icons.payment, 'Payments', 3, context),
          _buildNavItem(Icons.person, 'Profile', 4, context),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, BuildContext context) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        
        // Navigate to the appropriate page based on the selected index
        switch (index) {
          case 0: // Home
            // Already on home page
            break;
          case 1: // Messages
            context.push('/conversations');
            break;
          case 2: // Maintenance
            context.push('/maintenance/request');
            break;
          case 3: // Payments
            context.push('/payments/history');
            break;
          case 4: // Profile/Settings
            context.push('/settings');
            break;
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryAccent : AppColors.textPlaceholder,
            size: AppSizes.iconMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isSelected ? AppColors.primaryAccent : AppColors.textPlaceholder,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
