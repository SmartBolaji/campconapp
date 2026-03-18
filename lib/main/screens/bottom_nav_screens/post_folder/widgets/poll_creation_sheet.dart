import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/poll_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class PollCreationSheet extends StatefulWidget {
  final Function(PollModel) onPollCreated;

  const PollCreationSheet({
    required this.onPollCreated,
    super.key,
  });

  @override
  State<PollCreationSheet> createState() => _PollCreationSheetState();
}

class _PollCreationSheetState extends State<PollCreationSheet> {
  late TextEditingController _questionController;
  final List<TextEditingController> _optionControllers = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isMultiChoice = false;
  int _optionCount = 2;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 1));

    // Initialize 2 option controllers
    for (int i = 0; i < 2; i++) {
      _optionControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionCount < 4) {
      setState(() {
        _optionControllers.add(TextEditingController());
        _optionCount++;
      });
    }
  }

  void _removeOption(int index) {
    if (_optionCount > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
        _optionCount--;
      });
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _createPoll() {
    final question = _questionController.text.trim();
    final options = _optionControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (question.isEmpty) {
      _showError('Poll question is required');
      return;
    }

    if (options.length < 2) {
      _showError('At least 2 options are required');
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showError('Start and end dates are required');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showError('End date must be after start date');
      return;
    }

    // Create poll
    final poll = PollModel(
      pollId: DateTime.now().millisecondsSinceEpoch.toString(),
      question: question,
      options: options
          .asMap()
          .entries
          .map((e) => PollOption(
                id: e.key.toString(),
                text: e.value,
              ))
          .toList(),
      startDate: _startDate!,
      endDate: _endDate!,
      isMultiChoice: _isMultiChoice,
      createdBy: '', // Will be set by parent
      createdAt: DateTime.now(),
    );

    widget.onPollCreated(poll);
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag indicator
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: AppTheme.border,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Create Poll',
                        style: TextConstants.boldText.copyWith(
                          fontSize: 18.sp,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          color: AppTheme.textSecondary,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Poll Question
                  Text(
                    'Poll Question',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _questionController,
                    maxLines: 2,
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 14.sp,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'What\'s your question?',
                      hintStyle: TextConstants.mediumText.copyWith(
                        color: AppTheme.textLight,
                        fontSize: 14.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppTheme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                            BorderSide(color: AppTheme.primary, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 12.h),
                      filled: true,
                      fillColor: AppTheme.background,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Poll Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Options',
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (_optionCount < 4)
                        GestureDetector(
                          onTap: _addOption,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                Iconify(
                                  Ph.plus,
                                  size: 14.sp,
                                  color: AppTheme.primary,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Add',
                                  style: TextConstants.smallText.copyWith(
                                    fontSize: 12.sp,
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _optionCount,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _optionControllers[index],
                              maxLines: 1,
                              style: TextConstants.mediumText.copyWith(
                                fontSize: 14.sp,
                                color: AppTheme.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Option ${index + 1}',
                                hintStyle: TextConstants.mediumText.copyWith(
                                  color: AppTheme.textLight,
                                  fontSize: 14.sp,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide:
                                      BorderSide(color: AppTheme.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide:
                                      BorderSide(color: AppTheme.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                      color: AppTheme.primary, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 12.h,
                                ),
                                filled: true,
                                fillColor: AppTheme.background,
                              ),
                            ),
                          ),
                          if (_optionCount > 2) ...[
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () => _removeOption(index),
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Iconify(
                                  Ph.x,
                                  size: 16.sp,
                                  color: AppTheme.error,
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Multi-choice toggle
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Allow multiple choices',
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 14.sp,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Switch(
                          value: _isMultiChoice,
                          onChanged: (value) =>
                              setState(() => _isMultiChoice = value),
                          activeColor: AppTheme.primary,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Date pickers
                  Text(
                    'Poll Duration',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDateButton(
                          label: 'Start Date',
                          date: _startDate,
                          onTap: _selectStartDate,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildDateButton(
                          label: 'End Date',
                          date: _endDate,
                          onTap: _selectEndDate,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Create button
                  GestureDetector(
                    onTap: _createPoll,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          'Create Poll',
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final dateStr = date != null ? '${date.day}/${date.month}' : 'Select';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppTheme.background,
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextConstants.smallText.copyWith(
                fontSize: 12.sp,
                color: AppTheme.textLight,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Iconify(
                  Ph.calendar,
                  size: 16.sp,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(width: 6.w),
                Text(
                  dateStr,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
