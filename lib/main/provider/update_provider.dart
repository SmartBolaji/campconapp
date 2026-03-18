import 'package:flutter/material.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class UpdateProvider extends ChangeNotifier {
  final _updater = ShorebirdUpdater();

  bool _isChecking = false;
  bool _isUpdating = false;
  String? _updateMessage;
  UpdateStatus? _updateStatus;

  bool get isChecking => _isChecking;
  bool get isUpdating => _isUpdating;
  String? get updateMessage => _updateMessage;
  UpdateStatus? get updateStatus => _updateStatus;

  /// Get current patch information
  Future<Patch?> getCurrentPatch() async {
    try {
      final patch = await _updater.readCurrentPatch();
      return patch;
    } catch (e) {
      debugPrint('❌ Error reading current patch: $e');
      return null;
    }
  }

  /// Check for available updates
  Future<bool> checkForUpdate() async {
    if (_isChecking || _isUpdating) return false;

    _isChecking = true;
    _updateMessage = 'Checking for updates...';
    notifyListeners();

    try {
      _updateStatus = await _updater.checkForUpdate();
      _isChecking = false;

      if (_updateStatus == UpdateStatus.outdated) {
        _updateMessage = 'Update available! Tap Install to proceed.';
        notifyListeners();
        return true;
      } else if (_updateStatus == UpdateStatus.upToDate) {
        _updateMessage = 'You\'re running the latest version!';
        notifyListeners();
        return false;
      } else {
        _updateMessage = 'Unable to check for updates.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isChecking = false;
      _updateMessage = 'Error checking for updates: $e';
      debugPrint('❌ Update check error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Install the available update
  Future<bool> installUpdate() async {
    if (_isUpdating || _isChecking) return false;
    if (_updateStatus != UpdateStatus.outdated) return false;

    _isUpdating = true;
    _updateMessage = 'Installing update...';
    notifyListeners();

    try {
      await _updater.update();
      _isUpdating = false;
      _updateMessage = 'Update installed successfully!';
      notifyListeners();
      return true;
    } on UpdateException catch (e) {
      _isUpdating = false;
      _updateMessage = 'Update failed: ${e.message}';
      debugPrint('❌ Update error: ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _isUpdating = false;
      _updateMessage = 'Update failed: $e';
      debugPrint('❌ Update error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Reset state
  void reset() {
    _isChecking = false;
    _isUpdating = false;
    _updateMessage = null;
    _updateStatus = null;
    notifyListeners();
  }
}
