import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/search_provider.dart';
import 'package:campcon/main/screens/search/widgets/search_empty_state.dart';
import 'package:campcon/main/screens/search/widgets/search_header.dart';
import 'package:campcon/main/screens/search/widgets/search_idle_view.dart';
import 'package:campcon/main/screens/search/widgets/search_results_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  final SearchContext context;

  const SearchScreen({
    super.key,
    required this.context,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSearch();
      _focusNode.requestFocus();
    });
  }

  void _initializeSearch() {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    searchProvider.initialize(
      widget.context,
      userId: authProvider.currentUser?.uid,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                // Search Header
                SearchHeader(
                  controller: _searchController,
                  focusNode: _focusNode,
                  hintText: provider.hintText,
                  onChanged: (query) => provider.updateQuery(query),
                  onClear: () {
                    _searchController.clear();
                    provider.clearQuery();
                  },
                  onBack: () => Navigator.pop(context),
                  showFilter: widget.context == SearchContext.market ||
                      widget.context == SearchContext.resources,
                  onFilterTap: () => _showFilterSheet(context, provider),
                ),

                // Content
                Expanded(
                  child: _buildContent(provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(SearchProvider provider) {
    switch (provider.status) {
      case SearchStatus.idle:
        return SearchIdleView(
          recentSearches: provider.recentSearches,
          trendingSearches: provider.trendingSearches,
          onRecentTap: (query) {
            _searchController.text = query;
            provider.updateQuery(query);
          },
          onRecentRemove: (query) => provider.removeFromRecentSearches(query),
          onClearRecent: () => provider.clearRecentSearches(),
          onTrendingTap: (query) {
            _searchController.text = query;
            provider.updateQuery(query);
          },
        );

      case SearchStatus.searching:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 32.w,
                height: 32.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.primary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Searching...',
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        );

      case SearchStatus.empty:
        return SearchEmptyState(
          query: provider.query,
          context: widget.context,
        );

      case SearchStatus.success:
        return SearchResultsView(
          context: widget.context,
          provider: provider,
          onResultTap: () {
            provider.addToRecentSearches(provider.query);
          },
        );

      case SearchStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48.sp,
                color: AppTheme.error,
              ),
              SizedBox(height: 16.h),
              Text(
                'Something went wrong',
                style: TextConstants.mediumText.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () => provider.updateQuery(provider.query),
                child: Text(
                  'Try again',
                  style: TextConstants.smallText.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  void _showFilterSheet(BuildContext context, SearchProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      isScrollControlled: true,
      builder: (context) => _buildFilterSheet(provider),
    );
  }

  Widget _buildFilterSheet(SearchProvider provider) {
    if (widget.context == SearchContext.market) {
      return _MarketFilterSheet(provider: provider);
    } else if (widget.context == SearchContext.resources) {
      return _ResourceFilterSheet(provider: provider);
    }
    return const SizedBox.shrink();
  }
}

// Market Filter Sheet
class _MarketFilterSheet extends StatelessWidget {
  final SearchProvider provider;

  const _MarketFilterSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.resetFilters();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Reset',
                      style: TextConstants.smallText.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Type toggles
              Text(
                'Type',
                style: TextConstants.smallText.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _FilterChip(
                    label: 'Products',
                    isSelected: provider.showProducts,
                    onTap: () =>
                        provider.toggleProducts(!provider.showProducts),
                  ),
                  SizedBox(width: 10.w),
                  _FilterChip(
                    label: 'Services',
                    isSelected: provider.showServices,
                    onTap: () =>
                        provider.toggleServices(!provider.showServices),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Sort
              Text(
                'Sort By',
                style: TextConstants.smallText.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  'Recent',
                  'Price: Low to High',
                  'Price: High to Low',
                  'Most Popular',
                ]
                    .map((sort) => _FilterChip(
                          label: sort,
                          isSelected: provider.marketSort == sort,
                          onTap: () => provider.setMarketSort(sort),
                        ))
                    .toList(),
              ),
              SizedBox(height: 30.h),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: TextConstants.smallText.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 10.h),
            ],
          ),
        );
      },
    );
  }
}

// Resource Filter Sheet
class _ResourceFilterSheet extends StatelessWidget {
  final SearchProvider provider;

  const _ResourceFilterSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    final resourceTypes = [
      'All',
      'Lecture Notes',
      'Past Questions',
      'Textbooks',
      'Tutorials',
      'Other'
    ];

    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.resetFilters();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Reset',
                      style: TextConstants.smallText.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Resource type
              Text(
                'Resource Type',
                style: TextConstants.smallText.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: resourceTypes
                    .map((type) => _FilterChip(
                          label: type,
                          isSelected: provider.resourceType == type,
                          onTap: () => provider.setResourceType(type),
                        ))
                    .toList(),
              ),
              SizedBox(height: 30.h),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: TextConstants.smallText.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 10.h),
            ],
          ),
        );
      },
    );
  }
}

// Filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.background,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextConstants.smallText.copyWith(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
