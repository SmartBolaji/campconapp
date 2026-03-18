import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  ready,
  completed,
  cancelled,
}

class OrderModel {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final String sellerId;
  final String sellerName;
  final String buyerId;
  final String? buyerName;
  final String? buyerImage;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String pickupLocation;
  final String? pickupLocationId;
  final String? pickupAddress;
  final String? pickupPhone;
  final String? pickupCenterOwnerId;
  final String paymentMethod;
  final String? orderNotes;
  final OrderStatus status;
  final bool hasReview;
  final String? reviewId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  OrderModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.sellerId,
    required this.sellerName,
    required this.buyerId,
    this.buyerName,
    this.buyerImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.pickupLocation,
    this.pickupLocationId,
    this.pickupAddress,
    this.pickupPhone,
    this.pickupCenterOwnerId,
    required this.paymentMethod,
    this.orderNotes,
    required this.status,
    this.hasReview = false,
    this.reviewId,
    required this.createdAt,
    required this.updatedAt,
    this.confirmedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'],
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'],
      buyerImage: map['buyerImage'],
      quantity: map['quantity'] ?? 1,
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      pickupLocation: map['pickupLocation'] ?? '',
      pickupLocationId: map['pickupLocationId'],
      pickupAddress: map['pickupAddress'],
      pickupPhone: map['pickupPhone'],
      pickupCenterOwnerId: map['pickupCenterOwnerId'],
      paymentMethod: map['paymentMethod'] ?? '',
      orderNotes: map['orderNotes'],
      status: _parseStatus(map['status']),
      hasReview: map['hasReview'] ?? false,
      reviewId: map['reviewId'],
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      confirmedAt: map['confirmedAt'] != null
          ? _parseDateTime(map['confirmedAt'])
          : null,
      completedAt: map['completedAt'] != null
          ? _parseDateTime(map['completedAt'])
          : null,
      cancelledAt: map['cancelledAt'] != null
          ? _parseDateTime(map['cancelledAt'])
          : null,
      cancellationReason: map['cancellationReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerImage': buyerImage,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'pickupLocation': pickupLocation,
      'pickupLocationId': pickupLocationId,
      'pickupAddress': pickupAddress,
      'pickupPhone': pickupPhone,
      'pickupCenterOwnerId': pickupCenterOwnerId,
      'paymentMethod': paymentMethod,
      'orderNotes': orderNotes,
      'status': status.name,
      'hasReview': hasReview,
      'reviewId': reviewId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
    };
  }

  static OrderStatus _parseStatus(String? status) {
    switch (status) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'ready':
        return OrderStatus.ready;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  OrderModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    String? sellerId,
    String? sellerName,
    String? buyerId,
    String? buyerName,
    String? buyerImage,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? pickupLocation,
    String? pickupLocationId,
    String? pickupAddress,
    String? pickupPhone,
    String? pickupCenterOwnerId,
    String? paymentMethod,
    String? orderNotes,
    OrderStatus? status,
    bool? hasReview,
    String? reviewId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return OrderModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerImage: buyerImage ?? this.buyerImage,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      pickupLocationId: pickupLocationId ?? this.pickupLocationId,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupPhone: pickupPhone ?? this.pickupPhone,
      pickupCenterOwnerId: pickupCenterOwnerId ?? this.pickupCenterOwnerId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderNotes: orderNotes ?? this.orderNotes,
      status: status ?? this.status,
      hasReview: hasReview ?? this.hasReview,
      reviewId: reviewId ?? this.reviewId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  // Helper getters
  bool get isPending => status == OrderStatus.pending;
  bool get isConfirmed => status == OrderStatus.confirmed;
  bool get isProcessing => status == OrderStatus.processing;
  bool get isReady => status == OrderStatus.ready;
  bool get isCompleted => status == OrderStatus.completed;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isActive => !isCompleted && !isCancelled;

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get formattedTotal {
    return '₦${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }
}
