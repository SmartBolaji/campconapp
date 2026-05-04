import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/message.dart';
import 'package:campcon/main/services/cache.dart';
import 'package:campcon/main/widgets/navigation_helper.dart';
import 'package:campcon/main/widgets/role_badge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});

  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  bool _isSearching = false;
  List<DocumentSnapshot> _searchResults = [];
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Set focus to search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query, String currentUserId) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Search by userId, name, or bio that contains the query
      final usersRef = FirebaseFirestore.instance.collection('users');

      // Query for users where userId contains the search query
      final userIdResults = await usersRef
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(10)
          .get();

      // Query for users where name contains the search query
      final nameResults = await usersRef
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(10)
          .get();

      // Combine results and remove duplicates and current user
      final Map<String, DocumentSnapshot> uniqueResults = {};

      for (var doc in userIdResults.docs) {
        if (doc['uid'] != currentUserId) {
          uniqueResults[doc.id] = doc;
        }
      }

      for (var doc in nameResults.docs) {
        if (doc['uid'] != currentUserId) {
          uniqueResults[doc.id] = doc;
        }
      }

      setState(() {
        _searchResults = uniqueResults.values.toList();
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Error searching users: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _navigateToMessageScreen(DocumentSnapshot userData) {
    final data = userData.data() as Map<String, dynamic>;
    NavigationHelper.navigateTo(
      context,
      Message(
        uid: data['uid'] ?? '',
        name: data['name'] ?? 'Unknown',
        profileImg: data['profileImageUrl'] ?? data['profileImg'] ?? '',
        fcmToken: data['fcmToken'] ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            color: AppTheme.surface,
            child: Row(
              children: [
                // Back Button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Iconify(
                    Ph.arrow_left,
                    size: 24.sp,
                    color: AppTheme.textPrimary,
                  ),
                ),
                // Search Field
                Expanded(
                  child: Container(
                    height: 45.h,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 16.w),
                        Text(
                          'To:',
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            style: TextConstants.smallText.copyWith(
                              fontSize: 16.sp,
                              height: 1.0,
                            ),
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Search for users...',
                              hintStyle: TextConstants.smallText.copyWith(
                                fontSize: 16.sp,
                                color: AppTheme.textLight,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 13.h),
                              suffixIcon: searchQuery.isNotEmpty
                                  ? IconButton(
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                      icon:
                                          const Icon(IconlyLight.close_square),
                                      color: AppTheme.primary,
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          searchQuery = '';
                                          _searchResults = [];
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                              _searchUsers(value.toLowerCase(),
                                  currentUserId.toLowerCase());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isSearching
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                    ),
                  )
                : searchQuery.isEmpty
                    ? _buildEmptyState()
                    : _searchResults.isEmpty
                        ? _buildNoResultsState()
                        : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64.sp,
            color: AppTheme.textLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'Search for users to message',
            style: TextConstants.boldText.copyWith(
              fontSize: 16.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Enter a name or user ID',
            style: TextConstants.smallText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64.sp,
            color: AppTheme.textLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'No users found',
            style: TextConstants.boldText.copyWith(
              fontSize: 16.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try a different search term',
            style: TextConstants.smallText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final userData = _searchResults[index];
        final data = userData.data() as Map<String, dynamic>;

        final String oderId = data['username'] ?? data['uid'] ?? '';
        final String name = data['name'] ?? 'Unknown';
        final String profileImg =
            data['profileImageUrl'] ?? data['profileImg'] ?? '';
        final String role = data['role'] ?? 'user';

        return Padding(
          padding: EdgeInsets.only(top: index == 0 ? 10.h : 0),
          child: InkWell(
            onTap: () => _navigateToMessageScreen(userData),
            child: Ink(
              width: double.infinity,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 18.w),
                padding: EdgeInsets.symmetric(
                  vertical: 8.h,
                  // horizontal: 18.w,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: _searchResults.length > 1
                      ? Border(
                          bottom: BorderSide(color: AppTheme.border),
                        )
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile image - matching custom_top_bar.dart style
                    Container(
                      width: 52.w,
                      height: 52.h,
                      padding: profileImg.isEmpty
                          ? EdgeInsets.all(12.w)
                          : EdgeInsets.zero,
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
                                  cacheKey: '${profileImg}_profile',
                                ),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {},
                              )
                            : null,
                      ),
                      child: profileImg.isEmpty
                          ? Iconify(
                              Ph.user,
                              color: AppTheme.primary,
                              size: 24.sp,
                            )
                          : null,
                    ),
                    SizedBox(width: 16.w),
                    // User info
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User name with verification badge
                          Row(
                            children: [
                              Text(
                                name,
                                style: TextConstants.mediumText.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // Verify Badge
                              RoleBadge(
                                role: role,
                                size: 14.0,
                              ),
                            ],
                          ),
                          // add dot and user id
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 6.0, right: 6.0),
                            child: Text(
                              '•',
                              style: TextConstants.mediumText.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // User ID
                          Text(
                            oderId.isNotEmpty ? '@$oderId' : '',
                            style: TextConstants.smallText.copyWith(
                              fontSize: 14.sp,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Chevron icon
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16.sp,
                      color: AppTheme.textLight,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
