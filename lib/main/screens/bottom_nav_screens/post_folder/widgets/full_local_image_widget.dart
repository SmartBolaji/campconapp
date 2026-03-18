import 'dart:io';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenLocalImageView extends StatefulWidget {
  final List<File> images;
  final int initialIndex;

  const FullScreenLocalImageView({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenLocalImageView> createState() =>
      _FullScreenLocalImageViewState();
}

class _FullScreenLocalImageViewState extends State<FullScreenLocalImageView> {
  static const int maxVisibleIndicators = 4;
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  List<Widget> _buildLimitedIndicators() {
    final total = widget.images.length;
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
    final isActive = _currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive ? Colors.white : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showControls
          ? AppBar(
              backgroundColor: Colors.black.withValues(alpha: 0.4),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: FileImage(widget.images[index]),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  heroAttributes: PhotoViewHeroAttributes(
                    tag: 'local_image_$index',
                  ),
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading local image: $error');
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
                            'Image failed to load',
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
                  color: AppTheme.primary,
                ),
              ),
              itemCount: widget.images.length,
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
            if (_showControls && widget.images.length > 1)
              Positioned(
                bottom: 40,
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
