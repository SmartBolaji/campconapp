import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campcon/main/screens/profile/logistics/pickup_screen.dart';

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
      ? 'A clean listing helps people understand what you are selling faster and makes your post look more trustworthy.'
      : 'A clear service listing helps people know what you offer, how you charge, and where you can work.';

  IconData get _heroIcon => _isItem
      ? Icons.shopping_bag_outlined
      : Icons.home_repair_service_outlined;

  String get _primaryButtonText =>
      _isItem ? 'Continue to Item Form' : 'Continue to Service Form';

  List<_GuideStep> get _steps {
    if (_isItem) {
      return [
        _GuideStep(
          number: '1',
          title: 'Add strong photos',
          description:
              'Use clear images from the front, back, and any important details like condition, accessories, or flaws.',
          icon: Icons.photo_library_outlined,
          color: AppTheme.primary,
        ),
        _GuideStep(
          number: '2',
          title: 'Set the essentials',
          description:
              'You will fill in the item name, category, location, price, stock quantity, and optional discount.',
          icon: Icons.inventory_2_outlined,
          color: AppTheme.info,
        ),
        _GuideStep(
          number: '3',
          title: 'Post with confidence',
          description:
              'Review everything before publishing so buyers can understand the offer without extra questions.',
          icon: Icons.check_circle_outline,
          color: AppTheme.success,
        ),
      ];
    }

    return [
      _GuideStep(
        number: '1',
        title: 'Show the service clearly',
        description:
            'Upload a clean cover image and describe the exact service you offer so people know what to expect.',
        icon: Icons.badge_outlined,
        color: AppTheme.primary,
      ),
      _GuideStep(
        number: '2',
        title: 'Choose how you charge',
        description:
            'You will select a rate model such as hourly, daily, weekly, monthly, or one-time pricing.',
        icon: Icons.payments_outlined,
        color: AppTheme.info,
      ),
      _GuideStep(
        number: '3',
        title: 'Add location and details',
        description:
            'Enter the service location and write enough detail for someone to trust the offer and book quickly.',
        icon: Icons.location_on_outlined,
        color: AppTheme.success,
      ),
    ];
  }

  List<_ChecklistItem> get _checklist {
    if (_isItem) {
      return [
        _ChecklistItem(
          title: 'Item name',
          subtitle: 'Use a simple, accurate title.',
          icon: Icons.sell_outlined,
        ),
        _ChecklistItem(
          title: 'Price and stock',
          subtitle: 'Have your price and quantity ready.',
          icon: Icons.confirmation_number_outlined,
        ),
        _ChecklistItem(
          title: 'Condition notes',
          subtitle: 'Mention anything buyers should know.',
          icon: Icons.sticky_note_2_outlined,
        ),
      ];
    }

    return [
      _ChecklistItem(
        title: 'Service type',
        subtitle: 'Know whether you charge hourly or a fixed fee.',
        icon: Icons.timelapse_outlined,
      ),
      _ChecklistItem(
        title: 'Location',
        subtitle: 'Add where the service is available.',
        icon: Icons.place_outlined,
      ),
      _ChecklistItem(
        title: 'Service details',
        subtitle: 'Explain exactly what is included.',
        icon: Icons.description_outlined,
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
                            SizedBox(height: 20.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    size: 18.sp,
                                    color: AppTheme.primary,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'You can turn this guide off any time with the checkbox below.',
                                      style: TextConstants.smallText.copyWith(
                                        fontSize: 12.sp,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'What to know before you start',
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
                                    'Pickup center handoff',
                                    style: TextConstants.mediumText.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    'If you select pickup, drop the item at the campus pickup center and keep the order number. Mark the order as "Ready" so the buyer can collect it with the order number.',
                                    style: TextConstants.smallText.copyWith(
                                      fontSize: 13.sp,
                                      color: AppTheme.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              child: const PickupScreen(),
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
                                      SizedBox(width: 8.w),
                                      ElevatedButton(
                                        onPressed: _continue,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primary,
                                          foregroundColor: AppTheme.white,
                                          elevation: 0,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.h, horizontal: 14.w),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                        ),
                                        child: Text(
                                          _primaryButtonText,
                                          style:
                                              TextConstants.mediumText.copyWith(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.white,
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
                            onPressed: _continue,
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
