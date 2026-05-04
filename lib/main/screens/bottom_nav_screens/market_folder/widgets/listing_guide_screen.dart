import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/screens/profile/seller_application_pending_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campcon/main/screens/profile/logistics/pickup_centers_info_screen.dart';

enum ListingGuideType { item, service }

class ListingGuideScreen extends StatefulWidget {
  static const _prefsKey = 'market_listing_guide_hidden';

  final ListingGuideType type;
  final VoidCallback onContinue;

  const ListingGuideScreen({
    super.key,
    required this.type,
    required this.onContinue,
  });

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_prefsKey) ?? false);
  }

  static Future<void> launch({
    required BuildContext context,
    required ListingGuideType type,
    required VoidCallback onContinue,
  }) async {
    final shouldShowGuide = await shouldShow();
    if (!context.mounted) return;

    if (!shouldShowGuide) {
      onContinue();
      return;
    }

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 250),
        child: ListingGuideScreen(
          type: type,
          onContinue: onContinue,
        ),
      ),
    );
  }

  @override
  State<ListingGuideScreen> createState() => _ListingGuideScreenState();
}

class _ListingGuideScreenState extends State<ListingGuideScreen> {
  bool _dontShowAgain = false;

  bool get _isItem => widget.type == ListingGuideType.item;

  String get _title =>
      _isItem ? 'Before you list an item' : 'Before you list a service';

  String get _subtitle => _isItem
      ? 'A clear listing helps buyers understand your item. When sold, you drop it at our campus pickup center and the buyer collects it there.'
      : 'A clear service listing helps people know what you offer, how you charge, and where you can work.';

  IconData get _heroIcon => _isItem
      ? Icons.shopping_bag_outlined
      : Icons.home_repair_service_outlined;

  String get _primaryButtonText => 'Continue';

  List<_GuideStep> get _steps {
    if (_isItem) {
      return [
        _GuideStep(
          number: '1',
          title: 'Add strong photos',
          description:
              'Upload 3-5 clear images showing front, back, and important details. Use natural lighting, include close-ups of defects or features. Photos are your first impression—invest time here.',
          icon: Icons.photo_library_outlined,
          color: AppTheme.primary,
        ),
        _GuideStep(
          number: '2',
          title: 'Write accurate title and description',
          description:
              'Use a clear, specific title with brand, size, color, or key features. Mention condition, any defects, age, and why you\'re selling. Honesty builds buyer confidence.',
          icon: Icons.description_outlined,
          color: AppTheme.info,
        ),
        _GuideStep(
          number: '3',
          title: 'Set fair pricing and details',
          description:
              'Research similar items to price competitively. Fill in quantity, category, location, and condition. Ensure all fields are complete so buyers can find your listing.',
          icon: Icons.inventory_2_outlined,
          color: AppTheme.warning,
        ),
        _GuideStep(
          number: '4',
          title: 'Prepare for pickup center handoff',
          description:
              'Once sold, drop your item at the campus pickup center and keep the order number. Mark the order as "Ready" in the app so the buyer can collect it. Ensure items are clean and packaged well.',
          icon: Icons.storefront_outlined,
          color: AppTheme.success,
        ),
      ];
    }

    return [
      _GuideStep(
        number: '1',
        title: 'Create compelling service title',
        description:
            'Write a title that clearly describes what you offer (e.g., "Professional Resume Writing" or "Phone Repair"). Include specialty or experience level. Avoid vague terms.',
        icon: Icons.badge_outlined,
        color: AppTheme.primary,
      ),
      _GuideStep(
        number: '2',
        title: 'Write detailed service description',
        description:
            'Explain exactly what you offer, how long it takes, what buyer receives, and requirements. Mention experience or certifications. Answer: What\'s included? What isn\'t? Do you offer revisions? How do we communicate?',
        icon: Icons.description_outlined,
        color: AppTheme.info,
      ),
      _GuideStep(
        number: '3',
        title: 'Set transparent pricing and rates',
        description:
            'Choose rate model: hourly, daily, weekly, monthly, or one-time. Set prices that reflect your skill and market rates. Be clear about what\'s included and any additional costs.',
        icon: Icons.payments_outlined,
        color: AppTheme.warning,
      ),
      _GuideStep(
        number: '4',
        title: 'Add location and availability',
        description:
            'Specify your service area (campus, city, remote). List your availability hours and response time. Update as you take bookings so buyers know when to reach out.',
        icon: Icons.location_on_outlined,
        color: AppTheme.success,
      ),
    ];
  }

