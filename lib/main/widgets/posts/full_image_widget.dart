
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/services/cache.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenImageView extends StatefulWidget {
  final List<String> imageUrls;
  final bool isLiked;
  final Function onLike;
  final int initialIndex;

  const FullScreenImageView({
    Key? key,
    required this.imageUrls,
    required this.isLiked,
    required this.onLike,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  static const int maxVisibleIndicators = 4;
  late PageController _pageController;
  late bool isLiked;
  int _currentIndex = 0;
  bool _showControls = true; // Track if controls are visible

  @override
  void initState() {
    super.initState();
    isLiked = widget.isLiked;
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    await CustomCacheManager().preloadImages(widget.imageUrls);
  }

  void toggleLike() {
    isLiked = !isLiked;
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  List<Widget> _buildLimitedIndicators() {
    final total = widget.imageUrls.length;
    if (total <= 1) return [];

    int visibleIndicators =
        total < maxVisibleIndicators ? total : maxVisibleIndicators;
    int startIndex = (_currentIndex - visibleIndicators ~/ 2)
        .clamp(0, total - visibleIndicators);
    int endIndex = (startIndex + visibleIndicators).clamp(0, total);

    List<Widget> indicators = [];
    if (startIndex > 0) {
      indicators.add(_buildMiniDot());
    }
    for (int i = startIndex; i < endIndex; i++) {
      indicators.add(_buildIndicator(i));
    }
    if (endIndex < total) {
      indicators.add(_buildMiniDot());
    }
    return indicators;
  }

  Widget _buildMiniDot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentIndex == index ? Colors.white : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true, // Extend image behind app bar
      appBar: _showControls
          ? AppBar(
              backgroundColor: Colors.black.withValues(alpha: 0.4),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        toggleLike();
                      });
                      widget.onLike();
                    },
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? const Color(0xFFa62c71) : Colors.white,
                    ),
                  ),
                ),
              ],
            )
          : null, // Hide app bar when controls are hidden
      body: GestureDetector(
        onTap: _toggleControls, // Toggle controls on tap
        child: Stack(
          alignment: Alignment.center,
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(
                    widget.imageUrls[index],
                    cacheManager: CustomCacheManager(),
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  heroAttributes:
                      PhotoViewHeroAttributes(tag: index.toString()),
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading fullscreen image: $error');
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
                );
              },
              loadingBuilder: (context, event) => Center(
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded /
                          (event.expectedTotalBytes ?? 1),
                  color: Colors.white,
                ),
              ),
              itemCount: widget.imageUrls.length,
              pageController: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
            ),
            // Show page indicators only when controls are visible
            if (_showControls && widget.imageUrls.length > 1)
              Positioned(
                bottom: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildLimitedIndicators(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
