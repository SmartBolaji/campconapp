import 'package:cloud_firestore/cloud_firestore.dart';

class ResourceModel {
  final String id;
  final String title;
  final String description;
  final String? faculty;
  final String? department;
  final String? level;
  final String? course;
  final String resourceType;
  final String? fileUrl;
  final String? fileName;
  final bool isExternalLink;
  final String uploaderId;
  final DateTime createdAt;
  final int downloadCount;
  final int likes;

  ResourceModel({
    required this.id,
    required this.title,
    required this.description,
    this.faculty,
    this.department,
    this.level,
    this.course,
    required this.resourceType,
    this.fileUrl,
    this.fileName,
    this.isExternalLink = false,
    required this.uploaderId,
    required this.createdAt,
    this.downloadCount = 0,
    this.likes = 0,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      faculty: json['faculty'],
      department: json['department'],
      level: json['level'],
      course: json['course'],
      resourceType: json['resourceType'] ?? 'Other',
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      isExternalLink: json['isExternalLink'] ?? false,
      uploaderId: json['uploaderId'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      downloadCount: json['downloadCount'] ?? 0,
      likes: json['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'faculty': faculty,
      'department': department,
      'level': level,
      'course': course,
      'resourceType': resourceType,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'isExternalLink': isExternalLink,
      'uploaderId': uploaderId,
      'createdAt': Timestamp.fromDate(createdAt),
      'downloadCount': downloadCount,
      'likes': likes,
    };
  }

  ResourceModel copyWith({
    String? id,
    String? title,
    String? description,
    String? faculty,
    String? department,
    String? level,
    String? course,
    String? resourceType,
    String? fileUrl,
    String? fileName,
    bool? isExternalLink,
    String? uploaderId,
    DateTime? createdAt,
    int? downloadCount,
    int? likes,
  }) {
    return ResourceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      level: level ?? this.level,
      course: course ?? this.course,
      resourceType: resourceType ?? this.resourceType,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      isExternalLink: isExternalLink ?? this.isExternalLink,
      uploaderId: uploaderId ?? this.uploaderId,
      createdAt: createdAt ?? this.createdAt,
      downloadCount: downloadCount ?? this.downloadCount,
      likes: likes ?? this.likes,
    );
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String? category; // Campus category (Faculty, Hostel, Library, etc.)
  final String? faculty;
  final String? department;
  final String? level;
  final String? course;
  final String priority;
  final DateTime? dueDate;
  final bool hasReminder;
  final bool isPersonal;
  final String userId;
  final bool isCompleted;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.category,
    this.faculty,
    this.department,
    this.level,
    this.course,
    required this.priority,
    this.dueDate,
    this.hasReminder = false,
    this.isPersonal = true,
    required this.userId,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'],
      faculty: json['faculty'],
      department: json['department'],
      level: json['level'],
      course: json['course'],
      priority: json['priority'] ?? 'Medium',
      dueDate: json['dueDate'] != null
          ? (json['dueDate'] as Timestamp).toDate()
          : null,
      hasReminder: json['hasReminder'] ?? false,
      isPersonal: json['isPersonal'] ?? true,
      userId: json['userId'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'faculty': faculty,
      'department': department,
      'level': level,
      'course': course,
      'priority': priority,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'hasReminder': hasReminder,
      'isPersonal': isPersonal,
      'userId': userId,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && !isCompleted;
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? faculty,
    String? department,
    String? level,
    String? course,
    String? priority,
    DateTime? dueDate,
    bool? hasReminder,
    bool? isPersonal,
    String? userId,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      level: level ?? this.level,
      course: course ?? this.course,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      hasReminder: hasReminder ?? this.hasReminder,
      isPersonal: isPersonal ?? this.isPersonal,
      userId: userId ?? this.userId,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
