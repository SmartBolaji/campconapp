// lib/main/screens/bottonnavbarscreens/resource_folder/resource_section.dart
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/resource_provider.dart';
import 'package:campcon/main/widgets/resources/dept_card.dart';
import 'package:campcon/main/widgets/resources/level_card.dart';
import 'package:campcon/main/widgets/resources/faculty_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
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
          Padding(
            padding: EdgeInsets.only(
                left: 30.w, right: 30.w, top: 20.h, bottom: 10.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => provider.clearFacultySelection(),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Iconify(
                      Ph.arrow_left,
                      size: 18.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    provider.selectedFaculty!,
                    style: TextConstants.mediumText.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
          Padding(
            padding: EdgeInsets.only(
                left: 30.w, right: 30.w, top: 20.h, bottom: 10.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => provider.clearDepartmentSelection(),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Iconify(
                      Ph.arrow_left,
                      size: 18.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    provider.selectedDepartment!,
                    style: TextConstants.mediumText.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
                    // TODO: Navigate to courses/materials for this level
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Opening materials for ${provider.selectedDepartment} - $level',
                        ),
                        backgroundColor: AppTheme.primary,
                        behavior: SnackBarBehavior.floating,
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
