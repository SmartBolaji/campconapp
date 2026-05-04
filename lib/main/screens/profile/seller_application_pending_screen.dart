import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class SellerApplicationPendingScreen extends StatelessWidget {
  final UserModel user;

  const SellerApplicationPendingScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child:
                Iconify(Ph.arrow_left, size: 24.r, color: AppTheme.textPrimary),
          ),
        ),
        title: Text('Seller Application',
            style: TextConstants.boldText.copyWith(fontSize: 18.sp)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: userDoc.get(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data();
            final sellerApplication = data?['sellerApplication'] is Map
                ? Map<String, dynamic>.from(data?['sellerApplication'])
                : null;

            final category = (data?['businessCategory'] as String?) ??
                (sellerApplication?['sellerCategory'] as String?) ??
                (user.businessCategory ?? '');
            final name = (data?['businessName'] as String?) ??
                (sellerApplication?['sellerName'] as String?) ??
                (user.businessName ?? '');
            final description = (data?['businessDescription'] as String?) ??
                (sellerApplication?['sellerDescription'] as String?) ??
                (user.businessDescription ?? '');

            final contact = data?['contactInfo'] is Map
                ? Map<String, dynamic>.from(data?['contactInfo'])
                : (sellerApplication?['contactInfo'] is Map
                    ? Map<String, dynamic>.from(
                        sellerApplication?['contactInfo'])
                    : (user.contactInfo ?? <String, dynamic>{}));

            final whatsapp = (contact['whatsapp'] ?? '').toString();
            final instagram = (contact['instagram'] ?? '').toString();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pending badge banner
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.warning.withValues(alpha: 0.2),
                        AppTheme.info.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                        color: AppTheme.warning.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Iconify(
                          Ph.clock,
                          size: 24.r,
                          color: AppTheme.warning,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Application Pending',
                            style: TextConstants.boldText
                                .copyWith(fontSize: 16.sp),
                          ),
                          Text(
                            'Under review by our team',
                            style: TextConstants.smallText.copyWith(
                              fontSize: 12.sp,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Application Details',
                  style: TextConstants.boldText.copyWith(fontSize: 15.sp),
                ),
                SizedBox(height: 12.h),
                _buildConfirmCard('Category', category),
                SizedBox(height: 10.h),
                _buildConfirmCard('Business Name', name),
                SizedBox(height: 10.h),
                _buildConfirmCard('Description', description),
                if (whatsapp.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  _buildConfirmCard('WhatsApp', whatsapp),
                ],
                if (instagram.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  _buildConfirmCard('Instagram', instagram),
                ],
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppTheme.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Iconify(Ph.info, size: 18.r, color: AppTheme.info),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'We\'re reviewing your application. You\'ll be notified once it\'s approved. This usually takes 24-48 hours.',
                          style: TextConstants.smallText.copyWith(
                            fontSize: 12.sp,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildConfirmCard(String label, String value) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(label,
                style: TextConstants.smallText
                    .copyWith(fontSize: 12.sp, color: AppTheme.textLight)),
          ),
          Expanded(
            child: Text(value,
                style: TextConstants.mediumText.copyWith(fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }
}
