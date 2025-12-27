import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String orderId;
  final String productId;
  final String buyerId;
  final String buyerName;
  final String? buyerImage;
  final String sellerId;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.buyerId,
    required this.buyerName,
    this.buyerImage,
    required this.sellerId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      orderId: map['orderId'] ?? '',
      productId: map['productId'] ?? '',
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      buyerImage: map['buyerImage'],
      sellerId: map['sellerId'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'],
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerImage': buyerImage,
      'sellerId': sellerId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}
