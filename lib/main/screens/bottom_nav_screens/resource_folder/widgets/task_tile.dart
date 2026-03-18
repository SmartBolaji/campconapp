import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/resource_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback? onToggleComplete;
  final bool showVisibilityBadge;
  final String? currentUserId;

  const TaskTile({
    Key? key,
    required this.task,
    required this.onTap,
    this.onToggleComplete,
    this.showVisibilityBadge = false,
    this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMyTask = currentUserId != null && task.userId == currentUserId;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: task.isCompleted ? AppTheme.background : AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: task.isOverdue
                ? AppTheme.error.withValues(alpha: 0.5)
                : task.isDueToday
                    ? AppTheme.primary.withValues(alpha: 0.5)
                    : AppTheme.border,
            width: task.isOverdue || task.isDueToday ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with priority and checkbox
            Row(
              children: [
                // Priority badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color:
                        _getPriorityColor(task.priority).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    task.priority,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: _getPriorityColor(task.priority),
                    ),
                  ),
                ),

                // Overdue / due today
                if (task.isOverdue && !task.isCompleted) ...[
                  SizedBox(width: 6.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'Overdue',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.error,
                      ),
                    ),
                  ),
                ] else if (task.isDueToday && !task.isCompleted) ...[
                  SizedBox(width: 6.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'Today',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // Checkbox
                if (onToggleComplete != null && isMyTask)
                  GestureDetector(
                    onTap: onToggleComplete,
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? AppTheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(5.r),
                        border: Border.all(
                          color: task.isCompleted
                              ? AppTheme.primary
                              : AppTheme.border,
                          width: 1.5,
                        ),
                      ),
                      child: task.isCompleted
                          ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10.h),

            // Title
            Text(
              task.title,
              style: TextConstants.mediumText.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: task.isCompleted
                    ? AppTheme.textLight
                    : AppTheme.textPrimary,
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Description
            if (task.description.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                task.description,
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            SizedBox(height: 10.h),

            // Footer
            Row(
              children: [
                if (task.dueDate != null) ...[
                  Iconify(
                    Ph.calendar,
                    size: 12.sp,
                    color: task.isOverdue && !task.isCompleted
                        ? AppTheme.error
                        : AppTheme.textLight,
                  ),
                  SizedBox(width: 3.w),
                  Flexible(
                    child: Text(
                      DateFormat('MMM d').format(task.dueDate!),
                      style: TextConstants.smallText.copyWith(
                        fontSize: 11.sp,
                        color: task.isOverdue && !task.isCompleted
                            ? AppTheme.error
                            : AppTheme.textLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const Spacer(),
                if (task.hasReminder)
                  Iconify(Ph.bell, size: 13.sp, color: AppTheme.primary),
                if (task.course != null && task.course!.isNotEmpty) ...[
                  SizedBox(width: 6.w),
                  Iconify(Ph.book_open, size: 12.sp, color: AppTheme.textLight),
                ],
              ],
            ),
          ],
        ),
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
