import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/poll_model.dart';
import 'package:campcon/main/provider/poll_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class PollDisplayWidget extends StatelessWidget {
  final PollModel poll;
  final String currentUserId;
  final String postId;
  final Function(String optionId) onVote;
  final bool isLoading;

  const PollDisplayWidget({
    required this.poll,
    required this.currentUserId,
    required this.postId,
    required this.onVote,
    this.isLoading = false,
    super.key,
  });

  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d remaining';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h remaining';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m remaining';
    } else {
      return 'Ending soon';
    }
  }

  int _getUserVoteCount(PollModel pollModel) {
    int count = 0;
    for (var option in pollModel.options) {
      if (option.votedBy.contains(currentUserId)) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PollProvider>(
      builder: (context, pollProvider, child) {
        // Get poll from cache if available, otherwise use the passed poll
        final currentPoll = pollProvider.getPoll(postId) ?? poll;
        final timeRemaining = currentPoll.timeRemaining;
        final hasUserVoted = _getUserVoteCount(currentPoll) > 0;
        final userVoteCount = _getUserVoteCount(currentPoll);

        return Container(
          // margin: EdgeInsets.symmetric(vertical: 12.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppTheme.background,
            // borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poll Question
              Text(
                currentPoll.question,
                style: TextConstants.mediumText.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),

              SizedBox(height: 12.h),

              // Poll Options
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentPoll.options.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final option = currentPoll.options[index];
                  final percentage = currentPoll.totalVotes > 0
                      ? (option.votes / currentPoll.totalVotes * 100)
                      : 0.0;
                  final userVoted = option.votedBy.contains(currentUserId);

                  return GestureDetector(
                    onTap: currentPoll.isActive && !isLoading && !hasUserVoted
                        ? () => onVote(option.id)
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: userVoted ? AppTheme.primary : AppTheme.border,
                          width: userVoted ? 2 : 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Background percentage indicator
                          Container(
                            height: 44.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              color: userVoted
                                  ? AppTheme.primary.withOpacity(0.1)
                                  : AppTheme.primary.withOpacity(0.05),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: percentage / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  color: userVoted
                                      ? AppTheme.primary.withOpacity(0.2)
                                      : AppTheme.primary.withOpacity(0.1),
                                ),
                              ),
                            ),
                          ),
                          // Option content
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          option.text,
                                          style:
                                              TextConstants.mediumText.copyWith(
                                            fontSize: 14.sp,
                                            color: AppTheme.textPrimary,
                                            fontWeight: userVoted
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '${percentage.toStringAsFixed(0)}%',
                                    style: TextConstants.mediumText.copyWith(
                                      fontSize: 13.sp,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (userVoted) ...[
                                    SizedBox(width: 6.w),
                                    Iconify(
                                      Ph.check,
                                      size: 16.sp,
                                      color: AppTheme.primary,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 12.h),

              // Poll stats and status
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Iconify(
                          Ph.student,
                          size: 16.sp,
                          color: AppTheme.textLight,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${currentPoll.totalVotes} vote${currentPoll.totalVotes != 1 ? 's' : ''}',
                          style: TextConstants.smallText.copyWith(
                            fontSize: 12.sp,
                            color: AppTheme.textLight,
                          ),
                        ),
                        if (currentPoll.isMultiChoice) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'Multiple choice',
                              style: TextConstants.smallText.copyWith(
                                fontSize: 11.sp,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        if (currentPoll.hasEnded)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.textLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'Ended',
                              style: TextConstants.smallText.copyWith(
                                fontSize: 12.sp,
                                color: AppTheme.textLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          Row(
                            children: [
                              Iconify(
                                Ph.hourglass,
                                size: 14.sp,
                                color: AppTheme.primary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _formatTimeRemaining(timeRemaining),
                                style: TextConstants.smallText.copyWith(
                                  fontSize: 12.sp,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // User vote info
              if (hasUserVoted && currentPoll.isMultiChoice) ...[
                SizedBox(height: 8.h),
                Center(
                  child: Text(
                    'You voted for $userVoteCount option${userVoteCount != 1 ? 's' : ''}',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.primary,
                      fontStyle: FontStyle.italic,
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
