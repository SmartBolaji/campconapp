import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class ProfessionalAccountScreen extends StatefulWidget {
  const ProfessionalAccountScreen({super.key});

  @override
  State<ProfessionalAccountScreen> createState() =>
      _ProfessionalAccountScreenState();
}

class _ProfessionalAccountScreenState extends State<ProfessionalAccountScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Category
  String? _selectedCategory;

  // Step 2: Business info
  final _businessNameController = TextEditingController();
  final _businessDescController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _instagramController = TextEditingController();

  // Step 3: Business hours
  final Map<String, Map<String, dynamic>> _businessHours = {
    'Monday': {'open': true, 'from': '08:00', 'to': '18:00'},
    'Tuesday': {'open': true, 'from': '08:00', 'to': '18:00'},
    'Wednesday': {'open': true, 'from': '08:00', 'to': '18:00'},
    'Thursday': {'open': true, 'from': '08:00', 'to': '18:00'},
    'Friday': {'open': true, 'from': '08:00', 'to': '18:00'},
    'Saturday': {'open': false, 'from': '09:00', 'to': '15:00'},
    'Sunday': {'open': false, 'from': '09:00', 'to': '15:00'},
  };

  bool _saving = false;

  static const List<Map<String, dynamic>> _categories = [
    {'label': 'Food & Meals', 'icon': Ph.fork_knife},
    {'label': 'Fashion & Clothing', 'icon': Ph.t_shirt},
    {'label': 'Tech & Gadgets', 'icon': Ph.device_mobile},
    {'label': 'Beauty & Health', 'icon': Ph.heart},
    {'label': 'Books & Stationery', 'icon': Ph.book_open},
    {'label': 'Services', 'icon': Ph.wrench},
    {'label': 'Art & Crafts', 'icon': Ph.paint_brush},
    {'label': 'Events & Shows', 'icon': Ph.ticket},
    {'label': 'Other', 'icon': Ph.dots_three},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _businessNameController.dispose();
    _businessDescController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  bool get _step1Valid => _selectedCategory != null;
  bool get _step2Valid =>
      _businessNameController.text.trim().isNotEmpty &&
      _businessDescController.text.trim().isNotEmpty;

  void _nextStep() {
    if (_currentStep == 0 && !_step1Valid) {
      showFloatingSnackBar(context, 'Please select a business category',
          backgroundColor: AppTheme.warning);
      return;
    }
    if (_currentStep == 1 && !_step2Valid) {
      showFloatingSnackBar(
          context, 'Business name and description are required',
          backgroundColor: AppTheme.warning);
      return;
    }
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _activate() async {
    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final Map<String, dynamic> proData = {
        'isProfessional': true,
        'businessCategory': _selectedCategory,
        'businessName': _businessNameController.text.trim(),
        'businessDescription': _businessDescController.text.trim(),
        'businessHours': _businessHours,
        'contactInfo': {
          'whatsapp': _whatsappController.text.trim(),
          'instagram': _instagramController.text.trim(),
        },
        'professionalSince': FieldValue.serverTimestamp(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(proData);

      // Update local user model
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      if (currentUser != null) {
        authProvider.updateCurrentUser(currentUser.copyWith(
          isProfessional: true,
          businessCategory: _selectedCategory,
          businessName: _businessNameController.text.trim(),
          businessDescription: _businessDescController.text.trim(),
          businessHours: _businessHours,
          contactInfo: {
            'whatsapp': _whatsappController.text.trim(),
            'instagram': _instagramController.text.trim(),
          },
        ));
      }

      showFloatingSnackBar(context, 'Professional account activated! 🎉',
          backgroundColor: AppTheme.success);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Professional activation error: $e');
      showFloatingSnackBar(context, 'Failed to activate professional account',
          backgroundColor: AppTheme.error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    // If already professional, show management view
    if (user?.isProfessional == true) {
      return _buildManagementView(user!);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        automaticallyImplyActions: false,
        leading: GestureDetector(
          onTap: _prevStep,
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Iconify(Ph.arrow_left,
                size: 24.sp, color: AppTheme.textPrimary),
          ),
        ),
        title: Text(
          'Professional Account',
          style: TextConstants.boldText.copyWith(
            fontSize: 16.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1Category(),
                _buildStep2BusinessInfo(),
                _buildStep3Hours(),
                _buildStep4Confirm(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ---------- STEP INDICATOR ----------
  Widget _buildStepIndicator() {
    final labels = ['Category', 'Info', 'Hours', 'Confirm'];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == _currentStep;
          final done = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color:
                            done || active ? AppTheme.primary : AppTheme.border,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: done
                            ? Iconify(Ph.check, size: 16.r, color: Colors.white)
                            : Text('${i + 1}',
                                style: TextConstants.boldText.copyWith(
                                    fontSize: 13.sp,
                                    color: active
                                        ? Colors.white
                                        : AppTheme.textLight)),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(labels[i],
                        style: TextConstants.smallText.copyWith(
                            fontSize: 10.sp,
                            color: active
                                ? AppTheme.primary
                                : AppTheme.textLight)),
                  ],
                ),
                if (i < labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2.h,
                      margin:
                          EdgeInsets.only(bottom: 18.h, left: 4.w, right: 4.w),
                      color:
                          i < _currentStep ? AppTheme.primary : AppTheme.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ---------- STEP 1: CATEGORY ----------
  Widget _buildStep1Category() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What describes your business?',
              style: TextConstants.boldText.copyWith(fontSize: 18.sp)),
          SizedBox(height: 6.h),
          Text('Select the category that best fits your products or services.',
              style: TextConstants.smallText
                  .copyWith(fontSize: 13.sp, color: AppTheme.textLight)),
          SizedBox(height: 20.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: _categories.map((cat) {
              final selected = _selectedCategory == cat['label'];
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat['label']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: selected ? AppTheme.primary : AppTheme.border,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Iconify(cat['icon'],
                          size: 18.r,
                          color:
                              selected ? AppTheme.primary : AppTheme.textLight),
                      SizedBox(width: 8.w),
                      Text(cat['label'],
                          style: TextConstants.mediumText.copyWith(
                              fontSize: 13.sp,
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.textPrimary)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // ---------- STEP 2: BUSINESS INFO ----------
  Widget _buildStep2BusinessInfo() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about your business',
              style: TextConstants.boldText.copyWith(fontSize: 18.sp)),
          SizedBox(height: 6.h),
          Text('This info will appear on your professional profile.',
              style: TextConstants.smallText
                  .copyWith(fontSize: 13.sp, color: AppTheme.textLight)),
          SizedBox(height: 20.h),
          _buildStepField(
              label: 'Business Name *',
              controller: _businessNameController,
              hint: 'e.g. Ade\'s Kitchen'),
          SizedBox(height: 14.h),
          _buildStepField(
              label: 'Business Description *',
              controller: _businessDescController,
              hint: 'Describe what you offer...',
              maxLines: 3),
          SizedBox(height: 14.h),
          _buildStepField(
              label: 'WhatsApp Number',
              controller: _whatsappController,
              hint: '+234...',
              keyboardType: TextInputType.phone),
          SizedBox(height: 14.h),
          _buildStepField(
              label: 'Instagram Handle',
              controller: _instagramController,
              hint: '@yourbusiness'),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildStepField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextConstants.mediumText
                .copyWith(fontSize: 13.sp, color: AppTheme.textPrimary)),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextConstants.mediumText.copyWith(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextConstants.smallText
                .copyWith(fontSize: 13.sp, color: AppTheme.textLight),
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  // ---------- STEP 3: BUSINESS HOURS ----------
  Widget _buildStep3Hours() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Business Hours',
              style: TextConstants.boldText.copyWith(fontSize: 18.sp)),
          SizedBox(height: 6.h),
          Text('Set when customers can reach or order from you.',
              style: TextConstants.smallText
                  .copyWith(fontSize: 13.sp, color: AppTheme.textLight)),
          SizedBox(height: 20.h),
          ..._businessHours.entries.map((entry) {
            final day = entry.key;
            final info = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 90.w,
                    child: Text(day,
                        style:
                            TextConstants.mediumText.copyWith(fontSize: 13.sp)),
                  ),
                  Switch(
                    value: info['open'],
                    onChanged: (v) =>
                        setState(() => _businessHours[day]!['open'] = v),
                    activeColor: AppTheme.primary,
                  ),
                  if (info['open']) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _parseTime(info['from']),
                          );
                          if (picked != null) {
                            setState(() => _businessHours[day]!['from'] =
                                _formatTime(picked));
                          }
                        },
                        child: _timeChip(info['from']),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Text('–',
                          style: TextConstants.mediumText
                              .copyWith(fontSize: 13.sp)),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _parseTime(info['to']),
                          );
                          if (picked != null) {
                            setState(() => _businessHours[day]!['to'] =
                                _formatTime(picked));
                          }
                        },
                        child: _timeChip(info['to']),
                      ),
                    ),
                  ] else
                    Expanded(
                      child: Text('Closed',
                          style: TextConstants.smallText.copyWith(
                              fontSize: 12.sp, color: AppTheme.textLight)),
                    ),
                ],
              ),
            );
          }),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _timeChip(String time) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Text(time,
          textAlign: TextAlign.center,
          style: TextConstants.mediumText
              .copyWith(fontSize: 12.sp, color: AppTheme.primary)),
    );
  }

  TimeOfDay _parseTime(String s) {
    final parts = s.split(':');
    return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8, minute: int.tryParse(parts[1]) ?? 0);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ---------- STEP 4: CONFIRM ----------
  Widget _buildStep4Confirm() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Iconify(Ph.star, size: 40.r, color: AppTheme.primary),
                ),
                SizedBox(height: 14.h),
                Text('Almost there!',
                    style: TextConstants.boldText.copyWith(fontSize: 20.sp)),
                SizedBox(height: 6.h),
                Text(
                    'Review your details and activate your professional account.',
                    textAlign: TextAlign.center,
                    style: TextConstants.smallText
                        .copyWith(fontSize: 13.sp, color: AppTheme.textLight)),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          _buildConfirmCard('Business Category', _selectedCategory ?? ''),
          SizedBox(height: 10.h),
          _buildConfirmCard(
              'Business Name', _businessNameController.text.trim()),
          SizedBox(height: 10.h),
          _buildConfirmCard('Description', _businessDescController.text.trim()),
          if (_whatsappController.text.isNotEmpty) ...[
            SizedBox(height: 10.h),
            _buildConfirmCard('WhatsApp', _whatsappController.text.trim()),
          ],
          if (_instagramController.text.isNotEmpty) ...[
            SizedBox(height: 10.h),
            _buildConfirmCard('Instagram', _instagramController.text.trim()),
          ],
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: AppTheme.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Iconify(Ph.info, size: 18.r, color: AppTheme.info),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                      'Your professional badge will appear on your profile and listings. You can manage your details anytime.',
                      style: TextConstants.smallText.copyWith(
                          fontSize: 12.sp, color: AppTheme.textLight)),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
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

  // ---------- BOTTOM BAR ----------
  Widget _buildBottomBar() {
    final isLast = _currentStep == 3;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : (isLast ? _activate : _nextStep),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: _saving
                ? SizedBox(
                    height: 22.h,
                    width: 22.h,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(
                    isLast ? 'Activate Professional Account' : 'Continue',
                    style: TextConstants.boldText
                        .copyWith(fontSize: 15.sp, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  // ---------- MANAGEMENT VIEW (already professional) ----------
  Widget _buildManagementView(UserModel user) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child:
                Iconify(Ph.arrow_left, size: 24.r, color: AppTheme.textPrimary),
          ),
        ),
        title: Text('Professional Account',
            style: TextConstants.boldText.copyWith(fontSize: 18.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFD700).withValues(alpha: 0.2),
                    AppTheme.primary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Iconify(Ph.star_fill,
                      size: 32.r, color: const Color(0xFFFFD700)),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Professional Account',
                          style:
                              TextConstants.boldText.copyWith(fontSize: 16.sp)),
                      Text(user.businessCategory ?? '',
                          style: TextConstants.smallText.copyWith(
                              fontSize: 12.sp, color: AppTheme.textLight)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Text('Business Details',
                style: TextConstants.boldText.copyWith(fontSize: 15.sp)),
            SizedBox(height: 12.h),
            _buildConfirmCard('Name', user.businessName ?? ''),
            SizedBox(height: 10.h),
            _buildConfirmCard('Description', user.businessDescription ?? ''),
            SizedBox(height: 10.h),
            _buildConfirmCard('Category', user.businessCategory ?? ''),
            if (user.contactInfo != null) ...[
              SizedBox(height: 10.h),
              if ((user.contactInfo!['whatsapp'] ?? '').isNotEmpty)
                _buildConfirmCard('WhatsApp', user.contactInfo!['whatsapp']),
              SizedBox(height: 10.h),
              if ((user.contactInfo!['instagram'] ?? '').isNotEmpty)
                _buildConfirmCard('Instagram', user.contactInfo!['instagram']),
            ],
          ],
        ),
      ),
    );
  }
}
