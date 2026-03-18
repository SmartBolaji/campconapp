// Example: Direct usage of Shorebird updater in MainScreen or any screen
// This shows how simple it is to integrate updates

import 'package:flutter/material.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class UpdateCheckButton extends StatefulWidget {
  const UpdateCheckButton({super.key});

  @override
  State<UpdateCheckButton> createState() => _UpdateCheckButtonState();
}

class _UpdateCheckButtonState extends State<UpdateCheckButton> {
  final _updater = ShorebirdUpdater();
  bool _isChecking = false;
  String _status = '';

  Future<void> _checkAndUpdateIfAvailable() async {
    setState(() {
      _isChecking = true;
      _status = 'Checking for updates...';
    });

    try {
      // Check if update is available
      final updateStatus = await _updater.checkForUpdate();

      setState(() {
        if (updateStatus == UpdateStatus.outdated) {
          _status = 'Update available! Installing...';
        } else {
          _status = 'Already up to date!';
          _isChecking = false;
          return;
        }
      });

      // Perform the update if available
      if (updateStatus == UpdateStatus.outdated) {
        await _updater.update();
        setState(() {
          _status = 'Update complete! Restarting...';
          _isChecking = false;
        });
      }
    } on UpdateException catch (e) {
      setState(() {
        _status = 'Update failed: ${e.message}';
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isChecking = false;
      });
    }
  }

  /// Get and display current patch info
  Future<void> _showPatchInfo() async {
    try {
      final patch = await _updater.readCurrentPatch();
      if (patch != null) {
        print('Current patch number: ${patch.number}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Running patch #${patch.number}'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        print('No patches installed (running base release)');
      }
    } catch (e) {
      print('Error reading patch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Check button
        ElevatedButton(
          onPressed: _isChecking ? null : _checkAndUpdateIfAvailable,
          child: _isChecking
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Check for Update'),
        ),
        if (_status.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _status,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 8),
        // Button to show current patch info
        TextButton(
          onPressed: _showPatchInfo,
          child: const Text('Show Current Version'),
        ),
      ],
    );
  }
}
