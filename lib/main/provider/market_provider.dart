
import 'package:campcon/main/models/product_model.dart';
import 'package:flutter/material.dart';

class MarketplaceProvider extends ChangeNotifier {
  int selectedTab = 0;
  String sortBy = 'Closest to me';
  List<Product> products = [];
  List<Product> services = [];

  List<Product> get currentList => selectedTab == 0 ? products : services;

  void changeTab(int index) {
    selectedTab = index;
    notifyListeners();
  }

  void changeSortBy(String newSortBy) {
    sortBy = newSortBy;
    notifyListeners();
  }

  void addProduct(Product product) {
    if (product.isItem) {
      products.add(product);
    } else {
      services.add(product);
    }
    notifyListeners();
  }

  void removeProduct(int index) {
    if (selectedTab == 0) {
      products.removeAt(index);
    } else {
      services.removeAt(index);
    }
    notifyListeners();
  }
}