import 'package:campcon/main/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

enum ShimmerCardType {
  post,
  product,
  message,
  notification,
  resource,
}

class ShimmerCard extends StatelessWidget {
  final ShimmerCardType type;
  final EdgeInsetsGeometry? margin;

  const ShimmerCard({
    super.key,
    required this.type,
    this.margin,
  });

  const ShimmerCard.post({super.key, this.margin})
      : type = ShimmerCardType.post;
  const ShimmerCard.product({super.key, this.margin})
      : type = ShimmerCardType.product;
  const ShimmerCard.message({super.key, this.margin})
      : type = ShimmerCardType.message;
  const ShimmerCard.notification({super.key, this.margin})
      : type = ShimmerCardType.notification;
  const ShimmerCard.resource({super.key, this.margin})
      : type = ShimmerCardType.resource;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Shimmer.fromColors(
        baseColor: AppTheme.border.withValues(alpha: 0.45),
        highlightColor: AppTheme.surface.withValues(alpha: 0.9),
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    switch (type) {
      case ShimmerCardType.post:
        return _buildPostCard();
      case ShimmerCardType.product:
        return _buildProductCard();
      case ShimmerCardType.message:
        return _buildMessageCard();
      case ShimmerCardType.notification:
        return _buildNotificationCard();
      case ShimmerCardType.resource:
        return _buildResourceCard();
    }
  }

  Widget _block({double? width, double? height, BorderRadius? radius}) {
    return Container(
      width: width,
      height: height ?? 12.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius ?? BorderRadius.circular(10.r),
      ),
    );
  }

  Widget _buildPostCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _block(
                  width: 42.w,
                  height: 42.w,
                  radius: BorderRadius.circular(21.r)),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _block(width: 120.w, height: 12.h),
                    SizedBox(height: 8.h),
                    _block(width: 80.w, height: 10.h),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _block(width: double.infinity, height: 12.h),
          SizedBox(height: 8.h),
          _block(width: double.infinity, height: 12.h),
          SizedBox(height: 8.h),
          _block(width: 180.w, height: 12.h),
          SizedBox(height: 14.h),
          _block(
              width: double.infinity,
              height: 180.h,
              radius: BorderRadius.circular(16.r)),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                List.generate(4, (_) => _block(width: 56.w, height: 12.h)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _block(
              width: double.infinity,
              height: 170.h,
              radius: BorderRadius.circular(16.r)),
          SizedBox(height: 12.h),
          _block(width: double.infinity, height: 12.h),
          SizedBox(height: 8.h),
          _block(width: 90.w, height: 12.h),
          SizedBox(height: 8.h),
          _block(width: 120.w, height: 14.h),
        ],
      ),
    );
  }

  Widget _buildMessageCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          _block(
              width: 50.w, height: 50.w, radius: BorderRadius.circular(25.r)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _block(width: 120.w, height: 12.h),
                SizedBox(height: 8.h),
                _block(width: double.infinity, height: 10.h),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _block(width: 34.w, height: 10.h),
        ],
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _block(
              width: 44.w, height: 44.w, radius: BorderRadius.circular(22.r)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _block(width: double.infinity, height: 12.h),
                SizedBox(height: 8.h),
                _block(width: 160.w, height: 10.h),
                SizedBox(height: 8.h),
                _block(width: 60.w, height: 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _block(
              width: 46.w, height: 46.w, radius: BorderRadius.circular(12.r)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _block(width: double.infinity, height: 12.h),
                SizedBox(height: 8.h),
                _block(width: 150.w, height: 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final ShimmerCardType type;
  final EdgeInsetsGeometry? padding;

  const ShimmerList({
    super.key,
    required this.itemCount,
    required this.type,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) => ShimmerCard(type: type),
    );
  }
}
