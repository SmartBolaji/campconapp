import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/resource_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/resource_detail_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/resource_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ResourceListScreen extends StatefulWidget {
  final String faculty;
  final String department;
  final String level;
  final String? currentUserId;

  const ResourceListScreen({
    Key? key,
    required this.faculty,
    required this.department,
    required this.level,
    this.currentUserId,
  }) : super(key: key);

  @override
  State<ResourceListScreen> createState() => _ResourceListScreenState();
}

class _ResourceListScreenState extends State<ResourceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final provider = Provider.of<ResourceProvider>(context, listen: false);
    // Set filter context before loading
    provider.selectFaculty(widget.faculty);
    provider.selectDepartment(widget.department);
    provider.selectLevel(widget.level);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildResourcesList(),
            ),
          ],
        ),
      ),
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
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Iconify(
              Ph.arrow_left,
              color: AppTheme.textPrimary,
              size: 24.sp,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.department,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  widget.level,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadData,
            child: Iconify(
              Ph.arrows_clockwise,
              color: AppTheme.textPrimary,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesList() {
    return Consumer<ResourceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingResources) {
          return _buildLoadingState('Loading resources...');
        }

        final resources = provider.resources;

        if (resources.isEmpty) {
          return _buildEmptyState(
            icon: Ph.files,
            title: 'No Resources Yet',
            subtitle: 'Be the first to upload a resource for this level',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          color: AppTheme.primary,
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: ResourceTile(
                  resource: resource,
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
                  onDownload: () {
                    provider.incrementDownloadCount(resource.id);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(String message) {
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
            message,
            style: TextConstants.mediumText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required String icon,
    required String title,
    required String subtitle,
  }) {
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
                icon,
                size: 48.sp,
                color: AppTheme.textLight,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: TextConstants.mediumText.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextConstants.smallText.copyWith(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
