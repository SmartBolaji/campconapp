import 'package:campcon/main/models/poll_model.dart';
import 'package:flutter/material.dart';

class NewPostProvider extends ChangeNotifier {
  bool _showImagePicker = false;
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  PollModel? _currentPoll;

  bool get showImagePicker => _showImagePicker;
  TextEditingController get contentController => _contentController;
  FocusNode get contentFocusNode => _contentFocusNode;
  PollModel? get currentPoll => _currentPoll;
  bool get hasPoll => _currentPoll != null;

  void toggleImagePicker() {
    _showImagePicker = !_showImagePicker;
    if (_showImagePicker) {
      _contentFocusNode.unfocus();
    }
    notifyListeners();
  }

  void hideImagePicker() {
    if (_showImagePicker) {
      _showImagePicker = false;
      notifyListeners();
    }
  }

  void showPicker() {
    _showImagePicker = true;
    _contentFocusNode.unfocus();
    notifyListeners();
  }

  void onTextFieldTap() {
    if (_showImagePicker) {
      _showImagePicker = false;
      notifyListeners();
    }
  }

  void clearContent() {
    _contentController.clear();
    notifyListeners();
  }

  void setPoll(PollModel poll) {
    _currentPoll = poll;
    notifyListeners();
  }

  void removePoll() {
    _currentPoll = null;
    notifyListeners();
  }

  void reset() {
    _contentController.clear();
    _showImagePicker = false;
    _currentPoll = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }
}
