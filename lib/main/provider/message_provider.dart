import 'dart:async';
import 'package:campcon/main/models/message_model.dart';
import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/message_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MessageProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current active chat
  String? _currentChatId;
  String? _currentUserId;
  String? _otherUserId;

  // Other user data
  Map<String, dynamic>? _otherUserData;

  // Messages
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Typing indicator
  bool _isOtherUserTyping = false;
  Timer? _typingTimer;

  // Chat manager
  ChatManager? _chatManager;

  // Stream subscriptions
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  StreamSubscription<DocumentSnapshot>? _typingSubscription;

  // Getters
  String? get currentChatId => _currentChatId;
  String? get currentUserId => _currentUserId;
  String? get otherUserId => _otherUserId;
  Map<String, dynamic>? get otherUserData => _otherUserData;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get isOtherUserTyping => _isOtherUserTyping;
  ChatManager? get chatManager => _chatManager;

  // Generate chat ID from two user IDs
  String getChatId(String currentUserId, String otherUserId) {
    return (currentUserId.hashCode <= otherUserId.hashCode)
        ? "$currentUserId-$otherUserId"
        : "$otherUserId-$currentUserId";
  }

  // Initialize chat
  Future<void> initializeChat({
    required String currentUserId,
    required String otherUserId,
  }) async {
    _currentUserId = currentUserId;
    _otherUserId = otherUserId;
    _currentChatId = getChatId(currentUserId, otherUserId);
    _isLoading = true;
    notifyListeners();

    // Initialize chat manager
    _chatManager = ChatManager(
      chatId: _currentChatId!,
      currentUserId: currentUserId,
    );

    // Load other user data
    await loadOtherUserData(otherUserId);

    // Start listening to typing indicator
    _startTypingListener();

    _isLoading = false;
    notifyListeners();
  }

  // Load other user data from Firestore
  Future<void> loadOtherUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _otherUserData = doc.data();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Start listening to typing indicator
  void _startTypingListener() {
    if (_currentChatId == null || _otherUserId == null) return;

    _typingSubscription?.cancel();
    _typingSubscription = _firestore
        .collection('chats')
        .doc(_currentChatId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          final typing = data['typing'] as Map<String, dynamic>?;
          if (typing != null) {
            _isOtherUserTyping = typing[_otherUserId] == true;
            notifyListeners();
          }
        }
      }
    });
  }

  // Send message
  Future<void> sendMessage({
    required String text,
    String? imageUrl,
    ChatMessage? replyTo,
  }) async {
    if (_chatManager == null || _currentUserId == null || _otherUserId == null)
      return;

    try {
      await _chatManager!.sendMessage(
        text: text,
        receiverId: _otherUserId!,
        imageUrl: imageUrl,
        replyTo: replyTo,
      );
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
    }
  }

  // Send image message
  Future<void> sendImageMessage({
    required String imageUrl,
    String? text,
  }) async {
    if (_chatManager == null || _otherUserId == null) return;

    try {
      await _chatManager!.sendImageMessage(
        text: text ?? '',
        receiverId: _otherUserId!,
        imageUrl: imageUrl,
      );
    } catch (e) {
      _errorMessage = 'Failed to send image: $e';
      notifyListeners();
    }
  }

  // Load more messages
  Future<void> loadMoreMessages() async {
    if (_chatManager == null || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      await _chatManager!.loadMoreMessages();
    } catch (e) {
      debugPrint('Error loading more messages: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Set typing status
  Future<void> setTyping(bool isTyping) async {
    if (_currentChatId == null || _currentUserId == null) return;

    try {
      await _firestore.collection('chats').doc(_currentChatId).set({
        'typing': {
          _currentUserId: isTyping,
        },
      }, SetOptions(merge: true));

      // Auto-clear typing after 3 seconds
      _typingTimer?.cancel();
      if (isTyping) {
        _typingTimer = Timer(const Duration(seconds: 3), () {
          setTyping(false);
        });
      }
    } catch (e) {
      // Silently fail for typing indicator
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead() async {
    if (_chatManager == null) return;

    try {
      await _chatManager!.markAllAsRead();
    } catch (e) {
      // Silently fail
    }
  }

  // Edit message
  Future<void> editMessage(String messageId, String newText) async {
    if (_chatManager == null) return;

    try {
      await _chatManager!.editMessage(messageId, newText);
    } catch (e) {
      _errorMessage = 'Failed to edit message: $e';
      notifyListeners();
    }
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    if (_chatManager == null) return;

    try {
      await _chatManager!.deleteMessage(messageId);
    } catch (e) {
      _errorMessage = 'Failed to delete message: $e';
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clean up
  void disposeChat() {
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();
    _chatManager?.dispose();
    _chatManager = null;
    _currentChatId = null;
    _currentUserId = null;
    _otherUserId = null;
    _otherUserData = null;
    _messages = [];
    _isOtherUserTyping = false;
  }

  @override
  void dispose() {
    disposeChat();
    super.dispose();
  }
}
