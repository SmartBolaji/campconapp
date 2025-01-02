import 'package:flutter/material.dart';

class BuildActionWithCount extends StatefulWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final Function onTap;

  const BuildActionWithCount({
    Key? key,
    required this.icon,
    required this.count,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  State<BuildActionWithCount> createState() => _BuildActionWithCountState();
}

class _BuildActionWithCountState extends State<BuildActionWithCount>
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
  void didUpdateWidget(covariant BuildActionWithCount oldWidget) {
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
    return Column(
      children: [
        // Count Text
        Text(
          '${widget.count}',
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
            color: widget.isActive
                ? const Color(0xFFBA9E02)
                : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Divider
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          height: 1.5,
          width: 20,
          color:
              widget.isActive ? const Color(0xFFBA9E02) : Colors.grey.shade400,
        ),
        // Action Icon with animation
        GestureDetector(
          onTap: () => widget.onTap(),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  height: 30, // Height of the circular container
                  width: 30, // Width of the circular container
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isActive
                        ? const Color(0xFFBA9E02)
                        : Colors.grey.shade100,
                    border: Border.all(
                      width: 2.5,
                      color: widget.isActive
                          ? const Color(0xFFBA9E02)
                          : Colors.grey.shade500,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.isActive
                        ? Colors.grey.shade100
                        : Colors.grey.shade500,
                    size: 23, // Icon size
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
