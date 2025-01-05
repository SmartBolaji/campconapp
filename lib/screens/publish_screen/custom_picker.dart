import 'dart:io';
import 'package:campcon/services/backblaze.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomImagePicker extends StatefulWidget {
  @override
  _CustomImagePickerState createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  final firestore = FirebaseFirestore.instance;
  final backblazeService = BackblazeService(
    keyId: dotenv.env['KEY_ID']!,
    applicationKey: dotenv.env['APPLICATION_KEY']!,
    bucketId: dotenv.env['BUCKET_ID']!,
    bucketName: dotenv.env['BUCKET_NAME']!,
  );

  List<AssetEntity> _mediaList = [];
  List<AssetEntity> _selectedMedia = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Check permissions and request them if necessary
    if (Platform.isAndroid) {
      PermissionStatus storageStatus = await Permission.storage.request();
      PermissionStatus cameraStatus = await Permission.camera.request();
      PermissionStatus manageExternalStorageStatus =
          await Permission.manageExternalStorage.request();

      // Log the permission statuses for debugging
      print("Storage Permission: ${storageStatus.isGranted}");
      print("Camera Permission: ${cameraStatus.isGranted}");
      print(
          "Manage External Storage Permission: ${manageExternalStorageStatus.isGranted}");

      // If permissions are denied, show a message
      if (storageStatus.isDenied || cameraStatus.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage or Camera permission denied')),
        );
        return;
      }

      if (manageExternalStorageStatus.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Permission for MANAGE_EXTERNAL_STORAGE denied')),
        );
        return;
      }

      // Proceed with other actions if permissions are granted
      _fetchGalleryMedia();
    }
  }

  Future<void> _fetchGalleryMedia() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      final albums = await PhotoManager.getAssetPathList(onlyAll: true);
      final media = await albums.first.getAssetListPaged(page: 1, size: 100);
      setState(() {
        _mediaList = media;
        _isLoading = false;
      });
    } else {
      PhotoManager.openSetting();
    }
  }

  void _toggleSelection(AssetEntity asset) {
    setState(() {
      if (_selectedMedia.contains(asset)) {
        _selectedMedia.remove(asset);
      } else {
        _selectedMedia.add(asset);
      }
    });
  }

  Future<void> _uploadSelectedImages() async {
    for (final asset in _selectedMedia) {
      final file = await asset.file;
      if (file != null) {
        try {
          final downloadUrl = await backblazeService.uploadFile(file);
          await firestore.collection('waitlist').add({
            'url': downloadUrl,
            'uploadedAt': FieldValue.serverTimestamp(),
          });
          print('Uploaded: $downloadUrl');
        } catch (e) {
          print('Error uploading: $e');
        }
      }
    }
    setState(() {
      _selectedMedia.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Images uploaded successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select and Upload Images'),
        actions: [
          IconButton(
            icon: Icon(Icons.cloud_upload),
            onPressed: _selectedMedia.isNotEmpty ? _uploadSelectedImages : null,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _mediaList.length,
              itemBuilder: (context, index) {
                final asset = _mediaList[index];
                return FutureBuilder<File?>(
                  future: asset.file,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.data != null) {
                      final file = snapshot.data!;
                      final isSelected = _selectedMedia.contains(asset);
                      return GestureDetector(
                        onTap: () => _toggleSelection(asset),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(file, fit: BoxFit.cover),
                            if (isSelected)
                              Container(
                                color: Colors.black.withOpacity(0.5),
                                child: Icon(Icons.check_circle,
                                    color: Colors.white, size: 30),
                              ),
                          ],
                        ),
                      );
                    }
                    return Container(color: Colors.grey);
                  },
                );
              },
            ),
    );
  }
}
