import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EventDescriptionSection extends StatefulWidget {
  final String description;

  const EventDescriptionSection({
    Key? key,
    required this.description,
  }) : super(key: key);

  @override
  State<EventDescriptionSection> createState() =>
      _EventDescriptionSectionState();
}

class _EventDescriptionSectionState extends State<EventDescriptionSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final shouldShowMore = widget.description.length > 200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Event',
          style: TextConstants.boldText.copyWith(
            fontSize: 18.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        AnimatedCrossFade(
          firstChild: Text(
            widget.description,
            style: TextConstants.smallText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            widget.description,
            style: TextConstants.smallText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        if (shouldShowMore) ...[
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Show less' : 'Read more',
              style: TextConstants.mediumText.copyWith(
                fontSize: 14.sp,
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
