import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/resource_model.dart';
import 'package:campcon/main/provider/resource_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/task_detail_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class CategoryTasksScreen extends StatelessWidget {
  final String category;
  final Color color;
  final IconData icon;

  const CategoryTasksScreen({
    Key? key,
    required this.category,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Consumer<ResourceProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingTasks) {
                    return _buildLoadingState();
                  }

                  final tasks = provider.getTasksByCategory(category);
                  final publicTasks =
                      tasks.where((t) => !t.isPersonal).toList();
                  final personalTasks = tasks
                      .where((t) =>
                          t.isPersonal && t.userId == provider.currentUserId)
                      .toList();

                  if (tasks.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      if (provider.currentUserId != null) {
                        await provider.loadTasks(provider.currentUserId!);
                      }
                    },
                    color: color,
                    child: ListView(
                      padding: EdgeInsets.all(16.w),
                      children: [
                        // Public tasks section
                        if (publicTasks.isNotEmpty) ...[
                          _buildSectionHeader(
                            icon: Ph.globe,
                            title: 'Public Tasks',
                            count: publicTasks.length,
                            sectionColor: AppTheme.primary,
                          ),
                          SizedBox(height: 12.h),
                          _buildTaskGrid(publicTasks
                              .map((task) => _buildTaskItem(
                                  context, task, provider,
                                  isPublic: true))
                              .toList()),
                          SizedBox(height: 24.h),
                        ],

                        // Personal tasks section
                        if (personalTasks.isNotEmpty) ...[
                          _buildSectionHeader(
                            icon: Ph.lock_simple,
                            title: 'Personal Tasks',
                            count: personalTasks.length,
                            sectionColor: AppTheme.textSecondary,
                          ),
                          SizedBox(height: 12.h),
                          _buildTaskGrid(personalTasks
                              .map((task) =>
                                  _buildTaskItem(context, task, provider))
                              .toList()),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          // SizedBox(width: 12.w),
          // Container(
          //   padding: EdgeInsets.all(10.w),
          //   decoration: BoxDecoration(
          //     color: color.withValues(alpha: 0.1),
          //     borderRadius: BorderRadius.circular(10.r),
          //   ),
          //   child: Icon(
          //     icon,
          //     size: 22.sp,
          //     color: color,
          //   ),
          // ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Tasks',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String icon,
    required String title,
    required int count,
    required Color sectionColor,
  }) {
    return Row(
      children: [
        // Iconify(
        //   icon,
        //   size: 18.sp,
        //   color: sectionColor,
        // ),
        // SizedBox(width: 8.w),
        Text(
          title,
          style: TextConstants.mediumText.copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: sectionColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            count.toString(),
            style: TextConstants.smallText.copyWith(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: sectionColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskGrid(List<Widget> items) {
    final List<Widget> rows = [];
    for (int i = 0; i < items.length; i += 2) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: items[i]),
            SizedBox(width: 10.w),
            if (i + 1 < items.length)
              Expanded(child: items[i + 1])
            else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildTaskItem(
      BuildContext context, TaskModel task, ResourceProvider provider,
      {bool isPublic = false}) {
    return TaskTile(
      task: task,
      currentUserId: provider.currentUserId,
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: TaskDetailScreen(
              task: task,
              currentUserId: provider.currentUserId,
            ),
          ),
        );
      },
      // Public tasks are informational only — no completion toggle
      onToggleComplete: isPublic
          ? null
          : () {
              provider.toggleTaskCompletion(task.id, !task.isCompleted);
            },
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
              color: color,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading tasks...',
            style: TextConstants.mediumText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48.sp,
                color: color,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No Tasks in $category',
              style: TextConstants.mediumText.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Create a task and assign it to this category',
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
