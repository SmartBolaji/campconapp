import 'package:flutter/material.dart';

class BuildActionIcon extends StatefulWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final Function onTap;
  final double width;

  const BuildActionIcon({
    Key? key,
    required this.icon,
    required this.count,
    required this.isActive,
    required this.onTap,
    required this.width,
  }) : super(key: key);

  @override
  State<BuildActionIcon> createState() => _BuildActionIconState();
}

class _BuildActionIconState extends State<BuildActionIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant BuildActionIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger the animation when isActive changes to true
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap(),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  widget.icon,
                  color: widget.isActive
                      ? const Color(0xFFBA9E02)
                      : Colors.grey.shade500,
                  size: widget.width / 18,
                ),
              );
            },
          ),
          const SizedBox(width: 5),
          Text(
            '${widget.count}',
            style: TextStyle(
              fontFamily: 'Trebuchet',
              fontSize: widget.width / 28,
              color: widget.isActive
                  ? const Color(0xFFBA9E02)
                  : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
