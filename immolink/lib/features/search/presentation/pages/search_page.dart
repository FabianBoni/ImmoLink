import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:immolink/features/property/domain/models/property.dart';
import 'package:immolink/features/property/presentation/providers/property_providers.dart';
import '../../../../core/theme/app_colors.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, properties, tenants, messages

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final propertiesAsync = ref.watch(landlordPropertiesProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(l10n.search),
        backgroundColor: AppColors.surfaceCards,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchHeader(l10n),
          _buildFilterTabs(l10n),
          Expanded(
            child: _buildSearchResults(l10n, propertiesAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCards,
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
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.searchPropertiesTenantsMessages,
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search_outlined,
                  color: AppColors.primaryAccent,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.textTertiary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', l10n.all, Icons.search_outlined),
                  const SizedBox(width: 8),
                  _buildFilterChip('properties', l10n.properties, Icons.home_work_outlined),
                  const SizedBox(width: 8),
                  _buildFilterChip('tenants', l10n.tenants, Icons.people_outline),
                  const SizedBox(width: 8),
                  _buildFilterChip('messages', l10n.messages, Icons.chat_bubble_outline),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label, IconData icon) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : AppColors.surfaceCards,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : AppColors.borderLight,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryAccent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(AppLocalizations l10n, AsyncValue<List<Property>> propertiesAsync) {
    if (_searchQuery.isEmpty) {
      return _buildEmptyState(l10n);
    }

    return propertiesAsync.when(
      data: (properties) {
        final filteredResults = _filterResults(properties);
        
        if (filteredResults.isEmpty) {
          return _buildNoResultsState(l10n);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: filteredResults.length,
          itemBuilder: (context, index) {
            final result = filteredResults[index];
            return _buildResultItem(result, l10n);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  List<SearchResult> _filterResults(List<Property> properties) {
    final searchLower = _searchQuery.toLowerCase();
    List<SearchResult> results = [];    // Filter properties
    if (_selectedFilter == 'all' || _selectedFilter == 'properties') {
      for (final property in properties) {
        final addressString = '${property.address.street}, ${property.address.city}';
        if (addressString.toLowerCase().contains(searchLower) ||
            property.address.city.toLowerCase().contains(searchLower) ||
            property.address.street.toLowerCase().contains(searchLower) ||
            property.status.toLowerCase().contains(searchLower)) {
          results.add(SearchResult(
            type: 'property',
            title: addressString,
            subtitle: '${property.details.rooms} rooms • ${_getStatusTranslation(property.status)}',
            data: property,
          ));
        }
      }
    }

    // TODO: Add tenant search when tenant data is available
    // TODO: Add message search when message data is available

    return results;
  }

  String _getStatusTranslation(String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'available':
        return l10n.available;
      case 'occupied':
      case 'rented':
        return l10n.occupied;
      case 'maintenance':
        return l10n.maintenance;
      default:
        return status;
    }
  }

  Widget _buildResultItem(SearchResult result, AppLocalizations l10n) {
    IconData icon;
    Color iconColor;
    VoidCallback? onTap;

    switch (result.type) {
      case 'property':
        icon = Icons.home_work_outlined;
        iconColor = AppColors.primaryAccent;
        onTap = () {
          final property = result.data as Property;
          context.push('/property/${property.id}');
        };
        break;
      case 'tenant':
        icon = Icons.person_outline;
        iconColor = AppColors.info;
        break;
      case 'message':
        icon = Icons.chat_bubble_outline;
        iconColor = AppColors.warning;
        break;
      default:
        icon = Icons.search_outlined;
        iconColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCards,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          result.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          result.subtitle,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textTertiary,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.searchToFindResults,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.searchHint,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noResultsFound,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tryDifferentSearch,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SearchResult {
  final String type; // 'property', 'tenant', 'message'
  final String title;
  final String subtitle;
  final dynamic data;

  SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    this.data,
  });
}
