// lib/main/provider/resource_provider.dart
import 'package:campcon/main/constants/vars_constants.dart';
import 'package:campcon/main/models/resource_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResourceProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedTab = 0;
  String? _selectedFaculty;
  String? _selectedDepartment;
  String? _selectedLevel;

  final UsableData _usableData = UsableData();

  // Resources & Tasks State
  List<ResourceModel> _resources = [];
  List<TaskModel> _publicTasks = [];
  List<TaskModel> _personalTasks = [];
  bool _isLoadingResources = false;
  bool _isLoadingTasks = false;
  String? _resourcesError;
  String? _tasksError;
  String? _currentUserId;

  // Getters
  int get selectedTab => _selectedTab;
  String? get selectedFaculty => _selectedFaculty;
  String? get selectedDepartment => _selectedDepartment;
  String? get selectedLevel => _selectedLevel;
  String? get currentUserId => _currentUserId;

  List<ResourceModel> get resources => _resources;
  List<TaskModel> get publicTasks => _publicTasks;
  List<TaskModel> get personalTasks => _personalTasks;
  List<TaskModel> get allTasks => [..._publicTasks, ..._personalTasks];
  bool get isLoadingResources => _isLoadingResources;
  bool get isLoadingTasks => _isLoadingTasks;
  String? get resourcesError => _resourcesError;
  String? get tasksError => _tasksError;

  // Get tasks filtered by category
  List<TaskModel> getTasksByCategory(String category) {
    return allTasks.where((task) => task.category == category).toList();
  }

  // Get task count for a category
  int getTaskCountForCategory(String category) {
    return allTasks.where((task) => task.category == category).length;
  }

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
    _selectedLevel = null;
    _resources = [];
    notifyListeners();
  }

  // Select level
  void selectLevel(String level) {
    _selectedLevel = level;
    loadResources();
    notifyListeners();
  }

  // Clear level selection
  void clearLevelSelection() {
    _selectedLevel = null;
    _resources = [];
    notifyListeners();
  }

  // Set current user ID
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
    if (userId != null) {
      loadTasks(userId);
    }
  }

  // Load resources based on selected filters
  Future<void> loadResources() async {
    _isLoadingResources = true;
    _resourcesError = null;
    notifyListeners();

    try {
      Query query = _firestore.collection('resources');

      if (_selectedDepartment != null) {
        query = query.where('department', isEqualTo: _selectedDepartment);
      }
      if (_selectedLevel != null) {
        query = query.where('level', isEqualTo: _selectedLevel);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      _resources = snapshot.docs
          .map((doc) =>
              ResourceModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      _isLoadingResources = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading resources: $e');
      _resourcesError = 'Failed to load resources';
      _isLoadingResources = false;
      notifyListeners();
    }
  }

  // Load tasks for a user (public + personal)
  Future<void> loadTasks(String userId) async {
    _isLoadingTasks = true;
    _tasksError = null;
    notifyListeners();

    try {
      // Load public tasks
      final publicSnapshot = await _firestore
          .collection('tasks')
          .where('isPersonal', isEqualTo: false)
          .orderBy('dueDate', descending: false)
          .get();

      _publicTasks = publicSnapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();

      // Load personal tasks for current user
      final personalSnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where('isPersonal', isEqualTo: true)
          .orderBy('dueDate', descending: false)
          .get();

      _personalTasks = personalSnapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();

      _isLoadingTasks = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      _tasksError = 'Failed to load tasks';
      _isLoadingTasks = false;
      notifyListeners();
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'isCompleted': isCompleted,
      });

      // Update local state
      final publicIndex = _publicTasks.indexWhere((t) => t.id == taskId);
      if (publicIndex != -1) {
        final task = _publicTasks[publicIndex];
        _publicTasks[publicIndex] = TaskModel(
          id: task.id,
          title: task.title,
          description: task.description,
          category: task.category,
          faculty: task.faculty,
          department: task.department,
          level: task.level,
          course: task.course,
          priority: task.priority,
          dueDate: task.dueDate,
          hasReminder: task.hasReminder,
          isPersonal: task.isPersonal,
          userId: task.userId,
          isCompleted: isCompleted,
          createdAt: task.createdAt,
        );
      }

      final personalIndex = _personalTasks.indexWhere((t) => t.id == taskId);
      if (personalIndex != -1) {
        final task = _personalTasks[personalIndex];
        _personalTasks[personalIndex] = TaskModel(
          id: task.id,
          title: task.title,
          description: task.description,
          category: task.category,
          faculty: task.faculty,
          department: task.department,
          level: task.level,
          course: task.course,
          priority: task.priority,
          dueDate: task.dueDate,
          hasReminder: task.hasReminder,
          isPersonal: task.isPersonal,
          userId: task.userId,
          isCompleted: isCompleted,
          createdAt: task.createdAt,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
    }
  }

  // Delete task
  Future<bool> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      _publicTasks.removeWhere((t) => t.id == taskId);
      _personalTasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting task: $e');
      return false;
    }
  }

  // Delete resource
  Future<bool> deleteResource(String resourceId) async {
    try {
      await _firestore.collection('resources').doc(resourceId).delete();
      _resources.removeWhere((r) => r.id == resourceId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting resource: $e');
      return false;
    }
  }

  // Increment download count
  Future<void> incrementDownloadCount(String resourceId) async {
    try {
      await _firestore.collection('resources').doc(resourceId).update({
        'downloadCount': FieldValue.increment(1),
      });

      final index = _resources.indexWhere((r) => r.id == resourceId);
      if (index != -1) {
        final resource = _resources[index];
        _resources[index] = ResourceModel(
          id: resource.id,
          title: resource.title,
          description: resource.description,
          faculty: resource.faculty,
          department: resource.department,
          level: resource.level,
          course: resource.course,
          resourceType: resource.resourceType,
          fileUrl: resource.fileUrl,
          fileName: resource.fileName,
          uploaderId: resource.uploaderId,
          createdAt: resource.createdAt,
          downloadCount: resource.downloadCount + 1,
          likes: resource.likes,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error incrementing download count: $e');
    }
  }

  // Load data for current tab
  Future<void> loadCurrentTab() async {
    if (_currentUserId != null) {
      await loadTasks(_currentUserId!);
    }
    await Future.delayed(const Duration(milliseconds: 300));
    notifyListeners();
  }

  // Refresh current tab
  Future<void> refreshCurrentTab() async {
    _selectedFaculty = null;
    _selectedDepartment = null;
    _selectedLevel = null;
    _resources = [];
    if (_currentUserId != null) {
      await loadTasks(_currentUserId!);
    }
    await Future.delayed(const Duration(milliseconds: 300));
    notifyListeners();
  }
}
