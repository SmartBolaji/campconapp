import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loadingBankDetails = true;
  bool _savingBank = false;
  bool _requestingPayout = false;
  Map<String, dynamic>? _bankDetails;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBankDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  Future<void> _loadBankDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('paymentDetails')
          .doc('bank')
          .get();
      if (doc.exists) {
        setState(() {
          _bankDetails = doc.data();
          _bankNameController.text = _bankDetails!['bankName'] ?? '';
          _accountNumberController.text = _bankDetails!['accountNumber'] ?? '';
          _accountHolderController.text =
              _bankDetails!['accountHolderName'] ?? '';
        });
      }
    } catch (_) {
    } finally {
      setState(() => _loadingBankDetails = false);
    }
  }

  Future<void> _saveBankDetails() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _savingBank = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('paymentDetails')
          .doc('bank')
          .set({
        'bankName': _bankNameController.text.trim(),
        'accountNumber': _accountNumberController.text.trim(),
        'accountHolderName': _accountHolderController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      setState(() => _bankDetails = {
            'bankName': _bankNameController.text.trim(),
            'accountNumber': _accountNumberController.text.trim(),
            'accountHolderName': _accountHolderController.text.trim(),
          });
      showFloatingSnackBar(context, 'Bank details saved',
          backgroundColor: AppTheme.success);
    } catch (e) {
      showFloatingSnackBar(context, 'Failed to save bank details',
          backgroundColor: AppTheme.error);
    } finally {
      setState(() => _savingBank = false);
    }
  }

  Future<void> _requestPayout(double availableBalance) async {
    if (_bankDetails == null) {
      showFloatingSnackBar(context, 'Please set up bank details first',
          backgroundColor: AppTheme.warning);
      _tabController.animateTo(1);
      return;
    }
    if (availableBalance < 500) {
      showFloatingSnackBar(context, 'Minimum payout amount is ₦500',
          backgroundColor: AppTheme.warning);
      return;
    }

    setState(() => _requestingPayout = true);
    try {
      await FirebaseFirestore.instance.collection('payouts').add({
        'userId': _uid,
        'amount': availableBalance,
        'bankDetails': _bankDetails,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });
      showFloatingSnackBar(context, 'Payout request submitted successfully',
          backgroundColor: AppTheme.success);
    } catch (e) {
      showFloatingSnackBar(context, 'Failed to submit payout request',
          backgroundColor: AppTheme.error);
    } finally {
      setState(() => _requestingPayout = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Payments',
            style: TextConstants.boldText.copyWith(fontSize: 18.sp)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textLight,
          indicatorColor: AppTheme.primary,
          labelStyle: TextConstants.mediumText.copyWith(fontSize: 13.sp),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Bank Setup'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildBankSetupTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  // ----------- OVERVIEW TAB -----------
  Widget _buildOverviewTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('marketplace')
          .where('sellerId', isEqualTo: _uid)
          .snapshots(),
      builder: (context, snapshot) {
        double totalEarnings = 0;
        double availableBalance = 0;
        double pendingBalance = 0;

        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final price = (data['price'] ?? 0).toDouble();
            final status = data['status'] ?? '';
            if (status == 'completed') {
              totalEarnings += price;
              availableBalance += price;
            } else if (status == 'in_progress') {
              pendingBalance += price;
            }
          }
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              // Total earnings card
              _buildEarningsCard(
                label: 'Total Earnings',
                amount: totalEarnings,
                icon: Ph.currency_circle_dollar,
                color: AppTheme.success,
                bgColor: AppTheme.success.withValues(alpha: 0.1),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildSmallEarningsCard(
                      label: 'Available',
                      amount: availableBalance,
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildSmallEarningsCard(
                      label: 'Pending',
                      amount: pendingBalance,
                      color: AppTheme.warning,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              // Payout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _requestingPayout
                      ? null
                      : () => _requestPayout(availableBalance),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _requestingPayout
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Request Payout',
                          style: TextConstants.boldText
                              .copyWith(fontSize: 15.sp, color: Colors.white)),
                ),
              ),
              SizedBox(height: 8.h),
              Center(
                child: Text(
                  'Minimum payout: ₦500 · Processed within 3 business days',
                  style: TextConstants.smallText
                      .copyWith(fontSize: 11.sp, color: AppTheme.textLight),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEarningsCard({
    required String label,
    required double amount,
    required String icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Iconify(icon, size: 20.r, color: color),
              ),
              SizedBox(width: 10.w),
              Text(label,
                  style: TextConstants.mediumText
                      .copyWith(fontSize: 13.sp, color: color)),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '₦${NumberFormat('#,##0.00').format(amount)}',
            style:
                TextConstants.boldText.copyWith(fontSize: 28.sp, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallEarningsCard({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextConstants.smallText
                  .copyWith(fontSize: 12.sp, color: AppTheme.textLight)),
          SizedBox(height: 6.h),
          Text(
            '₦${NumberFormat('#,##0').format(amount)}',
            style:
                TextConstants.boldText.copyWith(fontSize: 18.sp, color: color),
          ),
        ],
      ),
    );
  }

  // ----------- BANK SETUP TAB -----------
  Widget _buildBankSetupTab() {
    if (_loadingBankDetails) {
      return Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            _bankDetails != null
                ? _buildBankInfoBanner()
                : _buildNoBankBanner(),
            SizedBox(height: 20.h),
            Text('Bank Details',
                style: TextConstants.boldText.copyWith(fontSize: 16.sp)),
            SizedBox(height: 16.h),
            _buildFormField(
              label: 'Bank Name',
              controller: _bankNameController,
              hint: 'e.g. Access Bank',
              icon: Ph.bank,
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter bank name' : null,
            ),
            SizedBox(height: 14.h),
            _buildFormField(
              label: 'Account Number',
              controller: _accountNumberController,
              hint: '10-digit account number',
              icon: Ph.hash,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Enter account number';
                if ((v?.length ?? 0) != 10) {
                  return 'Must be 10 digits';
                }
                return null;
              },
            ),
            SizedBox(height: 14.h),
            _buildFormField(
              label: 'Account Holder Name',
              controller: _accountHolderController,
              hint: 'Name on the account',
              icon: Ph.user,
              validator: (v) =>
                  (v?.isEmpty ?? true) ? 'Enter account holder name' : null,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savingBank ? null : _saveBankDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _savingBank
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('Save Bank Details',
                        style: TextConstants.boldText
                            .copyWith(fontSize: 15.sp, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfoBanner() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Iconify(Ph.check_circle, size: 20.r, color: AppTheme.success),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bank account linked',
                    style: TextConstants.mediumText
                        .copyWith(fontSize: 13.sp, color: AppTheme.success)),
                Text(
                    '${_bankDetails!['bankName']} · ****${(_bankDetails!['accountNumber'] as String).substring(6)}',
                    style: TextConstants.smallText
                        .copyWith(fontSize: 12.sp, color: AppTheme.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoBankBanner() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Iconify(Ph.warning, size: 20.r, color: AppTheme.warning),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
                'No bank account linked. Add one below to receive payouts.',
                style: TextConstants.smallText
                    .copyWith(fontSize: 12.sp, color: AppTheme.textLight)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextConstants.mediumText
                .copyWith(fontSize: 13.sp, color: AppTheme.textPrimary)),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextConstants.mediumText.copyWith(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextConstants.smallText
                .copyWith(fontSize: 13.sp, color: AppTheme.textLight),
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.r),
              child: Iconify(icon, size: 18.r, color: AppTheme.textLight),
            ),
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
        ),
      ],
    );
  }

  // ----------- HISTORY TAB -----------
  Widget _buildHistoryTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('payouts')
          .where('userId', isEqualTo: _uid)
          .orderBy('requestedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Iconify(Ph.receipt, size: 60.r, color: AppTheme.textLight),
                SizedBox(height: 12.h),
                Text('No payout history yet',
                    style: TextConstants.mediumText
                        .copyWith(fontSize: 15.sp, color: AppTheme.textLight)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.all(20.w),
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildPayoutItem(data);
          },
        );
      },
    );
  }

  Widget _buildPayoutItem(Map<String, dynamic> data) {
    final status = data['status'] ?? 'pending';
    final amount = (data['amount'] ?? 0).toDouble();
    final requestedAt = data['requestedAt'] is Timestamp
        ? (data['requestedAt'] as Timestamp).toDate()
        : DateTime.now();

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'completed':
        statusColor = AppTheme.success;
        statusLabel = 'Completed';
        break;
      case 'rejected':
        statusColor = AppTheme.error;
        statusLabel = 'Rejected';
        break;
      default:
        statusColor = AppTheme.warning;
        statusLabel = 'Pending';
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Iconify(Ph.money, size: 22.r, color: statusColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₦${NumberFormat('#,##0.00').format(amount)}',
                    style: TextConstants.boldText.copyWith(fontSize: 15.sp)),
                SizedBox(height: 2.h),
                Text(
                  DateFormat('MMM d, yyyy • h:mm a').format(requestedAt),
                  style: TextConstants.smallText
                      .copyWith(fontSize: 11.sp, color: AppTheme.textLight),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              statusLabel,
              style: TextConstants.mediumText
                  .copyWith(fontSize: 11.sp, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}
