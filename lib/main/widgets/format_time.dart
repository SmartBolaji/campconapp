// Add this function to your _CommentsBottomSheetState class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatTimestamp(Timestamp timestamp) {
  final now = DateTime.now();
  final date = timestamp.toDate();
  final difference = now.difference(date);

  // Less than 1 hour: show minutes (e.g., 1m, 5m, 59m)
  if (difference.inHours < 1) {
    return '${difference.inMinutes}m';
  }

  // Less than 24 hours: show hours (e.g., 1h, 5h, 23h)
  if (difference.inHours < 24) {
    return '${difference.inHours}h';
  }

  // Less than 7 days: show days (e.g., 1d, 5d)
  if (difference.inDays < 7) {
    return '${difference.inDays}d';
  }

  // Same year: show MM-DD format
  if (date.year == now.year) {
    return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Different year: show MM-DD-YY format
  return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}-${(date.year % 100).toString().padLeft(2, '0')}';
}

String formatDateTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  // Less than 1 hour: show minutes (e.g., 1m, 5m, 59m)
  if (difference.inHours < 1) {
    return '${difference.inMinutes}m';
  }

  // Less than 24 hours: show hours (e.g., 1h, 5h, 23h)
  if (difference.inHours < 24) {
    return '${difference.inHours}h';
  }

  // Less than 7 days: show days (e.g., 1d, 5d)
  if (difference.inDays < 7) {
    return '${difference.inDays}d';
  }

  // Same year: show MM-DD format
  if (dateTime.year == now.year) {
    return '${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  // Different year: show MM-DD-YY format
  return '${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}-${(dateTime.year % 100).toString().padLeft(2, '0')}';
}

String formatEscrowTimestamp(dynamic timestamp) {
  if (timestamp == null) return '-';

  DateTime dateTime;

  if (timestamp is Timestamp) {
    dateTime = timestamp.toDate().toLocal();
  } else if (timestamp is DateTime) {
    dateTime = timestamp.toLocal();
  } else {
    return '-'; // not a valid timestamp
  }

  return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
}

String truncateText(String text, {int maxLength = 15}) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}...';
}
