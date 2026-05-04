import 'dart:io';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/market_post_provider.dart';
import 'package:campcon/main/widgets/multi_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/widgets/listing_guide_screen.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class PostItemScreen extends StatefulWidget {
  const PostItemScreen({Key? key}) : super(key: key);

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  List<File> _selectedImages = [];
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _discountController = TextEditingController();
  String? _selectedCategory;
  bool _hasStock = true;
  bool _hasDiscount = false;

  final List<String> _categories = [
    'Clothing & Accessories',
    'Books & Stationery',
    'Electronics & Gadgets',
    'Home & Living',
    'Food & Beverages',
    'Beauty & Personal Care',
    'Sports & Outdoors',
    'Art & Collectibles',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ListingGuideScreen.launch(
        context: context,
        type: ListingGuideType.item,
        onContinue: () {},
      );
    });
  }

  double? get _calculatedDiscountedPrice {
    if (!_hasDiscount) return null;

    final price = double.tryParse(_priceController.text.trim());
    final discount = double.tryParse(_discountController.text.trim());

    if (price == null || discount == null || discount <= 0) return null;

    return price - (price * discount / 100);
  }

  Future<void> _postItem() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final marketProvider =
        Provider.of<MarketPostProvider>(context, listen: false);

    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      _showError('User not logged in');
      return;
    }

    if (_nameController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
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

    if (_hasStock) {
      final stock = int.tryParse(_stockController.text.trim());
      if (stock == null || stock <= 0) {
        _showError('Please enter valid stock quantity');
        return;
      }
    }

    if (_hasDiscount) {
      final discount = double.tryParse(_discountController.text.trim());
      if (discount == null || discount <= 0 || discount >= 100) {
        _showError('Please enter valid discount (1-99%)');
        return;
      }
    }

    FocusScope.of(context).unfocus();

    // Capture values - create copy of images list
    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();
    final category = _selectedCategory!;
    final images = List<File>.from(_selectedImages);
    final stock = _hasStock ? int.tryParse(_stockController.text.trim()) : null;
    final discount =
        _hasDiscount ? double.tryParse(_discountController.text.trim()) : null;

    // Clear form
    _nameController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _stockController.clear();
    _discountController.clear();
    setState(() {
      _selectedImages = [];
      _selectedCategory = null;
      _hasStock = true;
      _hasDiscount = false;
    });

    Navigator.of(context).pop();

    final success = await marketProvider.postItemSilently(
      userId: currentUser.uid,
      name: name,
      location: location,
      description: description,
      category: category,
      price: price,
      stock: stock,
      discount: discount,
      images: images.isNotEmpty ? images : null,
    );

    debugPrint(success ? '✓ Item posted' : '❌ Failed to post item');
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
                      placeholderTitle: 'Add Item Image',
                      placeholderSubtitle: 'Tap to upload',
                    ),
                    SizedBox(height: 20.h),
                    _buildTextField(
                      label: 'Item Name *',
                      controller: _nameController,
                      hint: 'e.g. iPhone 13 Pro Max',
                    ),
                    SizedBox(height: 16.h),
                    _buildCategoryDropdown(),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      label: 'Location *',
                      controller: _locationController,
                      hint: 'e.g. Campus Gate, Hostel Block A',
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      label: 'Description *',
                      controller: _descriptionController,
                      hint: 'Describe your item, condition, features...',
                      maxLines: 4,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      label: 'Price *',
                      controller: _priceController,
                      hint: 'Enter price',
                      keyboardType: TextInputType.number,
                      prefix: '₦',
                    ),
                    SizedBox(height: 20.h),
                    _buildStockSection(),
                    SizedBox(height: 16.h),
                    _buildDiscountSection(),
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
                'List an Item',
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
          'Category *',
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
                'Select category',
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
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _hasStock
            ? AppTheme.primary.withValues(alpha: 0.05)
            : AppTheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _hasStock
              ? AppTheme.primary.withValues(alpha: 0.3)
              : AppTheme.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Iconify(
                Ph.package,
                size: 20.sp,
                color: _hasStock ? AppTheme.primary : AppTheme.textSecondary,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Track Stock',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Set available quantity',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _hasStock,
                onChanged: (value) {
                  setState(() {
                    _hasStock = value;
                    if (!value) _stockController.clear();
                  });
                },
                activeColor: AppTheme.primary,
              ),
            ],
          ),
          if (_hasStock) ...[
            SizedBox(height: 16.h),
            _buildTextField(
              label: 'Stock Quantity *',
              controller: _stockController,
              hint: 'Enter available quantity',
              keyboardType: TextInputType.number,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiscountSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _hasDiscount
            ? AppTheme.success.withValues(alpha: 0.05)
            : AppTheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _hasDiscount
              ? AppTheme.success.withValues(alpha: 0.3)
              : AppTheme.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Iconify(
                Ph.percent,
                size: 20.sp,
                color: _hasDiscount ? AppTheme.success : AppTheme.textSecondary,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Discount',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Offer a special price',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _hasDiscount,
                onChanged: (value) {
                  setState(() {
                    _hasDiscount = value;
                    if (!value) _discountController.clear();
                  });
                },
                activeColor: AppTheme.success,
              ),
            ],
          ),
          if (_hasDiscount) ...[
            SizedBox(height: 16.h),
            _buildTextField(
              label: 'Discount Percentage *',
              controller: _discountController,
              hint: 'e.g. 10',
              keyboardType: TextInputType.number,
              prefix: '%',
            ),
            if (_calculatedDiscountedPrice != null) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Price:',
                      style: TextConstants.smallText.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '₦${_calculatedDiscountedPrice!.toStringAsFixed(0)}',
                      style: TextConstants.boldText.copyWith(
                        fontSize: 16.sp,
                        color: AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
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
        onTap: _postItem,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              'Post Item',
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
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _discountController.dispose();
    super.dispose();
  }
}
