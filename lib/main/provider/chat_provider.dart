import 'dart:async';

import 'package:campcon/main/models/random_chat_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/widgets.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  final List<RandomChatMessage> _messages = [];

  String? _currentUserId;
  String? _chatPartnerId;
  String? _activeRandomChatId;
  String? _anonymousPartnerName;
  UserProfile? _currentUserProfile;
  UserProfile? _chatPartnerProfile;

  bool _isRevealed = false;
  bool _revealRequestSent = false;
  bool _revealRequestReceived = false;
  bool _isSearchingMatch = false;

  StreamSubscription<QuerySnapshot>? _messageSubscription;
  StreamSubscription<QuerySnapshot>? _chatSubscription;

  List<RandomChatMessage> get messages => _messages;
  bool get isRevealed => _isRevealed;
  bool get revealRequestSent => _revealRequestSent;
  bool get revealRequestReceived => _revealRequestReceived;
  bool get isSearchingMatch => _isSearchingMatch;
  String? get activeRandomChatId => _activeRandomChatId;

  String get chatPartnerName {
    if (_isRevealed && _chatPartnerProfile != null) {
      return _chatPartnerProfile!.name;
    }
    return _anonymousPartnerName ?? 'Hmm ??';
  }

  String? get currentUserId => _currentUserId;
  String? get chatPartnerId => _chatPartnerId;
  UserProfile? get currentUserProfile => _currentUserProfile;
  UserProfile? get chatPartnerProfile => _chatPartnerProfile;

  void initializeChat({
    required String currentUserId,
    required String chatPartnerId,
    String anonymousPartnerName = 'Hmm ??',
  }) {
    _currentUserId = currentUserId;
    _chatPartnerId = chatPartnerId;
    _anonymousPartnerName = anonymousPartnerName;
    notifyListeners();
  }

  void setCurrentUserProfile(UserProfile profile) {
    _currentUserProfile = profile;
    notifyListeners();
  }

  void setChatPartnerProfile(UserProfile profile) {
    _chatPartnerProfile = profile;
    notifyListeners();
  }

  void setAnonymousPartnerName(String name) {
    _anonymousPartnerName = name;
    notifyListeners();
  }

  void addMessage(RandomChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<void> joinRandomChatQueue({required String currentUserId}) async {
    _currentUserId = currentUserId;
    _isSearchingMatch = true;
    notifyListeners();

    await _listenForMatchedChat(currentUserId);

    try {
      await _firestore.collection('random_chat_queue').doc(currentUserId).set({
        'userId': currentUserId,
        'status': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final callable = _functions.httpsCallable('joinRandomChatQueue');
      await callable.call({'userId': currentUserId});
    } catch (_) {}
  }

  Future<void> _listenForMatchedChat(String currentUserId) async {
    await _chatSubscription?.cancel();
    _chatSubscription = _firestore
        .collection('random_chats')
        .where('participants', arrayContains: currentUserId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) return;

      final doc = snapshot.docs.first;
      final data = doc.data();
      _activeRandomChatId = doc.id;
      _isSearchingMatch = false;
      _isRevealed = data['isRevealed'] ?? false;

      final user1 = data['user1']?.toString() ?? '';
      final user2 = data['user2']?.toString() ?? '';
      _chatPartnerId = user1 == currentUserId ? user2 : user1;

      final revealRequests =
          (data['revealRequests'] as Map<String, dynamic>?) ?? {};
      _revealRequestSent = revealRequests['from'] == currentUserId &&
          revealRequests['status'] == 'pending';
      _revealRequestReceived = revealRequests['to'] == currentUserId &&
          revealRequests['status'] == 'pending';

      await _loadPartnerProfile();
      await _listenMessages(doc.id);
      notifyListeners();
    });
  }

  Future<void> _loadPartnerProfile() async {
    if (_chatPartnerId == null || _chatPartnerId!.isEmpty) return;
    try {
      final userDoc =
          await _firestore.collection('users').doc(_chatPartnerId).get();
      if (!userDoc.exists) return;
      final data = userDoc.data() ?? {};
      _chatPartnerProfile = UserProfile(
        userId: _chatPartnerId!,
        name: (data['name'] ?? data['username'] ?? 'Hmm ??').toString(),
        avatarUrl: data['profileImageUrl']?.toString(),
        isOnline: false,
      );
      if (!_isRevealed) {
        _anonymousPartnerName = 'Hmm ??';
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _listenMessages(String chatId) async {
    await _messageSubscription?.cancel();
    _messageSubscription = _firestore
        .collection('random_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
      _messages
        ..clear()
        ..addAll(snapshot.docs.map((doc) {
          final data = doc.data();
          final sentAt = data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now();
          final hour = sentAt.hour % 12 == 0 ? 12 : sentAt.hour % 12;
          final minute = sentAt.minute.toString().padLeft(2, '0');
          final meridian = sentAt.hour >= 12 ? 'pm' : 'am';

          return RandomChatMessage(
            id: doc.id,
            text: (data['text'] ?? '').toString(),
            time: '$hour:$minute $meridian',
            isSent: (data['senderId'] ?? '') == _currentUserId,
            senderId: (data['senderId'] ?? '').toString(),
          );
        }));
      notifyListeners();
    });
  }

  Future<void> sendMessage(String text, {String? chatId}) async {
    if (_currentUserId == null) return;
    final targetChatId = chatId ?? _activeRandomChatId;
    if (targetChatId == null || text.trim().isEmpty) return;

    await _firestore
        .collection('random_chats')
        .doc(targetChatId)
        .collection('messages')
        .add({
      'senderId': _currentUserId,
      'text': text.trim(),
      'type': 'text',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('random_chats').doc(targetChatId).set({
      'lastMessage': text.trim(),
      'lastMessageSenderId': _currentUserId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void loadMessages(List<RandomChatMessage> messages) {
    _messages
      ..clear()
      ..addAll(messages);
    notifyListeners();
  }

  Future<void> sendRevealRequest({String? chatId}) async {
    if (_currentUserId == null || _chatPartnerId == null) return;
    final targetChatId = chatId ?? _activeRandomChatId;
    if (targetChatId == null) return;

    _revealRequestSent = true;
    notifyListeners();

    await _firestore.collection('random_chats').doc(targetChatId).set({
      'revealRequests': {
        'from': _currentUserId,
        'to': _chatPartnerId,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _createInAppNotification(
      recipientId: _chatPartnerId!,
      title: 'Reveal Request',
      body: 'Your random chat partner wants to reveal profiles.',
      targetId: targetChatId,
      targetType: 'random_chat',
    );
  }

  void receiveRevealRequest() {
    _revealRequestReceived = true;
    notifyListeners();
  }

  Future<void> acceptReveal({String? chatId}) async {
    final targetChatId = chatId ?? _activeRandomChatId;
    if (_currentUserId == null ||
        _chatPartnerId == null ||
        targetChatId == null) {
      return;
    }

    _isRevealed = true;
    _revealRequestReceived = false;
    _revealRequestSent = false;
    notifyListeners();

    await _firestore.collection('random_chats').doc(targetChatId).set({
      'isRevealed': true,
      'revealRequests': {
        'from': _currentUserId,
        'to': _chatPartnerId,
        'status': 'accepted',
        'resolvedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _loadPartnerProfile();

    await _createInAppNotification(
      recipientId: _chatPartnerId!,
      title: 'Reveal Accepted',
      body: 'Your reveal request was accepted.',
      targetId: targetChatId,
      targetType: 'random_chat',
    );
  }

  Future<void> declineReveal({String? chatId}) async {
    final targetChatId = chatId ?? _activeRandomChatId;
    if (_currentUserId == null ||
        _chatPartnerId == null ||
        targetChatId == null) {
      return;
    }

    _revealRequestReceived = false;
    _revealRequestSent = false;
    notifyListeners();

    await _firestore.collection('random_chats').doc(targetChatId).set({
      'revealRequests': {
        'from': _chatPartnerId,
        'to': _currentUserId,
        'status': 'declined',
        'resolvedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _createInAppNotification(
      recipientId: _chatPartnerId!,
      title: 'Reveal Declined',
      body: 'Your reveal request was declined.',
      targetId: targetChatId,
      targetType: 'random_chat',
    );
  }

  Future<void> _createInAppNotification({
    required String recipientId,
    required String title,
    required String body,
    String? targetId,
    String? targetType,
  }) async {
    if (_currentUserId == null || recipientId == _currentUserId) return;
    await _firestore.collection('notifications').add({
      'recipientId': recipientId,
      'actorId': _currentUserId,
      'actorName': _currentUserProfile?.name ?? 'Anonymous',
      'type': 'mention',
      'title': title,
      'body': body,
      'targetId': targetId,
      'targetType': targetType,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'metadata': {
        'kind': 'random_chat',
      },
    });
  }

  Future<void> resetChat() async {
    await _messageSubscription?.cancel();
    await _chatSubscription?.cancel();
    _messageSubscription = null;
    _chatSubscription = null;

    if (_currentUserId != null) {
      try {
        await _firestore
            .collection('random_chat_queue')
            .doc(_currentUserId)
            .delete();
      } catch (_) {}
    }

    _messages.clear();
    _isRevealed = false;
    _revealRequestSent = false;
    _revealRequestReceived = false;
    _isSearchingMatch = false;
    _activeRandomChatId = null;
    _currentUserId = null;
    _chatPartnerId = null;
    _anonymousPartnerName = null;
    _currentUserProfile = null;
    _chatPartnerProfile = null;
    notifyListeners();
  }

  void updatePartnerOnlineStatus(bool isOnline) {
    if (_chatPartnerProfile != null) {
      _chatPartnerProfile = UserProfile(
        userId: _chatPartnerProfile!.userId,
        name: _chatPartnerProfile!.name,
        avatarUrl: _chatPartnerProfile!.avatarUrl,
        isOnline: isOnline,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _chatSubscription?.cancel();
    super.dispose();
  }
}
