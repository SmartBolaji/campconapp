import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class ShorebirdService extends ChangeNotifier {
  final ShorebirdUpdater _updater = ShorebirdUpdater();

  bool _isCheckingForUpdate = false;
  bool _updateAvailable = false;
  String? _currentPatchNumber;
  String? _errorMessage;

  bool get isCheckingForUpdate => _isCheckingForUpdate;
  bool get updateAvailable => _updateAvailable;
  String? get currentPatchNumber => _currentPatchNumber;
  String? get errorMessage => _errorMessage;

  ShorebirdService() {
    _initializePatchNumber();
  }

  Future<void> _initializePatchNumber() async {
    try {
      final currentPatch = await _updater.readCurrentPatch();
      _currentPatchNumber = currentPatch?.number.toString();
      notifyListeners();
    } catch (e) {
      debugPrint('Error reading current patch: $e');
    }
  }

  Future<void> checkForUpdate() async {
    if (_isCheckingForUpdate) return;

    _isCheckingForUpdate = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final status = await _updater.checkForUpdate();

      if (status == UpdateStatus.outdated) {
        _updateAvailable = true;
        notifyListeners();
      } else {
        _updateAvailable = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to check for updates: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    } finally {
      _isCheckingForUpdate = false;
      notifyListeners();
    }
  }

  Future<void> performUpdate() async {
    try {
      await _updater.update();
      // After successful update, reload the patch number
      await _initializePatchNumber();
      _updateAvailable = false;
      notifyListeners();
    } on UpdateException catch (e) {
      _errorMessage = 'Update failed: ${e.message}';
      debugPrint(_errorMessage);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Update failed: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
