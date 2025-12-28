import 'package:cloud_firestore/cloud_firestore.dart';

enum PickupCenterStatus {
  pending,
  approved,
  rejected,
  suspended,
}

enum PickupCenterType {
  shop,
  warehouse,
  individual,
}

class PickupCenterModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String? ownerImage;
  final String name;
  final String description;
  final String address;
  final String? landmark;
  final String phoneNumber;
  final String? alternatePhone;
  final PickupCenterType type;
  final PickupCenterStatus status;
  final List<String> operatingDays;
  final String openingTime;
  final String closingTime;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final double rating;
  final int totalPickups;
  final int totalDropoffs;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? rejectionReason;
  final DateTime? approvedAt;
  final DateTime? suspendedAt;

  PickupCenterModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    this.ownerImage,
    required this.name,
    required this.description,
    required this.address,
    this.landmark,
    required this.phoneNumber,
    this.alternatePhone,
    required this.type,
    required this.status,
    required this.operatingDays,
    required this.openingTime,
    required this.closingTime,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.rating = 0.0,
    this.totalPickups = 0,
    this.totalDropoffs = 0,
    required this.createdAt,
    required this.updatedAt,
    this.rejectionReason,
    this.approvedAt,
    this.suspendedAt,
  });

  // Status helpers
  bool get isPending => status == PickupCenterStatus.pending;
  bool get isApproved => status == PickupCenterStatus.approved;
  bool get isRejected => status == PickupCenterStatus.rejected;
  bool get isSuspended => status == PickupCenterStatus.suspended;

  // Type display
  String get typeDisplay {
    switch (type) {
      case PickupCenterType.shop:
        return 'Shop';
      case PickupCenterType.warehouse:
        return 'Warehouse';
      case PickupCenterType.individual:
        return 'Individual';
    }
  }

  // Operating hours display
  String get operatingHours => '$openingTime - $closingTime';

  // Operating days display
  String get operatingDaysDisplay {
    if (operatingDays.length == 7) return 'Everyday';
    if (operatingDays.length == 5 &&
        !operatingDays.contains('Saturday') &&
        !operatingDays.contains('Sunday')) {
      return 'Weekdays';
    }
    if (operatingDays.length == 2 &&
        operatingDays.contains('Saturday') &&
        operatingDays.contains('Sunday')) {
      return 'Weekends';
    }
    return operatingDays.map((d) => d.substring(0, 3)).join(', ');
  }

  // Full address with landmark
  String get fullAddress {
    if (landmark != null && landmark!.isNotEmpty) {
      return '$address (Near $landmark)';
    }
    return address;
  }

  factory PickupCenterModel.fromMap(Map<String, dynamic> map) {
    return PickupCenterModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      ownerImage: map['ownerImage'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      landmark: map['landmark'],
      phoneNumber: map['phoneNumber'] ?? '',
      alternatePhone: map['alternatePhone'],
      type: _parseType(map['type']),
      status: _parseStatus(map['status']),
      operatingDays: List<String>.from(map['operatingDays'] ?? []),
      openingTime: map['openingTime'] ?? '08:00',
      closingTime: map['closingTime'] ?? '18:00',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      imageUrl: map['imageUrl'],
      rating: (map['rating'] ?? 0).toDouble(),
      totalPickups: map['totalPickups'] ?? 0,
      totalDropoffs: map['totalDropoffs'] ?? 0,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      rejectionReason: map['rejectionReason'],
      approvedAt:
          map['approvedAt'] != null ? _parseDateTime(map['approvedAt']) : null,
      suspendedAt: map['suspendedAt'] != null
          ? _parseDateTime(map['suspendedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerImage': ownerImage,
      'name': name,
      'description': description,
      'address': address,
      'landmark': landmark,
      'phoneNumber': phoneNumber,
      'alternatePhone': alternatePhone,
      'type': type.name,
      'status': status.name,
      'operatingDays': operatingDays,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'rating': rating,
      'totalPickups': totalPickups,
      'totalDropoffs': totalDropoffs,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'rejectionReason': rejectionReason,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'suspendedAt':
          suspendedAt != null ? Timestamp.fromDate(suspendedAt!) : null,
    };
  }

  static PickupCenterStatus _parseStatus(String? status) {
    switch (status) {
      case 'approved':
        return PickupCenterStatus.approved;
      case 'rejected':
        return PickupCenterStatus.rejected;
      case 'suspended':
        return PickupCenterStatus.suspended;
      default:
        return PickupCenterStatus.pending;
    }
  }

  static PickupCenterType _parseType(String? type) {
    switch (type) {
      case 'shop':
        return PickupCenterType.shop;
      case 'warehouse':
        return PickupCenterType.warehouse;
      default:
        return PickupCenterType.individual;
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  PickupCenterModel copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? ownerImage,
    String? name,
    String? description,
    String? address,
    String? landmark,
    String? phoneNumber,
    String? alternatePhone,
    PickupCenterType? type,
    PickupCenterStatus? status,
    List<String>? operatingDays,
    String? openingTime,
    String? closingTime,
    double? latitude,
    double? longitude,
    String? imageUrl,
    double? rating,
    int? totalPickups,
    int? totalDropoffs,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? rejectionReason,
    DateTime? approvedAt,
    DateTime? suspendedAt,
  }) {
    return PickupCenterModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerImage: ownerImage ?? this.ownerImage,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      type: type ?? this.type,
      status: status ?? this.status,
      operatingDays: operatingDays ?? this.operatingDays,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      totalPickups: totalPickups ?? this.totalPickups,
      totalDropoffs: totalDropoffs ?? this.totalDropoffs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedAt: approvedAt ?? this.approvedAt,
      suspendedAt: suspendedAt ?? this.suspendedAt,
    );
  }
}
