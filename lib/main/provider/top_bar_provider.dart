import 'package:flutter/material.dart';

class TopBarProvider extends ChangeNotifier {
  String _searchQuery = '';
  bool _isSearching = false;

  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    if (!_isSearching) {
      _searchQuery = '';
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
  }
}
