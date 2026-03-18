// lib/main/screens/bottonnavbarscreens/resource_folder/resource_section.dart
import 'package:campcon/main/provider/resource_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/faculty_card.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/faculty_resources_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ResourceSection extends StatelessWidget {
  const ResourceSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ResourceProvider>(
      builder: (context, provider, child) {
        return _buildFacultiesList(context, provider);
      },
    );
  }

  Widget _buildFacultiesList(BuildContext context, ResourceProvider provider) {
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
                onTap: () {
                  // Navigate to FacultyResourcesScreen
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: FacultyResourcesScreen(
                        faculty: faculty,
                        departments: provider.getDepartmentsForFaculty(faculty),
                        levels: provider.levels,
                        currentUserId: provider.currentUserId,
                      ),
                    ),
                  );
                },
              ),
            );
          },
          childCount: provider.faculties.length,
        ),
      ),
    );
  }
}
