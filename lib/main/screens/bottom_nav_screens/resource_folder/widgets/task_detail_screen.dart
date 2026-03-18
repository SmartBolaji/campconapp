import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/resource_model.dart';
import 'package:campcon/main/provider/resource_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final isPublic = !task.isPersonal;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isOwner),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),

                    // Status badges row
                    _buildStatusRow(),
                    SizedBox(height: 16.h),

                    // Title
                    Text(
                      task.title,
                      style: TextConstants.boldText.copyWith(
                        fontSize: 22.sp,
                        color: task.isCompleted && !isPublic
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                        decoration: task.isCompleted && !isPublic
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),

                    // Info metadata row
                    if (_hasInfoItems()) ...[
                      SizedBox(height: 12.h),
                      _buildInfoRow(),
                    ],

                    // Due date
                    if (task.dueDate != null) ...[
                      SizedBox(height: 16.h),
                      _buildDueDateRow(),
                    ],

                    // Description
                    if (task.description.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Divider(
                            color: AppTheme.border, height: 1, thickness: 1),
                      ),
                      Text(
                        task.description,
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 14.sp,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],

                    // Settings
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Divider(
                          color: AppTheme.border, height: 1, thickness: 1),
                    ),
                    _buildSettingsSection(context),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            // Only show completion button for personal tasks owned by the user
            if (isOwner && !isPublic) _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isOwner) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Iconify(
              Ph.arrow_left,
              color: AppTheme.textPrimary,
              size: 24.sp,
            ),
          ),
          const Spacer(),
          if (isOwner)
            GestureDetector(
              onTap: () => _showDeleteDialog(context),
              child: Iconify(
                Ph.trash,
                color: AppTheme.error,
                size: 22.sp,
              ),
            ),
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
            color: _getPriorityColor(task.priority).withValues(alpha: 0.15),
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
                ? AppTheme.textSecondary.withValues(alpha: 0.1)
                : AppTheme.primary.withValues(alpha: 0.1),
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
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
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
              color: AppTheme.error.withValues(alpha: 0.15),
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

  Widget _buildDueDateRow() {
    final isOverdue = task.isOverdue && !task.isCompleted;

    return Row(
      children: [
        Iconify(
          Ph.calendar_check,
          size: 16.sp,
          color: isOverdue ? AppTheme.error : AppTheme.textLight,
        ),
        SizedBox(width: 8.w),
        Text(
          DateFormat('EEEE, MMMM d, yyyy').format(task.dueDate!),
          style: TextConstants.mediumText.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isOverdue ? AppTheme.error : AppTheme.textSecondary,
          ),
        ),
        if (task.dueDate!.hour != 0 || task.dueDate!.minute != 0) ...[
          SizedBox(width: 8.w),
          Text(
            '· ${DateFormat('h:mm a').format(task.dueDate!)}',
            style: TextConstants.smallText.copyWith(
              fontSize: 13.sp,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ],
    );
  }

  bool _hasInfoItems() {
    return (task.category != null && task.category!.isNotEmpty) ||
        (task.course != null && task.course!.isNotEmpty) ||
        task.faculty != null ||
        task.department != null ||
        task.level != null;
  }

  Widget _buildInfoRow() {
    final items = <Widget>[];
    if (task.category != null && task.category!.isNotEmpty)
      items.add(_buildInfoItem(Ph.tag, task.category!));
    if (task.course != null && task.course!.isNotEmpty)
      items.add(_buildInfoItem(Ph.book_open, task.course!));
    if (task.faculty != null)
      items.add(_buildInfoItem(Ph.buildings, task.faculty!));
    if (task.department != null)
      items.add(_buildInfoItem(Ph.buildings, task.department!));
    if (task.level != null)
      items.add(_buildInfoItem(Ph.graduation_cap, task.level!));

    return Wrap(spacing: 16.w, runSpacing: 8.h, children: items);
  }

  Widget _buildInfoItem(String icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Iconify(icon, size: 15.sp, color: AppTheme.textLight),
        SizedBox(width: 5.w),
        Text(
          value,
          style: TextConstants.mediumText.copyWith(
            fontSize: 13.sp,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final viewerId = currentUserId ?? FirebaseAuth.instance.currentUser?.uid;

    return Column(
      children: [
        if (!task.isPersonal && viewerId != null)
          _buildPublicTaskReminderRow(viewerId),
        if (!task.isPersonal && viewerId != null) SizedBox(height: 16.h),
        // Reminder
        Row(
          children: [
            Iconify(
              Ph.bell,
              size: 18.sp,
              color: task.hasReminder ? AppTheme.primary : AppTheme.textLight,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Reminder',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Text(
              task.hasReminder ? 'On' : 'Off',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: task.hasReminder ? AppTheme.primary : AppTheme.textLight,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // Created
        Row(
          children: [
            Iconify(
              Ph.clock,
              size: 18.sp,
              color: AppTheme.textLight,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Created',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Text(
              DateFormat('MMM d, yyyy').format(task.createdAt),
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPublicTaskReminderRow(String viewerId) {
    final reminderDoc = FirebaseFirestore.instance
        .collection('taskReminders')
        .doc(task.id)
        .collection('subscribers')
        .doc(viewerId);

    return StreamBuilder<DocumentSnapshot>(
      stream: reminderDoc.snapshots(),
      builder: (context, snapshot) {
        final isSubscribed = snapshot.data?.exists == true;

        return Row(
          children: [
            Iconify(
              Ph.bell_ringing,
              size: 18.sp,
              color: isSubscribed ? AppTheme.primary : AppTheme.textLight,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Set Reminder',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Switch(
              value: isSubscribed,
              activeColor: AppTheme.primary,
              onChanged: (value) async {
                if (value) {
                  await reminderDoc.set({
                    'userId': viewerId,
                    'taskId': task.id,
                    'subscribedAt': FieldValue.serverTimestamp(),
                  });
                } else {
                  await reminderDoc.delete();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Consumer<ResourceProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
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
              padding: EdgeInsets.symmetric(vertical: 14.h),
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
