import 'package:campcon/screens/publish_screen/publish.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:page_transition/page_transition.dart';

class FloatingButton extends StatefulWidget {
  final bool isFabVisible;

  const FloatingButton({Key? key, required this.isFabVisible})
      : super(key: key);

  @override
  State<FloatingButton> createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<FloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Overlay without blur
        if (_isMenuOpen)
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(
              // color: Colors.black.withOpacity(0.6), // Semi-transparent overlay
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        // Floating menu options
        if (_isMenuOpen)
          Padding(
            padding: const EdgeInsets.only(
                bottom: 70, right: 16), // Prevent FAB overlap
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildOption(
                  context,
                  FeatherIcons.calendar,
                  'Event',
                  const Color(0xFFBA9E02),
                  () => _navigateTo(context, const PublishPage()),
                ),
                const SizedBox(height: 10),
                _buildOption(
                  context,
                  FeatherIcons.image,
                  'Photos',
                  const Color(0xFFBA9E02),
                  () => _navigateTo(context, const PublishPage()),
                ),
                const SizedBox(height: 10),
                _buildOption(
                  context,
                  FeatherIcons.checkSquare,
                  'List',
                  const Color(0xFFBA9E02),
                  () => _navigateTo(context, const PublishPage()),
                ),
                const SizedBox(height: 10),
                _buildOption(
                  context,
                  FeatherIcons.edit2,
                  'Post',
                  const Color(0xFFBA9E02),
                  () => _navigateTo(context, const PublishPage()),
                ),
              ],
            ),
          ),
        // Main floating action button
        // Main floating action button (Animated + to X transition)
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: _isMenuOpen ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) {
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: widget.isFabVisible ? 1.0 : 0.0,
              child: FloatingActionButton(
                onPressed: _toggleMenu,
                shape: const CircleBorder(),
                backgroundColor: const Color(0xFFBA9E02),
                child: Transform.rotate(
                  angle: value * 3.14159 / 2, // Rotate the plus sign to form X
                  child: Icon(
                    value == 1.0 ? Icons.close : Icons.add,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.all(Radius.circular(30))),
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
              child: Icon(icon, size: 12, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                fontFamily: 'Trebuchet',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    // custom
    Navigator.push(
      context,
      PageTransition(
        child: page,
        type: PageTransitionType.bottomToTop,
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 500),
      ),
    );

    // close
    setState(() {
      _isMenuOpen = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
