import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/provider/event_create_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class CreateEventTicketTiers extends StatelessWidget {
  const CreateEventTicketTiers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EventCreateProvider>(
      builder: (context, provider, child) {
        if (provider.isFree || !provider.sellOnCampcon) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with toggle
              Row(
                children: [
                  Iconify(
                    Ph.stack,
                    size: 20.sp,
                    color: AppTheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Multiple Ticket Tiers',
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Offer different ticket options (VIP, Regular, etc.)',
                          style: TextConstants.smallText.copyWith(
                            fontSize: 12.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: provider.hasMultipleTiers,
                    onChanged: (value) => provider.toggleMultipleTiers(value),
                    activeThumbColor: AppTheme.primary,
                  ),
                ],
              ),

              // Ticket Tiers List
              if (provider.hasMultipleTiers) ...[
                SizedBox(height: 16.h),
                ...provider.ticketTiers.asMap().entries.map((entry) {
                  return _TierCard(
                    key: ValueKey(entry.value.id),
                    index: entry.key,
                    tier: entry.value,
                    provider: provider,
                  );
                }),
                SizedBox(height: 12.h),
                // Add tier button
                GestureDetector(
                  onTap: () => provider.addTicketTier(),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBackground,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Iconify(
                          Ph.plus_circle,
                          size: 20.sp,
                          color: AppTheme.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Add Another Tier',
                          style: TextConstants.smallText.copyWith(
                            fontSize: 14.sp,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TierCard extends StatefulWidget {
  final int index;
  final TicketTier tier;
  final EventCreateProvider provider;

  const _TierCard({
    Key? key,
    required this.index,
    required this.tier,
    required this.provider,
  }) : super(key: key);

  @override
  State<_TierCard> createState() => _TierCardState();
}

class _TierCardState extends State<_TierCard> {
  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late TextEditingController stockController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.tier.name);
    descController = TextEditingController(text: widget.tier.description);
    priceController = TextEditingController(
      text: widget.tier.price > 0 ? widget.tier.price.toStringAsFixed(0) : '',
    );
    stockController = TextEditingController(
      text: widget.tier.stock > 0 ? widget.tier.stock.toString() : '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Tier ${widget.index + 1}',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.provider.ticketTiers.length > 1)
                GestureDetector(
                  onTap: () => widget.provider.removeTicketTier(widget.index),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Iconify(
                      Ph.trash,
                      size: 16.sp,
                      color: AppTheme.error,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),

          // Tier name
          _buildTierField(
            controller: nameController,
            label: 'Tier Name',
            hint: 'e.g. VIP, Regular, Early Bird',
            onChanged: (value) {
              widget.provider.updateTicketTier(
                widget.index,
                widget.tier.copyWith(name: value),
              );
            },
          ),
          SizedBox(height: 12.h),

          // Description
          _buildTierField(
            controller: descController,
            label: 'Description',
            hint: 'What\'s included in this tier',
            onChanged: (value) {
              widget.provider.updateTicketTier(
                widget.index,
                widget.tier.copyWith(description: value),
              );
            },
          ),
          SizedBox(height: 12.h),

          // Price and Stock row
          Row(
            children: [
              Expanded(
                child: _buildTierField(
                  controller: priceController,
                  label: 'Price (₦)',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    widget.provider.updateTicketTier(
                      widget.index,
                      widget.tier.copyWith(price: double.tryParse(value) ?? 0),
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTierField(
                  controller: stockController,
                  label: 'Available',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    widget.provider.updateTicketTier(
                      widget.index,
                      widget.tier.copyWith(stock: int.tryParse(value) ?? 0),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTierField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextConstants.smallText.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppTheme.buttonBorder,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppTheme.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: TextConstants.smallText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextConstants.smallText.copyWith(
                fontSize: 14.sp,
                color: AppTheme.textLight,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
            ),
          ),
        ),
      ],
    );
  }
}
