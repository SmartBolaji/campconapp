import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/product_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/product_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/product/order_summary_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/product/widgets/widgets.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
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
                ProductHeader(isItem: widget.product.isItem),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProductImage(
                          imageUrl: widget.product.imageUrl,
                          imageFile: widget.product.imageFile,
                          isItem: widget.product.isItem,
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

                              _buildBottomAction(
                                isSeller,
                                productProvider,
                                currentUserId,
                              ),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: isSeller
          ? _buildSellerActions()
          : widget.product.isItem
              ? _buildBuyerItemAction(provider, currentUserId, isOutOfStock)
              : _buildBuyerServiceAction(provider),
    );
  }

  Widget _buildSellerActions() {
    return Row(
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
    );
  }

  Widget _buildBuyerItemAction(
    ProductProvider provider,
    String currentUserId,
    bool isOutOfStock,
  ) {
    return CustomButton(
      text: isOutOfStock ? 'Out of Stock' : 'Buy Now',
      icon: isOutOfStock ? null : Ph.shopping_cart,
      onPressed: isOutOfStock
          ? () {}
          : provider.canProceedToOrder
              ? () => _showOrderSummary(provider, currentUserId)
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
    );
  }

  Widget _buildBuyerServiceAction(ProductProvider provider) {
    return CustomButton(
      text: 'Message Provider',
      onPressed: () => _openChat(provider),
      backgroundColor: AppTheme.primary,
      textColor: AppTheme.white,
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
    // TODO: Implement chat navigation
  }

  String _formatPrice(double price) {
    return '₦${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }
}
