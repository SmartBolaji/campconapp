import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/resource_model.dart';
import 'package:campcon/main/provider/resource_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/resource_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class FacultyResourcesScreen extends StatefulWidget {
  final String faculty;
  final List<String> departments;
  final List<String> levels;
  final String? currentUserId;

  const FacultyResourcesScreen({
    Key? key,
    required this.faculty,
    required this.departments,
    required this.levels,
    this.currentUserId,
  }) : super(key: key);

  @override
  State<FacultyResourcesScreen> createState() => _FacultyResourcesScreenState();
}

class _FacultyResourcesScreenState extends State<FacultyResourcesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeResources();
    });
  }

  void _initializeResources() {
    final provider = Provider.of<ResourceProvider>(context, listen: false);
    provider.initializeFacultyResources(widget.faculty);
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    final provider = Provider.of<ResourceProvider>(context, listen: false);
    await provider.refreshFacultyResources(widget.faculty);
    if (!mounted) return;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    try {
      final provider = Provider.of<ResourceProvider>(context, listen: false);
      provider.disposeFacultyResources();
    } catch (e) {
      // Silently handle if context is no longer available
    }
    super.dispose();
  }

  String get _truncatedFacultyName {
    final name = widget.faculty;
    if (name.length > 20) {
      return '${name.substring(0, 17)}...';
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResourceProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(provider),
                _buildFiltersRow(provider),
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Iconify(
                Ph.arrow_left,
                color: AppTheme.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
          Center(
            child: Text(
              'Faculty of $_truncatedFacultyName',
              style: TextConstants.mediumText.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 28.w),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ResourceProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppTheme.buttonBorder,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Row(
          children: [
            Iconify(
              Ph.magnifying_glass,
              size: 20.sp,
              color: AppTheme.textLight,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (query) => provider.setSearchQuery(query),
                style: TextConstants.mediumText.copyWith(
                  fontSize: 15.sp,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search resources...',
                  hintStyle: TextConstants.smallText.copyWith(
                    fontSize: 15.sp,
                    color: AppTheme.textLight,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (provider.searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  provider.setSearchQuery('');
                },
                child: Iconify(
                  Ph.x_circle_fill,
                  size: 18.sp,
                  color: AppTheme.textLight,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersRow(ResourceProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showDepartmentFilterSheet(provider),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: provider.selectedDepartmentFilter != null
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : AppTheme.background,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: provider.selectedDepartmentFilter != null
                        ? AppTheme.primary
                        : AppTheme.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Iconify(
                      Ph.funnel,
                      size: 14.sp,
                      color: provider.selectedDepartmentFilter != null
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        provider.selectedDepartmentFilter == null
                            ? 'All Departments'
                            : provider.selectedDepartmentFilter!,
                        style: TextConstants.smallText.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: provider.selectedDepartmentFilter != null
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18.sp,
                      color: provider.selectedDepartmentFilter != null
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: () => _showLevelFilterSheet(provider),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: provider.selectedLevelFilter != 'All'
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : AppTheme.background,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: provider.selectedLevelFilter != 'All'
                        ? AppTheme.primary
                        : AppTheme.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Iconify(
                      Ph.funnel,
                      size: 14.sp,
                      color: provider.selectedLevelFilter != 'All'
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        provider.selectedLevelFilter == 'All'
                            ? 'All Levels'
                            : provider.selectedLevelFilter,
                        style: TextConstants.smallText.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: provider.selectedLevelFilter != 'All'
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18.sp,
                      color: provider.selectedLevelFilter != 'All'
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDepartmentFilterSheet(ResourceProvider provider) {
    final departments = [null, ...widget.departments];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Text(
                'Filter by Department',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: departments.map((dept) {
                    final isSelected =
                        provider.selectedDepartmentFilter == dept;
                    final displayText = dept == null ? 'All Departments' : dept;

                    return InkWell(
                      onTap: () {
                        provider.setDepartmentFilter(dept);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                        margin: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              displayText,
                              style: TextConstants.mediumText.copyWith(
                                fontSize: 15.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.textPrimary,
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.primary,
                                size: 20.sp,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDepartmentFilter(ResourceProvider provider) {
    return Container(
      height: 38.h,
      padding: EdgeInsets.only(left: 16.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.departments.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = provider.selectedDepartmentFilter == null;
            return _buildDepartmentChip(
              'All Departments',
              isSelected,
              () => provider.setDepartmentFilter(null),
            );
          }

          final department = widget.departments[index - 1];
          final isSelected = provider.selectedDepartmentFilter == department;
          return _buildDepartmentChip(
            department,
            isSelected,
            () => provider.setDepartmentFilter(department),
          );
        },
      ),
    );
  }

  Widget _buildDepartmentChip(
      String label, bool isSelected, VoidCallback onTap) {
    String displayLabel = label;
    if (label.length > 25) {
      displayLabel = '${label.substring(0, 22)}...';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.background,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Center(
          child: Text(
            displayLabel,
            style: TextConstants.smallText.copyWith(
              fontSize: 13.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppTheme.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  void _showLevelFilterSheet(ResourceProvider provider) {
    final levels = ['All', ...widget.levels];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Text(
                'Filter by Level',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: levels.map((level) {
                    final isSelected = provider.selectedLevelFilter == level;
                    final displayText = level == 'All' ? 'All Levels' : level;

                    return InkWell(
                      onTap: () {
                        provider.setLevelFilter(level);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                        margin: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              displayText,
                              style: TextConstants.mediumText.copyWith(
                                fontSize: 15.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.textPrimary,
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.primary,
                                size: 20.sp,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(ResourceProvider provider) {
    if (provider.isFacultyResourcesLoading) {
      return _buildLoadingState();
    }

    if (provider.facultyResourcesError != null) {
      return _buildErrorState(provider);
    }

    final resources = provider.facultyResources;

    if (resources.isEmpty) {
      return _buildEmptyState(provider);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.primary,
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.25,
        ),
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final resource = resources[index];
          return _buildResourceCard(resource, provider);
        },
      ),
    );
  }

  Widget _buildResourceCard(ResourceModel resource, ResourceProvider provider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: ResourceDetailScreen(
              resource: resource,
              currentUserId: widget.currentUserId,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Expanded(
                      child: Text(
                        resource.description,
                        style: TextConstants.smallText.copyWith(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        if (resource.level != null) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBackground,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              resource.level!.replaceAll(' Level', 'L'),
                              style: TextConstants.smallText.copyWith(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                        ],
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: _getTypeColor(resource.resourceType)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            resource.resourceType,
                            style: TextConstants.smallText.copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: _getTypeColor(resource.resourceType),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 28.w,
            height: 28.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading resources...',
            style: TextConstants.mediumText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ResourceProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Iconify(
              Ph.warning_circle,
              size: 48.sp,
              color: AppTheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load resources',
              style: TextConstants.mediumText.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => provider.refreshFacultyResources(widget.faculty),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Try Again',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ResourceProvider provider) {
    String message = 'No resources found';
    if (provider.selectedDepartmentFilter != null ||
        provider.selectedLevelFilter != 'All') {
      message = 'No resources match your filters';
    } else if (provider.searchQuery.isNotEmpty) {
      message = 'No resources found for "${provider.searchQuery}"';
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                shape: BoxShape.circle,
              ),
              child: Iconify(
                Ph.files,
                size: 48.sp,
                color: AppTheme.textLight,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No Resources Yet',
              style: TextConstants.mediumText.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextConstants.smallText.copyWith(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (provider.selectedDepartmentFilter != null ||
                provider.selectedLevelFilter != 'All' ||
                provider.searchQuery.isNotEmpty) ...[
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  provider.clearFacultyFilters();
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBackground,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Clear Filters',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFE53935);
      case 'document':
      case 'doc':
      case 'docx':
        return const Color(0xFF2196F3);
      case 'presentation':
      case 'ppt':
      case 'pptx':
        return const Color(0xFFFF9800);
      case 'spreadsheet':
      case 'xls':
      case 'xlsx':
        return const Color(0xFF4CAF50);
      case 'image':
        return const Color(0xFF9C27B0);
      case 'video':
        return const Color(0xFFE91E63);
      case 'link':
        return const Color(0xFF00BCD4);
      case 'note':
        return const Color(0xFF607D8B);
      default:
        return AppTheme.textSecondary;
    }
  }
}
