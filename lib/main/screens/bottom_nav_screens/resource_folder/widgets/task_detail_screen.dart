import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/resource_model.dart';
import 'package:campcon/main/provider/resource_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;
  final String? currentUserId;

  const TaskDetailScreen({
    Key? key,
    required this.task,
    this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOwner = currentUserId != null && task.userId == currentUserId;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isOwner),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badges row
                    _buildStatusRow(),
                    SizedBox(height: 20.h),

                    // Title
                    Text(
                      task.title,
                      style: TextConstants.boldText.copyWith(
                        fontSize: 22.sp,
                        color: task.isCompleted
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Due date card
                    if (task.dueDate != null) ...[
                      _buildDueDateCard(),
                      SizedBox(height: 20.h),
                    ],

                    // Info cards
                    _buildInfoCards(),
                    SizedBox(height: 24.h),

                    // Description
                    if (task.description.isNotEmpty) ...[
                      _buildSectionTitle('Description'),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(
                          task.description,
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 14.sp,
                            color: AppTheme.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    // Settings
                    _buildSectionTitle('Settings'),
                    SizedBox(height: 8.h),
                    _buildSettingsCards(),
                  ],
                ),
              ),
            ),
            if (isOwner) _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isOwner) {
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
                'Task Details',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          if (isOwner)
            GestureDetector(
              onTap: () => _showDeleteDialog(context),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Iconify(
                  Ph.trash,
                  color: AppTheme.error,
                  size: 20.sp,
                ),
              ),
            )
          else
            SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Wrap(
      spacing: 10.w,
      runSpacing: 8.h,
      children: [
        // Priority badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: _getPriorityColor(task.priority).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                '${task.priority} Priority',
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: _getPriorityColor(task.priority),
                ),
              ),
            ],
          ),
        ),

        // Visibility badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: task.isPersonal
                ? AppTheme.textSecondary.withOpacity(0.1)
                : AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Iconify(
                task.isPersonal ? Ph.lock_simple : Ph.globe,
                size: 14.sp,
                color:
                    task.isPersonal ? AppTheme.textSecondary : AppTheme.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                task.isPersonal ? 'Personal' : 'Public',
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: task.isPersonal
                      ? AppTheme.textSecondary
                      : AppTheme.primary,
                ),
              ),
            ],
          ),
        ),

        // Completion badge
        if (task.isCompleted)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Iconify(
                  Ph.check_circle,
                  size: 14.sp,
                  color: const Color(0xFF10B981),
                ),
                SizedBox(width: 6.w),
                Text(
                  'Completed',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),

        // Overdue badge
        if (task.isOverdue && !task.isCompleted)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Iconify(
                  Ph.warning,
                  size: 14.sp,
                  color: AppTheme.error,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Overdue',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.error,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDueDateCard() {
    final isOverdue = task.isOverdue && !task.isCompleted;
    final isDueToday = task.isDueToday && !task.isCompleted;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isOverdue
            ? AppTheme.error.withOpacity(0.05)
            : isDueToday
                ? AppTheme.primary.withOpacity(0.05)
                : AppTheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isOverdue
              ? AppTheme.error.withOpacity(0.3)
              : isDueToday
                  ? AppTheme.primary.withOpacity(0.3)
                  : AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isOverdue
                  ? AppTheme.error.withOpacity(0.1)
                  : isDueToday
                      ? AppTheme.primary.withOpacity(0.1)
                      : AppTheme.surface,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Iconify(
              Ph.calendar_check,
              size: 28.sp,
              color: isOverdue
                  ? AppTheme.error
                  : isDueToday
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Due Date',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.textLight,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(task.dueDate!),
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isOverdue ? AppTheme.error : AppTheme.textPrimary,
                  ),
                ),
                if (task.dueDate!.hour != 0 || task.dueDate!.minute != 0)
                  Text(
                    DateFormat('h:mm a').format(task.dueDate!),
                    style: TextConstants.smallText.copyWith(
                      fontSize: 13.sp,
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

  Widget _buildInfoCards() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: [
        if (task.category != null && task.category!.isNotEmpty)
          _buildInfoChip(Ph.tag, 'Category', task.category!),
        if (task.course != null && task.course!.isNotEmpty)
          _buildInfoChip(Ph.book_open, 'Course', task.course!),
        if (task.faculty != null)
          _buildInfoChip(Ph.buildings, 'Faculty', task.faculty!),
        if (task.department != null)
          _buildInfoChip(Ph.buildings, 'Department', task.department!),
        if (task.level != null)
          _buildInfoChip(Ph.graduation_cap, 'Level', task.level!),
      ],
    );
  }

  Widget _buildInfoChip(String icon, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Iconify(
            icon,
            size: 16.sp,
            color: AppTheme.primary,
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextConstants.smallText.copyWith(
                  fontSize: 10.sp,
                  color: AppTheme.textLight,
                ),
              ),
              Text(
                value,
                style: TextConstants.mediumText.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextConstants.mediumText.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildSettingsCards() {
    return Column(
      children: [
        // Reminder setting
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Iconify(
                Ph.bell,
                size: 22.sp,
                color: task.hasReminder ? AppTheme.primary : AppTheme.textLight,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminder',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      task.hasReminder ? 'Enabled' : 'Disabled',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: task.hasReminder
                      ? AppTheme.primary.withOpacity(0.1)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  task.hasReminder ? 'ON' : 'OFF',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: task.hasReminder
                        ? AppTheme.primary
                        : AppTheme.textLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        // Created date
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Iconify(
                Ph.clock,
                size: 22.sp,
                color: AppTheme.textLight,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Created',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(task.createdAt),
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
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Consumer<ResourceProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border(
              top: BorderSide(color: AppTheme.border, width: 1),
            ),
          ),
          child: GestureDetector(
            onTap: () {
              provider.toggleTaskCompletion(task.id, !task.isCompleted);
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? AppTheme.textSecondary
                    : AppTheme.primary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Iconify(
                    task.isCompleted ? Ph.arrow_counter_clockwise : Ph.check,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    task.isCompleted
                        ? 'Mark as Incomplete'
                        : 'Mark as Complete',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete Task',
          style: TextConstants.boldText.copyWith(
            fontSize: 18.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
          style: TextConstants.mediumText.copyWith(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextConstants.mediumText.copyWith(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider =
                  Provider.of<ResourceProvider>(context, listen: false);
              final success = await provider.deleteTask(task.id);
              if (success) {
                Navigator.pop(context);
              }
            },
            child: Text(
              'Delete',
              style: TextConstants.mediumText.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return const Color(0xFF10B981);
      case 'Medium':
        return const Color(0xFF0EA5E9);
      case 'High':
        return const Color(0xFFF59E0B);
      case 'Urgent':
        return const Color(0xFFEF4444);
      default:
        return AppTheme.textSecondary;
    }
  }
}
