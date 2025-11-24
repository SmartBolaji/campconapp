import 'package:flutter/material.dart';

class AnimatedDialogProvider extends ChangeNotifier {
  bool _isVisible = false;
  bool _isContentVisible = false;
  bool _isButtonPressed = false;

  bool get isVisible => _isVisible;
  bool get isContentVisible => _isContentVisible;
  bool get isButtonPressed => _isButtonPressed;

  void show() {
    _isVisible = true;
    notifyListeners();

    // Delay content animation slightly for better effect
    Future.delayed(const Duration(milliseconds: 100), () {
      _isContentVisible = true;
      notifyListeners();
    });
  }

  void hide() {
    _isContentVisible = false;
    notifyListeners();

    // Wait for content to fade out before hiding dialog
    Future.delayed(const Duration(milliseconds: 200), () {
      _isVisible = false;
      notifyListeners();
    });
  }

  void pressButton() {
    _isButtonPressed = true;
    notifyListeners();
  }

  void releaseButton() {
    _isButtonPressed = false;
    notifyListeners();
  }

  void reset() {
    _isVisible = false;
    _isContentVisible = false;
    _isButtonPressed = false;
    notifyListeners();
  }
}
