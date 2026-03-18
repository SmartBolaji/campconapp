import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/resource_post_provider.dart';
import 'package:campcon/main/provider/resource_provider.dart';
import 'package:campcon/main/widgets/themed_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ResourcePostProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, provider),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task Title Field
                        _buildTextField(
                          label: 'Task Title *',
                          controller: provider.taskTitleController,
                          hint: 'Enter task title...',
                        ),
                        SizedBox(height: 20.h),

                        // Category Section
                        _buildCategorySection(context, provider),
                        SizedBox(height: 20.h),

                        // Priority Section
                        _buildPrioritySection(context, provider),
                        SizedBox(height: 20.h),

                        // Due Date & Time Section
                        _buildDueDateTimeSection(context, provider),
                        SizedBox(height: 20.h),

                        // Reminder Toggle
                        _buildReminderSection(provider),
                        SizedBox(height: 20.h),

                        // Visibility Section
                        _buildVisibilitySection(provider),
                        SizedBox(height: 20.h),

                        // Description Field
                        _buildTextField(
                          label: 'Description (Optional)',
                          controller: provider.taskDescriptionController,
                          hint: 'Add task details, instructions, or notes...',
                          maxLines: 5,
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
                _buildAddButton(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ResourcePostProvider provider) {
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
            onTap: () {
              provider.resetTaskForm();
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Iconify(
                Ph.x,
                color: AppTheme.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Add Task',
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextConstants.mediumText.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.border),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: TextConstants.mediumText.copyWith(
              fontSize: 15.sp,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextConstants.mediumText.copyWith(
                fontSize: 15.sp,
                color: AppTheme.textLight,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(
      BuildContext context, ResourcePostProvider provider) {
    final resourceProvider =
        Provider.of<ResourceProvider>(context, listen: false);
    final categories = resourceProvider.camplistCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: TextConstants.mediumText.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: categories.map((category) {
            final label = category['label'] as String;
            final color = category['color'] as Color;
            final icon = category['icon'] as IconData;
            final isSelected = provider.taskCategory == label;

            return GestureDetector(
              onTap: () => provider.setTaskCategory(label),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : AppTheme.background,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? color : AppTheme.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16.sp,
                      color: isSelected ? color : AppTheme.textSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      label,
                      style: TextConstants.smallText.copyWith(
                        fontSize: 13.sp,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? color : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrioritySection(
      BuildContext context, ResourcePostProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: TextConstants.mediumText.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: provider.priorities.map((priority) {
            final isSelected = provider.taskPriority == priority;
            return Expanded(
              child: GestureDetector(
                onTap: () => provider.setTaskPriority(priority),
                child: Container(
                  margin:
                      EdgeInsets.only(right: priority != 'Urgent' ? 8.w : 0),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getPriorityColor(priority).withValues(alpha: 0.15)
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isSelected
                          ? _getPriorityColor(priority)
                          : AppTheme.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      priority,
                      style: TextConstants.smallText.copyWith(
                        fontSize: 13.sp,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? _getPriorityColor(priority)
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
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

  Widget _buildDueDateTimeSection(
      BuildContext context, ResourcePostProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date & Time *',
          style: TextConstants.mediumText.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            // Date Picker
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context, provider),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: provider.taskDueDate != null
                        ? AppTheme.primary.withValues(alpha: 0.05)
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: provider.taskDueDate != null
                          ? AppTheme.primary.withValues(alpha: 0.3)
                          : AppTheme.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Iconify(
                        Ph.calendar,
                        size: 20.sp,
                        color: provider.taskDueDate != null
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        provider.taskDueDate != null
                            ? DateFormat('MMM d, yyyy')
                                .format(provider.taskDueDate!)
                            : 'Select date',
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 14.sp,
                          color: provider.taskDueDate != null
                              ? AppTheme.textPrimary
                              : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Time Picker
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(context, provider),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: provider.taskDueTime != null
                        ? AppTheme.primary.withValues(alpha: 0.05)
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: provider.taskDueTime != null
                          ? AppTheme.primary.withValues(alpha: 0.3)
                          : AppTheme.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Iconify(
                        Ph.clock,
                        size: 20.sp,
                        color: provider.taskDueTime != null
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        provider.taskDueTime != null
                            ? provider.taskDueTime!.format(context)
                            : 'Select time',
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 14.sp,
                          color: provider.taskDueTime != null
                              ? AppTheme.textPrimary
                              : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(
      BuildContext context, ResourcePostProvider provider) async {
    final DateTime? picked = await ThemedPickers.showDate(
      context,
      initialDate: provider.taskDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      provider.setTaskDueDate(picked);
    }
  }

  Future<void> _selectTime(
      BuildContext context, ResourcePostProvider provider) async {
    final TimeOfDay? picked = await ThemedPickers.showTime(
      context,
      initialTime: provider.taskDueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      provider.setTaskDueTime(picked);
    }
  }

  Widget _buildReminderSection(ResourcePostProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: provider.hasReminder
            ? AppTheme.primary.withValues(alpha: 0.05)
            : AppTheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: provider.hasReminder
              ? AppTheme.primary.withValues(alpha: 0.3)
              : AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          Iconify(
            Ph.bell,
            size: 22.sp,
            color: provider.hasReminder
                ? AppTheme.primary
                : AppTheme.textSecondary,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Reminder',
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Get notified before due date',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: provider.hasReminder,
            onChanged: (value) => provider.toggleReminder(value),
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilitySection(ResourcePostProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visibility',
          style: TextConstants.mediumText.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            // Personal (Private) Option
            Expanded(
              child: GestureDetector(
                onTap: () => provider.setTaskVisibility(true),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: provider.isPersonalTask
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: provider.isPersonalTask
                          ? AppTheme.primary
                          : AppTheme.border,
                      width: provider.isPersonalTask ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Iconify(
                        Ph.lock_simple,
                        size: 22.sp,
                        color: provider.isPersonalTask
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal',
                              style: TextConstants.mediumText.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: provider.isPersonalTask
                                    ? AppTheme.primary
                                    : AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Only you can see',
                              style: TextConstants.smallText.copyWith(
                                fontSize: 11.sp,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Public Option
            Expanded(
              child: GestureDetector(
                onTap: () => provider.setTaskVisibility(false),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: !provider.isPersonalTask
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: !provider.isPersonalTask
                          ? AppTheme.primary
                          : AppTheme.border,
                      width: !provider.isPersonalTask ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Iconify(
                        Ph.globe,
                        size: 22.sp,
                        color: !provider.isPersonalTask
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Public',
                              style: TextConstants.mediumText.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: !provider.isPersonalTask
                                    ? AppTheme.primary
                                    : AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Visible to others',
                              style: TextConstants.smallText.copyWith(
                                fontSize: 11.sp,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context, ResourcePostProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: GestureDetector(
        onTap: () => _addTask(context, provider),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              'Add Task',
              style: TextConstants.mediumText.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addTask(
      BuildContext context, ResourcePostProvider provider) async {
    final validationError = provider.validateTaskForm();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Store user id
    final userId = currentUser.uid;

    // Close screen first
    Navigator.of(context).pop();

    // Start silent task creation (BEFORE resetting form)
    final success = await provider.addTaskSilently(userId: userId);
    debugPrint(success ? '✓ Task added' : '❌ Task creation failed');

    // Reset form AFTER task is created
    provider.resetTaskForm();
  }
}
