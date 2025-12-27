import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/services/cache.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class MessageImageView extends StatelessWidget {
  final String imageUrl;

  const MessageImageView({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onSelected: (value) async {
              if (value == 'save') {
                await _saveImage(context);
              } else if (value == 'share') {
                await _shareImage(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.download_outlined),
                    SizedBox(width: 8),
                    Text(
                      'Save to device',
                      style: TextStyle(
                        fontFamily: 'Nexa Light',
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined),
                    SizedBox(width: 8),
                    Text('Share image',
                        style: TextStyle(
                          fontFamily: 'Nexa Light',
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: PhotoView(
        imageProvider: CachedNetworkImageProvider(
          imageUrl,
          cacheManager: CustomCacheManager(),
        ),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
          ),
        ),
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading message image: $error');
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.broken_image_rounded,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'Image failed to load\nTap to retry',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Update the permission handling and save process
  Future<void> _saveImage(BuildContext context) async {
    try {
      // For Android 13+, we need to request specific permissions
      if (Platform.isAndroid) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.storage,
        ].request();

        bool allGranted = true;
        statuses.forEach((permission, status) {
          if (!status.isGranted) {
            allGranted = false;
          }
        });

        if (!allGranted) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                title: const Text(
                  'Permission Required',
                  style: TextStyle(
                    fontFamily: 'Nexa Bold',
                    color: Color(0xFFa62c71),
                  ),
                ),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To save images, please allow Dressfli to access:',
                      style: TextStyle(fontFamily: 'Nexa Light'),
                    ),
                    SizedBox(height: 8),
                    Text('• Photos and media', // Use bullet points for clarity
                        style: TextStyle(fontFamily: 'Nexa Light')),
                    Text('• Files and media', // Use bullet points for clarity
                        style: TextStyle(fontFamily: 'Nexa Light')),
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
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await openAppSettings();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFa62c71),
                    ),
                    child: const Text(
                      'Open Settings',
                      style: TextStyle(fontFamily: 'Nexa Bold'),
                    ),
                  ),
                ],
              ),
            );
          }
          return;
        }
      }

      // Show loading indicator
      showFloatingSnackBar(
        context,
        'Saving image...',
      );

      // Get the image
      final response = await http.get(Uri.parse(imageUrl));

      // Save location depends on platform
      String path;

      if (Platform.isAndroid) {
        // Try to use the Pictures directory for better visibility
        Directory? directory;

        try {
          // First try to save to Pictures/Dressfli
          directory = Directory('/storage/emulated/0/Pictures/Dressfli');
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
        } catch (e) {
          // Fallback to app's external directory
          final documentsDir = await getExternalStorageDirectory();
          if (documentsDir == null) {
            throw Exception('Could not access storage directory');
          }
          directory = Directory('${documentsDir.path}/dressfli_images');
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        path = '${directory.path}/dressfli_$timestamp.jpg';
      } else {
        // For iOS, save to temp directory first (then will use Share to save to Photos)
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        path = '${tempDir.path}/dressfli_$timestamp.jpg';
      }

      // Write to file
      final file = File(path);
      await file.writeAsBytes(response.bodyBytes);

      // Show success message
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          'Image saved to ${Platform.isAndroid ? "Pictures/Dressfli" : "Photos"}',
        );

        // For iOS, we need an extra step to save to Photos
        if (Platform.isIOS) {
          // You'll need image_gallery_saver package for this
          // Or use Share.shareFiles to let user save it
          await Share.shareXFiles(
            [XFile(path)],
            subject: 'Save this image',
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving image: $e');
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          'Failed to save image: ${e.toString()}',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Future<void> _shareImage(BuildContext context) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preparing to share...')),
      );

      // Get the image
      final response = await http.get(Uri.parse(imageUrl));

      // Get temp directory
      final tempDir = await getTemporaryDirectory();

      // Generate a filename based on current timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${tempDir.path}/dressfli_$timestamp.jpg';

      // Write to file
      final file = File(path);
      await file.writeAsBytes(response.bodyBytes);

      // Share the file using the latest API
      final result = await Share.shareXFiles(
        [XFile(path)],
        subject: 'Shared from Dressfli',
        text: 'Check out this image from Dressfli!',
      );

      // Optional: Log share result
      debugPrint('Share result: ${result.status}');
    } catch (e) {
      debugPrint('Error sharing image: $e');
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          'Failed to share image: ${e.toString()}',
          backgroundColor: Colors.red,
        );
      }
    }
  }
}
