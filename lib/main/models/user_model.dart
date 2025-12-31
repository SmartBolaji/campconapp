import 'dart:io';

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
  });

  // Add getter for fullName
  String get fullName => name ?? username;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      aboutMe: map['aboutMe'],
      username: map['username'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? map['profileImg'],
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      isStudent: map['isStudent'],
      school: map['school'],
      level: map['level'],
      department: map['department'],
      interests:
          map['interests'] != null ? List<String>.from(map['interests']) : null,
      bio: map['bio'],
      profileImage: map['profileImage'] ?? map['profileImg'],
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      campus: map['campus'],
      role: map['role'] ?? 'user',
      fcmToken: map['fcmToken'],
      // Tags for personalization
      engagedTags: List<String>.from(map['engagedTags'] ?? []),
      engagedAuthors: List<String>.from(map['engagedAuthors'] ?? []),
      searchHistory: List<String>.from(map['searchHistory'] ?? []),
      viewedCampuses: List<String>.from(map['viewedCampuses'] ?? []),
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
    );
  }
}
