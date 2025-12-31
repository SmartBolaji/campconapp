import 'dart:io';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime eventDate;
  final DateTime eventTime;
  final String? imageUrl;
  final File? imageFile;
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

  //  New ticket stock fields
  final bool sellOnCampcon;
  final int? ticketStock;
  final int soldTickets;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.eventDate,
    required this.eventTime,
    this.imageUrl,
    this.imageFile,
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
    this.sellOnCampcon = false, //  New
    this.ticketStock, //  New
    this.soldTickets = 0, //  New
  });

  //  Calculate available tickets
  int get availableTickets {
    if (!sellOnCampcon || ticketStock == null) return 0;
    return ticketStock! - soldTickets;
  }

  //  Check if tickets are sold out
  bool get isSoldOut {
    if (!sellOnCampcon) return false;
    return availableTickets <= 0;
  }

  String get formattedPrice {
    if (isFree) return 'Free';
    if (ticketPrice == null) return 'Free';
    return '₦${ticketPrice!.toStringAsFixed(0)}';
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
    };
  }
}
