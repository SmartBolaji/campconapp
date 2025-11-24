import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class BackblazeService {
  final String keyId;
  final String applicationKey;
  final String bucketId;
  final String bucketName;

  BackblazeService({
    required this.keyId,
    required this.applicationKey,
    required this.bucketId,
    required this.bucketName,
  });

  // Update your settings to be more adaptive
  final int baseQuality = 50;
  final int maxWidth = 1000;
  final int maxHeight = 1000;
  final int maxFileSize = 250 * 1024;

  final int smallFileThreshold = 100 * 1024;
  final int mediumFileThreshold = 175 * 1024;
  final int largeFileThreshold = 250 * 1024;

  // Authorize with Backblaze
  Future<Map<String, String>> authorizeAccount() async {
    final String credentials =
        base64Encode(utf8.encode('$keyId:$applicationKey'));
    final response = await http.get(
      Uri.parse('https://api.backblazeb2.com/b2api/v2/b2_authorize_account'),
      headers: {'Authorization': 'Basic $credentials'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'apiUrl': data['apiUrl'],
        'authorizationToken': data['authorizationToken'],
      };
    } else {
      throw Exception('Failed to authorize account: ${response.body}');
    }
  }

  // Upload Image
  Future<String> uploadFile(File file) async {
    final auth = await authorizeAccount();
    final uploadUrlResponse = await http.post(
      Uri.parse('${auth['apiUrl']}/b2api/v2/b2_get_upload_url'),
      headers: {
        'Authorization': auth['authorizationToken']!,
      },
      body: jsonEncode({'bucketId': bucketId}),
    );

    if (uploadUrlResponse.statusCode == 200) {
      final uploadData = jsonDecode(uploadUrlResponse.body);
      final uploadUrl = uploadData['uploadUrl'];
      final uploadAuthToken = uploadData['authorizationToken'];

      // 🔹 Get sanitized filename
      String sanitizedFileName = _sanitizeFileName(file.uri.pathSegments.last);

      final uploadResponse = await http.post(
        Uri.parse(uploadUrl),
        headers: {
          'Authorization': uploadAuthToken!,
          'X-Bz-File-Name': Uri.encodeComponent(sanitizedFileName),
          'Content-Type': 'b2/x-auto',
          'X-Bz-Content-Sha1': 'do_not_verify',
        },
        body: file.readAsBytesSync(),
      );

      if (uploadResponse.statusCode == 200) {
        final fileData = jsonDecode(uploadResponse.body);
        return '${auth['apiUrl']}/file/$bucketName/${fileData['fileName']}';
      } else {
        throw Exception('File upload failed: ${uploadResponse.body}');
      }
    } else {
      throw Exception('Failed to get upload URL: ${uploadUrlResponse.body}');
    }
  }

  // 🔹 Sanitize filename (Remove spaces, special characters)
  String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(
            RegExp(r'[^\w.-]'), '_') // Replace special characters with "_"
        .toLowerCase(); // Convert to lowercase for consistency
  }

  // Make compress method public
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

  // More adaptive quality algorithm - determines appropriate quality setting
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
}
