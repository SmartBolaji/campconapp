import 'dart:io';

// Ticket Tier Model
class TicketTier {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final int sold;

  TicketTier({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.sold = 0,
  });

  int get available => stock - sold;
  bool get isSoldOut => available <= 0;

  String get formattedPrice {
    if (price == 0) return 'Free';
    return '₦${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  factory TicketTier.fromJson(Map<String, dynamic> json) {
    return TicketTier(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      sold: json['sold'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'sold': sold,
    };
  }

  TicketTier copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    int? sold,
  }) {
    return TicketTier(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      sold: sold ?? this.sold,
    );
  }
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime eventDate;
  final DateTime eventTime;
  final String? imageUrl;
  final List<String> imageUrls; // Multiple images
  final File? imageFile;
  final List<File>? imageFiles; // Multiple image files
  final String category;
  final String organizerId;
  final String organizerName;
  final String? ticketLink;
  final double? ticketPrice;
  final bool isFree;
  final DateTime createdAt;
  final int interestedCount;
  final int attendingCount;
  final String school;

  // Ticket fields
  final bool sellOnCampcon;
  final int? ticketStock;
  final int soldTickets;

  // Ticket tiers
  final List<TicketTier> ticketTiers;
  final bool hasMultipleTiers;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.eventDate,
    required this.eventTime,
    this.imageUrl,
    this.imageUrls = const [],
    this.imageFile,
    this.imageFiles,
    required this.category,
    required this.organizerId,
    required this.organizerName,
    this.ticketLink,
    this.ticketPrice,
    required this.isFree,
    required this.createdAt,
    this.interestedCount = 0,
    this.attendingCount = 0,
    required this.school,
    this.sellOnCampcon = false,
    this.ticketStock,
    this.soldTickets = 0,
    this.ticketTiers = const [],
    this.hasMultipleTiers = false,
  });

  // Get all images (primary + additional)
  List<String> get allImageUrls {
    if (imageUrl != null && imageUrls.isEmpty) {
      return [imageUrl!];
    } else if (imageUrl != null && imageUrls.isNotEmpty) {
      return [...imageUrls];
    }
    return imageUrls;
  }

  // Calculate available tickets (across all tiers or single stock)
  int get availableTickets {
    if (hasMultipleTiers && ticketTiers.isNotEmpty) {
      return ticketTiers.fold(0, (sum, tier) => sum + tier.available);
    }
    if (!sellOnCampcon || ticketStock == null) return 0;
    return ticketStock! - soldTickets;
  }

  // Total tickets (across all tiers or single stock)
  int get totalTickets {
    if (hasMultipleTiers && ticketTiers.isNotEmpty) {
      return ticketTiers.fold(0, (sum, tier) => sum + tier.stock);
    }
    return ticketStock ?? 0;
  }

  // Check if tickets are sold out
  bool get isSoldOut {
    if (!sellOnCampcon) return false;
    if (hasMultipleTiers && ticketTiers.isNotEmpty) {
      return ticketTiers.every((tier) => tier.isSoldOut);
    }
    return availableTickets <= 0;
  }

  // Get lowest ticket price
  double? get lowestPrice {
    if (isFree) return null;
    if (hasMultipleTiers && ticketTiers.isNotEmpty) {
      final prices = ticketTiers.map((t) => t.price).where((p) => p > 0);
      if (prices.isEmpty) return null;
      return prices.reduce((a, b) => a < b ? a : b);
    }
    return ticketPrice;
  }

  String get formattedPrice {
    if (isFree) return 'Free';
    if (hasMultipleTiers && ticketTiers.isNotEmpty) {
      final lowest = lowestPrice;
      if (lowest == null) return 'Free';
      return 'From ₦${lowest.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          )}';
    }
    if (ticketPrice == null) return 'Free';
    return '₦${ticketPrice!.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[eventDate.month - 1]} ${eventDate.day}, ${eventDate.year}';
  }

  String get formattedTime {
    final hour = eventTime.hour > 12 ? eventTime.hour - 12 : eventTime.hour;
    final minute = eventTime.minute.toString().padLeft(2, '0');
    final period = eventTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      eventDate: json['eventDate'] != null
          ? DateTime.parse(json['eventDate'])
          : DateTime.now(),
      eventTime: json['eventTime'] != null
          ? DateTime.parse(json['eventTime'])
          : DateTime.now(),
      imageUrl: json['imageUrl'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      category: json['category'] ?? '',
      organizerId: json['organizerId'] ?? '',
      organizerName: json['organizerName'] ?? '',
      ticketLink: json['ticketLink'],
      ticketPrice: json['ticketPrice']?.toDouble(),
      isFree: json['isFree'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      interestedCount: json['interestedCount'] ?? 0,
      attendingCount: json['attendingCount'] ?? 0,
      school: json['school'] ?? '',
      sellOnCampcon: json['sellOnCampcon'] ?? false,
      ticketStock: json['ticketStock'],
      soldTickets: json['soldTickets'] ?? 0,
      ticketTiers: (json['ticketTiers'] as List<dynamic>?)
              ?.map((t) => TicketTier.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      hasMultipleTiers: json['hasMultipleTiers'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'eventDate': eventDate.toIso8601String(),
      'eventTime': eventTime.toIso8601String(),
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'category': category,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'ticketLink': ticketLink,
      'ticketPrice': ticketPrice,
      'isFree': isFree,
      'createdAt': createdAt.toIso8601String(),
      'interestedCount': interestedCount,
      'attendingCount': attendingCount,
      'school': school,
      'sellOnCampcon': sellOnCampcon,
      'ticketStock': ticketStock,
      'soldTickets': soldTickets,
      'ticketTiers': ticketTiers.map((t) => t.toJson()).toList(),
      'hasMultipleTiers': hasMultipleTiers,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? eventDate,
    DateTime? eventTime,
    String? imageUrl,
    List<String>? imageUrls,
    File? imageFile,
    List<File>? imageFiles,
    String? category,
    String? organizerId,
    String? organizerName,
    String? ticketLink,
    double? ticketPrice,
    bool? isFree,
    DateTime? createdAt,
    int? interestedCount,
    int? attendingCount,
    String? school,
    bool? sellOnCampcon,
    int? ticketStock,
    int? soldTickets,
    List<TicketTier>? ticketTiers,
    bool? hasMultipleTiers,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      imageFile: imageFile ?? this.imageFile,
      imageFiles: imageFiles ?? this.imageFiles,
      category: category ?? this.category,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      ticketLink: ticketLink ?? this.ticketLink,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      isFree: isFree ?? this.isFree,
      createdAt: createdAt ?? this.createdAt,
      interestedCount: interestedCount ?? this.interestedCount,
      attendingCount: attendingCount ?? this.attendingCount,
      school: school ?? this.school,
      sellOnCampcon: sellOnCampcon ?? this.sellOnCampcon,
      ticketStock: ticketStock ?? this.ticketStock,
      soldTickets: soldTickets ?? this.soldTickets,
      ticketTiers: ticketTiers ?? this.ticketTiers,
      hasMultipleTiers: hasMultipleTiers ?? this.hasMultipleTiers,
    );
  }
}
