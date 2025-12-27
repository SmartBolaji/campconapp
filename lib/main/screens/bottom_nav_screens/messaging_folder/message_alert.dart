import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EscrowAlertSheet {
  static void show(BuildContext context, VoidCallback onContinue) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EscrowAlertWidget(onContinue: onContinue),
    );
  }

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    final disabled = prefs.getBool('escrow_alert_disabled');
    return !(disabled ?? false);
  }

  // Add this method to allow disabling from floating alert
  static Future<void> disableAlert() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('escrow_alert_disabled', true);
  }
}

class EscrowAlertWidget extends StatefulWidget {
  final VoidCallback onContinue;

  const EscrowAlertWidget({
    Key? key,
    required this.onContinue,
  }) : super(key: key);

  @override
  State<EscrowAlertWidget> createState() => _EscrowAlertWidgetState();
}

class _EscrowAlertWidgetState extends State<EscrowAlertWidget> {
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            // Center(
            //   child: Container(
            //     width: 40,
            //     height: 4,
            //     decoration: BoxDecoration(
            //       color: Colors.grey.shade300,
            //       borderRadius: BorderRadius.circular(2),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 14),

            // Header
            const Row(
              children: [
                // Container(
                //   padding: const EdgeInsets.all(12),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFFa62c71).withValues(alpha: 0.1),
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: const Icon(
                //     FeatherIcons.shield,
                //     color: Color(0xFFa62c71),
                //     size: 24,
                //   ),
                // ),
                // const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Shop Safely with Escrow Protection',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Nexa Bold',
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Safety tips
            _buildSafetyTip(
              icon: FeatherIcons.lock,
              title: 'Use Escrow Services',
              subtitle:
                  'For high-value items, consider using our escrow service to protect your payment until you receive the item as described.',
              color: const Color(0xFF27AE60),
            ),

            const SizedBox(height: 24),

            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFa62c71).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFa62c71).withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    FeatherIcons.info,
                    color: Color(0xFFa62c71),
                    size: 16,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'DressFli connects you with amazing sellers, but we encourage you to make informed choices. Your safety is our priority!',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Nexa Light',
                        color: Color(0xFFa62c71),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Don't show again checkbox
            Row(
              children: [
                Checkbox(
                  value: _dontShowAgain,
                  onChanged: (value) {
                    setState(() {
                      _dontShowAgain = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFFa62c71),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Don't show this again",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Nexa Light',
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFa62c71)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Nexa Bold',
                        color: Color(0xFFa62c71),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_dontShowAgain) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('escrow_alert_disabled', true);
                      }
                      Navigator.pop(context);
                      widget.onContinue();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFa62c71),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(
                        fontFamily: 'Nexa Bold',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTip({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Nexa Bold',
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Nexa Light',
                  color: Colors.grey.shade700,
                  // fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
