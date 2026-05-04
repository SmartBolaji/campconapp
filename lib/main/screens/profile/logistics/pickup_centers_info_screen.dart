import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/pickup_center_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class PickupCentersInfoScreen extends StatelessWidget {
  const PickupCentersInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child:
                Iconify(Ph.arrow_left, size: 24.r, color: AppTheme.textPrimary),
          ),
        ),
        title: Text(
          'Pickup Centers',
          style: TextConstants.boldText.copyWith(fontSize: 18.sp),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('pickup_centers')
            .where('status', isEqualTo: 'approved')
            .orderBy('rating', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  'Failed to load pickup centers. Please try again.',
                  textAlign: TextAlign.center,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 13.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final centers =
              docs.map((doc) => PickupCenterModel.fromMap(doc.data())).toList();

          if (centers.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  'No approved pickup centers yet.',
                  textAlign: TextAlign.center,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 13.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
            itemCount: centers.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final center = centers[index];
              return _PickupCenterCard(center: center);
            },
          );
        },
      ),
    );
  }
}

class _PickupCenterCard extends StatelessWidget {
  final PickupCenterModel center;

  const _PickupCenterCard({required this.center});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  center.typeDisplay,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 11.sp,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Iconify(Ph.star_fill, size: 14.sp, color: Colors.amber),
              SizedBox(width: 4.w),
              Text(
                center.rating.toStringAsFixed(1),
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            center.name,
            style: TextConstants.boldText.copyWith(
              fontSize: 16.sp,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            center.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextConstants.smallText.copyWith(
              fontSize: 12.sp,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10.h),
          _DetailRow(icon: Ph.map_pin, text: center.fullAddress),
          SizedBox(height: 6.h),
          _DetailRow(icon: Ph.phone, text: center.phoneNumber),
          SizedBox(height: 6.h),
          _DetailRow(icon: Ph.clock, text: center.operatingHours),
          SizedBox(height: 6.h),
          _DetailRow(icon: Ph.calendar, text: center.operatingDaysDisplay),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Iconify(icon, size: 15.sp, color: AppTheme.textLight),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextConstants.smallText.copyWith(
              fontSize: 12.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
