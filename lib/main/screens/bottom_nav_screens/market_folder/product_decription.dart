import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/product_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/product_provider.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/order_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class ProductDecription extends StatefulWidget {
  final Product product;

  const ProductDecription({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDecription> createState() => _ProductDecriptionState();
}

class _ProductDecriptionState extends State<ProductDecription> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      productProvider.loadProduct(widget.product);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid ?? '';
    final isSeller = currentUserId == widget.product.sellerId;

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductImage(),
                        Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildNameAndPrice(productProvider),
                              SizedBox(height: 8.h),
                              _buildCategoryAndLocation(),
                              SizedBox(height: 24.h),
                              _buildDescription(),
                              SizedBox(height: 24.h),

                              // Seller Information
                              _buildSellerInfo(productProvider),
                              SizedBox(height: 24.h),

                              // Item-specific options
                              if (widget.product.isItem && !isSeller) ...[
                                _buildQuantitySelector(productProvider),
                                SizedBox(height: 20.h),
                                _buildPickupLocationSelector(productProvider),
                                SizedBox(height: 20.h),
                                _buildPaymentMethodSelector(productProvider),
                                if (widget.product.isItem &&
                                    productProvider.canProceedToOrder) ...[
                                  SizedBox(height: 20.h),
                                  _buildOrderNotes(productProvider),
                                ],
                              ],

                              // Service-specific info
                              if (!widget.product.isItem && !isSeller) ...[
                                _buildServiceInfo(),
                              ],
                              _buildBottomAction(
                                  isSeller, productProvider, currentUserId),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            onTap: () {
              final productProvider =
                  Provider.of<ProductProvider>(context, listen: false);
              productProvider.reset();
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Iconify(
                Ph.arrow_left,
                color: AppTheme.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                widget.product.isItem ? 'Item Details' : 'Service Details',
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

  Widget _buildProductImage() {
    return Container(
      height: 320.h,
      width: double.infinity,
      color: AppTheme.buttonBorder,
      child: widget.product.imageFile != null
          ? Image.file(
              widget.product.imageFile!,
              fit: BoxFit.cover,
            )
          : widget.product.imageUrl != null
              ? Image.network(
                  widget.product.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(),
                )
              : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(
            widget.product.isItem ? Ph.shopping_bag : Ph.briefcase,
            size: 80.sp,
            color: AppTheme.primary.withOpacity(0.3),
          ),
          SizedBox(height: 12.h),
          Text(
            'No image available',
            style: TextConstants.smallText.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameAndPrice(ProductProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: TextConstants.boldText.copyWith(
            fontSize: 22.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),

        // Show wage type for services
        if (!widget.product.isItem && widget.product.wageType != null) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Iconify(
                  _getWageIcon(widget.product.wageType!),
                  size: 16.sp,
                  color: AppTheme.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  _getWageTypeDisplay(widget.product.wageType!),
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
        ],

        // Price with discount
        Row(
          children: [
            // Current price (with quantity for items)
            if (widget.product.isItem) ...[
              Text(
                provider.quantity > 1
                    ? '${widget.product.formattedPrice} × ${provider.quantity}'
                    : widget.product.formattedPrice,
                style: TextConstants.mediumText.copyWith(
                  fontSize: widget.product.discount != null ? 20.sp : 18.sp,
                  fontWeight: widget.product.discount != null
                      ? FontWeight.bold
                      : FontWeight.w600,
                  color: widget.product.discount != null
                      ? AppTheme.success
                      : AppTheme.textSecondary,
                ),
              ),
              if (provider.quantity > 1) ...[
                SizedBox(width: 8.w),
                Text(
                  '= ${_formatPrice(provider.totalPrice)}',
                  style: TextConstants.boldText.copyWith(
                    fontSize: 20.sp,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ] else ...[
              // Service price with wage label
              Text(
                widget.product.priceLabel ?? widget.product.formattedPrice,
                style: TextConstants.boldText.copyWith(
                  fontSize: 20.sp,
                  color: AppTheme.primary,
                ),
              ),
            ],

            // Original price (if discounted)
            if (widget.product.discount != null &&
                widget.product.discount! > 0) ...[
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.originalPriceFormatted,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 14.sp,
                      color: AppTheme.textLight,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppTheme.textLight,
                      decorationThickness: 2,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '${widget.product.discount!.toInt()}% OFF',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),

        // Stock info for items
        if (widget.product.isItem && widget.product.stock != null) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: widget.product.stock! > 0
                  ? AppTheme.primary.withOpacity(0.05)
                  : AppTheme.error.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: widget.product.stock! > 0
                    ? AppTheme.primary.withOpacity(0.3)
                    : AppTheme.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Iconify(
                  Ph.package,
                  size: 16.sp,
                  color: widget.product.stock! > 0
                      ? AppTheme.primary
                      : AppTheme.error,
                ),
                SizedBox(width: 8.w),
                Text(
                  widget.product.stock! > 0
                      ? '${widget.product.stock} in stock'
                      : 'Out of stock',
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: widget.product.stock! > 0
                        ? AppTheme.primary
                        : AppTheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatPrice(double price) {
    return '₦${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  Widget _buildCategoryAndLocation() {
    return Row(
      children: [
        Iconify(
          Ph.map_pin,
          size: 18.sp,
          color: AppTheme.textSecondary,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            widget.product.location,
            style: TextConstants.smallText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            children: [
              Icon(
                widget.product.isItem
                    ? Icons.shopping_bag_outlined
                    : Icons.work_outline,
                size: 14.sp,
                color: AppTheme.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                widget.product.category,
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextConstants.boldText.copyWith(
            fontSize: 16.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          widget.product.description,
          style: TextConstants.smallText.copyWith(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSellerInfo(ProductProvider provider) {
    if (provider.isLoadingSeller) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28.r,
              backgroundColor: AppTheme.buttonBorder,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12.h,
                    width: 60.w,
                    color: AppTheme.buttonBorder,
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    height: 16.h,
                    width: 120.w,
                    color: AppTheme.buttonBorder,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final seller = provider.sellerData;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            backgroundImage: seller?.profileImageUrl != null &&
                    seller!.profileImageUrl!.isNotEmpty
                ? NetworkImage(seller.profileImageUrl!)
                : null,
            child:
                seller?.profileImageUrl == null || seller!.profileImageUrl == ''
                    ? Iconify(
                        Ph.user,
                        color: AppTheme.primary,
                        size: 28.sp,
                      )
                    : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.isItem ? 'Seller' : 'Service Provider',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.textLight,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  seller?.fullName ?? 'Loading...',
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (seller?.bio != null && seller!.bio!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    seller.bio!,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Navigate to seller profile
            },
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Iconify(
                Ph.arrow_right,
                color: AppTheme.textSecondary,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(ProductProvider provider) {
    final maxQuantity = widget.product.stock ?? 99;
    final isOutOfStock = maxQuantity <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quantity',
              style: TextConstants.boldText.copyWith(
                fontSize: 16.sp,
                color: AppTheme.textPrimary,
              ),
            ),
            if (widget.product.stock != null)
              Text(
                'Max: $maxQuantity',
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        if (isOutOfStock)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Iconify(
                  Ph.warning,
                  color: AppTheme.error,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'This item is currently out of stock',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 14.sp,
                      color: AppTheme.error,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: provider.decrementQuantity,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: provider.quantity > 1
                          ? AppTheme.primary
                          : AppTheme.buttonBorder,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Iconify(
                      Ph.minus,
                      color: provider.quantity > 1
                          ? AppTheme.white
                          : AppTheme.textLight,
                      size: 16.sp,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${provider.quantity}',
                      style: TextConstants.boldText.copyWith(
                        fontSize: 18.sp,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: provider.quantity < maxQuantity
                      ? provider.incrementQuantity
                      : null,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: provider.quantity < maxQuantity
                          ? AppTheme.primary
                          : AppTheme.buttonBorder,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Iconify(
                      Ph.plus,
                      color: provider.quantity < maxQuantity
                          ? AppTheme.white
                          : AppTheme.textLight,
                      size: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPickupLocationSelector(ProductProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Iconify(
              Ph.map_pin,
              size: 18.sp,
              color: AppTheme.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              'Pickup Location',
              style: TextConstants.boldText.copyWith(
                fontSize: 16.sp,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: provider.selectedPickupLocation,
              hint: Text(
                'Select pickup location',
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
                fontSize: 14.sp,
                color: AppTheme.textPrimary,
              ),
              dropdownColor: AppTheme.surface,
              items: provider.pickupLocations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: provider.setPickupLocation,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector(ProductProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Iconify(
              Ph.credit_card,
              size: 18.sp,
              color: AppTheme.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              'Payment Method',
              style: TextConstants.boldText.copyWith(
                fontSize: 16.sp,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...provider.paymentMethods.map((method) {
          final isSelected = provider.selectedPaymentMethod == method.id;
          return GestureDetector(
            onTap: () => provider.setPaymentMethod(method.id),
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withOpacity(0.1)
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
                          ? AppTheme.primary.withOpacity(0.2)
                          : AppTheme.buttonBorder,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Iconify(
                      method.id == 'online' ? Ph.credit_card : Ph.money,
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
                          method.title,
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 15.sp,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          method.subtitle,
                          style: TextConstants.smallText.copyWith(
                            fontSize: 12.sp,
                            color: AppTheme.textSecondary,
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

  Widget _buildOrderNotes(ProductProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Notes (Optional)',
          style: TextConstants.boldText.copyWith(
            fontSize: 16.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.border),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            maxLength: 200,
            style: TextConstants.mediumText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Add any special instructions...',
              hintStyle: TextConstants.smallText.copyWith(
                color: AppTheme.textLight,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.w),
              counterStyle: TextConstants.smallText.copyWith(
                fontSize: 12.sp,
                color: AppTheme.textLight,
              ),
            ),
            onChanged: provider.setOrderNotes,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Iconify(
                Ph.info,
                color: AppTheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Service Information',
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Wage Type Info
          if (widget.product.wageType != null)
            _buildInfoRow(
              icon: _getWageIcon(widget.product.wageType!),
              label: 'Rate',
              value: _getWageTypeDisplay(widget.product.wageType!),
            ),
          if (widget.product.wageType != null) SizedBox(height: 8.h),

          _buildInfoRow(
            icon: Ph.clock,
            label: 'Duration',
            value: 'Discuss with provider',
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            icon: Ph.shield_check,
            label: 'Protection',
            value: 'Secure escrow available',
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            icon: Ph.chat_circle_dots,
            label: 'Contact',
            value: 'Message to discuss details',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Iconify(
          icon,
          size: 16.sp,
          color: AppTheme.textSecondary,
        ),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextConstants.smallText.copyWith(
            fontSize: 13.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextConstants.smallText.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(
    bool isSeller,
    ProductProvider provider,
    String currentUserId,
  ) {
    final isOutOfStock =
        widget.product.stock != null && widget.product.stock! <= 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: isSeller
          ? Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Edit Listing',
                    onPressed: () {
                      // TODO: Implement edit
                    },
                    backgroundColor: AppTheme.buttonBorder,
                    textColor: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    text: 'View Orders',
                    onPressed: () {
                      // TODO: Implement orders
                    },
                    backgroundColor: AppTheme.primary,
                    textColor: AppTheme.white,
                  ),
                ),
              ],
            )
          : widget.product.isItem
              ? CustomButton(
                  text: isOutOfStock ? 'Out of Stock' : 'Buy Now',
                  icon: isOutOfStock ? null : Ph.shopping_cart,
                  onPressed: isOutOfStock
                      ? () {}
                      : provider.canProceedToOrder
                          ? () {
                              if (provider.canProceedToOrder) {
                                OrderSummarySheet.show(
                                  context,
                                  productName: widget.product.name,
                                  quantity: provider.quantity,
                                  unitPrice: widget.product.formattedPrice,
                                  totalPrice: _formatPrice(provider.totalPrice),
                                  pickupLocation:
                                      provider.selectedPickupLocation!,
                                  paymentMethod:
                                      provider.selectedPaymentMethod!,
                                  orderNotes: provider.orderNotes.isNotEmpty
                                      ? provider.orderNotes
                                      : null,
                                  productProvider: provider,
                                  buyerId: currentUserId,
                                );
                              } else {
                                _openChat(provider);
                              }
                            }
                          : () {},
                  backgroundColor: isOutOfStock
                      ? AppTheme.buttonBorder
                      : provider.canProceedToOrder
                          ? AppTheme.primary
                          : AppTheme.buttonBorder,
                  textColor: isOutOfStock
                      ? AppTheme.textLight
                      : provider.canProceedToOrder
                          ? AppTheme.white
                          : AppTheme.textLight,
                )
              : CustomButton(
                  text: 'Message Provider',
                  onPressed: () => _openChat(provider),
                  backgroundColor: AppTheme.primary,
                  textColor: AppTheme.white,
                ),
    );
  }

  void _openChat(ProductProvider provider) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ChatScreen(
    //       recipientName: provider.sellerData?.fullName ?? 'Seller',
    //       productName: widget.product.name,
    //       isOrderChat: true,
    //       conversationId: widget.product.id,
    //     ),
    //   ),
    // );
  }

  String _getWageIcon(String wageType) {
    switch (wageType) {
      case 'hourly':
        return Ph.clock;
      case 'daily':
        return Ph.calendar;
      case 'weekly':
        return Ph.calendar_check;
      case 'monthly':
        return Ph.calendar_blank;
      case 'onetime':
        return Ph.currency_circle_dollar;
      default:
        return Ph.clock;
    }
  }

  String _getWageTypeDisplay(String wageType) {
    switch (wageType) {
      case 'hourly':
        return 'Hourly Rate';
      case 'daily':
        return 'Daily Rate';
      case 'weekly':
        return 'Weekly Rate';
      case 'monthly':
        return 'Monthly Rate';
      case 'onetime':
        return 'One-time Fee';
      default:
        return 'Payment';
    }
  }
}
