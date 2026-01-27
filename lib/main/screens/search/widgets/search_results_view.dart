import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/search_provider.dart';
import 'package:campcon/main/screens/search/widgets/result_tiles/conversation_result_tile.dart';
import 'package:campcon/main/screens/search/widgets/result_tiles/notification_result_tile.dart';
import 'package:campcon/main/screens/search/widgets/result_tiles/post_result_tile.dart';
import 'package:campcon/main/screens/search/widgets/result_tiles/product_result_tile.dart';
import 'package:campcon/main/screens/search/widgets/result_tiles/resource_result_tile.dart';
import 'package:campcon/main/screens/search/widgets/result_tiles/user_result_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchResultsView extends StatelessWidget {
  final SearchContext context;
  final SearchProvider provider;
  final VoidCallback onResultTap;
  
  const SearchResultsView({
    super.key,
    required this.context,
    required this.provider,
    required this.onResultTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildResults(),
      ),
    );
  }
  
  List<Widget> _buildResults() {
    switch (context) {
      case SearchContext.home:
        return _buildHomeResults();
      case SearchContext.messaging:
        return _buildMessagingResults();
      case SearchContext.resources:
        return _buildResourceResults();
      case SearchContext.notifications:
        return _buildNotificationResults();
      case SearchContext.market:
        return _buildMarketResults();
    }
  }
  
  // Home results (Users + Posts)
  List<Widget> _buildHomeResults() {
    List<Widget> widgets = [];
    
    // Users section
    if (provider.users.isNotEmpty) {
      widgets.add(_buildSectionTitle('People'));
      widgets.add(
        SizedBox(
          height: 100.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: provider.users.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: UserResultTile(
                  user: provider.users[index],
                  onTap: onResultTap,
                ),
              );
            },
          ),
        ),
      );
      widgets.add(SizedBox(height: 16.h));
    }
    
    // Posts section
    if (provider.posts.isNotEmpty) {
      widgets.add(_buildSectionTitle('Posts'));
      for (var post in provider.posts) {
        widgets.add(PostResultTile(
          post: post,
          onTap: onResultTap,
        ));
      }
    }
    
    return widgets;
  }
  
  // Messaging results (Conversations + Users)
  List<Widget> _buildMessagingResults() {
    List<Widget> widgets = [];
    
    // Conversations
    if (provider.conversations.isNotEmpty) {
      widgets.add(_buildSectionTitle('Conversations'));
      for (var conv in provider.conversations) {
        widgets.add(ConversationResultTile(
          conversation: conv,
          onTap: onResultTap,
        ));
      }
      widgets.add(SizedBox(height: 16.h));
    }
    
    // Users (for starting new chats)
    if (provider.users.isNotEmpty) {
      widgets.add(_buildSectionTitle('People'));
      for (var user in provider.users) {
        widgets.add(UserResultTile(
          user: user,
          onTap: onResultTap,
          showAsListTile: true,
        ));
      }
    }
    
    return widgets;
  }
  
  // Resource results
  List<Widget> _buildResourceResults() {
    return [
      _buildResultCount('${provider.resources.length} resources found'),
      ...provider.resources.map((resource) => ResourceResultTile(
        resource: resource,
        onTap: onResultTap,
      )),
    ];
  }
  
  // Notification results
  List<Widget> _buildNotificationResults() {
    return [
      _buildResultCount('${provider.notifications.length} notifications found'),
      ...provider.notifications.map((notif) => NotificationResultTile(
        notification: notif,
        onTap: onResultTap,
      )),
    ];
  }
  
  // Market results
  List<Widget> _buildMarketResults() {
    return [
      _buildResultCount('${provider.products.length} results found'),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.7,
          ),
          itemCount: provider.products.length,
          itemBuilder: (context, index) {
            return ProductResultTile(
              product: provider.products[index],
              onTap: onResultTap,
            );
          },
        ),
      ),
    ];
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
      child: Text(
        title,
        style: TextConstants.mediumText.copyWith(
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
  
  Widget _buildResultCount(String text) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
      child: Text(
        text,
        style: TextConstants.smallText.copyWith(
          fontSize: 13.sp,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}