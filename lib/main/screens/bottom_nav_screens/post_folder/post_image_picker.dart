import 'dart:typed_data';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/provider/media_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'dart:io';

class PostImagePicker extends StatefulWidget {
  const PostImagePicker({super.key});

  @override
  State<PostImagePicker> createState() => _PostImagePickerState();
}

class _PostImagePickerState extends State<PostImagePicker> {
  final Map<String, File> _cachedFiles = {};
  final Map<String, Uint8List> _cachedThumbnails = {};
  List<AssetPathEntity> _albums = [];
  List<AssetEntity> _mediaList = [];
  AssetPathEntity? _selectedAlbum;
  bool _isLoading = true;
  final int _pageSize = 50;
  bool _hasMoreToLoad = true;
  int _currentPage = 0;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
  }

  @override
  void dispose() {
    _cachedFiles.clear();
    _cachedThumbnails.clear();
    super.dispose();
  }

  /// Check if device is running Android 13 or higher (API 33+)
  Future<bool> _isAndroid13OrNewer() async {
    if (!Platform.isAndroid) return false;
    try {
      const channel = MethodChannel('com.campcon.app/android_version');
      final int sdkInt = await channel.invokeMethod('getSdkVersion') ?? 0;
      return sdkInt >= 33;
    } catch (e) {
      debugPrint("Error checking Android version: $e");
      // Fallback to checking via image_picker (it handles Android 13+ Photo Picker)
      return true; // Assume Android 13+ for fallback
    }
  }

  /// Use native Android Photo Picker (privacy-friendly, Android 13+)
  Future<void> _pickImagesWithNativePicker() async {
    try {
      final mediaProvider =
          Provider.of<MediaSelectionProvider>(context, listen: false);

      // Check remaining slots
      final remainingSlots = 10 -
          (mediaProvider.selectedImages.length +
              mediaProvider.capturedImages.length);

      if (remainingSlots <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 10 images allowed'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
        return;
      }

      // Use image_picker with multi-image mode
      // On Android 13+, this triggers the native Photo Picker dialog
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
        requestFullMetadata: false,
      );

      if (pickedFiles.isEmpty || !mounted) return;

      // Convert XFile to File objects
      final files = pickedFiles
          .map((xFile) => File(xFile.path))
          .take(remainingSlots)
          .toList();

      // Add to media provider
      await mediaProvider.addMultipleFiles(files);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Added ${files.length} image${files.length > 1 ? 's' : ''}'),
            backgroundColor: AppTheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error picking images with native picker: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick images'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _fetchAlbums() async {
    final permission = await PhotoManager.requestPermissionExtend();

    if (permission.isAuth) {
      try {
        final albums = await PhotoManager.getAssetPathList();
        if (mounted) {
          setState(() {
            _albums = albums;
            _selectedAlbum = albums.isNotEmpty ? albums.first : null;
          });
          if (_selectedAlbum != null) {
            _resetAndFetchMedia();
          }
        }
      } catch (e) {
        debugPrint("Error fetching albums: $e");
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      debugPrint("Permission denied. Open settings to grant access.");
      await openAppSettings();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Reset and start fresh when album changes
  void _resetAndFetchMedia() {
    setState(() {
      _isLoading = true;
      _mediaList = [];
      _currentPage = 0;
      _hasMoreToLoad = true;
      _cachedThumbnails.clear();
    });
    _fetchNextPage();
  }

  // Load media one page at a time
  Future<void> _fetchNextPage() async {
    if (!_hasMoreToLoad || _selectedAlbum == null) return;

    setState(() => _isLoading = true);

    try {
      final media = await _selectedAlbum!.getAssetListPaged(
        page: _currentPage,
        size: _pageSize,
      );

      if (media.isEmpty) {
        if (mounted) {
          setState(() {
            _hasMoreToLoad = false;
            _isLoading = false;
          });
        }
        return;
      }

      // Filter for images only and sort
      final images =
          media.where((asset) => asset.type == AssetType.image).toList();
      images.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

      if (images.isEmpty) {
        if (mounted) {
          setState(() {
            _currentPage++;
            _isLoading = false;
          });
        }
        return;
      }

      // Pre-load thumbnails only, not full files
      for (var asset in images) {
        _loadThumbnail(asset);
      }

      // Update state with new data
      if (mounted) {
        setState(() {
          _mediaList = [..._mediaList, ...images];
          _currentPage++;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching media: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Load thumbnails instead of full files
  Future<void> _loadThumbnail(AssetEntity asset) async {
    if (_cachedThumbnails.containsKey(asset.id)) return;

    try {
      // Use a small thumbnail size to conserve memory
      final thumbnail = await asset.thumbnailDataWithSize(
        const ThumbnailSize(200, 200),
        quality: 80,
      );

      if (thumbnail != null && mounted) {
        setState(() {
          _cachedThumbnails[asset.id] = thumbnail;
        });
      }
    } catch (e) {
      debugPrint("Error loading thumbnail: $e");
    }
  }

  // Only load full file when needed (for selected images)
  Future<File?> _loadFullFile(AssetEntity asset) async {
    if (_cachedFiles.containsKey(asset.id)) {
      return _cachedFiles[asset.id];
    }

    try {
      final file = await asset.file;
      if (file != null) {
        _cachedFiles[asset.id] = file;
        return file;
      }
    } catch (e) {
      debugPrint("Error loading full file: $e");
    }
    return null;
  }

  void _toggleSelection(BuildContext context, AssetEntity asset) async {
    final imageProvider =
        Provider.of<MediaSelectionProvider>(context, listen: false);

    // Load full file only when selected
    if (!imageProvider.isSelected(asset)) {
      final file = await _loadFullFile(asset);
      if (file == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load image'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
        return;
      }
    }

    imageProvider.toggleSelection(asset);
  }

  Future<void> _takePhoto() async {
    try {
      final cameraStatus = await Permission.camera.request();

      if (!cameraStatus.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
        return;
      }

      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (photo != null && mounted) {
        final mediaProvider =
            Provider.of<MediaSelectionProvider>(context, listen: false);

        if (mediaProvider.selectedImages.length +
                mediaProvider.capturedImages.length >=
            10) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 10 images allowed'),
              backgroundColor: AppTheme.error,
            ),
          );
          return;
        }

        final file = File(photo.path);
        await mediaProvider.addCapturedImage(file);

        debugPrint('📸 Photo captured and added to selection');
      }
    } catch (e) {
      debugPrint('❌ Error taking photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to take photo'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add scroll controller to detect when to load more
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 500 &&
          !_isLoading &&
          _hasMoreToLoad) {
        _fetchNextPage();
      }
    });

    final mediaProvider = Provider.of<MediaSelectionProvider>(context);

    if (_mediaList.isEmpty && _isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primary),
            SizedBox(height: 16.h),
            Text(
              'Loading images...',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    if (_mediaList.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FeatherIcons.image,
              size: 48.sp,
              color: AppTheme.textLight,
            ),
            SizedBox(height: 16.h),
            Text(
              'No images found',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Quick Pick Button (Native Photo Picker for Android 13+)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                FeatherIcons.zap,
                size: 18.sp,
                color: AppTheme.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: GestureDetector(
                  onTap: _pickImagesWithNativePicker,
                  child: Text(
                    'Quick Pick',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Album Dropdown
        if (_albums.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Icon(
                //   FeatherIcons.chevronDown,
                //   size: 18.sp,
                //   color: AppTheme.textSecondary,
                // ),
                // SizedBox(width: 8.w),
                Expanded(
                  child: DropdownButton<AssetPathEntity>(
                    underline: const SizedBox(),
                    icon: Icon(
                      FeatherIcons.chevronDown,
                      size: 18.sp,
                      color: AppTheme.textSecondary,
                    ),
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nexa Bold',
                    ),
                    dropdownColor: AppTheme.surface,
                    menuMaxHeight: 400.h,
                    borderRadius: BorderRadius.circular(12.r),
                    isExpanded: true,
                    value: _selectedAlbum,
                    items: _albums
                        .map((album) => DropdownMenuItem(
                              value: album,
                              child: Text(
                                album.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: album.name == _selectedAlbum?.name
                                      ? 14.sp
                                      : 13.sp,
                                  fontWeight: album.name == _selectedAlbum?.name
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontFamily: 'Nexa Bold',
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null && value != _selectedAlbum) {
                        setState(() => _selectedAlbum = value);
                        _resetAndFetchMedia();
                      }
                    },
                  ),
                ),
                // Text(
                //   '${_mediaList.length}',
                //   style: TextStyle(
                //     color: AppTheme.textLight,
                //     fontSize: 12.sp,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
              ],
            ),
          ),

        // Image grid with camera button
        Expanded(
          child: GridView.builder(
            controller: scrollController,
            padding: EdgeInsets.all(2.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 2.w,
            ),
            itemCount: _mediaList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCameraButton();
              }

              final mediaIndex = index - 1;
              if (mediaIndex >= _mediaList.length) {
                return const SizedBox();
              }

              final asset = _mediaList[mediaIndex];
              final hasThumbnail = _cachedThumbnails.containsKey(asset.id);
              final isSelected = mediaProvider.isSelected(asset);

              return GestureDetector(
                onTap: () => _toggleSelection(context, asset),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    hasThumbnail
                        ? Image.memory(
                            _cachedThumbnails[asset.id]!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: AppTheme.border),
                          )
                        : Container(color: AppTheme.border),
                    if (isSelected)
                      Container(
                        color: AppTheme.primary.withValues(alpha: 0.5),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${mediaProvider.selectedImages.indexOf(asset) + 1 + mediaProvider.capturedImages.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),

        // Loading indicator at bottom
        if (_isLoading && _mediaList.isNotEmpty && _hasMoreToLoad)
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primary,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Loading more...',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCameraButton() {
    return GestureDetector(
      onTap: _takePhoto,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.buttonBorder,
          border: Border.all(
            color: AppTheme.border,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FeatherIcons.camera,
              size: 32.sp,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
