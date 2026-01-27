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
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: task.isCompleted ? AppTheme.background : AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: task.isOverdue
                ? AppTheme.error.withOpacity(0.5)
                : task.isDueToday
                    ? AppTheme.primary.withOpacity(0.5)
                    : AppTheme.border,
            width: task.isOverdue || task.isDueToday ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            if (onToggleComplete != null && isMyTask)
              GestureDetector(
                onTap: onToggleComplete,
                child: Container(
                  width: 24.w,
                  height: 24.w,
                  margin: EdgeInsets.only(right: 12.w, top: 2.h),
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? AppTheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color:
                          task.isCompleted ? AppTheme.primary : AppTheme.border,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? Icon(
                          Icons.check,
                          size: 16.sp,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with priority and visibility
                  Row(
                    children: [
                      // Priority badge
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color:
                              _getPriorityColor(task.priority).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          task.priority,
                          style: TextConstants.smallText.copyWith(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: _getPriorityColor(task.priority),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Visibility badge
                      if (showVisibilityBadge)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: task.isPersonal
                                ? AppTheme.textSecondary.withOpacity(0.1)
                                : AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Iconify(
                                task.isPersonal ? Ph.lock_simple : Ph.globe,
                                size: 10.sp,
                                color: task.isPersonal
                                    ? AppTheme.textSecondary
                                    : AppTheme.primary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                task.isPersonal ? 'Personal' : 'Public',
                                style: TextConstants.smallText.copyWith(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: task.isPersonal
                                      ? AppTheme.textSecondary
                                      : AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const Spacer(),

                      // Overdue or due today indicator
                      if (task.isOverdue && !task.isCompleted)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Overdue',
                            style: TextConstants.smallText.copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.error,
                            ),
                          ),
                        )
                      else if (task.isDueToday && !task.isCompleted)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Due Today',
                            style: TextConstants.smallText.copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // Title
                  Text(
                    task.title,
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 15.sp,
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
                    SizedBox(height: 6.h),
                    Text(
                      task.description,
                      style: TextConstants.smallText.copyWith(
                        fontSize: 13.sp,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  SizedBox(height: 12.h),

                  // Footer with due date and course
                  Row(
                    children: [
                      // Due date
                      if (task.dueDate != null)
                        Row(
                          children: [
                            Iconify(
                              Ph.calendar,
                              size: 14.sp,
                              color: task.isOverdue && !task.isCompleted
                                  ? AppTheme.error
                                  : AppTheme.textLight,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              DateFormat('MMM d, yyyy').format(task.dueDate!),
                              style: TextConstants.smallText.copyWith(
                                fontSize: 12.sp,
                                color: task.isOverdue && !task.isCompleted
                                    ? AppTheme.error
                                    : AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),

                      if (task.dueDate != null && task.course != null)
                        SizedBox(width: 16.w),

                      // Course code
                      if (task.course != null && task.course!.isNotEmpty)
                        Row(
                          children: [
                            Iconify(
                              Ph.book_open,
                              size: 14.sp,
                              color: AppTheme.textLight,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              task.course!,
                              style: TextConstants.smallText.copyWith(
                                fontSize: 12.sp,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),

                      const Spacer(),

                      // Reminder indicator
                      if (task.hasReminder)
                        Iconify(
                          Ph.bell,
                          size: 16.sp,
                          color: AppTheme.primary,
                        ),
                    ],
                  ),
                ],
              ),
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