  List<_ChecklistItem> get _checklist {
    if (_isItem) {
      return [
        _ChecklistItem(
          title: 'Photos (3-5 minimum)',
          subtitle: 'Multiple angles, good lighting, show condition clearly.',
          icon: Icons.photo_library_outlined,
        ),
        _ChecklistItem(
          title: 'Clear, specific title',
          subtitle: 'Include brand, size, color, or key features.',
          icon: Icons.sell_outlined,
        ),
        _ChecklistItem(
          title: 'Detailed description',
          subtitle: 'Condition, defects, age, packaging, why selling.',
          icon: Icons.description_outlined,
        ),
        _ChecklistItem(
          title: 'Fair, researched price',
          subtitle: 'Check similar listings; consider market demand.',
          icon: Icons.local_offer_outlined,
        ),
        _ChecklistItem(
          title: 'Category and condition',
          subtitle: 'Select right category; be honest about condition.',
          icon: Icons.category_outlined,
        ),
        _ChecklistItem(
          title: 'Stock quantity',
          subtitle: 'Specify how many you have available.',
          icon: Icons.inventory_2_outlined,
        ),
        _ChecklistItem(
          title: 'Pickup center locations',
          subtitle: 'Know where the campus pickup centers are located.',
          icon: Icons.location_on_outlined,
        ),
        _ChecklistItem(
          title: 'Review before publish',
          subtitle: 'Check all details one more time for accuracy.',
          icon: Icons.fact_check_outlined,
        ),
      ];
    }

    return [
      _ChecklistItem(
        title: 'Service title',
        subtitle: 'Clear, professional, includes specialty or type.',
        icon: Icons.sell_outlined,
      ),
      _ChecklistItem(
        title: 'Service description',
        subtitle: 'Detailed, explains what\'s included, your experience.',
        icon: Icons.description_outlined,
      ),
      _ChecklistItem(
        title: 'Cover image',
        subtitle: 'Professional, clear representation of service.',
        icon: Icons.image_outlined,
      ),
      _ChecklistItem(
        title: 'Pricing model',
        subtitle: 'Choose hourly, daily, weekly, monthly, or fixed rate.',
        icon: Icons.payment_outlined,
      ),
      _ChecklistItem(
        title: 'Starting price',
        subtitle: 'Set entry-level price to attract inquiries.',
        icon: Icons.local_offer_outlined,
      ),
      _ChecklistItem(
        title: 'Service location',
        subtitle: 'Specify where available (campus, city, remote).',
        icon: Icons.place_outlined,
      ),
      _ChecklistItem(
        title: 'Availability hours',
        subtitle: 'State when available to work or respond.',
        icon: Icons.schedule_outlined,
      ),
      _ChecklistItem(
        title: 'Category',
        subtitle: 'Pick the most relevant service category.',
        icon: Icons.category_outlined,
      ),
    ];
  }

  Future<void> _continue() async {
    if (_dontShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(ListingGuideScreen._prefsKey, true);
    }

    if (!mounted) return;
    Navigator.pop(context);
    widget.onContinue();
  }

