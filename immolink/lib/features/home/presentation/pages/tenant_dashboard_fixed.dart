import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/category_tabs.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../property/presentation/providers/property_providers.dart';
import '../../../property/domain/models/property.dart';

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
    final currentUser = ref.watch(currentUserProvider);
    final propertiesAsync = ref.watch(tenantPropertiesProvider);
    
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
      body: propertiesAsync.when(
        data: (properties) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sectionSeparation),
              _buildHeader(currentUser?.fullName ?? 'Guest User'),
              const SizedBox(height: AppSpacing.sectionSeparation),
              _buildSearchBar(),
              const SizedBox(height: AppSpacing.itemSeparation),
              _buildCategoryTabs(),
              const SizedBox(height: AppSpacing.sectionSeparation),
              if (properties.isNotEmpty) 
                _buildPropertyCard(properties.first)
              else
                _buildNoPropertyCard(),
              const SizedBox(height: AppSpacing.sectionSeparation),
              _buildQuickActions(),
              const SizedBox(height: AppSpacing.sectionSeparation),
              _buildRecentActivity(),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error loading dashboard', style: AppTypography.subhead),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(tenantPropertiesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(String userName) {
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
                userName,
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

  Widget _buildPropertyCard(Property property) {
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
                    property.address.street,
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
                        '${property.address.city}, ${property.address.postalCode}',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPropertyStatus(property),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPropertyCard() {
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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.home_outlined,
                size: 64,
                color: AppColors.textPlaceholder,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No Property Assigned',
                style: AppTypography.subhead,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You haven\'t been assigned to any property yet. Contact your landlord for more information.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyStatus(Property property) {
    return Row(
      children: [
        _buildStatusItem('Rent Status', 'Paid', AppColors.success),
        const SizedBox(width: AppSpacing.lg),
        _buildStatusItem('Rent Amount', 'CHF ${property.rentAmount.toStringAsFixed(0)}', AppColors.primaryAccent),
      ],
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color == AppColors.success ? AppColors.successLight : AppColors.accentLight,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: AppSizes.iconMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
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
            'Submitted request for kitchen faucet',
            Icons.build,
            AppColors.warning,
            '1d ago',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildActivityItem(
            'Message from Landlord',
            'New message about property inspection',
            Icons.message,
            AppColors.primaryAccent,
            '3d ago',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String description, IconData icon, Color color, String time) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.cardsButtons),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.cardsButtons),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppSizes.iconSmall,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          // Handle navigation
          switch (index) {
            case 0: // Home - already here
              break;
            case 1: // Search
              context.push('/search');
              break;
            case 2: // Messages
              context.push('/conversations');
              break;
            case 3: // Payments
              context.push('/payments/history');
              break;
            case 4: // Profile/Settings
              context.push('/settings');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primaryAccent,
        unselectedItemColor: AppColors.textPlaceholder,
        items: [
          _buildBottomNavItem(Icons.home, 'Home', 0),
          _buildBottomNavItem(Icons.search, 'Search', 1),
          _buildBottomNavItem(Icons.message, 'Messages', 2),
          _buildBottomNavItem(Icons.payment, 'Payments', 3),
          _buildBottomNavItem(Icons.person, 'Profile', 4),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          
          // Handle navigation
          switch (index) {
            case 0: // Home - already here
              break;
            case 1: // Search
              context.push('/search');
              break;
            case 2: // Messages
              context.push('/conversations');
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
      ),
      label: '',
    );
  }
}
