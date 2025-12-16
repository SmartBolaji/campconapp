import 'dart:io';
import 'package:intl/intl.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final File? imageFile;
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

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.imageFile,
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
  });

  // ✅ Helper for price display
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
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
      category: json['category'] ?? '',
      isItem: json['isItem'] ?? true,
      sellerId: json['sellerId'] ?? '',
      location: json['location'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      stock: json['stock'],
      discount: json['discount']?.toDouble(),
      discountedPrice: json['discountedPrice']?.toDouble(),
      wageType: json['wageType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isItem': isItem,
      'sellerId': sellerId,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      if (stock != null) 'stock': stock,
      if (discount != null) 'discount': discount,
      if (discountedPrice != null) 'discountedPrice': discountedPrice,
      if (wageType != null) 'wageType': wageType,
    };
  }
}
