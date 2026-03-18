// lib/main/screens/bottonnavbarscreens/resource_folder/camplist_section.dart
import 'package:campcon/main/provider/resource_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/camplist_item_widget.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/category_tasks_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class CamplistSection extends StatelessWidget {
  const CamplistSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ResourceProvider>(
      builder: (context, provider, child) {
        return _buildCamplistContent(context, provider);
      },
    );
  }

  Widget _buildCamplistContent(
      BuildContext context, ResourceProvider provider) {
    return SliverPadding(
      padding:
          EdgeInsets.only(top: 16.h, bottom: 60.h, left: 20.w, right: 20.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = provider.camplistCategories[index];
            final categoryLabel = category['label'] as String;
            final taskCount = provider.getTaskCountForCategory(categoryLabel);

            return CamplistItemWidget(
              category: category,
              taskCount: taskCount,
              onTap: () => _handleCamplistCategoryTap(context, category),
            );
          },
          childCount: provider.camplistCategories.length,
        ),
      ),
    );
  }

  void _handleCamplistCategoryTap(
      BuildContext context, Map<String, dynamic> category) {
    final label = category['label'] as String;
    final color = category['color'] as Color;
    final icon = category['icon'] as IconData;

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: CategoryTasksScreen(
          category: label,
          color: color,
          icon: icon,
        ),
      ),
    );
  }
}
