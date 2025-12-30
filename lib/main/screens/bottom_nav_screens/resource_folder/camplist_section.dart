// lib/main/screens/bottonnavbarscreens/resource_folder/camplist_section.dart
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/provider/resource_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/camplist_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            return CamplistItemWidget(
              category: category,
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

    // TODO: Navigate to specific category screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $label list'),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
