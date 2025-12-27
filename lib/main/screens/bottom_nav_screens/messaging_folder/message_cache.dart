import 'dart:convert';
import 'package:campcon/main/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MessageCacheService {
  static const String _messagesBoxName = 'chat_messages';
  static bool _initialized = false;

  // Keep track of open boxes to prevent closing a box multiple times
  static final Map<String, Box<String>> _openBoxes = {};

  // Add a lock to prevent concurrent access
  static final Map<String, bool> _boxLocks = {};

  // Initialize Hive
  static Future<void> init() async {
    if (_initialized) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDir.path);

      // Try to clear any corrupted boxes
      await _clearCorruptedBoxes();

      _initialized = true;
      debugPrint('Message cache initialized successfully');
    } catch (e) {
      debugPrint('Error initializing message cache: $e');
    }
  }

  // Add this method to handle corrupted boxes
  static Future<void> _clearCorruptedBoxes() async {
    try {
      // Use the file system approach instead of trying to access boxes directly
      final appDir = await getApplicationDocumentsDirectory();
      final hivePath = appDir.path;
      final boxPattern = RegExp(r'chat_messages_.*\.hive');

      final directory = Directory(hivePath);
      if (await directory.exists()) {
        final hiveFiles = directory
            .listSync()
            .where((file) => boxPattern.hasMatch(file.path))
            .toList();

        debugPrint('Found ${hiveFiles.length} potential message cache files');

        for (final file in hiveFiles) {
          final fileName = file.path.split(Platform.pathSeparator).last;
          // Extract box name without extension
          final boxName = fileName.replaceAll('.hive', '');

          try {
            // Try to open it to check if it's valid
            await Hive.openBox<String>(boxName);
          } catch (e) {
            debugPrint('Found corrupted box: $boxName, deleting it');
            await Hive.deleteBoxFromDisk(boxName);
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing corrupted boxes: $e');
    }
  }

  // Get box name for a specific chat
  static String _getChatBoxName(String chatId) {
    return '${_messagesBoxName}_$chatId';
  }

  // Open a box if not already open
  static Future<Box<String>> _getBox(String chatId) async {
    if (!_initialized) await init();

    final boxName = _getChatBoxName(chatId);

    // Wait if another operation is accessing this box
    while (_boxLocks[boxName] == true) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Set lock
    _boxLocks[boxName] = true;

    try {
      // Return cached box if it exists and is open
      if (_openBoxes.containsKey(boxName) && _openBoxes[boxName]!.isOpen) {
        return _openBoxes[boxName]!;
      }

      try {
        // Try to open the box
        final box = await Hive.openBox<String>(boxName);
        _openBoxes[boxName] = box;
        return box;
      } catch (e) {
        // If we can't open it, delete and recreate it
        debugPrint('Error opening box $boxName: $e');
        await Hive.deleteBoxFromDisk(boxName);

        // Try one more time with a fresh box
        final box = await Hive.openBox<String>(boxName);
        _openBoxes[boxName] = box;
        return box;
      }
    } finally {
      // Release lock
      _boxLocks[boxName] = false;
    }
  }

  // Safely close all boxes when app is closing
  static Future<void> closeAllBoxes() async {
    for (var entry in _openBoxes.entries) {
      if (entry.value.isOpen) {
        await entry.value.close();
      }
    }
    _openBoxes.clear();
  }

  // Helper method to make a message JSON-encodable
  static Map<String, dynamic> _makeSerializable(Map<String, dynamic> message) {
    final result = Map<String, dynamic>.from(message);

    // Convert Timestamp to a format that can be serialized
    if (result['timestamp'] is Timestamp) {
      final timestamp = result['timestamp'] as Timestamp;
      // Store as a map with seconds and nanoseconds
      result['timestamp'] = {
        '_seconds': timestamp.seconds,
        '_nanoseconds': timestamp.nanoseconds
      };
    }

    return result;
  }

  // Cache messages - store as JSON strings to avoid adapter requirements
  static Future<void> cacheMessages(
      String chatId, List<dynamic> messages) async {
    if (messages.isEmpty) return;

    try {
      final box = await _getBox(chatId);

      // Use a batch operation for efficiency
      final Map<String, String> entries = {};
      for (var message in messages) {
        final Map<String, dynamic> messageData;

        if (message is ChatMessage) {
          messageData = {
            'messageId': message.messageId,
            'senderId': message.senderId,
            'receiverId': message.receiverId,
            'text': message.text,
            'timestamp':
                Timestamp.fromMillisecondsSinceEpoch(message.timestamp),
            'isRead': message.isRead,
            if (message.imageUrl != null) 'imageUrl': message.imageUrl,
            'edited': message.edited,
          };
        } else if (message is Map<String, dynamic>) {
          messageData = message;
        } else {
          continue; // Skip invalid types
        }

        // Make the message serializable before encoding
        final serializableMessage = _makeSerializable(messageData);
        entries[messageData['messageId']] = jsonEncode(serializableMessage);
      }

      await box.putAll(entries);
    } catch (e) {
      debugPrint('Error caching messages: $e');
    }
  }

  // Get messages from cache with pagination
  static Future<List<Map<String, dynamic>>> getMessages(String chatId,
      {int limit = 25, int offset = 0}) async {
    final List<Map<String, dynamic>> result = [];

    try {
      final box = await _getBox(chatId);

      // Get all messages and sort them
      final allMessages = <Map<String, dynamic>>[];
      for (var key in box.keys) {
        final messageJson = box.get(key);
        if (messageJson != null) {
          try {
            final messageMap = jsonDecode(messageJson) as Map<String, dynamic>;
            allMessages.add(messageMap);
          } catch (e) {
            debugPrint('Error decoding message: $e');
          }
        }
      }

      // Sort by timestamp descending
      allMessages.sort((a, b) {
        final aTime = a['timestamp'] is Map ? a['timestamp']['_seconds'] : 0;
        final bTime = b['timestamp'] is Map ? b['timestamp']['_seconds'] : 0;
        return bTime.compareTo(aTime);
      });

      // Apply pagination
      final paginatedMessages = allMessages.skip(offset).take(limit).toList();
      result.addAll(paginatedMessages);
    } catch (e) {
      debugPrint('Error getting messages from cache: $e');
    }

    return result;
  }

  // Save a single message
  static Future<void> cacheMessage(String chatId, dynamic message) async {
    try {
      final box = await _getBox(chatId);
      final Map<String, dynamic> messageData;

      if (message is ChatMessage) {
        // Convert ChatMessage to Map
        messageData = {
          'messageId': message.messageId,
          'senderId': message.senderId,
          'receiverId': message.receiverId,
          'text': message.text,
          'timestamp': Timestamp.fromMillisecondsSinceEpoch(message.timestamp),
          'isRead': message.isRead,
          if (message.imageUrl != null) 'imageUrl': message.imageUrl,
          'edited': message.edited,
        };
      } else if (message is Map<String, dynamic>) {
        messageData = message;
      } else {
        throw ArgumentError(
            'Message must be either ChatMessage or Map<String, dynamic>');
      }

      // Make the message serializable before encoding
      final serializableMessage = _makeSerializable(messageData);
      await box.put(messageData['messageId'], jsonEncode(serializableMessage));
    } catch (e) {
      debugPrint('Error caching single message: $e');
    }
  }

  // Clear all messages for a chat
  static Future<void> clearChat(String chatId) async {
    try {
      final box = await _getBox(chatId);
      await box.clear();
    } catch (e) {
      debugPrint('Error clearing chat cache: $e');
    }
  }

  // Update a message in cache
  static Future<void> updateMessage(
      String chatId, String messageId, Map<String, dynamic> updates) async {
    try {
      final box = await _getBox(chatId);

      // Get existing message
      final messageJson = box.get(messageId);
      if (messageJson == null) {
        debugPrint('Cannot update message $messageId: not found in cache');
        return;
      }

      // Parse existing message
      Map<String, dynamic> messageData;
      try {
        messageData = jsonDecode(messageJson) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Error decoding message for update: $e');
        return;
      }

      // Apply updates
      updates.forEach((key, value) {
        messageData[key] = value;
      });

      // Save updated message
      await box.put(messageId, jsonEncode(messageData));
    } catch (e) {
      debugPrint('Error updating cached message: $e');
    }
  }

  // Delete a message from cache
  static Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      final box = await _getBox(chatId);
      await box.delete(messageId);
    } catch (e) {
      debugPrint('Error deleting message from cache: $e');
    }
  }
}
