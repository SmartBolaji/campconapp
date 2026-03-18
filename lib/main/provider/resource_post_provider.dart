import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campcon/main/provider/upload_status_mixin.dart';
import 'package:campcon/main/services/backblaze.dart';

class ResourcePostProvider extends ChangeNotifier with UploadStatusMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BackblazeService _backblazeService = BackblazeService.instance;

  // Upload Resource Form State
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _fileUrlController = TextEditingController();
  bool _isFileUpload = true; // true = upload file, false = share URL
  String? _selectedFaculty;
  String? _selectedDepartment;
  String? _selectedLevel;
  String? _selectedCourse;
  String? _selectedResourceType;
  File? _selectedFile;
  String? _fileName;

  // Add Task Form State
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();
  String? _taskCategory; // Campus category (Faculty, Hostel, Library, etc.)
  String? _taskFaculty;
  String? _taskDepartment;
  String? _taskLevel;
  String? _taskCourse;
  String? _taskPriority;
  DateTime? _taskDueDate;
  TimeOfDay? _taskDueTime;
  bool _hasReminder = false;
  bool _isPersonalTask = true; // true = personal (private), false = public

  // Resource Types
  final List<String> _resourceTypes = [
    'Lecture Notes',
    'Past Questions',
    'Textbook',
    'Assignment',
    'Lab Report',
    'Project',
    'Slides',
    'Tutorial',
    'Other',
  ];

  // Priority Levels
  final List<String> _priorities = [
    'Low',
    'Medium',
    'High',
    'Urgent',
  ];

  // Getters - Upload Resource
  TextEditingController get titleController => _titleController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get fileUrlController => _fileUrlController;
  bool get isFileUpload => _isFileUpload;
  String? get selectedFaculty => _selectedFaculty;
  String? get selectedDepartment => _selectedDepartment;
  String? get selectedLevel => _selectedLevel;
  String? get selectedCourse => _selectedCourse;
  String? get selectedResourceType => _selectedResourceType;
  File? get selectedFile => _selectedFile;
  String? get fileName => _fileName;
  List<String> get resourceTypes => _resourceTypes;

  // Getters - Add Task
  TextEditingController get taskTitleController => _taskTitleController;
  TextEditingController get taskDescriptionController =>
      _taskDescriptionController;
  String? get taskCategory => _taskCategory;
  String? get taskFaculty => _taskFaculty;
  String? get taskDepartment => _taskDepartment;
  String? get taskLevel => _taskLevel;
  String? get taskCourse => _taskCourse;
  String? get taskPriority => _taskPriority;
  DateTime? get taskDueDate => _taskDueDate;
  TimeOfDay? get taskDueTime => _taskDueTime;
  bool get hasReminder => _hasReminder;
  bool get isPersonalTask => _isPersonalTask;
  List<String> get priorities => _priorities;

  // Setters - Upload Resource
  void setSelectedFaculty(String? faculty) {
    _selectedFaculty = faculty;
    _selectedDepartment = null;
    notifyListeners();
  }

  void setSelectedDepartment(String? department) {
    _selectedDepartment = department;
    notifyListeners();
  }

  void setUploadMode(bool isFileUpload) {
    _isFileUpload = isFileUpload;
    // Clear opposite mode data
    if (isFileUpload) {
      _fileUrlController.clear();
    } else {
      _selectedFile = null;
      _fileName = null;
    }
    notifyListeners();
  }

  void setSelectedLevel(String? level) {
    _selectedLevel = level;
    notifyListeners();
  }

  void setSelectedCourse(String? course) {
    _selectedCourse = course;
    notifyListeners();
  }

  void setSelectedResourceType(String? type) {
    _selectedResourceType = type;
    notifyListeners();
  }

  void setSelectedFile(File? file, {String? name}) {
    _selectedFile = file;
    _fileName = name;
    notifyListeners();
  }

  void clearSelectedFile() {
    _selectedFile = null;
    _fileName = null;
    notifyListeners();
  }

  // Setters - Add Task
  void setTaskCategory(String? category) {
    _taskCategory = category;
    notifyListeners();
  }

  void setTaskFaculty(String? faculty) {
    _taskFaculty = faculty;
    _taskDepartment = null;
    notifyListeners();
  }

  void setTaskDepartment(String? department) {
    _taskDepartment = department;
    notifyListeners();
  }

  void setTaskLevel(String? level) {
    _taskLevel = level;
    notifyListeners();
  }

  void setTaskCourse(String? course) {
    _taskCourse = course;
    notifyListeners();
  }

  void setTaskPriority(String? priority) {
    _taskPriority = priority;
    notifyListeners();
  }

  void setTaskDueDate(DateTime? date) {
    _taskDueDate = date;
    notifyListeners();
  }

  void setTaskDueTime(TimeOfDay? time) {
    _taskDueTime = time;
    notifyListeners();
  }

  void toggleReminder(bool value) {
    _hasReminder = value;
    notifyListeners();
  }

  void setTaskVisibility(bool isPersonal) {
    _isPersonalTask = isPersonal;
    notifyListeners();
  }

  // Provider-specific wrapper to preserve old call sites.
  void setUploadSuccessForType(String type) {
    super.setUploadSuccess(message: '$type uploaded successfully!');
  }

  // Reset Resource Form
  void resetResourceForm() {
    _titleController.clear();
    _descriptionController.clear();
    _fileUrlController.clear();
    _isFileUpload = true;
    _selectedFaculty = null;
    _selectedDepartment = null;
    _selectedLevel = null;
    _selectedCourse = null;
    _selectedResourceType = null;
    _selectedFile = null;
    _fileName = null;
    notifyListeners();
  }

  // Reset Task Form
  void resetTaskForm() {
    _taskTitleController.clear();
    _taskDescriptionController.clear();
    _taskCategory = null;
    _taskFaculty = null;
    _taskDepartment = null;
    _taskLevel = null;
    _taskCourse = null;
    _taskPriority = null;
    _taskDueDate = null;
    _taskDueTime = null;
    _hasReminder = false;
    _isPersonalTask = true;
    notifyListeners();
  }

  // Validation - Upload Resource
  String? validateResourceForm() {
    if (_titleController.text.trim().isEmpty) {
      return 'Please enter a title';
    }
    if (_selectedResourceType == null) {
      return 'Please select a resource type';
    }
    if (_isFileUpload && _selectedFile == null) {
      return 'Please select a file to upload';
    }
    if (!_isFileUpload && _fileUrlController.text.trim().isEmpty) {
      return 'Please enter a file URL';
    }
    if (!_isFileUpload) {
      final url = _fileUrlController.text.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return 'Please enter a valid URL (starting with http:// or https://)';
      }
    }
    return null;
  }

  // Validation - Add Task
  String? validateTaskForm() {
    if (_taskTitleController.text.trim().isEmpty) {
      return 'Please enter a task title';
    }
    if (_taskCategory == null) {
      return 'Please select a category';
    }
    if (_taskDueDate == null) {
      return 'Please select a due date';
    }
    return null;
  }

  // Upload Resource Silently
  Future<bool> uploadResourceSilently({
    required String userId,
  }) async {
    final validationError = validateResourceForm();
    if (validationError != null) {
      return false;
    }

    startSilentUpload();

    try {
      String? fileUrl;
      String? finalFileName;

      if (_isFileUpload && _selectedFile != null) {
        // Upload file to Backblaze
        updateSilentUploadProgress(0.1, message: 'Preparing file...');

        updateSilentUploadProgress(0.3, message: 'Uploading file...');
        // Compress file before upload
        final compressedFile =
            await _backblazeService.compressImage(_selectedFile!);
        // Upload via Cloud Function
        fileUrl = await _backblazeService.uploadImageToCloud(compressedFile);
        finalFileName = _fileName;

        updateSilentUploadProgress(0.7, message: 'File uploaded...');
        debugPrint('✓ File uploaded successfully');
      } else {
        // Use provided URL
        fileUrl = _fileUrlController.text.trim();
        // Extract filename from URL or use a generic name
        final uri = Uri.tryParse(fileUrl);
        finalFileName = uri?.pathSegments.isNotEmpty == true
            ? uri!.pathSegments.last
            : 'External Link';
        updateSilentUploadProgress(0.5, message: 'Validating URL...');
      }

      setProcessing('Publishing resource...');
      updateSilentUploadProgress(0.9, message: 'Publishing resource...');

      final resourceRef = _firestore.collection('resources').doc();

      final resource = {
        'id': resourceRef.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'faculty': _selectedFaculty,
        'department': _selectedDepartment,
        'level': _selectedLevel,
        'course': _selectedCourse,
        'resourceType': _selectedResourceType,
        'fileUrl': fileUrl,
        'fileName': finalFileName,
        'isExternalLink': !_isFileUpload,
        'uploaderId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'downloadCount': 0,
        'likes': 0,
      };

      await resourceRef.set(resource);

      setUploadSuccessForType('Resource');
      debugPrint('✓ Resource uploaded successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error uploading resource: $e');
      setUploadFailed('Failed to upload resource. Please try again.');
      return false;
    }
  }

  // Add Task Silently
  Future<bool> addTaskSilently({
    required String userId,
  }) async {
    final validationError = validateTaskForm();
    if (validationError != null) {
      return false;
    }

    startSilentUpload();

    try {
      setProcessing('Creating task...');
      updateSilentUploadProgress(0.5, message: 'Creating task...');

      final taskRef = _firestore.collection('tasks').doc();

      DateTime? fullDueDateTime;
      if (_taskDueDate != null) {
        if (_taskDueTime != null) {
          fullDueDateTime = DateTime(
            _taskDueDate!.year,
            _taskDueDate!.month,
            _taskDueDate!.day,
            _taskDueTime!.hour,
            _taskDueTime!.minute,
          );
        } else {
          fullDueDateTime = _taskDueDate;
        }
      }

      final task = {
        'id': taskRef.id,
        'title': _taskTitleController.text.trim(),
        'description': _taskDescriptionController.text.trim(),
        'category': _taskCategory,
        'faculty': _taskFaculty,
        'department': _taskDepartment,
        'level': _taskLevel,
        'course': _taskCourse,
        'priority': _taskPriority ?? 'Medium',
        'dueDate': fullDueDateTime != null
            ? Timestamp.fromDate(fullDueDateTime)
            : null,
        'hasReminder': _hasReminder,
        'isPersonal': _isPersonalTask,
        'userId': userId,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await taskRef.set(task);

      updateSilentUploadProgress(1.0, message: 'Task created!');
      // setUploadSuccess('Task');
      debugPrint('✓ Task created successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating task: $e');
      setUploadFailed('Failed to create task. Please try again.');
      return false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fileUrlController.dispose();
    _taskTitleController.dispose();
    _taskDescriptionController.dispose();
    super.dispose();
  }
}
