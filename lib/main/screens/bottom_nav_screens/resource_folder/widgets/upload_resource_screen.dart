import 'dart:io';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/constants/vars_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/resource_post_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class UploadResourceScreen extends StatelessWidget {
  const UploadResourceScreen({Key? key}) : super(key: key);

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
                        // Upload Mode Toggle
                        _buildUploadModeToggle(provider),
                        SizedBox(height: 20.h),

                        // File Upload or URL Input Section
                        if (provider.isFileUpload)
                          _buildFileUpload(context, provider)
                        else
                          _buildUrlInput(provider),
                        SizedBox(height: 24.h),

                        // Title Field
                        _buildTextField(
                          label: 'Title *',
                          controller: provider.titleController,
                          hint: 'Enter resource title...',
                        ),
                        SizedBox(height: 20.h),

                        // Resource Type Dropdown
                        _buildDropdown(
                          context: context,
                          label: 'Resource Type *',
                          value: provider.selectedResourceType,
                          items: provider.resourceTypes,
                          hint: 'Select resource type',
                          onChanged: (value) =>
                              provider.setSelectedResourceType(value),
                        ),
                        SizedBox(height: 20.h),

                        // Faculty Dropdown
                        _buildFacultyDropdown(context, provider),
                        SizedBox(height: 20.h),

                        // Department Dropdown (only show if faculty is selected)
                        if (provider.selectedFaculty != null)
                          Column(
                            children: [
                              _buildDepartmentDropdown(context, provider),
                              SizedBox(height: 20.h),
                            ],
                          ),

                        // Level Dropdown
                        _buildLevelDropdown(context, provider),
                        SizedBox(height: 20.h),

                        // Course Field
                        _buildTextField(
                          label: 'Course Code (Optional)',
                          controller: TextEditingController(
                              text: provider.selectedCourse ?? ''),
                          hint: 'e.g., CSC 201',
                          onChanged: (value) =>
                              provider.setSelectedCourse(value),
                        ),
                        SizedBox(height: 20.h),

                        // Description Field
                        _buildTextField(
                          label: 'Description (Optional)',
                          controller: provider.descriptionController,
                          hint: 'Add a description for this resource...',
                          maxLines: 4,
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
                _buildUploadButton(context, provider),
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
              provider.resetResourceForm();
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
                'Upload Resource',
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

  Widget _buildUploadModeToggle(ResourcePostProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Share Method',
        //   style: TextConstants.mediumText.copyWith(
        //     fontSize: 14.sp,
        //     fontWeight: FontWeight.w600,
        //     color: AppTheme.textPrimary,
        //   ),
        // ),
        // SizedBox(height: 12.h),
        Row(
          children: [
            // Upload File Option
            Expanded(
              child: GestureDetector(
                onTap: () => provider.setUploadMode(true),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: provider.isFileUpload
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: provider.isFileUpload
                          ? AppTheme.primary
                          : AppTheme.border,
                      width: provider.isFileUpload ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Iconify(
                        Ph.file_arrow_up,
                        size: 22.sp,
                        color: provider.isFileUpload
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upload File',
                              style: TextConstants.mediumText.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: provider.isFileUpload
                                    ? AppTheme.primary
                                    : AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'From device',
                              style: TextConstants.smallText.copyWith(
                                fontSize: 11.sp,
                                color: AppTheme.textLight,
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
            // Share URL Option
            Expanded(
              child: GestureDetector(
                onTap: () => provider.setUploadMode(false),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: !provider.isFileUpload
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: !provider.isFileUpload
                          ? AppTheme.primary
                          : AppTheme.border,
                      width: !provider.isFileUpload ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Iconify(
                        Ph.link,
                        size: 22.sp,
                        color: !provider.isFileUpload
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share URL',
                              style: TextConstants.mediumText.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: !provider.isFileUpload
                                    ? AppTheme.primary
                                    : AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Drive, Dropbox...',
                              style: TextConstants.smallText.copyWith(
                                fontSize: 11.sp,
                                color: AppTheme.textLight,
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

  Widget _buildUrlInput(ResourcePostProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File URL *',
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
            border: Border.all(
              color: provider.fileUrlController.text.isNotEmpty
                  ? AppTheme.primary.withValues(alpha: 0.5)
                  : AppTheme.border,
            ),
          ),
          child: TextField(
            controller: provider.fileUrlController,
            style: TextConstants.mediumText.copyWith(
              fontSize: 15.sp,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'https://drive.google.com/...',
              hintStyle: TextConstants.mediumText.copyWith(
                fontSize: 15.sp,
                color: AppTheme.textLight,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(14.w),
                child: Iconify(
                  Ph.link,
                  size: 20.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Paste a link to Google Drive, Dropbox, OneDrive, or any file hosting service',
          style: TextConstants.smallText.copyWith(
            fontSize: 12.sp,
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildFileUpload(BuildContext context, ResourcePostProvider provider) {
    return GestureDetector(
      onTap: () => _pickFile(context, provider),
      child: Container(
        height: 160.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: provider.selectedFile != null
                ? AppTheme.primary.withValues(alpha: 0.5)
                : AppTheme.border,
            width: 1.5,
          ),
        ),
        child: provider.selectedFile != null
            ? Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Iconify(
                            _getFileIcon(provider.fileName ?? ''),
                            size: 40.sp,
                            color: AppTheme.primary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Text(
                            provider.fileName ?? 'File selected',
                            style: TextConstants.mediumText.copyWith(
                              fontSize: 14.sp,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: () => provider.clearSelectedFile(),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Iconify(
                    Ph.file_arrow_up,
                    size: 48.sp,
                    color: AppTheme.textLight,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Upload File',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 16.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'PDF, DOC, PPT, etc.',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 13.sp,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Ph.file_pdf;
      case 'doc':
      case 'docx':
        return Ph.file_doc;
      case 'ppt':
      case 'pptx':
        return Ph.file_ppt;
      case 'xls':
      case 'xlsx':
        return Ph.file_xls;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Ph.file_image;
      case 'zip':
      case 'rar':
        return Ph.file_zip;
      default:
        return Ph.file;
    }
  }

  Future<void> _pickFile(
      BuildContext context, ResourcePostProvider provider) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'ppt',
          'pptx',
          'xls',
          'xlsx',
          'txt',
          'zip',
          'rar'
        ],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        provider.setSelectedFile(file, name: fileName);
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick file'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
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

  Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
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
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                hint,
                style: TextConstants.mediumText.copyWith(
                  fontSize: 15.sp,
                  color: AppTheme.textLight,
                ),
              ),
              icon: Iconify(
                Ph.caret_down,
                size: 20.sp,
                color: AppTheme.textSecondary,
              ),
              dropdownColor: AppTheme.surface,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 15.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFacultyDropdown(
      BuildContext context, ResourcePostProvider provider) {
    final usableData = UsableData();
    final faculties = usableData.departments
        .map((d) => d['faculty']!)
        .toSet()
        .toList()
      ..sort();

    return _buildDropdown(
      context: context,
      label: 'Faculty (Optional)',
      value: provider.selectedFaculty,
      items: faculties,
      hint: 'Select faculty',
      onChanged: (value) => provider.setSelectedFaculty(value),
    );
  }

  Widget _buildDepartmentDropdown(
      BuildContext context, ResourcePostProvider provider) {
    final usableData = UsableData();
    final departments = usableData.departments
        .where((d) => d['faculty'] == provider.selectedFaculty)
        .map((d) => d['department']!)
        .toList()
      ..sort();

    return _buildDropdown(
      context: context,
      label: 'Department (Optional)',
      value: provider.selectedDepartment,
      items: departments,
      hint: 'Select department',
      onChanged: (value) => provider.setSelectedDepartment(value),
    );
  }

  Widget _buildLevelDropdown(
      BuildContext context, ResourcePostProvider provider) {
    final usableData = UsableData();
    final levels = usableData.levelList;

    return _buildDropdown(
      context: context,
      label: 'Level (Optional)',
      value: provider.selectedLevel,
      items: levels,
      hint: 'Select level',
      onChanged: (value) => provider.setSelectedLevel(value),
    );
  }

  Widget _buildUploadButton(
      BuildContext context, ResourcePostProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: GestureDetector(
        onTap: () => _uploadResource(context, provider),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              'Upload Resource',
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

  Future<void> _uploadResource(
      BuildContext context, ResourcePostProvider provider) async {
    final validationError = provider.validateResourceForm();
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
        SnackBar(
          content: Text('User not logged in'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Store values before closing
    final userId = currentUser.uid;

    // Close screen first
    Navigator.of(context).pop();

    // Start silent upload (BEFORE resetting form)
    final success = await provider.uploadResourceSilently(userId: userId);
    debugPrint(success ? '✓ Resource uploaded' : '❌ Upload failed');

    // Reset form AFTER upload completes
    provider.resetResourceForm();
  }
}
