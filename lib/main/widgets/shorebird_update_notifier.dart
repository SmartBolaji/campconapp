import 'package:campcon/main/services/algorithm/shorebird.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShorebirdUpdateNotifier extends StatefulWidget {
  final Widget child;

  const ShorebirdUpdateNotifier({super.key, required this.child});

  @override
  State<ShorebirdUpdateNotifier> createState() =>
      _ShorebirdUpdateNotifierState();
}

class _ShorebirdUpdateNotifierState extends State<ShorebirdUpdateNotifier> {
  bool _hasShownUpdateSnack = false;
  bool _hasShownErrorSnack = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ShorebirdService>(
      builder: (context, shorebirdService, _) {
        if (shorebirdService.updateAvailable) {
          if (!_hasShownUpdateSnack) {
            _hasShownUpdateSnack = true;
            _hasShownErrorSnack = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('A new app update is available.'),
                  action: SnackBarAction(
                    label: 'Update',
                    onPressed: () async {
                      await _performUpdate(context, shorebirdService);
                    },
                  ),
                  duration: const Duration(seconds: 10),
                ),
              );
            });
          }
        } else {
          _hasShownUpdateSnack = false;
        }

        if (shorebirdService.errorMessage != null) {
          if (!_hasShownErrorSnack) {
            _hasShownErrorSnack = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(shorebirdService.errorMessage!),
                  action: SnackBarAction(
                    label: 'Dismiss',
                    onPressed: shorebirdService.clearError,
                  ),
                ),
              );
            });
          }
        } else {
          _hasShownErrorSnack = false;
        }

        return widget.child;
      },
    );
  }

  Future<void> _performUpdate(
    BuildContext context,
    ShorebirdService service,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Installing Update'),
        content: SizedBox(
          height: 80,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    await service.performUpdate();

    if (!mounted) return;
    Navigator.pop(context);

    if (service.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Update installed successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
