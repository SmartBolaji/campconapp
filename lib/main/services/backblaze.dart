import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class BackblazeService {
  // ── Singleton ───────────────────────────────────────────────
  static final BackblazeService _instance = BackblazeService._internal();
  factory BackblazeService() => _instance;
  static BackblazeService get instance => _instance;

  BackblazeService._internal();

  // ── Compression Settings ─────────────────────────────────────
  final int maxWidth = 1000;
  final int maxHeight = 1000;
  final int maxFileSize = 250 * 1024;

  final int smallFileThreshold = 100 * 1024;
  final int mediumFileThreshold = 175 * 1024;
  final int largeFileThreshold = 250 * 1024;

  /// Upload compressed image via Cloud Function (server-side upload)
  Future<String> uploadImageToCloud(File compressedFile) async {
    try {
      debugPrint('📤 Starting image upload to Cloud Function');

      // Read file as bytes
      final bytes = await compressedFile.readAsBytes();
      final base64Data = base64Encode(bytes);

      debugPrint('📦 Image size: ${(bytes.length / 1024).round()}KB');
      debugPrint('🔐 Converted to base64: ${base64Data.length} chars');

      // Get sanitized filename
      final fileName = _sanitizeFileName(compressedFile.uri.pathSegments.last);

      // Call Cloud Function with image data
      final callable = FirebaseFunctions.instance.httpsCallable('uploadImage');

      debugPrint('🚀 Calling uploadImage Cloud Function...');

      final result = await callable.call({
        'imageData': base64Data,
        'fileName': fileName,
        'contentType': 'image/webp',
      });

      final data = result.data as Map<String, dynamic>;

      if (data['success'] == true) {
        final url = data['url'] as String;
        debugPrint('✅ Image uploaded successfully');
        debugPrint('📎 URL: $url');
        return url;
      } else {
        throw Exception('Upload response indicated failure');
      }
    } catch (e) {
      debugPrint('❌ Error uploading image to Cloud Function: $e');
      rethrow;
    }
  }

  // 🔹 Sanitize filename (Remove spaces, special characters)
  String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(
            RegExp(r'[^\w.-]'), '_') // Replace special characters with "_"
        .toLowerCase(); // Convert to lowercase for consistency
  }

  // ── Image Compression ────────────────────────────────────────

  /// Compress image to WebP format with adaptive quality
  Future<File> compressImage(File file) async {
    try {
      final originalFileSize = await file.length();

      // Determine adaptive quality based on file size
      final int adaptiveQuality = getAdaptiveQuality(file, originalFileSize);

      // Create temp file path with unique name
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Always use WebP format for better compression
      final targetPath = path.join(
        dir.path,
        'compressed_${timestamp}.webp',
      );

      // Compress image - use WebP for all images
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: adaptiveQuality, // Use adaptive quality instead of fixed
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.webp, // Always use WebP for best compression
      );

      if (result == null) {
        throw Exception('Image compression failed');
      }

      final compressedFileSize = await result.length();
      final compressionRatio = (compressedFileSize / originalFileSize) * 100;

      debugPrint('Original size: ${(originalFileSize / 1024).round()}KB');
      debugPrint('Compressed size: ${(compressedFileSize / 1024).round()}KB');
      debugPrint('Compression ratio: ${compressionRatio.toStringAsFixed(2)}%');

      // Determine if second pass is needed based on image characteristics
      // Only apply aggressive second pass if:
      // 1. Compression ratio is still high (over 20%) AND
      // 2. File is larger than our threshold AND
      // 3. Not a high-detail image that needs quality preservation
      if (compressionRatio > 20 && compressedFileSize > largeFileThreshold) {
        debugPrint('Performing second-pass compression for better results');

        final secondTargetPath = path.join(
          dir.path,
          'compressed_2_${timestamp}.webp',
        );

        final secondResult = await FlutterImageCompress.compressAndGetFile(
          result.path,
          secondTargetPath,
          quality: 30, // More aggressive quality reduction
          minWidth: (maxWidth * 0.8).round(), // 20% smaller dimensions
          minHeight: (maxHeight * 0.8).round(),
          format: CompressFormat.webp,
        );

        if (secondResult != null) {
          // Delete first compressed result
          await File(result.path).delete();

          final secondCompressedSize = await secondResult.length();
          final secondRatio = (secondCompressedSize / originalFileSize) * 100;

          debugPrint(
              'Second-pass size: ${(secondCompressedSize / 1024).round()}KB');
          debugPrint(
              'Final compression ratio: ${secondRatio.toStringAsFixed(2)}%');

          // If second pass gives us a file under our threshold, use it
          if (secondCompressedSize <= maxFileSize) {
            return File(secondResult.path);
          } else {
            // Otherwise, if first pass was better quality and not huge, use that
            if (compressedFileSize <= maxFileSize * 1.2) {
              // Allow up to 20% over target
              await File(secondResult.path).delete();
              return File(result.path);
            }
            // If both are too large, go with the smaller one
            return File(secondResult.path);
          }
        }
      }

      return File(result.path);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      // Return original file if compression fails
      return file;
    }
  }

  /// More adaptive quality algorithm - determines appropriate quality setting
  int getAdaptiveQuality(File file, int originalSize) {
    // Check file extension for format-specific considerations
    final ext = path.extension(file.path).toLowerCase();
    final bool isPNG = ext == '.png';

    // PNG images with transparency need higher quality
    if (isPNG) {
      return 65; // Higher quality for PNGs to preserve details
    }

    // Size-based adaptive quality (similar to Pinterest's approach)
    if (originalSize > 5 * 1024 * 1024) return 35; // 5MB+ huge images
    if (originalSize > 3 * 1024 * 1024) return 40; // 3-5MB large images
    if (originalSize > 1 * 1024 * 1024) return 45; // 1-3MB medium images

    // For smaller files, preserve more quality
    return 55; // Default quality for smaller files
  }

  // Helper method to determine content type
  String getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      case '.heic':
        return 'image/heic';
      default:
        return 'b2/x-auto';
    }
  }
}
