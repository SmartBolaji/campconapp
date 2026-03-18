import 'dart:io';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/market_post_provider.dart';
import 'package:campcon/main/widgets/multi_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class PostServiceScreen extends StatefulWidget {
  const PostServiceScreen({Key? key}) : super(key: key);

  @override
  State<PostServiceScreen> createState() => _PostServiceScreenState();
}

class _PostServiceScreenState extends State<PostServiceScreen> {
  List<File> _selectedImages = [];
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;
  String _selectedWageType = 'hourly';

  final List<String> _categories = [
    'Tutoring',
    'Photography',
    'Design',
    'Writing',
    'Delivery',
    'Repairs',
    'Cleaning',
    'Fitness',
    'Other',
  ];

  final List<WageTypeOption> _wageTypes = [
    WageTypeOption(
      id: 'hourly',
      title: 'Hourly',
      subtitle: 'Per hour rate',
      icon: Ph.clock,
      description: 'Charge per hour of service',
    ),
    WageTypeOption(
      id: 'daily',
      title: 'Daily',
      subtitle: 'Per day rate',
      icon: Ph.calendar,
      description: 'Charge per day of service',
    ),
    WageTypeOption(
      id: 'weekly',
      title: 'Weekly',
      subtitle: 'Per week rate',
      icon: Ph.calendar_check,
      description: 'Charge per week of service',
    ),
    WageTypeOption(
      id: 'monthly',
      title: 'Monthly',
      subtitle: 'Per month rate',
      icon: Ph.calendar_blank,
      description: 'Charge per month of service',
    ),
    WageTypeOption(
      id: 'onetime',
      title: 'One-time',
      subtitle: 'Fixed price',
      icon: Ph.currency_circle_dollar,
      description: 'One-time fixed fee',
    ),
  ];

  String _getPriceLabel() {
    switch (_selectedWageType) {
      case 'hourly':
        return 'Price per hour *';
      case 'daily':
        return 'Price per day *';
      case 'weekly':
        return 'Price per week *';
      case 'monthly':
        return 'Price per month *';
      case 'onetime':
        return 'One-time price *';
      default:
        return 'Price *';
    }
  }

  String _getPriceHint() {
    switch (_selectedWageType) {
      case 'hourly':
        return 'Enter hourly rate';
      case 'daily':
        return 'Enter daily rate';
      case 'weekly':
        return 'Enter weekly rate';
      case 'monthly':
        return 'Enter monthly rate';
      case 'onetime':
        return 'Enter fixed price';
      default:
        return 'Enter price';
    }
  }

  Future<void> _postService() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final marketProvider =
        Provider.of<MarketPostProvider>(context, listen: false);

    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      _showError('User not logged in');
      return;
    }

    if (_locationController.text.trim().isEmpty ||
        _selectedCategory == null ||
        _descriptionController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      _showError('Please fill all required fields');
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      _showError('Please enter a valid price');
      return;
    }

    FocusScope.of(context).unfocus();

    // Capture values - create copy of images list
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();
    final category = _selectedCategory!;
    final images = List<File>.from(_selectedImages);
    final wageType = _selectedWageType;

    // Clear form
    _locationController.clear();
    _descriptionController.clear();
    _priceController.clear();
    setState(() {
      _selectedImages = [];
      _selectedCategory = null;
      _selectedWageType = 'hourly';
    });

    Navigator.of(context).pop();

    final success = await marketProvider.postServiceSilently(
      userId: currentUser.uid,
      location: location,
      description: description,
      category: category,
      price: price,
      wageType: wageType,
      images: images.isNotEmpty ? images : null,
    );

    debugPrint(success ? '✓ Service posted' : '❌ Failed to post service');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Multi-Image Picker
                    MultiImagePicker(
                      images: _selectedImages,
                      onImagesChanged: (images) {
                        setState(() => _selectedImages = images);
                      },
                      placeholderTitle: 'Add Service Image',
                      placeholderSubtitle: 'Tap to upload',
                    ),
                    SizedBox(height: 20.h),
                    _buildCategoryDropdown(),
                    SizedBox(height: 20.h),
                    _buildTextField(
                      label: 'Location *',
                      controller: _locationController,
                      hint: 'e.g. Main Campus, Block A',
                    ),
                    SizedBox(height: 20.h),
                    _buildWageTypeSelector(),
                    SizedBox(height: 20.h),
                    _buildTextField(
                      label: _getPriceLabel(),
                      controller: _priceController,
                      hint: _getPriceHint(),
                      keyboardType: TextInputType.number,
                      prefix: '₦',
                    ),
                    SizedBox(height: 20.h),
                    _buildTextField(
                      label: 'Description *',
                      controller: _descriptionController,
                      hint:
                          'Describe your service, experience, and what you offer...',
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
            ),
            _buildPostButton(),
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
                Ph.x,
                color: AppTheme.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Post Service',
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

  Widget _buildWageTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Iconify(
              Ph.currency_circle_dollar,
              size: 18.sp,
              color: AppTheme.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              'Payment Type *',
              style: TextConstants.boldText.copyWith(
                fontSize: 16.sp,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ..._wageTypes.map((wageType) {
          final isSelected = _selectedWageType == wageType.id;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedWageType = wageType.id);
              _priceController.clear();
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.1)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withValues(alpha: 0.2)
                          : AppTheme.buttonBorder,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Iconify(
                      wageType.icon,
                      size: 20.sp,
                      color: isSelected ? AppTheme.primary : AppTheme.textLight,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wageType.title,
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          wageType.subtitle,
                          style: TextConstants.smallText.copyWith(
                            fontSize: 13.sp,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Iconify(
                      Ph.check_circle_fill,
                      color: AppTheme.primary,
                      size: 22.sp,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextConstants.smallText.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppTheme.buttonBorder,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: Row(
            children: [
              if (prefix != null) ...[
                Text(
                  prefix,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 16.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  keyboardType: keyboardType,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 15.sp,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextConstants.smallText.copyWith(
                      color: AppTheme.textLight,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Type *',
          style: TextConstants.smallText.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppTheme.buttonBorder,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedCategory,
              hint: Text(
                'Select service type',
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
              icon: Iconify(
                Ph.caret_down,
                color: AppTheme.textLight,
                size: 20.sp,
              ),
              style: TextConstants.mediumText.copyWith(
                fontSize: 15.sp,
                color: AppTheme.textPrimary,
              ),
              dropdownColor: AppTheme.surface,
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostButton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: GestureDetector(
        onTap: _postService,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              'Post Service',
              style: TextConstants.mediumText.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

// Wage Type Model
class WageTypeOption {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String description;

  WageTypeOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
  });
}
