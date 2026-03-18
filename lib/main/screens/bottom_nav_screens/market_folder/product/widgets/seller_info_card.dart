import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/product_provider.dart';
import 'package:campcon/main/services/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class SellerInfoCard extends StatelessWidget {
  final ProductProvider provider;
  final bool isItem;

  const SellerInfoCard({
    Key? key,
    required this.provider,
    required this.isItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (provider.isLoadingSeller) {
      return _buildLoadingState();
    }

    final seller = provider.sellerData;

    return Column(children: [
      Divider(color: AppTheme.border, height: 24.h, thickness: 1),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28.r,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              backgroundImage: seller?.profileImageUrl != null &&
                      seller!.profileImageUrl!.isNotEmpty
                  ? NetworkImage(seller.profileImageUrl!)
                  : null,
              child: seller?.profileImageUrl == null ||
                      seller!.profileImageUrl == ''
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
                    isItem ? 'Seller' : 'Service Provider',
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
                  if (provider.sellerTotalReviews > 0) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final rating = provider.sellerAverageRating;
                          return Padding(
                            padding: EdgeInsets.only(right: 2.w),
                            child: Iconify(
                              index < rating.round() ? Ph.star_fill : Ph.star,
                              size: 14.sp,
                              color: AppTheme.primary,
                            ),
                          );
                        }),
                        SizedBox(width: 4.w),
                        Text(
                          '${provider.sellerAverageRating.toStringAsFixed(1)} (${provider.sellerTotalReviews})',
                          style: TextConstants.smallText.copyWith(
                            fontSize: 12.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
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
                final seller = provider.sellerData;
                if (seller != null) {
                  NavigationHelper.openProfile(context, seller.uid);
                }
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
      )
    ]);
  }

  Widget _buildLoadingState() {
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
}
