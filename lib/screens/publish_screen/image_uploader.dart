import 'dart:io';
import 'package:campcon/services/backblaze.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploader extends StatefulWidget {
  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  final firestore = FirebaseFirestore.instance;

  final backblazeService = BackblazeService(
    keyId: dotenv.env['KEY_ID']!,
    applicationKey: dotenv.env['APPLICATION_KEY']!,
    bucketId: dotenv.env['BUCKET_ID']!,
    bucketName: dotenv.env['BUCKET_NAME']!,
  );

  Future<void> uploadImages() async {
    try {
      for (var file in _selectedImages) {
        final downloadUrl = await backblazeService.uploadFile(file);
        await firestore.collection('waitlist').add({
          'url': downloadUrl,
          'uploadedAt': FieldValue.serverTimestamp(),
        });
      }
      print('Images uploaded successfully');
      setState(() {
        _selectedImages.clear();
      });
    } catch (e) {
      print('Error uploading images: $e');
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Images')),
      body: Column(
        children: [
          Expanded(
            child: _selectedImages.isNotEmpty
                ? GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            _selectedImages[index],
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : Center(
                    child: Text('No images selected'),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _pickImages,
                  child: Text('Select Images'),
                ),
                ElevatedButton(
                  onPressed: _selectedImages.isNotEmpty ? uploadImages : null,
                  child: Text('Upload Images'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
