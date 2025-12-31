import 'package:flutter/material.dart';

class NewPostProvider extends ChangeNotifier {
  bool _showImagePicker = false;
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();

  bool get showImagePicker => _showImagePicker;
  TextEditingController get contentController => _contentController;
  FocusNode get contentFocusNode => _contentFocusNode;

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

  void reset() {
    _contentController.clear();
    _showImagePicker = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }
}
