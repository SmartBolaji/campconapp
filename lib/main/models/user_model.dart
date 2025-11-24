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
  final String? school; // Add this
  final String? level; // Add this
  final String? department; // Add this
  final List<String>? interests; // Add this

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
    this.school, // Add this
    this.level, // Add this
    this.department, // Add this
    this.interests, // Add this
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      aboutMe: map['aboutMe'],
      username: map['username'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      isStudent: map['isStudent'],
      school: map['school'], // Add this
      level: map['level'], // Add this
      department: map['department'], // Add this
      interests: map['interests'] != null
          ? List<String>.from(map['interests'])
          : null, // Add this
    );
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
      'school': school, // Add this
      'level': level, // Add this
      'department': department, // Add this
      'interests': interests, // Add this
    };
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
    String? school, // Add this
    String? level, // Add this
    String? department, // Add this
    List<String>? interests, // Add this
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
      school: school ?? this.school, // Add this
      level: level ?? this.level, // Add this
      department: department ?? this.department, // Add this
      interests: interests ?? this.interests, // Add this
    );
  }
}
