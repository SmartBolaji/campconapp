import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/pickup_center_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/pickup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key});

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  late PickupProvider _pickupProvider;

  @override
  void initState() {
    super.initState();
    _pickupProvider = Provider.of<PickupProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePickup();
    });
  }

  void _initializePickup() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.uid;
    if (userId != null) {
      _pickupProvider.initialize(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Consumer<PickupProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: provider.isLoading
                      ? _buildLoading()
                      : provider.hasPickupCenter
                          ? _buildMyPickupCenter(provider)
                          : _buildApplicationForm(provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Iconify(
              Ph.arrow_left,
              color: AppTheme.textPrimary,
              size: 24.sp,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Pickup Center',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(width: 24.w),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        color: AppTheme.primary,
      ),
    );
  }

  // ===== MY PICKUP CENTER VIEW =====
  Widget _buildMyPickupCenter(PickupProvider provider) {
    final center = provider.myPickupCenter!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          _buildStatusCard(center),
          SizedBox(height: 20.h),

          // Center Details
          _buildCenterDetailsCard(center),
          SizedBox(height: 20.h),

          // Stats (if approved)
          if (center.isApproved) ...[
            _buildStatsCard(center),
            SizedBox(height: 20.h),
          ],

          // Actions
          _buildActionsSection(center, provider),
        ],
      ),
    );
  }

  Widget _buildStatusCard(PickupCenterModel center) {
    Color statusColor;
    String statusText;
    String statusDescription;
    IconData? statusIcon;

    switch (center.status) {
      case PickupCenterStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending Review';
        statusDescription =
            'Your application is being reviewed. This usually takes 24-48 hours.';
        statusIcon = Icons.hourglass_empty;
        break;
      case PickupCenterStatus.approved:
        statusColor = AppTheme.success;
        statusText = 'Approved';
        statusDescription =
            'Your pickup center is active and visible to buyers.';
        statusIcon = Icons.check_circle;
        break;
      case PickupCenterStatus.rejected:
        statusColor = AppTheme.error;
        statusText = 'Rejected';
        statusDescription =
            center.rejectionReason ?? 'Your application was not approved.';
        statusIcon = Icons.cancel;
        break;
      case PickupCenterStatus.suspended:
        statusColor = Colors.red.shade700;
        statusText = 'Suspended';
        statusDescription =
            'Your pickup center has been temporarily suspended.';
        statusIcon = Icons.pause_circle;
        break;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextConstants.boldText.copyWith(
                    fontSize: 16.sp,
                    color: statusColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  statusDescription,
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

  Widget _buildCenterDetailsCard(PickupCenterModel center) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  center.typeDisplay,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const Spacer(),
              if (center.isApproved)
                Row(
                  children: [
                    Iconify(Ph.star_fill, size: 14.sp, color: Colors.amber),
                    SizedBox(width: 4.w),
                    Text(
                      center.rating.toStringAsFixed(1),
                      style: TextConstants.smallText.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            center.name,
            style: TextConstants.boldText.copyWith(
              fontSize: 18.sp,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            center.description,
            style: TextConstants.smallText.copyWith(
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          Divider(color: AppTheme.border, height: 1),
          SizedBox(height: 16.h),
          _buildDetailRow(Ph.map_pin, 'Address', center.fullAddress),
          SizedBox(height: 10.h),
          _buildDetailRow(Ph.phone, 'Phone', center.phoneNumber),
          SizedBox(height: 10.h),
          _buildDetailRow(Ph.clock, 'Hours', center.operatingHours),
          SizedBox(height: 10.h),
          _buildDetailRow(Ph.calendar, 'Days', center.operatingDaysDisplay),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Iconify(icon, size: 18.sp, color: AppTheme.textLight),
        SizedBox(width: 10.w),
        SizedBox(
          width: 60.w,
          child: Text(
            label,
            style: TextConstants.smallText.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextConstants.smallText.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(PickupCenterModel center) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Ph.package,
              label: 'Pickups',
              value: '${center.totalPickups}',
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: AppTheme.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Ph.truck,
              label: 'Dropoffs',
              value: '${center.totalDropoffs}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Iconify(icon,
            size: 24.sp, color: AppTheme.white.withValues(alpha: 0.8)),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextConstants.boldText.copyWith(
            fontSize: 20.sp,
            color: AppTheme.white,
          ),
        ),
        Text(
          label,
          style: TextConstants.smallText.copyWith(
            fontSize: 12.sp,
            color: AppTheme.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(
      PickupCenterModel center, PickupProvider provider) {
    return Column(
      children: [
        if (center.isPending || center.isRejected)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showWithdrawDialog(provider),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.error),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                center.isPending ? 'Withdraw Application' : 'Delete & Reapply',
                style: TextConstants.mediumText.copyWith(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (center.isApproved) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showEditSheet(center, provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Edit Details',
                style: TextConstants.mediumText.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ===== APPLICATION FORM =====
  Widget _buildApplicationForm(PickupProvider provider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          _buildInfoBanner(),
          SizedBox(height: 20.h),

          // Center Type
          _buildSectionTitle('Type of Center *'),
          SizedBox(height: 8.h),
          _buildTypeSelector(provider),
          SizedBox(height: 20.h),

          // Center Name
          _buildSectionTitle('Center Name *'),
          SizedBox(height: 8.h),
          _buildTextField(
            hint: 'e.g., John\'s Shop, Campus Warehouse',
            value: provider.centerName,
            onChanged: provider.setCenterName,
          ),
          SizedBox(height: 20.h),

          // Description
          _buildSectionTitle('Description *'),
          SizedBox(height: 8.h),
          _buildTextField(
            hint: 'Describe your pickup center...',
            value: provider.description,
            onChanged: provider.setDescription,
            maxLines: 3,
          ),
          SizedBox(height: 20.h),

          // Address
          _buildSectionTitle('Address *'),
          SizedBox(height: 8.h),
          _buildTextField(
            hint: 'Full address of pickup location',
            value: provider.address,
            onChanged: provider.setAddress,
            maxLines: 2,
          ),
          SizedBox(height: 12.h),

          // Landmark
          _buildSectionTitle('Landmark (Optional)'),
          SizedBox(height: 8.h),
          _buildTextField(
            hint: 'e.g., Near the main gate, Opposite library',
            value: provider.landmark ?? '',
            onChanged: provider.setLandmark,
          ),
          SizedBox(height: 20.h),

          // Phone Number
          _buildSectionTitle('Phone Number *'),
          SizedBox(height: 8.h),
          _buildTextField(
            hint: '08012345678',
            value: provider.phoneNumber,
            onChanged: provider.setPhoneNumber,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 12.h),

          // Alternate Phone
          _buildSectionTitle('Alternate Phone (Optional)'),
          SizedBox(height: 8.h),
          _buildTextField(
            hint: '08012345678',
            value: provider.alternatePhone ?? '',
            onChanged: provider.setAlternatePhone,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 20.h),

          // Operating Days
          _buildSectionTitle('Operating Days *'),
          SizedBox(height: 8.h),
          _buildDaysSelector(provider),
          SizedBox(height: 20.h),

          // Operating Hours
          _buildSectionTitle('Operating Hours *'),
          SizedBox(height: 8.h),
          _buildTimeSelector(provider),
          SizedBox(height: 32.h),

          // Submit Button
          _buildSubmitButton(provider),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

// ...existing code...

  Widget _buildInfoBanner() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Iconify(Ph.storefront,
                    size: 24.sp, color: AppTheme.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Become a Pickup Center',
                      style: TextConstants.boldText.copyWith(
                        fontSize: 16.sp,
                        color: AppTheme.primary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Turn your space into a earning point',
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
          SizedBox(height: 16.h),

          // How it works section
          Text(
            'How it works',
            style: TextConstants.smallText.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),

          _buildHowItWorksStep(
            number: '1',
            title: 'Receive packages',
            description: 'Sellers drop off items at your location',
          ),
          SizedBox(height: 8.h),
          _buildHowItWorksStep(
            number: '2',
            title: 'Store safely',
            description: 'Keep items secure until pickup',
          ),
          SizedBox(height: 8.h),
          _buildHowItWorksStep(
            number: '3',
            title: 'Hand over & earn',
            description: 'Give items to buyers and get paid per transaction',
          ),

          SizedBox(height: 16.h),

          // Benefits row
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildBenefitItem(
                    icon: Ph.money,
                    label: 'Earn per\npickup',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40.h,
                  color: AppTheme.border,
                ),
                Expanded(
                  child: _buildBenefitItem(
                    icon: Ph.users_three,
                    label: 'More\ncustomers',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40.h,
                  color: AppTheme.border,
                ),
                Expanded(
                  child: _buildBenefitItem(
                    icon: Ph.clock,
                    label: 'Flexible\nhours',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22.w,
          height: 22.h,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextConstants.smallText.copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextConstants.smallText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                description,
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem({
    required String icon,
    required String label,
  }) {
    return Column(
      children: [
        Iconify(icon, size: 22.sp, color: AppTheme.primary),
        SizedBox(height: 6.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextConstants.smallText.copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextConstants.smallText.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildTypeSelector(PickupProvider provider) {
    return Row(
      children: PickupCenterType.values.map((type) {
        final isSelected = provider.selectedType == type;
        String label;
        String icon;

        switch (type) {
          case PickupCenterType.shop:
            label = 'Shop';
            icon = Ph.storefront;
            break;
          case PickupCenterType.warehouse:
            label = 'Warehouse';
            icon = Ph.house;
            break;
          case PickupCenterType.individual:
            label = 'Individual';
            icon = Ph.user;
            break;
        }

        return Expanded(
          child: GestureDetector(
            onTap: () => provider.setSelectedType(type),
            child: Container(
              margin: EdgeInsets.only(
                  right: type != PickupCenterType.individual ? 8.w : 0),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.1)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Iconify(
                    icon,
                    size: 24.sp,
                    color: isSelected ? AppTheme.primary : AppTheme.textLight,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    label,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required String hint,
    required String value,
    required Function(String) onChanged,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: value.isEmpty ? null : value,
      onChanged: onChanged,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextConstants.smallText.copyWith(
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextConstants.smallText.copyWith(
          color: AppTheme.textLight,
        ),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildDaysSelector(PickupProvider provider) {
    return Column(
      children: [
        // Quick select buttons
        Row(
          children: [
            _buildQuickSelectButton('All Days', () => provider.selectAllDays()),
            SizedBox(width: 8.w),
            _buildQuickSelectButton(
                'Weekdays', () => provider.selectWeekdays()),
            SizedBox(width: 8.w),
            _buildQuickSelectButton('Clear', () => provider.clearDays()),
          ],
        ),
        SizedBox(height: 12.h),
        // Day chips
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: provider.availableDays.map((day) {
            final isSelected = provider.selectedDays.contains(day);
            return GestureDetector(
              onTap: () => provider.toggleDay(day),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.background,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : AppTheme.border,
                  ),
                ),
                child: Text(
                  day.substring(0, 3),
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppTheme.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickSelectButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          label,
          style: TextConstants.smallText.copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector(PickupProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildTimeField(
            label: 'Opens at',
            value: provider.openingTime,
            onTap: () => _selectTime(context, provider.openingTime, (time) {
              provider.setOpeningTime(time);
            }),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildTimeField(
            label: 'Closes at',
            value: provider.closingTime,
            onTap: () => _selectTime(context, provider.closingTime, (time) {
              provider.setClosingTime(time);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Iconify(Ph.clock, size: 18.sp, color: AppTheme.textLight),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 10.sp,
                    color: AppTheme.textLight,
                  ),
                ),
                Text(
                  value,
                  style: TextConstants.smallText.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    String currentTime,
    Function(String) onSelect,
  ) async {
    final parts = currentTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onSelect(formattedTime);
    }
  }

  Widget _buildSubmitButton(PickupProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: provider.isFormValid && !provider.isSubmitting
            ? () => _submitApplication(provider)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.5),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: provider.isSubmitting
            ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: CircularProgressIndicator(
                  color: AppTheme.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Submit Application',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                ),
              ),
      ),
    );
  }

  Future<void> _submitApplication(PickupProvider provider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    final userData = authProvider.currentUser;

    if (user == null) return;

    final success = await provider.submitApplication(
      userId: user.uid,
      userName: userData?.fullName ?? 'Unknown',
      userImage: userData?.profileImageUrl,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Application submitted successfully!'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to submit application'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  void _showWithdrawDialog(PickupProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Withdraw Application?',
          style: TextConstants.boldText.copyWith(
            fontSize: 18.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to withdraw your application? You can reapply later.',
          style: TextConstants.smallText.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextConstants.smallText.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              final userId = authProvider.currentUser?.uid;
              if (userId != null) {
                await provider.withdrawApplication(userId);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Withdraw',
              style: TextConstants.smallText.copyWith(
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(PickupCenterModel center, PickupProvider provider) {
    // Load current data into form
    provider.loadFormFromCenter(center);

    // Navigate to edit mode or show bottom sheet
    // For simplicity, showing a snackbar - you can implement a full edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Edit functionality coming soon!'),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}
