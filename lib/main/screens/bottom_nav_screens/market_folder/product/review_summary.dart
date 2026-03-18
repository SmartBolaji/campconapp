import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/review_model.dart';
import 'package:campcon/main/services/cache.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:timeago/timeago.dart' as timeago;

enum ReviewSort { newest, highest, lowest }

class ReviewSummaryScreen extends StatefulWidget {
  final String productId;
  final String productName;

  const ReviewSummaryScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ReviewSummaryScreen> createState() => _ReviewSummaryScreenState();
}

class _ReviewSummaryScreenState extends State<ReviewSummaryScreen> {
  ReviewSort _sortBy = ReviewSort.newest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon:
              Iconify(Ph.arrow_left, color: AppTheme.textPrimary, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reviews',
          style: TextConstants.boldText.copyWith(
            fontSize: 18.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .where('productId', isEqualTo: widget.productId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final reviews = (snapshot.data?.docs ?? [])
              .map((doc) =>
                  ReviewModel.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          if (reviews.isEmpty) {
            return _buildEmptyState();
          }

          // Sort
          switch (_sortBy) {
            case ReviewSort.newest:
              reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              break;
            case ReviewSort.highest:
              reviews.sort((a, b) => b.rating.compareTo(a.rating));
              break;
            case ReviewSort.lowest:
              reviews.sort((a, b) => a.rating.compareTo(b.rating));
              break;
          }

          // Calculate stats
          final totalRating =
              reviews.fold<double>(0, (sum, r) => sum + r.rating);
          final average = totalRating / reviews.length;
          final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
          for (final r in reviews) {
            distribution[r.rating.round()] =
                (distribution[r.rating.round()] ?? 0) + 1;
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: _buildRatingOverview(
                      average, reviews.length, distribution),
                ),
              ),
              SliverToBoxAdapter(child: _buildSortBar()),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildReviewCard(reviews[index]),
                    childCount: reviews.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 20.h)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(Ph.star, size: 60.sp, color: AppTheme.border),
          SizedBox(height: 16.h),
          Text(
            'No reviews yet',
            style: TextConstants.mediumText.copyWith(
              fontSize: 16.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingOverview(
      double average, int total, Map<int, int> distribution) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          // Average rating
          Column(
            children: [
              Text(
                average.toStringAsFixed(1),
                style: TextConstants.boldText.copyWith(
                  fontSize: 40.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
              Row(
                children: _buildStarsRow(average, 18.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                '$total review${total == 1 ? '' : 's'}',
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(width: 24.w),

          // Distribution bars
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final star = 5 - index;
                final count = distribution[star] ?? 0;
                final fraction = total > 0 ? count / total : 0.0;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: TextConstants.smallText.copyWith(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Iconify(Ph.star_fill,
                          size: 12.sp, color: AppTheme.primary),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: fraction,
                            backgroundColor: AppTheme.border,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppTheme.primary),
                            minHeight: 8.h,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      SizedBox(
                        width: 24.w,
                        child: Text(
                          '$count',
                          style: TextConstants.smallText.copyWith(
                            fontSize: 11.sp,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: TextConstants.smallText.copyWith(
              fontSize: 13.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(width: 8.w),
          _buildSortChip('Newest', ReviewSort.newest),
          SizedBox(width: 8.w),
          _buildSortChip('Highest', ReviewSort.highest),
          SizedBox(width: 8.w),
          _buildSortChip('Lowest', ReviewSort.lowest),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, ReviewSort sort) {
    final isActive = _sortBy == sort;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = sort),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : AppTheme.background,
          borderRadius: BorderRadius.circular(20.r),
          border:
              Border.all(color: isActive ? AppTheme.primary : AppTheme.border),
        ),
        child: Text(
          label,
          style: TextConstants.smallText.copyWith(
            fontSize: 12.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? AppTheme.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: AppTheme.primaryBackground,
                backgroundImage:
                    review.buyerImage != null && review.buyerImage!.isNotEmpty
                        ? CachedNetworkImageProvider(
                            review.buyerImage!,
                            cacheManager: CustomCacheManager(),
                          )
                        : null,
                child: review.buyerImage == null || review.buyerImage!.isEmpty
                    ? Iconify(Ph.user, size: 16.sp, color: AppTheme.primary)
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.buyerName,
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      timeago.format(review.createdAt),
                      style: TextConstants.smallText.copyWith(
                        fontSize: 11.sp,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Row(children: _buildStarsRow(review.rating, 14.sp)),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              review.comment!,
              style: TextConstants.mediumText.copyWith(
                fontSize: 14.sp,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildStarsRow(double rating, double size) {
    return List.generate(5, (index) {
      return Iconify(
        index < rating.round() ? Ph.star_fill : Ph.star,
        size: size,
        color: index < rating.round() ? AppTheme.primary : AppTheme.border,
      );
    });
  }
}
