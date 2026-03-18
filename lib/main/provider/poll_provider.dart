import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campcon/main/models/poll_model.dart';

class PollProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  // Poll cache by postId
  final Map<String, PollModel> _pollCache = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get poll from cache
  PollModel? getPoll(String postId) {
    return _pollCache[postId];
  }

  /// Cache a poll
  void cachePoll(String postId, PollModel poll) {
    _pollCache[postId] = poll;
    notifyListeners();
  }

  /// Vote on a poll option
  /// Returns the updated poll if successful
  Future<PollModel?> votePoll({
    required String postId,
    required String optionId,
    required String userId,
    required PollModel currentPoll,
  }) async {
    setLoading(true);
    clearError();

    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final updatedOptions = currentPoll.options.map((option) {
        if (option.id == optionId) {
          // Check if user hasn't already voted for this option
          if (!option.votedBy.contains(userId)) {
            return option.copyWith(
              votes: option.votes + 1,
              votedBy: [...option.votedBy, userId],
            );
          }
          return option;
        }
        return option;
      }).toList();

      // Calculate new total votes
      int totalVotes = updatedOptions.fold(0, (sum, opt) => sum + opt.votes);

      final updatedPoll = currentPoll.copyWith(
        options: updatedOptions,
        totalVotes: totalVotes,
      );

      // Update in Firestore
      await postRef.update({
        'poll': updatedPoll.toMap(),
      });

      // Update local cache immediately for UI update
      cachePoll(postId, updatedPoll);

      setLoading(false);
      return updatedPoll;
    } catch (e) {
      debugPrint('Error voting on poll: $e');
      setError('Failed to vote on poll');
      setLoading(false);
      return null;
    }
  }

  /// Close a poll (stop accepting votes)
  Future<bool> closePoll({
    required String postId,
    required PollModel currentPoll,
  }) async {
    setLoading(true);
    clearError();

    try {
      final postRef = _firestore.collection('posts').doc(postId);

      final updatedPoll = currentPoll.copyWith(isClosed: true);

      await postRef.update({
        'poll': updatedPoll.toMap(),
      });

      // Update local cache
      cachePoll(postId, updatedPoll);

      setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Error closing poll: $e');
      setError('Failed to close poll');
      setLoading(false);
      return false;
    }
  }

  /// Get poll results with sorted options
  List<PollOption> getPollResultsSorted(PollModel poll) {
    final sorted = List<PollOption>.from(poll.options);
    sorted.sort((a, b) => b.votes.compareTo(a.votes));
    return sorted;
  }

  /// Clear specific poll from cache
  void clearPoll(String postId) {
    _pollCache.remove(postId);
    notifyListeners();
  }

  /// Clear all cached polls
  void clearAllPolls() {
    _pollCache.clear();
    notifyListeners();
  }
}
