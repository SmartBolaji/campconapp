// lib/main/screens/bottom_nav_screens/messaging_folder/message_screen.dart
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/search_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/new_message.dart';
import 'package:campcon/main/screens/search/search_screen.dart';
import 'package:campcon/main/services/cache.dart';
import 'package:campcon/main/widgets/action_search_bar.dart';
import 'package:campcon/main/widgets/custom_top_bar.dart';
import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/message.dart';
import 'package:campcon/main/widgets/navigation_helper.dart';
import 'package:campcon/main/widgets/verified_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Format timestamp for display
  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    } else {
      // Older - show date
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  // Fetch user data for all chat participants
  Future<Map<String, DocumentSnapshot>> _getUserDataMap(
      List<QueryDocumentSnapshot> chatDocs, String currentUserId) async {
    Map<String, DocumentSnapshot> userDataMap = {};
    Set<String> userIds = {};

    // Extract all unique user IDs
    for (var doc in chatDocs) {
      var participants = List<String>.from(doc['participants'] ?? []);
      String otherUserId = participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );

      if (otherUserId.isNotEmpty) {
        userIds.add(otherUserId);
      }
    }

    // Fetch user data for all IDs at once
    for (String userId in userIds) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          userDataMap[userId] = userDoc;
        }
      } catch (e) {
        debugPrint('Error fetching user data for $userId: $e');
      }
    }

    return userDataMap;
  }

  // Filter chats based on search query and blocked users
  Future<List<QueryDocumentSnapshot>> _filterChats(
    List<QueryDocumentSnapshot> chatDocs,
    Map<String, DocumentSnapshot> userDataMap,
    String currentUserId,
  ) async {
    // Get blocked users
    QuerySnapshot blockedSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('blocked_users')
        .get();

    Set<String> blockedUserIds =
        blockedSnapshot.docs.map((doc) => doc['userId'] as String).toSet();

    // Filter out chats with blocked users
    var filteredChats = chatDocs.where((doc) {
      var participants = List<String>.from(doc['participants'] ?? []);
      var otherUserId = participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );

      // Skip chats with blocked users
      if (blockedUserIds.contains(otherUserId)) {
        return false;
      }

      if (_searchQuery.isEmpty) {
        return true;
      }

      if (!userDataMap.containsKey(otherUserId)) {
        return false;
      }

      var userData = userDataMap[otherUserId]!;
      var userName = (userData['name'] ?? "").toString().toLowerCase();
      var lastMessage = (doc['lastMessage'] ?? "").toString().toLowerCase();

      return userName.contains(_searchQuery) ||
          lastMessage.contains(_searchQuery);
    }).toList();

    return filteredChats;
  }

  // Build individual chat item
  Widget _buildChatItem(
    QueryDocumentSnapshot chat,
    Map<String, DocumentSnapshot> userDataMap,
    String currentUserId,
  ) {
    var participants = List<String>.from(chat['participants'] ?? []);
    var otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    // Use null-aware operator to access userData safely
    var userData = userDataMap[otherUserId];
    if (userData == null || !userData.exists) {
      return const SizedBox.shrink(); // Return empty widget
    }

    var userDataMap2 = userData.data() as Map<String, dynamic>;
    var lastMessage = chat['lastMessage'] ?? "No messages yet";
    var timestamp = chat['lastMessageTimestamp'] != null
        ? (chat['lastMessageTimestamp'] as Timestamp)
        : Timestamp.now();
    bool isUnread = chat['unreadBy'] != null &&
        (chat['unreadBy'] as List<dynamic>).contains(currentUserId);

    final String name = userDataMap2['name'] ?? 'Unknown';
    final String profileImg =
        userDataMap2['profileImageUrl'] ?? userDataMap2['profileImg'] ?? '';
    final String fcmToken = userDataMap2['fcmToken'] ?? '';
    final String role = userDataMap2['role'] ?? 'user';
    final String uid = userDataMap2['uid'] ?? otherUserId;

    return InkWell(
      onTap: () => NavigationHelper.navigateTo(
        context,
        Message(
          uid: uid,
          name: name,
          profileImg: profileImg,
          fcmToken: fcmToken,
        ),
      ),
      child: Ink(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color:
              isUnread ? AppTheme.primary.withOpacity(0.03) : AppTheme.surface,
          // border: Border(
          //   bottom: BorderSide(
          //     color: AppTheme.border,
          //     width: 1,
          //   ),
          // ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile image - circular container
            Container(
              width: 52.w,
              height: 52.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: profileImg.isEmpty
                    ? AppTheme.primaryBackground
                    : AppTheme.border,
                image: profileImg.isNotEmpty
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(
                          profileImg,
                          cacheManager: CustomCacheManager(),
                          cacheKey: '${profileImg}_chat',
                        ),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {},
                      )
                    : null,
              ),
              child: profileImg.isEmpty
                  ? Center(
                      child: Iconify(
                        Ph.user,
                        color: AppTheme.primary,
                        size: 24.sp,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 16.w),

            // Content area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row with time
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: TextConstants.mediumText.copyWith(
                                  fontSize: 15.sp,
                                  fontWeight: isUnread
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            VerifyBadge(
                              role: role,
                              size: 14.0,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTimestamp(timestamp),
                            style: TextConstants.smallText.copyWith(
                              fontSize: 12.sp,
                              color: isUnread
                                  ? AppTheme.primary
                                  : AppTheme.textLight,
                              fontWeight:
                                  isUnread ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          if (isUnread) ...[
                            SizedBox(width: 8.w),
                            Container(
                              width: 8.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Last message
                  Text(
                    lastMessage,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 13.sp,
                      fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                      color: isUnread
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Floating App Bar with Search
            SliverAppBar(
              backgroundColor: AppTheme.surface,
              elevation: 0,
              floating: true,
              snap: true,
              pinned: true,
              expandedHeight: 130.h,
              surfaceTintColor: AppTheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      // Top Bar
                      CustomTopBar(
                        centerText: 'Messages',
                        showEdit: true,
                        showSearch: false,
                        onEditTap: () {
                          NavigationHelper.navigateTo(
                              context, const NewMessageScreen());
                        },
                      ),
                      SizedBox(height: 20.h),

                      // Search Bar using ActionSearchBar - navigates to search screen
                      ActionSearchBar.navigate(
                        hintText: 'Search conversations',
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              duration: const Duration(milliseconds: 200),
                              child: const SearchScreen(
                                context: SearchContext.messaging,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(1.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.border,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content Section
            _buildSliverContent(currentUserId),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverContent(String currentUserId) {
    if (currentUserId.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'Please log in to view messages',
            style: TextConstants.mediumText.copyWith(
              fontSize: 18.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastMessageTimestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    IconlyBold.danger,
                    size: 48.sp,
                    color: AppTheme.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading messages',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 18.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    IconlyBold.chat,
                    size: 64.sp,
                    color: AppTheme.textLight,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No messages yet',
                    style: TextConstants.boldText.copyWith(
                      fontSize: 18.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      'Start a conversation with someone',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final chatDocs = snapshot.data!.docs;

        // Use FutureBuilder to fetch user data and filter chats
        return FutureBuilder<Map<String, DocumentSnapshot>>(
          future: _getUserDataMap(chatDocs, currentUserId),
          builder: (context, userDataSnapshot) {
            if (!userDataSnapshot.hasData) {
              return SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primary,
                  ),
                ),
              );
            }

            final userDataMap = userDataSnapshot.data!;

            return FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _filterChats(chatDocs, userDataMap, currentUserId),
              builder: (context, filteredSnapshot) {
                if (!filteredSnapshot.hasData) {
                  return SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                      ),
                    ),
                  );
                }

                final filteredChats = filteredSnapshot.data!;

                if (filteredChats.isEmpty && _searchQuery.isNotEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No conversations found',
                        style: TextConstants.mediumText.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                if (filteredChats.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            IconlyBold.chat,
                            size: 64.sp,
                            color: AppTheme.textLight,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No messages yet',
                            style: TextConstants.boldText.copyWith(
                              fontSize: 18.sp,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40.w),
                            child: Text(
                              'Start a conversation with someone',
                              style: TextConstants.smallText.copyWith(
                                fontSize: 14.sp,
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Show chats list
                return SliverPadding(
                  padding: EdgeInsets.only(
                    bottom: 60.h,
                    // top: 8.h,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildChatItem(
                          filteredChats[index],
                          userDataMap,
                          currentUserId,
                        );
                      },
                      childCount: filteredChats.length,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
