import 'dart:async';
import 'package:campcon/main/models/message_model.dart';
import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/message_cache.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ChatManager {
  static const int _messagesPerPage = 25;

  final String chatId;
  final String currentUserId;

  final StreamController<List<ChatMessage>> _messagesController =
      StreamController<List<ChatMessage>>.broadcast();
  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;

  List<ChatMessage> _currentMessages = [];
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  StreamSubscription? _messagesSubscription;

  // Add this field to the ChatManager class (near the top with other fields):
  final Set<String> _justSentMessageIds = {};

  ChatManager({required this.chatId, required this.currentUserId}) {
    _initialize();
  }

  Future<void> _initialize() async {
    // First try to load from cache
    final cachedMessages =
        await MessageCacheService.getMessages(chatId, limit: _messagesPerPage);

    if (cachedMessages.isNotEmpty) {
      // Convert Map to ChatMessage objects
      _currentMessages =
          cachedMessages.map((map) => ChatMessage.fromFirestore(map)).toList();
      _messagesController.add(_currentMessages);
    }

    // Setup real-time listener for new messages
    _setupMessagesListener();
  }

  void _setupMessagesListener() {
    final query = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(_messagesPerPage);

    _messagesSubscription = query.snapshots().listen((snapshot) {
      // Handle real-time updates
      _handleMessagesUpdate(snapshot);
    }, onError: (error) {
      debugPrint('Error listening to messages: $error');
    });
  }

  // Update the _handleMessagesUpdate method to properly preserve the deleted state

  Future<void> _handleMessagesUpdate(QuerySnapshot snapshot) async {
    try {
      // Convert to message objects
      final List<ChatMessage> messages = snapshot.docs
          .map((doc) =>
              ChatMessage.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();

      // Don't try to cache if there are no messages to cache
      if (messages.isNotEmpty) {
        // Cache the new messages
        try {
          await MessageCacheService.cacheMessages(chatId, messages);
        } catch (e) {
          debugPrint('Error caching messages from update: $e');
        }
      }

      // Create efficient merging with messageId as key
      final Map<String, ChatMessage> mergedMap = {};

      // First add existing messages to the map
      for (var message in _currentMessages) {
        mergedMap[message.messageId] = message;
      }

      // Then add/update with messages from Firestore
      for (var message in messages) {
        // Check if message already exists
        final existingMsg = mergedMap[message.messageId];

        // Only update if the message doesn't exist or if the new message has newer data
        // but preserve deleted status if it was already set
        if (existingMsg == null) {
          // New message - add it
          mergedMap[message.messageId] = message;
        } else {
          // Existing message - preserve deleted state if it was already deleted
          if (existingMsg.deleted) {
            // Keep the message marked as deleted even if Firestore hasn't updated yet
            mergedMap[message.messageId] = ChatMessage(
              messageId: message.messageId,
              senderId: message.senderId,
              receiverId: message.receiverId,
              text: 'This message was deleted',
              timestamp: message.timestamp,
              isRead: message.isRead,
              imageUrl: null,
              edited: false,
              deleted: true,
            );
          } else {
            // Normal update
            mergedMap[message.messageId] = message;
          }
        }
      }

      // Convert back to sorted list
      final updatedMessages = mergedMap.values.toList();
      updatedMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Always update to ensure UI reflects current state
      _currentMessages = updatedMessages;
      _messagesController.add(_currentMessages);
    } catch (e) {
      debugPrint('Error handling message update: $e');
    }
  }

  // Helper to check if two message lists are equal
  bool _areListsEqual(List<ChatMessage> list1, List<ChatMessage> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i].messageId != list2[i].messageId ||
          list1[i].isRead != list2[i].isRead ||
          list1[i].edited != list2[i].edited) {
        return false;
      }
    }

    return true;
  }

  Future<void> loadMoreMessages() async {
    if (_isLoadingMore || !_hasMoreMessages) return;

    _isLoadingMore = true;

    try {
      // Get the oldest message timestamp
      final oldestTimestamp = _currentMessages.isEmpty
          ? Timestamp.now()
          : Timestamp.fromMillisecondsSinceEpoch(_currentMessages
              .map((m) => m.timestamp)
              .reduce((min, ts) => ts < min ? ts : min));

      // Query older messages
      final query = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .startAfter([oldestTimestamp])
          .limit(_messagesPerPage)
          .get();

      if (query.docs.isEmpty) {
        _hasMoreMessages = false;
      } else {
        final olderMessages = query.docs
            .map((doc) => ChatMessage.fromFirestore(doc.data()))
            .toList();

        // Cache these messages
        await MessageCacheService.cacheMessages(chatId, olderMessages);

        // Add to current messages
        _currentMessages.addAll(olderMessages);
        _currentMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        _messagesController.add(_currentMessages);
      }
    } catch (e) {
      debugPrint('Error loading more messages: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> markAsRead(String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});

      // Update cache
      await MessageCacheService.updateMessage(
          chatId, messageId, {'isRead': true});

      // Update in-memory list
      final index =
          _currentMessages.indexWhere((m) => m.messageId == messageId);
      if (index >= 0) {
        final updatedMessage = ChatMessage(
          messageId: _currentMessages[index].messageId,
          senderId: _currentMessages[index].senderId,
          receiverId: _currentMessages[index].receiverId,
          text: _currentMessages[index].text,
          timestamp: _currentMessages[index].timestamp,
          isRead: true,
          imageUrl: _currentMessages[index].imageUrl,
          edited: _currentMessages[index].edited,
        );

        _currentMessages[index] = updatedMessage;
        _messagesController.add(_currentMessages);
      }
    } catch (e) {
      debugPrint('Error marking message as read: $e');
    }
  }

  Future<void> sendMessage({
    required String text,
    required String receiverId,
    String? imageUrl,
    ChatMessage? replyTo, // <-- Add this parameter
  }) async {
    try {
      final messageRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      final String messageId = messageRef.id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Build reply metadata if replying
      Map<String, dynamic>? replyData;
      if (replyTo != null) {
        replyData = {
          'messageId': replyTo.messageId,
          'text': replyTo.text,
          'senderId': replyTo.senderId,
          'imageUrl': replyTo.imageUrl,
        };
      }

      // Create message data
      final messageData = {
        'messageId': messageId,
        'senderId': currentUserId,
        'receiverId': receiverId,
        'text': text,
        'timestamp': Timestamp.fromMillisecondsSinceEpoch(timestamp),
        'isRead': false,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (replyData != null) 'replyTo': replyData, // <-- Add reply metadata
      };

      final message = ChatMessage.fromFirestore(messageData);

      final existingIndex =
          _currentMessages.indexWhere((m) => m.messageId == messageId);
      if (existingIndex == -1) {
        _currentMessages.insert(0, message);
        _messagesController.add(_currentMessages);
      }

      await messageRef.set(messageData);

      // You'll need to pass receiver data to save it
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'participants': [currentUserId, receiverId],
        'lastMessage': text,
        'lastMessageTimestamp': Timestamp.fromMillisecondsSinceEpoch(timestamp),
        'lastMessageSenderId': currentUserId,
        'unreadBy': FieldValue.arrayUnion([receiverId]),
      }, SetOptions(merge: true));

      await MessageCacheService.cacheMessage(chatId, message);
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  // Update the sendImageMessage method

  Future<void> sendImageMessage({
    required String text,
    required String receiverId,
    required String imageUrl,
  }) async {
    try {
      // Create message reference
      final messageRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final String messageId = messageRef.id;

      // Create message data
      final Map<String, dynamic> messageData = {
        'messageId': messageId,
        'senderId': currentUserId,
        'receiverId': receiverId,
        'text': text,
        'imageUrl': imageUrl,
        'timestamp': Timestamp.fromMillisecondsSinceEpoch(timestamp),
        'isRead': false,
      };

      // Create message object
      final message = ChatMessage.fromFirestore(messageData);

      // Add locally to avoid delay
      final existingIndex =
          _currentMessages.indexWhere((m) => m.messageId == messageId);
      if (existingIndex == -1) {
        _currentMessages.insert(0, message);
        _messagesController.add(_currentMessages);

        // Keep track of messages we just sent to avoid duplication
        _justSentMessageIds.add(messageId);

        // Remove from tracking after some time
        Future.delayed(const Duration(seconds: 10), () {
          _justSentMessageIds.remove(messageId);
        });
      }

      // Save to Firestore
      await messageRef.set(messageData);

      // Update chat document
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'participants': [currentUserId, receiverId],
        'lastMessage': text.isNotEmpty ? text : 'Image',
        'lastMessageTimestamp': Timestamp.fromMillisecondsSinceEpoch(timestamp),
        'unreadBy': FieldValue.arrayUnion([receiverId]),
      }, SetOptions(merge: true));

      // Cache manually to avoid race condition with the listener
      try {
        await MessageCacheService.cacheMessage(chatId, messageData);
      } catch (e) {
        debugPrint('Error caching image message: $e');
      }
    } catch (e) {
      debugPrint('Error sending image message: $e');
    }
  }

  Future<void> editMessage(String messageId, String newText) async {
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'text': newText,
        'edited': true,
      });

      // Update cache
      await MessageCacheService.updateMessage(
          chatId, messageId, {'text': newText, 'edited': true});

      // Update in-memory list
      final index =
          _currentMessages.indexWhere((m) => m.messageId == messageId);
      if (index >= 0) {
        final updatedMessage = ChatMessage(
          messageId: _currentMessages[index].messageId,
          senderId: _currentMessages[index].senderId,
          receiverId: _currentMessages[index].receiverId,
          text: newText,
          timestamp: _currentMessages[index].timestamp,
          isRead: _currentMessages[index].isRead,
          imageUrl: _currentMessages[index].imageUrl,
          edited: true,
        );

        _currentMessages[index] = updatedMessage;
        _messagesController.add(_currentMessages);
      }
    } catch (e) {
      debugPrint('Error editing message: $e');
      rethrow;
    }
  }

  // Update the deleteMessage method for immediate UI updates

  Future<void> deleteMessage(String messageId) async {
    try {
      // Update UI immediately first for responsive feeling
      final index =
          _currentMessages.indexWhere((m) => m.messageId == messageId);
      if (index >= 0) {
        final deletedMessage = ChatMessage(
          messageId: _currentMessages[index].messageId,
          senderId: _currentMessages[index].senderId,
          receiverId: _currentMessages[index].receiverId,
          text: 'This message was deleted',
          timestamp: _currentMessages[index].timestamp,
          isRead: _currentMessages[index].isRead,
          imageUrl: null,
          edited: false,
          deleted: true,
        );

        // Create a new list with the updated message
        final updatedMessages = List<ChatMessage>.from(_currentMessages);
        updatedMessages[index] = deletedMessage;

        // Update the controller with the new list
        _currentMessages = updatedMessages;
        _messagesController.add(_currentMessages);
      }

      // Get the message to check if it's the most recent one
      final messageDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .get();

      if (!messageDoc.exists) {
        debugPrint('Message $messageId not found for deletion');
        return;
      }

      final wasLastMessage = await _isLastMessage(messageId);

      // Update the message in Firestore
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'text': 'This message was deleted',
        'deleted': true,
        'imageUrl': null, // Remove image URL if it exists
      });

      // If this was the last message, update the chat document
      if (wasLastMessage) {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .update({
          'lastMessage': 'This message was deleted',
        });
      }

      // Update cache
      await MessageCacheService.updateMessage(chatId, messageId, {
        'text': 'This message was deleted',
        'deleted': true,
        'imageUrl': null,
      });
    } catch (e) {
      debugPrint('Error marking message as deleted: $e');
      rethrow;
    }
  }

  // Add this helper method to check if a message is the last one in the chat
  Future<bool> _isLastMessage(String messageId) async {
    try {
      final chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .get();

      if (!chatDoc.exists) return false;

      // Get the most recent message
      final messagesQuery = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (messagesQuery.docs.isEmpty) return false;

      // Check if the most recent message is the one being deleted
      final mostRecentMessageId = messagesQuery.docs.first.id;
      return mostRecentMessageId == messageId;
    } catch (e) {
      debugPrint('Error checking if message is the last one: $e');
      return false;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      // Get all unread messages sent to current user
      final unreadQuery = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadQuery.docs.isEmpty) return;

      // Use a batch write
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in unreadQuery.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      // Update chat document
      await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
        'unreadBy': FieldValue.arrayRemove([currentUserId])
      });

      // Update cache and in-memory messages
      for (var doc in unreadQuery.docs) {
        final messageId = (doc.data())['messageId'];
        await MessageCacheService.updateMessage(
            chatId, messageId, {'isRead': true});

        final index =
            _currentMessages.indexWhere((m) => m.messageId == messageId);
        if (index >= 0) {
          _currentMessages[index] = ChatMessage(
            messageId: _currentMessages[index].messageId,
            senderId: _currentMessages[index].senderId,
            receiverId: _currentMessages[index].receiverId,
            text: _currentMessages[index].text,
            timestamp: _currentMessages[index].timestamp,
            isRead: true,
            imageUrl: _currentMessages[index].imageUrl,
            edited: _currentMessages[index].edited,
          );
        }
      }

      _messagesController.add(_currentMessages);
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  void dispose() {
    _messagesSubscription?.cancel();
    _messagesController.close();
  }
}
