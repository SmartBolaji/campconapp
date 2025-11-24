import 'package:campcon/main/models/chat_model.dart';
import 'package:flutter/material.dart';

class MarketChatProvider extends ChangeNotifier {
  // Hardcoded current user ID for demonstration, should be replaced by AuthService.currentUser.id
  final String currentUserId = 'user_self_123'; 
  
  // The list of messages for the currently viewed conversation
  List<MessageModel> _messages = [];
  
  // The ID of the conversation being viewed
  String _conversationId = '';

  List<MessageModel> get messages => _messages;
  String get conversationId => _conversationId;

  // Function to initialize the chat with a conversation ID and fetch messages
  void loadConversation(String id) {
    _conversationId = id;
    // In a real app, this would trigger a Firestore/API call to fetch messages
    // For now, we use dynamic mock data
    _messages = _generateMockMessages(id);
    // Sort by timestamp newest last for display order
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    notifyListeners();
  }

  // Temporary function to simulate fetching data for different conversations
  List<MessageModel> _generateMockMessages(String conversationId) {
    // This logic should be replaced by reading from a database (e.g., Firestore)
    return [
      MessageModel(
        senderId: currentUserId,
        text: 'Hello, is this available?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5, seconds: 30)),
      ),
      MessageModel(
        senderId: 'recipient_456',
        text: 'Yes, it is. Where are you located?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4, seconds: 15)),
      ),
      MessageModel(
        senderId: currentUserId,
        text: 'I\'m near the old market. How much is the final price?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2, seconds: 50)),
      ),
    ];
  }

  // Function to simulate sending a new message
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final newMessage = MessageModel(
      senderId: currentUserId,
      text: text,
      timestamp: DateTime.now(),
    );

    // In a real app, this would involve writing to the database first.
    // The Firestore listener would then update the list via the _messages stream.
    
    _messages.add(newMessage);
    // Re-sort or ensure ordering if needed, then notify
    notifyListeners();
  }

  // Add more methods for message status (read, delete, etc.)
}
// class ChatService extends ChangeNotifier {
//   // get instance of firestore
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // get user stream
//   Stream<List<Map<String, dynamic>>> getUserStream() {
//     return _firestore.collection("Users").snapshots().map((snapshot) {
//       return snapshot.docs.map((docs) {
//         final user = docs.data();
//         return user;
//       }).toList();
//     });
//   }
//   // send message

//   // get message
// }
