import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? aboutMe;
  final String username;
  final String? profileImageUrl;
  final String phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool? isStudent;
  final String? school;
  final String? level;
  final String? department;
  final List<String>? interests;
  final String? bio;
  final String? profileImage;
  final int followersCount;
  final int followingCount;
  final String? campus;
  final String role;
  final String? fcmToken;

  // Engagement-based personalization fields
  final List<String> engagedTags; // Tags from posts user liked/commented
  final List<String> engagedAuthors; // User IDs of authors user engages with
  final List<String> searchHistory; // Recent search terms
  final List<String> viewedCampuses; // Campuses user has shown interest in

  // Professional account fields
  final bool isProfessional;
  final String? businessCategory;
  final String? businessName;
  final String? businessDescription;
  final Map<String, dynamic>? businessHours;
  final Map<String, dynamic>? contactInfo;
  final String? sellerStatus; // 'pending', 'approved', 'rejected'

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.aboutMe,
    required this.username,
    this.profileImageUrl,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    this.isStudent,
    this.school,
    this.level,
    this.department,
    this.interests,
    this.bio,
    this.profileImage,
    this.followersCount = 0,
    this.followingCount = 0,
    this.campus,
    this.role = 'user',
    this.fcmToken,
    // Tags for personalization
    this.engagedTags = const [],
    this.engagedAuthors = const [],
    this.searchHistory = const [],
    this.viewedCampuses = const [],
    // Professional
    this.isProfessional = false,
    this.businessCategory,
    this.businessName,
    this.businessDescription,
    this.businessHours,
    this.contactInfo,
    this.sellerStatus,
  });

  // Add getter for fullName
  String get fullName => name ?? username;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final Map<String, dynamic>? sellerApplication =
        map['sellerApplication'] is Map
            ? Map<String, dynamic>.from(map['sellerApplication'])
            : null;
    final dynamic sellerCategoryRaw =
        sellerApplication == null ? null : sellerApplication['sellerCategory'];
    final dynamic sellerNameRaw =
        sellerApplication == null ? null : sellerApplication['sellerName'];
    final dynamic sellerDescriptionRaw = sellerApplication == null
        ? null
        : sellerApplication['sellerDescription'];
    final dynamic sellerHoursRaw =
        sellerApplication == null ? null : sellerApplication['sellerHours'];
    final dynamic sellerContactRaw =
        sellerApplication == null ? null : sellerApplication['contactInfo'];

    // Safely extract list fields, filtering out non-string values
    List<String> extractStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.where((item) => item is String).cast<String>().toList();
      }
      return [];
    }

    // Safely extract string fields
    String extractString(dynamic value) {
      if (value is String) return value;
      if (value is num) return value.toString();
      return '';
    }

    // Safely parse DateTime from Timestamp or String
    DateTime extractDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return UserModel(
      uid: extractString(map['uid']),
      email: extractString(map['email']),
      name: map['name'] is String ? map['name'] : null,
      aboutMe: map['aboutMe'] is String ? map['aboutMe'] : null,
      username: extractString(map['username']),
      profileImageUrl:
          extractString(map['profileImageUrl'] ?? map['profileImg']),
      phoneNumber: extractString(map['phoneNumber']),
      createdAt: map['createdAt'] != null
          ? extractDateTime(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? extractDateTime(map['updatedAt'])
          : DateTime.now(),
      isStudent: map['isStudent'] is bool ? map['isStudent'] : null,
      school: map['school'] is String ? map['school'] : null,
      level: map['level'] is String ? map['level'] : null,
      department: map['department'] is String ? map['department'] : null,
      interests:
          map['interests'] != null ? extractStringList(map['interests']) : null,
      bio: map['bio'] is String ? map['bio'] : null,
      profileImage: extractString(map['profileImage'] ?? map['profileImg']),
      followersCount: (map['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (map['followingCount'] as num?)?.toInt() ?? 0,
      campus: map['campus'] is String ? map['campus'] : null,
      role: extractString(map['role'] ?? 'user'),
      fcmToken: map['fcmToken'] is String ? map['fcmToken'] : null,
      // Tags for personalization
      engagedTags: extractStringList(map['engagedTags']),
      engagedAuthors: extractStringList(map['engagedAuthors']),
      searchHistory: extractStringList(map['searchHistory']),
      viewedCampuses: extractStringList(map['viewedCampuses']),
      // Professional
      isProfessional:
          map['isProfessional'] is bool ? map['isProfessional'] : false,
      businessCategory: map['businessCategory'] is String
          ? map['businessCategory']
          : (sellerCategoryRaw is String ? sellerCategoryRaw : null),
      businessName: map['businessName'] is String
          ? map['businessName']
          : (sellerNameRaw is String ? sellerNameRaw : null),
      businessDescription: map['businessDescription'] is String
          ? map['businessDescription']
          : (sellerDescriptionRaw is String ? sellerDescriptionRaw : null),
      businessHours: map['businessHours'] is Map
          ? Map<String, dynamic>.from(map['businessHours'])
          : (sellerHoursRaw is Map
              ? Map<String, dynamic>.from(sellerHoursRaw)
              : null),
      contactInfo: map['contactInfo'] is Map
          ? Map<String, dynamic>.from(map['contactInfo'])
          : (sellerContactRaw is Map
              ? Map<String, dynamic>.from(sellerContactRaw)
              : null),
      sellerStatus: map['sellerStatus'] is String ? map['sellerStatus'] : null,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel.fromMap(json);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'aboutMe': aboutMe,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isStudent': isStudent,
      'school': school,
      'level': level,
      'department': department,
      'interests': interests,
      'bio': bio,
      'profileImage': profileImage,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'campus': campus,
      'role': role,
      'fcmToken': fcmToken,
      // Tags for personalization
      'engagedTags': engagedTags,
      'engagedAuthors': engagedAuthors,
      'searchHistory': searchHistory,
      'viewedCampuses': viewedCampuses,
      // Professional
      'isProfessional': isProfessional,
      'businessCategory': businessCategory,
      'businessName': businessName,
      'businessDescription': businessDescription,
      'businessHours': businessHours,
      'contactInfo': contactInfo,
      'sellerStatus': sellerStatus,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? aboutMe,
    String? username,
    String? profileImageUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isStudent,
    String? school,
    String? level,
    String? department,
    List<String>? interests,
    String? bio,
    String? profileImage,
    int? followersCount,
    int? followingCount,
    String? campus,
    String? role,
    String? fcmToken,
    // Tags for personalization
    List<String>? engagedTags,
    List<String>? engagedAuthors,
    List<String>? searchHistory,
    List<String>? viewedCampuses,
    // Professional
    bool? isProfessional,
    String? businessCategory,
    String? businessName,
    String? businessDescription,
    Map<String, dynamic>? businessHours,
    Map<String, dynamic>? contactInfo,
    String? sellerStatus,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      aboutMe: aboutMe ?? this.aboutMe,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isStudent: isStudent ?? this.isStudent,
      school: school ?? this.school,
      level: level ?? this.level,
      department: department ?? this.department,
      interests: interests ?? this.interests,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      campus: campus ?? this.campus,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      // Tags for personalization
      engagedTags: engagedTags ?? this.engagedTags,
      engagedAuthors: engagedAuthors ?? this.engagedAuthors,
      searchHistory: searchHistory ?? this.searchHistory,
      viewedCampuses: viewedCampuses ?? this.viewedCampuses,
      // Professional
      isProfessional: isProfessional ?? this.isProfessional,
      businessCategory: businessCategory ?? this.businessCategory,
      businessName: businessName ?? this.businessName,
      businessDescription: businessDescription ?? this.businessDescription,
      businessHours: businessHours ?? this.businessHours,
      contactInfo: contactInfo ?? this.contactInfo,
      sellerStatus: sellerStatus ?? this.sellerStatus,
    );
  }
}
