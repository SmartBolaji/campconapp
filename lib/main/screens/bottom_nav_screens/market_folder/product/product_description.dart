import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/product_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/product_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/product/edit_product_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/product/order_summary_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/product/review_summary.dart';
import 'package:campcon/main/services/navigation_helper.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/product/widgets/widgets.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:timeago/timeago.dart' as timeago;

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
  bool _isDescriptionExpanded = false;

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
          backgroundColor: Theme.of(context).colorScheme.surface,
          bottomNavigationBar: isSeller
              ? _buildFloatingBottomBar(
                  isSeller,
                  productProvider,
                  currentUserId,
                )
              : null,
          floatingActionButton: !isSeller
              ? Padding(
                  padding: EdgeInsets.all(20.w),
                  child: widget.product.isItem
                      ? _buildBuyerItemActionFAB(productProvider, currentUserId)
                      : _buildBuyerServiceFAB(productProvider),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          body: SafeArea(
            child: Column(
              children: [
                ProductHeader(isItem: widget.product.isItem),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProductImage(
                          product: widget.product,
                        ),
                        Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProductPriceInfo(
                                product: widget.product,
                                provider: productProvider,
                              ),
                              SizedBox(height: 8.h),
                              _buildCategoryAndLocation(),
                              SizedBox(height: 24.h),

                              _buildDescription(),
                              SizedBox(height: 24.h),

                              // Seller Information
                              SellerInfoCard(
                                provider: productProvider,
                                isItem: widget.product.isItem,
                              ),
                              SizedBox(height: 12.h),

                              // Metadata under seller
                              _buildCategoryAndMetadata(),
                              SizedBox(height: 24.h),

                              // Reviews section
                              _buildReviewsSection(),
                              SizedBox(height: 24.h),

                              // Item-specific options
                              if (widget.product.isItem && !isSeller) ...[
                                QuantitySelector(
                                  provider: productProvider,
                                  stock: widget.product.stock,
                                ),
                                SizedBox(height: 20.h),
                                PickupLocationSelector(
                                  provider: productProvider,
                                ),
                                SizedBox(height: 20.h),
                                PaymentMethodSelector(
                                  provider: productProvider,
                                ),
                                if (productProvider.canProceedToOrder) ...[
                                  SizedBox(height: 20.h),
                                  _buildOrderNotes(productProvider),
                                ],
                              ],

                              // Service-specific info
                              if (!widget.product.isItem && !isSeller) ...[
                                ServiceInfoCard(
                                  wageType: widget.product.wageType,
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Related products section
                        _buildRelatedProducts(productProvider),
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
      ],
    );
  }

  Widget _buildCategoryAndMetadata() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
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
        SizedBox(width: 12.w),
        Iconify(Ph.clock, size: 16.sp, color: AppTheme.textLight),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            timeago.format(widget.product.createdAt),
            style: TextConstants.smallText.copyWith(
              fontSize: 12.sp,
              color: AppTheme.textLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    final shouldShowMore = widget.product.description.length > 200;

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
        AnimatedCrossFade(
          firstChild: Text(
            widget.product.description,
            style: TextConstants.smallText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            widget.product.description,
            style: TextConstants.smallText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          crossFadeState: _isDescriptionExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        if (shouldShowMore) ...[
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Text(
              _isDescriptionExpanded ? 'Show less' : 'Read more',
              style: TextConstants.mediumText.copyWith(
                fontSize: 14.sp,
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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

  Widget _buildFloatingBottomBar(
    bool isSeller,
    ProductProvider provider,
    String currentUserId,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: _buildSellerActions(),
      ),
    );
  }

  Widget _buildSellerActions() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Edit Listing',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProductScreen(product: widget.product),
                ),
              );
              if (result == true && mounted) {
                Navigator.pop(context);
              }
            },
            backgroundColor: AppTheme.buttonBorder,
            textColor: AppTheme.textPrimary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomButton(
            text: 'Manage Orders',
            onPressed: () {
              NavigationHelper.openSellerOrders(
                context,
                productId: widget.product.id,
                productName: widget.product.name,
              );
            },
            backgroundColor: AppTheme.primary,
            textColor: AppTheme.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBuyerItemActionFAB(
      ProductProvider provider, String currentUserId) {
    final isOutOfStock =
        widget.product.stock != null && widget.product.stock! <= 0;

    if (isOutOfStock) {
      return FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.buttonBorder,
        child: Iconify(
          Ph.shopping_cart,
          size: 22.sp,
          color: AppTheme.textLight,
        ),
      );
    }

    final canBuy = provider.canProceedToOrder;
    if (canBuy) {
      return FloatingActionButton.extended(
        onPressed: () => _showOrderSummary(provider, currentUserId),
        backgroundColor: AppTheme.primary,
        label: Text(
          'Buy — ${_formatPrice(provider.totalPrice)}',
          style: TextConstants.mediumText.copyWith(
            fontSize: 14.sp,
            color: AppTheme.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        icon: Iconify(
          Ph.shopping_cart,
          size: 18.sp,
          color: AppTheme.white,
        ),
      );
    } else {
      return FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.buttonBorder,
        child: Iconify(
          Ph.shopping_cart,
          size: 22.sp,
          color: AppTheme.textLight,
        ),
      );
    }
  }

  Widget _buildBuyerServiceFAB(ProductProvider provider) {
    return FloatingActionButton.extended(
      onPressed: () => _openChat(provider),
      backgroundColor: AppTheme.primary,
      label: Text(
        'Message',
        style: TextConstants.mediumText.copyWith(
          fontSize: 14.sp,
          color: AppTheme.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      icon: Iconify(
        Ph.chat_circle_dots,
        size: 20.sp,
        color: AppTheme.white,
      ),
    );
  }

  void _showOrderSummary(ProductProvider provider, String currentUserId) {
    OrderSummarySheet.show(
      context,
      productName: widget.product.name,
      quantity: provider.quantity,
      unitPrice: widget.product.formattedPrice,
      totalPrice: _formatPrice(provider.totalPrice),
      pickupCenter: provider.selectedPickupCenter!,
      paymentMethod: provider.selectedPaymentMethod!,
      orderNotes: provider.orderNotes.isNotEmpty ? provider.orderNotes : null,
      productProvider: provider,
      buyerId: currentUserId,
    );
  }

  void _openChat(ProductProvider provider) {
    final seller = provider.sellerData;
    if (seller != null) {
      NavigationHelper.openChat(context, otherUser: seller);
    }
  }

  String _formatPrice(double price) {
    return '₦${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  Widget _buildRelatedProducts(ProductProvider provider) {
    if (provider.isLoadingRelated) {
      return Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20.h,
              width: 140.w,
              decoration: BoxDecoration(
                color: AppTheme.buttonBorder,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 200.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (_, __) => Container(
                  width: 160.w,
                  decoration: BoxDecoration(
                    color: AppTheme.buttonBorder,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (provider.relatedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    final title = widget.product.isItem ? 'Similar Items' : 'Similar Services';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            title,
            style: TextConstants.boldText.copyWith(
              fontSize: 18.sp,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 200.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            scrollDirection: Axis.horizontal,
            itemCount: provider.relatedProducts.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final product = provider.relatedProducts[index];
              return _buildRelatedProductCard(product);
            },
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildRelatedProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDecription(product: product),
          ),
        );
      },
      child: Container(
        width: 160.w,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12.r),
              ),
              child: SizedBox(
                height: 120.h,
                width: double.infinity,
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppTheme.buttonBorder,
                          child: Center(
                            child: Iconify(
                              Ph.image,
                              size: 32.sp,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppTheme.buttonBorder,
                          child: Center(
                            child: Iconify(
                              Ph.image,
                              size: 32.sp,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: AppTheme.buttonBorder,
                        child: Center(
                          child: Iconify(
                            Ph.image,
                            size: 32.sp,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    product.formattedPrice,
                    style: TextConstants.boldText.copyWith(
                      fontSize: 14.sp,
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Iconify(
                        Ph.map_pin,
                        size: 12.sp,
                        color: AppTheme.textLight,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          product.location,
                          style: TextConstants.smallText.copyWith(
                            fontSize: 11.sp,
                            color: AppTheme.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  Widget _buildReviewsSection() {
    final avgRating = widget.product.averageRating ?? 0.0;
    final reviewCount = widget.product.reviewCount ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReviewSummaryScreen(
              productId: widget.product.id,
              productName: widget.product.name,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Divider(color: AppTheme.border, height: 24.h, thickness: 1),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              children: [
                Iconify(Ph.star_fill, size: 22.sp, color: AppTheme.primary),
                SizedBox(width: 8.w),
                Text(
                  avgRating > 0 ? avgRating.toStringAsFixed(1) : '—',
                  style: TextConstants.boldText.copyWith(
                    fontSize: 18.sp,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  '($reviewCount review${reviewCount == 1 ? '' : 's'})',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 13.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  'See All',
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 13.sp,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.w),
                Iconify(Ph.arrow_right, size: 16.sp, color: AppTheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
