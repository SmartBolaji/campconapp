import 'dart:typed_data';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/provider/media_provider.dart';
import 'package:flutter/material.dart';
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
            SnackBar(
              content: const Text('Failed to load image'),
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
            SnackBar(
              content: const Text('Camera permission is required'),
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
            SnackBar(
              content: const Text('Maximum 10 images allowed'),
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
          SnackBar(
            content: const Text('Failed to take photo'),
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
        // Selected images preview
        if (mediaProvider.selectedImages.isNotEmpty ||
            mediaProvider.capturedImages.isNotEmpty)
          Container(
            height: 80.h,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.border,
                  width: 1,
                ),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mediaProvider.selectedImages.length +
                  mediaProvider.capturedImages.length,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              itemBuilder: (context, index) {
                if (index < mediaProvider.capturedImages.length) {
                  final file = mediaProvider.capturedImages[index];
                  return _buildSelectedImageTile(
                    index: index,
                    onRemove: () => mediaProvider.removeCapturedAt(index),
                    child: Image.file(
                      file,
                      fit: BoxFit.cover,
                      width: 70.w,
                      height: 70.h,
                    ),
                  );
                }

                final galleryIndex =
                    index - mediaProvider.capturedImages.length;
                final asset = mediaProvider.selectedImages[galleryIndex];
                final fileExists = _cachedFiles.containsKey(asset.id);
                final thumbnailExists = _cachedThumbnails.containsKey(asset.id);

                return _buildSelectedImageTile(
                  index: index,
                  onRemove: () => mediaProvider.removeAt(galleryIndex),
                  child: fileExists
                      ? Image.file(
                          _cachedFiles[asset.id]!,
                          fit: BoxFit.cover,
                          width: 70.w,
                          height: 70.h,
                        )
                      : thumbnailExists
                          ? Image.memory(
                              _cachedThumbnails[asset.id]!,
                              fit: BoxFit.cover,
                              width: 70.w,
                              height: 70.h,
                            )
                          : Container(
                              color: AppTheme.border,
                              width: 70.w,
                              height: 70.h,
                              child: Center(
                                child: SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ),
                );
              },
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
                Icon(
                  FeatherIcons.chevronDown,
                  size: 18.sp,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: DropdownButton<AssetPathEntity>(
                    underline: const SizedBox(),
                    icon: null,
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
                        color: AppTheme.primary.withOpacity(0.5),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
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

  Widget _buildSelectedImageTile({
    required int index,
    required VoidCallback onRemove,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      width: 70.w,
      height: 70.h,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: child,
          ),
          Positioned(
            top: 4.w,
            right: 4.w,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14.sp,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 4.w,
            left: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
