import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportType { post, event, product }

enum ReportStatus { pending, underReview, resolved, dismissed }

enum ReportPriority { low, medium, high }

class ReportModel {
  final String reportId;
  final ReportType reportType; // post | event | product
  final String targetId; // postId | eventId | productId
  final String targetTitle; // Display name of the reported content
  final String? targetImageUrl;
  final String? targetDescription; // Short excerpt of the content
  final String? targetLocation; // For events

  // Reporter info
  final String reporterId;
  final String reporterName;
  final String? reporterProfileImage;

  // Report details
  final String reason; // e.g. Spam/Promotion, Misleading Info, Harassment
  final String? additionalDetails;

  // Admin fields
  final ReportStatus status;
  final ReportPriority priority;
  final String? resolvedBy; // Admin UID
  final String? resolutionNote;
  final DateTime? resolvedAt;

  final DateTime createdAt;
  final String school; // Campus/school context

  ReportModel({
    required this.reportId,
    required this.reportType,
    required this.targetId,
    required this.targetTitle,
    this.targetImageUrl,
    this.targetDescription,
    this.targetLocation,
    required this.reporterId,
    required this.reporterName,
    this.reporterProfileImage,
    required this.reason,
    this.additionalDetails,
    this.status = ReportStatus.pending,
    this.priority = ReportPriority.medium,
    this.resolvedBy,
    this.resolutionNote,
    this.resolvedAt,
    required this.createdAt,
    required this.school,
  });

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String get reportTypeLabel {
    switch (reportType) {
      case ReportType.post:
        return 'POST REPORT';
      case ReportType.event:
        return 'EVENT REPORT';
      case ReportModel _:
      case ReportType.product:
        return 'PRODUCT REPORT';
    }
  }

  String get statusLabel {
    switch (status) {
      case ReportStatus.pending:
        return 'PENDING';
      case ReportStatus.underReview:
        return 'UNDER REVIEW';
      case ReportStatus.resolved:
        return 'RESOLVED';
      case ReportStatus.dismissed:
        return 'DISMISSED';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case ReportPriority.low:
        return 'LOW PRIORITY';
      case ReportPriority.medium:
        return 'MEDIUM PRIORITY';
      case ReportPriority.high:
        return 'HIGH PRIORITY';
    }
  }

  bool get isActionable =>
      status == ReportStatus.pending || status == ReportStatus.underReview;

  // ─── Serialization ──────────────────────────────────────────────────────────

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      reportId: map['reportId'] ?? '',
      reportType: ReportType.values.firstWhere(
        (e) => e.name == map['reportType'],
        orElse: () => ReportType.post,
      ),
      targetId: map['targetId'] ?? '',
      targetTitle: map['targetTitle'] ?? '',
      targetImageUrl: map['targetImageUrl'],
      targetDescription: map['targetDescription'],
      targetLocation: map['targetLocation'],
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? '',
      reporterProfileImage: map['reporterProfileImage'],
      reason: map['reason'] ?? '',
      additionalDetails: map['additionalDetails'],
      status: ReportStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReportStatus.pending,
      ),
      priority: ReportPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => ReportPriority.medium,
      ),
      resolvedBy: map['resolvedBy'],
      resolutionNote: map['resolutionNote'],
      resolvedAt: map['resolvedAt'] is Timestamp
          ? (map['resolvedAt'] as Timestamp).toDate()
          : map['resolvedAt'] != null
              ? DateTime.tryParse(map['resolvedAt'])
              : null,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      school: map['school'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'reportType': reportType.name,
      'targetId': targetId,
      'targetTitle': targetTitle,
      if (targetImageUrl != null) 'targetImageUrl': targetImageUrl,
      if (targetDescription != null) 'targetDescription': targetDescription,
      if (targetLocation != null) 'targetLocation': targetLocation,
      'reporterId': reporterId,
      'reporterName': reporterName,
      if (reporterProfileImage != null)
        'reporterProfileImage': reporterProfileImage,
      'reason': reason,
      if (additionalDetails != null) 'additionalDetails': additionalDetails,
      'status': status.name,
      'priority': priority.name,
      if (resolvedBy != null) 'resolvedBy': resolvedBy,
      if (resolutionNote != null) 'resolutionNote': resolutionNote,
      if (resolvedAt != null) 'resolvedAt': resolvedAt!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'school': school,
    };
  }

  ReportModel copyWith({
    String? reportId,
    ReportType? reportType,
    String? targetId,
    String? targetTitle,
    String? targetImageUrl,
    String? targetDescription,
    String? targetLocation,
    String? reporterId,
    String? reporterName,
    String? reporterProfileImage,
    String? reason,
    String? additionalDetails,
    ReportStatus? status,
    ReportPriority? priority,
    String? resolvedBy,
    String? resolutionNote,
    DateTime? resolvedAt,
    DateTime? createdAt,
    String? school,
  }) {
    return ReportModel(
      reportId: reportId ?? this.reportId,
      reportType: reportType ?? this.reportType,
      targetId: targetId ?? this.targetId,
      targetTitle: targetTitle ?? this.targetTitle,
      targetImageUrl: targetImageUrl ?? this.targetImageUrl,
      targetDescription: targetDescription ?? this.targetDescription,
      targetLocation: targetLocation ?? this.targetLocation,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      reporterProfileImage: reporterProfileImage ?? this.reporterProfileImage,
      reason: reason ?? this.reason,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      createdAt: createdAt ?? this.createdAt,
      school: school ?? this.school,
    );
  }
}

// ─── Predefined report reasons ──────────────────────────────────────────────

class ReportReasons {
  static const List<String> postReasons = [
    'Spam/Promotion',
    'Misleading Information',
    'Harassment or Bullying',
    'Hate Speech',
    'Nudity or Sexual Content',
    'Violence or Dangerous Content',
    'Intellectual Property Violation',
    'Other',
  ];

  static const List<String> eventReasons = [
    'Misleading Information',
    'Fake Event',
    'Spam/Promotion',
    'Inappropriate Content',
    'Safety Concern',
    'Other',
  ];

  static const List<String> productReasons = [
    'Counterfeit Product',
    'Misleading Description',
    'Prohibited Item',
    'Spam/Scam',
    'Wrong Category',
    'Other',
  ];
}




