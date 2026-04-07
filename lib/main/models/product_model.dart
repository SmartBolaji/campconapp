import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final List<String> imageUrls; // Multiple images
  final File? imageFile;
  final List<File>? imageFiles; // Multiple image files
  final String category;
  final bool isItem;
  final String sellerId;
  final String location;
  final DateTime createdAt;
  final int? stock;
  final double? discount;
  final double? discountedPrice;
  final String? wageType;
  final int? views;
  final double? averageRating;
  final int? reviewCount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.imageUrls = const [],
    this.imageFile,
    this.imageFiles,
    required this.category,
    required this.isItem,
    required this.sellerId,
    required this.location,
    required this.createdAt,
    this.stock,
    this.discount,
    this.discountedPrice,
    this.wageType,
    this.views,
    this.averageRating,
    this.reviewCount,
  });

  // Get all images (primary + additional, deduplicated)
  List<String> get allImageUrls {
    if (imageUrl != null && imageUrls.isEmpty) {
      return [imageUrl!];
    } else if (imageUrl != null && imageUrls.isNotEmpty) {
      // Avoid duplicating imageUrl if it's already the first item in imageUrls
      if (imageUrls.first == imageUrl) {
        return imageUrls;
      }
      return [imageUrl!, ...imageUrls];
    }
    return imageUrls;
  }

  // Helper for price display
  String get formattedPrice {
    if (price == 0) return 'Free';
    final formatter = NumberFormat("#,##0", "en_US");
    String formattedPrice = formatter.format(discountedPrice ?? price);
    return '₦$formattedPrice';
  }

  String get originalPriceFormatted {
    final formatter = NumberFormat("#,##0", "en_US");
    String formattedPrice = formatter.format(price);
    return '₦$formattedPrice';
  }

  String? get priceLabel {
    if (!isItem && wageType != null) {
      switch (wageType) {
        case 'hourly':
          return '₦${price.toStringAsFixed(0)}/hr';
        case 'daily':
          return '₦${price.toStringAsFixed(0)}/day';
        case 'weekly':
          return '₦${price.toStringAsFixed(0)}/week';
        case 'monthly':
          return '₦${price.toStringAsFixed(0)}/month';
        case 'onetime':
          return formattedPrice;
        default:
          return formattedPrice;
      }
    }
    return null;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // Safely extract list fields, filtering out non-string values
    List<String> extractStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value
            .where((item) => item is String)
            .cast<String>()
            .toList();
      }
      return [];
    }

    // Safely extract string fields
    String extractString(dynamic value) {
      if (value is String) return value;
      if (value is num) return value.toString();
      return '';
    }

    return Product(
      id: extractString(json['id']),
      name: extractString(json['name']),
      description: extractString(json['description']),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] is String ? json['imageUrl'] : null,
      imageUrls: extractStringList(json['imageUrls']),
      category: extractString(json['category']),
      isItem: json['isItem'] is bool ? json['isItem'] : true,
      sellerId: extractString(json['sellerId']),
      location: extractString(json['location']),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(json['createdAt'].toString()))
          : DateTime.now(),
      stock: json['stock'] is num ? json['stock'] : null,
      discount: (json['discount'] as num?)?.toDouble(),
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
      wageType: json['wageType'] is String ? json['wageType'] : null,
      views: json['views'] is num ? json['views'] : null,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] is num ? json['reviewCount'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'category': category,
      'isItem': isItem,
      'sellerId': sellerId,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      if (stock != null) 'stock': stock,
      if (discount != null) 'discount': discount,
      if (discountedPrice != null) 'discountedPrice': discountedPrice,
      if (wageType != null) 'wageType': wageType,
      if (views != null) 'views': views,
      if (averageRating != null) 'averageRating': averageRating,
      if (reviewCount != null) 'reviewCount': reviewCount,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    List<String>? imageUrls,
    File? imageFile,
    List<File>? imageFiles,
    String? category,
    bool? isItem,
    String? sellerId,
    String? location,
    DateTime? createdAt,
    int? stock,
    double? discount,
    double? discountedPrice,
    String? wageType,
    int? views,
    double? averageRating,
    int? reviewCount,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      imageFile: imageFile ?? this.imageFile,
      imageFiles: imageFiles ?? this.imageFiles,
      category: category ?? this.category,
      isItem: isItem ?? this.isItem,
      sellerId: sellerId ?? this.sellerId,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      stock: stock ?? this.stock,
      discount: discount ?? this.discount,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      wageType: wageType ?? this.wageType,
      views: views ?? this.views,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
