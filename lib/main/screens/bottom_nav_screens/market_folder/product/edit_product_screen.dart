import 'dart:io';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/product_model.dart';
import 'package:campcon/main/provider/market_post_provider.dart';
import 'package:campcon/main/widgets/multi_image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/services/cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _discountController;
  String? _selectedCategory;
  bool _hasStock = true;
  bool _hasDiscount = false;
  bool _isSaving = false;
  String _selectedWageType = 'hourly';

  List<String> _existingImageUrls = [];
  List<File> _newImages = [];

  final List<String> _itemCategories = [
    'Electronics',
    'Books',
    'Clothing',
    'Furniture',
    'Sports',
    'Accessories',
    'Food & Drinks',
    'Health & Beauty',
    'Other',
  ];

  final List<String> _serviceCategories = [
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

  final List<_WageTypeOption> _wageTypes = [
    _WageTypeOption(
      id: 'hourly',
      title: 'Hourly',
      subtitle: 'Per hour rate',
      icon: Ph.clock,
    ),
    _WageTypeOption(
      id: 'daily',
      title: 'Daily',
      subtitle: 'Per day rate',
      icon: Ph.calendar,
    ),
    _WageTypeOption(
      id: 'weekly',
      title: 'Weekly',
      subtitle: 'Per week rate',
      icon: Ph.calendar_check,
    ),
    _WageTypeOption(
      id: 'monthly',
      title: 'Monthly',
      subtitle: 'Per month rate',
      icon: Ph.calendar_blank,
    ),
    _WageTypeOption(
      id: 'onetime',
      title: 'One-time',
      subtitle: 'Fixed price',
      icon: Ph.currency_circle_dollar,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p.name);
    _locationController = TextEditingController(text: p.location);
    _descriptionController = TextEditingController(text: p.description);
    _priceController = TextEditingController(text: p.price.toStringAsFixed(0));
    _stockController = TextEditingController(text: p.stock?.toString() ?? '');
    _discountController =
        TextEditingController(text: p.discount?.toStringAsFixed(0) ?? '');
    _selectedCategory = p.category;
    _hasStock = p.stock != null && p.stock! > 0;
    _hasDiscount = p.discount != null && p.discount! > 0;
    _existingImageUrls = List<String>.from(p.allImageUrls);
    _selectedWageType = p.wageType ?? 'hourly';
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

  List<String> get _categories =>
      widget.product.isItem ? _itemCategories : _serviceCategories;

  double? get _calculatedDiscountedPrice {
    if (!_hasDiscount) return null;

    final price = double.tryParse(_priceController.text.trim());
    final discount = double.tryParse(_discountController.text.trim());

    if (price == null || discount == null || discount <= 0) return null;

    return price - (price * discount / 100);
  }

  String _getPriceLabel() {
    if (widget.product.isItem) return 'Price *';
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
    if (widget.product.isItem) return 'Enter price';
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

  Future<void> _saveChanges() async {
    if (widget.product.isItem && _nameController.text.trim().isEmpty) {
      _showError('Please enter a name');
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

    setState(() => _isSaving = true);

    try {
      final marketProvider =
          Provider.of<MarketPostProvider>(context, listen: false);

      final data = <String, dynamic>{
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': price,
        'category': _selectedCategory,
        'location': _locationController.text.trim(),
        'imageUrls': _existingImageUrls,
        'imageUrl':
            _existingImageUrls.isNotEmpty ? _existingImageUrls.first : null,
      };

      if (widget.product.isItem) {
        if (_hasStock) {
          final stock = int.tryParse(_stockController.text.trim());
          data['stock'] = stock ?? 0;
        } else {
          data['stock'] = null;
        }

        if (_hasDiscount) {
          final discount = double.tryParse(_discountController.text.trim());
          if (discount != null && discount > 0 && discount < 100) {
            data['discount'] = discount;
            data['discountedPrice'] = price - (price * discount / 100);
          }
        } else {
          data['discount'] = null;
          data['discountedPrice'] = null;
        }
      } else {
        data['wageType'] = _selectedWageType;
      }

      final success = await marketProvider.updateProduct(
        widget.product.id,
        data,
        newImages: _newImages.isNotEmpty ? _newImages : null,
        userId: widget.product.sellerId,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing updated successfully!')),
          );
          Navigator.pop(context, true);
        } else {
          _showError('Failed to update listing');
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteListing() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        title: Text('Delete Listing',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Are you sure you want to delete this listing? This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final marketProvider =
        Provider.of<MarketPostProvider>(context, listen: false);
    final success =
        await marketProvider.deleteMarketplaceItem(widget.product.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing deleted')),
        );
        Navigator.pop(context, true);
        Navigator.pop(context);
      } else {
        _showError('Failed to delete listing');
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
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
                    // Existing images
                    if (_existingImageUrls.isNotEmpty) ...[
                      _buildExistingImages(),
                      SizedBox(height: 16.h),
                    ],

                    // Add new images
                    MultiImagePicker(
                      images: _newImages,
                      onImagesChanged: (images) {
                        setState(() => _newImages = images);
                      },
                      placeholderTitle: widget.product.isItem
                          ? 'Add Item Image'
                          : 'Add Service Image',
                      placeholderSubtitle: 'Tap to upload',
                    ),
                    SizedBox(height: 20.h),

                    // Name (items only — services use category as name)
                    if (widget.product.isItem) ...[
                      _buildTextField(
                        label: 'Item Name *',
                        controller: _nameController,
                        hint: 'e.g. iPhone 13 Pro Max',
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // Category
                    _buildCategoryDropdown(),
                    SizedBox(height: 16.h),

                    // Location
                    _buildTextField(
                      label: 'Location *',
                      controller: _locationController,
                      hint: widget.product.isItem
                          ? 'e.g. Campus Gate, Hostel Block A'
                          : 'e.g. Main Campus, Block A',
                    ),
                    SizedBox(height: 16.h),

                    // Service: wage type selector
                    if (!widget.product.isItem) ...[
                      _buildWageTypeSelector(),
                      SizedBox(height: 16.h),
                    ],

                    // Price
                    _buildTextField(
                      label: _getPriceLabel(),
                      controller: _priceController,
                      hint: _getPriceHint(),
                      keyboardType: TextInputType.number,
                      prefix: '₦',
                    ),
                    SizedBox(height: 16.h),

                    // Description
                    _buildTextField(
                      label: 'Description *',
                      controller: _descriptionController,
                      hint: widget.product.isItem
                          ? 'Describe your item, condition, features...'
                          : 'Describe your service, experience, and what you offer...',
                      maxLines: 4,
                    ),

                    // Item-specific: Stock & Discount
                    if (widget.product.isItem) ...[
                      SizedBox(height: 20.h),
                      _buildStockSection(),
                      SizedBox(height: 16.h),
                      _buildDiscountSection(),
                    ],
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
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
                widget.product.isItem ? 'Edit Item' : 'Edit Service',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _deleteListing,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Iconify(
                Ph.trash,
                color: AppTheme.error,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Images',
          style: TextConstants.smallText.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 100.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _existingImageUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: _existingImageUrls[index],
                        cacheManager: CustomCacheManager(),
                        width: 100.w,
                        height: 100.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeExistingImage(index),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
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
          widget.product.isItem ? 'Category *' : 'Service Type *',
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
              value: _categories.contains(_selectedCategory)
                  ? _selectedCategory
                  : null,
              hint: Text(
                widget.product.isItem
                    ? 'Select category'
                    : 'Select service type',
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
        }),
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

  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: GestureDetector(
        onTap: _isSaving ? null : _saveChanges,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: _isSaving
                ? AppTheme.primary.withValues(alpha: 0.6)
                : AppTheme.primary,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: _isSaving
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      color: AppTheme.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Save Changes',
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
}

class _WageTypeOption {
  final String id;
  final String title;
  final String subtitle;
  final String icon;

  _WageTypeOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
