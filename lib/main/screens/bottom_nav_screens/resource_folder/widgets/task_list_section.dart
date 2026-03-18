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

class TaskListSection extends StatelessWidget {
  final String? currentUserId;
  final String? faculty;
  final String? department;
  final String? level;

  const TaskListSection({
    Key? key,
    this.currentUserId,
    this.faculty,
    this.department,
    this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ResourceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingTasks) {
          return _buildLoadingState();
        }

        final publicTasks = provider.publicTasks;
        final personalTasks = provider.personalTasks;

        if (publicTasks.isEmpty && personalTasks.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Public tasks section
            if (publicTasks.isNotEmpty) ...[
              _buildSectionHeader(
                icon: Ph.globe,
                title: 'Public Tasks',
                count: publicTasks.length,
                color: AppTheme.primary,
              ),
              SizedBox(height: 12.h),
              _buildTaskGrid(publicTasks
                  .map((task) => _buildTaskItem(context, task, isPublic: true))
                  .toList()),
              SizedBox(height: 24.h),
            ],

            // Personal tasks section
            if (personalTasks.isNotEmpty && currentUserId != null) ...[
              _buildSectionHeader(
                icon: Ph.lock_simple,
                title: 'Personal Tasks',
                count: personalTasks.length,
                color: AppTheme.textSecondary,
              ),
              SizedBox(height: 12.h),
              _buildTaskGrid(personalTasks
                  .map((task) => _buildTaskItem(context, task))
                  .toList()),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required String icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        // Iconify(
        //   icon,
        //   size: 18.sp,
        //   color: color,
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
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            count.toString(),
            style: TextConstants.smallText.copyWith(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: color,
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

  Widget _buildTaskItem(BuildContext context, TaskModel task,
      {bool isPublic = false}) {
    return TaskTile(
      task: task,
      currentUserId: currentUserId,
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: TaskDetailScreen(
              task: task,
              currentUserId: currentUserId,
            ),
          ),
        );
      },
      // Public tasks are informational only — no completion toggle
      onToggleComplete: isPublic
          ? null
          : () {
              final provider =
                  Provider.of<ResourceProvider>(context, listen: false);
              provider.toggleTaskCompletion(task.id, !task.isCompleted);
            },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Loading tasks...',
              style: TextConstants.mediumText.copyWith(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                shape: BoxShape.circle,
              ),
              child: Iconify(
                Ph.clipboard_text,
                size: 40.sp,
                color: AppTheme.textLight,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No Tasks Yet',
              style: TextConstants.mediumText.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Create your first task to get started',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Task list screen wrapper
class TaskListScreen extends StatefulWidget {
  final String? currentUserId;
  final String? faculty;
  final String? department;
  final String? level;

  const TaskListScreen({
    Key? key,
    this.currentUserId,
    this.faculty,
    this.department,
    this.level,
  }) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  void _loadTasks() {
    if (widget.currentUserId != null) {
      final provider = Provider.of<ResourceProvider>(context, listen: false);
      provider.loadTasks(widget.currentUserId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _loadTasks(),
                color: AppTheme.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20.w),
                  child: TaskListSection(
                    currentUserId: widget.currentUserId,
                    faculty: widget.faculty,
                    department: widget.department,
                    level: widget.level,
                  ),
                ),
              ),
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
          Expanded(
            child: Center(
              child: Text(
                'Tasks',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }
}