  void _handlePrimary() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    // Pending sellers should keep seeing pending status until approved.
    if (user != null && user.sellerStatus == 'pending') {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: SellerApplicationPendingScreen(user: user),
        ),
      );
      return;
    }

    _continue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary.withValues(alpha: 0.14),
              AppTheme.surface,
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20.sp,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Expanded(
                    //   child: Text(
                    //     _heroLabel,
                    //     style: TextConstants.mediumText.copyWith(
                    //       fontSize: 14.sp,
                    //       fontWeight: FontWeight.w600,
                    //       color: AppTheme.textSecondary,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(color: AppTheme.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(14.w),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primary,
                                        AppTheme.primaryDark,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _heroIcon,
                                    color: AppTheme.white,
                                    size: 30.sp,
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _title,
                                        style: TextConstants.boldText.copyWith(
                                          fontSize: 24.sp,
                                          color: AppTheme.textPrimary,
                                          height: 1.15,
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      Text(
                                        _subtitle,
                                        style:
                                            TextConstants.mediumText.copyWith(
                                          fontSize: 14.sp,
                                          color: AppTheme.textSecondary,
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // SizedBox(height: 20.h),
                            // Container(
                            //   padding: EdgeInsets.symmetric(
                            //     horizontal: 12.w,
                            //     vertical: 10.h,
                            //   ),
                            //   decoration: BoxDecoration(
                            //     color: AppTheme.primary.withValues(alpha: 0.08),
                            //     borderRadius: BorderRadius.circular(14.r),
                            //   ),
                            //   child: Row(
                            //     children: [
                            //       Icon(
                            //         Icons.lightbulb_outline,
                            //         size: 18.sp,
                            //         color: AppTheme.primary,
                            //       ),
                            //       // SizedBox(width: 8.w),
                            //       // Expanded(
                            //       //   child: Text(
                            //       //     'You can turn this guide off any time with the checkbox below.',
                            //       //     style: TextConstants.smallText.copyWith(
                            //       //       fontSize: 12.sp,
                            //       //       color: AppTheme.textSecondary,
                            //       //     ),
                            //       //   ),
                            //       // ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'What to know before you starting your listing',
                        style: TextConstants.boldText.copyWith(
                          fontSize: 17.sp,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ..._steps.map(
                        (step) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _GuideStepCard(step: step),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _isItem
                            ? 'Checklist for item listings'
                            : 'Checklist for service listings',
                        style: TextConstants.boldText.copyWith(
                          fontSize: 17.sp,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ..._checklist.map(
                        (item) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: _ChecklistCard(item: item),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Pro tips for better listings',
                        style: TextConstants.boldText.copyWith(
                          fontSize: 17.sp,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _ProTipCard(
                        title: 'Be honest and specific',
                        description:
                            'Describe condition accurately. Mention defects or wear. Buyers appreciate transparency and complete transactions faster without disputes.',
                        icon: Icons.verified_outlined,
                      ),
                      SizedBox(height: 10.h),
                      _ProTipCard(
                        title:
                            _isItem ? 'Price competitively' : 'Show your value',
                        description: _isItem
                            ? 'Research similar items on Campcon and other platforms. Price competitively based on condition and demand.'
                            : 'Highlight your experience, certifications, or past work. Share why your service is worth the price. Start with competitive rates to build reviews.',
                        icon: Icons.trending_up_outlined,
                      ),
                      SizedBox(height: 10.h),
                      _ProTipCard(
                        title: 'Respond quickly',
                        description:
                            'Answer buyer questions fast. Quick responses show professionalism and boost your chances of making a sale or booking.',
                        icon: Icons.speed_outlined,
                      ),
                      SizedBox(height: 10.h),
                      _ProTipCard(
                        title: 'Keep your listing updated',
                        description:
                            'Edit listings when you get offers, change availability, or adjust quantity. Remove or mark items sold. This keeps buyer trust high.',
                        icon: Icons.update_outlined,
                      ),
                      SizedBox(height: 12.h),
                      // Pickup center highlight — explain handoff and link to pickup centers
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.storefront_outlined,
                                size: 22.sp,
                                color: AppTheme.primary,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'How pickup works on Campcon',
                                    style: TextConstants.mediumText.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    'After a buyer purchases your item, you drop it at a campus pickup center and keep the order number. Mark the order as "Ready" in the app so the buyer can collect it using their order number. Ensure your item is clean, packaged well, and ready to hand off.',
                                    style: TextConstants.smallText.copyWith(
                                      fontSize: 13.sp,
                                      color: AppTheme.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Wrap(
                                    spacing: 8.w,
                                    runSpacing: 8.h,
                                    alignment: WrapAlignment.end,
                                    children: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.w, vertical: 10.h),
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: AppTheme.border),
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              child:
                                                  const PickupCentersInfoScreen(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'View pickup centers',
                                          style:
                                              TextConstants.mediumText.copyWith(
                                            fontSize: 14.sp,
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
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
                      SizedBox(height: 18.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 18.sp,
                                  color: AppTheme.textSecondary,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Good listings usually have:',
                                  style: TextConstants.mediumText.copyWith(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            _bullet('Clear images with enough light'),
                            _bullet('Accurate pricing and location'),
                            _bullet(_isItem
                                ? 'Quantity or stock information if needed'
                                : 'A service description that explains the value'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 18.h),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(top: BorderSide(color: AppTheme.border)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _dontShowAgain,
                          onChanged: (value) {
                            setState(() {
                              _dontShowAgain = value ?? false;
                            });
                          },
                          activeColor: AppTheme.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        Expanded(
                          child: Text(
                            'Don\'t show this guide again',
                            style: TextConstants.smallText.copyWith(
                              fontSize: 13.sp,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppTheme.border),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: Text(
                              'Maybe later',
                              style: TextConstants.mediumText.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _handlePrimary,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: AppTheme.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: Text(
                              _primaryButtonText,
                              style: TextConstants.mediumText.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.white,
                              ),
                            ),
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
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 5.h),
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextConstants.mediumText.copyWith(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideStep {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _GuideStep({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _ChecklistItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ChecklistItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _GuideStepCard extends StatelessWidget {
  final _GuideStep step;

  const _GuideStepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: Icon(
                step.icon,
                size: 20.sp,
                color: step.color,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        step.number,
                        style: TextConstants.smallText.copyWith(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        step.title,
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  step.description,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 13.sp,
                    color: AppTheme.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final _ChecklistItem item;

  const _ChecklistCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              item.icon,
              size: 18.sp,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.subtitle,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProTipCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _ProTipCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              size: 18.sp,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  description,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
