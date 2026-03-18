import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/sales_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class EarningsSheet extends StatefulWidget {
  final SalesProvider provider;

  const EarningsSheet({super.key, required this.provider});

  @override
  State<EarningsSheet> createState() => _EarningsSheetState();
}

class _EarningsSheetState extends State<EarningsSheet> {
  bool _showWeekly = true;

  @override
  void initState() {
    super.initState();
    widget.provider.calculateEarningsBreakdown();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppTheme.textLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Text(
                      'Earnings Breakdown',
                      style: TextConstants.boldText.copyWith(
                        fontSize: 18.sp,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Iconify(
                        Ph.x,
                        size: 22.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    _buildTotalCard(),
                    SizedBox(height: 16.h),
                    _buildChartSection(),
                    SizedBox(height: 16.h),
                    _buildTopProducts(),
                    SizedBox(height: 16.h),
                    _buildRevenueByProduct(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Earnings',
                  style: TextConstants.smallText.copyWith(
                    color: AppTheme.white.withValues(alpha: 0.8),
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.provider.formatCurrency(widget.provider.totalRevenue),
                  style: TextConstants.boldText.copyWith(
                    color: AppTheme.white,
                    fontSize: 24.sp,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Today',
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.white.withValues(alpha: 0.8),
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.provider.formatCurrency(widget.provider.todayRevenue),
                style: TextConstants.boldText.copyWith(
                  color: AppTheme.white,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    final data = _showWeekly
        ? widget.provider.weeklyRevenue
        : widget.provider.monthlyRevenue;

    final maxY = data.values.isEmpty
        ? 100.0
        : data.values.reduce((a, b) => a > b ? a : b) * 1.3;

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
              Text(
                'Revenue Trend',
                style: TextConstants.mediumText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              _buildToggleChip('Week', _showWeekly, () {
                setState(() => _showWeekly = true);
              }),
              SizedBox(width: 8.w),
              _buildToggleChip('Month', !_showWeekly, () {
                setState(() => _showWeekly = false);
              }),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: data.isEmpty || data.values.every((v) => v == 0)
                ? Center(
                    child: Text(
                      'No data yet',
                      style: TextConstants.smallText.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipPadding: EdgeInsets.all(8.w),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              widget.provider.formatCurrency(rod.toY),
                              TextConstants.smallText.copyWith(
                                color: AppTheme.white,
                                fontSize: 11.sp,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final keys = data.keys.toList();
                              if (value.toInt() >= 0 &&
                                  value.toInt() < keys.length) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: Text(
                                    keys[value.toInt()],
                                    style: TextConstants.smallText.copyWith(
                                      fontSize: 10.sp,
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxY / 4,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppTheme.border,
                          strokeWidth: 1,
                        ),
                      ),
                      barGroups: data.entries.toList().asMap().entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.value,
                              color: AppTheme.primary,
                              width: _showWeekly ? 22.w : 28.w,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(4.r),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : AppTheme.background,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextConstants.smallText.copyWith(
            fontSize: 12.sp,
            color: selected ? AppTheme.primary : AppTheme.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTopProducts() {
    final topProducts = widget.provider.topProducts;
    if (topProducts.isEmpty) return const SizedBox.shrink();

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
              Iconify(Ph.trophy, size: 18.sp, color: Colors.amber),
              SizedBox(width: 8.w),
              Text(
                'Top Selling Products',
                style: TextConstants.mediumText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...topProducts.take(5).toList().asMap().entries.map((e) {
            final rank = e.key + 1;
            final entry = e.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: rank <= 3
                          ? Colors.amber.withValues(alpha: 0.15)
                          : AppTheme.background,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$rank',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: rank <= 3
                            ? Colors.amber.shade700
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextConstants.smallText.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    widget.provider.formatCurrency(entry.value),
                    style: TextConstants.smallText.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRevenueByProduct() {
    final revenue = widget.provider.revenueByProduct;
    if (revenue.isEmpty) return const SizedBox.shrink();

    final total = revenue.values.fold(0.0, (sum, v) => sum + v);

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
          Text(
            'Revenue by Product',
            style: TextConstants.mediumText.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          ...revenue.entries.map((entry) {
            final percentage = total > 0 ? (entry.value / total) : 0.0;
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextConstants.smallText.copyWith(
                            color: AppTheme.textPrimary,
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        widget.provider.formatCurrency(entry.value),
                        style: TextConstants.smallText.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: AppTheme.border,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      minHeight: 6.h,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
