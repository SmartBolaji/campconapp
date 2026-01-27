// lib/main/screens/bottonnavbarscreens/resource_folder/resource_section.dart
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/resource_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/dept_card.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/level_card.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/faculty_card.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/resource_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ResourceSection extends StatelessWidget {
  const ResourceSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ResourceProvider>(
      builder: (context, provider, child) {
        return _buildResourceContent(context, provider);
      },
    );
  }

  Widget _buildResourceContent(
      BuildContext context, ResourceProvider provider) {
    // Show levels if department is selected
    if (provider.selectedDepartment != null) {
      return _buildLevelsList(context, provider);
    }

    // Show departments if faculty is selected
    if (provider.selectedFaculty != null) {
      return _buildDepartmentsList(context, provider);
    }

    // Show faculties list as column
    return SliverPadding(
      padding:
          EdgeInsets.only(top: 16.h, bottom: 60.h, left: 20.w, right: 20.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final faculty = provider.faculties[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 0.h),
              child: FacultyCard(
                faculty: faculty,
                onTap: () => provider.selectFaculty(faculty),
              ),
            );
          },
          childCount: provider.faculties.length,
        ),
      ),
    );
  }

  Widget _buildDepartmentsList(
      BuildContext context, ResourceProvider provider) {
    final departments =
        provider.getDepartmentsForFaculty(provider.selectedFaculty!);

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and faculty title
          GestureDetector(
            onTap: () => provider.clearFacultySelection(),
            child: Container(
              padding: EdgeInsets.only(
                  top: 16.h, bottom: 16.h, left: 28.w, right: 20.w),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  Iconify(
                    Ph.arrow_left,
                    size: 20.sp,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      provider.selectedFaculty!,
                      style: TextConstants.smallText.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Departments list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final department = departments[index];
              return buildDepartmentCard(
                context,
                department,
                () => provider.selectDepartment(department),
              );
            },
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildLevelsList(BuildContext context, ResourceProvider provider) {
    final levels = provider.levels;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and department title
          GestureDetector(
            onTap: () => provider.clearDepartmentSelection(),
            child: Container(
              padding: EdgeInsets.only(
                  top: 16.h, bottom: 16.h, left: 28.w, right: 20.w),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  Iconify(
                    Ph.arrow_left,
                    size: 20.sp,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      provider.selectedDepartment!,
                      style: TextConstants.smallText.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Levels list
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                return buildLevelCard(
                  context,
                  level,
                  () {
                    // Navigate to ResourceListScreen
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: ResourceListScreen(
                          faculty: provider.selectedFaculty!,
                          department: provider.selectedDepartment!,
                          level: level,
                          currentUserId: provider.currentUserId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }
}
