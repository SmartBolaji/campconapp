// lib/main/provider/resource_provider.dart
import 'package:campcon/main/constants/vars_constants.dart';
import 'package:flutter/material.dart';

class ResourceProvider extends ChangeNotifier {
  int _selectedTab = 0;
  String? _selectedFaculty;
  String? _selectedDepartment;

  final UsableData _usableData = UsableData();

  // Getters
  int get selectedTab => _selectedTab;
  String? get selectedFaculty => _selectedFaculty;
  String? get selectedDepartment => _selectedDepartment;

  // Get unique faculties from departments
  List<String> get faculties {
    final Set<String> uniqueFaculties = {};
    for (var dept in _usableData.departments) {
      uniqueFaculties.add(dept['faculty']!);
    }
    return uniqueFaculties.toList()..sort();
  }

  // Get levels list
  List<String> get levels => _usableData.levelList;

  // Camplist categories
  List<Map<String, dynamic>> get camplistCategories => [
        {
          'icon': Icons.school,
          'label': 'Faculty',
          'subtitle': 'Browse by faculty',
          'color': const Color(0xFF6B4CE6),
        },
        {
          'icon': Icons.business,
          'label': 'School',
          'subtitle': 'University information',
          'color': const Color(0xFF0EA5E9),
        },
        {
          'icon': Icons.home,
          'label': 'Hostel',
          'subtitle': 'Campus accommodations',
          'color': const Color(0xFFEC4899),
        },
        {
          'icon': Icons.restaurant,
          'label': 'Cafeteria',
          'subtitle': 'Dining locations',
          'color': const Color(0xFFF59E0B),
        },
        {
          'icon': Icons.local_library,
          'label': 'Library',
          'subtitle': 'Study resources',
          'color': const Color(0xFF10B981),
        },
        {
          'icon': Icons.medical_services,
          'label': 'Health Center',
          'subtitle': 'Medical facilities',
          'color': const Color(0xFFEF4444),
        },
        {
          'icon': Icons.sports_basketball,
          'label': 'Sports Complex',
          'subtitle': 'Recreation facilities',
          'color': const Color(0xFF8B5CF6),
        },
        {
          'icon': Icons.admin_panel_settings,
          'label': 'Admin Offices',
          'subtitle': 'Administrative centers',
          'color': const Color(0xFF64748B),
        },
      ];

  // Get departments for a specific faculty
  List<String> getDepartmentsForFaculty(String faculty) {
    return _usableData.departments
        .where((dept) => dept['faculty'] == faculty)
        .map((dept) => dept['department']!)
        .toList()
      ..sort();
  }

  // Change tab
  void changeTab(int index) {
    _selectedTab = index;
    _selectedFaculty = null;
    _selectedDepartment = null;
    notifyListeners();
  }

  // Select faculty
  void selectFaculty(String faculty) {
    _selectedFaculty = faculty;
    _selectedDepartment = null;
    notifyListeners();
  }

  // Select department
  void selectDepartment(String department) {
    _selectedDepartment = department;
    notifyListeners();
  }

  // Clear faculty selection
  void clearFacultySelection() {
    _selectedFaculty = null;
    _selectedDepartment = null;
    notifyListeners();
  }

  // Clear department selection
  void clearDepartmentSelection() {
    _selectedDepartment = null;
    notifyListeners();
  }

  // Load data for current tab
  Future<void> loadCurrentTab() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 300));
    notifyListeners();
  }

  // Refresh current tab
  Future<void> refreshCurrentTab() async {
    _selectedFaculty = null;
    _selectedDepartment = null;
    await Future.delayed(const Duration(milliseconds: 300));
    notifyListeners();
  }
}
