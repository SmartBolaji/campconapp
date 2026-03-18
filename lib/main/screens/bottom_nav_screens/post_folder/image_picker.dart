import 'dart:io';
import 'dart:typed_data';
import 'package:campcon/main/provider/media_provider.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ProductImagePicker extends StatefulWidget {
  const ProductImagePicker({super.key});

  @override
  ProductImagePickerState createState() => ProductImagePickerState();
}

class ProductImagePickerState extends State<ProductImagePicker> {
  final Map<String, File> _cachedFiles = {};
  final Map<String, Uint8List> _cachedThumbnails = {}; // Add thumbnail cache
  List<AssetPathEntity> _albums = [];
  List<AssetEntity> _mediaList = [];
  Map<String, List<AssetEntity>> _mediaByMonth = {};
  AssetPathEntity? _selectedAlbum;
  bool _isLoading = true;
  final int _pageSize = 50; // Reduced page size
  bool _hasMoreToLoad = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
  }

  @override
  void dispose() {
    // Clear caches when leaving screen
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
      }
    } else {
      debugPrint("Permission denied. Open settings to grant access.");
      openAppSettings();
    }
  }

  // Reset and start fresh when album changes
  void _resetAndFetchMedia() {
    setState(() {
      _isLoading = true;
      _mediaList = [];
      _mediaByMonth = {};
      _currentPage = 0;
      _hasMoreToLoad = true;
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
        setState(() {
          _hasMoreToLoad = false;
          _isLoading = false;
        });
        return;
      }

      // Filter for images only and sort
      final images =
          media.where((asset) => asset.type == AssetType.image).toList();
      images.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

      if (images.isEmpty) {
        setState(() {
          _currentPage++;
          _isLoading = false;
        });
        return;
      }

      // Group by month
      final newMediaByMonth =
          Map<String, List<AssetEntity>>.from(_mediaByMonth);
      for (var asset in images) {
        final month = DateFormat.yMMMM().format(asset.createDateTime);
        if (!newMediaByMonth.containsKey(month)) {
          newMediaByMonth[month] = [];
        }
        newMediaByMonth[month]!.add(asset);

        // Pre-load thumbnails only, not full files
        _loadThumbnail(asset);
      }

      // Update state with new data
      if (mounted) {
        setState(() {
          _mediaByMonth = newMediaByMonth;
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
        _cachedThumbnails[asset.id] = thumbnail;
        // Force a rebuild of affected widgets
        setState(() {});
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
        // Show error if file can't be loaded
        showFloatingSnackBar(
          context,
          'Failed to load image',
          backgroundColor: Colors.red,
        );
        return;
      }
    }

    imageProvider.toggleSelection(asset);
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

    final imageProvider = Provider.of<MediaSelectionProvider>(context);

    return PopScope(
      onPopInvoked: (bool didPop) {
        if (didPop) imageProvider.clearSelection();
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: CustomScrollView(
          controller: scrollController, // Add controller for pagination
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.grey.shade100,
              surfaceTintColor: Colors.grey.shade100,
              floating: true,
              pinned: true,
              leading: GestureDetector(
                onTap: () {
                  // clear storage
                  imageProvider.clearSelection();
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade800,
                    size: 20,
                  ),
                ),
              ),
              title: Row(
                children: [
                  if (_albums.isNotEmpty)
                    Expanded(
                      child: DropdownButton<AssetPathEntity>(
                        underline: const SizedBox(),
                        icon: const Icon(
                          FontAwesome5.chevron_down,
                          size: 15,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Nexa Bold',
                        ),
                        dropdownColor: Colors.white,
                        menuMaxHeight: 500,
                        menuWidth: 250,
                        borderRadius: BorderRadius.circular(10),
                        isExpanded: true,
                        value: _selectedAlbum,
                        items: _albums
                            .map((album) => DropdownMenuItem(
                                  value: album,
                                  child: Text(
                                    album.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize:
                                          album.name == _selectedAlbum!.name
                                              ? 19
                                              : 17,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Nexa Bold',
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedAlbum = value);
                            _resetAndFetchMedia(); // Use the correct method
                          }
                        },
                      ),
                    ),
                  const SizedBox(width: 110),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    // onTap: () => imageProvider.selectedImages.isNotEmpty
                    //     ?
                    //     NavigationHelper.navigateTo(
                    //         context,
                    //         PublishProduct(
                    //           selectedImages: imageProvider.selectedImages,
                    //         ))
                    //     : null,
                    child: Text(
                      imageProvider.selectedImages.isEmpty
                          ? 'Done'
                          : 'Add ${imageProvider.selectedImages.length}',
                      style: TextStyle(
                        color: imageProvider.selectedImages.isNotEmpty
                            ? Colors.grey.shade800
                            : Colors.grey.shade800.withValues(alpha: 0.5),
                        fontFamily: 'Nexa Bold',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Consumer<MediaSelectionProvider>(
              builder: (context, imageProvider, child) {
                if (imageProvider.selectedImages.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox());
                }
                return SliverToBoxAdapter(
                  child: Container(
                    height: 300,
                    padding: const EdgeInsets.only(bottom: 5),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageProvider.selectedImages.length,
                      itemBuilder: (context, index) {
                        final asset = imageProvider.selectedImages[index];
                        // Use cached file if available, otherwise show thumbnail
                        final fileExists = _cachedFiles.containsKey(asset.id);
                        final thumbnailExists =
                            _cachedThumbnails.containsKey(asset.id);

                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 0),
                              ),
                              child: ClipRRect(
                                child: fileExists
                                    ? Image.file(_cachedFiles[asset.id]!,
                                        fit: BoxFit.cover)
                                    : thumbnailExists
                                        ? Image.memory(
                                            _cachedThumbnails[asset.id]!,
                                            fit: BoxFit.cover)
                                        : const Center(
                                            child: CircularProgressIndicator(
                                                color: Color(0xFFa62c71))),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 10,
                              child: GestureDetector(
                                onTap: () =>
                                    imageProvider.toggleSelection(asset),
                                child: const CircleAvatar(
                                  backgroundColor: Color(0xFFa62c71),
                                  radius: 15,
                                  child: Icon(Icons.remove,
                                      size: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            _mediaList.isEmpty && !_isLoading
                ? SliverFillRemaining(
                    child: Center(
                      child: Container(
                        color: Colors.grey.shade100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Nothing to see here...',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: 'Nexa Light',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : _mediaList.isEmpty && _isLoading
                    ? SliverFillRemaining(
                        child: Center(
                          child: Container(
                            color: Colors.grey.shade100,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                    color: Color(0xFFa62c71)),
                                SizedBox(height: 16),
                                Text(
                                  'Loading images...',
                                  style: TextStyle(
                                    color: Color(0xFFa62c71),
                                    fontFamily: 'Nexa Light',
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= _mediaByMonth.length) {
                              return const SizedBox(); // Return empty widget if out of bounds
                            }

                            final month = _mediaByMonth.keys.elementAt(index);
                            final assets = _mediaByMonth[month]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 8, top: 15, bottom: 8),
                                  child: Text(
                                    month,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Nexa Bold',
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                                GridView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 2,
                                    mainAxisSpacing: 2,
                                  ),
                                  itemCount: assets.length,
                                  itemBuilder: (context, gridIndex) {
                                    final asset = assets[gridIndex];
                                    final hasThumbnail =
                                        _cachedThumbnails.containsKey(asset.id);
                                    final isSelected =
                                        imageProvider.isSelected(asset);

                                    return GestureDetector(
                                      onTap: () =>
                                          _toggleSelection(context, asset),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          hasThumbnail
                                              ? Image.memory(
                                                  _cachedThumbnails[asset.id]!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      Container(
                                                          color: Colors
                                                              .grey.shade300),
                                                )
                                              : Container(
                                                  color: Colors.grey.shade300),
                                          if (isSelected)
                                            Container(
                                              color: const Color(0xFFa62c71)
                                                  .withValues(alpha: 0.3),
                                              child: const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                  size: 30),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                          childCount: _mediaByMonth.length,
                        ),
                      ),

            // Add bottom loader for pagination
            if (_isLoading && _mediaList.isNotEmpty && _hasMoreToLoad)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFa62c71)),
                        SizedBox(height: 12),
                        Text(
                          'Loading more...',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Nexa Light',
                            color: Color(0xFFa62c71),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
