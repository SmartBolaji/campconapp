import 'dart:io';

class Product {
  final String name;
  final String price;
  final String location;
  final File? imageFile;
  final bool isItem;
  final String description;
  final String category;

  Product({
    required this.name,
    required this.price,
    required this.location,
    this.imageFile,
    required this.isItem,
    required this.description,
    required this.category,
  });
}