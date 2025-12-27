import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageOptions {
  // Show the message options bottom sheet
  static void showOptions(
    BuildContext context, {
    required String currentUserId,
    required String otherUserId,
    required String otherUserName,
    VoidCallback? onBlock,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildOptionsSheet(
        context,
        currentUserId: currentUserId,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        onBlock: onBlock,
      ),
    );
  }

  // Build the options sheet
  static Widget _buildOptionsSheet(
    BuildContext context, {
    required String currentUserId,
    required String otherUserId,
    required String otherUserName,
    VoidCallback? onBlock,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'Chat options',
                style: TextStyle(
                  fontFamily: 'Nexa Bold',
                  fontSize: 18,
                ),
              ),
            ),

            // Options list with styled containers
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  // Block user option
                  _buildOptionTile(
                    context,
                    icon: Icons.block_rounded,
                    title: 'Block',
                    subtitle: 'Stop receiving messages from this user',
                    onTap: () => _confirmBlockUser(
                      context,
                      currentUserId,
                      otherUserId,
                      otherUserName,
                      onBlock,
                    ),
                  ),

                  Divider(height: 1, color: Colors.grey.shade200),

                  // Report user option
                  _buildOptionTile(
                    context,
                    icon: Icons.flag_rounded,
                    title: 'Report',
                    subtitle: 'Report inappropriate behavior',
                    onTap: () => _showReportOptions(
                      context,
                      currentUserId,
                      otherUserId,
                      otherUserName,
                    ),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build individual option tile
  static Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withValues(alpha: 0.1)
                    : const Color(0xFFa62c71).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : const Color(0xFFa62c71),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Nexa Bold',
                      fontSize: 16,
                      color: isDestructive ? Colors.red : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Nexa Light',
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Confirm block user dialog
  static void _confirmBlockUser(
    BuildContext context,
    String currentUserId,
    String otherUserId,
    String otherUserName,
    VoidCallback? onBlock,
  ) {
    Navigator.pop(context); // Close the options sheet

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Block',
          style: TextStyle(
            fontFamily: 'Nexa Bold',
            fontSize: 18,
            color: Color(0xFFa62c71),
          ),
        ),
        content: RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Nexa Light',
              fontSize: 15,
              color: Colors.grey.shade800,
            ),
            children: [
              const TextSpan(text: 'Are you sure you want to block '),
              TextSpan(
                text: otherUserName,
                style: const TextStyle(fontFamily: 'Nexa Bold'),
              ),
              const TextSpan(
                text:
                    '? \n\nYou won\'t receive messages from them and they won\'t be able to message you.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontFamily: 'Nexa Light',
                fontSize: 15,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _blockUser(context, currentUserId, otherUserId);
              if (onBlock != null) {
                onBlock();
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text(
              'Block',
              style: TextStyle(
                fontFamily: 'Nexa Bold',
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Implement block user functionality
  static Future<void> _blockUser(
    BuildContext context,
    String currentUserId,
    String blockedUserId,
  ) async {
    try {
      // 1. Add to blocked users collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('blocked_users')
          .doc(blockedUserId)
          .set({
        'userId': blockedUserId,
        'blockedAt': FieldValue.serverTimestamp(),
      });

      // 2. Also update user document to indicate they have blocked users
      // This helps with querying in other parts of the app
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'hasBlockedUsers': true,
      });

      // 3. Show success message
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          'User blocked successfully',
        );
      }
    } catch (e) {
      debugPrint('Error blocking user: $e');
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          'Failed to block user. Please try again.',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  // Show report options
  static void _showReportOptions(
    BuildContext context,
    String currentUserId,
    String reportedUserId,
    String reportedUserName,
  ) {
    Navigator.pop(context); // Close the options sheet

    final reportReasons = [
      'Inappropriate content',
      'Harassment or bullying',
      'Scam or fraud',
      'Impersonation',
      'Fake account',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      elevation: 8,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding:
            const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Report',
                  style: TextStyle(
                    fontFamily: 'Nexa Bold',
                    fontSize: 18,
                  ),
                ),
              ),

              // Subtitle
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'Select a reason for reporting $reportedUserName',
                  style: TextStyle(
                    fontFamily: 'Nexa Light',
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Report reasons list
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reportReasons.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    final reason = reportReasons[index];
                    return ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        _showReportConfirmation(
                          context,
                          currentUserId,
                          reportedUserId,
                          reportedUserName,
                          reason,
                        );
                      },
                      title: Text(
                        reason,
                        style: const TextStyle(
                          fontFamily: 'Nexa Light',
                          fontSize: 16,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show report confirmation dialog
  static void _showReportConfirmation(
    BuildContext context,
    String currentUserId,
    String reportedUserId,
    String reportedUserName,
    String reason,
  ) {
    TextEditingController additionalInfoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Additional Information',
          style: TextStyle(
            fontFamily: 'Nexa Bold',
            fontSize: 18,
            color: Color(0xFFa62c71),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide any additional details about this report:',
              style: TextStyle(
                fontFamily: 'Nexa Light',
                fontSize: 15,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: additionalInfoController,
              decoration: InputDecoration(
                hintText: 'Optional',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontFamily: 'Nexa Light',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFFa62c71), width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(
                fontFamily: 'Nexa Light',
                fontSize: 15,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontFamily: 'Nexa Light',
                fontSize: 15,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitReport(
                context,
                currentUserId,
                reportedUserId,
                reason,
                additionalInfoController.text,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFa62c71),
            ),
            child: const Text(
              'Submit Report',
              style: TextStyle(
                fontFamily: 'Nexa Bold',
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Submit the report to Firestore
  static Future<void> _submitReport(
    BuildContext context,
    String reporterId,
    String reportedUserId,
    String reason,
    String additionalInfo,
  ) async {
    try {
      // Create a new report document
      await FirebaseFirestore.instance.collection('reports').add({
        'reporterId': reporterId,
        'reportedUserId': reportedUserId,
        'reason': reason,
        'additionalInfo': additionalInfo,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, reviewed, closed
      });

      // Show success message
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          'Report submitted successfully. Our team will review it.',
        );
      }
    } catch (e) {
      debugPrint('Error submitting report: $e');
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          'Failed to submit report. Please try again.',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  // Check if a user is blocked
  static Future<bool> isUserBlocked(
      String currentUserId, String otherUserId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('blocked_users')
          .doc(otherUserId)
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint('Error checking if user is blocked: $e');
      return false;
    }
  }

  // Unblock user
  static Future<void> unblockUser(
    BuildContext context,
    String currentUserId,
    String blockedUserId,
  ) async {
    try {
      // Remove from blocked users collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('blocked_users')
          .doc(blockedUserId)
          .delete();

      // Check if there are any remaining blocked users
      QuerySnapshot remainingBlocked = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('blocked_users')
          .limit(1)
          .get();

      // Update the hasBlockedUsers flag if no blocked users remain
      if (remainingBlocked.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .update({
          'hasBlockedUsers': false,
        });
      }

      // Show success message
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          'User unblocked successfully',
        );
      }
    } catch (e) {
      debugPrint('Error unblocking user: $e');
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          'Failed to unblock user. Please try again.',
          backgroundColor: Colors.red,
        );
      }
    }
  }
}
