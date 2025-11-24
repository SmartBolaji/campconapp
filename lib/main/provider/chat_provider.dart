import 'package:campcon/main/models/story_model.dart';
import 'package:flutter/widgets.dart';



class ChatProvider extends ChangeNotifier  {
  final List<ChatMessage> _messages = [];
  
  String? _currentUserId;
  String? _chatPartnerId;
  String? _anonymousPartnerName; // Set this before reveal
  UserProfile? _currentUserProfile;
  UserProfile? _chatPartnerProfile;
  
  bool _isRevealed = false;
  bool _revealRequestSent = false;
  bool _revealRequestReceived = false;

  List<ChatMessage> get messages => _messages;
  bool get isRevealed => _isRevealed;
  bool get revealRequestSent => _revealRequestSent;
  bool get revealRequestReceived => _revealRequestReceived;
  
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

  // Initialize chat with user IDs
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

  // Set current user profile (from Firebase)
  void setCurrentUserProfile(UserProfile profile) {
    _currentUserProfile = profile;
    notifyListeners();
  }

  // Set chat partner profile (from Firebase, after reveal)
  void setChatPartnerProfile(UserProfile profile) {
    _chatPartnerProfile = profile;
    notifyListeners();
  }

  // Set anonymous partner name before reveal
  void setAnonymousPartnerName(String name) {
    _anonymousPartnerName = name;
    notifyListeners();
  }

  // Add message from Firebase or local
  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  // Send message (you'll implement Firebase logic here)
  void sendMessage(String text) {
    if (_currentUserId == null) return;
    
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'pm' : 'am'}';
    
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      time: time,
      isSent: true,
      senderId: _currentUserId!,
    );
    
    _messages.add(message);
    notifyListeners();
    
    // TODO: Send to Firebase here
    // FirebaseFirestore.instance.collection('chats').add(message);
  }

  // Load messages from Firebase
  void loadMessages(List<ChatMessage> messages) {
    _messages.clear();
    _messages.addAll(messages);
    notifyListeners();
  }

  // Send reveal request (implement Firebase logic)
  void sendRevealRequest() {
    _revealRequestSent = true;
    notifyListeners();
    
    // TODO: Send reveal request to Firebase
    // Send notification to chat partner
  }

  // Receive reveal request (called from Firebase listener)
  void receiveRevealRequest() {
    _revealRequestReceived = true;
    notifyListeners();
  }

  // Accept reveal (fetch partner profile from Firebase)
  void acceptReveal() {
    _isRevealed = true;
    _revealRequestReceived = false;
    _revealRequestSent = false;
    notifyListeners();
    
    // TODO: Fetch partner profile from Firebase using _chatPartnerId
    // FirebaseFirestore.instance.collection('users').doc(_chatPartnerId).get()
    // then call setChatPartnerProfile(profile)
  }

  // Decline reveal
  void declineReveal() {
    _revealRequestReceived = false;
    notifyListeners();
    
    // TODO: Send decline notification to Firebase
  }

  // Reset chat
  void resetChat() {
    _messages.clear();
    _isRevealed = false;
    _revealRequestSent = false;
    _revealRequestReceived = false;
    _currentUserId = null;
    _chatPartnerId = null;
    _anonymousPartnerName = null;
    _currentUserProfile = null;
    _chatPartnerProfile = null;
    notifyListeners();
  }

  // Update partner online status (from Firebase listener)
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
}