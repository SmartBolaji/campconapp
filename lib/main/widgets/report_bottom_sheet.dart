import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReportBottomSheet extends StatefulWidget {
  final ReportType reportType;
  final String targetId;
  final String targetTitle;
  final String? targetDescription;
  final String? targetLocation;
  final String? targetImageUrl;
  final String reporterId;
  final String reporterName;
  final String? reporterProfileImage;
  final String? school;

  const ReportBottomSheet({
    super.key,
    required this.reportType,
    required this.targetId,
    required this.targetTitle,
    this.targetDescription,
    this.targetLocation,
    this.targetImageUrl,
    required this.reporterId,
    required this.reporterName,
    this.reporterProfileImage,
    this.school,
  });

  static Future<void> show({
    required BuildContext context,
    required ReportType reportType,
    required String targetId,
    required String targetTitle,
    String? targetDescription,
    String? targetLocation,
    String? targetImageUrl,
    required String reporterId,
    required String reporterName,
    String? reporterProfileImage,
    required String school,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportBottomSheet(
        reportType: reportType,
        targetId: targetId,
        targetTitle: targetTitle,
        targetDescription: targetDescription,
        targetLocation: targetLocation,
        targetImageUrl: targetImageUrl,
        reporterId: reporterId,
        reporterName: reporterName,
        reporterProfileImage: reporterProfileImage,
        school: school,
      ),
    );
  }

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;
  bool _submitted = false;

  List<String> get _reasons {
    switch (widget.reportType) {
      case ReportType.post:
        return ReportReasons.postReasons;
      case ReportType.event:
        return ReportReasons.eventReasons;
      case ReportType.product:
        return ReportReasons.productReasons;
    }
  }

  String get _typeLabel {
    switch (widget.reportType) {
      case ReportType.post:
        return 'Post';
      case ReportType.event:
        return 'Event';
      case ReportType.product:
        return 'Product';
    }
  }

  Future<void> _submit() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final docRef = FirebaseFirestore.instance.collection('reports').doc();

      final report = ReportModel(
        reportId: docRef.id,
        reportType: widget.reportType,
        targetId: widget.targetId,
        targetTitle: widget.targetTitle,
        targetDescription: widget.targetDescription,
        targetLocation: widget.targetLocation,
        targetImageUrl: widget.targetImageUrl,
        reporterId: widget.reporterId,
        reporterName: widget.reporterName,
        reporterProfileImage: widget.reporterProfileImage,
        reason: _selectedReason!,
        additionalDetails: _detailsController.text.trim().isEmpty
            ? null
            : _detailsController.text.trim(),
        status: ReportStatus.pending,
        priority: ReportPriority.medium,
        createdAt: DateTime.now(),
        school: widget.school ?? '',
      );

      await docRef.set(report.toMap());

      setState(() {
        _isSubmitting = false;
        _submitted = true;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── Drag handle ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkTextSecondary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────────────
            Expanded(
              child: _submitted
                  ? _buildSuccessState()
                  : _buildFormState(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormState(ScrollController controller) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightPrimaryBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.flag_rounded,
                  color: AppColors.lightPrimary, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report $_typeLabel',
                  style: TextConstants.mediumText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Help us keep Campcon safe',
                  style: TextConstants.smallText.copyWith(
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Target preview card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.lightPrimaryBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.targetTitle,
                  style: TextConstants.smallText.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.targetDescription != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.targetDescription!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextConstants.smallText.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ],
              // if (widget.targetLocation != null) ...[
              //   const SizedBox(height: 6),
              //   Row(
              //     children: [
              //       Icon(Icons.location_on,
              //           size: 13, color: AppColors.darkPrimary),
              //       const SizedBox(width: 4),
              //       Text(
              //         widget.targetLocation!,
              //         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              //       ),
              //     ],
              //   ),
              // ],
            ],
          ),
        ),

        const SizedBox(height: 22),

        Text('What\'s the issue?',
            style: TextConstants.smallText.copyWith(
              fontWeight: FontWeight.w600,
            )),
        SizedBox(height: 8.h),

        // Reason chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _reasons.map((reason) {
            final selected = _selectedReason == reason;
            return GestureDetector(
              onTap: () => setState(() => _selectedReason = reason),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? AppColors.lightPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color:
                        selected ? AppColors.darkPrimary : Colors.grey.shade300,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  reason,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: selected
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        SizedBox(height: 18.h),

        // Additional details
        Text('Additional details (optional)',
            style: TextConstants.smallText.copyWith(
              fontWeight: FontWeight.w600,
            )),
        SizedBox(height: 8.h),
        TextField(
          controller: _detailsController,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Describe the issue in more detail...',
            hintStyle: TextConstants.smallText.copyWith(
              fontSize: 12.sp,
              color: AppColors.lightTextSecondary,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.lightBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.lightBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.lightBorder, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),

        const SizedBox(height: 8),
        Text(
          'Reports are reviewed by our admin team. False reports may result in account restrictions.',
          style: TextConstants.smallText.copyWith(
            fontSize: 11.sp,
            color: AppColors.lightTextSecondary,
          ),
        ),

        const SizedBox(height: 20),

        // Submit button
        SizedBox(
          width: double.infinity,
          height: 47.h,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              foregroundColor: AppColors.darkTextPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSubmitting
                ? SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.lightPrimary,
                    ),
                  )
                : Text(
                    'Submit Report',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.lightPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.darkPrimary, size: 46),
            ),
            const SizedBox(height: 20),
            const Text(
              'Report Submitted',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Our admin team will review this $_typeLabel and take appropriate action. Thank you for helping keep Campcon safe.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  foregroundColor: AppColors.darkTextSecondary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
