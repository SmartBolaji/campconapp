import 'dart:io';
import 'package:campcon/services/backblaze.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

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

  List<AssetPathEntity> _albums = [];
  List<AssetEntity> _mediaList = [];
  List<AssetEntity> _selectedMedia = [];
  AssetPathEntity? _selectedAlbum;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
  }

  Future<void> _fetchAlbums() async {
    final permission = await PhotoManager.requestPermissionExtend();

    if (permission.isAuth) {
      try {
        final albums = await PhotoManager.getAssetPathList();
        setState(() {
          _albums = albums;
          _selectedAlbum = albums.isNotEmpty ? albums.first : null;
        });
        if (_selectedAlbum != null) {
          await _fetchMediaFromAlbum(_selectedAlbum!);
        }
      } catch (e) {
        print("Error fetching albums: $e");
      }
    } else {
      print("Permission denied. Open settings to grant access.");
      openAppSettings();
    }
  }

  Future<void> _fetchMediaFromAlbum(AssetPathEntity album) async {
    setState(() => _isLoading = true);
    try {
      final media = await album.getAssetListPaged(page: 0, size: 100);

      // Filter out only images
      final images =
          media.where((asset) => asset.type == AssetType.image).toList();

      // Sort media by date (most recent first)
      media.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

      setState(() {
        _mediaList = images;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching media: $e");
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
    if (_selectedMedia.isEmpty) {
      print("No media selected for upload.");
      return;
    }

    for (final asset in _selectedMedia) {
      final file = await asset.file;
      if (file != null) {
        try {
          print("Uploading ${file.path}...");
          final downloadUrl = await backblazeService.uploadFile(file);
          await firestore.collection('waitlist').add({
            'url': downloadUrl,
            'uploadedAt': FieldValue.serverTimestamp(),
          });
          print('Uploaded: $downloadUrl');
        } catch (e) {
          print('Error uploading: $e');
        }
      } else {
        print("Failed to get file for asset: $asset");
      }
    }
    setState(() {
      _selectedMedia.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Images uploaded successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        surfaceTintColor: Colors.grey.shade100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Transform.scale(
            scale: 0.80,
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: Icon(
                Icons.close,
                color: Colors.grey.shade800,
                size: 30,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            if (_albums.isNotEmpty)
              Expanded(
                child: DropdownButton<AssetPathEntity>(
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lato',
                    // fontWeight: FontWeight.w600,
                  ),
                  menuWidth: 200,
                  isExpanded: true,
                  value: _selectedAlbum,
                  items: _albums
                      .map((album) => DropdownMenuItem(
                            value: album,
                            child: Text(
                              album.name,
                              overflow:
                                  TextOverflow.ellipsis, // Avoids text overflow
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: album.name == _selectedAlbum!.name
                                    ? 19
                                    : 17,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lato',
                                // fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedAlbum = value);
                      _fetchMediaFromAlbum(value);
                    }
                  },
                ),
              ),
            const SizedBox(
              width: 70,
            )
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () =>
                  _selectedMedia.isNotEmpty ? _uploadSelectedImages : null,
              child: Text(
                _selectedMedia.isEmpty
                    ? 'Done'
                    : 'Add ${_selectedMedia.length}',
                style: TextStyle(
                  color: _selectedMedia.isNotEmpty
                      ? Colors.grey.shade800
                      : Colors.grey.shade800.withOpacity(0.5),
                  fontFamily: 'Lato',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: _mediaList.length,
                    itemBuilder: (context, index) {
                      final asset = _mediaList[index];
                      return FutureBuilder<File?>(
                        future: asset.file,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
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
                                      child: const Icon(Icons.check_circle,
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
          ),
        ],
      ),
    );
  }
}
